# AWS ECS Fargate + Go App アーキテクチャ提案書

## 概要
このドキュメントは、Terraformを使用してAWS ECS Fargate上にセキュアな「Hello World」Goアプリケーションをデプロイするためのアーキテクチャ概要です。

## 進捗状況

### 1. アプリケーション (Go)
*   [x] **実装:** `net/http` を使用した軽量HTTPサーバー (`./app/main.go`)
    *   エンドポイント: `GET /` で `{"message": "Hello World"}` を返す
*   [x] **コンテナ化:**
    *   Dockerfile: マルチステージビルド (distroless または alpine)
    *   ローカルでのビルドと動作確認

### 2. インフラストラクチャ (Terraform - `./infra`)

#### 基本設定 & ネットワーク (VPC)
*   [x] **Provider設定:** AWSプロバイダーとバージョンの固定
*   [x] **VPC作成:** CIDRブロック (例: `10.0.0.0/16`)
*   [x] **サブネット作成:**
    *   パブリックサブネット (x2): ALB, NAT Gateway用
    *   プライベートサブネット (x2): ECSタスク用 (インターネットからの直接アクセス不可)
*   [x] **ゲートウェイ:**
    *   Internet Gateway (IGW)
    *   NAT Gateway (プライベートサブネットからのOutbound通信用)
*   [x] **ルートテーブル:** 各サブネットへの適切なルーティング設定

#### セキュリティ
*   [x] **セキュリティグループ (SG):**
    *   ALB SG: インバウンド HTTP (80) を `0.0.0.0/0` から許可
    *   ECS Task SG: インバウンドを **ALB SG からのみ** 許可 (ポート 8080 など)
*   [x] **IAMロール:**
    *   Task Execution Role: ECRからのPull, CloudWatchへのログ出力権限
    *   Task Role: アプリケーション自体の権限 (今回は特に不要だが作成)

#### コンピュート (ECS Fargate) & レジストリ
*   [x] **ECRリポジトリ:** Dockerイメージの格納先
*   [x] **ECSクラスター:** Fargateキャパシティプロバイダー設定
*   [x] **タスク定義 (Task Definition):**
    *   CPU/メモリ: 最小構成 (例: 256 CPU / 512 MiB Memory)
    *   コンテナ定義: ECRイメージを指定
*   [x] **ECSサービス:**
    *   レプリカ数: 2 (冗長構成)
    *   ロードバランサー連携: ALBターゲットグループへの紐付け

#### ロードバランシング (ALB)
*   [x] **ALB本体:** インターネット向け (Internet-facing)、パブリックサブネットに配置
*   [x] **ターゲットグループ:** Goアプリのヘルスチェック設定 (例: `GET /`)
*   [x] **リスナー:** ポート80 (HTTP) でのリクエスト受け付け

### 3. デプロイ & 確認
*   [ ] **イメージのPush:** ECRへのDockerイメージのPush
*   [ ] **Terraform Apply:** インフラの構築とECSサービスの起動
*   [ ] **動作確認:** ALBのDNS名にアクセスして "Hello World" が返るか確認