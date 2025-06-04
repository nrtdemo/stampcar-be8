*** Settings ***
Documentation     Stamp Car on THE 9 TOWER using SeleniumLibrary.
Library           SeleniumLibrary
Library           DateTime
Library           OperatingSystem
Resource          ../resources/docker_config.robot
Suite Setup       Initialize Test Suite
Suite Teardown    Cleanup Test Suite
Test Teardown     Run Keyword If Test Failed    Handle Test Failure

*** Variables ***
# Browser Configuration
${CONFIG.BROWSER.URL}           http://the9estamp.grandcanalland.com/web-estamp/login
${CONFIG.BROWSER.DEFAULT}       chrome
${CONFIG.BROWSER.HEADLESS}      headlesschrome
${CONFIG.BROWSER.OPTIONS}       add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--remote-debugging-port=9222");add_argument("--disable-web-security");add_argument("--window-size=1920,1080");add_argument("--disable-features=VizDisplayCompositor")
${CONFIG.BROWSER.TIMEOUT}       3s

# Test Data
${CONFIG.USERNAME}              BE8
${CONFIG.PASSWORD}              1234
${PARAMETERS.LICENSE}           ${EMPTY}
${PARAMETERS.SERIAL}            ${EMPTY}

# Logging Configuration
${LOG.DIRECTORY}                ./Logs
${LOG.LEVEL}                    INFO
${LOG.TIMESTAMP_FORMAT}         %Y%m%d_%H%M%S

# Login Page Elements
${LOGIN_PAGE.USERNAME_INPUT}        id:MainContent_MainLogin_UserName
${LOGIN_PAGE.PASSWORD_INPUT}        id:MainContent_MainLogin_Password
${LOGIN_PAGE.SUBMIT_BUTTON}         id:MainContent_MainLogin_LoginButton
${LOGIN_PAGE.SUCCESS_MESSAGE}       xpath://div[contains(@class,'success')]

# Navigation Elements
${NAVIGATION.GOTO_PARKING_BUTTON}   xpath://a[contains(@href,'Search.aspx') or contains(text(),'Go to')]

# Search Page Elements
${SEARCH_PAGE.INPUT_FIELD}          id:MainContent_keywordTextBox
${SEARCH_PAGE.LICENSE_BUTTON}       id:MainContent_searchLicensneButton
${SEARCH_PAGE.SERIAL_BUTTON}        id:MainContent_searchSerialButton
${SEARCH_PAGE.SELECT_CAR_BUTTON}    id:MainContent_ParkingDetail_LinkButton1_0
${SEARCH_PAGE.CONFIRM_BUTTON}       id:MainContent_doneButton1

# E-Stamp Page Elements
${STAMP_PAGE.DROPDOWN}              id:MainContent_couponDropDown
${STAMP_PAGE.FREE_OPTION}           xpath://select[@id='MainContent_couponDropDown']/option[2]
${STAMP_PAGE.SUBMIT_BUTTON}         id:MainContent_submitButton
${STAMP_PAGE.SUCCESS_MESSAGE}       xpath://div[contains(@class,'success')]
${SEARCH_PAGE.NO_RESULTS_MESSAGE}   xpath://div[contains(text(),'No results found')]

# Screenshot Configuration
${CAPTURE.DIRECTORY}                ./Capture
${CAPTURE.TIMESTAMP_FORMAT}         %Y%m%d_%H%M%S

*** Keywords ***
# Login Page Actions
Enter Login Credentials
    [Documentation]    Enter username and password on login page
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Visible    ${LOGIN_PAGE.USERNAME_INPUT}
    Input Text    ${LOGIN_PAGE.USERNAME_INPUT}    ${username}
    Input Text    ${LOGIN_PAGE.PASSWORD_INPUT}    ${password}
    Click Element    ${LOGIN_PAGE.SUBMIT_BUTTON}

Verify Login Success
    [Documentation]    Verify successful login by checking navigation elements
    Wait Until Element Is Visible    ${NAVIGATION.GOTO_PARKING_BUTTON}    timeout=${CONFIG.BROWSER.TIMEOUT}

# Navigation Actions
Navigate To Parking Section
    [Documentation]    Navigate to the parking section after login
    Click Element      ${NAVIGATION.GOTO_PARKING_BUTTON}
    Wait Until Element Is Visible    ${SEARCH_PAGE.INPUT_FIELD}    timeout=${CONFIG.BROWSER.TIMEOUT}

# Search Page Actions
Enter Search Term
    [Documentation]    Enter search term in the search field
    [Arguments]    ${serial}    ${license}
    ${search_term}=    Set Variable If    "${serial}" != ""    ${serial}    ${license}
    Wait Until Element Is Visible    ${SEARCH_PAGE.INPUT_FIELD}
    Clear Element Text    ${SEARCH_PAGE.INPUT_FIELD}
    Input Text    ${SEARCH_PAGE.INPUT_FIELD}    ${search_term}
    IF	"${PARAMETERS.LICENSE}" != ""
        Click Element    ${SEARCH_PAGE.LICENSE_BUTTON}
    ELSE
        Click Element    ${SEARCH_PAGE.SERIAL_BUTTON}
    END
    Wait Until Element Is Visible    ${SEARCH_PAGE.SELECT_CAR_BUTTON}    timeout=${CONFIG.BROWSER.TIMEOUT}
    Click Element    ${SEARCH_PAGE.SELECT_CAR_BUTTON}

# E-Stamp Page Actions
Select Free E-Stamp Option
    [Documentation]    Select the free e-stamp option from dropdown
    Wait Until Element Is Visible    ${STAMP_PAGE.DROPDOWN}
    Click Element    ${STAMP_PAGE.FREE_OPTION}

Submit E-Stamp Application
    [Documentation]    Submit the e-stamp application
    Click Element    ${STAMP_PAGE.SUBMIT_BUTTON}

Confirm E-Stamp Application
    [Documentation]    Final confirmation of e-stamp application
    Wait Until Element Is Visible    ${SEARCH_PAGE.CONFIRM_BUTTON}
    Click Element    ${SEARCH_PAGE.CONFIRM_BUTTON}

Verify E-Stamp Success
    [Documentation]    Verify that e-stamp was applied successfully
    Wait Until Element Is Visible    ${STAMP_PAGE.SUCCESS_MESSAGE}    timeout=${CONFIG.BROWSER.TIMEOUT}

# Missing Keywords
Select Vehicle From Results
    [Documentation]    Select the first vehicle from search results
    Wait Until Element Is Visible    ${SEARCH_PAGE.SELECT_CAR_BUTTON}    timeout=${CONFIG.BROWSER.TIMEOUT}
    Click Element    ${SEARCH_PAGE.SELECT_CAR_BUTTON}

Confirm Vehicle Selection
    [Documentation]    Confirm the selected vehicle
    Wait Until Element Is Visible    ${SEARCH_PAGE.CONFIRM_BUTTON}    timeout=${CONFIG.BROWSER.TIMEOUT}
    Click Element    ${SEARCH_PAGE.CONFIRM_BUTTON}

# Error Handling and Logging Keywords
Initialize Test Suite
    [Documentation]    Initialize test suite with logging and environment setup
    Create Log Directory
    Detect Environment
    Log    Test suite initialized for environment: Docker=${ENV.docker}, Local=${ENV.local}

Create Log Directory
    [Documentation]    Create the log directory if it does not exist
    Create Directory    ${LOG.DIRECTORY}
    Create Directory    ${CAPTURE.DIRECTORY}
    Log    Log directory created at: ${LOG.DIRECTORY}
    Log    Capture directory created at: ${CAPTURE.DIRECTORY}

Handle Test Failure
    [Documentation]    Handle test failure by capturing screenshot and logging error details
    ${timestamp}=    Get Current Date    result_format=${LOG.TIMESTAMP_FORMAT}
    ${error_screenshot}=    Set Variable    ${CAPTURE.DIRECTORY}/error_${timestamp}.png
    Run Keyword And Ignore Error    Capture Page Screenshot    ${error_screenshot}
    Log    Test failed at ${timestamp}    level=ERROR
    Log    Error screenshot saved to: ${error_screenshot}    level=ERROR
    Cleanup Test Browser

Cleanup Test Suite
    [Documentation]    Clean up test suite and log completion status
    ${timestamp}=    Get Current Date    result_format=${LOG.TIMESTAMP_FORMAT}
    Log    Suite completed at: ${timestamp}
    Cleanup Test Browser

# Screenshot Actions
Capture Screen
    [Documentation]    Capture screenshot with optional custom filename
    [Arguments]    ${filename}=${EMPTY}    ${directory}=${CAPTURE.DIRECTORY}
    ${timestamp}=    Get Current Date    result_format=${CAPTURE.TIMESTAMP_FORMAT}
    IF    "${filename}" == "${EMPTY}"
        ${screenshot_name}=    Set Variable    screenshot_${timestamp}
    ELSE
        ${screenshot_name}=    Set Variable    ${filename}_${timestamp}
    END
    Create Directory    ${directory}
    ${screenshot_path}=    Set Variable    ${directory}/${screenshot_name}.png
    Capture Page Screenshot    ${screenshot_path}
    Log    Screenshot saved to: ${screenshot_path}

*** Test Cases ***
Stamp Car on THE 9 TOWER
    [Documentation]    Test case to stamp a car on THE 9 TOWER using SeleniumLibrary.
    Setup Test Browser
    Enter Login Credentials    ${CONFIG.USERNAME}    ${CONFIG.PASSWORD}
    Verify Login Success
    Navigate To Parking Section
    Enter Search Term    ${PARAMETERS.LICENSE}      ${PARAMETERS.SERIAL}
    Select Vehicle From Results
    Confirm Vehicle Selection
    Select Free E-Stamp Option
    Submit E-Stamp Application
    Confirm E-Stamp Application
    Verify E-Stamp Success
    Capture Screen
    Cleanup Test Browser