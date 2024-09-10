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
${ADD_AD_URL_MOTOR}        /pridat-inzerat/motocykle/zakladne-udaje
${ADD_AD_CLASS}      item
${ADD_AD_DIV_CLASS}  bg-icon
${XPATH_INPUT}  //input[@type='text' and @name='VIN' and @id='vindiv']
${CAR_BRAND_SELECTOR}    //select[@name='CarBrandID']
${CAR_BRAND_OPTION}   Adamoto
${UPLOAD_BUTTON}  //button[@type='button' and contains(@class, 'form-action-link') and contains(@class, 'data-button-upload-photos') and contains(@class, 'dz-clickable') and text()='nahrajte']
${UPLOAD_INPUT_XPATH}  //input[@type='file' and @name='fotoDacia']
${CHECKBOX_XPATH}  //input[@type='checkbox' and @name='acceptterms' and @id='contact-advertising-conditions']
${ADD_AD_LINK}  //a[@href='/pridat-inzerat/motocykle/zakladne-udaje' and contains(@class, 'item')]

*** Test Cases ***
Login And Create A New Advertisiment
    [Documentation]  Tento test otvorí prehliadač, načíta stránku, zaloguje usera a pridá inzerát s fotografiou.
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
    Add With No Ecv Desktop
    Choose A Model Starfinger
    Price Part Motorcycle
    Upload An Image
    Click Next Button Desktop
    Confirm Checkbox Add Ad
    Check Adding Of Adv
    Sleep  ${SLEEP_TIME}
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist




