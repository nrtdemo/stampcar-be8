# Docker Setup for StampCar Robot Framework Tests

This guide explains how to run Robot Framework tests with Selenium and ChromeDriver in Docker containers.

## 🐋 Docker Files Overview

- **`Dockerfile`** - Main Docker image configuration with Chrome/ChromeDriver
- **`docker-compose.yml`** - Docker Compose configuration for easy deployment
- **`docker-entrypoint.sh`** - Entry point script that starts Xvfb and Chrome
- **`docker-run.sh`** - Convenience script for common Docker operations

## 🚀 Quick Start

### Option 1: Using Docker Compose (Recommended)

```bash
# Build and run with Docker Compose
docker-compose up --build

# Run in detached mode
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Option 2: Using the Convenience Script

```bash
# Make script executable (first time only)
chmod +x docker-run.sh

# Build the Docker image
./docker-run.sh build

# Run tests with Docker Compose
./docker-run.sh run

# Run specific license plate test
./docker-run.sh test license ABC123

# Run specific serial number test
./docker-run.sh test serial SER456

# Open shell in container for debugging
./docker-run.sh shell

# Clean up Docker resources
./docker-run.sh clean
```

### Option 3: Manual Docker Commands

```bash
# Build the image
docker build -t stampcar-robot-tests .

# Run license plate test
docker run --rm \
  -v "$(pwd)/Logs:/app/Logs" \
  -e DISPLAY=:99 \
  --shm-size=2g \
  --security-opt seccomp:unconfined \
  stampcar-robot-tests \
  python3 run_robot.py --license "ABC123"

# Run serial number test
docker run --rm \
  -v "$(pwd)/Logs:/app/Logs" \
  -e DISPLAY=:99 \
  --shm-size=2g \
  --security-opt seccomp:unconfined \
  stampcar-robot-tests \
  python3 run_robot.py --serial "SER456"

# Run web interface
docker run --rm \
  -p 8080:8080 \
  -v "$(pwd)/Logs:/app/Logs" \
  -e DISPLAY=:99 \
  --shm-size=2g \
  --security-opt seccomp:unconfined \
  stampcar-robot-tests \
  python3 main.py
```

## 🔧 Docker Configuration Details

### Browser Configuration for Docker

The Docker setup includes special Chrome options for containerized environments:

```robot
${CONFIG.BROWSER.OPTIONS}    add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--remote-debugging-port=9222");add_argument("--disable-web-security");add_argument("--window-size=1920,1080")
```

### Environment Variables

- `DISPLAY=:99` - Virtual display for headless Chrome
- `PYTHONUNBUFFERED=1` - Unbuffered Python output
- `DEBIAN_FRONTEND=noninteractive` - Non-interactive apt installations

### Volume Mounts

- `./Logs:/app/Logs` - Persist test results and screenshots
- `./robots:/app/robots` - Mount robot files for easy editing

### Security Options

- `--shm-size=2gb` - Increase shared memory for Chrome stability
- `--security-opt seccomp:unconfined` - Required for Chrome in containers

## 📁 Output Files

All test outputs are saved to the `./Logs` directory:

- `log.html` - Test execution log
- `report.html` - Test report
- `output.xml` - Raw test output
- `Capture/` - Screenshots directory

## 🔍 Debugging

### View Container Logs

```bash
# Using Docker Compose
docker-compose logs -f

# Using convenience script
./docker-run.sh logs

# Manual Docker command
docker logs stampcar-robot-container
```

### Debug Mode

```bash
# Open shell in container
./docker-run.sh shell

# Or manually
docker run -it --rm \
  -v "$(pwd)/Logs:/app/Logs" \
  -e DISPLAY=:99 \
  --shm-size=2g \
  --security-opt seccomp:unconfined \
  stampcar-robot-tests \
  /bin/bash
```

### Verify Chrome Installation

```bash
# Check Chrome version
docker run --rm stampcar-robot-tests google-chrome --version

# Check ChromeDriver version
docker run --rm stampcar-robot-tests chromedriver --version

# Test Xvfb
docker run --rm stampcar-robot-tests /usr/local/bin/docker-entrypoint.sh echo "Xvfb test"
```

## 🐛 Troubleshooting

### Common Issues

1. **Chrome crashes in container**
   - Ensure `--shm-size=2gb` is set
   - Use `--security-opt seccomp:unconfined`

2. **Permission errors with mounted volumes**
   ```bash
   sudo chown -R $USER:$USER ./Logs
   ```

3. **Port already in use (8080)**
   ```bash
   # Change port mapping
   docker run -p 8081:8080 ...
   ```

4. **Container exits immediately**
   - Check logs: `docker logs <container_name>`
   - Verify entrypoint script is executable

### Performance Optimization

```bash
# Increase container resources
docker run --memory=4g --cpus=2 ...

# Use larger shared memory
docker run --shm-size=4gb ...
```

## 🔄 Development Workflow

1. **Make changes** to robot files or Python code
2. **Rebuild image** with `./docker-run.sh build`
3. **Run tests** with `./docker-run.sh test license ABC123`
4. **Check results** in `./Logs` directory
5. **Debug if needed** with `./docker-run.sh shell`

## 📦 Production Deployment

For production deployment, consider:

1. **Multi-stage builds** to reduce image size
2. **Health checks** for container monitoring
3. **Resource limits** for memory and CPU
4. **Log aggregation** for centralized logging
5. **Secrets management** for credentials

Example production Docker run:

```bash
docker run -d \
  --name stampcar-prod \
  --restart unless-stopped \
  -p 8080:8080 \
  -v /var/log/stampcar:/app/Logs \
  --memory=2g \
  --cpus=1 \
  --health-cmd="curl -f http://localhost:8080/status || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  stampcar-robot-tests
```

## 🆘 Support

If you encounter issues:

1. Check this README for troubleshooting steps
2. Review Docker logs for error messages
3. Verify system requirements are met
4. Test with manual Docker commands first
