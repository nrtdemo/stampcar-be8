*** Settings ***
Documentation     Configuration and test data for THE 9 TOWER e-stamp automation

*** Variables ***
# Application Configuration
${CONFIG.BASE_URL}              http://the9estamp.grandcanalland.com
${CONFIG.LOGIN_URL}             ${CONFIG.BASE_URL}/web-estamp/login
${CONFIG.TIMEOUT.IMPLICIT}      10s
${CONFIG.TIMEOUT.EXPLICIT}      30s
${CONFIG.TIMEOUT.PAGE_LOAD}     60s

# Browser Configuration
${CONFIG.BROWSER.DEFAULT}       chrome
${CONFIG.BROWSER.HEADLESS}      headlesschrome
${CONFIG.BROWSER.OPTIONS}       --disable-web-security --no-sandbox --disable-dev-shm-usage --disable-gpu --window-size=1920,1080

# Test Data
${TEST_DATA.USERNAME}           BE8
${TEST_DATA.PASSWORD}           1234

# Test Vehicles - License Plates
@{TEST_DATA.LICENSE_PLATES}     1405    2247    5276    6463

# Test Vehicles - Serial Numbers  
@{TEST_DATA.SERIAL_NUMBERS}     SN001   SN002   SN003   SN004

# File Paths
${CONFIG.SCREENSHOT_DIR}        ./Capture
${CONFIG.LOGS_DIR}             ./Logs
${CONFIG.REPORTS_DIR}          ./Reports

# Error Messages
${ERRORS.LOGIN_FAILED}          Login failed - please check credentials
${ERRORS.VEHICLE_NOT_FOUND}     Vehicle not found in system
${ERRORS.STAMP_FAILED}          E-stamp application failed
${ERRORS.NETWORK_ERROR}         Network connection error

*** Keywords ***
Get Test Vehicle License Plate
    [Documentation]    Get a test license plate by index
    [Arguments]    ${index}=0
    ${license_plate}=    Get From List    ${TEST_DATA.LICENSE_PLATES}    ${index}
    RETURN    ${license_plate}

Get Test Vehicle Serial Number
    [Documentation]    Get a test serial number by index
    [Arguments]    ${index}=0
    ${serial_number}=    Get From List    ${TEST_DATA.SERIAL_NUMBERS}    ${index}
    RETURN    ${serial_number}

Create Output Directories
    [Documentation]    Create necessary output directories
    Create Directory    ${CONFIG.SCREENSHOT_DIR}
    Create Directory    ${CONFIG.LOGS_DIR}
    Create Directory    ${CONFIG.REPORTS_DIR}
