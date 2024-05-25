*** Settings ***
Library           SeleniumLibrary
Library           RequestsLibrary

*** Test Cases ***
Predajcovia page load
    [Tags]    basic test predajca    load    smoke
    Open Browser    https://www.autobazar.eu/predajcovia-aut/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    ${response}=    GET    https://www.autobazar.eu/predajcovia-aut/    params=query=ciao    expected_status=200
    Close Browser

Home page load
    [Tags]    basic test HP    load    smoke
    Open Browser    https://www.autobazar.eu/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    ${response}=    GET    https://www.autobazar.eu/    params=query=ciao    expected_status=200
    Close Browser

Nové autá page load
    [Tags]    basic test NA    load    smoke
    Open Browser    https://www.autobazar.eu/vysledky-nove-auta/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    ${response}=    GET    https://www.autobazar.eu/vysledky-nove-auta/    params=query=ciao    expected_status=200
    Close Browser

Na dovoz page load
    [Tags]    basic test dovoz    load    smoke
    Open Browser    https://www.autobazar.eu/vysledky-na-dovoz/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    ${response}=    GET    https://www.autobazar.eu/vysledky-na-dovoz/    params=query=ciao    expected_status=200
    Close Browser

Fórum page load
    [Tags]    basic test forum    load    smoke
    Open Browser    https://forum.autobazar.eu/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    ${response}=    GET    https://forum.autobazar.eu/    params=query=ciao    expected_status=200
    Close Browser

Magazín page load
    [Tags]    basic test magazin    load    smoke
    Open Browser    https://magazin.autobazar.eu/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    ${response}=    GET    https://magazin.autobazar.eu/    params=query=ciao    expected_status=200
    Close Browser

Detail PJC funkcna cast
    [Tags]    basic test predajca    inzerat    smoke
    Open Browser    https://www.autobazar.eu/predajcovia-aut/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    Unselect Frame
    Wait Until Page Contains Element    //input[contains(@placeholder, 'Napíšte hľadaný výraz')]    timeout=10s
    ${search_field}=    Get WebElement    //input[contains(@placeholder, 'Napíšte hľadaný výraz')]
    Set Window Position    x=341    y=169
    Set Window Size    width=1935    height=1090
    Close Browser

Detail PJC funkcna cast s logmi
    [Tags]    basic test predajca    inzerat    smoke
    Log    Toto je moj logovaci zaznam.
    Open Browser    https://www.autobazar.eu/predajcovia-aut/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    Unselect Frame
    Wait Until Page Contains Element    //input[contains(@placeholder, 'Napíšte hľadaný výraz')]    timeout=10s
    ${search_field}=    Get WebElement    //input[contains(@placeholder, 'Napíšte hľadaný výraz')]
    Set Window Position    x=341    y=169
    Set Window Size    width=1935    height=1090
    ${premenna}=    set variable    Hello, world!
    Log    Toto je moj logovaci zaznam koncek
    Close Browser    # Zatvorí prehliadač

Detail PJC funkcne bolo ale uz nie je
    [Tags]    basic test predajca    inzerat    smoke
    Open Browser    https://www.autobazar.eu/predajcovia-aut/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    Unselect Frame
    Wait Until Page Contains Element    //input[contains(@placeholder, 'Napíšte hľadaný výraz')]    timeout=10s
    ${search_field}=    Get WebElement    //input[contains(@placeholder, 'Napíšte hľadaný výraz')]
    Click Element    ${search_field}
    Wait Until Element Is Visible    ${search_field}
    Input Text    ${search_field}    AAA
    Sleep    3s
    Wait Until Element Is Enabled    //*[@id="__next"]/div[2]/main/div/div/div[5]/form/div/div/button
    Click Button    //*[@id="__next"]/div[2]/main/div/div/div[5]/form/div/div/button
    Sleep    6s
    Wait Until Page Contains Element    //*[@id="__next"]/div[2]/main/div/div/div[10]/div[1]/div[1]/div/div[1]    3s
    Click Element    //*[@id="__next"]/div[2]/main/div/div/div[10]/div[1]/div[1]/div/div[1]
    Sleep    3s
    ${current_url}=    Get Location
    Should Be Equal As Strings    ${current_url}    https://www.autobazar.eu/predajca/aaabanskabystrica/
    Set Window Position    x=341    y=169
    Set Window Size    width=1935    height=1090
    Close Browser

Detail PJC prac verzia
    [Tags]    basic test predajca    inzerat    smoke
    Open Browser    https://www.autobazar.eu/predajcovia-aut/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    Unselect Frame
    Wait Until Page Contains Element    //input[contains(@placeholder, 'Napíšte hľadaný výraz')]    timeout=10s
    ${search_field}=    Get WebElement    //input[contains(@placeholder, 'Napíšte hľadaný výraz')]
    Click Element    //*[@id="__next"]/div[2]/main/div/div/div[5]/form/div/div/div[1]/input
    Input Text    //*[@id="__next"]/div[2]/main/div/div/div[5]/form/div/div/div[1]/input    AAA AUTO - BANSKÁ BYSTRICA
    Sleep    3s
    Click Element    //*[@id="__next"]/div[2]/main/div/div/div[5]/form/div/div/button[span[text()='Zobraziť']]
    Wait Until Element Is Visible    //*[@id="__next"]/div[2]/main/div/div/div[5]/form/div/div/button[span[text()='Zobraziť']]
    Sleep    6s
    Wait Until Page Contains Element    //*[@id="__next"]/div[2]/main/div/div/div[10]/div/div[1]/div/div[1][contains(text(),'AAA AUTO - BANSKÁ BYSTRICA')]    timeout=20s
    Click Element    //*[@id="__next"]/div[2]/main/div/div/div[10]/div/div[1]/div/div[1][contains(text(),'AAA AUTO - BANSKÁ BYSTRICA')]
    Sleep    3s
    ${current_url}=    Get Location
    Log    ${current_url}
    Location should be    https://www.autobazar.eu/predajca/aaabanskabystrica/
    Set Window Position    x=341    y=169
    Set Window Size    width=1935    height=1090
    Close Browser

Detail pjc gpt help
    Open Browser    https://www.autobazar.eu/predajcovia-aut/    chrome
    Sleep    6s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    Unselect Frame
    Wait Until Page Contains Element    //input[contains(@placeholder, 'Napíšte hľadaný výraz')]    timeout=10s
    ${search_field}=    Execute JavaScript    return document.querySelector("input[placeholder*='Napíšte hľadaný výraz']")
    Set Window Position    x=341    y=169
    Set Window Size    width=1935    height=1090
    Wait Until Element Is Visible    ${search_field}
    Execute JavaScript    arguments[0].value = "AAA";
    Sleep    3s
    ${button}=    Execute JavaScript    return document.evaluate("//*[text()='Hľadať']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    Click Element    ${button}
    Sleep    6s
    Wait Until Page Contains Element    //*[@id="__next"]/div[2]/main/div/div/div[10]/div[1]/div[1]/div/div[1]    3s
    Click Element    //*[@id="__next"]/div[2]/main/div/div/div[10]/div[1]/div[1]/div/div[1]
    Sleep    3s
    ${current_url}=    Get Location
    Should Be Equal As Strings    ${current_url}    https://www.autobazar.eu/predajca/aaabanskabystrica/

Prihlásenie a pridanie do obľúbených
    [Tags]    basic test    login    oblubene    smoke
    Open Browser    https://www.autobazar.eu/    chrome
    Sleep    3s
    Select Frame    //iframe[@title='SP Consent Message']
    Click Element    //button[@title='Prijať všetko']
    Sleep    3s
    Click Button    (//button[@class='flex'])[1]
    Sleep    3s
    set window position    x=341    y=169
    set window size    width=1935    height=1090
    Close Browser

Example Test
    Log    Toto je moj logovaci zaznam.

*** Keywords ***
Log Element Text
    [Arguments]    ${locator}
    ${element_text}=    Get Text    ${locator}
    Log    Text elementu: ${element_text}
