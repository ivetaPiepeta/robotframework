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

*** Test Cases ***
Open Browser And Check Statuses of hrefs on Desktop
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód na desktope.
    Run Test With Resolution    ${DESKTOP_WIDTH}    ${DESKTOP_HEIGHT}

*** Keywords ***

Run Test With Resolution
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
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
    Create Session  autobazar  ${Base_URL}  verify=False
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

Wait Until Page Is Fully Loaded Old
    ${ready_state}=  Execute JavaScript  return document.readyState
    Wait Until Keyword Succeeds  1 min  1 sec  Execute JavaScript  return document.readyState == 'complete'
    Log To Console  Načítavam stránku

Get All Links In Element
    [Arguments]  ${element_xpath}
    ${elements}=  Get WebElements  ${element_xpath}//a
    ${hrefs}=  Create List
    FOR  ${element}  IN  @{elements}
        ${href}=  Get Element Attribute  ${element}  href
        Append To List  ${hrefs}  ${href}
    END
    RETURN  ${hrefs}

Verify Status For All Links
    [Arguments]  @{hrefs}
    FOR  ${href}  IN  @{hrefs}
        ${response}=  GET On Session  autobazar  ${href}
        Log To Console  ${href} - Status Code: ${response.status_code}
        Should Be Equal As Numbers  ${response.status_code}  200  Status code of ${href} should be 200
    END

Verify Status For All Links No
    [Arguments]  @{hrefs}
    FOR  ${href}  IN  @{hrefs}
        ${full_url}=  Evaluate  '${href}'
        ${response}=  GET On Session  autobazar  ${full_url}
        Log To Console  ${full_url} - Status Code: ${response.status_code}
        Should Be Equal As Numbers  ${response.status_code}  200  Status code of ${full_url} should be 200
    END
    Log To Console  Overujem linky z menu.

Click And Verify Links On Page From Current Session
    [Arguments]  @{hrefs}
    ${MAIN_WINDOW}=  Get Window Handles  # Uložíme hlavné okno
    FOR  ${href}  IN  @{hrefs}
        ${full_url}=  Evaluate  '${href}'  # Získanie úplnej URL
        Log To Console  Klikám na link: ${full_url}

        # Klikneme na odkaz priamo a prejdeme na novú stránku
        Go To  ${full_url}
        Wait Until Page Is Fully Loaded Old
        Log To Console  Kontrolujem status kódy pre odkazy na stránke: ${full_url}

        # Získame všetky odkazy na stránke
        GetAllPageHrefs
        Remove Duplicates From List
        Log Total Links Found
        CheckHrefsStatus

        # Vrátime sa na pôvodnú stránku
        Go To  ${Base_URL}
        Wait Until Page Is Fully Loaded Old
    END
    Log To Console  Overujem celé podmenu.

Open Valid Links And Check Status
    [Arguments]  ${url}
    Log To Console  Otváram odkaz: ${url}
    Go To    ${url}
    Wait Until Page Is Fully Loaded
    FOR  ${link}  IN  @{elemements}
        ${href}=  Get Element Attribute  ${link}  href
        ${status}=  Run Keyword And Ignore Error  Check Single Href Status  ${href}
        Log To Console  ${status}
        ${status_code}=  Set Variable If  '${status[0]}' == 'PASS'  ${status[1]}  -1
        Log To Console  status kód linku ${href} je ${status_code}
        Run Keyword If  '${status_code}' == '200'  Log Valid Link  ${href}
        Run Keyword If  '${status_code}' != '200'  Log Broken Link  ${href}  ${status_code}
    END

Repeat All Pages
    [Arguments]  ${url}
    Log To Console  Otváram odkaz: ${url}
    FOR  ${url}  IN  @{Valid_Links}
        Open Valid Links And Check Status  ${url}
    END
