# Docker Selenium Grid Setup for Flask + Robot Framework

This setup provides a complete environment for running your Flask web application with Selenium Grid for automated testing using Robot Framework.

## 🏗️ Architecture

The setup includes:
- **Flask Application**: Your main web application running on port 8080
- **Selenium Hub**: Central hub coordinating browser sessions (port 4444)
- **Chrome Node**: Chrome browser instances for testing (with VNC on port 7900)
- **Firefox Node**: Firefox browser instances for testing (with VNC on port 7901)

## 🚀 Quick Start

1. **Start the complete environment:**
   ```bash
   ./run-selenium-grid.sh
   ```

2. **Access your applications:**
   - Flask Web App: http://localhost:8080
   - Selenium Grid Console: http://localhost:4444
   - Chrome VNC Viewer: http://localhost:7900 (password: `secret`)
   - Firefox VNC Viewer: http://localhost:7901 (password: `secret`)

## 📋 Available Commands

```bash
# Start all services (default)
./run-selenium-grid.sh start

# Stop all services
./run-selenium-grid.sh stop

# Restart all services
./run-selenium-grid.sh restart

# View logs from all services
./run-selenium-grid.sh logs

# Check service status
./run-selenium-grid.sh status

# Build Docker images
./run-selenium-grid.sh build
```

## 🔧 Manual Docker Commands

If you prefer to use Docker Compose directly:

```bash
# Start all services
docker-compose -f docker-compose.selenium.yml up -d

# View logs
docker-compose -f docker-compose.selenium.yml logs -f

# Stop all services
docker-compose -f docker-compose.selenium.yml down

# Rebuild and start
docker-compose -f docker-compose.selenium.yml up --build -d
```

## 🧪 Running Tests

Once the environment is running, you can execute Robot Framework tests in several ways:

### 1. Through the Flask Web Interface
- Open http://localhost:8080
- Use the web interface to run tests with specific parameters
- View results and screenshots directly in the browser

### 2. Direct Robot Framework Execution
```bash
# Execute tests using the docker environment
docker exec -it stampcar-flask-app robot --variable PARAMETERS.SERIAL:your-serial-number robots/stampcar-be8.robot
```

### 3. Using the Python Script
```bash
# From inside the Flask container
docker exec -it stampcar-flask-app python run_robot.py --serial your-serial-number
```

## 🖥️ VNC Access for Debugging

You can watch your tests run in real-time using VNC:

1. **Chrome Browser**: Open http://localhost:7900 in your browser
2. **Firefox Browser**: Open http://localhost:7901 in your browser
3. **Password**: `secret`

This is especially useful for debugging test failures or understanding what's happening during test execution.

## 📁 File Structure

```
├── docker-compose.selenium.yml  # Main compose file for Selenium Grid setup
├── Dockerfile.selenium          # Flask app dockerfile optimized for Selenium
├── run-selenium-grid.sh         # Convenience script to manage the environment
├── main.py                      # Flask web application
├── robots/
│   └── stampcar-be8.robot      # Main Robot Framework test file
├── resources/
│   └── docker_config.robot     # Environment-specific configurations
├── Logs/                        # Test execution logs and screenshots
└── test-results/          ****     # Additional test results
```

## 🔧 Configuration

### Environment Variables

The setup uses these key environment variables:

- `SELENIUM_HUB_URL`: URL of the Selenium Hub (automatically set to `http://selenium-hub:4444`)
- `ROBOT_FRAMEWORK_DOCKER`: Flag indicating Docker environment (set to `true`)
- `FLASK_ENV`: Flask environment mode
- `PORT`: Flask application port (default: 8080)

### Browser Configuration

The Robot Framework tests automatically detect the environment and configure browsers accordingly:

- **Selenium Grid**: Uses remote WebDriver pointing to the Selenium Hub
- **Local Development**: Uses local browser drivers
- **Docker (standalone)**: Uses headless browsers with local drivers

## 🐛 Troubleshooting

### Services not starting
```bash
# Check Docker is running
docker info

# Check for port conflicts
lsof -i :4444 -i :8080 -i :7900 -i :7901

# View detailed logs
docker-compose -f docker-compose.selenium.yml logs
```

### Tests failing to connect to Selenium Grid
```bash
# Check if Selenium Hub is responding
curl http://localhost:4444/status

# Check if nodes are registered
curl http://localhost:4444/grid/api/hub/status
```

### Browser sessions not starting
```bash
# Check browser node logs
docker-compose -f docker-compose.selenium.yml logs selenium-node-chrome
docker-compose -f docker-compose.selenium.yml logs selenium-node-firefox

# Restart specific services
docker-compose -f docker-compose.selenium.yml restart selenium-node-chrome
```

### Flask app not accessible
```bash
# Check Flask app logs
docker-compose -f docker-compose.selenium.yml logs flask-app

# Test Flask app health
curl http://localhost:8080/
```

## 📊 Monitoring

### Selenium Grid Console
- Access: http://localhost:4444
- Shows active sessions, available browsers, and node status

### VNC Sessions
- Chrome: http://localhost:7900 (password: `secret`)
- Firefox: http://localhost:7901 (password: `secret`)
- Watch tests execute in real-time

### Logs
- All logs are available via: `./run-selenium-grid.sh logs`
- Individual service logs: `docker-compose -f docker-compose.selenium.yml logs [service-name]`

## 🔒 Security Notes

- VNC password is set to `secret` - change this for production use
- The setup runs containers with appropriate security settings
- Chrome runs with `--no-sandbox` flag for container compatibility

## 🚀 Production Considerations

For production deployment:
1. Change VNC passwords
2. Use proper secrets management
3. Configure proper networking and security groups
4. Consider resource limits and scaling requirements
5. Set up proper logging and monitoring
6. Use production-grade WSGI server (Gunicorn is already included)
