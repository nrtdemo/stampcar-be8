*** Settings ***
Documentation     Test configuration and resource file for Robot Framework Docker tests
Library           SeleniumLibrary
Library           DateTime  
Library           OperatingSystem

*** Variables ***
# Environment Detection
&{ENV}            docker=${EMPTY}    local=${EMPTY}

# Browser Configuration for Different Environments  
&{BROWSER_CONFIG}    
...    docker_chrome_options=add_argument("--headless");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--window-size=1920,1080");add_argument("--disable-features=VizDisplayCompositor");add_argument("--disable-web-security");add_argument("--remote-debugging-port=9222")
...    local_chrome_options=add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--window-size=1920,1080");add_argument("--disable-features=VizDisplayCompositor");add_argument("--disable-web-security")
...    docker_chromium_binary=binary_location=/usr/bin/chromium

*** Keywords ***
Detect Environment
    [Documentation]    Detect if running in Docker or local environment
    ${docker_env}=    Get Environment Variable    ROBOT_FRAMEWORK_DOCKER    default=${EMPTY}
    ${is_docker}=    Evaluate    "${docker_env}" != "${EMPTY}"
    Set Suite Variable    ${ENV.docker}    ${is_docker}
    Set Suite Variable    ${ENV.local}    ${not is_docker}
    Log    Environment detected - Docker: ${ENV.docker}, Local: ${ENV.local}
    RETURN    ${is_docker}

Get Browser Options
    [Documentation]    Get appropriate browser options based on environment
    ${is_docker}=    Detect Environment
    ${arch}=    Get Environment Variable    TARGETARCH    default=amd64
    
    IF    ${ENV.docker}
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
    ${is_docker}=    Detect Environment
    ${browser}=    Set Variable If    ${ENV.docker}    headlesschrome    chrome
    Log    Browser name: ${browser}
    RETURN    ${browser}

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
