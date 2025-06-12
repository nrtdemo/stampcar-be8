# Production Dockerfile for Render.com deployment
FROM python:3.11-slim

# Set environment variables for production
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV FLASK_ENV=production
ENV PORT=10000
ENV HOST=0.0.0.0
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    gnupg2 \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome browser for headless testing
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
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

# Expose port (Render uses PORT environment variable)
EXPOSE $PORT

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/ || exit 1

# Use Gunicorn for production deployment
CMD gunicorn --bind 0.0.0.0:$PORT --workers 2 --timeout 120 main:app
