*** Settings ***
Documentation     Simple example using SeleniumLibrary.
Library           SeleniumLibrary

*** Variables ***
${LOGIN URL}			http://the9estamp.grandcanalland.com/web-estamp/login
${BROWSER}				headlesschrome
${username}				BE8
${password}				1234
${license}				0000
${serial}				0000
${input_username}		//*[@id="MainContent_MainLogin_UserName"]
${input_password}		//*[@id="MainContent_MainLogin_Password"]
${button_login}			//*[@id="MainContent_MainLogin_LoginButton"]
${goto_button}	  		//*[@id="ctl01"]/div[4]/div[2]/div[1]/p[2]/a
${input_search}			//*[@id="MainContent_keywordTextBox"]
${button_license}		//*[@id="MainContent_searchLicensneButton"]
${button_serail}		//*[@id="MainContent_searchSerialButton"]
${button_select}		//*[@id="MainContent_ParkingDetail_LinkButton1_0"]
${button_ok}			//*[@id="MainContent_doneButton1"]
${select_estamp_field}	//*[@id="MainContent_couponDropDown"]
${select_estamp_click}	//*[@id="MainContent_couponDropDown"]/option[2]
${button_submit}		//*[@id="MainContent_submitButton"]

*** Keywords ***
LOGIN THENINETOWER
	Open Browser	${LOGIN URL}	${BROWSER}
INPUT USERNAME AND PASSWORD
	Input Text	${input_username}	${username}
	Input Text	${input_password}	${password}	
	Click ELement	${button_login}
	Wait Until Element Is Visible	${goto_button}
	Click ELement	${goto_button}
SEARCH CAR
	Input Text	${input_search}	${license}
	Click ELement	${button_license}
	Click ELement	${button_select}
	Click ELement	${button_ok}
STAMP FREE
	Wait Until Element Is Visible	${select_estamp_field}
	Click ELement	${select_estamp_click}
	Click ELement	${button_submit}
	Click ELement	${button_ok}
	Input Text	${input_search}	${license}
	Click ELement	${button_license}
	Capture Page Screenshot	./${license}/the9tower-stamp-{index}.png

*** Test Cases ***
Valdiate The9-StampCar 
	LOGIN THENINETOWER
	INPUT USERNAME AND PASSWORD
	SEARCH CAR
	STAMP FREE