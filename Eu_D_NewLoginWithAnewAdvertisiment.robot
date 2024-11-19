*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem
Resource  SharedKeywords.robot

*** Variables ***


*** Test Cases ***
Login And Create A New Advertisiment
    [Documentation]  Tento test otvorí prehliadač, načíta stránku, zaloguje usera, pridá inzerát s fotografiou a chce pokračovať na úhradu inzerátu.
    Run Test With Resolution

*** Keywords ***

Run Test With Resolution
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód. Prihlási sa do konta užívateľa novým spôsobom.
    Disable Insecure Request Warnings
    Create Session  autobazar  ${Base_URL}  verify=False
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${Base_URL}  chrome
    Maximize Browser Window
    Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded
    #Perform New Login Desktop
    Perform Login Desktop 2

    #pokracovanie workovskeho pridania inzeratu po novom:
    Add A New Advertisiment Desktop Prod
    Add Ecv Prod
    #Check My Ečv Work
    #note - Choose A Model Prestige Work
    Basic Data Prod
    Click Next Button Desktop Work
    Vehicle Equipment Work
    Click Next Button Desktop Work
    Name And Condition Of The Vehicle Work
    Click Next Button Desktop Work
    Price Part Work
    Click Next Button Desktop Work
    Upload An Image Work  ${image_path2}
    Click Button Add An Advertisement Desktop Work

    Sleep  ${SLEEP_TIME}
    [Teardown]  Close Browser
    #Fail Test If Broken Links Exist



Perform New Login Desktop
    Sleep  2s
    Wait Until Element Is Visible  //button[.//picture/img[@alt='Prihlásiť'] and .//span[text()='Prihlásiť']]
    Click Element Using JavaScript  //button[.//picture/img[@alt='Prihlásiť'] and .//span[text()='Prihlásiť']]
    Log To Console  Klikám Prihlásiť z HP
    Sleep  1s
    Click Element Using JavaScript  //button[contains(@class, 'rounded-tr-2xl') and contains(@class, 'bg-[#EBEBF514]') and contains(., 'Nové prihlásenie')]
    Log To Console  Vyberám Nové prihlásenie v modalnom okne
    Sleep  1s
    Click Element Using JavaScript  //button[contains(@class, 'btn') and contains(@class, 'flex') and span[text()='Prihlásiť sa']]
    Log To Console  Klikám Prihlásiť cez button s logom - nové prihlásenie od 23.9.2024
    Sleep  1s
    Disable Insecure Request Warnings
    Log To Console  Ignorujem hlášky apky, ktoré mi vyskakujú
    Input Text  //input[@type='email' and @id='username']  ${USERNAME2}
    Input Text  //input[@type='password' and @id='password']  ${PASSWORD2}
    Click Element Using JavaScript  //button[contains(., 'Prihlásiť sa')]
    Sleep  1s
    Log To Console  Korektné prihlásenie do AB.EU - nový spôsob