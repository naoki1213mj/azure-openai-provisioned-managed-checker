#!/bin/bash

# 現在の日時を取得してフォーマットする（例：YYYYMMDD_HHMMSS）
timestamp=$(date '+%Y%m%d_%H%M%S')

# 出力ファイル名（タイムスタンプを含む）
output_file_provisioned_managed="provisioned_managed_deployments_${timestamp}.txt"
output_file_other_deployments="other_deployments_${timestamp}.txt"

# 出力ファイルを初期化
> "$output_file_provisioned_managed"
> "$output_file_other_deployments"

# 全サブスクリプションを取得
subscriptions=$(az account list --query "[].id" -o tsv)

for subscription in $subscriptions; do
    # サブスクリプションを設定
    az account set --subscription "$subscription"

    echo "Checking subscription: $subscription"

    # OpenAIサービスリソースのリストを取得 (kindが"OpenAI"のリソースのみ)
    resources=$(az cognitiveservices account list --subscription "$subscription" --query "[?kind=='OpenAI'].{Name:name, ResourceGroup:resourceGroup}" -o tsv)

    if [ -z "$resources" ]; then
        echo "No OpenAI resources found in subscription: $subscription"
        continue
    fi

    any_provisioned_managed=false
    any_other_deployments=false
    resources_with_provisioned_managed_deployments=""
    resources_with_other_deployments=""

    # 各リソースについて確認
    while read -r resourceName resourceGroup; do
        echo "Checking resource: $resourceName in resource group: $resourceGroup"

        # デプロイメントのリストを取得
        deployments=$(az cognitiveservices account deployment list --resource-group "$resourceGroup" --name "$resourceName" --subscription "$subscription" -o json)

        if [ -z "$deployments" ] || [ "$deployments" == "[]" ]; then
            echo "No deployments found in resource: $resourceName"
            continue
        fi

        # 各デプロイメントを確認
        for row in $(echo "${deployments}" | jq -r '.[] | @base64'); do
            _jq() {
                echo "${row}" | base64 --decode | jq -r "${1}"
            }

            deploymentName=$(_jq '.name')
            skuName=$(_jq '.sku.name')
            modelName=$(_jq '.properties.model.name')

            if [ "$skuName" == "Provisioned-managed" ]; then
                any_provisioned_managed=true
                resources_with_provisioned_managed_deployments+="$resourceName (Resource Group: $resourceGroup, DeploymentName: $deploymentName, SKU Name: $skuName, ModelName: $modelName)\n"
            else
                any_other_deployments=true
                resources_with_other_deployments+="$resourceName (Resource Group: $resourceGroup, DeploymentName: $deploymentName, SKU Name: $skuName, ModelName: $modelName)\n"
            fi
        done

    done <<< "$resources"

    # 'Provisioned-managed' なデプロイメントの出力
    if [ "$any_provisioned_managed" = true ]; then
        echo "Some deployments in subscription $subscription have SKU Name set to 'Provisioned-managed'."
        # サブスクリプションIDをファイルに追加
        echo "-------------------------------------" >> "$output_file_provisioned_managed"
        echo "Subscription: $subscription" >> "$output_file_provisioned_managed"
        echo "Resources with Provisioned-managed deployments and their models:" >> "$output_file_provisioned_managed"
        # リソース情報を追加
        echo -e "$resources_with_provisioned_managed_deployments" >> "$output_file_provisioned_managed"
        echo "-------------------------------------" >> "$output_file_provisioned_managed"
    else
        echo "No deployments with SKU Name 'Provisioned-managed' found in subscription $subscription."
    fi

    # 'Provisioned-managed' 以外のデプロイメントの出力
    if [ "$any_other_deployments" = true ]; then
        echo "Some deployments in subscription $subscription are not 'Provisioned-managed'."
        # サブスクリプションIDをファイルに追加
        echo "-------------------------------------" >> "$output_file_other_deployments"
        echo "Subscription: $subscription" >> "$output_file_other_deployments"
        echo "Resources with other deployments and their models:" >> "$output_file_other_deployments"
        # リソース情報を追加
        echo -e "$resources_with_other_deployments" >> "$output_file_other_deployments"
        echo "-------------------------------------" >> "$output_file_other_deployments"
    else
        echo "All deployments in subscription $subscription are 'Provisioned-managed' or no other deployments found."
    fi
done

echo "Subscriptions with deployments have been saved to $output_file_provisioned_managed and $output_file_other_deployments"
