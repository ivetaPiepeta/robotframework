*** Settings ***
# Importuje potrebné knižnice pre testovanie
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem

*** Variables ***
# Definuje základnú URL pre testovanie
${Base_URL}  https://www.autobazar.eu/
# Vytvára prázdny zoznam pre stránky predajcov
@{Dealer_Pages}

*** Test Cases ***
# Definuje testovací prípad na otvorenie prehliadača a kontrolu stavových kódov
Open Browser And Check Statuses
    [Documentation]  Tento test otvorí prehliadač, načíta stránku a overí HTTP status kód.
    # Vytvorí HTTP session pre základnú URL
    Create Session  autobazar  ${Base_URL}
    # Získa HTTP odpoveď pre hlavnú stránku
    ${response}  GET On Session  autobazar  /
    # Zaloguje HTTP status kód odpovede
    Log  HTTP status kód je: ${response.status_code}
    # Overí, že HTTP status kód je 200 (úspešný)
    Should Be Equal As Numbers  ${response.status_code}  200
    # Otvorí prehliadač na základnej URL pomocou prehliadača Chrome
    Open Browser  ${Base_URL}  chrome
    # Maximalizuje okno prehliadača
    Maximize Browser Window
    # Prepne sa do rámca a akceptuje cookies
    Switch To Frame And Accept All
    # Odstráni výber rámca
    Unselect Frame
    # Získa odkazy z prvého zadaného elementu
    GetElementHrefs  //div[@class='hidden min-h-[53px] space-x-3 px-1 py-[10px] leading-[46px] lg:flex']//a
    # Získa odkazy z druhého zadaného elementu
    GetElementHrefs  //div[@class='mb-2 hidden h-[44px] w-full items-center justify-evenly rounded-[8px] bg-[#002973] text-[14px] font-medium lg:flex']//a
    # Po dokončení testu zatvorí prehliadač
    [Teardown]  Close Browser

*** Keywords ***

# Definuje kľúčové slovo na prepnutie do rámca a akceptovanie všetkých cookies
Switch To Frame And Accept All
    # Počká, kým stránka obsahuje element rámca
    Wait Until Page Contains Element  //iframe[@title='SP Consent Message']
    # Vyberie rámec podľa zadaného XPath selektora
    Select Frame    //iframe[@title='SP Consent Message']
    # Klikne na tlačidlo na akceptovanie všetkých cookies
    Click Element    //button[@title='Prijať všetko']
    # Odstráni výber rámca
    Unselect Frame

# Definuje kľúčové slovo na získanie href atribútov zadaného XPath selektora
GetElementHrefs
    [Arguments]    ${xpath_selector}
    # Počká, kým stránka obsahuje element podľa zadaného XPath selektora
    Wait Until Page Contains Element  ${xpath_selector}
    # Získa všetky webové elementy podľa zadaného XPath selektora
    ${links}=    Get WebElements   ${xpath_selector}
    # Pre každý element v zozname elementov
    FOR    ${link}    IN    @{links}
        # Získa href atribút elementu
        ${href}=    Get Element Attribute    ${link}    href
        # Zaloguje href atribút
        Log   ${href}
        # Pridá href atribút do zoznamu stránok predajcov
        Append To List    ${Dealer_Pages}    ${href}
    END
    # Skontroluje stavové kódy pre všetky odkazy
    CheckHrefsStatus

# Definuje kľúčové slovo na kontrolu stavových kódov odkazov
CheckHrefsStatus
    # Pre každý odkaz v zozname stránok predajcov
    FOR  ${page}  IN  @{Dealer_Pages}
        # Získa HTTP odpoveď pre daný odkaz
        ${response}  GET On Session  autobazar  ${Base_URL}${page}
        # Zaloguje HTTP status kód pre daný odkaz
        Log  HTTP status kód pre ${Base_URL}${page} je: ${response.status_code}
        # Overí, že HTTP status kód je 200 (úspešný)
        Should Be Equal As Numbers  ${response.status_code}  200
    END
    # Vyprázdni zoznam stránok predajcov
    Set Variable    @{Dealer_Pages}    @{EMPTY}