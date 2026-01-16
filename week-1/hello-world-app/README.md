# Hello World DevOps Application

## Description
A simple Flask-based web application demonstrating containerization and cloud deployment.

## Quick Start

### Local Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run application
python app.py
```

### Docker
```bash
# Build image
docker build -t hello-devops:v1.0 .

# Run container
docker run -p 8080:5000 hello-devops:v1.0
```

See the documentation in `docs/` for detailed instructions.
