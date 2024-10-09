*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem

*** Variables ***
${Base_URL}  https://www.autobazar.eu/
${NSK_URL}  https://www.nehnutelnosti.sk/
${Work_URL}  https://next.autobazareu.work/
${URL_NA}  https://www.autobazar.eu/vysledky-nove-auta/
${URL_dovoz}  https://www.autobazar.eu/vysledky-na-dovoz/
${URL_najnovsie}  https://www.autobazar.eu/vysledky-najnovsie/
${URL_sellers}  https://www.autobazar.eu/predajcovia-aut/
${URL_seller_detail}  https://www.autobazar.eu/predajca/autodado/
${URL_seller_detail2}  https://www.autobazar.eu/predajca/styxvrable/
${URL_seller_detail3}  https://www.autobazar.eu/predajca//
${URL_forum}  https://forum.autobazar.eu/
${URL_magazin}  https://magazin.autobazar.eu/
${URL_AProka}  https://www.autopredajcaroka.eu/
${URL_documents}  https://www.autobazar.eu/dokumenty
${URL_tests}  https://www.autobazar.eu/testy-aut/
${URL_prices}  https://www.autobazar.eu/ceny-aut/
${URL_advertisiment}  https://www.autobazar.eu/detail/bmw-rad-7-nemazat-tento-inzerat/31565154/
${URL_podcast}  https://magazin.autobazar.eu/podcasty
${URL_myaccount}  https://autobazar.eu/moje-konto/
${URL_myfavorite}  https://autobazar.eu/moje-konto/oblubene/
${URL_currentads}  https://www.autobazar.eu/sk/users.php?act=view
${URL_noncurrentads}  https://www.autobazar.eu/sk/users.php?act=expired
${URL_modificate}  https://www.autobazar.eu/vysledky/nakladne-vozidla-nad-7-5t/
${URL_CZ}  https://www.autobazar.cz

${DESKTOP_WIDTH}  1920
${DESKTOP_HEIGHT}  1080
${MOBILE_WIDTH}  390
${MOBILE_HEIGHT}  844

${BUTTON_TEXT_CALL}  Zavolať
${BUTTON_TEXT_WRITE}  Napísať
${BUTTON_TEXT_VISIT}  Navštíviť

${SEARCH_AGENT_NAME}  Moje hľadanie

${SLEEP_TIME}  2s
${WAIT_TIME}  5s
${WAIT_TIMEOUT}  20s
${TYPING_DELAY}  0.5s
${USERNAME_WORK}   iveta1234522
${USERNAME}   testsukromnik2
${PASSWORD_WORK}   takenejake2H
${PASSWORD}   Ringier01
${ECV_INPUT_NAME}     ecv_vozidla
${ECV_INPUT_CLASS}    ecv-input
@{ECV_LIST}           Z  A  5  7  5  J  L
${ECV_LIST2}           ZA575JL
${BUTTON_NEXT_TEXT}   Ďalej
${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}  Pridať inzerát
${image_path}  /Users/vlckova.brindzova/PycharmProjects/robotframework/venv/Photos/fotoDacia.jpeg
${image_path2}  /Users/vlckova.brindzova/PycharmProjects/robotframework/venv/Photos/adamotoo.jpeg
${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}  Pridať inzerát
${KM}  10000
${PRICE}  30000
${KM2}  10000
${KM3}  100000
${PRICE2}  2500
${PRICE_FROM}  13000
${PRICE_TO}  25000
${YEAR_FROM}  1999
${YEAR_TO}  2024
${FUEL}  Diesel
${BODYWORK}  Combi
${GEARBOX}  Automatická
${DRIVE}  Predný
${NRofDOORS}  31408
${DOORS_value}  5

${textarea_name1}  otherEquipment
${textarea_name2}  noteForBuyer
${placeholder1}  Napríklad: rok staré, možnosť odkúpenia auta, garážované a pod...
${RANDOM_TEXT}  Testovací inzerát, prosím nereagujte naň.
${RANDOM_TEXT2}  Testovací inzerát, prosím nereagujte naň, určite.
${RANDOM_NAME}  Najlepšie auto!

*** Keywords ***
Disable Insecure Request Warnings
    [Documentation]  Potlačí upozornenia na neoverené HTTPS požiadavky.
    Evaluate  exec("import urllib3; urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)")

Switch To Frame And Accept All
    Wait Until Page Contains Element  //iframe[@title='SP Consent Message']
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Unselect Frame

Switch To Frame And Accept All CZ
    Wait Until Page Contains Element  //iframe[@title='SP Consent Message']
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Přijmout vše']
    Unselect Frame

Wait Until Page Is Fully Loaded
    Wait Until Page Contains Element  //footer
    Wait Until Page Contains Element  //main
    Wait Until Page Contains Element  //nav
    ${ready_state}=  Execute JavaScript  return document.readyState
    Wait Until Keyword Succeeds  1 min  1 sec  Execute JavaScript  return document.readyState == 'complete'

Wait Until Page Is Fully Loaded Ecv Part
    Wait Until Page Contains Element  //footer
    ${ready_state}=  Execute JavaScript  return document.readyState
    Wait Until Keyword Succeeds  1 min  1 sec  Execute JavaScript  return document.readyState == 'complete'

Wait Until Page Is Fully Loaded Old
    ${ready_state}=  Execute JavaScript  return document.readyState
    Wait Until Keyword Succeeds  1 min  1 sec  Execute JavaScript  return document.readyState == 'complete'
    Log To Console  Načítavam stránku

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

Remove Duplicates From Listt
    [Documentation]  Odstráni duplicity zo zoznamu odkazov.
    ${unique_links}=  Remove Duplicates  ${Links}
    Set Global Variable  ${Links}  ${unique_links}

Scroll Down To Load All Content
    ${height}=  Execute JavaScript  return document.body.scrollHeight
    WHILE  ${True}
        ${current_height}=  Execute JavaScript  return window.scrollY
        Log To Console  desktop scrolujem
        ${viewport_height}=  Execute JavaScript  return window.innerHeight
        Log To Console  rozlíšenie: ${current_height} + ${viewport_height} >= ${height}
        Run Keyword If  ${current_height} + ${viewport_height} >= ${height}  Exit For Loop
        Log To Console  desktop scrollujem
        Execute JavaScript  window.scrollBy(0, window.innerHeight)
        Sleep  1s
    END

Clear List
    [Arguments]  @{list}
    [Documentation]  Vyprázdni daný zoznam.
    Set Variable  @{list}  @{EMPTY}

Scroll Down To Load Content 1 time
    Execute JavaScript    window.scrollBy(0, window.innerHeight)
    Sleep    1s

Scroll Down To Load Content 2 times
    FOR    ${i}    IN RANGE    2
        Execute JavaScript    window.scrollBy(0, window.innerHeight)
        Sleep    1s
    END

Scroll Down To Load Content 7 times
    FOR    ${i}    IN RANGE    7
        Execute JavaScript    window.scrollBy(0, window.innerHeight)
        Sleep    1s
    END

Click Element Using JavaScript
    [Arguments]  ${xpath}
    Execute JavaScript  document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Sleep  1s

Click Button And Verify Response
    [Arguments]  ${button_text}
    Log To Console  Clicking button with text "${BUTTON_TEXT_CALL}" and verifying response
    ${button_xpath}=    Set Variable    //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT_CALL}']
    Wait Until Element Is Visible    ${button_xpath}
    Click Element Using JavaScript    ${BUTTON_TEXT_CALL}
    ${url}=    Get Location
    Log To Console  Verifying response for URL: ${url}
    ${response}=    Request  GET  ${url}
    Should Be Equal As Numbers  ${response.status_code}  200
    Log To Console  Button "${button_text}" returned status code ${response.status_code}

Check Phone Number
    [Arguments]  ${phone_number}
    Log To Console  Checking phone number
    ${phone_xpath}=    Set Variable    //div[contains(@class, 'mt-[24px]')]//a[contains(@class, 'btn-cta')]
    Wait Until Element Is Visible    ${phone_xpath}
    ${actual_phone_number}=    Get Text    ${phone_xpath}
    Log To Console  Retrieved phone number: ${actual_phone_number}
    Should Be Equal    ${actual_phone_number}  ${phone_number}

Scroll To Buttons
    [Arguments]  ${button_xpath_call}  ${button_xpath_write}  ${button_xpath_visit}
    Scroll Element Into View    ${button_xpath_call}
    Scroll Element Into View    ${button_xpath_write}
    Scroll Element Into View    ${button_xpath_visit}

Return To Main Page
    [Arguments]  ${main_page_element_xpath}
    Close All Browsers
    Open Browser    ${URL}    chrome
    Maximize Browser Window
    Wait Until Page Is Fully Loaded
    Switch To Frame And Accept All
    Scroll To Buttons    ${BUTTON_XPATH_CALL}    ${BUTTON_XPATH_WRITE}    ${BUTTON_XPATH_VISIT}

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

Should Ignore Href
    [Arguments]  ${href}
    ${result}=  Run Keyword And Return Status  Should Contain Any  ${href}  @{Ignored_Patterns}
    RETURN  ${result}

Log Total Links Found
    [Documentation]  Zaloguje celkový počet nájdených odkazov.
    ${total_links}=  Get Length  ${All_links}
    Log To Console  Total links found: ${total_links}
    Set Global Variable  ${TOTAL_LINKS}  ${total_links}
    Set Global Variable  ${REMAINING_LINKS}  ${total_links}

Log Broken Link
    [Arguments]  ${url}  ${status_code}
    Log  Broken link found: ${url} with status code: ${status_code}
    Append To List  ${Broken_Links}  ${url}

Log Valid Link
    [Arguments]  ${url}
    Log  Valid link found: ${url} with status code: ${status_code}
    Append To List  ${Valid_Links}  ${url}

Log All Valid Links
    [Documentation]  Zaloguje všetky platné odkazy na konci testu.
    Log To Console  Valid links found: ${Valid_Links}

Fail Test If Broken Links Exist
    Run Keyword If  ${Broken_Links}  Fail  Broken links found: ${Broken_Links}

Select Option From Dropdown By Index
    [Arguments]    ${dropdown_locator}    ${index}
    Select From List By Index    ${dropdown_locator}    ${index}
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]

Select Option From Dropdown By Value
    [Arguments]    ${dropdown_locator}    ${value}
    Select From List By Value    ${dropdown_locator}    ${value}
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]

Wait Until Loader Disappears And Click Button
    [Arguments]  ${xpath}
    [Documentation]  Počká, kým zmizne loader (SVG prvok) a klikne na tlačidlo.
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  ${xpath}
    Scroll Element Into View  ${xpath}
    Click Element Using JavaScript  ${xpath}

Perform Login Desktop
    Wait Until Element Is Visible  //button[.//picture/img[@alt='Prihlásiť'] and .//span[text()='Prihlásiť']]
    Click Element Using JavaScript  //button[.//picture/img[@alt='Prihlásiť'] and .//span[text()='Prihlásiť']]
    Input Text  //input[@type='text' and @placeholder='Meno, email alebo tel. číslo']  ${USERNAME}
    Input Text  //input[@type='password' and @placeholder='Heslo']  ${PASSWORD}
    Click Element Using JavaScript  //button[contains(., 'Prihlásiť sa')]
    Sleep  1s
    Log To Console  Korektné prihlásenie do AB.EU

Perform Login Desktop Old
    Wait Until Element Is Visible  //a[@class='switchLogin']
    Click Element Using JavaScript  //a[@class='switchLogin']
    Input Text  //input[@type='text' and @placeholder='Meno, email alebo tel. číslo']  ${USERNAME}
    Input Text  //input[@type='password' and @placeholder='Heslo']  ${PASSWORD}
    Click Element Using JavaScript  //input[@type='submit' and @value='Prihlásiť sa']
    Sleep  1s
    Log To Console  Korektné prihlásenie do starého AB.EU

Seller Links Check
    [Documentation]  Tento test otvorí prehliadač, načíta stránku predajcov aut, overí HTTP status kód každého inzerátu kliknutím na obrázok.
    Disable Insecure Request Warnings
    FOR  ${url}  IN  @{Valid_Links}
        Open Valid Link And Check Inner Links  ${url}
    END
    Navigate ThroughPages Until Last Span
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist

Navigate ThroughPages Until Last Span
    ${last_page}=  Get Variable Value  ${False}
    WHILE  '${last_page}' == '${False}'
        @{elements}=  Get WebElements  ${PAGINATOR_WRAPPER_SELLER}//a | ${PAGINATOR_WRAPPER_SELLER}//span
        ${urls}=  Create List
        FOR  ${element}  IN  @{elements}
            ${href}=  Get Element Attribute  ${element}  href
            Run Keyword If  '${href}'  Append To List  ${urls}  ${href}
        END
        ${current_url}=  Get Location
        ${next_url}=  Evaluate  helper.get_next_page_url("${current_url}", ${urls})
        Log To Console    Next URL is: ${next_url}
        Open Valid Link And Check Inner Links  ${current_url}
        Run Keyword If  '${next_url}' == 'None'  Exit For Loop
        Run Keyword If  '${next_url}' != 'None'  Go To  ${next_url}
        Run Keyword If  '${next_url}' != 'None'  Sleep  1s  # Wait for the next page to load
    END
    Sleep  2s

Input Search Term And Click Button
    [Arguments]  ${term}
    Input Text  //input[@type='search' and @placeholder='Napíšte hľadaný výraz']  ${term}
    Wait Until Loader Disappears And Click Button  //button[contains(@class, 'mt-5 w-full space-x-2 rounded-lg bg-[#0071e3] px-[15px] py-[14px] font-semibold disabled:bg-[#0071e3]/80 disabled:text-white/80 lg:w-[170px]')]

Get All Links
    [Documentation]  Získaj všetky odkazy (a-href) z prvkov s triedou `flex flex-wrap justify-between gap-2`.
    @{elements}=  Get WebElements  //div[contains(@class, 'flex flex-wrap justify-between gap-2')]//a
    ${links}=  Create List
    FOR  ${element}  IN  @{elements}
        ${href}=  Get Element Attribute  ${element}  href
        Append To List  ${links}  ${href}
    END
    ${unique_links}=  Remove Duplicates  ${links}
    Set Global Variable  ${Links}  ${unique_links}

Get All Links And Check Status For All Pages
    [Documentation]  Získa všetky odkazy a skontroluje ich stav pre všetky strany v paginácii.
    WHILE  True
        ${next_button_exists}=  Run Keyword And Return Status  Page Should Contain Element  ${NEXT_BUTTON_XPATH}
        Get All Links
        Log Total Links Found
        CheckHrefsStatus
        Clear List  @{Links}
        Run Keyword If  ${next_button_exists} == False  Exit For Loop
        Click Element Using JavaScript  ${NEXT_BUTTON_XPATH}
        Sleep  ${SLEEP_TIME}
        Wait Until Page Is Fully Loaded
    END

Get All Links And Check Status For All Pages Here
    [Documentation]  Získa všetky odkazy a skontroluje ich stav pre všetky strany v paginácii.
    WHILE  True
        ${next_button_exists}=  Run Keyword And Return Status  Page Should Contain Element  ${NEXT_BUTTON_XPATH}
        Get All Links In Element
        Log Total Links Found
        CheckHrefsStatus
        Clear List  @{Links}
        Run Keyword If  ${next_button_exists} == False  Exit For Loop
        Click Element Using JavaScript  ${NEXT_BUTTON_XPATH}
        Sleep  ${SLEEP_TIME}
        Wait Until Page Is Fully Loaded
    END

Open Valid Link And Check Inner Links
    [Arguments]  ${url}
    [Documentation]  Otvorí platný odkaz a skontroluje vnútorné odkazy.
    Log To Console  Otváram odkaz: ${url}
    Go To    ${url}
    Wait Until Page Is Fully Loaded
    ${image_a}=  Get WebElements  //div[contains(@class, 'mt-8') and contains(@class, 'flex') and contains(@class, 'min-h-[122px]') and contains(@class, 'w-full') and contains(@class, 'justify-between') and contains(@class, 'gap-0.5') and contains(@class, 'md:min-h-[192px]') and contains(@class, 'flex-row')]/a[1]

    FOR  ${link}  IN  @{image_a}
        ${href}=  Get Element Attribute  ${link}  href
        ${status}=  Run Keyword And Ignore Error  Check Single Href Status  ${href}
        Log To Console  ${status}
        ${status_code}=  Set Variable If  '${status[0]}' == 'PASS'  ${status[1]}  -1
        Log To Console  status kód linku ${href} je ${status_code}
        Run Keyword If  '${status_code}' == '200'  Log Valid Link  ${href}
        Run Keyword If  '${status_code}' != '200'  Log Broken Link  ${href}  ${status_code}
    END

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

Click Button Add An Advertisement Desktop
    Wait Until Page Is Fully Loaded Ecv Part
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //button[contains(text(),'${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}')]
    Wait Until Element Is Enabled  //button[contains(text(),'${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}')]
    Click Element Using JavaScript  //button[contains(text(),'${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}')]
    Log To Console  Klikám Pridať inzerát
    Sleep  ${SLEEP_TIME}

Click Next Button Desktop
    Wait Until Page Is Fully Loaded Ecv Part
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //button[contains(text(),'${BUTTON_NEXT_TEXT}')]
    Click Element Using JavaScript  //button[contains(text(),'${BUTTON_NEXT_TEXT}')]
    Log To Console  Klikám Ďalej
    Sleep  ${SLEEP_TIME}

Input Text Slowly
    [Arguments]  ${locator}  @{text}
    FOR  ${char}  IN  @{text}
        Log To Console  ${char}
        Input Text  ${locator}  ${char}
        Sleep  ${TYPING_DELAY}
    END

Add A New Advertisiment Desktop
    Wait Until Page Is Fully Loaded
    Wait Until Element Is Visible  //a[@href='https://www.autobazar.eu/sk/pridat-inzerat' and contains(., 'Pridať inzerát')]
    Click Element Using JavaScript  //a[@href='https://www.autobazar.eu/sk/pridat-inzerat' and contains(., 'Pridať inzerát')]
    Wait Until Element Is Visible  //a[@href='${ADD_AD_URL}' and contains(@class, '${ADD_AD_CLASS}')][1]
    Sleep  1s
    Click Element Using JavaScript  //a[@href='${ADD_AD_URL}' and contains(@class, '${ADD_AD_CLASS}')][1]
    Sleep  ${SLEEP_TIME}

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

Upload An Image
    [Arguments]    ${image}
    Log To Console  https://www.autobazar.eu/pridat-inzerat/yy/media
    # Kliknutie na tlačidlo "nahrajte" na zviditeľnenie input elementu
    Click Element Using JavaScript    xpath=//button[contains(@class, 'data-button-upload-photos')]
    # Výber a nahranie súboru
    Choose File     xpath=//input[@type='file']    ${image}
    Sleep   ${SLEEP_TIME}

Select From List
    [Arguments]    ${brand}
    Select From List By Label    ${CAR_BRAND_SELECTOR}    ${brand}

Check Adding Of Adv
    Wait Until Page Is Fully Loaded Ecv Part
    ${header_text} =    Get Text    xpath=//*[@id="tasks2"]/center/h1    # Získa text z <h1> elementu vo vnútri #tasks2
    Should Be Equal As Strings    ${header_text}    Váš inzerát ešte nie je zverejnený    # Porovná text s očakávaným textom
    Log To Console  Overujem pridanie inzerátu

Confirm Checkbox Add Ad
    Wait Until Page Is Fully Loaded Ecv Part
    Log To Console  https://www.autobazar.eu/pridat-inzerat/.../kontakt
    Scroll Down To Load Content 1 time
    Click Element   id=contact-advertising-conditions
    Log To Console  Potvrdzujem súhlas klienta
    Click Button Add An Advertisement Desktop
    Sleep  ${SLEEP_TIME}
    Log To Console  Vytváram nový inzerát

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

Go To Gateway
    Wait Until Page Is Fully Loaded Ecv Part
    Wait Until Element Is Visible  ${XPATH_GATE}
    Click Element Using JavaScript  ${XPATH_PAY_OPTIONS}
    Log To Console  Úhrada kartou
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  ${XPATH_TRUSTPAY}
    Click Element Using JavaScript  ${XPATH_TRUSTPAY}
    Log To Console  Presmerovanie na úhradu kartou

Wait Until Loader Disappears And Click Buttonn
    [Arguments]  ${locator}
    Wait Until Element Is Not Visible  ${locator}  timeout=30s
    Click Element Using JavaScript  ${locator}

Select Brand From Dropdown
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Značka']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Značka']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='flex space-x-1']//button[picture/img[@alt='Škoda']]
    Click Element Using JavaScript  //div[@class='flex space-x-1']//button[picture/img[@alt='Škoda']]
    Log To Console  Vyberám značku Škoda
    Sleep  ${SLEEP_TIME}

Select Model From Drop
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Scroll Element Into View  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Wait Until Element Is Visible  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Click Element Using JavaScript  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Log To Console  Vyberám model Octavia
    Sleep  ${SLEEP_TIME}

Select Model From Dropdown
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Click Element Using JavaScript  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Log To Console  Vyberám model Octavia
    ${button_xpath}=    Set Variable    //button[.//span[text()='Potvrdiť']]
    ${select_xpath}=    Set Variable    //select[@name='model']
    Click Button And Wait For Select Box To Close  ${button_xpath}  ${select_xpath}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s modelom: ${button_text_show}

Click Button And Wait For Select Box To Close
    [Arguments]  ${button_xpath}  ${select_xpath}
    Click Element Using JavaScript  ${button_xpath}
    Wait Until Element Is Not Visible  ${select_xpath}
    Log To Console  Select box zatvorený.

Select Brand From Dropdown And Close Listbox
    [Arguments]  ${brand}
    ${button_xpath}=    Set Variable  //button[.//span[text()='Potvrdiť']]
    ${listbox_xpath}=    Set Variable  //div[@class='scrollbar mt-[70px] h-60 w-full overflow-auto bg-[#002466] px-3 py-1 text-sm']
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Značka']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Značka']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='flex space-x-1']//button[picture/img[@alt='${brand}']]
    Click Element Using JavaScript  //div[@class='flex space-x-1']//button[picture/img[@alt='${brand}']]
    Log To Console  Vyberám značku ${brand}
    Sleep  ${SLEEP_TIME}
    Click Button And Wait For Listbox To Close  ${button_xpath}  ${listbox_xpath}
    Log To Console  Zatváram listbox značka
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov so značkou: ${button_text_show}

Select Model From Dropdown And Close Listbox
    [Arguments]  ${model}
    ${button_xpath}=    Set Variable  //button[.//span[text()='Potvrdiť']]
    ${listbox_xpath}=    Set Variable  //div[@class='scrollbar mt-[70px] h-60 w-full overflow-auto bg-[#002466] px-3 py-1 text-sm']
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), '${model}')]
    Click Element Using JavaScript  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), '${model}')]
    Log To Console  Vyberám model ${model}
    Sleep  ${SLEEP_TIME}
    Click At Coordinates  100  100
    Log To Console  Klikám mimo scrollbaru
    Sleep  ${SLEEP_TIME}
    Log To Console  Zatváram listbox model
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s modelom: ${button_text_show}

Click Button And Wait For Listbox To Close
    [Arguments]  ${button_xpath}  ${listbox_xpath}
    Click Element Using JavaScript  ${button_xpath}
    Wait Until Element Is Not Visible  ${listbox_xpath}  timeout=20s
    Log To Console  Listbox zatvorený.

Select Year From Dropdown
    [Arguments]  ${year}
    ${option_value}=  Set Variable  od ${year}
    Wait Until Element Is Visible  //select[@name='yearFrom']
    Click Element Using JavaScript  //select[@name='yearFrom']
    Select From List By Label  //select[@name='yearFrom']  ${option_value}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadávam rok od: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Select Price From Dropdown
    [Arguments]  ${price}
    ${option_value}=  Set Variable  od ${price} €
    Wait Until Element Is Visible  //select[@name='priceFrom']
    Click Element Using JavaScript  //select[@name='priceFrom']
    Select From List By Value  //select[@name='priceFrom']  ${price}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadávam cenu od: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Select Fuel From Dropdown
    [Arguments]  ${fuel}
    ${option_value}=  Set Variable  ${fuel}
    Wait Until Element Is Visible  //select[@name='fuel']
    Click Element Using JavaScript  //select[@name='fuel']
    Select From List By Label  //select[@name='fuel']  ${fuel}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadávam palivo: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Input Value Km Into Dropdown
    [Arguments]  ${km}
    ${option_value}=  Set Variable  ${km}
    Wait Until Element Is Visible  //input[@name='mileageFrom']
    Click Element Using JavaScript  //input[@name='mileageFrom']
    Input Text  //input[@name='mileageFrom']  ${km}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadávam kilometre: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Wait For Element And Compare Values
    [Arguments]  ${button_locator}  ${text_locator}
    [Documentation]  Počká, kým sa zobrazí element, a potom porovná jeho hodnotu s iným textovým elementom.
    Wait Until Element Is Visible  ${button_locator}
    ${button_text_show}=  Get Text  ${button_locator}
    Wait Until Element Is Visible  ${text_locator}
    ${results_text}=  Get Text  ${text_locator}
    Should Be Equal As Numbers  ${button_text_show}  ${results_text}

Click At Coordinates
    [Arguments]  ${x}  ${y}
    Execute Javascript  window.scrollTo(${x}, ${y});
    Click Element At Coordinates  xpath=//body  ${x}  ${y}

Select Bodywork
    [Arguments]  ${bodywork_option}
    Wait Until Element Is Visible  //select[@name='bodywork']
    Log To Console  Klikám na select: ${bodywork_option}
    Select From List By Label  //select[@name='bodywork']  ${bodywork_option}
    Sleep  ${SLEEP_TIME}
    Log To Console  Potvrdzujem select: ${bodywork_option}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadávam karosériu: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Check Sk Location Checkbox
    [Arguments]  ${location}
    Wait Until Element Is Visible  //label[input[@name='location']]//span[contains(text(), '${location}')]
    Click Element Using JavaScript  //label[input[@name='location']]//span[contains(text(), '${location}')]
    Sleep  ${SLEEP_TIME}
    Log To Console  Checkbox pre ${location} vybraný.
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadané inzeráty: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Set Price From Input
    [Arguments]  ${price}
    Scroll Element Into View  //input[@placeholder='Cena od']
    Wait Until Element Is Visible  //input[@placeholder='Cena od']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Cena od']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Cena od']
    Input Text  //input[@placeholder='Cena od']  ${PRICE_FROM}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložená cena od: ${price}
    Sleep  20s

Set Price To Input
    [Arguments]  ${price}
    Scroll Element Into View  //input[@placeholder='Cena do']
    Wait Until Element Is Visible  //input[@placeholder='Cena do']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Cena do']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Cena do']
    Input Text  //input[@placeholder='Cena do']  ${PRICE_TO}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložená cena do: ${price}
    Sleep  10s

Set Km From Input
    [Arguments]  ${km}
    Scroll Element Into View  //input[@placeholder='Km od']
    Wait Until Element Is Visible  //input[@placeholder='Km od']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Km od']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Km od']
    Input Text  //input[@placeholder='Km od']  ${KM2}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložené km do: ${km}
    Sleep  10s

Set Km To Input
    [Arguments]  ${km}
    Scroll Element Into View  //input[@placeholder='Km do']
    Wait Until Element Is Visible  //input[@placeholder='Km do']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Km do']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Km do']
    Input Text  //input[@placeholder='Km do']  ${KM3}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložené km do: ${km}
    Sleep  10s

Set Year From Input
    [Arguments]  ${year}
    Scroll Element Into View  //input[@placeholder='Rok od']
    Wait Until Element Is Visible  //input[@placeholder='Rok od']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Rok od']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Rok od']
    Input Text  //input[@placeholder='Rok od']  ${YEAR_FROM}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložený rok do: ${year}
    Sleep  10s

Set Year To Input
    [Arguments]  ${year}
    Scroll Element Into View  //input[@placeholder='Rok do']
    Wait Until Element Is Visible  //input[@placeholder='Rok do']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Rok do']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Rok do']
    Input Text  //input[@placeholder='Rok do']  ${YEAR_TO}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložený rok do: ${year}
    Sleep  10s

Check Diesel Checkbox
    [Arguments]  ${fuel}
    ${xpath}=  Set Variable  //button[contains(., '${fuel}')]
    Wait Until Element Is Visible  ${xpath}  20s
    Click Element Using JavaScript  ${xpath}
    Sleep  ${SLEEP_TIME}
    Log To Console  Checkbox pre ${fuel} vybraný.
    Sleep  ${SLEEP_TIME}

Check Combi Checkbox
    [Arguments]  ${bodywork}
    ${xpath}=  Set Variable  //button[contains(., '${bodywork}')]
    Wait Until Element Is Visible  ${xpath}  20s
    Click Element Using JavaScript  ${xpath}
    Sleep  ${SLEEP_TIME}
    Log To Console  Checkbox pre ${bodywork} vybraný.
    Sleep  ${SLEEP_TIME}

Check Gearbox Checkbox
#prevodovka
    [Arguments]  ${gearbox}
    ${xpath}=  Set Variable  //button[contains(., '${gearbox}')]
    Wait Until Element Is Visible  ${xpath}  20s
    Click Element Using JavaScript  ${xpath}
    Sleep  ${SLEEP_TIME}
    Log To Console  Checkbox pre prevodovku ${gearbox} vybraný.
    Sleep  ${SLEEP_TIME}

Check Drive Checkbox
#pohon
    [Arguments]  ${drive}
    ${xpath}=  Set Variable  //button[contains(., '${drive}')]
    Wait Until Element Is Visible  ${xpath}  20s
    Click Element Using JavaScript  ${xpath}
    Sleep  ${SLEEP_TIME}
    Log To Console  Checkbox pre pohon ${drive} vybraný.
    Sleep  ${SLEEP_TIME}
