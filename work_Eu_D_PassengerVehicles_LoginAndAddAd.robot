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

Upload An Image Work
    [Arguments]  ${image}
    ${current_url}=    Get Location
    Log To Console  Aktuálna URL je: ${current_url}
    Wait Until Element Is Visible  //div[contains(@class,'border-dashed') and contains(@class,'bg-[#002466]')]  timeout=${WAIT_TIMEOUT}
    Click Element Using JavaScript  //div[contains(@class,'border-dashed') and contains(@class,'bg-[#002466]')]
    Log To Console  Klikol som na element
    # Výber a nahranie súboru
    Choose File     xpath=//input[@type='file']    ${image}
    Sleep   ${SLEEP_TIME}
    Log To Console  Nahratý obrázok.


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
    Click Optional Parameters Button Work
    Extra Basic Data Work

Vehicle Equipment Work
    [Documentation]  Výbava vozidla - Bezpečnosť a stabilizačné systémy, interiér, Exteriér, Komfort a multimédia, Funkcie a asistenčné služby a ďalšia výbava v poznámke.
    Wait Until Page Is Fully Loaded Old
    ${current_url}=    Get Location
    Log To Console  Aktuálna URL je: ${current_url}
    Click Safety And Stabilization Systems Work
    Click Interier Work
    Click Exterier Work
    Click Comfort And Multimedia Work
    Click Features and Assistance Services Work
    Note Work  ${textarea_name1}  ${placeholder1}  ${RANDOM_TEXT}

Name And Condition Of The Vehicle Work
    [Documentation]  Názov a stav vozidla.
    Renaming Work
    Condition Work
    Note Work  ${textarea_name2}  ${placeholder1}  ${RANDOM_TEXT2}

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
    Click Element Using JavaScript  //input[@name='mileage']
    Log To Console  Klikám na input Najazdené kilometre.
    Input Text  //input[@name='mileage']  6666
    Sleep  ${SLEEP_TIME}
    Log To Console  Vpisujem počet najazdených kilometrov.

Click Optional Parameters Button Work
    Wait Until Element Is Visible  //button[contains(@class,'relative') and contains(@class,'flex') and contains(.,'Ďalšie nepovinné parametre')]
    Scroll Element Into View  //button[contains(@class,'relative') and contains(@class,'flex') and contains(.,'Ďalšie nepovinné parametre')]
    Click Element Using JavaScript  //button[contains(@class,'relative') and contains(@class,'flex') and contains(.,'Ďalšie nepovinné parametre')]
    Log To Console  Klikám na Ďalšie nepovinné parametre
    Wait Until Element Is Visible  //div[contains(@class,'rounded-b-[16px]') and @data-headlessui-state='open']  timeout=${SLEEP_TIME}
    Log To Console  Panel s nepovinnými parametrami je zobrazený


Extra Basic Data Work
    Wait Until Element Is Visible  //input[@name='consumptionInTheCity']
    Click Element Using JavaScript  //input[@name='consumptionInTheCity']
    Log To Console  Klikám na input Spotreba v meste.
    Input Text  //input[@name='consumptionInTheCity']  10
    Sleep  ${SLEEP_TIME}
    Log To Console  Vpisujem spotrebu v meste.
    #
    Click Element Using JavaScript  //input[@name='consumptionOutOfTown']
    Log To Console  Klikám na input Spotreba mimo mesta.
    Input Text  //input[@name='consumptionOutOfTown']  8
    Sleep  ${SLEEP_TIME}
    Log To Console  Vpisujem spotrebu mimo mesta.
    #
    Click Element Using JavaScript  //input[@name='consumptionCombined']
    Log To Console  Klikám na input Spotreba kombinovaná.
    Input Text  //input[@name='consumptionCombined']  8
    Sleep  ${SLEEP_TIME}
    Log To Console  Vpisujem kombinovanú spotrebu.




Click Safety And Stabilization Systems Work
    Wait Until Element Is Visible    xpath=//button[contains(.,'Bezpečnosť a stabilizačné systémy')]
    Scroll Element Into View    xpath=//button[contains(.,'Bezpečnosť a stabilizačné systémy')]
    Click Element Using JavaScript  xpath=//button[contains(.,'Bezpečnosť a stabilizačné systémy')]
    Log To Console  Klikám na Bezpečnosť a stabilizačné systémy.
    # Čaká, kým sa panel "Bezpečnosť a stabilizačné systémy" rozbalí
    Wait Until Element Is Visible  //div[contains(@class,'rounded-b-[16px]') and @data-headlessui-state='open']  timeout=${SLEEP_TIME}
    Log To Console  Panel s Bezpečnosťou je rozbalený.
    # Klik na skrytý input checkbox
    Click Element Using JavaScript  //input[@name='airbag' and @type='checkbox' and contains(@class, 'hidden')]
    Log To Console  Volím airbagy.
    # Čaká, kým sa zobrazí tlačidlo listboxu
    Wait Until Element Is Visible  //button[span[contains(.,'Vyberte typ')]]  timeout=${WAIT_TIMEOUT}
    Log To Console  Rozbaľujem airbagy.
    Click Element  //button[span[contains(.,'Vyberte typ')]]
    Log To Console  Vyberám kolenné airbagy.
    Wait Until Element Is Visible  //div[span[contains(.,'Airbag kolenný')]]
    Click Element Using JavaScript  //div[contains(@class,'flex') and contains(.,'Airbag kolenný')]
    Log To Console  Klikám kolenné airbagy.
    Click Element Using JavaScript  xpath=//button[contains(.,'Bezpečnosť a stabilizačné systémy')]
    Log To Console  Minimalizujem 1.sekciu

Click Interier Work
    Wait Until Element Is Visible    xpath=//button[contains(.,'Interiér')]
    Log To Console  Klikám Interiér
    Scroll Element Into View    xpath=//button[contains(.,'Interiér')]
    Click Element Using JavaScript  xpath=//button[contains(.,'Interiér')]
    Log To Console  Klikám na Interiér.
    # Čaká, kým sa panel "Interiér" rozbalí
    Wait Until Element Is Visible  //div[contains(@class,'rounded-b-[16px]') and @data-headlessui-state='open']  timeout=${SLEEP_TIME}
    Log To Console  Panel s Interiérom je rozbalený.
    # Klik na skrytý input checkbox
    Click Element Using JavaScript  //input[@name='interier_heated_seats' and @type='checkbox' and contains(@class, 'hidden')]
    Log To Console  Volím vyhrievané sedačky.
    # Čaká, kým sa zobrazí tlačidlo listboxu
    Wait Until Element Is Visible  //select[@name='interier_heated_seats_type']  timeout=${WAIT_TIMEOUT}
    Log To Console  Rozbaľujem typ vyhrievaných sedačiek.
    Click Element Using JavaScript  //select[@name='interier_heated_seats_type']
    Log To Console  Vyberám si zo selektu sedačiek.
    Wait Until Element Is Visible  //select[@name='interier_heated_seats_type']
    Select From List By Label  //select[@name='interier_heated_seats_type']  Vyhrievané sedačky vpredu
    Log To Console  Klikám vyhrievané sedačky.
    Click Element Using JavaScript  xpath=//button[contains(.,'Interiér')]
    Log To Console  Minimalizujem 2.sekciu

Click Exterier Work
    Wait Until Element Is Visible    xpath=//button[contains(.,'Exteriér')]
    Scroll Element Into View    xpath=//button[contains(.,'Exteriér')]
    Click Element Using JavaScript  xpath=//button[contains(.,'Exteriér')]
    Log To Console  Panel s Exteriérom je rozbalený.
    # Vyber LED svetlomety
    Wait Until Element Is Visible  //div[contains(@class,'addition-field-input-checkbox') and contains(., 'LED svetlomety')]  timeout=${WAIT_TIMEOUT}
    Log To Console  LED svetlomety sú dostupné.
    Click Element Using JavaScript  //div[contains(@class,'addition-field-input-checkbox') and contains(., 'LED svetlomety')]
    # Vyber ťažné zariadenie
    Wait Until Element Is Visible  //div[contains(@class,'addition-field-input-checkbox') and contains(., 'Ťažné zariadenie')]  timeout=${WAIT_TIMEOUT}
    Log To Console  Ťažné zariadenie je dostupné.
    Click Element Using JavaScript  //div[contains(@class,'addition-field-input-checkbox') and contains(., 'Ťažné zariadenie')]
    Log To Console  LED svetlomety a ťažné zariadenie sú selektnuté.
    Click Element Using JavaScript  xpath=//button[contains(.,'Exteriér')]
    Log To Console  Minimalizujem 3.sekciu

Click Comfort And Multimedia Work
    Wait Until Element Is Visible    xpath=//button[contains(.,'Komfort a multimédia')]
    Log To Console  Klikám Komfort a multimédia
    Scroll Element Into View    xpath=//button[contains(.,'Komfort a multimédia')]
    Click Element Using JavaScript  xpath=//button[contains(.,'Komfort a multimédia')]
    Log To Console  Klikám na Komfort a multimédia.
    # Čaká, kým sa panel "Komfort a multimédia" rozbalí
    Wait Until Element Is Visible  //div[contains(@class,'rounded-b-[16px]') and @data-headlessui-state='open']  timeout=${SLEEP_TIME}
    Log To Console  Panel Komfort a multimédia je rozbalený.
    # Klik na skrytý input checkbox
    Click Element Using JavaScript  //input[@name='comfort_autoradio' and @type='checkbox' and contains(@class, 'hidden')]
    Log To Console  Volím Autorádio.
    # Čaká, kým sa zobrazí tlačidlo listboxu
    Wait Until Element Is Visible  //select[@name='comfort_autoradio_type']  timeout=${WAIT_TIMEOUT}
    Log To Console  Rozbaľujem typ autorádií.
    Click Element Using JavaScript  //select[@name='comfort_autoradio_type']
    Log To Console  Vyberám si zo selektu autorádií.
    Wait Until Element Is Visible  //select[@name='comfort_autoradio_type']
    Select From List By Label  //select[@name='comfort_autoradio_type']  Rádio + MP3
    Log To Console  Klikám Rádio + MP3.
    # Klik na skrytý input checkbox
    Click Element Using JavaScript  //input[@name='comfort_air_conditioning' and @type='checkbox' and contains(@class, 'hidden')]
    Log To Console  Volím Klimatizáciu.
    # Čaká, kým sa zobrazí tlačidlo listboxu
    Wait Until Element Is Visible  //select[@name='comfort_air_conditioning_type']  timeout=${WAIT_TIMEOUT}
    Log To Console  Rozbaľujem typ klimatizácie.
    Click Element Using JavaScript  //select[@name='comfort_air_conditioning_type']
    Log To Console  Vyberám si zo selektu klimatizácií.
    Wait Until Element Is Visible  //select[@name='comfort_air_conditioning_type']
    Select From List By Label  //select[@name='comfort_air_conditioning_type']  Manuálna klimatizácia
    Log To Console  Klikám Manuálna klimatizácia.
    # Vyber Welcome light
    Log To Console  Welcome light je dostupné.
    Click Element Using JavaScript  //input[@name='comfort_welcome_light' and @type='checkbox' and contains(@class, 'hidden')]
    Log To Console  Klikám Welcome light.
    Click Element Using JavaScript  xpath=//button[contains(.,'Komfort a multimédia')]
    Log To Console  Minimalizujem 4.sekciu

Click Features and Assistance Services Work
    Wait Until Element Is Visible    xpath=//button[contains(.,'Funkcie a asistenčné služby')]
    Scroll Element Into View    xpath=//button[contains(.,'Funkcie a asistenčné služby')]
    Click Element Using JavaScript  xpath=//button[contains(.,'Funkcie a asistenčné služby')]
    Log To Console  Panel Funkcie a asistenčné služby je rozbalený.
    # Vyber 4 parametre podla name
    Click Element Using JavaScript  //input[@name='assistent_adaptive_cruise_control' and @type='checkbox' and contains(@class, 'hidden')]
    Click Element Using JavaScript  //input[@name='assistent_remote_control_locking' and @type='checkbox' and contains(@class, 'hidden')]
    Click Element Using JavaScript  //input[@name='assistent_rain_sensor' and @type='checkbox' and contains(@class, 'hidden')]
    Click Element Using JavaScript  //input[@name='assistent_cruise_control' and @type='checkbox' and contains(@class, 'hidden')]
    Log to console  Vyberám Adaptívny tempomat, Diaľkové otváranie kufra, Dažďový senzor a Tempomat
    Click Element Using JavaScript  xpath=//button[contains(.,'Funkcie a asistenčné služby')]
    Log To Console  Minimalizujem 5.sekciu

Note Work
    [Arguments]    ${textarea_name}    ${placeholder}    ${text}
    Click Element Using JavaScript  //textarea[@name='${textarea_name}' and @placeholder='${placeholder}']
    Input Text  //textarea[@name='${textarea_name}' and @placeholder='${placeholder}']    ${text}

    #Click Element Using JavaScript  //textarea[@name='otherEquipment' and @placeholder='Napríklad: rok staré, možnosť odkúpenia auta, garážované a pod...']
    #Log To Console  klikám
    #Input Text  //textarea[@name='otherEquipment' and @placeholder='Napríklad: rok staré, možnosť odkúpenia auta, garážované a pod...']    ${RANDOM_TEXT}
    #Log To Console  píšem

Renaming Work
    Wait Until Element Is Visible  //textarea[@name='title']
    ${current_url}=    Get Location
    Log To Console  Aktuálna URL je: ${current_url}
    Click Element Using JavaScript  //textarea[@name='title']
    Log To Console  Klikám na Nadpis.
    Input Text  //textarea[@name='title']  ${RANDOM_NAME}
    Sleep  ${SLEEP_TIME}
    Log To Console  Vkladám názov vozidla.

Condition Work
    Click Element Using JavaScript  //input[@name='boughtInSR' and @type='checkbox' and contains(@class, 'hidden')]
    Click Element Using JavaScript  //input[@name='notDamaged' and @type='checkbox' and contains(@class, 'hidden')]
    Click Element Using JavaScript  //input[@name='serviceBook' and @type='checkbox' and contains(@class, 'hidden')]
    Click Element Using JavaScript  //input[@name='allServiceHistory' and @type='checkbox' and contains(@class, 'hidden')]
    Log to console  Vyberám Ako nové, Nebúrané, Servisná knižka a Úplná servisná história.

Price Part Work
    ${current_url}=    Get Location
    Log To Console  Aktuálna URL je: ${current_url}
    Wait Until Element Is Visible  //input[@name='price' and @placeholder='Zadajte sumu' and contains(@type, 'number')]
    Click Element Using JavaScript  //input[@name='price' and @placeholder='Zadajte sumu' and contains(@type, 'number')]
    Log To Console  klik cena
    Input Text  //input[@type='number' and @name='price']  ${PRICE}
    Log To Console  vpisujem cenu
    Sleep  ${SLEEP_TIME}

Click Button Add An Advertisement Desktop Work
    ${current_url}=    Get Location
    Log To Console  Aktuálna URL je: ${current_url}
    Wait Until Element Is Visible  //button[contains(text(),'${BUTTON_ADD_AN_ADVERTISEMENT_TEXT2}')]
    Click Element Using JavaScript  //button[contains(text(),'${BUTTON_ADD_AN_ADVERTISEMENT_TEXT2}')]
    Log To Console  Klikám Pridať inzerát
    Sleep  ${SLEEP_TIME}
