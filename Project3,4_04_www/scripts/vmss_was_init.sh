#!/bin/bash
set -e
set -o pipefail

# 로깅 설정
LOG_FILE="/var/log/lupang_setup.log"
ERROR_LOG="/var/log/lupang_error.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$ERROR_LOG" >&2)

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

log "========================================="
log "Lupang Shopping Mall WAS 초기화 (V3.0 Enterprise)"
log "========================================="

# 1. 멱등성 체크 (이미 설치되었으면 종료)
COMPLETE_FLAG="/tmp/lupang_init_complete.txt"
if [ -f "$COMPLETE_FLAG" ]; then
    if rpm -q httpd >/dev/null 2>&1; then
        log "초기화가 이미 완료되었습니다. 스킵합니다."
        exit 0
    fi
fi

# 2. 시스템 설정 (SELinux, 방화벽)
log "[1/9] SELinux 비활성화 중..."
setenforce 0 2>/dev/null || log "WARNING: setenforce 실패 (무시)"
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 2>/dev/null || true

log "[2/9] 방화벽 설정 중..."
systemctl enable firewalld 2>/dev/null || true
systemctl start firewalld 2>/dev/null || true
firewall-cmd --permanent --add-service=http 2>/dev/null || true
firewall-cmd --permanent --add-service=https 2>/dev/null || true
firewall-cmd --reload 2>/dev/null || true

# 3. 패키지 설치
log "[3/9] 패키지 설치 확인 중..."
if ! rpm -q httpd >/dev/null 2>&1; then
    log "패키지 설치 시작..."
    dnf update -y || error_exit "dnf update 실패"
    dnf install -y httpd php php-mysqlnd php-gd php-json php-mbstring mysql git || error_exit "패키지 설치 실패"
else
    log "httpd가 이미 설치되어 있습니다. 스킵"
fi

# 4. 디렉토리 및 로그 파일 설정
log "[4/9] 웹 디렉토리 및 로그 파일 준비 중..."
mkdir -p /var/www/html/uploads
chmod -R 755 /var/www/html
chmod 777 /var/www/html/uploads

# Sentinel 연동을 위한 JSON 로그 파일 생성
touch /var/log/lupang_app.json
chmod 666 /var/log/lupang_app.json

# Health check 파일 생성 (LB용)
cat > /var/www/html/health.php <<'EOF'
<?php
if (isset($_GET['status']) && $_GET['status'] == 500) {
    http_response_code(500);
    echo "Service Down";
} else {
    http_response_code(200);
    echo "OK";
}
?>
EOF

# 5. DB 연결 및 추가 테이블 생성
log "[5/9] DB 설정 및 테이블 초기화..."
cat > /var/www/html/db_config.php <<'EOF'
<?php
$host = "${db_host}";
$user = "${db_user}";
$pass = "${db_password}";
$db   = "${db_name}";

$conn = new mysqli($host, $user, $pass, $db);

// DB 연결 실패 로그 (JSON)
if ($conn->connect_error) {
    $log = ['timestamp' => date('c'), 'level' => 'CRITICAL', 'action' => 'DB_CONNECTION', 'message' => $conn->connect_error];
    file_put_contents('/var/log/lupang_app.json', json_encode($log) . "\n", FILE_APPEND);
    die("DB Connection Failed");
}

// [핵심] JSON 구조화 로깅 함수 (Sentinel 연동 최적화)
function writeLog($action, $level, $msg, $extra = []) {
    $logEntry = [
        'timestamp' => date('c'),
        'client_ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
        'user_agent'=> $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
        'method'    => $_SERVER['REQUEST_METHOD'] ?? 'unknown',
        'uri'       => $_SERVER['REQUEST_URI'] ?? 'unknown',
        'action'    => $action,
        'level'     => $level,
        'message'   => $msg,
        'details'   => $extra
    ];
    // 한 줄에 하나의 JSON 객체 저장
    file_put_contents('/var/log/lupang_app.json', json_encode($logEntry) . "\n", FILE_APPEND);
}
?>
EOF

# 문의 게시판용 테이블 생성 (안전하게 시도)
mysql -h "${db_host}" -u "${db_user}" -p"${db_password}" "${db_name}" -e "CREATE TABLE IF NOT EXISTS inquiries (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50), title VARCHAR(100), filename VARCHAR(255), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);" 2>/dev/null || log "WARNING: 테이블 생성 시도 실패 (DB 연결 문제일 수 있음)"

log "[6/9] PHP 웹 애플리케이션 파일 생성 (V3.0)..."

# [Header] V3.0
cat > /var/www/html/header.php <<'EOF'
<?php
if(session_status() === PHP_SESSION_NONE) session_start();
include_once 'db_config.php';

$currentUser = null;
if (isset($_COOKIE['lupang_token'])) {
    $decoded = base64_decode($_COOKIE['lupang_token']);
    $currentUser = json_decode($decoded, true);
}
?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lupang V3 - Enterprise</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f0f2f5; font-family: 'Noto Sans KR', sans-serif; }
        .navbar-lupang { background-color: white; border-bottom: 1px solid #ddd; padding: 15px 0; }
        .logo { color: #e60023; font-weight: 900; font-size: 28px; text-decoration: none; }
        .logo:hover { color: #e60023; }
        .search-input { border: 2px solid #e60023; border-radius: 4px 0 0 4px; border-right: none; }
        .search-btn { background-color: #e60023; color: white; border: none; width: 50px; border-radius: 0 4px 4px 0; }
        .nav-link { color: #333; font-size: 13px; }
        .nav-link:hover { color: #e60023; }
        .admin-badge { background-color: #dc3545; color: white; padding: 2px 5px; border-radius: 3px; font-size: 10px; }
    </style>
</head>
<body>
<nav class="navbar-lupang sticky-top">
    <div class="container">
        <a href="index.php" class="logo me-4">Lupang!</a>
        
        <form action="search.php" method="GET" class="d-flex flex-grow-1 me-4">
            <input type="text" name="q" class="form-control search-input" placeholder="검색어를 입력하세요">
            <button type="submit" class="search-btn"><i class="fas fa-search"></i></button>
        </form>
        
        <div class="d-flex align-items-center gap-3">
            <?php if($currentUser): ?>
                <a href="mypage.php" class="nav-link text-center">
                    <i class="fas fa-user fs-5 d-block mb-1"></i>
                    <?php echo htmlspecialchars($currentUser['username']); ?>
                    <?php if(isset($currentUser['role']) && $currentUser['role'] === 'admin') echo '<span class="admin-badge">ADMIN</span>'; ?>
                </a>
                <a href="inquiry.php" class="nav-link text-center">
                    <i class="fas fa-headset fs-5 d-block mb-1"></i>
                    1:1문의
                </a>
                <a href="logout.php" class="nav-link text-center">
                    <i class="fas fa-sign-out-alt fs-5 d-block mb-1"></i>
                    로그아웃
                </a>
            <?php else: ?>
                <a href="login.php" class="nav-link text-center"><i class="fas fa-user fs-5 d-block mb-1"></i>로그인</a>
            <?php endif; ?>
        </div>
    </div>
</nav>
<div class="container mt-4 mb-5" style="min-height: 700px;">
EOF

# [Footer]
cat > /var/www/html/footer.php <<'EOF'
</div>
<footer class="mt-5 py-4 bg-white border-top text-center text-muted">
    <small>
        (주)루팡 | 대표: 아무개 | 서울특별시 송파구 송파대로 570<br>
        사업자등록번호: 000-00-00000 | 통신판매업신고: 2025-서울송파-0000<br>
        본 사이트는 모의해킹 실습을 위해 제작된 <strong>가상 사이트</strong>입니다.
    </small>
</footer>
</body>
</html>
EOF

# [Index] V3.0 (Picsum 이미지 적용)
cat > /var/www/html/index.php <<'EOF'
<?php include 'header.php'; ?>

<!-- 메인 배너 -->
<div id="mainBanner" class="carousel slide mb-5 rounded overflow-hidden shadow-sm" data-bs-ride="carousel">
    <div class="carousel-inner">
        <div class="carousel-item active">
            <img src="https://picsum.photos/id/29/1200/400" class="d-block w-100" alt="Banner">
            <div class="carousel-caption d-none d-md-block text-start" style="text-shadow: 2px 2px 4px rgba(0,0,0,0.7);">
                <h1 class="fw-bold">와우회원 전용 특가</h1>
                <p class="fs-4">최대 50% 할인 + 로켓배송 🚀</p>
            </div>
        </div>
    </div>
</div>

<h3 class="fw-bold mb-3">오늘의 추천 상품</h3>
<div class="row row-cols-1 row-cols-md-4 g-3">
    <?php
    $sql = "SELECT * FROM products";
    $result = $conn->query($sql);
    if($result && $result->num_rows > 0):
        while($row = $result->fetch_assoc()):
            $discount = rand(5, 30);
    ?>
    <div class="col">
        <a href="product.php?id=<?php echo $row['id']; ?>" class="text-decoration-none text-dark">
            <div class="card h-100 border-0 shadow-sm">
                <img src="<?php echo $row['image_url']; ?>" class="card-img-top" style="height: 200px; object-fit: contain;">
                <div class="card-body">
                    <h5 class="card-title text-truncate"><?php echo $row['name']; ?></h5>
                    <div class="text-danger fw-bold fs-5">
                        <span class="fs-6 text-muted text-decoration-line-through me-1"><?php echo $discount; ?>%</span>
                        <?php echo number_format($row['price']); ?>원
                    </div>
                    <span class="badge bg-primary"><i class="fas fa-rocket"></i> 로켓배송</span>
                    <p class="text-success small fw-bold mt-2">내일(목) 새벽 7시 도착 보장</p>
                </div>
            </div>
        </a>
    </div>
    <?php endwhile; else: ?>
        <div class="col-12"><div class="alert alert-info">상품 데이터가 없습니다. DB 연결을 확인하세요.</div></div>
    <?php endif; ?>
</div>
<?php include 'footer.php'; ?>
EOF

# [Login] V3.0 (JSON 로깅 적용)
cat > /var/www/html/login.php <<'EOF'
<?php
include 'db_config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user = $_POST['username'];
    $pass = $_POST['password'];
    
    // Prepared Statement
    $stmt = $conn->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
    $stmt->bind_param("ss", $user, $pass);
    $stmt->execute();
    $res = $stmt->get_result();
    
    if ($row = $res->fetch_assoc()) {
        writeLog('LOGIN', 'INFO', 'Login Success', ['username' => $user]);
        
        // [취약점] 쿠키 평문 저장
        $tokenData = ['id' => $row['id'], 'username' => $row['username'], 'role' => $row['role']];
        $token = base64_encode(json_encode($tokenData));
        setcookie('lupang_token', $token, time() + 3600, '/');
        
        echo "<script>location.href='index.php';</script>";
    } else {
        // Brute Force 탐지용 로그
        writeLog('LOGIN', 'WARN', 'Login Failed', ['username' => $user, 'attempt_pass' => $pass]);
        echo "<script>alert('아이디 또는 비밀번호가 일치하지 않습니다.');</script>";
    }
}
?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인 - Lupang</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center justify-content-center" style="height: 100vh;">
    <div class="bg-white p-5 rounded shadow text-center" style="width: 400px;">
        <h1 class="text-danger fw-bold mb-4">Lupang!</h1>
        <form method="POST">
            <div class="mb-3">
                <input type="text" name="username" class="form-control" placeholder="아이디" required>
            </div>
            <div class="mb-3">
                <input type="password" name="password" class="form-control" placeholder="비밀번호" required>
            </div>
            <button type="submit" class="btn btn-danger w-100 py-2">로그인</button>
        </form>
        <div class="mt-3 text-muted small">테스트 계정: hacker / 1234</div>
    </div>
</body>
</html>
EOF

# [MyPage] V3.0 (관리자 버튼 추가)
cat > /var/www/html/mypage.php <<'EOF'
<?php include 'header.php'; ?>
<?php
if (!$currentUser) {
    echo "<script>alert('로그인이 필요합니다.'); location.href='login.php';</script>";
    exit;
}

$userId = $currentUser['id']; 
$sql = "SELECT * FROM users WHERE id = $userId";
$result = $conn->query($sql);
$userData = $result->fetch_assoc();

writeLog('MYPAGE_ACCESS', 'INFO', 'User Accessed Mypage', ['uid' => $userId]);
?>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card p-4">
                <div class="text-center mb-4">
                    <h4><?php echo $userData['real_name']; ?> 님</h4>
                    <span class="badge bg-warning text-dark"><?php echo $userData['role']; ?></span>
                </div>
                <ul class="list-group list-group-flush mb-4">
                    <li class="list-group-item"><strong>아이디:</strong> <?php echo $userData['username']; ?></li>
                    <li class="list-group-item"><strong>전화번호:</strong> <?php echo $userData['phone']; ?></li>
                    <li class="list-group-item"><strong>배송지:</strong> <?php echo $userData['address']; ?></li>
                </ul>
                
                <?php if(isset($currentUser['role']) && $currentUser['role'] === 'admin'): ?>
                    <div class="alert alert-danger">
                        <strong>[관리자 권한 확인됨]</strong><br>
                        <a href="admin_dashboard.php" class="btn btn-danger mt-2 w-100">
                            <i class="fas fa-lock me-2"></i>관리자 대시보드 접속
                        </a>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>
<?php include 'footer.php'; ?>
EOF

# [Admin Dashboard] 신규 추가 (DB 덤프 시뮬레이션)
cat > /var/www/html/admin_dashboard.php <<'EOF'
<?php include 'header.php'; ?>
<?php
if (!$currentUser || $currentUser['role'] !== 'admin') {
    writeLog('ADMIN_ACCESS', 'ERROR', 'Unauthorized Admin Access Attempt', ['user' => $currentUser]);
    echo "<div class='alert alert-danger m-5'>🚫 관리자만 접근 가능합니다. (IP가 기록되었습니다)</div>";
    include 'footer.php';
    exit;
}

writeLog('ADMIN_ACCESS', 'INFO', 'Admin Dashboard Access', ['user' => $currentUser['username']]);

if (isset($_POST['download_db'])) {
    writeLog('DATA_EXFILTRATION', 'CRITICAL', 'Admin Downloaded Full DB Dump', ['user' => $currentUser['username']]);
    echo "<script>alert('전체 회원 정보(150,000건) 다운로드가 시작됩니다.');</script>";
}
?>
<div class="container">
    <h2 class="text-danger mb-4">관리자 대시보드</h2>
    <div class="card border-danger mb-4">
        <div class="card-header bg-danger text-white">⚠️ 중요 데이터 접근</div>
        <div class="card-body">
            <p>고객 정보를 포함한 전체 DB 백업 파일을 다운로드합니다. 이 작업은 감사 로그에 기록됩니다.</p>
            <form method="POST">
                <button type="submit" name="download_db" class="btn btn-dark">
                    <i class="fas fa-download me-2"></i>전체 회원 DB 다운로드 (.sql)
                </button>
            </form>
        </div>
    </div>
</div>
<?php include 'footer.php'; ?>
EOF

# [Inquiry] 신규 추가 (파일 업로드 취약점)
cat > /var/www/html/inquiry.php <<'EOF'
<?php include 'header.php'; ?>
<?php
if (!$currentUser) echo "<script>location.href='login.php';</script>";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title = $_POST['title'];
    if (isset($_FILES['file']) && $_FILES['file']['error'] == 0) {
        $target_dir = "uploads/";
        $filename = basename($_FILES["file"]["name"]);
        $target_file = $target_dir . $filename;
        
        // [취약점] 확장자 검사 없음
        if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
            writeLog('FILE_UPLOAD', 'WARN', 'File Uploaded', ['filename' => $filename, 'user' => $currentUser['username']]);
            echo "<div class='alert alert-success'>문의 접수 완료. 파일: <a href='uploads/$filename' target='_blank'>$filename</a></div>";
        } else {
            writeLog('FILE_UPLOAD', 'ERROR', 'Upload Failed');
        }
    }
}
?>
<div class="container">
    <h3 class="mb-4">1:1 문의하기</h3>
    <div class="card">
        <div class="card-body">
            <form method="POST" enctype="multipart/form-data">
                <div class="mb-3">
                    <label>제목</label>
                    <input type="text" name="title" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label>첨부파일 (이미지 등)</label>
                    <input type="file" name="file" class="form-control">
                </div>
                <button type="submit" class="btn btn-primary w-100">문의 등록</button>
            </form>
        </div>
    </div>
</div>
<?php include 'footer.php'; ?>
EOF

# [Stress Test] 신규 추가 (부하 테스트)
cat > /var/www/html/stress.php <<'EOF'
<?php
include 'db_config.php';
$duration = isset($_GET['t']) ? (int)$_GET['t'] : 1; 
$start = microtime(true);
$count = 0;
while(microtime(true) - $start < $duration) {
    for($i=0; $i<1000; $i++) hash('sha256', 'stress'.$i);
    $conn->query("SELECT 1"); 
    $count++;
}
echo "Stress Test Completed. Loops: $count";
writeLog('STRESS_TEST', 'INFO', 'Stress Test Triggered', ['loops' => $count]);
?>
EOF

# [Product], [Search], [Logout] (기존 파일 유지)
cat > /var/www/html/logout.php <<'EOF'
<?php
setcookie('lupang_token', '', time() - 3600, '/');
header('Location: index.php');
?>
EOF

cat > /var/www/html/product.php <<'EOF'
<?php include 'header.php'; ?>
<?php
$id = $_GET['id']; 
$sql = "SELECT * FROM products WHERE id = $id";
$result = $conn->query($sql);
$product = $result ? $result->fetch_assoc() : null;

if($_SERVER['REQUEST_METHOD'] === 'POST') {
    $comment = $_POST['comment'];
    $uname = $currentUser ? $currentUser['username'] : 'Guest';
    $insert = "INSERT INTO reviews (product_id, username, comment) VALUES ('$id', '$uname', '$comment')";
    $conn->query($insert);
}
?>
<?php if($product): ?>
<div class="row">
    <div class="col-md-5"><img src="<?php echo $product['image_url']; ?>" class="img-fluid rounded"></div>
    <div class="col-md-7">
        <h2><?php echo $product['name']; ?></h2>
        <hr><h3 class="text-danger"><?php echo number_format($product['price']); ?>원</h3>
        <p class="mt-4"><?php echo $product['description']; ?></p>
        <button class="btn btn-danger w-50 btn-lg">바로구매</button>
    </div>
</div>
<div class="mt-5">
    <h4>상품평</h4>
    <form method="POST" class="mb-4">
        <textarea name="comment" class="form-control mb-2" rows="3" placeholder="상품평을 남겨주세요"></textarea>
        <button type="submit" class="btn btn-primary">등록</button>
    </form>
    <ul class="list-group list-group-flush">
        <?php
        $rSql = "SELECT * FROM reviews WHERE product_id = $id ORDER BY id DESC";
        $rRes = $conn->query($rSql);
        if($rRes) while($review = $rRes->fetch_assoc()) {
            echo "<li class='list-group-item'><strong>" . $review['username'] . "</strong>: " . $review['comment'] . "</li>";
        }
        ?>
    </ul>
</div>
<?php else: ?>
    <div class="alert alert-danger">상품이 존재하지 않습니다.</div>
<?php endif; ?>
<?php include 'footer.php'; ?>
EOF

cat > /var/www/html/search.php <<'EOF'
<?php include 'header.php'; ?>
<?php $q = $_GET['q'] ?? ''; ?>
<div class="mb-4"><h3>'<span class="text-danger"><?php echo $q; ?></span>'에 대한 검색 결과</h3></div>
<div class="alert alert-secondary">검색 결과가 없습니다. (XSS 테스트용 페이지)</div>
<?php include 'footer.php'; ?>
EOF

log "[7/9] 파일 권한 설정 중..."
chown -R apache:apache /var/www/html 2>/dev/null || chown -R www:www /var/www/html 2>/dev/null || true
chmod -R 755 /var/www/html
chmod 777 /var/www/html/uploads

log "[8/9] Apache 웹서버 시작 중..."
systemctl enable httpd || error_exit "Apache enable 실패"
systemctl start httpd || error_exit "Apache 시작 실패"
sleep 2
systemctl is-active httpd || error_exit "Apache가 실행되지 않음"

# 완료 표시
date > "$COMPLETE_FLAG"

log "========================================="
log "✅ Lupang V3.0 초기화 완료!"
log "========================================="
log "JSON 로그: /var/log/lupang_app.json"
EOF