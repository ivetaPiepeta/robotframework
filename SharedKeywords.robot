*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem

*** Variables ***
${Base_URL}  https://www.autobazar.eu/

*** Keywords ***
Disable Insecure Request Warnings
    Evaluate  exec("import urllib3; urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)")

Switch To Frame And Accept All
    Wait Until Page Contains Element  //iframe[@title='SP Consent Message']
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Unselect Frame

Wait Until Page Is Fully Loaded
    Wait Until Page Contains Element  //footer
    Wait Until Page Contains Element  //main
    Wait Until Page Contains Element  //nav
    ${ready_state}=  Execute JavaScript  return document.readyState
    Wait Until Keyword Succeeds  1 min  1 sec  Execute JavaScript  return document.readyState == 'complete'

Scroll Down To Load All Content
    ${height}=  Execute JavaScript  return document.body.scrollHeight
    WHILE  ${True}
        ${current_height}=  Execute JavaScript  return window.scrollY
        ${viewport_height}=  Execute JavaScript  return window.innerHeight
        Run Keyword If  ${current_height} + ${viewport_height} >= ${height}  Exit For Loop
        Execute JavaScript  window.scrollBy(0, window.innerHeight)
        Sleep  1s
    END

Clear List
    [Arguments]  @{list}
    [Documentation]  Vyprázdni daný zoznam.
    Set Variable  @{list}  @{EMPTY}
