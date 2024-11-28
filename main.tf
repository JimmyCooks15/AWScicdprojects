name: Terraform EC2 Provisioning

on:
  push:
    branches:
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Set up Terraform
      uses: hashicorp/setup-terraform@v1
      with:
        terraform_version: 1.5.4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws_region: "eu-west-1"

    - name: Set up SSH private key
      run: |
        mkdir -p ~/.ssh
        echo "${{ secrets.AWS_PRIVATE_KEY }}" > ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa

    - name: Initialize Terraform
      run: terraform init

    - name: Apply Terraform configuration
      run: terraform apply -auto-approve

    - name: Output EC2 instance IP
      run: |
        echo "PUBLIC_IP=$(terraform output -raw vm_ip)" >> $GITHUB_ENV
        echo "Public IP: $PUBLIC_IP"
