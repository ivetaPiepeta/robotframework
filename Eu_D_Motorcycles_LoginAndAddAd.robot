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
${ADD_AD_URL}        /pridat-inzerat/osobne-vozidla/zakladne-udaje
${ADD_AD_URL_MOTOR}        /pridat-inzerat/motocykle/zakladne-udaje
${ADD_AD_CLASS}      item
${ADD_AD_DIV_CLASS}  bg-icon
${XPATH_INPUT}  //input[@type='text' and @name='VIN' and @id='vindiv']
${CAR_BRAND_SELECTOR}    //select[@name='CarBrandID']
${CAR_BRAND_OPTION}   Adamoto
${UPLOAD_BUTTON}  //button[@type='button' and contains(@class, 'form-action-link') and contains(@class, 'data-button-upload-photos') and contains(@class, 'dz-clickable') and text()='nahrajte']
${UPLOAD_INPUT_XPATH}  //input[@type='file' and @name='fotoDacia']
${CHECKBOX_XPATH}  //input[@type='checkbox' and @name='acceptterms' and @id='contact-advertising-conditions']
${ADD_AD_LINK}  //a[@href='/pridat-inzerat/motocykle/zakladne-udaje' and contains(@class, 'item')]



*** Test Cases ***
Login And Create A New Advertisiment
    [Documentation]  Tento test otvorí prehliadač, načíta stránku, zaloguje usera a pridá inzerát s fotografiou.
    Run Test With Resolution

*** Keywords ***

Run Test With Resolution
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
    Disable Insecure Request Warnings
    Create Session  autobazar  ${Base_URL}  verify=False
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${Base_URL}  chrome
    Maximize Browser Window
    Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded
    Perform Login Desktop
    Add With No Ecv Desktop
    Choose A Model Starfinger
    Price Part Motorcycle
    Upload An Image
    Click Next Button Desktop
    Confirm Checkbox Add Ad
    Check Adding Of Adv

    Sleep  ${SLEEP_TIME}
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

Add A New Advertisiment Desktop
    Wait Until Page Is Fully Loaded
    Wait Until Element Is Visible  //a[@href='https://www.autobazar.eu/sk/pridat-inzerat' and contains(., 'Pridať inzerát')]
    Click Element Using JavaScript  //a[@href='https://www.autobazar.eu/sk/pridat-inzerat' and contains(., 'Pridať inzerát')]
    Log To Console  Pridávam inzerát - výber kategórie
    Wait Until Element Is Visible  //a[@href='${ADD_AD_URL}' and contains(@class, '${ADD_AD_CLASS}')][1]
    Sleep  1s
    Click Element Using JavaScript  //a[@href='${ADD_AD_URL}' and contains(@class, '${ADD_AD_CLASS}')][1]
    Sleep  ${SLEEP_TIME}

Add Ecv
    Wait Until Page Is Fully Loaded Ecv Part
    Log To Console  https://www.autobazar.eu/pridat-inzerat/osobne-vozidla/zakladne-udaje
    Wait Until Element Is Visible  //input[@name='${ECV_INPUT_NAME}' and contains(@class, '${ECV_INPUT_CLASS}')]
    Click Element Using JavaScript  //input[@name='${ECV_INPUT_NAME}' and contains(@class, '${ECV_INPUT_CLASS}')]
    Input Text Slowly  //input[@name='${ECV_INPUT_NAME}' and contains(@class, '${ECV_INPUT_CLASS}')]  ${ECV_LIST}
    Sleep  ${SLEEP_TIME}
    Click Next Button Desktop
    Sleep  ${SLEEP_TIME}

Add With No Ecv Desktop
    Wait Until Page Is Fully Loaded Ecv Part
    Wait Until Element Is Visible  //a[@href='https://www.autobazar.eu/sk/pridat-inzerat' and contains(., 'Pridať inzerát')]
    Click Element Using JavaScript  //a[@href='https://www.autobazar.eu/sk/pridat-inzerat' and contains(., 'Pridať inzerát')]
    Log To Console  Pridávam inzerát - výber kategórie
    Wait Until Element Is Visible  ${ADD_AD_LINK}
    Click Element Using JavaScript  ${ADD_AD_LINK}
    Sleep  ${SLEEP_TIME}
    Log To Console  https://www.autobazar.eu/pridat-inzerat/motocykle/zakladne-udaje
    Wait Until Element Is Visible  ${CAR_BRAND_SELECTOR}
    Click Element Using JavaScript  ${CAR_BRAND_SELECTOR}
    Log To Console  Čakám 2
    Select From List  ${CAR_BRAND_OPTION}
    Log To Console  Čakám 3
    Sleep  ${SLEEP_TIME}
    Click Next Button Desktop

Click Next Button Desktop
    Wait Until Page Is Fully Loaded Ecv Part
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //button[contains(text(),'${BUTTON_NEXT_TEXT}')]
    Click Element Using JavaScript  //button[contains(text(),'${BUTTON_NEXT_TEXT}')]
    Log To Console  Klikám Ďalej
    Sleep  ${SLEEP_TIME}

Click Button Add An Advertisement Desktop
    Wait Until Page Is Fully Loaded Ecv Part
    Capture Page Screenshot  before_click.png
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //button[contains(text(),'${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}')]
    Wait Until Element Is Enabled  //button[contains(text(),'${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}')]
    Click Element Using JavaScript  //button[contains(text(),'${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}')]
    Log To Console  Klikám Pridať inzerát
    Sleep  ${SLEEP_TIME}
    Capture Page Screenshot  after_click.png


Check Adding Of Adv
    Wait Until Page Is Fully Loaded Ecv Part
    ${header_text} =    Get Text    xpath=//*[@id="tasks2"]/center/h1    # Získa text z <h1> elementu vo vnútri #tasks2
    Should Be Equal As Strings    ${header_text}    Váš inzerát ešte nie je zverejnený    # Porovná text s očakávaným textom
    Log To Console  Overujem pridanie inzerátu

Input Text Slowly
    [Arguments]  ${locator}  @{text}
    FOR  ${char}  IN  @{text}
        Log To Console  ${char}
        Input Text  ${locator}  ${char}
        Sleep  ${TYPING_DELAY}
    END

Choose A Model Prestige
    Wait Until Page Is Fully Loaded Ecv Part
    Wait Until Element Is Visible  //div[@id='selectTags']//span[@data-value='93510']
    Click Element Using JavaScript  //div[@id='selectTags']//span[@data-value='93510']
    Log To Console  "Clicked on 1.5 Blue dCi 115 Prestige 4x4"
    Sleep  ${TYPING_DELAY}
    Wait Until Element Is Visible  //div[@class='etax-bottom-bar']//a[contains(text(),'Vybrať a pokračovať')]  timeout=15
    Click Element Using JavaScript  //div[@class='etax-bottom-bar']//a[contains(text(),'Vybrať a pokračovať')]
    Click Next Button Desktop
    Sleep  ${SLEEP_TIME}

Choose A Model Starfinger
    Wait Until Page Is Fully Loaded Ecv Part
    Wait Until Element Is Visible  //div[@id='selectTags']//span[@data-value='20071']
    Click Element Using JavaScript  //div[@id='selectTags']//span[@data-value='20071']
    Log To Console  "Clicked on Starfinger"
    Sleep  ${TYPING_DELAY}
    Wait Until Element Is Visible  //div[@class='etax-bottom-bar']//a[contains(text(),'Vybrať a pokračovať')]
    Click Element Using JavaScript  //div[@class='etax-bottom-bar']//a[contains(text(),'Vybrať a pokračovať')]
    Click Next Button Desktop
    Sleep  ${SLEEP_TIME}

Delete VIN
    Wait Until Page Is Fully Loaded Ecv Part
    Log To Console  https://www.autobazar.eu/pridat-inzerat/osobne-vozidla/spresnenie
    Wait Until Element Is Visible  //input[@type='text' and @name='VIN' and @id='vindiv']
    Scroll Element Into View  //input[@type='text' and @name='VIN' and @id='vindiv']
    Log To Console  scrolujem ku VINku
    Double Click Element
    Clear Text In Input
    Sleep  1s
    Input Text  //input[@type='number' and @data-enable='drivenkm']  ${KM}
    Log To Console  vypisujem kilometre
    Click Next Button Desktop
    Sleep  ${SLEEP_TIME}

Double Click Element
    Execute JavaScript  var element = document.evaluate("${XPATH_INPUT}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; var evt = document.createEvent('MouseEvents'); evt.initEvent('dblclick', true, true); element.dispatchEvent(evt);
    Log To Console  dvojklik

Clear Text In Input
    Wait Until Element Is Visible  ${XPATH_INPUT}
    Log To Console  vidim vinko
    Clear Element Text  ${XPATH_INPUT}
    Log To Console  výmaz vinka

Price Part
    Wait Until Page Is Fully Loaded Ecv Part
    Click Next Button Desktop
    Log To Console  https://www.autobazar.eu/pridat-inzerat/osobne-vozidla/vybava
    Click Next Button Desktop
    Log To Console  https://www.autobazar.eu/pridat-inzerat/osobne-vozidla/stav
    Wait Until Element Is Visible  //input[@type='number' and @name='price' and @id='normalPrice' and contains(@class, 'normalPrice')]
    Log To Console  vpisujem cenu
    Click Element Using JavaScript  //input[@type='number' and @name='price' and @id='normalPrice']
    Log To Console  klik cena
    Input Text  //input[@type='number' and @name='price' and @id='normalPrice']  ${PRICE}
    Log To Console  vpisujem cenu
    Sleep  ${SLEEP_TIME}
    Click Next Button Desktop
    Log To Console  https://www.autobazar.eu/pridat-inzerat/osobne-vozidla/cena

Price Part Motorcycle
    Wait Until Page Is Fully Loaded Ecv Part
    Log To Console  https://www.autobazar.eu/pridat-inzerat/motocykle/spresnenie
    Wait Until Element Is Visible  //input[@type='number' and @data-enable='drivenkm']
    Input Text  //input[@type='number' and @data-enable='drivenkm']  ${KM2}
    Click Next Button Desktop
    Log To Console  https://www.autobazar.eu/pridat-inzerat/motocykle/vybava
    Click Next Button Desktop
    Log To Console  https://www.autobazar.eu/pridat-inzerat/motocykle/stav
    Click Next Button Desktop
    Sleep  1s
    Wait Until Element Is Visible  //input[@type='number' and @name='price' and @id='normalPrice' and contains(@class, 'normalPrice')]
    Log To Console  vpisujem cenu
    Click Element Using JavaScript  //input[@type='number' and @name='price' and @id='normalPrice']
    Log To Console  klik cena
    Input Text  //input[@type='number' and @name='price' and @id='normalPrice']  ${PRICE2}
    Log To Console  vpisujem cenu
    Sleep  ${SLEEP_TIME}
    Click Next Button Desktop
    Log To Console  https://www.autobazar.eu/pridat-inzerat/motocykle/cena

Upload Image
    [Arguments]  ${image_path2}
    Wait Until Page Is Fully Loaded Ecv Part
    Log To Console  https://www.autobazar.eu/pridat-inzerat/osobne-vozidla/media
    Scroll Down To Load Content 1 time
    Wait Until Element Is Visible  ${UPLOAD_BUTTON}
    Click Element Using JavaScript  ${UPLOAD_BUTTON}
    Sleep  1s
    Wait Until Element Is Visible  ${UPLOAD_INPUT_XPATH}
    Choose File  ${UPLOAD_INPUT_XPATH}  ${image_path2}
    Log To Console  Nahrávam súbor jpeg
    Sleep  ${SLEEP_TIME}
    Click Next Button Desktop

Upload An Image
    Log To Console  https://www.autobazar.eu/pridat-inzerat/osobne-vozidla/media
    # Kliknutie na tlačidlo "nahrajte" na zviditeľnenie input elementu
    Click Element Using JavaScript    xpath=//button[contains(@class, 'data-button-upload-photos')]
    # Výber a nahranie súboru
    Choose File     xpath=//input[@type='file']    ${image_path2}
    Sleep   ${SLEEP_TIME}

Confirm Checkbox Add Ad
    Wait Until Page Is Fully Loaded Ecv Part
    Log To Console  https://www.autobazar.eu/pridat-inzerat/.../kontakt
    Scroll Down To Load Content 1 time
    Click Element   id=contact-advertising-conditions
    Log To Console  Potvrdzujem súhlas klienta
    Click Button Add An Advertisement Desktop
    Sleep  ${SLEEP_TIME}
    Log To Console  Vytváram nový inzerát

Change Checkbox Value
    Wait Until Element Is Visible  ${CHECKBOX_XPATH}
    Log To Console  Checkbox zaškrtávam
    Execute JavaScript  document.evaluate("${CHECKBOX_XPATH}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.checked = true
    Log To Console  Checkbox zaškrtnutý

Change Checkbox Value X
[Arguments]    ${CHECKBOX_XPATH}
    Wait Until Element Is Visible  ${CHECKBOX_XPATH}    10s
    ${is_selected}=    Get Element Attribute    ${CHECKBOX_XPATH}    checked
    Run Keyword If    '${is_selected}'=='false'   Check Checkbox      ${CHECKBOX_XPATH}

Select From List
    [Arguments]    ${brand}
    Select From List By Label    ${CAR_BRAND_SELECTOR}    ${brand}

Check Checkbox Status
    [Arguments]    ${CHECKBOX_XPATH}
    Wait Until Element Is Visible  ${CHECKBOX_XPATH}
    ${is_selected}=    Get Element Attribute    ${CHECKBOX_XPATH}    checked
    Log To Console  Checkbox status: ${is_selected}