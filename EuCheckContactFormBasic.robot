*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem
Resource  SharedKeywords.robot

*** Variables ***
${URL_inzerat1}  https://www.autobazar.eu/detail/dacia-duster-test115-blue-dci-115-prestige-4x4/31262521/
${CALL_BUTTON_XPATH}  //*[@id="headlessui-dialog-title-:r2:"]


*** Test Cases ***
The click to call will display the phone number
    [Documentation]  Overí, že kliknutie na tlačidlo "Zavolať" zobrazí správne telefónne číslo.
    Open Browser  ${URL_inzerat1}  chrome
    Maximize Browser Window
    Switch To Frame And Accept All
    Click Call Button
    Verify Phone Number Displayed
    Close Browser

*** Keywords ***
Accept Cookies
    [Documentation]  Akceptuje cookies nastavenia na stránke.
    Click Button  xpath=//button[contains(text(), 'Prijať všetko')]

Click Call Button
    [Documentation]  Klikne na tlačidlo "Zavolať".
    Wait Until Element Is Visible  xpath=//button[contains(text(), 'Zavolať')][1]
    Click Element Using JavaScript  xpath=//button[contains(text(), 'Zavolať')][1]

Verify Phone Number Displayed
    [Documentation]  Overí, že sa zobrazí správny text pre telefónne číslo.
    Wait Until Element Is Visible  ${CALL_BUTTON_XPATH}
    Element Text Should Be  ${CALL_BUTTON_XPATH}  Zavolajte predajcovi
    Wait Until Element Is Visible  xpath=//a[contains(@href, 'tel:0914 111 115')]
    Element Text Should Be  xpath=//a[contains(@href, 'tel:0914 111 115')]  0914 111 115

Click Element Using JavaScript
    [Arguments]  ${xpath}
    Execute JavaScript  document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()