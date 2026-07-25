"""Small demo web app that exposes Prometheus metrics."""

import random
import time
from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["endpoint"],
)
ACTIVE_USERS = Gauge("active_users", "Simulated active users")
CPU_USAGE = Gauge("cpu_usage_percent", "Simulated CPU usage percent")
MEMORY_USAGE = Gauge("memory_usage_mb", "Simulated memory usage in MB")

# Seed metrics so Grafana shows data immediately after first Prometheus scrape
ACTIVE_USERS.set(25)
CPU_USAGE.set(42.5)
MEMORY_USAGE.set(256.0)


def simulate_system_metrics():
    """Generate realistic-looking demo metrics."""
    ACTIVE_USERS.set(random.randint(5, 50))
    CPU_USAGE.set(round(random.uniform(10, 85), 2))
    MEMORY_USAGE.set(round(random.uniform(128, 512), 2))


@app.route("/")
def home():
    start = time.time()
    simulate_system_metrics()
    REQUEST_COUNT.labels(method="GET", endpoint="/", status="200").inc()
    REQUEST_LATENCY.labels(endpoint="/").observe(time.time() - start)
    return jsonify({
        "service": "demo-app",
        "status": "running",
        "message": "Visit /metrics for Prometheus data",
    })


@app.route("/api/data")
def api_data():
    start = time.time()
    simulate_system_metrics()
    items = [{"id": i, "value": random.randint(1, 100)} for i in range(5)]
    REQUEST_COUNT.labels(method="GET", endpoint="/api/data", status="200").inc()
    REQUEST_LATENCY.labels(endpoint="/api/data").observe(time.time() - start)
    return jsonify({"items": items, "timestamp": time.time()})


@app.route("/health")
def health():
    simulate_system_metrics()
    REQUEST_COUNT.labels(method="GET", endpoint="/health", status="200").inc()
    return jsonify({"status": "healthy"})


@app.route("/metrics")
def metrics():
    simulate_system_metrics()
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
