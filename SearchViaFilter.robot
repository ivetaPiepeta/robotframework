*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  BuiltIn
Library  OperatingSystem
Library  String
Resource  SharedKeywords.robot
Library    helper.py

*** Variables ***
@{Links}    # Tento zoznam bude obsahovať všetky odkazy (href)
@{Broken_Links}
@{Valid_Links}  # Tento zoznam bude obsahovať všetky odkazy s statusom 200
${TOTAL_LINKS}  0
${REMAINING_LINKS}  0
${SLEEP_TIME}  2s
${Search_Term}  ABS
@{Paginator_Links}
${NEXT_BUTTON_XPATH}  //a[contains(@class, 'cursor-pointer') and contains(text(), 'Ďalší predajcovia')]
${PAGINATOR_WRAPPER_SELLER}  //div[@class="float-none mx-0 my-0"]
${BUTTON_TEXT_SHOW}  //button[contains(., 'Zobraziť')]
${TEXT_LOCATOR}  //div[@class='mr-[100px] font-semibold lowercase text-[rgba(235,235,245,.6)] xs:mr-1']


*** Test Cases ***
Seller check
    [Documentation]  Vyfiltruje v kazdom inpute moznost a porovná vysledky v buttne s vyhladanymi vysledkami
    Disable Insecure Request Warnings
    Create Session  vyhladavanie  ${Base_URL}  verify=False
    ${response}  GET On Session  vyhladavanie  /
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${Base_URL}  chrome
    Maximize Browser Window
    Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded
    Scroll Down To Load Content 1 time

    Using A Filter HP

    Sleep  ${SLEEP_TIME}
    Wait Until Page Is Fully Loaded
    Get All Links And Check Status For All Pages
    Fail Test If Broken Links Exist
    Log All Valid Links


*** Keywords ***
Navigate ThroughPages Until Last Span
    ${last_page}=  Get Variable Value  ${False}
    WHILE  '${last_page}' == '${False}'
        @{elements}=  Get WebElements  ${PAGINATOR_WRAPPER_SELLER}//a | ${PAGINATOR_WRAPPER_SELLER}//span
        ${urls}=  Create List
        FOR  ${element}  IN  @{elements}
            ${href}=  Get Element Attribute  ${element}  href
            Run Keyword If  '${href}'  Append To List  ${urls}  ${href}
        END
        ${current_url}=  Get Location
        ${next_url}=  Evaluate  helper.get_next_page_url("${current_url}", ${urls})
        Log To Console    Next URL is: ${next_url}
        Open Valid Link And Check Inner Links  ${current_url}
        Run Keyword If  '${next_url}' == 'None'  Exit For Loop
        Run Keyword If  '${next_url}' != 'None'  Go To  ${next_url}
        Run Keyword If  '${next_url}' != 'None'  Sleep  1s  # Wait for the next page to load
    END
    Sleep  2s

Wait Until Loader Disappears And Click Button
    [Arguments]  ${xpath}
    [Documentation]  Počká, kým zmizne loader (SVG prvok) a klikne na tlačidlo.
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  ${xpath}
    Scroll Element Into View  ${xpath}
    Click Element Using JavaScript  ${xpath}

Click Element Using JavaScript
    [Arguments]  ${xpath}
    Execute JavaScript  document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Sleep  ${SLEEP_TIME}

Input Search Term And Click Button
    [Arguments]  ${term}
    Input Text  //input[@type='text' and @placeholder='Kľúčové slovo']  ${term}
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]

Get All Links
    [Documentation]  Získaj všetky odkazy (a-href) z prvkov s triedou `flex flex-wrap justify-between gap-2`.
    @{elements}=  Get WebElements  //div[contains(@class, 'flex flex-wrap justify-between gap-2')]//a
    ${links}=  Create List
    FOR  ${element}  IN  @{elements}
        ${href}=  Get Element Attribute  ${element}  href
        Append To List  ${links}  ${href}
    END
    ${unique_links}=  Remove Duplicates  ${links}
    Set Global Variable  ${Links}  ${unique_links}

Remove Duplicates From List
    [Documentation]  Odstráni duplicity zo zoznamu odkazov.
    ${unique_links}=  Remove Duplicates  ${Links}
    Set Global Variable  ${Links}  ${unique_links}

CheckHrefsStatus
    [Documentation]  Skontroluje stav všetkých odkazov.
    ${total_links}=  Get Length  ${Links}
    Set Global Variable  ${TOTAL_LINKS}  ${total_links}
    Set Global Variable  ${REMAINING_LINKS}  ${total_links}
    FOR  ${page}  IN  @{Links}
        ${status}=  Run Keyword And Ignore Error  Check Single Href Status  ${page}
        ${status_code}=  Set Variable If  '${status[0]}' == 'PASS'  ${status[1]}  -1
        Run Keyword If  '${status_code}' == '200'  Log Valid Link  ${page}
        Run Keyword If  '${status_code}' != '200'  Log Broken Link  ${page}  ${status_code}
        ${REMAINING_LINKS}=  Evaluate  ${REMAINING_LINKS} - 1
        Log To Console  ${REMAINING_LINKS}/${TOTAL_LINKS} ${page}  no new line=True
    END
    Set Variable  @{Links}  @{EMPTY}

Check Single Href Status
    [Arguments]  ${page}
    Disable Insecure Request Warnings
    ${response}=  GET On Session  sukromnici  ${page}
    Log  HTTP status kód pre ${page} je: ${response.status_code}
    RETURN  ${response.status_code}

Log Broken Link
    [Arguments]  ${url}  ${status_code}
    Log  Broken link found: ${url} with status code: ${status_code}
    Append To List  ${Broken_Links}  ${url}

Log Valid Link
    [Arguments]  ${url}
    Append To List  ${Valid_Links}  ${url}

Log Total Links Found
    [Documentation]  Zaloguje celkový počet nájdených odkazov.
    ${total_links}=  Get Length  ${Links}
    Log To Console  Total links found: ${total_links}
    Set Global Variable  ${TOTAL_LINKS}  ${total_links}
    Set Global Variable  ${REMAINING_LINKS}  ${total_links}

Fail Test If Broken Links Exist
    Run Keyword If  ${Broken_Links}  Fail  Broken links found: ${Broken_Links}

Log All Valid Links
    [Documentation]  Zaloguje všetky platné odkazy na konci testu.
    Log To Console  Valid links found: ${Valid_Links}

Get All Links And Check Status For All Pages
    [Documentation]  Získa všetky odkazy a skontroluje ich stav pre všetky strany v paginácii.
    WHILE  True
        ${next_button_exists}=  Run Keyword And Return Status  Page Should Contain Element  ${NEXT_BUTTON_XPATH}
        Get All Links
        Log Total Links Found
        CheckHrefsStatus
        Clear List  @{Links}
        Run Keyword If  ${next_button_exists} == False  Exit For Loop
        Click Element Using JavaScript  ${NEXT_BUTTON_XPATH}
        Sleep  ${SLEEP_TIME}
        Wait Until Page Is Fully Loaded
    END

Open Valid Link And Check Inner Links
    [Arguments]  ${url}
    [Documentation]  Otvorí platný odkaz a skontroluje vnútorné odkazy.
    Log To Console  Otváram odkaz: ${url}
    Go To    ${url}
    Wait Until Page Is Fully Loaded
    ${image_a}=  Get WebElements  //div[contains(@class, 'mt-8') and contains(@class, 'flex') and contains(@class, 'min-h-[122px]') and contains(@class, 'w-full') and contains(@class, 'justify-between') and contains(@class, 'gap-0.5') and contains(@class, 'md:min-h-[192px]') and contains(@class, 'flex-row')]/a[1]

    FOR  ${link}  IN  @{image_a}
        ${href}=  Get Element Attribute  ${link}  href
        ${status}=  Run Keyword And Ignore Error  Check Single Href Status  ${href}
        Log To Console  ${status}
        ${status_code}=  Set Variable If  '${status[0]}' == 'PASS'  ${status[1]}  -1
        Log To Console  status kód linku ${href} je ${status_code}
        Run Keyword If  '${status_code}' == '200'  Log Valid Link  ${href}
        Run Keyword If  '${status_code}' != '200'  Log Broken Link  ${href}  ${status_code}
    END

Using A Filter HP
    Wait Until Page Is Fully Loaded
    Log To Console  Začínam vyhľadávanie
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov bez filtra: ${button_text_show}
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Značka']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Značka']
    Log To Console  Klikám na select
    Wait Until Element Is Visible  //div[@class='flex space-x-1']//button[picture/img[@alt='Škoda']]
    Click Element Using JavaScript  //div[@class='flex space-x-1']//button[picture/img[@alt='Škoda']]
    Log To Console  Vyberám značku Škoda
    Sleep  ${SLEEP_TIME}
    Click Element Using JavaScript  //button[.//span[text()='Potvrdiť']]
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov so značkou: ${button_text_show}
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Scroll Element Into View  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Wait Until Element Is Visible  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Click Element Using JavaScript  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Log To Console  Vyberám model Octavia
    Sleep  ${SLEEP_TIME}
    Scroll Element Into View  //button[.//span[text()='Potvrdiť']]
    Click Element Using JavaScript  //button[.//span[text()='Potvrdiť']]
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s modelom: ${button_text_show}
    Sleep  ${SLEEP_TIME}
    Log To Console  Končím vyhľadávanie a spúšťam výsledky
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Button text: ${button_text_show}
    Scroll Element Into View  //select[@name='yearFrom']
    Select Year From Dropdown  2020


    #Sleep  ${SLEEP_TIME}
    #${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    #Log To Console  Button text: ${button_text_show}
    #Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]
    #Sleep  ${SLEEP_TIME}
    #${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    #Log To Console  Button text: ${button_text_show}
    #Wait Until Page Is Fully Loaded
    #${results_text}=    Get Text    //div[contains(@class, 'mr-[100px] font-semibold lowercase text-[rgba(235,235,245,.6)] xs:mr-1') and contains(text(), 'inzerátov')]
    #Log To Console  Results text: ${results_text}
    #Compare Values    ${button_text_show}    ${results_text}
    #Wait For Element And Compare Values  ${BUTTON_LOCATOR}  ${TEXT_LOCATOR}

Wait Until Loader Disappears And Click Buttonn
    [Arguments]  ${locator}
    Wait Until Element Is Not Visible  ${locator}  timeout=30s
    Click Element Using JavaScript  ${locator}

Select Year From Dropdown
    [Arguments]  ${year}
    ${option_value}=  Set Variable  od ${year}
    Wait Until Element Is Visible  //select[@name='yearFrom']
    Click Element Using JavaScript  //select[@name='yearFrom']
    Select From List By Label  //select[@name='yearFrom']  ${option_value}

Wait For Element And Compare Values
    [Arguments]  ${button_locator}  ${text_locator}
    [Documentation]  Počká, kým sa zobrazí element, a potom porovná jeho hodnotu s iným textovým elementom.
    Wait Until Element Is Visible  ${button_locator}
    ${button_text_show}=  Get Text  ${button_locator}
    Wait Until Element Is Visible  ${text_locator}
    ${results_text}=  Get Text  ${text_locator}
    Should Be Equal As Numbers  ${button_text_show}  ${results_text}