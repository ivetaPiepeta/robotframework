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
${Search_Term}  ABS
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
    Scroll Down To Load Content 1 time
    Using A Filter HP
    Sleep  ${SLEEP_TIME}
    Wait Until Page Is Fully Loaded
    Scroll Down To Load All Content
    GetAllPageHrefs
    Remove Duplicates From List
    Log Total Links Found
    CheckHrefsStatus

*** Keywords ***
Using A Filter HP
    Wait Until Page Is Fully Loaded
    Log To Console  Začínam vyhľadávanie
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov bez filtra: ${button_text_show}
    Select Brand From Dropdown And Close Listbox  Škoda
    Click At Coordinates  100  100
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov so značkou: ${button_text_show}
    Select Model From Dropdown And Close Listbox  Octavia Combi
    Click At Coordinates  100  100
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s modelom: ${button_text_show}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Button text: ${button_text_show}
    Scroll Element Into View  //select[@name='yearFrom']
    Select Year From Dropdown  2020
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov od roku: ${button_text_show}
    Scroll Element Into View  //select[@name='priceFrom']
    Select Price From Dropdown  7000
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov od ceny: ${button_text_show}
    Scroll Element Into View  //select[@name='fuel']
    Select Fuel From Dropdown  Diesel
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s palivom: ${button_text_show}
    Input Value Km Into Dropdown  ${KM}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s najazdenými: ${button_text_show}
    Select Bodywork  Combi
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s karosériou: ${button_text_show}
    Check Sk Location Checkbox  SK
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov pre Slovensko: ${button_text_show}
    Log To Console  Končím vyhľadávanie a spúšťam výsledky
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]