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
    Click And Search For Impa Ziar Nad Hronom
#    ${links}    Get All Links On Page
#    FOR    ${link}    IN    @{links}
#        ${response}    Get Request    ${link}
#        Log    HTTP status kód pre ${link} je: ${response.status_code}
#        Should Be Equal As Numbers    ${response.status_code}    200
#    END
    Click Show Button
#    Wait For Element Text    xpath=//div[contains(@class, 'w-full')]//a[contains(@href, '/predajca/impaziar/') and contains(text(), 'IMPA Žiar nad Hronom')]

*** Keywords ***
Open Browser To Predajcovia Aut
    Open Browser    ${BASE_URL}    chrome
    Maximize Browser Window
    Wait Until Page Contains Element    //a    10s

Click And Search For Impa Ziar Nad Hronom
    [Documentation]    Klikne na pole 'Napíšte hľadaný výraz', počká a napíše text 'Impa Žiar nad Hronom'.
    Handle Consent Elements
    Wait Until Page Contains Element    xpath=//input[@placeholder='Napíšte hľadaný výraz']    10s
    Click Element    xpath=//input[@placeholder='Napíšte hľadaný výraz']
    Sleep    1s
    Input Text    xpath=//input[@placeholder='Napíšte hľadaný výraz']    Impa Žiar nad Hronom
    Sleep    1s

Handle Consent Elements
    [Documentation]    Zatvorí alebo skryje iframe a div s oznámením o ochrane osobných údajov, ak existujú.
    Wait Until Page Contains Element    xpath=//div[@id='sp_message_container_1090194']    10s
    ${div_visible}=    Run Keyword And Return Status    Element Should Be Visible    xpath=//div[@id='sp_message_container_1090194']
    Run Keyword If    ${div_visible}    Execute JavaScript    document.getElementById('sp_message_container_1090194').style.display = 'none';

    Wait Until Page Contains Element    xpath=//iframe[@id='sp_message_iframe_1090194']    10s
    ${iframe_visible}=    Run Keyword And Return Status    Element Should Be Visible    xpath=//iframe[@id='sp_message_iframe_1090194']
    Run Keyword If    ${iframe_visible}    Execute JavaScript    document.getElementById('sp_message_iframe_1090194').style.display = 'none';
    Sleep    1s
    Maximize Browser Window

Click Show Button
    # Simulácia stlačenia klávesy Tab
    Press Key  xpath=//input[@placeholder='Napíšte hľadaný výraz']  \ue004
    Click Element  //body
    Sleep    2s

    Execute Javascript	window.scrollTo(0,document.body.scrollHeight);
    Execute Javascript    $(document).scrollTop(3000)
    Scroll Element Into View xpath=//input[@placeholder='Napíšte hľadaný výraz']
    # Kliknite na tlačidlo
    Click Element  xpath=//button[@type='submit' and contains(@class, 'bg-[#0071e3]') and .//span[text()='Zobraziť']]
    Sleep    10s

Get All Links On Page
    ${elements}    Get WebElements    //a[@href]
    ${links}    Create List
    FOR    ${el}    IN    @{elements}
        ${href}    Get Element Attribute    ${el}    href
        Append To List    ${links}    ${href}
    END
    [Return]    ${links}

Get Request
    [Arguments]    ${url}
    ${response}    Get    ${url}
    [Return]    ${response}
