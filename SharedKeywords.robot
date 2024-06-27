*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem

*** Variables ***
${Base_URL}  https://www.autobazar.eu/
${URL_NA}  https://www.autobazar.eu/vysledky-nove-auta/
${URL_dovoz}  https://www.autobazar.eu/vysledky-na-dovoz/
${URL_najnovsie}  https://www.autobazar.eu/vysledky-najnovsie/
${URL_sellers}  https://www.autobazar.eu/predajcovia-aut/
${URL_forum}  https://forum.autobazar.eu/
${URL_magazin}  https://magazin.autobazar.eu/
${URL_AProka}  https://www.autopredajcaroka.eu/
${URL_documents}  https://www.autobazar.eu/dokumenty
${URL_tests}  https://www.autobazar.eu/testy-aut/
${URL_prices}  https://www.autobazar.eu/ceny-aut/
${URL_advertisiment}  https://www.autobazar.eu/detail/mercedes-glc-kupe-220-d-4matic-a-t/31460018/

${SLEEP_TIME}  2s
${USERNAME}   testsukromnik2
${PASSWORD}   Ringier01
${ECV_INPUT_NAME}     ecv_vozidla
${ECV_INPUT_CLASS}    ecv-input
@{ECV_LIST}           Z  A  5  7  5  J  L
${BUTTON_NEXT_TEXT}   Ďalej
${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}  Pridať inzerát
${TYPING_DELAY}       0.5s
${image_path}  /Users/vlckova.brindzova/PycharmProjects/robotframework/venv/Photos/fotoDacia.jpeg
${image_path2}  /Users/vlckova.brindzova/PycharmProjects/robotframework/venv/Photos/adamotoo.jpeg
${BUTTON_ADD_AN_ADVERTISEMENT_TEXT}  Pridať inzerát
${KM}  10000
${PRICE}  30000
${KM2}  10000
${PRICE2}  2500
*** Keywords ***
Disable Insecure Request Warnings
    Evaluate  exec("import urllib3; urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)")

Switch To Frame And Accept All
    Wait Until Page Contains Element  //iframe[@title='SP Consent Message']
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
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

Scroll Down To Load All Content
    ${height}=  Execute JavaScript  return document.body.scrollHeight
    WHILE  ${True}
        ${current_height}=  Execute JavaScript  return window.scrollY
        ${viewport_height}=  Execute JavaScript  return window.innerHeight
        Run Keyword If  ${current_height} + ${viewport_height} >= ${height}  Exit For Loop
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