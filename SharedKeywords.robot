*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem

*** Variables ***
${Base_URL}  https://www.autobazar.eu/
${URL_NA}  https://www.autobazar.eu/vysledky-nove-auta/
${URL_dovoz}  https://www.autobazar.eu/vysledky-na-dovoz/

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

Scroll Down To Load Content 1 time
    Execute JavaScript    window.scrollBy(0, window.innerHeight)
    Sleep    1s


Scroll Down To Load Content 2 times
    FOR    ${i}    IN RANGE    2
        Execute JavaScript    window.scrollBy(0, window.innerHeight)
        Sleep    1s
    END

Click Element Using JavaScript
    [Arguments]  ${xpath}
    Execute JavaScript  document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Sleep  1s

Select Option From Dropdown By Index
    [Arguments]    ${dropdown_locator}    ${index}
    Select From List By Index    ${dropdown_locator}    ${index}
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]

Select Option From Dropdown By Value
    [Arguments]    ${dropdown_locator}    ${value}
    Select From List By Value    ${dropdown_locator}    ${value}
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]