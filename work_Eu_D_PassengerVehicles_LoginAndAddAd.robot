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

    Price Part Work
    Log To Console  pridanie4
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

Click Next Button Desktop
    Wait Until Page Is Fully Loaded Ecv Part
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //button[contains(text(),'${BUTTON_NEXT_TEXT}')]
    Click Element Using JavaScript  //button[contains(text(),'${BUTTON_NEXT_TEXT}')]
    Log To Console  Klikám Ďalej
    Sleep  ${SLEEP_TIME}

Click Button Add An Advertisement Desktop
    Wait Until Page Is Fully Loaded Ecv Part
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //button[contains(text(),'${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}')]
    Click Element Using JavaScript  //button[contains(text(),'${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}')]
    Log To Console  Klikám Pridať inzerát
    Sleep  ${SLEEP_TIME}

Input Text Slowly
    [Arguments]  ${locator}  @{text}
    FOR  ${char}  IN  @{text}
        Log To Console  ${char}
        Input Text  ${locator}  ${char}
        Sleep  ${TYPING_DELAY}
    END





Double Click Element
    Execute JavaScript  var element = document.evaluate("${XPATH_INPUT}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; var evt = document.createEvent('MouseEvents'); evt.initEvent('dblclick', true, true); element.dispatchEvent(evt);
    Log To Console  dvojklik

Clear Text In Input
    Wait Until Element Is Visible  ${XPATH_INPUT}
    Log To Console  vidim vinko
    Clear Element Text  ${XPATH_INPUT}
    Log To Console  výmaz vinka

Price Part Work
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

Upload An Image
    Log To Console  https://www.autobazar.eu/pridat-inzerat/osobne-vozidla/media
    # Kliknutie na tlačidlo "nahrajte" na zviditeľnenie input elementu
    Click Element Using JavaScript    xpath=//button[contains(@class, 'data-button-upload-photos')]
    # Výber a nahranie súboru
    Choose File     xpath=//input[@type='file']    ${IMAGE_PATH}
    Sleep   ${SLEEP_TIME}


Confirm Checkbox Add Ad
    Wait Until Page Is Fully Loaded Ecv Part
    Log To Console  https://www.autobazar.eu/pridat-inzerat/osobne-vozidla/kontakt
    Scroll Down To Load Content 1 time
    Click Element   id=contact-advertising-conditions
    Log To Console  Potvrdzujem súhlas klienta
    Click Button Add An Advertisement Desktop
    Sleep  ${SLEEP_TIME}
    Log To Console  Vytváram nový inzerát

Change Checkbox Value
    [Arguments]  ${locator}
    Wait Until Element Is Visible  ${locator}
    Execute JavaScript  document.evaluate("${locator}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.checked = true
    Log To Console  Checkbox value changed to 1.

Check Adding Of Adv
    Wait Until Page Is Fully Loaded Ecv Part
    ${header_text} =    Get Text    xpath=//*[@id="tasks2"]/center/h1    # Získa text z <h1> elementu vo vnútri #tasks2
    Should Be Equal As Strings    ${header_text}    Váš inzerát ešte nie je zverejnený    # Porovná text s očakávaným textom
    Log To Console  Overujem pridanie inzerátu

Perform Login Desktop Work
    Wait Until Element Is Visible  //button[.//picture/img[@alt='Prihlásiť'] and .//span[text()='Prihlásiť']]
    Click Element Using JavaScript  //button[.//picture/img[@alt='Prihlásiť'] and .//span[text()='Prihlásiť']]
    Input Text  //input[@type='text' and @placeholder='Meno, email alebo tel. číslo']  ${USERNAME_WORK}
    Input Text  //input[@type='password' and @placeholder='Heslo']  ${PASSWORD_WORK}
    Click Element Using JavaScript  //button[contains(., 'Prihlásiť sa')]
    Sleep  1s
    Log To Console  Korektné prihlásenie do next.AB.EU

Add A New Advertisiment Desktop Work
    Wait Until Page Is Fully Loaded
    Wait Until Element Is Visible  //div[@class='flex']//a[contains(@class, 'bg-[#0a84ff]') and contains(text(), 'Pridať inzerát')]
    Click Element Using JavaScript  //a[contains(@href, '/pridat-inzerat') and contains(text(), 'Pridať inzerát')]
    Reload Page
    #reload pretoze chce doplnit udaje
    Wait Until Element Is Visible  //a[contains(@href, '/pridat-inzerat/osobne-vozidla/zakladne-udaje/') and .//p[contains(text(), 'Miesto pre vaše sedany')]]
    Sleep  1s
    Click Element Using JavaScript  //a[contains(@href, '/pridat-inzerat/osobne-vozidla/zakladne-udaje/') and .//p[contains(text(), 'Miesto pre vaše sedany')]]
    Sleep  ${SLEEP_TIME}
    Log To Console  Vyberám kategóriu Osobné a úžitkové autá do 3,5 tony

Add Ecv Work
    Wait Until Page Is Fully Loaded Old
    ${current_url}=    Get Location
    Log To Console  Aktuálna URL je: ${current_url}
    Wait Until Element Is Visible  //input[@type='text' and contains(@placeholder, 'Zadajte EČV')]
    Click Element Using JavaScript  //input[@type='text' and contains(@placeholder, 'Zadajte EČV')]
    Input Text Slowly  //input[@type='text' and contains(@placeholder, 'Zadajte EČV')]  ${ECV_LIST2}
    Sleep  ${SLEEP_TIME}
    Log To Console  Vypĺňam EČV kvôli kontrole eurotaxu
    Click Next Button Desktop Work
    Sleep  ${SLEEP_TIME}

Click Next Button Desktop Work
    Wait Until Page Is Fully Loaded Old
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //button[contains(text(),'${BUTTON_NEXT_TEXT}')]
    Click Element Using JavaScript  //button[contains(text(),'${BUTTON_NEXT_TEXT}')]
    Log To Console  Klikám Ďalej
    Sleep  ${SLEEP_TIME}

Check My Ečv Work
    Wait Until Page Is Fully Loaded Old
    Wait Until Element Is Visible  //button[contains(text(),'Skontrolovať')]
    Click Element Using JavaScript  //button[contains(text(),'Skontrolovať')]
    Log To Console  Klikám Skontrolovať ečv
    Sleep  ${SLEEP_TIME}
    Click Next Button Desktop Work

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

Basic Data Work
    Basic Data Bodywork Work
    Basic Data Fuel Work
    Basic Data Drive Work
    Basic Data Gearbox Work
    Needed Data Work

Basic Data Bodywork Work
    Wait Until Page Is Fully Loaded Old
    ${current_url}=    Get Location
    Log To Console  Aktuálna URL je: ${current_url}
    Wait Until Element Is Visible  //div[@class='relative']//select[@name='bodywork']
    Click Element Using JavaScript  //div[@class='relative']//select[@name='bodywork']
    Log To Console  Klikám na select karoséria: ${BODYWORK}
    Select From List By Value  //div[@class='relative']/select[@name='bodywork']  30932
    Sleep  ${SLEEP_TIME}
    Log To Console  Potvrdzujem select: ${BODYWORK}

Basic Data Fuel Work
    Wait Until Element Is Visible  //div[@class='relative']//select[@name='fuel']
    Click Element Using JavaScript  //div[@class='relative']//select[@name='fuel']
    Log To Console  Klikám na select palivo: ${FUEL}
    Select From List By Value  //div[@class='relative']/select[@name='fuel']  31253
    Sleep  ${SLEEP_TIME}
    Log To Console  Potvrdzujem select: ${FUEL}

Basic Data Drive Work
    Wait Until Element Is Visible  //div[@class='relative']//select[@name='drive']
    Click Element Using JavaScript  //div[@class='relative']//select[@name='drive']
    Log To Console  Klikám na select pohon: ${DRIVE}
    Select From List By Value  //div[@class='relative']/select[@name='drive']  31264
    Sleep  ${SLEEP_TIME}
    Log To Console  Potvrdzujem select: ${DRIVE}

Basic Data Gearbox Work
    Wait Until Element Is Visible  //div[@class='relative']//select[@name='gearbox']
    Click Element Using JavaScript  //div[@class='relative']//select[@name='gearbox']
    Log To Console  Klikám na select prevodovka: ${GEARBOX}
    Select From List By Value  //div[@class='relative']/select[@name='gearbox']  31388
    Sleep  ${SLEEP_TIME}
    Log To Console  Potvrdzujem select: ${GEARBOX}

Needed Data Work
    Wait Until Element Is Visible  //input[@name='engineCapacity']
    Click Element Using JavaScript  //input[@name='engineCapacity']
    Log To Console  Klikám na input Objem motora.
    Input Text  //input[@name='engineCapacity']  12345
    Sleep  ${SLEEP_TIME}
    Log To Console  Vpisujem objem motora.
    #
    Click Element Using JavaScript  //input[@name='enginePower']
    Log To Console  Klikám na input Objem motora.
    Input Text  //input[@name='enginePower']  12345
    Sleep  ${SLEEP_TIME}
    Log To Console  Vpisujem výkon motora.
    #
    Click Element Using JavaScript  //div[@class='relative']//select[@name='numberOfDoors']
    Log To Console  Klikám na select počet dverí: ${DOORS_value}
    Select From List By Value  //div[@class='relative']/select[@name='numberOfDoors']  ${NRofDOORS}
    Sleep  ${SLEEP_TIME}
    Log To Console  Potvrdzujem select počet dverí: ${DOORS_value}
    #

Price Part Work
    Wait Until Page Is Fully Loaded Old
    Click Next Button Desktop Work
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

