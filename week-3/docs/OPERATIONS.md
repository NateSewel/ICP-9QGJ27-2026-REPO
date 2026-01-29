# Operations Runbook

## Secret Management with Vault

### Initializing Vault
Once the Vault EC2 instance is running:
1.  SSH into the Vault instance.
2.  Initialize Vault:
    ```bash
    vault operator init
    ```
3.  Unseal Vault using the generated keys.

### Configuring AWS Secrets Engine
To allow Vault to manage AWS IAM users/roles:
```bash
vault secrets enable aws
vault write aws/config/root \
    access_key=AKIA... \
    secret_key=sbY... \
    region=us-east-1
```

## Scaling the Platform

### Scaling EC2 Instances
To increase the number of application servers, update `terraform.tfvars`:
```hcl
instance_count = 5
```
Then run `terraform apply`.

## Monitoring & Troubleshooting

### Viewing Logs
Application logs are stored on EC2 instances. In a production environment, it is recommended to stream these to **Amazon CloudWatch Logs**.

### Redis Connectivity
If the application cannot connect to Redis:
1.  Verify the security group `dev-redis-sg` allows traffic from `dev-ec2-sg` on port 6379.
2.  Check the endpoint in the Terraform outputs.
