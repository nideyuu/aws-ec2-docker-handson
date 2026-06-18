#!/bin/bash

# OSパッケージ更新
dnf update -y

# Dockerインストール
dnf install docker -y

# Dockerサービス起動
systemctl start docker

# Docker自動起動設定
systemctl enable docker

# nginxコンテナ起動
docker run -d \
  -p 80:80 \
  --name nginx-container \
  nginx
