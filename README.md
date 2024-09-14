# Azure OpenAI Provisioned-managed Checker

This repository contains a shell script that helps you identify all **Provisioned-managed** deployments within your Azure OpenAI resources across all subscriptions in your Azure tenant. This is crucial for preventing unexpected high charges due to unintended deployment configurations.

## Overview

In Azure OpenAI Service, **Provisioned-managed** deployments provide dedicated compute resources for your models, offering high performance but at a higher cost. Managing these deployments effectively is crucial for cost optimization and resource management.

**Recently, there have been instances where deploying a model with default settings led to high charges, even without using the API.** This is often caused by unintentionally selecting the "Provisioned-Managed" option during deployment, which defaults to the maximum Provisioned Throughput Unit (PTU), resulting in hourly charges.

This script automates the process of scanning all your Azure subscriptions to find Azure OpenAI resources and checks for deployments with `sku.name` set to `Provisioned-managed`. It outputs the findings into timestamped files for easy tracking and auditing.

## Features

- Scans all Azure subscriptions accessible by your account.
- Identifies Azure OpenAI resources (`kind` == `OpenAI`).
- Checks for deployments with `sku.name` equal to `Provisioned-managed`.
- Outputs two timestamped files:
  - `provisioned_managed_deployments_YYYYMMDD_HHMMSS.txt`: Lists all `Provisioned-managed` deployments.
  - `other_deployments_YYYYMMDD_HHMMSS.txt`: Lists all other deployments.
- Provides detailed information including:
  - Subscription ID
  - Resource Group
  - Resource Name
  - Deployment Name
  - SKU Name
  - Model Name

## Prerequisites

- **Azure CLI** installed.
  - [Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Cognitive Services Extension** for Azure CLI.

  ```bash
  az extension add --name cognitiveservices
  ```

- **jq** installed for JSON parsing.
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

- **Azure Account Access** with appropriate permissions.
  - **Reader role at the subscription level** is required to read resource information.

## Usage

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/azure-openai-provisioned-managed-checker.git
   cd azure-openai-provisioned-managed-checker
   ```

2. **Log in to Azure**

   ```bash
   az login
   ```

3. **Ensure Appropriate Permissions**

   - Confirm that your account has at least the **Reader role** for the subscriptions you wish to scan.

4. **Make the Script Executable**

   ```bash
   chmod +x check_provisioned_managed_deployments.sh
   ```

5. **Run the Script**

   ```bash
   ./check_provisioned_managed_deployments.sh
   ```

6. **Review the Output Files**

   - `provisioned_managed_deployments_YYYYMMDD_HHMMSS.txt`
   - `other_deployments_YYYYMMDD_HHMMSS.txt`

## Output Files Explanation

### `provisioned_managed_deployments_YYYYMMDD_HHMMSS.txt`

- Contains deployments where `sku.name` is `Provisioned-managed`.
- Useful for identifying high-cost deployments for cost optimization.
- Includes detailed information:
  - Subscription ID
  - Resource Group
  - Resource Name
  - Deployment Name
  - SKU Name
  - Model Name

### `other_deployments_YYYYMMDD_HHMMSS.txt`

- Contains deployments where `sku.name` is not `Provisioned-managed` (e.g., `Standard`).
- Helps in auditing and managing all other deployments.
- Includes the same detailed information as above.

## Important Notes

- **Azure Roles and Permissions**

  - Ensure that you have the **Reader role** at the subscription level to access the necessary resource information.
  - If you lack sufficient permissions, contact your Azure administrator.

- **Keep Azure CLI and Extensions Updated**

  - Use the latest versions to avoid compatibility issues.

- **Security Considerations**

  - Follow the principle of least privilege when assigning roles and permissions.
  - Regularly review and adjust permissions as needed.

- **Disclaimer**

  - This script is provided "as is" without any warranty.
  - The information is based on the state of Azure services as of **September 14, 2024**.
  - Use at your own risk; the author is not responsible for any consequences arising from its use.

## License

This project is licensed under the MIT License.
