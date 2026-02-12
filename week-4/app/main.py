import logging
import sys
from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator
from pythonjsonlogger import jsonlogger

# Configure structured logging
logHandler = logging.StreamHandler(sys.stdout)
formatter = jsonlogger.JsonFormatter('%(asctime)s %(levelname)s %(message)s')
logHandler.setFormatter(formatter)
logger = logging.getLogger("app")
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

app = FastAPI(title="FastAPI Week 4 Optimized")

# Add Prometheus instrumentation
Instrumentator().instrument(app).expose(app)

@app.get("/")
def read_root():
    logger.info("Root endpoint accessed")
    return {"message": "Welcome to the Week 4 Optimized FastAPI Service"}

@app.get("/health")
def health():
    logger.info("Health check endpoint accessed")
    return {"status": "ok", "version": "1.0.0"}

@app.get("/ready")
def ready():
    return {"status": "ready"}
