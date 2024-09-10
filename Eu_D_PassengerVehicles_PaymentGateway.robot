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
${ADD_AD_URL}        /pridat-inzerat/osobne-vozidla/zakladne-udaje
${ADD_AD_CLASS}      item
${ADD_AD_DIV_CLASS}  bg-icon
${XPATH_INPUT}  //input[@type='text' and @name='VIN' and @id='vindiv']
${XPATH_GATE}  //div[@class='p-package swiper-slide']//form[@id='overenaklasikaForm']
${XPATH_PAY_OPTIONS}  //a[@class='payment-options' and @data-toggle-payment-options='packagemodal1' and text()='Ďalšie možnosti platby']
${XPATH_TRUSTPAY}  //div[@class='option']//button[@class='btn btn-card' and contains(text(), 'Zaplatiť kartou')]

*** Test Cases ***
Login And Create A New Advertisiment
    [Documentation]  Tento test otvorí prehliadač, načíta stránku, zaloguje usera, pridá inzerát s fotografiou a chce pokračovať na úhradu inzerátu.
    Run Test With Resolution

*** Keywords ***
Run Test With Resolution
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
    Disable Insecure Request Warnings
    Create Session  autobazar  ${Base_URL}  verify=False
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${Base_URL}  chrome
    Maximize Browser Window
    Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded
    Perform Login Desktop
    Add A New Advertisiment Desktop
    Add Ecv
    Choose A Model Prestige
    Delete VIN
    Price Part
    Upload An Image  ${image_path}
    Click Next Button Desktop
    Confirm Checkbox Add Ad
    Check Adding Of Adv
    Go To Gateway
    Sleep  ${SLEEP_TIME}
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist