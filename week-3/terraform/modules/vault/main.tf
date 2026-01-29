data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_instance" "vault" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.small"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data_base64 = base64encode(<<-EOF
              #!/bin/bash
              # Install Vault from official HashiCorp repo
              dnf install -y yum-utils
              dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
              dnf install -y vault

              # Create a simple dev-mode config file
              cat <<EOT > /etc/vault.d/vault.hcl
              storage "file" {
                path = "/opt/vault/data"
              }
              listener "tcp" {
                address     = "0.0.0.0:8200"
                tls_disable = 1
              }
              ui = true
              EOT

              mkdir -p /opt/vault/data
              chown -R vault:vault /opt/vault /etc/vault.d

              # Create systemd service for persistence
              cat <<EOT > /etc/systemd/system/vault.service
              [Unit]
              Description="HashiCorp Vault - A tool for managing secrets"
              Documentation=https://www.vaultproject.io/docs/
              Requires=network-online.target
              After=network-online.target

              [Service]
              User=vault
              Group=vault
              ProtectSystem=full
              ProtectHome=read-only
              PrivateTmp=yes
              PrivateDevices=yes
              SecureBits=keep-caps
              AmbientCapabilities=CAP_IPC_LOCK
              NoNewPrivileges=yes
              ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
              ExecReload=/bin/kill --signal HUP $MAINPID
              KillMode=process
              Restart=on-failure
              RestartSec=5
              LimitNOFILE=65536

              [Install]
              WantedBy=multi-user.target
              EOT

              systemctl daemon-reload
              systemctl enable --now vault
              EOF
  )

  tags = merge(var.common_tags, {
    Name = "${var.environment}-vault"
  })
}
