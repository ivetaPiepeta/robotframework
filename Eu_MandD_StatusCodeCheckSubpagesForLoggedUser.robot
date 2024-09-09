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

*** Keywords ***
Run Test With Resolution
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kódy pre všetky dostupné url v celom podmenu - prihlásený užívateľ.
    [Arguments]  ${width}  ${height}
    Log To Console  Starting test case with resolution  ${width}  ${height}
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
    Scroll Down To Load All Content
    ${links_xpath}=  Set Variable  //div[contains(@class, 'mb-2 hidden h-[44px] w-full items-center justify-evenly rounded-[8px] bg-[#002973] text-[14px] font-medium lg:flex')]
    ${hrefs}=  Get All Links In Element  ${links_xpath}
    Verify Status For All Links  @{hrefs}
    # Klikanie na jednotlivé odkazy a overovanie ďalších odkazov na týchto stránkach
    Click And Verify Links On Page From Current Session  @{hrefs}
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist

