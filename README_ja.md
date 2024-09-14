# Azure OpenAI Provisioned-managed チェッカー

このリポジトリには、Azureテナント内のすべてのサブスクリプションをスキャンし、Azure OpenAIリソース内で **Provisioned-managed** なデプロイメントを特定するシェルスクリプトが含まれています。これは、意図しないデプロイ設定による予期せぬ高額課金を防止するために重要です。

[English README is available here](./README.md)

## 概要

Azure OpenAI Serviceにおいて、**Provisioned-managed** なデプロイメントは専用の計算リソースを提供し、高いパフォーマンスを実現しますが、その分コストも高くなります。

**最近、モデルをデプロイしただけで高額な課金が発生する事例が報告されています。** これは、デプロイ時に意図せず「Provisioned-Managed」オプションを選択してしまい、デフォルトで最大のPTU（Provisioned Throughput Unit）が設定され、時間単位の課金が発生するためです。

このスクリプトは、複数のサブスクリプションにまたがるAzure OpenAIリソースを自動的にスキャンし、`sku.name` が `Provisioned-managed` に設定されているデプロイメントをチェックします。結果はタイムスタンプ付きのファイルに出力され、トラッキングや監査に便利です。

## 特徴

- アカウントがアクセス可能なすべてのAzureサブスクリプションをスキャン
- Azure OpenAIリソース（`kind` == `OpenAI`）を特定
- `sku.name` が `Provisioned-managed` のデプロイメントをチェック
- タイムスタンプ付きの2つのファイルに出力：
  - `provisioned_managed_deployments_YYYYMMDD_HHMMSS.txt`: `Provisioned-managed` なデプロイメントの一覧
  - `other_deployments_YYYYMMDD_HHMMSS.txt`: その他のデプロイメントの一覧
- 詳細情報を提供：
  - サブスクリプションID
  - リソースグループ
  - リソース名
  - デプロイメント名
  - SKU名
  - モデル名

## 前提条件

- **Azure CLI** のインストール
  - [インストールガイド](https://docs.microsoft.com/ja-jp/cli/azure/install-azure-cli)
- Azure CLI用の **Cognitive Services 拡張機能**

  ```bash
  az extension add --name cognitiveservices
  ```

- JSONパース用の **jq** のインストール
  - macOS:

    ```bash
    brew install jq
    ```

  - Ubuntu/Debian:

    ```bash
    sudo apt-get install jq
    ```

  - CentOS/RHEL:

    ```bash
    sudo yum install jq
    ```

- **Azureアカウントへのアクセス権限**
  - 対象のサブスクリプションに対する**閲覧者（Reader）ロール**が必要です。

## 使用方法

1. **リポジトリをクローン**

   ```bash
   git clone https://github.com/yourusername/azure-openai-provisioned-managed-checker.git
   cd azure-openai-provisioned-managed-checker
   ```

2. **Azureにログイン**

   ```bash
   az login
   ```

3. **適切な権限を確認**

   - サブ

スクリプションレベルで**閲覧者（Reader）ロール**が割り当てられていることを確認してください。

4. **スクリプトに実行権限を付与**

   ```bash
   chmod +x check_provisioned_managed_deployments.sh
   ```

5. **スクリプトを実行**

   ```bash
   ./check_provisioned_managed_deployments.sh
   ```

6. **出力ファイルを確認**

   - `provisioned_managed_deployments_YYYYMMDD_HHMMSS.txt`
   - `other_deployments_YYYYMMDD_HHMMSS.txt`

## 出力ファイルの説明

### `provisioned_managed_deployments_YYYYMMDD_HHMMSS.txt`

- `sku.name` が `Provisioned-managed` のデプロイメントが含まれます。
- 高コストなデプロイメントを特定するのに役立ちます。
- 含まれる詳細情報：
  - サブスクリプションID
  - リソースグループ
  - リソース名
  - デプロイメント名
  - SKU名
  - モデル名

### `other_deployments_YYYYMMDD_HHMMSS.txt`

- `sku.name` が `Provisioned-managed` ではない（例：`Standard`）デプロイメントが含まれます。
- すべてのデプロイメントを監査・管理するのに役立ちます。
- 含まれる詳細情報は上記と同じです。

## 重要な注意事項

- **Azureロールと権限**

  - スクリプトを正常に実行するために、対象のサブスクリプションに対する**閲覧者（Reader）ロール**が必要です。
  - 権限が不足している場合、Azure管理者に問い合わせてください。

- **Azure CLIと拡張機能の更新**

  - 最新バージョンを使用して、互換性の問題を避けてください。

- **セキュリティに関する考慮事項**

  - 権限とロールを割り当てる際には、最小権限の原則に従ってください。
  - 定期的に権限を見直し、必要に応じて調整してください。

- **免責事項**

  - このスクリプトは現状のまま提供されており、いかなる保証もありません。
  - 情報は **2024年9月14日** 時点のAzureサービスに基づいています。
  - 利用は自己責任で行ってください。これにより生じたいかなる結果についても、作者は責任を負いません。

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
