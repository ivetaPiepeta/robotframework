*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem

*** Variables ***
${Base_URL}  https://www.autobazar.eu/
@{Dealer_Pages}  /predajcovia-aut/  /vysledky-nove-auta/

*** Test Cases ***
Open Browser And Check Status
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
    Create Session  autobazar  ${Base_URL}
    ${response}  GET On Session  autobazar  /
    Log  HTTP status kód je: ${response.status_code}
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${Base_URL}  chrome
    Maximize Browser Window
    Run Keyword And Continue On Failure  Wait Until Page Contains Element  //iframe  2s
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
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Unselect Frame
