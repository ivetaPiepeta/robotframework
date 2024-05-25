*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem

*** Variables ***
${Base_URL}  https://www.autobazar.eu/
@{Dealer_Pages}  /predajcovia-aut/  /vysledky-nove-auta/  /vysledky-na-dovoz/

*** Test Cases ***
Open Browser And Check Statuses
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
    Create Session  autobazar  ${Base_URL}
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${Base_URL}  chrome
    Maximize Browser Window
    Switch To Frame And Accept All
    Unselect Frame
    FOR  ${page}  IN  @{Dealer_Pages}
        ${response}  GET On Session  autobazar  ${Base_URL}${page}
        Wait Until Page Contains Element  //body
        Log  HTTP status kód pre ${Base_URL}${page} je: ${response.status_code}
        Should Be Equal As Numbers  ${response.status_code}  200
    END
    [Teardown]  Close Browser

*** Keywords ***

Switch To Frame And Accept All
    Wait Until Page Contains Element  //iframe[@title='SP Consent Message']
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Unselect Frame
