# Use Python 3.11 slim base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    curl \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Detect architecture and install Chrome accordingly
RUN ARCH=$(dpkg --print-architecture) \
    && if [ "$ARCH" = "amd64" ]; then \
        # AMD64 - Use official Google Chrome
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
        && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
        && apt-get update \
        && apt-get install -y google-chrome-stable; \
    elif [ "$ARCH" = "arm64" ]; then \
        # ARM64 - Use Chromium from official Debian repo
        apt-get update \
        && apt-get install -y chromium chromium-driver; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi \
    && rm -rf /var/lib/apt/lists/*

# Install ChromeDriver for the correct architecture
RUN ARCH=$(dpkg --print-architecture) \
    && if [ "$ARCH" = "amd64" ]; then \
        # AMD64 - Download ChromeDriver
        CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | awk -F. '{print $1}') \
        && CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VERSION}") \
        && wget -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" \
        && unzip /tmp/chromedriver.zip -d /tmp/ \
        && mv /tmp/chromedriver /usr/local/bin/chromedriver \
        && chmod +x /usr/local/bin/chromedriver \
        && rm /tmp/chromedriver.zip; \
    elif [ "$ARCH" = "arm64" ]; then \
        # ARM64 - ChromeDriver is already installed as chromium-driver
        ln -sf /usr/bin/chromedriver /usr/local/bin/chromedriver || true; \
    fi

# Create app directory
WORKDIR /app

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Create necessary directories
RUN mkdir -p /app/Logs/Capture \
    && chmod -R 755 /app/Logs

# Create a non-root user
RUN useradd -m -s /bin/bash robotuser \
    && chown -R robotuser:robotuser /app

# Switch to non-root user
USER robotuser

# Expose port for web interface (if needed)
EXPOSE 8080

# Create entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
USER robotuser

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Default command
CMD ["python3", "run_robot.py"]
