# Robot Framework Docker Testing Environment

This project provides a complete Docker-based testing environment for running Robot Framework automated web tests with browser automation capabilities.

## 🚀 Quick Start

### Prerequisites
- Docker installed on your system
- Basic understanding of Robot Framework

### Running Tests

#### Using the Docker Test Runner Script (Recommended)
```bash
# Run tests with a license plate
./run-docker-tests.sh --license ABC123

# Run tests with a serial number  
./run-docker-tests.sh --serial SN123456

# Show help
./run-docker-tests.sh --help
```

#### Using Docker Directly
```bash
# Basic test run
docker run --rm -v "$(pwd):/app" stampcar-robot-test:latest robot robots/stampcar-be8.robot

# Run with parameters
docker run --rm -v "$(pwd):/app" stampcar-robot-test:latest \
  robot --variable PARAMETERS.LICENSE:ABC123 robots/stampcar-be8.robot

# Run with custom output directory
docker run --rm -v "$(pwd):/app" -v "$(pwd)/test-results:/app/Logs" \
  stampcar-robot-test:latest robot --outputdir /app/Logs robots/stampcar-be8.robot
```

## 🏗️ Building the Docker Image

```bash
# Build the image
docker build -t stampcar-robot-test:latest .

# Build for specific architecture (if needed)
docker buildx build --platform linux/amd64 -t stampcar-robot-test:latest .
docker buildx build --platform linux/arm64 -t stampcar-robot-test:latest .
```

## 📁 Project Structure

```
stampcar-be8/
├── Dockerfile                    # Multi-architecture Docker configuration
├── docker-entrypoint.sh         # Container startup script
├── run-docker-tests.sh          # Convenient test runner script
├── requirements.txt              # Python dependencies
├── robots/
│   └── stampcar-be8.robot       # Main Robot Framework test file
├── resources/
│   └── docker_config.robot     # Docker environment configuration
├── Logs/                        # Test output directory
│   ├── log.html                 # Test execution log
│   ├── output.xml               # Test results in XML format
│   ├── report.html              # Test report
│   └── Capture/                 # Screenshots directory
└── .dockerignore                # Docker build exclusions
```

## 🛠️ Environment Features

### Multi-Architecture Support
- **AMD64**: Uses Google Chrome with ChromeDriver
- **ARM64**: Uses Chromium browser (compatible with Apple Silicon Macs)
- Automatic architecture detection and browser configuration

### Browser Configuration
- **Headless Mode**: All tests run in headless mode inside Docker
- **Virtual Display**: Uses Xvfb for headless browser rendering
- **Optimized Options**: Pre-configured Chrome/Chromium options for container environment

### Test Execution
- **Isolated Environment**: Each test run is completely isolated
- **Volume Mounting**: Test files and results are shared between host and container
- **Error Handling**: Automatic screenshot capture on test failures
- **Logging**: Comprehensive test logging and reporting

## 🎯 Test Configuration

### Environment Variables
The Docker container automatically sets these environment variables:
- `ROBOT_FRAMEWORK_DOCKER=true`: Indicates Docker environment
- `DISPLAY=:99`: Virtual display for headless browser
- `TARGETARCH`: Container architecture (amd64/arm64)

### Browser Options
The test configuration automatically applies appropriate browser options based on the environment:

**Docker Environment:**
- `--headless`: Run browser without GUI
- `--no-sandbox`: Required for containerized Chrome
- `--disable-dev-shm-usage`: Prevent shared memory issues
- `--disable-gpu`: Disable GPU acceleration
- `--window-size=1920,1080`: Standard window size
- `--remote-debugging-port=9222`: Enable debugging

**Local Environment:**
- Same options but without `--headless` flag

### Test Parameters
You can pass parameters to your tests:

```bash
# License plate search
./run-docker-tests.sh --license "ABC-123"

# Serial number search  
./run-docker-tests.sh --serial "SN123456"
```

## 📊 Test Results

After running tests, you'll find results in the `Logs/` directory:

- **log.html**: Detailed test execution log
- **output.xml**: Machine-readable test results
- **report.html**: Human-readable test report
- **Capture/**: Screenshots (including error screenshots)

## 🔧 Customization

### Adding New Tests
1. Create new `.robot` files in the `robots/` directory
2. Follow the existing test structure and use the `docker_config.robot` resource
3. Run tests using the same Docker commands

### Modifying Browser Configuration
Edit `resources/docker_config.robot` to change:
- Browser options
- Environment detection logic
- Browser selection criteria

### Custom Test Runner
Modify `run-docker-tests.sh` to add:
- Additional command-line options
- Custom test file selection
- Different output configurations

## 🐛 Troubleshooting

### Common Issues

**Browser not starting:**
- Ensure the Docker container has enough memory allocated
- Check that the virtual display (Xvfb) is running properly

**Tests failing with timeout:**
- Increase timeout values in the test configuration
- Check network connectivity from within the container

**Permission issues:**
- Ensure proper volume mounting permissions
- The container runs as `robotuser` with appropriate file permissions

**Architecture-specific issues:**
- On Apple Silicon Macs, ensure you're using the ARM64-compatible image
- For Intel Macs or Linux, the AMD64 image should work fine

### Debug Mode
Run tests with additional logging:

```bash
docker run --rm -v "$(pwd):/app" stampcar-robot-test:latest \
  robot --loglevel DEBUG robots/stampcar-be8.robot
```

## 🔄 Continuous Integration

This Docker setup is ideal for CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Robot Framework Tests
  run: |
    docker run --rm -v ${{ github.workspace }}:/app \
      stampcar-robot-test:latest \
      robot --outputdir /app/test-results robots/stampcar-be8.robot
```

## 📝 Notes

- The container automatically detects the architecture and configures the appropriate browser
- All tests run in headless mode for consistency and performance
- Screenshot capture is automatically enabled for debugging failed tests
- The environment is completely isolated and reproducible across different systems

## 🤝 Contributing

To contribute to this testing environment:

1. Test your changes with both AMD64 and ARM64 architectures
2. Ensure backward compatibility with existing test files
3. Update documentation for any new features
4. Verify that the Docker build process works correctly

## 📄 License

This project follows the same license as the main application.
