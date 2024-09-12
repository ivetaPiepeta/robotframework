*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem
Library  String
Resource  SharedKeywords.robot
Library    helper.py

*** Variables ***
@{All_links}    # Tento zoznam bude obsahovať všetky odkazy (href)
@{Broken_Links}
@{Valid_Links}  # Tento zoznam bude obsahovať všetky odkazy s statusom 200
${TOTAL_LINKS}  0
${REMAINING_LINKS}  0
${SLEEP_TIME}  2s
@{Paginator_Links}
${NEXT_BUTTON_XPATH}  //a[contains(@class, 'cursor-pointer') and contains(text(), 'Ďalší predajcovia')]
${PAGINATOR_WRAPPER_SELLER}  //div[@class="float-none mx-0 my-0"]
${BUTTON_TEXT_SHOW}  //button[contains(., 'Zobraziť')]
${TEXT_LOCATOR}  //div[@class='mr-[100px] font-semibold lowercase text-[rgba(235,235,245,.6)] xs:mr-1']

*** Test Cases ***
Seller check
    [Documentation]  Vyfiltruje v kazdom inpute moznost a porovná vysledky v buttne s vyhladanymi vysledkami
    Disable Insecure Request Warnings
    Create Session  vyhladavanie  ${Base_URL}  verify=False
    ${response}  GET On Session  vyhladavanie  /
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${Base_URL}  chrome
    Maximize Browser Window
    Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded
    Perform Login Desktop
    Scroll Down To Load Content 1 time
    Using A Filter HP For Search Agent
    Save A New Search Agent
    Detele A Search Agent
    Sleep  ${SLEEP_TIME}
    Wait Until Page Is Fully Loaded Ecv Part
    Get All Links And Check Status For All Pages
    Fail Test If Broken Links Exist
    Log All Valid Links

*** Keywords ***
Using A Filter HP For Search Agent
    Wait Until Page Is Fully Loaded
    Log To Console  Začínam vyhľadávanie
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov bez filtra: ${button_text_show}
    Select Brand From Dropdown And Close Listbox  Škoda
    Click At Coordinates  100  100
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov so značkou: ${button_text_show}
    Select Model From Dropdown And Close Listbox  Octavia
    Click At Coordinates  100  100
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s modelom: ${button_text_show}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Button text: ${button_text_show}
    Scroll Element Into View  //select[@name='yearFrom']
    Select Year From Dropdown  2022
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov od roku: ${button_text_show}
    Scroll Element Into View  //select[@name='priceFrom']
    Select Price From Dropdown  8000
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov od ceny: ${button_text_show}
    Scroll Element Into View  //select[@name='fuel']
    Select Fuel From Dropdown  Benzín
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s karosériou: ${button_text_show}
    Check Sk Location Checkbox  CZ
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov pre Slovensko: ${button_text_show}
    Log To Console  Končím vyhľadávanie a spúšťam výsledky
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]

Wait For Element And Compare Values
    [Arguments]  ${button_locator}  ${text_locator}
    [Documentation]  Počká, kým sa zobrazí element, a potom porovná jeho hodnotu s iným textovým elementom.
    Wait Until Element Is Visible  ${button_locator}
    ${button_text_show}=  Get Text  ${button_locator}
    Wait Until Element Is Visible  ${text_locator}
    ${results_text}=  Get Text  ${text_locator}
    Should Be Equal As Numbers  ${button_text_show}  ${results_text}

Save A New Search Agent
    Sleep  ${SLEEP_TIME}
    Wait Until Page Is Fully Loaded
    Wait Until Element Is Visible  //span[@class='ml-2' and contains(text(), 'Uložiť hľadanie')]
    Click Element Using JavaScript  //span[@class='ml-2' and contains(text(), 'Uložiť hľadanie')]
    Log To Console  Klikám na uloženie hľadania
    Wait Until Element Is Visible  //input[@type='text' and @name='title' and @placeholder='Moje obľúbené vyhľadávanie č.1']
    Log To Console  Zobrazí sa modal pre uloženie
    Click Element Using JavaScript  //input[@type='text' and @name='title' and @placeholder='Moje obľúbené vyhľadávanie č.1']
    Log To Console  Klikne sa modal pre uloženie - názov
    Input Text Slowly  //input[@type='text' and @name='title' and @placeholder='Moje obľúbené vyhľadávanie č.1']  ${SEARCH_AGENT_NAME}
    Log To Console  Vypíše sa modal pre uloženie - názov
    Click Element Using JavaScript  //select[@name='schedule']
    Log To Console  Klikne sa modal pre uloženie - frekvencia
    Select From List By Value  //select[@name='schedule']  0
    Log To Console  Vyberie sa modal pre uloženie - názov - Posielať ihneď
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //button[@type='submit' and contains(text(), 'Uložiť hľadanie')]
    Capture Page Screenshot
    Log To Console  Idem uložiť hľadanie - tlačidlo je viditeľné
    Click Element  //button[@type='submit' and contains(text(), 'Uložiť hľadanie')]
    Log To Console  Hľadanie uložené.
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //button[@class='button-search mt-7' and contains(text(), 'Rozumiem')]
    Sleep  ${SLEEP_TIME}
    Log To Console  Potvrdzujem, že rozumiem.
    Click Element  //button[@class='button-search mt-7' and contains(text(), 'Rozumiem')]
    Log To Console  Klikám, že rozumiem.
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='mb-2 hidden h-[44px] w-full items-center justify-evenly rounded-[8px] bg-[#002973] text-[14px] font-medium lg:flex']
    Click Element  //a[contains(@href, '/sk/users.php?act=preferences')]
    Log To Console  Klikli sme na "Uložené hľadania"

Detele A Search Agent
    Wait Until Page Is Fully Loaded Ecv Part
    Log To Console  brm
    Wait Until Element Is Visible  //a[@title='Zmazať']
    Click Element  //a[@title='Zmazať' and @data-modal-plt-name='Moje hľadanie']
    Sleep  ${SLEEP_TIME}
    Log To Console  Klikli sme na link "Zmazať"
    Handle Alert  ACCEPT
    Log To Console  Upozornenie spracované.
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //a[@class='modal-button' and contains(text(), 'Rozumiem')]  10s
    Sleep  ${SLEEP_TIME}
    Log To Console  Potvrdzujem, že rozumiem.
    Click Element  //a[@class='modal-button' and contains(text(), 'Rozumiem')]
    Log To Console  Klikám, že rozumiem.
