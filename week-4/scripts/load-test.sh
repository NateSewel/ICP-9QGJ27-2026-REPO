#!/bin/bash
set -e

# Configuration
DURATION="2m"
USERS=50
SPAWN_RATE=10
HOST="http://localhost:8000" # Update with your Ingress host

echo "### Starting Load Test with Locust ###"
echo "Target Host: $HOST"
echo "Duration: $DURATION"
echo "Users: $USERS"

# Check if locust is installed
if ! command -v locust &> /dev/null; then
    echo "Locust not found. Installing..."
    pip install locust
fi

# Run locust in headless mode
locust -f tests/load/locustfile.py \
    --headless \
    --users $USERS \
    --spawn-rate $SPAWN_RATE \
    --run-time $DURATION \
    --host $HOST \
    --html tests/load/report.html

echo "### Load Test Completed. Report generated at tests/load/report.html ###"
