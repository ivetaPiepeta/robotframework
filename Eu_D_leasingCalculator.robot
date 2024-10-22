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

${CALCULATOR_LOCATOR}  //div[@class='relative space-y-4']/div[@id='calculator' and contains(@class, 'absolute')]
${URL_detail}  https://www.autobazar.eu/detail/
${URL_detail_new}  https://www.autobazar.eu/detail-nove-auto/

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
    Search A Calculator List
    Sleep  ${SLEEP_TIME}
    Log To Console  Mám vyfiltrovanú ponuku vyhovujúcu leasingovej kalkulačke.
    Wait Until Page Is Fully Loaded
    Scroll Down To Load All Content
    @{hrefs}  Get Every Page Hrefs
    @{hrefs}  Remove Duplicates From Listtt  @{hrefs}
    Log Totall Links Found  @{hrefs}
    ${filtered_hrefs}=  Filter Links With Calculator  @{hrefs}
    Log To Console  Filter Links With Calculator?
    Check Links Calculator Presence  @{filtered_hrefs}

*** Keywords ***
Search A Calculator List
    Wait Until Page Is Fully Loaded
    Log To Console  Začínam vyhľadávanie
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov bez filtra: ${button_text_show}
    Scroll Element Into View  //select[@name='yearFrom']
    Select Year From Dropdown  2020
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov od roku: ${button_text_show}
    Scroll Element Into View  //select[@name='priceFrom']
    Select Price From Dropdown  10000
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov od ceny: ${button_text_show}
    Input Value To Km Into Dropdown  ${KM4}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s najazdenými: ${button_text_show}
    Check Sk Location Checkbox  SK
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov pre Slovensko: ${button_text_show}
    Log To Console  Končím vyhľadávanie a spúšťam výsledky
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]

Filter Links With Calculator
    [Documentation]  Vyfiltrujem si url detailov inzerátov s "https://www.autobazar.eu/detail-nove-auto/"
    [Arguments]  @{hrefs}
    Log To Console  Vyfiltrovaný zoznam in progress.
    ${filtered_hrefs}=  Create List
    FOR  ${href}  IN  @{hrefs}
        Run Keyword If  '${href}'.startswith('${URL_detail}') or '${href}'.startswith('${URL_detail_new}')  Append To List  ${filtered_hrefs}  ${href}
    END
    RETURN  ${filtered_hrefs}
    Log To Console  Mám hotový zoznam detailov inzerátov.

Check Links Calculator Presence
    [Documentation]  Otvorí každý zo získaných url a overí prítomnosť kalkulačky
    [Arguments]  @{filtered_hrefs}
    ${window_handles}=  Get Window Handles
    ${original_handle}=  Set Variable  ${window_handles}[0]
    FOR    ${href}  IN  @{filtered_hrefs}
        Open New Tab In Existing Browser  ${href}
        Sleep  ${SLEEP_TIME}
        Wait Until Page Is Fully Loaded
        Scroll Down To Load Content 1 time
        ${is_present}=  Run Keyword And Return Status  Check For Calculator
        Log To Console  Kalkulačka prítomná na ${href}: ${is_present}
        Close Current Tab And Switch Back  ${original_handle}
        Log To Console  cyklus FOR
    END

Open New Tab In Existing Browser
    [Arguments]  ${url}
    Execute JavaScript  window.open("${url}","_blank")
    ${handles}=  Get Window Handles
    Switch Window  ${handles}[-1]
    Log To Console  Open New Tab In Existing Browser

Close Current Tab And Switch Back
    [Documentation]  Close the current browser tab and return to the previous one
    [Arguments]  ${original_handle}
    Close Window
    Switch Window  ${original_handle}
    Log To Console  Close Current Tab And Switch Back

Check For Calculator
    [Arguments]  ${CALCULATOR_LOCATOR}
    Log To Console  Overujem prítomnosť kalkulačky na stránke.
    Run Keyword And Ignore Error  Wait Until Page Contains Element  ${CALCULATOR_LOCATOR}  10s
    ${result}=  Run Keyword And Return Status  Element Should Be Visible  ${CALCULATOR_LOCATOR}
    RETURN  ${result}
    Log To Console  Check For Calculator
