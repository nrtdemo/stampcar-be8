# Docker Deployment Guide

This guide explains how to build and deploy the Robot Framework Web Runner using Docker.

## 🐳 Quick Start

### Option 1: Using the Build Script (Recommended)
```bash
# Make the script executable and run it
chmod +x docker-run.sh
./docker-run.sh
```

### Option 2: Using Docker Commands
```bash
# Build the image
docker build -t robot-web-runner:latest .

# Run the container
docker run -d \
  --name robot-web-runner \
  -p 8080:8080 \
  -v "$(pwd)/Logs:/app/Logs" \
  robot-web-runner:latest
```

### Option 3: Using Docker Compose
```bash
# Production deployment
docker-compose up -d

# Development with hot reload
docker-compose -f docker-compose.dev.yml up -d
```

## 🛠️ Docker Configuration

### Dockerfile Features
- **Base Image**: Python 3.11 slim for optimal size and security
- **Chrome Installation**: Google Chrome and ChromeDriver for Selenium tests
- **Xvfb**: Virtual display server for headless browser testing
- **Health Check**: Automatic container health monitoring
- **Multi-stage optimization**: Efficient layer caching

### Environment Variables
- `PORT`: Application port (default: 8080)
- `FLASK_ENV`: Flask environment (development/production)
- `DISPLAY`: X11 display for headless Chrome (:99)

### Volume Mounts
- `./Logs:/app/Logs`: Persistent log storage outside container

## 📊 Container Management

### View Logs
```bash
# Real-time logs
docker logs robot-web-runner -f

# Recent logs
docker logs robot-web-runner --tail 100
```

### Container Control
```bash
# Stop the container
docker stop robot-web-runner

# Restart the container
docker restart robot-web-runner

# Remove the container
docker rm -f robot-web-runner
```

### Debug Container
```bash
# Execute commands inside running container
docker exec -it robot-web-runner bash

# Check Chrome installation
docker exec -it robot-web-runner google-chrome --version

# Check Python packages
docker exec -it robot-web-runner pip list
```

## 🔧 Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Find process using port 8080
   lsof -i :8080
   
   # Use different port
   docker run -p 8081:8080 robot-web-runner:latest
   ```

2. **Permission Issues with Logs**
   ```bash
   # Fix log directory permissions
   sudo chown -R $USER:$USER ./Logs
   chmod -R 755 ./Logs
   ```

3. **Chrome/Selenium Issues**
   ```bash
   # Check if Chrome is working inside container
   docker exec -it robot-web-runner google-chrome --headless --dump-dom https://google.com
   ```

4. **Memory Issues**
   ```bash
   # Run with more memory (4GB)
   docker run -m 4g robot-web-runner:latest
   ```

### Performance Optimization

1. **Multi-stage Build** (for production)
   - Reduce image size by excluding development dependencies
   - Use `.dockerignore` to exclude unnecessary files

2. **Resource Limits**
   ```bash
   # Limit CPU and memory usage
   docker run --cpus="2" -m 2g robot-web-runner:latest
   ```

## 🚀 Production Deployment

### Using Docker Compose (Recommended)
```bash
# Production deployment with health checks
docker-compose up -d

# Scale to multiple instances
docker-compose up -d --scale robot-web-runner=3
```

### Using Container Orchestration
- **Kubernetes**: Create deployment and service manifests
- **Docker Swarm**: Use stack deployment
- **Cloud Services**: Deploy to AWS ECS, Google Cloud Run, Azure Container Instances

### Health Monitoring
The container includes a health check that pings the Flask application every 30 seconds:
```dockerfile
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/ || exit 1
```

## 📈 Monitoring and Logs

### Application Logs
- Flask application logs are available via `docker logs`
- Robot Framework test logs are stored in `./Logs` directory
- Access detailed HTML reports at `/logs` endpoint

### Container Metrics
```bash
# Monitor resource usage
docker stats robot-web-runner

# Container information
docker inspect robot-web-runner
```

## 🔐 Security Considerations

1. **Run as Non-root User** (for production)
2. **Use Multi-stage Builds** to minimize attack surface
3. **Regular Base Image Updates** for security patches
4. **Network Isolation** using Docker networks
5. **Secret Management** for sensitive configuration

---

Access the web interface at: **http://localhost:8080**
