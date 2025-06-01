# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:slim

# Allow statements and log messages to immediately appear in the logs
ENV PYTHONUNBUFFERED=True
ENV PYTHONDONTWRITEBYTECODE=1
ENV PORT=8080
ENV DISPLAY=:99

# Install system dependencies for Chrome and Robot Framework
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    wget \
    curl \
    gnupg \
    unzip \
    xvfb \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libfontconfig1 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libxss1 \
    fonts-liberation \
    libappindicator1 \
    libnss3 \
    lsb-release \
    xdg-utils \
    libglib2.0-0 \
    libgconf-2-4 \
    libxrandr2 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxtst6 \
    libasound2 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libatspi2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome/Chromium based on architecture
RUN apt-get update && \
    if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        apt-get install -y wget gnupg && \
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg && \
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
        apt-get update && \
        apt-get install -y google-chrome-stable; \
    else \
        apt-get install -y chromium chromium-driver; \
        ln -sf /usr/bin/chromium /usr/bin/google-chrome; \
        ln -sf /usr/bin/chromedriver /usr/local/bin/chromedriver; \
    fi && \
    rm -rf /var/lib/apt/lists/*

# Install ChromeDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    rm -f /usr/local/bin/chromedriver && \
    unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ && \
    rm /tmp/chromedriver.zip && \
    chmod +x /usr/local/bin/chromedriver

# Set up application directory
ENV APP_HOME=/app
WORKDIR $APP_HOME

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p Logs/Capture && \
    chmod -R 755 Logs

# Create a script to start Xvfb and the application
RUN echo '#!/bin/bash\n\
# Start Xvfb\n\
Xvfb :99 -screen 0 1920x1080x24 &\n\
export DISPLAY=:99\n\
\n\
# Wait for Xvfb to start\n\
sleep 2\n\
\n\
# Start the Flask application\n\
exec "$@"\n\
' > /start.sh && chmod +x /start.sh

# Expose port
EXPOSE $PORT

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/ || exit 1

# Run the web service with Xvfb
ENTRYPOINT ["/start.sh"]
CMD ["gunicorn", "--bind", ":8080", "--workers", "1", "--threads", "8", "--timeout", "300", "main:app"]
