# Use Python 3.11 slim base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV FLASK_ENV=development
ENV PORT=8080
ENV HOST=0.0.0.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Create directories for logs and results
RUN mkdir -p /app/Logs /app/test-results /app/Logs/Capture

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY main.py .
COPY run_robot.py .
COPY robots/ ./robots/
COPY resources/ ./resources/
COPY templates/ ./templates/
COPY static/ ./static/

# Create non-root user for security
RUN useradd -m -u 1001 appuser && \
    chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Run the Flask application
CMD ["python", "main.py"]
