data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_instance" "app" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile

  user_data_base64 = base64encode(<<-EOF
#!/bin/bash
# Log output to help with debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting deployment version 1.0.2..."

# Ensure we have internet access via NAT Gateway before proceeding
MAX_RETRIES=30
COUNT=0
until ping -c 1 google.com || [ $COUNT -eq $MAX_RETRIES ]; do
  echo "Waiting for internet access ($COUNT/$MAX_RETRIES)..."
  sleep 5
  ((COUNT++))
done

# Install Node.js
dnf install -y nodejs

mkdir -p /app
cd /app

# Create package.json
cat <<'EOT_PKG' > package.json
{
  "name": "employee-mgmt",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.3"
  }
}
EOT_PKG

# Create index.js using Environment Variables
cat <<'EOT_JS' > index.js
const express = require('express');
const { Pool } = require('pg');
const app = express();
app.use(express.json());

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASS,
  port: parseInt(process.env.DB_PORT || '5432', 10),
  connectionTimeoutMillis: 5000,
});

// Table initialization (non-blocking)
pool.query('CREATE TABLE IF NOT EXISTS employees (id SERIAL PRIMARY KEY, name TEXT, role TEXT)')
  .then(() => console.log('Database initialized successfully'))
  .catch(err => console.error('DB Init Error:', err.message));

app.get('/', (req, res) => res.send('<h1>Employee Management System</h1><p>Status: Running</p>'));
app.get('/health', (req, res) => res.status(200).send('OK'));

app.get('/employees', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM employees');
    res.json(rows);
  } catch (err) {
    console.error('Query Error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

app.listen(3000, '0.0.0.0', () => console.log('Server listening on port 3000'));
EOT_JS

echo "Installing dependencies..."
npm install || { echo "npm install failed"; exit 1; }

# Safely split the RDS endpoint
ENDPOINT="${var.rds_endpoint}"
HOST=$(echo $ENDPOINT | cut -d: -f1)
PORT=$(echo $ENDPOINT | cut -s -d: -f2)
if [ -z "$PORT" ]; then PORT="5432"; fi

# Create systemd service
cat <<EOT_SVC > /etc/systemd/system/employee-mgmt.service
[Unit]
Description=Employee Management API
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/app
Environment=DB_HOST=$HOST
Environment=DB_PORT=$PORT
Environment=DB_USER=${var.db_username}
Environment=DB_PASS=${var.db_password}
Environment=DB_NAME=${var.db_name}
ExecStart=/usr/bin/node index.js
Restart=always
RestartSec=10
StandardOutput=append:/var/log/employee-mgmt.log
StandardError=append:/var/log/employee-mgmt.log

[Install]
WantedBy=multi-user.target
EOT_SVC

systemctl daemon-reload
systemctl enable employee-mgmt
systemctl start employee-mgmt

echo "user_data script finished."
EOF
  )

  tags = merge(var.common_tags, {
    Name    = "${var.environment}-app-server-${count.index + 1}"
    Version = "1.0.2" # Force replacement
  })
}
