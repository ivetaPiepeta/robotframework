*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    Collections
Suite Setup    Open Browser To Predajcovia Aut
Suite Setup    Maximize Browser Window
Suite Teardown    Close Browser

*** Variables ***
${BASE_URL}    https://www.autobazar.eu/predajcovia-aut/
&{SELLERS}    IMPA Žiar nad Hronom=impaziar    Autodado=autodado

*** Test Cases ***
Check All Links On Predajcovia Aut Page
    [Documentation]    Test overuje, či sú všetky odkazy na stránke /predajcovia-aut/ funkčné.
    FOR    ${seller_name}    ${seller_url_part}    IN    &{SELLERS}
        Handle Consent Elements
        Go To Predajcovia Aut Page
        Click And Search For Seller    ${seller_name}
        Scroll Down And Click Show Button    ${seller_name}    ${seller_url_part}
        ${links}    Get All Links On Page
        FOR    ${link}    IN    @{links}
            ${is_http}    Run Keyword And Return Status    Should Start With    ${link}    http
            Run Keyword If    ${is_http}    Check Link    ${link}
        END
        Check Current URL And HTTP Status Code    ${seller_url_part}
        Click First Element In Section
        ${first_element_url}    Get First Element URL
        Run Keyword If    '${first_element_url}' != 'None'    Verify New Tab URL    ${first_element_url}
        Switch To Original Tab
        Go To Next Page If Exists
        Click First Element In Section
        ${first_element_url}    Get First Element URL
        Run Keyword If    '${first_element_url}' != 'None'    Verify New Tab URL    ${first_element_url}
    END

*** Keywords ***
Open Browser To Predajcovia Aut
    Open Browser    ${BASE_URL}    chrome
    Maximize Browser Window
    Wait Until Page Contains Element    //a    10s

Handle Consent Elements
    [Documentation]    Potvrdí iframe s oznámením o ochrane osobných údajov, ak existuje.
    ${iframe_visible}    Run Keyword And Return Status    Page Should Contain Element    xpath=//iframe[@id='sp_message_iframe_1090194']
    Run Keyword If    ${iframe_visible}    Handle Iframe

Handle Iframe
    [Documentation]    Potvrdí iframe s oznámením o ochrane osobných údajov.
    Select Frame    xpath=//iframe[@id='sp_message_iframe_1090194']
    ${button_visible}    Run Keyword And Return Status    Page Should Contain Element    xpath=//button[@title='Prijať všetko']
    Run Keyword If    ${button_visible}    Click Button    xpath=//button[@title='Prijať všetko']
    Unselect Frame

Go To Predajcovia Aut Page
    [Documentation]    Naviguje späť na hlavnú stránku predajcov.
    Go To    ${BASE_URL}
    Wait Until Page Contains Element    xpath=//input[@placeholder='Napíšte hľadaný výraz']    10s

Click And Search For Seller
    [Arguments]    ${seller_name}
    [Documentation]    Klikne na pole 'Napíšte hľadaný výraz', počká a napíše text ${seller_name}.
    Wait Until Page Contains Element    xpath=//input[@placeholder='Napíšte hľadaný výraz']    10s
    Click Element    xpath=//input[@placeholder='Napíšte hľadaný výraz']
    Sleep    1s
    Input Text    xpath=//input[@placeholder='Napíšte hľadaný výraz']    ${seller_name}
    Sleep    1s

Scroll Down And Click Show Button
    [Arguments]    ${seller_name}    ${seller_url_part}
    Execute JavaScript    window.scrollBy(0, 500)
    Wait Until Element Is Visible    xpath=//button[contains(., 'Zobraziť')]    10s
    Wait Until Element Is Enabled    xpath=//button[contains(., 'Zobraziť')]    10s
    Click Element    xpath=//button[contains(., 'Zobraziť')]
    Sleep    2s
    Execute JavaScript    window.scrollBy(0, 500)
    Sleep    2s
    Wait Until Seller Link Is Visible And Click    ${seller_url_part}

Wait Until Seller Link Is Visible And Click
    [Arguments]    ${seller_url_part}
    ${seller_xpath}    Set Variable    xpath=//a[contains(@href, '/predajca/${seller_url_part}/')]
    Wait Until Element Is Visible    ${seller_xpath}    20s
    Execute JavaScript    document.querySelector("a[href*='${seller_url_part}']").click()
    Sleep    2s

Get All Links On Page
    ${links}    SeleniumLibrary.Get All Links
    [RETURN]    ${links}

Check Link
    [Arguments]    ${url}
    ${response}    Get Request    ${url}
    Log    HTTP status kód pre ${url} je: ${response.status_code}
    Should Be Equal As Numbers    ${response.status_code}    200

Check Current URL And HTTP Status Code
    [Arguments]    ${seller_url_part}
    [Documentation]    Test overuje, či sa nachádzate na URL obsahujúcej ${seller_url_part} a či server vracia HTTP status kód 200.
    ${expected_url}    Set Variable    https://www.autobazar.eu/predajca/${seller_url_part}/
    ${current_url}    Get Location
    Should Be Equal    ${current_url}    ${expected_url}
    Sleep    5s

Click First Element In Section
    [Documentation]    Skroluje dolu a klikne na prvý element v sekcii inzerátov predajcu.
    Execute JavaScript    window.scrollBy(0, 1000)
    Sleep    5s
    ${first_element_xpath}    Set Variable    xpath=//div[@class="mt-8 flex min-h-[122px] w-full justify-between gap-0.5 md:min-h-[192px] flex-row"]/a[1]
    ${first_element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${first_element_xpath}    10s
    Run Keyword If    ${first_element_visible}
        Execute JavaScript    arguments[0].click();    ${first_element_xpath}
    ...    ELSE
    ...    Log    First element is not visible.
    Sleep    5s


Get First Element URL
    [Documentation]    Získa URL prvého elementu v sekcii inzerátov predajcu.
    ${first_element_url}    Get Element Attribute    ${first_element_xpath}    href

Verify New Tab URL
    [Arguments]    ${expected_url}
    [Documentation]    Overuje URL v novom tabe.
    Run Keyword If    '${expected_url}' != 'None'    Log    Aktuálna URL v novom tabe je: ${new_url}
    Run Keyword If    '${expected_url}' != 'None'    Should Be Equal    ${new_url}
    Sleep    10s

Switch To Original Tab
    [Documentation]    Prepne späť na pôvodný tab.
    ${original_window}    Get Window Handles
    Switch Window    ${original_window[0]}
    Sleep    2s

Go To Next Page If Exists
    [Documentation]    Skroluje dolu a klikne na tlačidlo pre stránkovanie, ak existuje.
    Execute JavaScript    window.scrollBy(0, 2000)
    Sleep    5s
    ${pagination_exists}    Run Keyword And Return Status    Element Should Be Visible    xpath=//a[contains(@href, '/predajca/') and contains(@href, '?page=2')]
    Run Keyword If    ${pagination_exists}    Execute JavaScript    document.querySelector("a[href*='?page=2']").click()
    Run Keyword If    ${pagination_exists}    Sleep    5s
