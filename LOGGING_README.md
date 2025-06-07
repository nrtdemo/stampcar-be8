# Robot Framework Test with Enhanced Output Logging

This setup provides comprehensive logging for Robot Framework test failures and successes, with all output files stored in the root folder.

## Features

✅ **Comprehensive Logging**: All logs, reports, and output files are saved to the root folder  
✅ **Failure Handling**: Automatic screenshot capture and page source saving on test failure  
✅ **Timestamped Files**: All output files include timestamps for version tracking  
✅ **Standard File Names**: Latest files are also copied to standard names (log.html, report.html, output.xml)  
✅ **Error Details**: Detailed error logging with execution metadata  

## Output Files Location

All output files are saved in the **root folder** (`/Users/nrtdemo/Project/stampcar-be8/`):

### Timestamped Files
- `log_YYYYMMDD_HHMMSS.html` - Detailed execution log
- `report_YYYYMMDD_HHMMSS.html` - Test report
- `output_YYYYMMDD_HHMMSS.xml` - Raw test output
- `execution_log_YYYYMMDD_HHMMSS.json` - Execution metadata (Python runner only)

### Standard Files (Latest)
- `log.html` - Latest log file
- `report.html` - Latest report file  
- `output.xml` - Latest output file

### Failure Debug Files (in ./Logs/)
- `error_YYYYMMDD_HHMMSS.png` - Screenshot when test fails
- `page_source_YYYYMMDD_HHMMSS.html` - Page source when test fails

## Usage

### Option 1: Bash Script (Simple)
```bash
# Make executable (first time only)
chmod +x run_robot.sh

# Run with keyword search
./run_robot.sh "search_keyword"

# Run with license plate search  
./run_robot.sh "ABC123" "license"

# Run with serial number search
./run_robot.sh "SER456" "" "serial"
```

### Option 2: Python Script (Advanced)
```bash
# Make executable (first time only)
chmod +x run_robot.py

# Run with keyword search
./run_robot.py --keyword "search_keyword"

# Run with license plate search
./run_robot.py --license "ABC123"

# Run with serial number search  
./run_robot.py --serial "SER456"

# Run in headless mode
./run_robot.py --keyword "search_keyword" --headless

# Specify custom root directory
./run_robot.py --keyword "search_keyword" --root-dir "/custom/path"
```

### Option 3: Direct Robot Command
```bash
robot --outputdir . --log log_$(date +%Y%m%d_%H%M%S).html --report report_$(date +%Y%m%d_%H%M%S).html --output output_$(date +%Y%m%d_%H%M%S).xml --loglevel INFO --variable PARAMETERS.KEYWORD:"your_keyword" stampcar-be8.robot
```

## Test Configuration

The robot test includes these failure handling features:

1. **Suite Setup**: Creates log directory
2. **Test Teardown**: Captures failure details if test fails
3. **Suite Teardown**: Logs completion status and closes browsers

### Failure Handling
When a test fails, the following happens automatically:
- Screenshot is captured to `./Logs/error_TIMESTAMP.png`
- Page source is saved to `./Logs/page_source_TIMESTAMP.html`  
- Error details are logged with timestamp
- Browser is closed properly

### Variables
- `PARAMETERS.KEYWORD` - Search term
- `PARAMETERS.LICENSE` - License plate (if provided, uses license search)
- `PARAMETERS.SERIAL` - Serial number  
- `CONFIG.BROWSER.DEFAULT` - Browser type (chrome/headlesschrome)

## Examples

## Troubleshooting

1. **Check the latest log.html** for detailed execution steps
2. **Check the latest report.html** for test results summary
3. **Check ./Logs/** folder for screenshots and page source on failures
4. **Check execution_log_*.json** (Python runner) for command details

## File Structure After Test Run

```
./Logs/
├── log.html                          # Latest log (copy)
├── report.html                       # Latest report (copy)
├── output.xml                        # Latest output (copy)
└── Capture/
    ├── error_20250604_143022.png     # Failure screenshot
    └── page_source_20250604_143022.html # Failure page source
```
