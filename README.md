# AWS EC2 Docker Hands-on

## 概要

本ハンズオンでは、AWS上にDocker実行環境を構築し、TerraformによるInfrastructure as Code（IaC）とEC2 UserDataによる自動構築を学習しました。

最終的には、TerraformでAWS環境を構築し、EC2起動時にUserDataを利用してDockerおよびnginxコンテナを自動起動できる環境を作成しました。

---

## 学習目的

* Dockerの基本操作を理解する
* EC2上でDockerコンテナを実行する
* TerraformによるAWS環境のコード化を学ぶ
* UserDataによるサーバ初期構築の自動化を学ぶ
* GitHubによるコード管理を行う

---

## 構成図

```text
Internet
    │
    ▼
Application Load Balancer
(Public Subnet 1a / 1c)
    │
    ▼
Target Group
    │
    ▼
EC2
(Private Subnet 1a)
    │
    ▼
Docker
    │
    ▼
nginx Container

Private EC2 outbound access:
EC2
    │
    ▼
NAT Gateway
(Public Subnet 1a)
    │
    ▼
Internet Gateway
    │
    ▼
Internet

Management access:
Systems Manager Session Manager
    │
    ▼
Private EC2
---

## 使用技術

### AWS

- VPC
- Public Subnet
- Private Subnet
- Internet Gateway
- NAT Gateway
- Elastic IP
- Route Table
- Security Group
- EC2
- Application Load Balancer
- Target Group
- IAM Role
- Systems Manager Session Manager

### OS

* Amazon Linux 2023

### Container

* Docker
* nginx

### IaC

* Terraform

### Version Control

* Git
* GitHub

---

## ディレクトリ構成

```text
aws-ec2-docker-handson/
│
├── app/
│   └── nginx/
│       └── html/
│           └── index.html
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── user_data.sh
│   └── .terraform.lock.hcl
│
└── README.md
```

---

## Terraformで構築したリソース

- VPC
- Public Subnet x2
- Private Subnet x2
- Internet Gateway
- NAT Gateway
- Elastic IP
- Public Route Table
- Private Route Table
- Security Group
  - ALB用Security Group
  - EC2用Security Group
- EC2 Instance
- IAM Role
- IAM Instance Profile
- Application Load Balancer
- Target Group
- Listener
- Target Group Attachment
---

## UserDataで自動化した内容

EC2起動時に以下を自動実行します。

* パッケージ更新
* Dockerインストール
* Dockerサービス起動
* Docker自動起動設定
* nginxコンテナ起動

実行スクリプトは `terraform/user_data.sh` に定義しています。

## セキュリティ設計

本構成では、EC2をPrivate Subnetに配置し、インターネットから直接アクセスできない構成にしています。

外部からのHTTPアクセスはApplication Load Balancerで受け付け、ALBからPrivate EC2上のnginxコンテナへ転送します。

### Security Group

#### ALB用Security Group

- Inbound
  - HTTP 80: 0.0.0.0/0
- Outbound
  - All traffic

#### EC2用Security Group

- Inbound
  - HTTP 80: ALB Security Groupからのみ許可
- Outbound
  - All traffic

SSHは使用せず、EC2への管理接続はSystems Manager Session Managerを利用します。

## 動作確認

### ALB経由のブラウザアクセス

Terraform apply後に出力されるALB DNS名へアクセスし、nginxコンテナで配信しているHTMLページが表示されることを確認しました。

```bash
terraform output alb_dns_name

Target Group Health Check

Target Groupに登録されたEC2インスタンスが Healthy になることを確認しました。

Session Manager接続

Private Subnet上のEC2へ、SSHではなくSystems Manager Session Managerで接続できることを確認しました。

EC2内部確認
# Dockerサービスが起動しているか確認
sudo systemctl status docker
# 起動中のDockerコンテナを確認
sudo docker ps
# EC2内部からnginxにアクセスできるか確認
curl http://localhost
# nginxコンテナのログを確認
sudo docker logs nginx-container

---

## Dockerで学習した内容

### コンテナ作成

```bash
docker run -d -p 80:80 --name nginx-container nginx
```
### コンテナ確認

```bash
docker ps
```

### コンテナ停止

```bash
docker stop nginx-container
```

### コンテナ削除

```bash
docker rm nginx-container
```

### Volume Mount

```bash
docker run -d \
-p 80:80 \
--name nginx-container \
-v ~/docker-nginx/html:/usr/share/nginx/html:ro \
nginx
```

EC2上のHTMLファイルをコンテナへマウントし、自作HTMLを配信する仕組みを学習しました。

---

### 初期化

terraform init
```

### 構文チェック

```bash
terraform validate


### 実行計画確認

```bash
terraform plan

### 環境構築

```bash
terraform apply

### 環境削除

```bash
terraform destroy
```

---

## 学んだこと

### Docker

* Dockerサービスの管理方法
* コンテナの作成・起動・停止・削除
* Port Mappingの仕組み
* Volume Mountの仕組み

### Terraform

* Infrastructure as Code (IaC)
* Terraformの基本構成
* variables.tfとterraform.tfvarsの役割
* outputs.tfの利用方法
* Terraform Stateの概念
* terraform plan の重要性
- ALB / Target Group / Listener のコード化
- IAM Role / Instance Profile のコード化
- Security Group Rule の分離管理
- Terraform apply / destroy による環境管理

### AWS

* VPCとSubnetの関係
* Internet Gatewayの役割
* Route Tableの役割
* Security Groupによるアクセス制御
* EC2作成とSSH接続
- Public Subnet / Private Subnet の使い分け
- ALBをPublic Subnetに配置する理由
- EC2をPrivate Subnetに配置するセキュリティ上のメリット
- NAT GatewayによるPrivate Subnetからの外向き通信
- Target GroupとHealth Checkの仕組み
- Security Group間参照によるアクセス制御
- Session ManagerによるSSHレス接続

### UserData
* EC2初回起動時の自動処理
* Docker自動インストール
* サーバ初期構築の自動化

---

## 今後の改善予定

- Auto Scaling Groupの追加
- Launch Templateの利用
- CloudWatch Alarmによるスケールアウト
- HTTPS化（ACM + ALB Listener 443）
- Route53による独自ドメイン対応
- Terraform Module化

---


Terraform実行後、

```bash
terraform apply

のみで以下が自動実行される環境を構築しました。

* AWS環境構築
* EC2作成
* Dockerインストール
* Docker起動
* nginxコンテナ起動

ブラウザからEC2へアクセスし、nginxのWebページ表示を確認しました。

## 結果
* UserDataで自作HTMLを自動配置

* nginxコンテナの利用方法
```

```bash


