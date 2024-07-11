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
${PHONE_NUMBER}    0914 166 639
${TOP_NAV_FORM_XPATH}    //button[contains(@class, 'btn-cta') and text()='Kontaktovať predajcu']
${CONTACT_BUTTON_SELECTOR}    //button[contains(text()='${BUTTON_TEXT_CALL}')]
${BUTTON_XPATH_CALL}     //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT_CALL}']
${BUTTON_XPATH_WRITE}    //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT_WRITE}']
${BUTTON_XPATH_VISIT}    //div[contains(@class, '${PARENT_CLASS}')]//button[text()='${BUTTON_TEXT_VISIT}']

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
    Scroll To Buttons    ${BUTTON_XPATH_CALL}    ${BUTTON_XPATH_WRITE}    ${BUTTON_XPATH_VISIT}
    Log To Console  Click All Buttons And Verify Content3

    Wait Until Page Contains Element    ${BUTTON_XPATH_CALL}
    Log To Console  Click All Buttons And Verify Content41
    Click Element    ${BUTTON_XPATH_CALL}
    Log To Console  Click All Buttons And Verify Content42
    Check Phone Number  ${PHONE_NUMBER}
    Log To Console  Click All Buttons And Verify Content43
    Return To Main Page  ${BUTTON_XPATH_CALL}
    Log To Console  Click All Buttons And Verify Content432
    Wait Until Page Contains Element    ${BUTTON_XPATH_WRITE}
    Log To Console  Click All Buttons And Verify Content44
    Click Element    ${BUTTON_XPATH_WRITE}
    Return To Main Page  ${BUTTON_XPATH_CALL}
    Log To Console  Click All Buttons And Verify Content45
    Wait Until Page Contains Element    ${BUTTON_XPATH_VISIT}
    Log To Console  Click All Buttons And Verify Content46
    Click Element    ${BUTTON_XPATH_VISIT}
    Log To Console  Test case completed: Click All Buttons And Verify Content


*** Keywords ***

Click Element Using JavaScript
    [Arguments]  ${xpath}
    ${xpath}=    Set Variable    //input[contains(@id, '${BUTTON_TEXT_CALL}')]
    Execute JavaScript  document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Sleep  ${SLEEP_TIME}

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
    Log To Console  Button1
    Wait Until Element Is Visible    ${phone_xpath}
    Log To Console  Button2
    ${actual_phone_number}=    Get Text    ${phone_xpath}
    Log To Console  Retrieved phone number: ${actual_phone_number}
    Should Be Equal    ${actual_phone_number}  ${phone_number}

Verify All Buttons And Phone Number
    Click Button And Verify Response    ${BUTTON_TEXT_CALL}

Scroll To Buttons
    [Arguments]  ${button_xpath_call}  ${button_xpath_write}  ${button_xpath_visit}
    Scroll Element Into View    ${button_xpath_call}
    Scroll Element Into View    ${button_xpath_write}
    Scroll Element Into View    ${button_xpath_visit}

Return To Main Page
    [Arguments]  ${main_page_element_xpath}
    Close Browser  # Zatvorí aktuálny prehliadač
    Open Browser    ${URL}    chrome
    Maximize Browser Window
    Wait Until Page Is Fully Loaded
    Switch To Frame And Accept All
    Scroll To Buttons    ${BUTTON_XPATH_CALL}    ${BUTTON_XPATH_WRITE}    ${BUTTON_XPATH_VISIT}