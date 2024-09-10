*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem
Resource  SharedKeywords.robot

*** Variables ***
@{All_links}
@{Broken_Links}
@{Ignored_Patterns}  mailto:  tel:  javascript:
${TOTAL_LINKS}  0
${REMAINING_LINKS}  0

*** Test Cases ***
Login And Click On Favorites on Desktop
    [Documentation]  Tento test otvorí prehliadač, načíta stránku, zaloguje usera a pridá inzerát do obľúbených na desktope/odoberie inzerát z obľúbených na desktope.
    Run Test With Resolution    ${DESKTOP_WIDTH}    ${DESKTOP_HEIGHT}

*** Keywords ***
Run Test With Resolution
    [Arguments]  ${width}  ${height}
    Disable Insecure Request Warnings
    Create Session  autobazar  ${Base_URL}  verify=False
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${Base_URL}  chrome
    Set Window Size  ${width}  ${height}
    Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded
    Perform Login Desktop
    Click To Favorites
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist

Click To Favorites
    Go To  ${Base_URL}
    Wait Until Page Is Fully Loaded
    Scroll Down To Load Content 1 time
    Select Option From Dropdown By Index    //select[@name='userType']    2
    Sleep  ${SLEEP_TIME}
    Wait Until Page Is Fully Loaded
    Sleep  1s
    Scroll Down To Load Content 1 time
    Wait Until Element Is Visible  //button[.//picture/img[@alt='parking'][1]]
    Click Element Using JavaScript  //button[.//picture/img[@alt='parking'][1]]
