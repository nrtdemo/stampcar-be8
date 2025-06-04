*** Settings ***
Documentation     Stamp Car on THE 9 TOWER using SeleniumLibrary.
Library           SeleniumLibrary
Library           DateTime
Library           OperatingSystem

*** Variables ***
# Browser Configuration
${CONFIG.BROWSER.URL}           http://the9estamp.grandcanalland.com/web-estamp/login
${CONFIG.BROWSER.DEFAULT}       chrome
${CONFIG.BROWSER.HEADLESS}      headlesschrome
${CONFIG.BROWSER.OPTIONS}       
${CONFIG.BROWSER.TIMEOUT}       3s

# Test Data
${CONFIG.USERNAME}              BE8
${CONFIG.PASSWORD}              1234
${PARAMETERS.LICENSE}           ${EMPTY}
${PARAMETERS.SERIAL}            ${EMPTY}

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
    [Arguments]    ${search_term}
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
    

Verify E-Stamp Success
    [Documentation]    Verify that e-stamp was applied successfully
    Wait Until Element Is Visible    ${STAMP_PAGE.SUCCESS_MESSAGE}    timeout=${CONFIG.BROWSER.TIMEOUT}

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
    Open Browser    ${CONFIG.BROWSER.URL}    ${CONFIG.BROWSER.DEFAULT}    options=${CONFIG.BROWSER.OPTIONS}
    Maximize Browser Window
    Enter Login Credentials    ${CONFIG.USERNAME}    ${CONFIG.PASSWORD}
    Verify Login Success
    Navigate To Parking Section
    Enter Search Term    ${PARAMETERS.KEYWORD}
    Select Vehicle From Results
    Confirm Vehicle Selection
    Select Free E-Stamp Option
    Submit E-Stamp Application
    Confirm E-Stamp Application
    Verify E-Stamp Success
    Capture Screen
    Close Browser