# THE 9 TOWER E-Stamp Automation Features

### Web-Based Test Runner
- **Modern Web Interface**: Beautiful, responsive web UI for running Robot Framework tests
- **Real-time Execution**: Live test execution monitoring with real-time logs
- **Interactive Results**: Web-based test results viewing and analysis
- **Parameter Configuration**: Easy test configuration through web forms
- **Browser Selection**: Support for multiple browsers (Chrome, Firefox, Edge, headless modes)
- **Tag-based Execution**: Run specific test subsets using tags

### Docker Support
- **Containerized Execution**: Full Docker support for consistent test environments
- **Multi-platform Deployment**: Works on any platform supporting Docker
- **Development Environment**: Docker Compose setup for development
- **Production Ready**: Optimized Docker configuration for production deployments

### Robot Framework Automation
- **Page Object Model**: Separated UI elements and actions into dedicated resource files
- **Configuration Management**: Centralized configuration and test data
- **Error Handling**: Improved error handling and verification steps
- **Modular Design**: Separated concerns with dedicated resource filess project is a comprehensive Robot Framework automation solution for THE 9 TOWER e-stamp system, featuring both command-line execution and a modern web-based test runner interface built with Flask.

## Project Structure

```
stampcar-be8/
├── stampcar-be8.robot          # Main Robot Framework test file
├── main.py                     # Flask web application for test runner
├── resources/                  # Robot Framework resources
│   ├── page_objects.robot      # Page Object Model implementation
│   ├── config.robot           # Configuration and test data
│   └── docker_config.robot    # Docker-specific configuration
├── templates/
│   └── index.html             # Web interface template
├── static/                    # Static web assets
├── Capture/                   # Screenshots directory
├── Logs/                      # Test execution logs
├── Reports/                   # Test reports
├── Dockerfile                 # Docker containerization
├── docker-compose.yml         # Docker Compose configuration
├── docker-compose.dev.yml     # Development Docker Compose
├── docker-run.sh             # Docker build and run script
├── requirements.txt          # Python dependencies
├── DOCKER.md                 # Docker deployment guide
└── README.md                 # This documentation
```

## Features

### Refactored Implementation
- **Page Object Model**: Separated UI elements and actions into dedicated resource files
- **Configuration Management**: Centralized configuration and test data
- **Better Naming**: Descriptive variable and keyword names following Robot Framework conventions
- **Error Handling**: Improved error handling and verification steps
- **Modular Design**: Separated concerns with dedicated resource files

### Test Capabilities
- **License Plate Search**: Search vehicles by license plate number
- **Serial Number Search**: Search vehicles by serial number
- **E-Stamp Application**: Apply free e-stamp to selected vehicles
- **Process Verification**: Screenshot capture for verification
- **Data-Driven Testing**: Template-based testing with multiple test data sets
- **Negative Testing**: Error handling validation

## Test Cases

1. **Validate E-Stamp Process With License Plate**
   - Tests the complete e-stamp process using license plate identification
   - Tags: smoke, license_plate, critical

2. **Validate E-Stamp Process With Serial Number**
   - Tests the complete e-stamp process using serial number identification
   - Tags: smoke, serial_number, critical

3. **Data Driven E-Stamp Testing**
   - Comprehensive testing with multiple vehicles using templates
   - Tags: regression, data_driven

4. **Negative Test - Invalid Vehicle Search**
   - Tests error handling with invalid vehicle identifiers
   - Tags: negative, error_handling

5. **Login Validation Test**
   - Validates login functionality
   - Tags: smoke, login

## Usage

### Method 1: Web Interface (Recommended)

#### Prerequisites
- Python 3.7+
- Chrome browser (or other supported browsers)

#### Quick Start
```bash
# Install dependencies
pip install -r requirements.txt

# Run the web application
python main.py
```

The web interface will be available at `http://localhost:8080`

#### Web Interface Features
- **Test Configuration**: Select browser, tags, and execution options
- **Real-time Monitoring**: Watch test execution progress in real-time
- **Results Viewing**: Integrated test results and log viewing
- **Screenshot Gallery**: View captured screenshots directly in the browser

### Method 2: Docker (Production Ready)

#### Quick Docker Start
```bash
# Make script executable and run
chmod +x docker-run.sh
./docker-run.sh
```

#### Manual Docker Commands
```bash
# Build the image
docker build -t robot-web-runner:latest .

# Run the container
docker run -d \
  --name robot-web-runner \
  -p 8080:8080 \
  robot-web-runner:latest
```

#### Docker Compose
```bash
# Development environment
docker-compose -f docker-compose.dev.yml up

# Production environment
docker-compose up
```

### Method 3: Command Line

#### Prerequisites
- Python 3.7+
- Robot Framework
- SeleniumLibrary
- Chrome browser (or configure for other browsers)

#### Installation
```bash
pip install -r requirements.txt
```

#### Running Tests

#### Run all tests:
```bash
robot stampcar-be8.robot
```

#### Run specific test tags:
```bash
# Run only smoke tests
robot --include smoke stampcar-be8.robot

# Run only license plate tests
robot --include license_plate stampcar-be8.robot

# Run regression tests
robot --include regression stampcar-be8.robot
```

#### Run with custom browser:
```bash
robot --variable CONFIG.BROWSER.DEFAULT:firefox stampcar-be8.robot
```

#### Run in headless mode:
```bash
robot --variable CONFIG.BROWSER.DEFAULT:headlesschrome stampcar-be8.robot
```

## Configuration

### Web Application Settings
- **Default Port**: 8080 (configurable via environment variables)
- **Browser Support**: Chrome, Firefox, Edge, Safari, headless modes
- **File Upload**: Support for custom Robot Framework files
- **Environment Variables**: 
  - `PORT`: Web server port (default: 8080)
  - `FLASK_ENV`: Flask environment (development/production)

### Test Data
- Default username: BE8
- Default password: 1234
- Test vehicles are configured in `resources/config.robot`
- Docker-specific configuration in `resources/docker_config.robot`

### Timeouts
- Implicit wait: 10 seconds
- Explicit wait: 30 seconds
- Page load timeout: 60 seconds

### Output Directories
- Screenshots: `./Capture/`
- Logs: `./Logs/`
- Reports: `./Reports/`

## Deployment Options

### Local Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run with Flask development server
python main.py
```

### Production with Gunicorn
```bash
# Install Gunicorn (included in requirements.txt)
gunicorn --bind 0.0.0.0:8080 main:app
```

### Cloud Deployment
The project includes:
- `Procfile` for Heroku deployment
- `Dockerfile` for container-based deployment
- Environment variable configuration for cloud platforms

### Docker Production
```bash
# Build production image
docker build -t stampcar-automation .

# Run with production settings
docker run -p 8080:8080 \
  -e FLASK_ENV=production \
  stampcar-automation
```

## Best Practices Implemented

1. **Page Object Model**: UI elements and actions are separated into page objects
2. **Configuration Management**: All configuration is centralized
3. **Descriptive Naming**: Variables and keywords use clear, descriptive names
4. **Documentation**: All keywords and test cases are properly documented
5. **Error Handling**: Proper error handling and verification steps
6. **Modular Design**: Code is organized into logical modules
7. **Data-Driven Testing**: Support for template-based testing
8. **Tagging Strategy**: Tests are properly tagged for selective execution
9. **Setup/Teardown**: Proper test setup and cleanup procedures
10. **Screenshot Verification**: Process verification through screenshots
11. **Web Interface**: Modern web-based test runner for better user experience
12. **Containerization**: Docker support for consistent deployment environments
13. **Real-time Monitoring**: Live test execution feedback through web interface
14. **Cross-platform Support**: Works on Windows, macOS, and Linux

## API Endpoints

The Flask web application provides the following REST API endpoints:

- `GET /` - Main web interface
- `POST /run-robot` - Execute Robot Framework tests
- `GET /status` - Get current test execution status
- `GET /results` - Retrieve test results
- `GET /logs` - Get execution logs
- `POST /upload` - Upload custom Robot Framework files

## Dependencies

### Python Packages
- **Flask**: Web framework for the test runner interface
- **Gunicorn**: WSGI HTTP Server for production deployment
- **Selenium**: Web browser automation
- **Robot Framework**: Test automation framework
- **Robot Framework SeleniumLibrary**: Robot Framework library for web testing
- **WebDriver Manager**: Automatic webdriver management
- **ChromeDriver Binary**: Chrome browser driver

## Troubleshooting

### Common Issues
1. **Element not found**: Check if selectors in `page_objects.robot` are current
2. **Timeout errors**: Adjust timeout values in `config.robot`
3. **Browser issues**: Ensure ChromeDriver is compatible with your Chrome version
4. **Login failures**: Verify credentials in `config.robot`
5. **Web interface not loading**: Check if port 8080 is available
6. **Docker build failures**: Ensure Docker is installed and running
7. **Permission errors**: Make sure `docker-run.sh` is executable (`chmod +x docker-run.sh`)

### Debug Mode
Run tests with increased logging:
```bash
# Command line
robot --loglevel DEBUG stampcar-be8.robot

# Web interface - select "DEBUG" log level in the interface
```

### Docker Troubleshooting
```bash
# Check container status
docker ps

# View container logs
docker logs robot-web-runner

# Access container shell
docker exec -it robot-web-runner /bin/bash

# Remove and rebuild container
docker rm -f robot-web-runner
docker rmi robot-web-runner:latest
./docker-run.sh
```

### Web Interface Issues
- **Port conflicts**: Change the port using environment variable: `PORT=8081 python main.py`
- **Browser compatibility**: Use the browser selection dropdown in the web interface
- **File upload issues**: Ensure uploaded files are valid Robot Framework files

## Maintenance

### Updating Selectors
UI element selectors are centralized in `resources/page_objects.robot`. Update them there if the application UI changes.

### Adding New Test Data
Add new test vehicles to the lists in `resources/config.robot`.

### Adding New Test Cases
Follow the existing pattern in the main test file and use the established keywords from the resource files.

### Updating Dependencies
```bash
# Update Python packages
pip install --upgrade -r requirements.txt

# Update Docker base image
# Edit Dockerfile and rebuild: docker build -t robot-web-runner:latest .
```

### Performance Optimization
- Use headless browsers for faster execution
- Adjust timeouts based on application performance
- Consider parallel test execution for large test suites
- Monitor resource usage in Docker environments

## Contributing

1. Follow Robot Framework coding standards
2. Update documentation when adding new features
3. Test both command-line and web interface functionality
4. Ensure Docker compatibility when making changes
5. Add appropriate tags to new test cases

## Support

For detailed Docker deployment instructions, see [DOCKER.md](DOCKER.md).

For issues and feature requests, please check the troubleshooting section first, then create detailed bug reports including:
- Browser and version used
- Execution method (CLI, web interface, Docker)
- Full error messages and logs
- Steps to reproduce the issue
