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
${PREMIUM_DIV_CLASS}  mt-8 flex min-h-[122px] w-full justify-between gap-0.5 md:min-h-[192px] flex-col sm:flex-row
${PREMIUM_SPAN_TEXT}  PREMIUM
${FIRST_DETAIL}


*** Test Cases ***
Check Detail of Advertisiment On Desktop
    [Documentation]  Tento test otvorí prehliadač, overí statusy v detaile inzerátu.
    Run Test With Resolution    ${DESKTOP_WIDTH}    ${DESKTOP_HEIGHT}


*** Keywords ***

Disable Insecure Request Warnings
    [Documentation]  Potlačí upozornenia na neoverené HTTPS požiadavky.
    Evaluate  exec("import urllib3; urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)")

GetAllPageHrefs
    [Documentation]  Získa všetky odkazy (a-href) na stránke.
    ${links}=  Get WebElements  //a[@href]
    FOR  ${link}  IN  @{links}
        ${href}=  Get Element Attribute  ${link}  href
        ${should_ignore}=  Should Ignore Href  ${href}
        Run Keyword If  '${should_ignore}' == 'False'  Append To List  ${All_links}  ${href}
    END

Remove Duplicates From List
    [Documentation]  Odstráni duplicity zo zoznamu odkazov.
    ${unique_links}=  Remove Duplicates  ${All_links}
    Set Global Variable  ${All_links}  ${unique_links}

Log Total Links Found
    [Documentation]  Zaloguje celkový počet nájdených odkazov.
    ${total_links}=  Get Length  ${All_links}
    Set Global Variable  ${TOTAL_LINKS}  ${total_links}
    Set Global Variable  ${REMAINING_LINKS}  ${total_links}

CheckHrefsStatus
    FOR  ${page}  IN  @{All_links}
        ${status}=  Run Keyword And Ignore Error  Check Single Href Status  ${page}
        ${status_code}=  Set Variable If  '${status[0]}' == 'PASS'  ${status[1]}  -1
        Run Keyword If  '${status_code}' != '200'  Log Broken Link  ${page}  ${status_code}
        ${REMAINING_LINKS}=  Evaluate  ${REMAINING_LINKS} - 1
        Log To Console  ${REMAINING_LINKS}/${TOTAL_LINKS} ${page}  no new line=True
    END
    Set Variable  @{All_links}  @{EMPTY}

Check Single Href Status
    [Arguments]  ${page}
    Disable Insecure Request Warnings
    ${response}=  GET On Session  autobazar  ${page}
    Log  HTTP status kód pre ${page} je: ${response.status_code}
    RETURN  ${response.status_code}

Log Broken Link
    [Arguments]  ${url}  ${status_code}
    Log  Broken link found: ${url} with status code: ${status_code}
    Append To List  ${Broken_Links}  ${url}

Log Valid Link
    [Arguments]  ${url}
    Log  Valid link found: ${url} with status code: ${status_code}
    Append To List  ${Valid_Links}  ${url}

Fail Test If Broken Links Exist
    Run Keyword If  ${Broken_Links}  Fail  Broken links found: ${Broken_Links}

Should Ignore Href
    [Arguments]  ${href}
    ${result}=  Run Keyword And Return Status  Should Contain Any  ${href}  @{Ignored_Patterns}
    RETURN  ${result}

Run Test With Resolution
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
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
    Scroll Down To Load All Content

    Find First Ad

    GetAllPageHrefs
    Remove Duplicates From List
    Log Total Links Found
    CheckHrefsStatus
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist

Find First Ad
    Go To  ${Base_URL}
    Wait Until Page Is Fully Loaded
    Scroll Down To Load Content 1 time
    Select Option From Dropdown By Index    //select[@name='userType']    2
    Sleep  ${SLEEP_TIME}
    Wait Until Page Is Fully Loaded
    Sleep  1s
    Scroll Down To Load Content 1 time
    Wait Until Element Is Visible  //div[contains(@class, '${PREMIUM_DIV_CLASS}') and .//span[text()='${PREMIUM_SPAN_TEXT}']]
    Click Element Using JavaScript  css=div.${PREMIUM_DIV_CLASS} a[target="_blank"]
    Sleep  ${SLEEP_TIME}