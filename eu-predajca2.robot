*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    Collections
Suite Setup    Open Browser To Predajcovia Aut
Suite Teardown    Close Browser

*** Variables ***
${BASE_URL}    https://www.autobazar.eu/predajcovia-aut/

*** Test Cases ***
Check All Links On Predajcovia Aut Page
    [Documentation]    Test overuje, či sú všetky odkazy na stránke /predajcovia-aut/ funkčné.
    Handle Consent Elements
    Click And Search For Impa Ziar Nad Hronom
    Scroll Down And Click Show Button
    ${links}    Get All Links On Page
    FOR    ${link}    IN    @{links}
        ${is_http}    Run Keyword And Return Status    Should Start With    ${link}    http
        Run Keyword If    ${is_http}    Check Link    ${link}
    END

*** Keywords ***
Open Browser To Predajcovia Aut
    Open Browser    ${BASE_URL}    chrome
    Maximize Browser Window
    Wait Until Page Contains Element    //a    10s

Handle Consent Elements
    [Documentation]    Potvrdí iframe s oznámením o ochrane osobných údajov, ak existuje.
    Wait Until Page Contains Element    xpath=//iframe[@id='sp_message_iframe_1090194']    10s
    Select Frame    xpath=//iframe[@id='sp_message_iframe_1090194']
    Wait Until Page Contains Element    xpath=//button[@title='Prijať všetko']    10s
    Click Button    xpath=//button[@title='Prijať všetko']
    Unselect Frame
    Sleep    2s

Click And Search For Impa Ziar Nad Hronom
    [Documentation]    Klikne na pole 'Napíšte hľadaný výraz', počká a napíše text 'Impa Žiar nad Hronom'.
    Wait Until Page Contains Element    xpath=//input[@placeholder='Napíšte hľadaný výraz']    10s
    Click Element    xpath=//input[@placeholder='Napíšte hľadaný výraz']
    Sleep    1s
    Input Text    xpath=//input[@placeholder='Napíšte hľadaný výraz']    Impa Žiar nad Hronom
    Sleep    1s

Scroll Down And Click Show Button
    Execute JavaScript    window.scrollBy(0, 500)
    Wait Until Element Is Visible    xpath=//button[contains(., 'Zobraziť')]    10s
    Wait Until Element Is Enabled    xpath=//button[contains(., 'Zobraziť')]    10s
    Click Button    xpath=//button[contains(., 'Zobraziť')]
    Sleep    2s
    Execute JavaScript    window.scrollBy(0, 500)
    Sleep    2s
    Wait Until Element Is Visible    xpath=//h3[contains(., 'IMPA Žiar nad Hronom s.r.o.')]    10s
    Click Element    xpath=//h3[contains(., 'IMPA Žiar nad Hronom s.r.o.')]/a
    Sleep    2s

Get All Links On Page
    ${links}    SeleniumLibrary.Get All Links
    [RETURN]    ${links}

Check Link
    [Arguments]    ${url}
    ${response}    GET On Session    ${url}
    Log    HTTP status kód pre ${url} je: ${response.status_code}
    Should Be Equal As Numbers    ${response.status_code}    200

Check Current URL And HTTP Status Code
    [Documentation]    Test overuje, či sa nachádzate na URL "https://www.autobazar.eu/predajca/impaziar/" a či server vracia HTTP status kód 200.
    ${current_url}    Get Location
    Should Be Equal    ${current_url}    https://www.autobazar.eu/predajca/impaziar/
    Sleep    5s
    Execute JavaScript    window.scrollBy(0, 1000)
    Sleep    5s

Click First Element In Section
    [Documentation]    Skroluje dolu a klikne na prvý element v sekcii inzerátov predajcu.
    ${first_element_url}    Get Element Attribute    xpath=//div[@class="mt-8 flex min-h-[122px] w-full justify-between gap-0.5 md:min-h-[192px] flex-row"]/a[1]    href
    Wait Until Element Is Visible    xpath=//div[@class="mt-8 flex min-h-[122px] w-full justify-between gap-0.5 md:min-h-[192px] flex-row"]/a[1]    10s
    Wait Until Element Is Enabled    xpath=//div[@class="mt-8 flex min-h-[122px] w-full justify-between gap-0.5 md:min-h-[192px] flex-row"]/a[1]    10s
    Click Element    xpath=//div[@class="mt-8 flex min-h-[122px] w-full justify-between gap-0.5 md:min-h-[192px] flex-row"]/a[1]
    Sleep    5s

