*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem
Resource  SharedKeywords.robot

*** Variables ***
${URL}     https://www.autobazar.eu/detail-nove-auto/dacia-duster-15-blue-dci-115-extreme-4x4/31393475/
${BUTTON_TEXT_CALL}    Zavolať
${BUTTON_TEXT_WRITE}    Napísať
${BUTTON_TEXT_VISIT}    Navštíviť
${PARENT_CLASS}    hidden lg:grid lg:grid-cols-3 lg:gap-4 lg:px-6 lg:pb-5
${BUTTON_TEXT}     Zavolať
${BUTTON_XPATH}    //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT}']
${TOP_NAV_FORM_XPATH}    //button[contains(@class, 'btn-cta') and text()='Kontaktovať predajcu']
${CONTACT_BUTTON_SELECTOR}    //div[@id="headlessui-dialog-panel-:rj:"]//button[text()='Zavolať']
*** Test Cases ***
Click Visible "Zavolať" Button And Check Content
    Open Browser    ${URL}    chrome
    Maximize Browser Window
    Wait Until Page Is Fully Loaded
    Switch To Frame And Accept All
    Scroll Down To Load Content 2 times
    Click Element Using JavaScript  ${TOP_NAV_FORM_XPATH}
    Wait Until Page Contains Element    ${CONTACT_BUTTON_SELECTOR}
    Click Element Using JavaScript  ${CONTACT_BUTTON_SELECTOR}
    Log to console  bac
