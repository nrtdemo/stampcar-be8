*** Settings ***
Documentation     Test configuration and resource file for Robot Framework Docker tests
Library           SeleniumLibrary
Library           DateTime  
Library           OperatingSystem
Library           Process

*** Variables ***
# Environment Detection
&{ENV}            docker=${EMPTY}    local=${EMPTY}    selenium_grid=${EMPTY}

# Selenium Grid Configuration
${SELENIUM_HUB_URL}    http://selenium-chrome:4444
${SELENIUM_TIMEOUT}    30s

# Browser Configuration for Different Environments  
&{BROWSER_CONFIG}    
...    docker_chrome_options=add_argument("--headless");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--window-size=1920,1080");add_argument("--disable-features=VizDisplayCompositor");add_argument("--disable-web-security");add_argument("--remote-debugging-port=9222")
...    local_chrome_options=add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--window-size=1920,1080");add_argument("--disable-features=VizDisplayCompositor");add_argument("--disable-web-security")
...    docker_chromium_binary=binary_location=/usr/bin/chromium
...    selenium_grid_chrome_options=add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--window-size=1920,1080");add_argument("--disable-features=VizDisplayCompositor");add_argument("--disable-web-security")

*** Keywords ***
Detect Environment
    [Documentation]    Detect if running in Docker, local, or Selenium Grid environment
    ${docker_env}=    Get Environment Variable    ROBOT_FRAMEWORK_DOCKER    default=${EMPTY}
    ${selenium_hub_url}=    Get Environment Variable    SELENIUM_HUB_URL    default=${EMPTY}
    
    ${is_docker}=    Evaluate    "${docker_env}" != "${EMPTY}"
    ${is_selenium_grid}=    Evaluate    "${selenium_hub_url}" != "${EMPTY}"
    ${is_local}=    Evaluate    not ${is_docker} and not ${is_selenium_grid}
    
    Set Suite Variable    ${ENV.docker}    ${is_docker}
    Set Suite Variable    ${ENV.selenium_grid}    ${is_selenium_grid}
    Set Suite Variable    ${ENV.local}    ${is_local}
    
    Log    Environment detected - Docker: ${ENV.docker}, Selenium Grid: ${ENV.selenium_grid}, Local: ${ENV.local}
    
    IF    ${ENV.selenium_grid}
        Set Suite Variable    ${SELENIUM_HUB_URL}    ${selenium_hub_url}
        Log    Using Selenium Grid at: ${SELENIUM_HUB_URL}
    END
    
    RETURN    ${is_selenium_grid}

Get Browser Options
    [Documentation]    Get appropriate browser options based on environment
    ${is_selenium_grid}=    Detect Environment
    ${arch}=    Get Environment Variable    TARGETARCH    default=amd64
    
    IF    ${ENV.selenium_grid}
        ${options}=    Set Variable    ${BROWSER_CONFIG.selenium_grid_chrome_options}
    ELSE IF    ${ENV.docker}
        ${options}=    Set Variable    ${BROWSER_CONFIG.docker_chrome_options}
        IF    "${arch}" == "arm64"
            ${options}=    Set Variable    ${options};${BROWSER_CONFIG.docker_chromium_binary}
        END
    ELSE
        ${options}=    Set Variable    ${BROWSER_CONFIG.local_chrome_options}
    END
    
    Log    Browser options: ${options}
    RETURN    ${options}

Get Browser Name
    [Documentation]    Get appropriate browser name based on environment
    ${is_selenium_grid}=    Detect Environment
    
    IF    ${ENV.selenium_grid}
        ${browser}=    Set Variable    chrome
    ELSE IF    ${ENV.docker}
        ${browser}=    Set Variable    headlesschrome
    ELSE
        ${browser}=    Set Variable    chrome
    END
    
    Log    Browser name: ${browser}
    RETURN    ${browser}

Get Remote URL
    [Documentation]    Get remote WebDriver URL if using Selenium Grid
    ${is_selenium_grid}=    Detect Environment
    
    IF    ${ENV.selenium_grid}
        RETURN    ${SELENIUM_HUB_URL}
    ELSE
        RETURN    ${EMPTY}
    END

Setup Test Browser
    [Documentation]    Setup browser with appropriate configuration based on environment
    [Arguments]    ${url}    ${alias}=None
    
    ${browser_name}=    Get Browser Name
    ${browser_options}=    Get Browser Options
    ${remote_url}=    Get Remote URL
    
    IF    "${remote_url}" != "${EMPTY}"
        # Use Selenium Grid
        Open Browser    ${url}    ${browser_name}    
        ...    remote_url=${remote_url}    options=${browser_options}    alias=${alias}
        Log    Browser opened via Selenium Grid at: ${remote_url}
    ELSE
        # Use local browser
        Open Browser    ${url}    ${browser_name}    options=${browser_options}    alias=${alias}
        Log    Local browser opened: ${browser_name}
    END
    
    # Common browser setup
    Maximize Browser Window
    Set Selenium Implicit Wait    10s
    
Wait For Selenium Grid
    [Documentation]    Wait for Selenium Grid to be ready
    IF    ${ENV.selenium_grid}
        Log    Waiting for Selenium Grid to be ready...
        Wait Until Keyword Succeeds    60s    5s    Check Selenium Grid Status
    END

Check Selenium Grid Status
    [Documentation]    Check if Selenium Grid is responding
    ${response}=    Run Process    curl    -f    ${SELENIUM_HUB_URL}/status
    Should Be Equal As Integers    ${response.rc}    0

Setup Test Browser
    [Documentation]    Universal browser setup for all environments
    ${browser_name}=    Get Browser Name
    ${browser_options}=    Get Browser Options
    ${url}=    Set Variable    http://the9estamp.grandcanalland.com/web-estamp/login
    
    Log    Opening browser: ${browser_name} with options: ${browser_options}
    Open Browser    ${url}    ${browser_name}    options=${browser_options}
    Set Window Size    1920    1080
    
    # Additional setup for Docker environment
    IF    ${ENV.docker}
        Set Selenium Timeout    10s
        Set Selenium Implicit Wait    5s
    END

Cleanup Test Browser
    [Documentation]    Clean browser session and close all browsers
    Run Keyword And Ignore Error    Close Browser
    Run Keyword And Ignore Error    Close All Browsers
