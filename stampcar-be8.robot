*** Settings ***
Documentation     Automated stamp car testing for THE 9 TOWER e-stamp system
Library           SeleniumLibrary
Library           Collections
Library           OperatingSystem
Resource          resources/page_objects.robot
Resource          resources/config.robot
Resource          resources/docker_config.robot
Test Setup        Setup Test Environment
Test Teardown     Cleanup Test Environment
Suite Setup       Create Output Directories
Suite Teardown    Generate Test Report

*** Variables ***
# Test Instance Variables (set during test execution)
${LICENSE_PLATE}                ${EMPTY}
${SERIAL_NUMBER}                ${EMPTY}

*** Keywords ***
# Setup and Teardown Keywords
Setup Test Environment
    [Documentation]    Initialize browser and set timeouts
    Set Selenium Implicit Wait    ${CONFIG.TIMEOUT.IMPLICIT}
    Set Selenium Timeout          ${CONFIG.TIMEOUT.EXPLICIT}

Cleanup Test Environment
    [Documentation]    Close browser and cleanup resources
    Close All Browsers

Generate Test Report
    [Documentation]    Generate final test execution report
    Log    Test execution completed. Check reports in ${CONFIG.REPORTS_DIR}

# Application Flow Keywords
Open Login Page
    [Documentation]    Navigate to the login page and verify it loads
    Open Browser For Docker    ${CONFIG.LOGIN_URL}
    Wait Until Element Is Visible    ${LOGIN_PAGE.USERNAME_INPUT}    timeout=${CONFIG.TIMEOUT.EXPLICIT}

Perform User Login
    [Documentation]    Complete login process with credentials
    [Arguments]    ${username}=${TEST_DATA.USERNAME}    ${password}=${TEST_DATA.PASSWORD}
    Enter Login Credentials    ${username}    ${password}
    Submit Login Form
    Verify Login Success
    Navigate To Parking Section

Search Vehicle By License Plate
    [Documentation]    Search for a vehicle using license plate number
    [Arguments]    ${license_plate}
    Enter Search Term    ${license_plate}
    Search By License Plate

Search Vehicle By Serial Number
    [Documentation]    Search for a vehicle using serial number
    [Arguments]    ${serial_number}
    Enter Search Term    ${serial_number}
    Search By Serial Number

Process Vehicle Selection
    [Documentation]    Select and confirm the found vehicle
    Select Vehicle From Results
    Confirm Vehicle Selection

Apply E-Stamp To Vehicle
    [Documentation]    Apply free e-stamp to the selected vehicle
    Select Free E-Stamp Option
    Submit E-Stamp Application
    Confirm E-Stamp Application

Capture Process Verification
    [Documentation]    Take screenshot for process verification
    [Arguments]    ${identifier}
    ${screenshot_path}=    Set Variable    ${CONFIG.SCREENSHOT_DIR}/${identifier}
    Create Directory    ${screenshot_path}
    
    # Search again to verify the process
    Enter Search Term    ${identifier}
    Run Keyword If    "${LICENSE_PLATE}" != "${EMPTY}"    Search By License Plate
    ...    ELSE    Search By Serial Number
    
    Sleep    2s    # Wait for page to stabilize
    Capture Page Screenshot    ${screenshot_path}/process_verification.png
    Log    Screenshot saved: ${screenshot_path}/process_verification.png

# High-Level Business Keywords
Execute Vehicle Search
    [Documentation]    Search for vehicle using either license plate or serial number
    Run Keyword If    "${LICENSE_PLATE}" != "${EMPTY}"    Search Vehicle By License Plate    ${LICENSE_PLATE}
    ...    ELSE IF    "${SERIAL_NUMBER}" != "${EMPTY}"    Search Vehicle By Serial Number    ${SERIAL_NUMBER}
    ...    ELSE    Fail    ${ERRORS.VEHICLE_NOT_FOUND}: Either LICENSE_PLATE or SERIAL_NUMBER must be provided

Complete E-Stamp Process
    [Documentation]    Execute the complete e-stamp application process
    Execute Vehicle Search
    Process Vehicle Selection
    Apply E-Stamp To Vehicle
    
    # Determine identifier for screenshot
    ${identifier}=    Set Variable If    "${LICENSE_PLATE}" != "${EMPTY}"    ${LICENSE_PLATE}    ${SERIAL_NUMBER}
    Capture Process Verification    ${identifier}
    
    Log    E-stamp process completed successfully for vehicle: ${identifier}

*** Test Cases ***
Validate E-Stamp Process With License Plate
    [Documentation]    Test e-stamp process using license plate identification
    [Tags]    smoke    license_plate    critical
    [Setup]    Set Test Variable    ${LICENSE_PLATE}    1405
    Open Login Page
    Perform User Login
    Complete E-Stamp Process

Validate E-Stamp Process With Serial Number
    [Documentation]    Test e-stamp process using serial number identification
    [Tags]    smoke    serial_number    critical
    [Setup]    Set Test Variable    ${SERIAL_NUMBER}    2247
    Open Login Page
    Perform User Login
    Complete E-Stamp Process

Data Driven E-Stamp Testing
    [Documentation]    Comprehensive testing with multiple vehicles using template
    [Tags]    regression    data_driven
    [Template]    Execute E-Stamp Workflow
    # Test data: license_plate | serial_number | description
    1405        ${EMPTY}      License plate test - Vehicle 1405
    ${EMPTY}    2247          Serial number test - Vehicle 2247
    5276        ${EMPTY}      License plate test - Vehicle 5276
    ${EMPTY}    6463          Serial number test - Vehicle 6463

Negative Test - Invalid Vehicle Search
    [Documentation]    Test behavior with invalid vehicle identifiers
    [Tags]    negative    error_handling
    [Setup]    Set Test Variable    ${LICENSE_PLATE}    INVALID999
    Open Login Page
    Perform User Login
    Run Keyword And Expect Error    *    Execute Vehicle Search

Login Validation Test
    [Documentation]    Validate login functionality with correct credentials
    [Tags]    smoke    login
    Open Login Page
    Perform User Login
    [Teardown]    Log    Login validation completed successfully

*** Keywords ***
Execute E-Stamp Workflow
    [Documentation]    Template keyword for data-driven testing
    [Arguments]    ${license_plate}    ${serial_number}    ${description}
    Log    Executing: ${description}
    Set Test Variable    ${LICENSE_PLATE}    ${license_plate}
    Set Test Variable    ${SERIAL_NUMBER}    ${serial_number}
    Open Login Page
    Perform User Login
    Complete E-Stamp Process