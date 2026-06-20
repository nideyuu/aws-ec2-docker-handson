#!/bin/bash

# OSパッケージ更新
dnf update -y

# Dockerインストール
dnf install docker -y

# Dockerサービス起動
systemctl start docker

# Docker自動起動設定
systemctl enable docker

# nginxで配信するHTML用ディレクトリ作成
mkdir -p /home/ec2-user/docker-nginx/html

# 自作HTML作成
cat << 'EOF' > /home/ec2-user/docker-nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>AWS EC2 Docker Hands-on</title>
</head>
<body>
  <h1>AWS EC2 Docker Hands-on</h1>
  <p>This page is served by nginx running in a Docker container on EC2.</p>
  <p>HTML and Docker container were provisioned automatically by Terraform UserData.</p>
</body>
</html>
EOF

# ファイル所有者をec2-userに変更
chown -R ec2-user:ec2-user /home/ec2-user/docker-nginx

# Volume Mount付きでnginxコンテナ起動
docker run -d \
  -p 80:80 \
  --name nginx-container \
  -v /home/ec2-user/docker-nginx/html:/usr/share/nginx/html:ro \
  nginx
