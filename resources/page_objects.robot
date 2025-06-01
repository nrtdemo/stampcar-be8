*** Settings ***
Documentation     Page Object Model for THE 9 TOWER e-stamp system
Library           SeleniumLibrary

*** Variables ***
# Login Page Elements
${LOGIN_PAGE.USERNAME_INPUT}        id:MainContent_MainLogin_UserName
${LOGIN_PAGE.PASSWORD_INPUT}        id:MainContent_MainLogin_Password
${LOGIN_PAGE.SUBMIT_BUTTON}         id:MainContent_MainLogin_LoginButton
${LOGIN_PAGE.SUCCESS_MESSAGE}       xpath://div[contains(@class,'success')]

# Navigation Elements
${NAVIGATION.GOTO_PARKING_BUTTON}   xpath://a[contains(@href,'parking') or contains(text(),'parking')]

# Search Page Elements
${SEARCH_PAGE.INPUT_FIELD}          id:MainContent_keywordTextBox
${SEARCH_PAGE.LICENSE_BUTTON}       id:MainContent_searchLicensneButton
${SEARCH_PAGE.SERIAL_BUTTON}        id:MainContent_searchSerialButton
${SEARCH_PAGE.SELECT_CAR_BUTTON}    id:MainContent_ParkingDetail_LinkButton1_0
${SEARCH_PAGE.CONFIRM_BUTTON}       id:MainContent_doneButton1
${SEARCH_PAGE.NO_RESULTS_MESSAGE}   xpath://div[contains(text(),'No results found')]

# E-Stamp Page Elements
${STAMP_PAGE.DROPDOWN}              id:MainContent_couponDropDown
${STAMP_PAGE.FREE_OPTION}           xpath://select[@id='MainContent_couponDropDown']/option[2]
${STAMP_PAGE.SUBMIT_BUTTON}         id:MainContent_submitButton
${STAMP_PAGE.SUCCESS_MESSAGE}       xpath://div[contains(@class,'success')]

*** Keywords ***
# Login Page Actions
Enter Login Credentials
    [Documentation]    Enter username and password on login page
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Visible    ${LOGIN_PAGE.USERNAME_INPUT}
    Input Text    ${LOGIN_PAGE.USERNAME_INPUT}    ${username}
    Input Text    ${LOGIN_PAGE.PASSWORD_INPUT}    ${password}

Submit Login Form
    [Documentation]    Submit the login form
    Click Element    ${LOGIN_PAGE.SUBMIT_BUTTON}

Verify Login Success
    [Documentation]    Verify successful login by checking navigation elements
    Wait Until Element Is Visible    ${NAVIGATION.GOTO_PARKING_BUTTON}    timeout=30s

# Navigation Actions
Navigate To Parking Section
    [Documentation]    Navigate to the parking section after login
    Click Element    ${NAVIGATION.GOTO_PARKING_BUTTON}
    Wait Until Element Is Visible    ${SEARCH_PAGE.INPUT_FIELD}    timeout=30s

# Search Page Actions
Enter Search Term
    [Documentation]    Enter search term in the search field
    [Arguments]    ${search_term}
    Wait Until Element Is Visible    ${SEARCH_PAGE.INPUT_FIELD}
    Clear Element Text    ${SEARCH_PAGE.INPUT_FIELD}
    Input Text    ${SEARCH_PAGE.INPUT_FIELD}    ${search_term}

Search By License Plate
    [Documentation]    Perform search by license plate
    Click Element    ${SEARCH_PAGE.LICENSE_BUTTON}
    Wait Until Element Is Visible    ${SEARCH_PAGE.SELECT_CAR_BUTTON}    timeout=30s

Search By Serial Number
    [Documentation]    Perform search by serial number
    Click Element    ${SEARCH_PAGE.SERIAL_BUTTON}
    Wait Until Element Is Visible    ${SEARCH_PAGE.SELECT_CAR_BUTTON}    timeout=30s

Select Vehicle From Results
    [Documentation]    Select the vehicle from search results
    Click Element    ${SEARCH_PAGE.SELECT_CAR_BUTTON}

Confirm Vehicle Selection
    [Documentation]    Confirm the selected vehicle
    Wait Until Element Is Visible    ${SEARCH_PAGE.CONFIRM_BUTTON}
    Click Element    ${SEARCH_PAGE.CONFIRM_BUTTON}

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
    Wait Until Element Is Visible    ${STAMP_PAGE.SUCCESS_MESSAGE}    timeout=30s
