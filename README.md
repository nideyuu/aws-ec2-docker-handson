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
Internet Gateway
    │
    ▼
Public Subnet (10.0.0.0/24)
    │
    ▼
EC2 (Amazon Linux 2023)
    │
    ▼
Docker
    │
    ▼
nginx Container
```

---

## 使用技術

### AWS

* VPC
* Public Subnet
* Internet Gateway
* Route Table
* Security Group
* EC2

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

* VPC
* Public Subnet
* Internet Gateway
* Route Table
* Route Table Association
* Security Group
* EC2 Instance

---

## UserDataで自動化した内容

EC2起動時に以下を自動実行します。

* パッケージ更新
* Dockerインストール
* Dockerサービス起動
* Docker自動起動設定
* nginxコンテナ起動

実行スクリプトは `terraform/user_data.sh` に定義しています。

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

### AWS

* VPCとSubnetの関係
* Internet Gatewayの役割
* Route Tableの役割
* Security Groupによるアクセス制御
* EC2作成とSSH接続

### UserData
* EC2初回起動時の自動処理
* Docker自動インストール
* サーバ初期構築の自動化

---

## 今後の改善予定

* Docker Volume Mountの完全自動化
* Application Load Balancer (ALB) の追加
* Route53による独自ドメイン対応
* Terraform Module化
* 3層構成への拡張

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


