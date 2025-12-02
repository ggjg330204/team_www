#!/bin/bash
# WAS VMSS 초기화 스크립트 (Dark Mode & KOR & Enhanced Security Labs)
# 작성일: 2025-12-02
# 로깅 설정
LOG_FILE="/var/log/was_init.log"
exec >> "$LOG_FILE" 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=========================================="
log "WAS VMSS 초기화 시작 (Korean/Dark Mode)"
log "=========================================="

# 완료 플래그 파일 확인 (멱등성)
COMPLETE_FLAG="/tmp/was_init_complete.txt"
if [ -f "$COMPLETE_FLAG" ]; then
    if rpm -q httpd >/dev/null 2>&1; then
        log "초기화가 이미 완료되었습니다. 스킵합니다."
        exit 0
    fi
fi

# SELinux 비활성화 (실습을 위해 보안 약화, 실제 운영시엔 켜야 함)
setenforce 0 2>/dev/null
grubby --update-kernel ALL --args selinux=0 2>/dev/null

# 방화벽 설정
systemctl enable firewalld 2>/dev/null
systemctl start firewalld 2>/dev/null
firewall-cmd --zone=public --add-service=http --permanent 2>/dev/null
firewall-cmd --zone=public --add-service=https --permanent 2>/dev/null
firewall-cmd --reload 2>/dev/null

# DNF 최적화 및 패키지 설치
if ! rpm -q httpd >/dev/null 2>&1; then
    log "httpd, PHP, MySQL 클라이언트 패키지 설치"
    dnf install -y httpd php php-mysqlnd php-gd php-curl mysql git 2>/dev/null
else
    log "패키지가 이미 설치되어 있습니다. 스킵"
fi

# 웹 디렉터리 설정
mkdir -p /var/www/html
chmod 755 /var/www/html
mkdir -p /var/www/html/uploads
chmod 777 /var/www/html/uploads

# Health check 파일 생성
if [ ! -f /var/www/html/health.html ]; then
    echo "OK" > /var/www/html/health.html
    chmod 644 /var/www/html/health.html
fi

# DB 연결 설정 파일 생성
cat > /var/www/html/db_connect.php <<EOF
<?php
\$servername = "${db_host}";
\$username = "${db_user}";
\$password = "${db_password}";
\$dbname = "${db_name}";

// Create connection
\$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

// Check connection
if (\$conn->connect_error) {
    die("DB 연결 실패: " . \$conn->connect_error);
}
?>
EOF

# 메인 페이지 (index.php) - 다크 모드 & 애니메이션 적용
cat > /var/www/html/index.php <<EOF
<?php include 'db_connect.php'; ?>
<!DOCTYPE html>
<html lang="ko" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Azure Cloud Security Demo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
    <style>
        body { background-color: #121212; color: #e0e0e0; font-family: 'Noto Sans KR', sans-serif; }
        .hero { 
            background: linear-gradient(135deg, #0f2027, #203a43, #2c5364); 
            color: white; 
            padding: 60px 0; 
            border-bottom: 2px solid #00d4ff;
        }
        .card { 
            background-color: #1e1e1e; 
            border: 1px solid #333; 
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.5);
            border-color: #00d4ff;
        }
        .badge-custom { font-size: 0.9em; padding: 8px 12px; }
        .security-alert { border-left: 4px solid #ff4444; background: #2c1e1e; }
        .architecture-info { border-left: 4px solid #00d4ff; background: #1e2a30; }
        
        /* Animation Delays */
        .delay-1 { animation-delay: 0.2s; }
        .delay-2 { animation-delay: 0.4s; }
        .delay-3 { animation-delay: 0.6s; }
    </style>
</head>
<body>
    <div class="hero text-center animate__animated animate__fadeIn">
        <h1 class="display-4 fw-bold">Azure Cloud Security Labs</h1>
        <p class="lead">보안 아키텍처 검증 및 취약점 시뮬레이션 환경</p>
        <span class="badge bg-primary">VMSS Instance</span>
        <span class="badge bg-info text-dark">PHP 8.x</span>
        <span class="badge bg-warning text-dark">OWASP Top 10 Demo</span>
    </div>

    <div class="container mt-5">
        <!-- 시스템 정보 및 아키텍처 현황 -->
        <div class="row mb-4 animate__animated animate__fadeInUp">
            <div class="col-12">
                <div class="card p-4 architecture-info">
                    <h3>🛡️ 아키텍처 보안 현황판</h3>
                    <div class="row mt-3">
                        <div class="col-md-3">
                            <strong>서버 호스트:</strong><br>
                            <span class="text-info"><?php echo gethostname(); ?></span>
                        </div>
                        <div class="col-md-3">
                            <strong>내부 IP / Zone:</strong><br>
                            <?php echo \$_SERVER['SERVER_ADDR']; ?> / 
                            <span class="badge bg-secondary"><?php echo \$_SERVER['HTTP_X_AZURE_ZONE'] ?? 'N/A'; ?></span>
                        </div>
                        <div class="col-md-3">
                            <strong>WAF 통과 여부 (추정):</strong><br>
                            <?php
                            \$waf_headers = ['X-AppGw-Trace-Id', 'X-Azure-WAF'];
                            \$detected = false;
                            foreach(\$waf_headers as \$h) {
                                if(isset(\$_SERVER['HTTP_'.str_replace('-', '_', strtoupper(\$h))])) \$detected = true;
                            }
                            echo \$detected ? '<span class="badge bg-success">WAF 탐지됨 (Safe)</span>' : '<span class="badge bg-danger">WAF 미탐지 (Direct Access?)</span>';
                            ?>
                        </div>
                        <div class="col-md-3">
                            <strong>암호화 통신 (SSL):</strong><br>
                            <?php echo (isset(\$_SERVER['HTTPS']) && \$_SERVER['HTTPS'] === 'on') ? '<span class="badge bg-success">HTTPS 적용됨</span>' : '<span class="badge bg-danger">HTTP (Insecure)</span>'; ?>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- DB 상태 -->
            <div class="col-md-4 mb-4 animate__animated animate__fadeInLeft delay-1">
                <div class="card h-100">
                    <div class="card-body">
                        <h4 class="card-title text-warning">💾 데이터베이스 상태</h4>
                        <hr>
                        <?php
                        if (\$conn->ping()) {
                            echo '<div class="alert alert-success border-0">✅ 연결 성공</div>';
                            echo '<p class="small text-muted">Host: ' . \$servername . '</p>';
                        } else {
                            echo '<div class="alert alert-danger border-0">❌ 연결 실패</div>';
                        }
                        ?>
                    </div>
                </div>
            </div>

            <!-- 보안 실습 메뉴 -->
            <div class="col-md-8 mb-4 animate__animated animate__fadeInRight delay-2">
                <div class="card h-100">
                    <div class="card-body">
                        <h4 class="card-title text-danger">⚠️ 취약점 점검 랩 (OWASP Top 10)</h4>
                        <p class="text-muted small">아래 항목들은 보안 설정(WAF, NSG, Input Validation)을 검증하기 위해 의도적으로 취약하게 제작되었습니다.</p>
                        <hr>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <a href="login.php" class="btn btn-outline-danger w-100 text-start p-3">
                                    <strong>💉 SQL Injection</strong><br>
                                    <small>로그인 우회 및 데이터 유출 시도</small>
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="guestbook.php" class="btn btn-outline-warning w-100 text-start p-3">
                                    <strong>📜 XSS (크로스 사이트 스크립팅)</strong><br>
                                    <small>악성 스크립트 실행 테스트</small>
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="upload.php" class="btn btn-outline-info w-100 text-start p-3">
                                    <strong>file_upload File Upload & Webshell</strong><br>
                                    <small>악성 파일 업로드 차단 검증</small>
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="ssrf.php" class="btn btn-outline-light w-100 text-start p-3">
                                    <strong>☁️ SSRF & IMDS Access</strong><br>
                                    <small>Azure 메타데이터(169.254...) 접근 시도</small>
                                </a>
                            </div>
                             <div class="col-md-6">
                                <a href="cmd.php" class="btn btn-outline-secondary w-100 text-start p-3">
                                    <strong>💻 Command Injection</strong><br>
                                    <small>시스템 명령어 실행(OS Command) 시도</small>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 데이터 복제 모니터링 -->
        <div class="row mt-2 animate__animated animate__fadeInUp delay-3">
            <div class="col-12">
                <div class="card p-3">
                    <h4>📡 실시간 데이터 복제 모니터링</h4>
                    <p class="text-muted">가용성 영역(Zone) 간 데이터 동기화 상태를 확인합니다.</p>
                    <table class="table table-dark table-hover table-striped">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Server ID</th>
                                <th>Zone</th>
                                <th>Timestamp</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            \$sql = "SELECT * FROM replication_test ORDER BY id DESC LIMIT 5";
                            \$result = \$conn->query(\$sql);
                            if (\$result && \$result->num_rows > 0) {
                                while(\$row = \$result->fetch_assoc()) {
                                    echo "<tr><td>" . \$row["id"]. "</td><td>" . \$row["server_id"]. "</td><td>" . \$row["zone"]. "</td><td>" . \$row["timestamp"]. "</td></tr>";
                                }
                            } else {
                                echo "<tr><td colspan='4' class='text-center'>데이터가 없습니다.</td></tr>";
                            }
                            ?>
                        </tbody>
                    </table>
                    <form method="post" action="generate_data.php" class="d-grid gap-2 d-md-flex justify-content-md-end">
                        <button type="submit" class="btn btn-success">테스트 데이터 생성</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <footer class="text-center mt-5 mb-3 text-muted">
        <small>&copy; 2025 Azure Cloud Architecture Demo Team</small>
    </footer>
</body>
</html>
EOF

# [취약점 1] SQL Injection (Korean & Dark)
cat > /var/www/html/login.php <<EOF
<?php include 'db_connect.php'; ?>
<!DOCTYPE html>
<html lang="ko" data-bs-theme="dark">
<head><title>SQL Injection Lab</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"></head>
<body class="container mt-5">
    <div class="card p-4 mx-auto" style="max-width: 500px;">
        <h2 class="mb-3 text-danger">SQL 인젝션 로그인</h2>
        <p class="text-muted"><code>' OR '1'='1</code> 같은 구문을 입력해보세요.</p>
        <form method="POST">
            <div class="mb-3">
                <label>사용자명 (Username)</label>
                <input type="text" name="username" class="form-control" placeholder="admin">
            </div>
            <div class="mb-3">
                <label>비밀번호 (Password)</label>
                <input type="password" name="password" class="form-control">
            </div>
            <button type="submit" class="btn btn-danger w-100">로그인 시도</button>
        </form>
        <hr>
        <?php
        if (\$_SERVER["REQUEST_METHOD"] == "POST") {
            \$username = \$_POST['username'];
            \$password = \$_POST['password'];
            
            // 취약한 코드: 입력값 검증 없음
            \$sql = "SELECT * FROM users WHERE username = '\$username' AND password = '\$password'";
            echo "<div class='alert alert-secondary'><strong>실행된 쿼리:</strong><br><code>\$sql</code></div>";
            
            if(\$conn) {
                \$result = \$conn->query(\$sql);
                if (\$result && \$result->num_rows > 0) {
                    echo "<div class='alert alert-success'>🎉 로그인 성공! 환영합니다, " . htmlspecialchars(\$username) . "</div>";
                } else {
                    echo "<div class='alert alert-danger'>로그인 실패</div>";
                }
            }
        }
        ?>
        <a href="index.php" class="btn btn-outline-light w-100 mt-2">메인으로 돌아가기</a>
    </div>
</body>
</html>
EOF

# [취약점 2] XSS (Korean & Dark)
cat > /var/www/html/guestbook.php <<EOF
<?php include 'db_connect.php'; ?>
<!DOCTYPE html>
<html lang="ko" data-bs-theme="dark">
<head><title>XSS Lab</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"></head>
<body class="container mt-5">
    <div class="row">
        <div class="col-md-6">
            <div class="card p-4">
                <h2 class="text-warning">방명록 (XSS 취약)</h2>
                <p>메시지에 <code>&lt;script&gt;alert(1)&lt;/script&gt;</code>를 입력해보세요.</p>
                <form method="POST">
                    <div class="mb-3">
                        <label>작성자</label>
                        <input type="text" name="username" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label>메시지</label>
                        <textarea name="message" class="form-control" rows="3"></textarea>
                    </div>
                    <button type="submit" class="btn btn-warning w-100 text-dark">방명록 남기기</button>
                </form>
            </div>
            <a href="index.php" class="btn btn-outline-light mt-3">메인으로 돌아가기</a>
        </div>
        <div class="col-md-6">
            <h4 class="mt-2">📝 최근 게시글</h4>
            <?php
            if (\$_SERVER["REQUEST_METHOD"] == "POST") {
                \$username = \$_POST['username'];
                \$message = \$_POST['message'];
                if(\$conn) {
                    \$stmt = \$conn->prepare("INSERT INTO guestbook (username, message) VALUES (?, ?)");
                    \$stmt->bind_param("ss", \$username, \$message);
                    \$stmt->execute();
                }
            }
            
            if(\$conn) {
                \$sql = "SELECT * FROM guestbook ORDER BY id DESC LIMIT 10";
                \$result = \$conn->query(\$sql);
                
                while(\$row = \$result->fetch_assoc()) {
                    // 취약한 코드: htmlspecialchars 미사용
                    echo "<div class='card mb-2 border-secondary'><div class='card-body'>";
                    echo "<h5 class='card-title text-info'>" . \$row['username'] . "</h5>";
                    echo "<p class='card-text'>" . \$row['message'] . "</p>";
                    echo "<small class='text-muted'>" . \$row['created_at'] . "</small>";
                    echo "</div></div>";
                }
            }
            ?>
        </div>
    </div>
</body>
</html>
EOF

# [취약점 3] File Upload (Korean & Dark)
cat > /var/www/html/upload.php <<EOF
<!DOCTYPE html>
<html lang="ko" data-bs-theme="dark">
<head><title>File Upload Lab</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"></head>
<body class="container mt-5">
    <div class="card p-4 mx-auto" style="max-width: 600px;">
        <h2 class="text-info">파일 업로드 취약점</h2>
        <p>PHP 파일 등 실행 가능한 파일을 업로드하여 웹쉘(Webshell) 공격 가능성을 테스트합니다.</p>
        <form action="upload_handler.php" method="post" enctype="multipart/form-data">
            <div class="mb-3">
                <label class="form-label">업로드할 파일 선택</label>
                <input type="file" name="fileToUpload" id="fileToUpload" class="form-control">
            </div>
            <button type="submit" class="btn btn-info text-dark w-100">파일 업로드</button>
        </form>
        <a href="index.php" class="btn btn-outline-light w-100 mt-3">메인으로 돌아가기</a>
    </div>
</body>
</html>
EOF

cat > /var/www/html/upload_handler.php <<EOF
<?php
\$target_dir = "uploads/";
if (!file_exists(\$target_dir)) {
    mkdir(\$target_dir, 0777, true);
}
\$target_file = \$target_dir . basename(\$_FILES["fileToUpload"]["name"]);

echo '<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">';
echo '<body class="container mt-5" data-bs-theme="dark">';

// 취약한 코드: 확장자 검사 미흡
if (move_uploaded_file(\$_FILES["fileToUpload"]["tmp_name"], \$target_file)) {
    echo "<div class='alert alert-success'>파일이 업로드 되었습니다: " . htmlspecialchars( basename( \$_FILES["fileToUpload"]["name"])). "</div>";
    echo "<p>저장 경로: <a href='\$target_file' target='_blank'>\$target_file</a></p>";
} else {
    echo "<div class='alert alert-danger'>업로드 중 오류 발생</div>";
}
echo '<a href="upload.php" class="btn btn-secondary">돌아가기</a>';
echo '</body>';
?>
EOF

# [취약점 4] SSRF & Cloud Metadata (Azure 특화)
cat > /var/www/html/ssrf.php <<EOF
<!DOCTYPE html>
<html lang="ko" data-bs-theme="dark">
<head><title>SSRF Lab</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"></head>
<body class="container mt-5">
    <div class="card p-4">
        <h2 class="text-light">☁️ SSRF (Azure IMDS) 테스트</h2>
        <p>서버가 외부 또는 내부 자원을 요청하도록 유도합니다. 클라우드 환경에서는 <code>169.254.169.254</code>(메타데이터) 접근 여부가 중요합니다.</p>
        
        <form method="POST">
            <div class="input-group mb-3">
                <span class="input-group-text">Target URL</span>
                <input type="text" name="url" class="form-control" value="http://169.254.169.254/metadata/instance?api-version=2021-02-01">
            </div>
            <div class="form-check mb-3">
                <input class="form-check-input" type="checkbox" name="header_check" id="headerCheck" checked>
                <label class="form-check-label" for="headerCheck">Metadata: true 헤더 포함 (Azure 필수)</label>
            </div>
            <button type="submit" class="btn btn-primary">요청 보내기 (Curl)</button>
        </form>
        <hr>
        <div class="bg-dark p-3 border rounded">
            <h5>결과:</h5>
            <pre class="text-success">
<?php
if (\$_SERVER["REQUEST_METHOD"] == "POST") {
    \$url = \$_POST['url'];
    \$use_header = isset(\$_POST['header_check']);
    
    echo "Requesting: \$url\n";
    
    \$ch = curl_init();
    curl_setopt(\$ch, CURLOPT_URL, \$url);
    curl_setopt(\$ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt(\$ch, CURLOPT_TIMEOUT, 3);
    
    if (\$use_header) {
        // Azure IMDS는 이 헤더가 있어야 응답함 (보안 기능)
        // SSRF 취약점이 있더라도 헤더를 조작 못하면 방어됨
        curl_setopt(\$ch, CURLOPT_HTTPHEADER, array("Metadata: true"));
    }

    \$response = curl_exec(\$ch);
    \$err = curl_error(\$ch);
    curl_close(\$ch);

    if (\$err) {
        echo "cURL Error: " . htmlspecialchars(\$err);
    } else {
        echo htmlspecialchars(\$response);
    }
}
?>
            </pre>
        </div>
        <a href="index.php" class="btn btn-outline-light mt-3">메인으로 돌아가기</a>
    </div>
</body>
</html>
EOF

# [취약점 5] Command Injection
cat > /var/www/html/cmd.php <<EOF
<!DOCTYPE html>
<html lang="ko" data-bs-theme="dark">
<head><title>Command Injection Lab</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"></head>
<body class="container mt-5">
    <div class="card p-4 border-danger">
        <h2 class="text-danger">💻 Command Injection</h2>
        <p>IP 주소를 입력하면 Ping을 날리는 기능입니다. <code>127.0.0.1; cat /etc/passwd</code> 등을 시도해보세요.</p>
        
        <form method="POST">
            <div class="input-group mb-3">
                <span class="input-group-text">IP Address</span>
                <input type="text" name="ip" class="form-control" placeholder="8.8.8.8">
                <button type="submit" class="btn btn-danger">Ping 테스트</button>
            </div>
        </form>
        <div class="bg-black p-3 text-white font-monospace rounded">
<?php
if (\$_SERVER["REQUEST_METHOD"] == "POST") {
    \$ip = \$_POST['ip'];
    // 취약한 코드: 입력값 검증 없이 shell_exec 실행
    // 실제 환경에서는 escapeshellarg() 등을 써야 함
    echo "\$ ping -c 3 " . htmlspecialchars(\$ip) . "<br>";
    \$output = shell_exec("ping -c 3 " . \$ip);
    echo "<pre>" . htmlspecialchars(\$output) . "</pre>";
}
?>
        </div>
        <a href="index.php" class="btn btn-outline-light mt-3">메인으로 돌아가기</a>
    </div>
</body>
</html>
EOF

# 데이터 생성 스크립트 (KOR)
cat > /var/www/html/generate_data.php <<EOF
<?php
include 'db_connect.php';

\\\$server_id = gethostname();
\\\$zone = \\\$_SERVER['HTTP_X_AZURE_ZONE'] ?? 'Unknown';

\\\$sql = "INSERT INTO replication_test (server_id, zone) VALUES ('\\\$server_id', '\\\$zone')";

if (\\\$conn->query(\\\$sql) === TRUE) {
    header("Location: index.php");
} else {
    echo "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css' rel='stylesheet'>";
    echo "<body class='container mt-5' data-bs-theme='dark'>";
    echo "<div class='alert alert-danger'>오류 발생: " . \\\$conn->error . "</div>";
    echo "<a href='index.php' class='btn btn-secondary'>돌아가기</a>";
    echo "</body>";
}
?>
EOF

# 권한 설정 (uploads 폴더 쓰기 권한 등)
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
chmod -R 777 /var/www/html/uploads

# 서비스 시작
systemctl enable httpd
systemctl restart httpd

# 완료 표시
date > "$COMPLETE_FLAG"
log "WAS VMSS 초기화 완료"