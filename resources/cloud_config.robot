*** Settings ***
Documentation     Production configuration for Robot Framework cloud deployment
Library           SeleniumLibrary
Library           DateTime  
Library           OperatingSystem
Library           Process

*** Variables ***
# Cloud Environment Configuration
${CLOUD_HEADLESS}    true
${CLOUD_TIMEOUT}     60s
${SCREENSHOT_ON_FAILURE}    true

# Browser Configuration for Production/Cloud
&{CLOUD_BROWSER_CONFIG}    
...    chrome_options=add_argument("--headless");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--window-size=1920,1080");add_argument("--disable-features=VizDisplayCompositor");add_argument("--disable-web-security");add_argument("--remote-debugging-port=9222");add_argument("--disable-background-timer-throttling");add_argument("--disable-backgrounding-occluded-windows");add_argument("--disable-renderer-backgrounding")

*** Keywords ***
Setup Cloud Browser
    [Documentation]    Configure browser for cloud environment (Render.com, etc.)
    [Arguments]    ${browser}=chrome
    
    ${headless_mode}=    Get Environment Variable    ROBOT_FRAMEWORK_HEADLESS    default=true
    ${is_cloud}=    Evaluate    "${headless_mode}".lower() == "true"
    
    IF    ${is_cloud}
        Log    Setting up browser for cloud environment (headless mode)
        ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
        Call Method    ${chrome_options}    add_argument    --headless=new
        Call Method    ${chrome_options}    add_argument    --no-sandbox
        Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
        Call Method    ${chrome_options}    add_argument    --disable-gpu
        Call Method    ${chrome_options}    add_argument    --window-size=1920,1080
        Call Method    ${chrome_options}    add_argument    --disable-features=VizDisplayCompositor
        Call Method    ${chrome_options}    add_argument    --disable-web-security
        Call Method    ${chrome_options}    add_argument    --remote-debugging-port=9222
        Call Method    ${chrome_options}    add_argument    --disable-background-timer-throttling
        Call Method    ${chrome_options}    add_argument    --disable-backgrounding-occluded-windows
        Call Method    ${chrome_options}    add_argument    --disable-renderer-backgrounding
        Call Method    ${chrome_options}    add_argument    --disable-extensions
        Call Method    ${chrome_options}    add_argument    --disable-plugins
        Call Method    ${chrome_options}    add_argument    --disable-images
        
        Create WebDriver    Chrome    chrome_options=${chrome_options}
        Set Window Size    1920    1080
    ELSE
        Log    Setting up browser for local environment
        Open Browser    about:blank    ${browser}
        Maximize Browser Window
    END
    
    Set Selenium Timeout    ${CLOUD_TIMEOUT}
    Set Selenium Implicit Wait    10s

Capture Screenshot On Failure
    [Documentation]    Capture screenshot when test fails in cloud environment
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${screenshot_name}=    Set Variable    error_${timestamp}.png
    ${screenshot_path}=    Set Variable    ${OUTPUTDIR}/Capture/${screenshot_name}
    
    Run Keyword If Test Failed    Capture Page Screenshot    ${screenshot_path}
    Run Keyword If Test Failed    Log    Screenshot saved: ${screenshot_path}

Log Environment Info
    [Documentation]    Log environment information for debugging
    ${python_version}=    Evaluate    sys.version    sys
    ${selenium_version}=    Evaluate    selenium.__version__    selenium
    ${current_dir}=    Get Location
    
    Log    Python Version: ${python_version}
    Log    Selenium Version: ${selenium_version}
    Log    Current Directory: ${current_dir}
    Log    Output Directory: ${OUTPUTDIR}
    
    ${env_vars}=    Get Environment Variables
    FOR    ${key}    IN    @{env_vars.keys()}
        ${value}=    Get From Dictionary    ${env_vars}    ${key}
        Continue For Loop If    'PASSWORD' in '${key}' or 'SECRET' in '${key}' or 'TOKEN' in '${key}'
        Log    ${key}: ${value}
    END
