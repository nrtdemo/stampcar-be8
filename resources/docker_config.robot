*** Settings ***
Documentation     Docker-specific configuration for Robot Framework tests
Library           SeleniumLibrary

*** Variables ***
# Docker Chrome Configuration
${DOCKER.CHROME.OPTIONS}    --headless --no-sandbox --disable-dev-shm-usage --disable-gpu --window-size=1920x1080

*** Keywords ***
Open Browser For Docker
    [Documentation]    Open browser with Docker-specific options
    [Arguments]    ${url}    ${browser}=chrome
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --headless
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --disable-gpu
    Call Method    ${options}    add_argument    --disable-web-security
    Call Method    ${options}    add_argument    --disable-extensions
    Call Method    ${options}    add_argument    --disable-background-timer-throttling
    Call Method    ${options}    add_argument    --disable-backgrounding-occluded-windows
    Call Method    ${options}    add_argument    --disable-renderer-backgrounding
    Call Method    ${options}    add_argument    --disable-ipc-flooding-protection
    Create Webdriver    Chrome    options=${options}
    Go To    ${url}
    Set Window Size    1920    1080