# StampCar Robot Framework Test Runner

This Flask web application provides a modern web interface for running Robot Framework tests for the StampCar system on THE 9 TOWER.

## Features

### Web Interface
- **Modern Responsive Design**: Clean, professional interface with Bootstrap 5
- **Real-time Test Execution**: Live status updates and log streaming
- **Test Type Selection**: Support for both License Plate and Serial Number testing
- **Results Display**: Comprehensive test results with screenshots
- **Execution Logs**: Real-time log display with auto-scrolling
- **Mobile Friendly**: Responsive design that works on all devices

### API Endpoints

#### Modern API
- `POST /run-robot` - Start a new robot test
- `GET /status` - Get current test execution status
- `GET /logs` - Get test execution logs
- `GET /screenshot/<filename>` - Serve screenshot images

#### Legacy API (Backward Compatibility)
- `GET /license?v=LICENSE_PLATE` - Run license plate test (returns screenshot)
- `GET /serial?v=SERIAL_NUMBER` - Run serial number test (returns screenshot)

## Usage

### Running the Application

1. **Development Mode**:
   ```bash
   python main.py
   ```
   The application will start on `http://localhost:8080`

2. **Production Mode**:
   ```bash
   gunicorn main:app
   ```

### Using the Web Interface

1. Open your browser to `http://localhost:8080`
2. Select test type (License Plate or Serial Number)
3. Enter the test value
4. Click "Start Test"
5. Monitor real-time status and logs
6. View results and screenshots when complete

### Using the API

#### Start a Test
```bash
curl -X POST http://localhost:8080/run-robot \
  -F "test_type=license" \
  -F "test_value=ABC123"
```

#### Check Status
```bash
curl http://localhost:8080/status
```

#### Get Logs
```bash
curl http://localhost:8080/logs
```

## File Structure

```
├── main.py                 # Flask application
├── templates/
│   └── index.html         # Web interface template
├── static/
│   └── style.css          # Custom CSS styles
├── robots/
│   └── stampcar-be8.robot # Robot Framework test file
├── Logs/                  # Test execution logs and screenshots
│   ├── Capture/          # Screenshot directory
│   ├── log.html          # Test execution log
│   ├── output.xml        # Test results XML
│   └── report.html       # Test report
└── requirements.txt       # Python dependencies
```

## Configuration

The application can be configured using environment variables:

- `PORT`: Server port (default: 8080)
- `HOST`: Server host (default: 0.0.0.0)
- `FLASK_ENV`: Set to "development" for debug mode

## Dependencies

- Flask 3.1.1 - Web framework
- Robot Framework 7.3 - Test automation
- Selenium Library 6.7.1 - Web automation
- Chrome WebDriver - Browser automation

## Test Execution

The application executes Robot Framework tests with the following command structure:

```bash
robot -d ./Logs --variable license:VALUE ./robots/stampcar-be8.robot
robot -d ./Logs --variable serial:VALUE ./robots/stampcar-be8.robot
```

Results are stored in the `./Logs` directory, and screenshots are captured in `./Logs/Capture/`.

## Features Overview

### Real-time Status Monitoring
- Visual status indicators (Ready, Running, Success, Error)
- Live execution time tracking
- Automatic status polling every 2 seconds

### Test Results
- Success/failure indication
- Return code display
- Error message handling
- Screenshot display when available
- Detailed output logs

### User Experience
- Intuitive test type selection
- Form validation
- Loading states and animations
- Responsive design for all screen sizes
- Auto-scrolling logs
- Clear visual feedback

### Error Handling
- Comprehensive error reporting
- Timeout handling (5-minute limit)
- File not found handling
- Network error resilience

This web interface provides a complete solution for running and monitoring Robot Framework tests with a professional, user-friendly interface.
