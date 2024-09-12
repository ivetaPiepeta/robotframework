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
${DESKTOP_WIDTH}  1920
${DESKTOP_HEIGHT}  1080
${MOBILE_WIDTH}  390
${MOBILE_HEIGHT}  844
${LINKS_XPATH}  //div[@class='mb-2 hidden h-[44px] w-full items-center justify-evenly rounded-[8px] bg-[#002973] text-[14px] font-medium lg:flex']/a


*** Test Cases ***
Open Browser And Check Statuses of hrefs on Desktop
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód na desktope.
    Run Test With Resolution    ${DESKTOP_WIDTH}    ${DESKTOP_HEIGHT}

*** Keywords ***
Run Test With Resolution
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
    [Arguments]  ${width}  ${height}
    Disable Insecure Request Warnings
    Create Session  autobazar  ${URL_myfavorite}  verify=False
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${URL_myfavorite}  chrome
    Set Window Size  ${width}  ${height}
    Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded
    Perform Login Desktop
    Scroll Down To Load All Content
    GetAllPageHrefs
    Remove Duplicates From List
    Log Total Links Found
    CheckHrefsStatus
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist