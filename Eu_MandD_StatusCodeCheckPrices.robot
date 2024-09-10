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
Open Browser And Check Statuses of hrefs on Desktop
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód na desktope.
    Run Test With Resolution    ${DESKTOP_WIDTH}    ${DESKTOP_HEIGHT}

Open Browser And Check Statuses of hrefs on Mobile
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód na mobile.
    Run Test With Resolution Mobile    ${MOBILE_WIDTH}    ${MOBILE_HEIGHT}

*** Keywords ***
Run Test With Resolution
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
    [Arguments]  ${width}  ${height}
    Disable Insecure Request Warnings
    Create Session  autobazar  ${URL_prices}  verify=False
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${URL_prices}  chrome
    Set Window Size  ${width}  ${height}
    Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded Old
    Log To Console  Načítavam stránku pre rozlíšenie desktop.
    Scroll Down To Load All Content
    GetAllPageHrefs
    Remove Duplicates From List
    Log Total Links Found
    CheckHrefsStatus
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist

Run Test With Resolution Mobile
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
    [Arguments]  ${width}  ${height}
    Disable Insecure Request Warnings
    Create Session  autobazar  ${URL_prices}  verify=False
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${URL_prices}  chrome
    Set Window Size  ${width}  ${height}
    Wait Until Page Is Fully Loaded Old
    Sleep  ${SLEEP_TIME}
    Switch To Frame And Accept All
    Reload Page
    Log To Console  Načítavam stránku pre rozlíšenie mobil.
    Scroll Down To Load Content 2 times
    Wait Until Page Is Fully Loaded Old
    GetAllPageHrefs
    Remove Duplicates From List
    Log Total Links Found
    CheckHrefsStatus
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist
