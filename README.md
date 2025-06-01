# THE 9 TOWER E-Stamp Automation

This project contains automated tests for THE 9 TOWER e-stamp system using Robot Framework and SeleniumLibrary.

## Project Structure

```
stamp-car-be8/
├── stampcar-be8.robot          # Main test file
├── resources/
│   ├── page_objects.robot      # Page Object Model implementation
│   └── config.robot           # Configuration and test data
├── Capture/                   # Screenshots directory
├── Logs/                      # Test execution logs
├── Reports/                   # Test reports
└── README.md                  # This file
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

### Prerequisites
- Python 3.7+
- Robot Framework
- SeleniumLibrary
- Chrome browser (or configure for other browsers)

### Installation
```bash
pip install robotframework
pip install robotframework-seleniumlibrary
```

### Running Tests

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

### Test Data
- Default username: BE8
- Default password: 1234
- Test vehicles are configured in `resources/config.robot`

### Timeouts
- Implicit wait: 10 seconds
- Explicit wait: 30 seconds
- Page load timeout: 60 seconds

### Output Directories
- Screenshots: `./Capture/`
- Logs: `./Logs/`
- Reports: `./Reports/`

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

## Troubleshooting

### Common Issues
1. **Element not found**: Check if selectors in `page_objects.robot` are current
2. **Timeout errors**: Adjust timeout values in `config.robot`
3. **Browser issues**: Ensure ChromeDriver is compatible with your Chrome version
4. **Login failures**: Verify credentials in `config.robot`

### Debug Mode
Run tests with increased logging:
```bash
robot --loglevel DEBUG stampcar-be8.robot
```

## Maintenance

### Updating Selectors
UI element selectors are centralized in `resources/page_objects.robot`. Update them there if the application UI changes.

### Adding New Test Data
Add new test vehicles to the lists in `resources/config.robot`.

### Adding New Test Cases
Follow the existing pattern in the main test file and use the established keywords from the resource files.
