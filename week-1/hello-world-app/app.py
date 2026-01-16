"""
Hello World DevOps Application
InternCareer Path - Week 1
Intern ID: ICP-9QGJ27-2026

A simple Flask application demonstrating containerization and cloud deployment.
"""

from flask import Flask, jsonify, request
import socket
import os
import sys
from datetime import datetime
import platform

app = Flask(__name__)

# Application metadata
APP_VERSION = "1.0.0"
INTERN_ID = "ICP-9QGJ27-2026"
WEEK = "Week 1"

@app.route('/')
def hello():
    """
    Main endpoint returning application information
    """
    return jsonify({
        'message': 'Hello from DevOps Internship!',
        'intern_id': INTERN_ID,
        'week': WEEK,
        'version': APP_VERSION,
        'hostname': socket.gethostname(),
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'platform': {
            'system': platform.system(),
            'python_version': platform.python_version(),
            'architecture': platform.machine()
        },
        'timestamp': datetime.now().isoformat(),
        'aws_region': os.environ.get('AWS_REGION', 'N/A')
    })

@app.route('/health')
def health():
    """
    Health check endpoint for monitoring
    """
    return jsonify({
        'status': 'healthy',
        'service': 'hello-devops',
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/info')
def info():
    """
    Detailed system information endpoint
    """
    return jsonify({
        'application': {
            'name': 'Hello DevOps App',
            'version': APP_VERSION,
            'intern_id': INTERN_ID,
            'week': WEEK
        },
        'system': {
            'hostname': socket.gethostname(),
            'platform': platform.platform(),
            'python_version': sys.version,
            'environment': os.environ.get('ENVIRONMENT', 'development')
        },
        'endpoints': {
            '/': 'Main application endpoint',
            '/health': 'Health check endpoint',
            '/info': 'Detailed system information',
            '/env': 'Environment variables (filtered)'
        }
    })

@app.route('/env')
def environment():
    """
    Display safe environment variables
    """
    # Filter out sensitive environment variables
    safe_vars = {
        k: v for k, v in os.environ.items() 
        if not any(sensitive in k.upper() for sensitive in ['KEY', 'SECRET', 'PASSWORD', 'TOKEN'])
    }
    
    return jsonify({
        'environment_variables': safe_vars,
        'count': len(safe_vars)
    })

@app.errorhandler(404)
def not_found(error):
    """
    Custom 404 error handler
    """
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested endpoint does not exist',
        'available_endpoints': ['/', '/health', '/info', '/env']
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """
    Custom 500 error handler
    """
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'Something went wrong on the server'
    }), 500

if __name__ == '__main__':
    # Get port from environment or use default
    port = int(os.environ.get('PORT', 5000))
    
    # Get debug mode from environment
    debug = os.environ.get('DEBUG', 'False').lower() == 'true'
    
    print(f"""
    ╔════════════════════════════════════════════════════════════╗
    ║          DevOps Internship - Hello World App              ║
    ║              InternCareer Path - Week 1                    ║
    ╚════════════════════════════════════════════════════════════╝
    
    Application starting...
    Version: {APP_VERSION}
    Intern ID: {INTERN_ID}
    Environment: {os.environ.get('ENVIRONMENT', 'development')}
    Port: {port}
    Debug: {debug}
    
    Available endpoints:
    - GET  /         : Main application info
    - GET  /health   : Health check
    - GET  /info     : Detailed system info
    - GET  /env      : Environment variables
    
    """)
    
    # Run the application
    app.run(
        host='0.0.0.0',
        port=port,
        debug=debug
    )
