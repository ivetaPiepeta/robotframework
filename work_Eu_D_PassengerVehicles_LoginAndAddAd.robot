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
${ADD_AD_URL}        /pridat-inzerat/osobne-vozidla/zakladne-udaje
${ADD_AD_CLASS}      item
${ADD_AD_CLASS_WORK}
${ADD_AD_DIV_CLASS}  bg-icon
${XPATH_INPUT}  //input[@type='text' and @name='VIN' and @id='vindiv']

*** Test Cases ***
Login And Create A New Advertisiment
    [Documentation]  Tento test otvorí prehliadač, načíta stránku, zaloguje usera a pridá inzerát s fotografiou.
    Run Test With Resolution

*** Keywords ***
Run Test With Resolution
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
    Disable Insecure Request Warnings
    Create Session  autobazar  ${Work_URL}  verify=False
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${Work_URL}  chrome
    Maximize Browser Window
    #Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded
    Perform Login Desktop Work
    Add A New Advertisiment Desktop Work
    Add Ecv Work
    Check My Ečv Work
    #Choose A Model Prestige Work
    Basic Data Work
    Click Next Button Desktop Work
    Vehicle Equipment Work
    Click Next Button Desktop Work
    Name And Condition Of The Vehicle Work
    Click Next Button Desktop Work
    Price Part Work
    Click Next Button Desktop Work
    Upload An Image Work  ${image_path2}
    Click Button Add An Advertisement Desktop Work
    #tu dorob overenie v aktualnych inzeratoch, keď budú na nexte
    Sleep  ${SLEEP_TIME}
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist



GetAllPageHrefs
    [Documentation]  Získa všetky odkazy (a-href) na stránke.
    ${links}=  Get WebElements  //a[@href]
    FOR  ${link}  IN  @{links}
        ${href}=  Get Element Attribute  ${link}  href
        ${should_ignore}=  Should Ignore Href  ${href}
        Run Keyword If  '${should_ignore}' == 'False'  Append To List  ${All_links}  ${href}
    END

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

Choose A Model Prestige Work
    Wait Until Page Is Fully Loaded Ecv Part
    Wait Until Element Is Visible  //div[@id='selectTags']//span[@data-value='93510']
    Click Element Using JavaScript  //div[@id='selectTags']//span[@data-value='93510']
    Log To Console  "Clicked on 1.5 Blue dCi 115 Prestige 4x4"
    Sleep  ${TYPING_DELAY}
    Wait Until Element Is Visible  //div[@class='etax-bottom-bar']//a[contains(text(),'Vybrať a pokračovať')]  timeout=15
    Click Element Using JavaScript  //div[@class='etax-bottom-bar']//a[contains(text(),'Vybrať a pokračovať')]
    Click Next Button Desktop Work
    Sleep  ${SLEEP_TIME}

