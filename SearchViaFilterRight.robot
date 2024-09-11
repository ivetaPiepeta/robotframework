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
    Using A Filter HP And Right Side
    Sleep  ${SLEEP_TIME}
    Wait Until Page Is Fully Loaded
    Scroll Down To Load All Content
    GetAllPageHrefs
    Remove Duplicates From List
    Log Total Links Found
    CheckHrefsStatus

*** Keywords ***

Using A Filter HP And Right Side
    Wait Until Page Is Fully Loaded
    Log To Console  Začínam vyhľadávanie
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov bez filtra: ${button_text_show}
    Select Brand From Dropdown And Close Listbox  Škoda
    Click At Coordinates  100  100
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov so značkou: ${button_text_show}
    Log To Console  Končím vyhľadávanie a spúšťam výsledky
    Sleep  ${SLEEP_TIME}
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]
    Sleep  ${SLEEP_TIME}
    Set Price From Input  ${PRICE_FROM}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov so cenou od: ${button_text_show}
    Set Price To Input  ${PRICE_TO}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov so cenou do: ${button_text_show}
    Set Km From Input  ${KM2}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s km od: ${button_text_show}
    Set Km To Input  ${KM3}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s km do: ${button_text_show}
    Set Year From Input  ${YEAR_FROM}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s rokom od: ${button_text_show}
    Set Year To Input  ${YEAR_TO}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s rokom do: ${button_text_show}
    Check Diesel Checkbox  ${FUEL}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s ${FUEL}: ${button_text_show}
    Check Combi Checkbox  ${BODYWORK}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s ${FUEL}: ${button_text_show}
    Check Gearbox Checkbox  ${GEARBOX}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s ${GEARBOX} prevodovka: ${button_text_show}
    Check Drive Checkbox  ${DRIVE}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov ${DRIVE} pohon: ${button_text_show}