# Docker Basics & Hello World Application

## Objective
Build and containerize a simple Hello World web application using Docker.

## Docker Fundamentals

### What is Docker?
Docker is a platform for developing, shipping, and running applications in containers. Containers package an application with all its dependencies, ensuring it runs consistently across different environments.

### Key Docker Concepts
- **Image:** Blueprint for creating containers
- **Container:** Running instance of an image
- **Dockerfile:** Instructions to build an image
- **Docker Hub/ECR:** Registry for storing images
- **Volumes:** Persistent data storage
- **Networks:** Container communication

## Building Your First Docker Application

### Project Structure
```
hello-world-app/
├── app.py
├── requirements.txt
├── Dockerfile
├── .dockerignore
└── README.md
```

### Step 1: Create the Application

Create `app.py`:
```python
from flask import Flask, jsonify
import socket
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from DevOps Internship!',
        'intern_id': 'ICP-9QGJ27-2026',
        'week': 'Week 1',
        'hostname': socket.gethostname(),
        'environment': os.environ.get('ENVIRONMENT', 'development')
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
```

Create `requirements.txt`:
```
Flask==3.0.0
gunicorn==21.2.0
```

### Step 2: Create Dockerfile

Create `Dockerfile`:
```dockerfile
# Use official Python runtime as base image
FROM python:3.11-slim

# Set metadata
LABEL maintainer="Nathaniel Isewede"
LABEL description="Hello World DevOps Application"
LABEL version="1.0"

# Set working directory in container
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Expose port
EXPOSE 5000

# Set environment variables
ENV ENVIRONMENT=production
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1

# Run application with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
```

### Step 3: Create .dockerignore

Create `.dockerignore`:
```
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv
.git
.gitignore
README.md
.dockerignore
*.md
.env
```

## Building and Testing Locally

### Build Docker Image
```bash
# Navigate to app directory
cd hello-world-app

# Build the image
docker build -t hello-devops:v1.0 .

# Verify image was created
docker images | grep hello-devops
```

### Run Container Locally
```bash
# Run container
docker run -d \
  --name hello-devops-container \
  -p 8080:5000 \
  -e ENVIRONMENT=development \
  hello-devops:v1.0

# Check if container is running
docker ps

# View container logs
docker logs hello-devops-container

# Follow logs in real-time
docker logs -f hello-devops-container
```

### Test the Application
```bash
# Test the main endpoint
curl http://localhost:8080/

# Expected output:
# {
#   "message": "Hello from DevOps Internship!",
#   "intern_id": "ICP-9QGJ27-2026",
#   "week": "Week 1",
#   "hostname": "container_id",
#   "environment": "development"
# }

# Test health endpoint
curl http://localhost:8080/health

# Test in browser
# Open: http://localhost:8080
```

## Essential Docker Commands

### Image Management
```bash
# List all images
docker images

# Remove an image
docker rmi hello-devops:v1.0

# Remove unused images
docker image prune

# Tag an image
docker tag hello-devops:v1.0 hello-devops:latest
```

### Container Management
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop hello-devops-container

# Start a stopped container
docker start hello-devops-container

# Restart a container
docker restart hello-devops-container

# Remove a container
docker rm hello-devops-container

# Remove a running container (force)
docker rm -f hello-devops-container
```

### Debugging Commands
```bash
# Execute command in running container
docker exec -it hello-devops-container /bin/bash

# View container details
docker inspect hello-devops-container

# View resource usage
docker stats hello-devops-container

# View container processes
docker top hello-devops-container
```

## Docker Best Practices

### 1. Use Specific Base Image Versions
```dockerfile
# Good
FROM python:3.11-slim

# Avoid
FROM python:latest
```

### 2. Minimize Layers
```dockerfile
# Good - Single RUN command
RUN apt-get update && \
    apt-get install -y package1 package2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Avoid - Multiple RUN commands
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2
```

### 3. Use .dockerignore
Always exclude unnecessary files to reduce build context size.

### 4. Run as Non-Root User
```dockerfile
# Create non-root user
RUN useradd -m -u 1000 appuser
USER appuser
```

### 5. Use Multi-Stage Builds (Advanced)
```dockerfile
# Build stage
FROM python:3.11 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Runtime stage
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY app.py .
CMD ["python", "app.py"]
```

## Troubleshooting

### Container Exits Immediately
```bash
# Check logs
docker logs hello-devops-container

# Run interactively to debug
docker run -it hello-devops:v1.0 /bin/bash
```

### Port Already in Use
```bash
# Find process using port 8080
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# Use different port
docker run -p 8081:5000 hello-devops:v1.0
```

### Build Failures
```bash
# Build with verbose output
docker build --progress=plain -t hello-devops:v1.0 .

# Build without cache
docker build --no-cache -t hello-devops:v1.0 .
```

## Cleanup

```bash
# Stop and remove container
docker stop hello-devops-container
docker rm hello-devops-container

# Remove image
docker rmi hello-devops:v1.0

# Clean up everything (use with caution!)
docker system prune -a
```

## Verification Checklist

- [ ] Application code created
- [ ] Dockerfile created with best practices
- [ ] Docker image built successfully
- [ ] Container runs without errors
- [ ] Application accessible at http://localhost:8080
- [ ] Health check endpoint works
- [ ] Container logs show no errors
- [ ] Screenshot of running application saved

## Screenshots to Capture

1. `docker images` output showing your image
2. `docker ps` output showing running container
3. Browser/curl output showing application response
4. `docker logs` output showing application startup

Save all screenshots in `week-1/screenshots/` directory.

## Next Steps
Proceed to [03-aws-deployment.md](03-aws-deployment.md) to deploy this containerized application to AWS.

---

**Status:** Completed  
**Previous:** [← Environment Setup](01-environment-setup.md)  
**Next:** [AWS Deployment →](03-aws-deployment.md)
