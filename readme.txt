C:\01_IaC\02_team_www 폴더에서 
마우스 오른쪽 클릭으로 터미널창 접속
처음 한번

git init
git remote add origin git@github.com:ggjg330204/team_www.git
git fetch origin
git checkout -b main origin/main

git clone git@github.com:ggjg330204/team_www.git

불러오는 방법
git remote -v
git branch -a
git pull origin main

업로드 방법
git add .
git commit -m "변경사항 메모"
git push -u origin main