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
${DESKTOP_WIDTH}  1600
${DESKTOP_HEIGHT}  1080
${MOBILE_WIDTH}  390
${MOBILE_HEIGHT}  844

*** Test Cases ***
Login And Click On Favorites on Desktop
    [Documentation]  Tento test otvorí prehliadač, načíta stránku, zaloguje usera a pridá inzerát do obľúbených na desktope.
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
    Perform Login
    Click To Favorites

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

Perform Login
    Wait Until Element Is Visible  //button[.//picture/img[@alt='Prihlásiť'] and .//span[text()='Prihlásiť']]
    Click Element Using JavaScript  //button[.//picture/img[@alt='Prihlásiť'] and .//span[text()='Prihlásiť']]
    Input Text  //input[@type='text' and @placeholder='Meno, email alebo tel. číslo']  ${USERNAME}
    Input Text  //input[@type='password' and @placeholder='Heslo']  ${PASSWORD}
    Click Element Using JavaScript  //button[contains(., 'Prihlásiť sa')]
    Sleep  1s

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

Click Element Using JavaScript 3
    [Arguments]  ${xpath}
    Execute JavaScript  document.querySelector("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Sleep  1s

Click Element Using XPath
    [Arguments]  ${xpath}
    Execute JavaScript
        var element = document.evaluate(arguments[0], document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
        if (element) {
            element.click();
        } else {
            throw new Error("Element not found with XPath: " + arguments[0]);
        }
    Sleep  1s

Click Element Using JavaScript 2
    [Arguments]  ${locator}
    ${is_xpath}=  Should Start With  ${locator}  //
    Run Keyword If  '${is_xpath}' == 'True'
        Execute JavaScript  var element = document.evaluate("${locator}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; element.click();
        ELSE  Execute JavaScript  document.querySelector("${locator}").click();
    Sleep  1s

Should Start With
    [Arguments]  ${locator}  ${prefix}
    ${result}=  Evaluate  ${{locator.startswith(prefix)}}
    RETURN  ${result}


Is Locator XPath
    [Arguments]  ${locator}
    ${result} =  Should Start With  ${locator}  //
    RETURN  ${result}