*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem
Resource  SharedKeywords.robot

*** Variables ***
${URL}     https://www.autobazar.eu/detail/dacia-duster-15-blue-dci-115-prestige-4x4/31419005/
${BUTTON_TEXT_CALL}  Zavolať
${BUTTON_TEXT_WRITE}  Napísať
${BUTTON_TEXT_VISIT}  Navštíviť
${PARENT_CLASS}    mt-[16px] grid grid-cols-3 gap-4
${PHONE_NUMBER}    0914166639
${BUTTON_XPATH}    //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT_CALL}']
${TOP_NAV_FORM_XPATH}    //button[contains(@class, 'btn-cta') and text()='Kontaktovať predajcu']
${CONTACT_BUTTON_SELECTOR}    //button[contains(text()='${BUTTON_TEXT_CALL}')]

*** Test Cases ***
Click All Buttons And Verify Content
    [Documentation]  Tento test otvorí v prehliadači inzerát a overí funkčnosť buttonu v spodnej časti Zalovať, Napísať a Navštíviť.
    Log To Console  Starting test case: Click All Buttons And Verify Content
    Open Browser    ${URL}    chrome
    Maximize Browser Window
    Wait Until Page Is Fully Loaded
    Log To Console  Click All Buttons And Verify Content1
    Switch To Frame And Accept All
    Log To Console  Click All Buttons And Verify Content2
    Scroll Down To Load Content 7 times
    Log To Console  Click All Buttons And Verify Content3
    Verify All Buttons And Phone Number
    Log To Console  Click All Buttons And Verify Content4
    Log To Console  Test case completed: Click All Buttons And Verify Content

*** Keywords ***

Click Element Using JavaScript
    [Arguments]  ${xpath}
    ${xpath}=    Set Variable    //input[contains(@id, '${BUTTON_TEXT_CALL}')]
    Execute JavaScript  document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Sleep  ${SLEEP_TIME}

Click Button And Verify Response
    [Arguments]  ${button_text}
    Log To Console  Clicking button with text "${button_text}" and verifying response
    ${button_xpath}=    Set Variable    //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT_CALL}']
    Wait Until Element Is Visible    ${button_xpath}
    Click Element Using JavaScript    ${button_xpath}
    ${url}=    Get Location
    Log To Console  Verifying response for URL: ${url}
    ${response}=    Request  GET  ${url}
    Should Be Equal As Numbers  ${response.status_code}  200
    Log To Console  Button "${button_text}" returned status code ${response.status_code}

Check Phone Number
    Log To Console  Checking phone number for button "Zavolať"
    ${phone_xpath}=    Set Variable    //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT_CALL}']
    Wait Until Element Is Visible    ${phone_xpath}
    Click Element Using JavaScript    ${phone_xpath}
    ${phone_number}=    Get Text    ${phone_xpath}/following-sibling::span
    Log To Console  Retrieved phone number: ${phone_number}
    Should Be Equal    ${phone_number}  ${PHONE_NUMBER}

Verify All Buttons And Phone Number
    Click Button And Verify Response    ${BUTTON_TEXT_CALL}


