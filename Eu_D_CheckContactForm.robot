*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem
Resource  SharedKeywords.robot

*** Variables ***
${URL}     https://www.autobazar.eu/detail/bmw-x7-xdrive-m50i-a-t/31567177/
${PHONE_NUMBER}    0904 531 939

${PARENT_CLASS}    mt-[16px] grid grid-cols-3 gap-4
${TOP_NAV_FORM_XPATH}    //button[contains(@class, 'btn-cta') and text()='Kontaktovať predajcu']
${CONTACT_BUTTON_SELECTOR}    //button[contains(text()='${BUTTON_TEXT_CALL}')]
${BUTTON_XPATH_CALL}     //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT_CALL}']
${BUTTON_XPATH_WRITE}    //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT_WRITE}']
${BUTTON_XPATH_VISIT}    //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT_VISIT}']

*** Test Cases ***
Open Browser And Check Statuses of hrefs on Desktop
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód na desktope.
    Click All Buttons And Verify Phone Number    ${DESKTOP_WIDTH}    ${DESKTOP_HEIGHT}

*** Keywords ***
Click Element Using JavaScript
    [Arguments]  ${xpath}
    ${xpath}=    Set Variable    //input[contains(@id, '${BUTTON_TEXT_CALL}')]
    Execute JavaScript  document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Sleep  ${SLEEP_TIME}

Click All Buttons And Verify Phone Number
    [Documentation]  Tento test otvorí v prehliadači inzerát a overí funkčnosť buttonu v spodnej časti Zalovať, Napísať a Navštíviť. Overí správnosť tel kontaktu.
    [Arguments]  ${width}  ${height}
    Open Browser    ${URL}    chrome
    Maximize Browser Window
    Wait Until Page Is Fully Loaded
    Log To Console  Starting test case: Click All Buttons And Verify Content
    Switch To Frame And Accept All
    Scroll To Buttons    ${BUTTON_XPATH_CALL}    ${BUTTON_XPATH_WRITE}    ${BUTTON_XPATH_VISIT}
    Wait Until Page Contains Element    ${BUTTON_XPATH_CALL}
    Click Element    ${BUTTON_XPATH_CALL}
    Check Phone Number  ${PHONE_NUMBER}
    Return To Main Page  ${BUTTON_XPATH_CALL}
    Wait Until Page Contains Element    ${BUTTON_XPATH_WRITE}
    Click Element    ${BUTTON_XPATH_WRITE}
    Log To Console  Checking write part
    Return To Main Page  ${BUTTON_XPATH_CALL}
    Wait Until Page Contains Element    ${BUTTON_XPATH_VISIT}
    Click Element    ${BUTTON_XPATH_VISIT}
    Log To Console  Checking visit part
    Log To Console  Test case completed: Click All Buttons And Verify Content
    [Teardown]  Close All Browsers