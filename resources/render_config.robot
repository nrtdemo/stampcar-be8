*** Settings ***
Documentation     Docker configuration for Robot Framework tests in Render environment.
Library           SeleniumLibrary

*** Variables ***
# Render-specific Chrome options for headless operation
${RENDER_CHROME_OPTIONS}    add_argument("--headless");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--disable-web-security");add_argument("--disable-features=VizDisplayCompositor");add_argument("--disable-background-timer-throttling");add_argument("--disable-backgrounding-occluded-windows");add_argument("--disable-renderer-backgrounding");add_argument("--window-size=1920,1080");add_argument("--force-device-scale-factor=1");add_argument("--disable-extensions");add_argument("--disable-plugins");add_argument("--disable-images");add_argument("--disable-javascript");add_argument("--virtual-time-budget=5000")

*** Keywords ***
Open Browser For Render
    [Documentation]    Open browser with Render-specific configuration
    [Arguments]    ${url}    ${browser}=chrome
    
    # Set Chrome options for Render environment
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --headless
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --disable-gpu
    Call Method    ${options}    add_argument    --disable-web-security
    Call Method    ${options}    add_argument    --disable-features=VizDisplayCompositor
    Call Method    ${options}    add_argument    --window-size=1920,1080
    Call Method    ${options}    add_argument    --disable-extensions
    Call Method    ${options}    add_argument    --disable-plugins
    
    # Open browser with custom options
    Open Browser    ${url}    ${browser}    options=${options}
    Set Window Size    1920    1080

Setup Chrome Driver For Render
    [Documentation]    Setup Chrome driver for Render environment
    
    # Auto-install ChromeDriver if needed
    ${driver_path}=    Evaluate    
    ...    __import__('chromedriver_autoinstaller').install()
    ...    chromedriver_autoinstaller
    
    Set Environment Variable    CHROMEDRIVER_PATH    ${driver_path}
    
    Log    ChromeDriver installed at: ${driver_path}
