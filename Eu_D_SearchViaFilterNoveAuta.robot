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

*** Test Cases ***
Open Browser And Check Statuses of hrefs on Desktop
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód na desktope.
    Run Test With Resolution    ${DESKTOP_WIDTH}    ${DESKTOP_HEIGHT}

*** Keywords ***
Using A Filter NA
    Wait Until Page Is Fully Loaded
    Log To Console  Začínam vyhľadávanie
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov bez filtra: ${button_text_show}
    Select Brand From NA Dropdown And Close Listbox  Škoda
    Click At Coordinates  100  100
    Sleep  ${SLEEP_TIME}
    Click At Coordinates  100  100
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov so značkou: ${button_text_show}
    Select Model From NA Dropdown And Close Listbox  Kamiq
    Click At Coordinates  100  100
    Sleep  ${SLEEP_TIME}
    Click At Coordinates  100  100
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s modelom: ${button_text_show}
    Sleep  ${SLEEP_TIME}
    Scroll Element Into View  //button[@class='absolute inset-y-0 right-0 flex items-center pr-1 disabled:cursor-not-allowed disabled:opacity-60 pr-2']
    Set Price From Input  ${PRICE_FROM}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov od ceny: ${button_text_show}
    Log To Console  Končím vyhľadávanie a spúšťam výsledky
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Potvrdiť')]

Select Brand From NA Dropdown And Close Listbox
    [Arguments]  ${brand}
    ${button_xpath}=    Set Variable  //button[.//span[text()='Potvrdiť']]
    ${listbox_xpath}=    Set Variable  //div[@class='scrollbar mt-[70px] h-60 w-full overflow-auto bg-[#002466] px-3 py-1 text-sm']
    Wait Until Element Is Visible  //button[contains(@class, 'relative w-full rounded-[8px] border-none p-4 text-left text-[16px] font-medium text-white disabled:cursor-not-allowed bg-[#EBEBF518] hover:bg-[#EBEBF532]')]//span[text()='Všetky značky']
    Click Element Using JavaScript  //button[contains(@class, 'relative w-full rounded-[8px] border-none p-4 text-left text-[16px] font-medium text-white disabled:cursor-not-allowed bg-[#EBEBF518] hover:bg-[#EBEBF532]')]//span[text()='Všetky značky']
    Log To Console  Klikám na select so značkami
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='flex space-x-1']//button[picture/img[@alt='${brand}']]
    Click Element Using JavaScript  //div[@class='flex space-x-1']//button[picture/img[@alt='${brand}']]
    Log To Console  Vyberám značku ${brand}
    Sleep  ${SLEEP_TIME}
    Click Button And Wait For Listbox To Close  ${button_xpath}  ${listbox_xpath}
    Log To Console  Zatváram listbox značka
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov so značkou: ${button_text_show}

Select Model From NA Dropdown And Close Listbox
    [Arguments]  ${model}
    ${button_xpath}=    Set Variable  //button[.//span[text()='Potvrdiť']]
    ${listbox_xpath}=    Set Variable  //div[@class='scrollbar mt-[70px] h-60 w-full overflow-auto bg-[#002466] px-3 py-1 text-sm']
    Wait Until Element Is Visible  //button[contains(@class, 'relative w-full rounded-[8px] border-none p-4 text-left text-[16px] font-medium text-white disabled:cursor-not-allowed bg-[#EBEBF518] hover:bg-[#EBEBF532]')]//span[text()='Všetky modely']
    Click Element Using JavaScript  //button[contains(@class, 'relative w-full rounded-[8px] border-none p-4 text-left text-[16px] font-medium text-white disabled:cursor-not-allowed bg-[#EBEBF518] hover:bg-[#EBEBF532]')]//span[text()='Všetky modely']
    Log To Console  Klikám na select modelov
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), '${model}')]
    Click Element Using JavaScript  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), '${model}')]
    Log To Console  Vyberám model ${model}
    Sleep  ${SLEEP_TIME}
    Click At Coordinates  100  100
    Log To Console  Klikám mimo scrollbaru
    Sleep  ${SLEEP_TIME}
    Log To Console  Zatváram listbox model
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s modelom: ${button_text_show}

Run Test With Resolution
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
    [Arguments]  ${width}  ${height}
    Disable Insecure Request Warnings
    Create Session  autobazar  ${URL_NA}  verify=False
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${URL_NA}  chrome
    Set Window Size  ${width}  ${height}
    Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded
    Scroll Down To Load All Content
    Using A Filter NA
    Sleep  ${SLEEP_TIME}
    Wait Until Page Is Fully Loaded
    Scroll Down To Load All Content
    GetAllPageHrefs
    Remove Duplicates From List
    Log Total Links Found
    CheckHrefsStatus
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist