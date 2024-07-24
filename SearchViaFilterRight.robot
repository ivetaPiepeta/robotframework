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
    Using A Filter HP And Right Side
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
    Select Brand From Dropdown And Close Listbox  Škoda
    Click At Coordinates  100  100
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov so značkou: ${button_text_show}
    Select Model From Dropdown And Close Listbox  Octavia Combi
    Click At Coordinates  100  100
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s modelom: ${button_text_show}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Button text: ${button_text_show}
    Scroll Element Into View  //select[@name='yearFrom']
    Select Year From Dropdown  2020
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov od roku: ${button_text_show}
    Scroll Element Into View  //select[@name='priceFrom']
    Select Price From Dropdown  7000
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov od ceny: ${button_text_show}
    Scroll Element Into View  //select[@name='fuel']
    Select Fuel From Dropdown  Diesel
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s palivom: ${button_text_show}
    Input Value Km Into Dropdown  ${KM}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s najazdenými: ${button_text_show}
    Select Bodywork  Combi
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s karosériou: ${button_text_show}
    Check Sk Location Checkbox  SK
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov pre Slovensko: ${button_text_show}
    Log To Console  Končím vyhľadávanie a spúšťam výsledky
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]

Using A Filter HP And Right Side
    Wait Until Page Is Fully Loaded
    Log To Console  Začínam vyhľadávanie
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov bez filtra: ${button_text_show}
    Select Brand From Dropdown And Close Listbox  Škoda
    Click At Coordinates  100  100
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov so značkou: ${button_text_show}
    Log To Console  Končím vyhľadávanie a spúšťam výsledky
    Sleep  ${SLEEP_TIME}
    Wait Until Loader Disappears And Click Button  //button[contains(., 'Zobraziť')]
    Sleep  ${SLEEP_TIME}
    Set Price From Input  ${PRICE_FROM}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov so cenou od: ${button_text_show}
    Set Price To Input  ${PRICE_TO}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov so cenou do: ${button_text_show}
    Set Km From Input  ${KM2}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s km od: ${button_text_show}
    Set Km To Input  ${KM3}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s km do: ${button_text_show}
    Set Year From Input  ${YEAR_FROM}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s rokom od: ${button_text_show}
    Set Year To Input  ${YEAR_TO}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s rokom do: ${button_text_show}
    Check Diesel Checkbox  ${FUEL}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s ${FUEL}: ${button_text_show}
    Check Combi Checkbox  ${BODYWORK}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s ${FUEL}: ${button_text_show}
    Check Gearbox Checkbox  ${GEARBOX}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov s ${GEARBOX} prevodovka: ${button_text_show}
    Check Drive Checkbox  ${DRIVE}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Potvrdiť')]
    Log To Console  Počet inzerátov ${DRIVE} pohon: ${button_text_show}

Wait Until Loader Disappears And Click Buttonn
    [Arguments]  ${locator}
    Wait Until Element Is Not Visible  ${locator}  timeout=30s
    Click Element Using JavaScript  ${locator}

Select Brand From Dropdown
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Značka']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Značka']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='flex space-x-1']//button[picture/img[@alt='Škoda']]
    Click Element Using JavaScript  //div[@class='flex space-x-1']//button[picture/img[@alt='Škoda']]
    Log To Console  Vyberám značku Škoda
    Sleep  ${SLEEP_TIME}

Select Model From Drop
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Scroll Element Into View  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Wait Until Element Is Visible  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Click Element Using JavaScript  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Log To Console  Vyberám model Octavia
    Sleep  ${SLEEP_TIME}

Select Model From Dropdown
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Click Element Using JavaScript  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), 'Octavia Combi')]
    Log To Console  Vyberám model Octavia
    ${button_xpath}=    Set Variable    //button[.//span[text()='Potvrdiť']]
    ${select_xpath}=    Set Variable    //select[@name='model']
    Click Button And Wait For Select Box To Close  ${button_xpath}  ${select_xpath}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s modelom: ${button_text_show}

Click Button And Wait For Select Box To Close
    [Arguments]  ${button_xpath}  ${select_xpath}
    Click Element Using JavaScript  ${button_xpath}
    Wait Until Element Is Not Visible  ${select_xpath}
    Log To Console  Select box zatvorený.

Select Brand From Dropdown And Close Listbox
    [Arguments]  ${brand}
    ${button_xpath}=    Set Variable  //button[.//span[text()='Potvrdiť']]
    ${listbox_xpath}=    Set Variable  //div[@class='scrollbar mt-[70px] h-60 w-full overflow-auto bg-[#002466] px-3 py-1 text-sm']
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Značka']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Značka']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='flex space-x-1']//button[picture/img[@alt='${brand}']]
    Click Element Using JavaScript  //div[@class='flex space-x-1']//button[picture/img[@alt='${brand}']]
    Log To Console  Vyberám značku ${brand}
    Sleep  ${SLEEP_TIME}
    Click Button And Wait For Listbox To Close  ${button_xpath}  ${listbox_xpath}
    Log To Console  Zatváram listbox značka
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov so značkou: ${button_text_show}

Select Model From Dropdown And Close Listbox
    [Arguments]  ${model}
    ${button_xpath}=    Set Variable  //button[.//span[text()='Potvrdiť']]
    ${listbox_xpath}=    Set Variable  //div[@class='scrollbar mt-[70px] h-60 w-full overflow-auto bg-[#002466] px-3 py-1 text-sm']
    Wait Until Element Is Visible  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Click Element Using JavaScript  //button[contains(@class, 'relative mt-1 h-12 w-full rounded-[8px] border-none bg-[#00225F] px-3 py-3 text-left disabled:cursor-not-allowed text-white/60')]//span[text()='Všetky modely']
    Log To Console  Klikám na select
    Sleep  ${SLEEP_TIME}
    Wait Until Element Is Visible  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), '${model}')]
    Click Element Using JavaScript  //div[@class='relative flex cursor-pointer select-none items-center py-0.5 pr-4 text-white']//span[starts-with(text(), '${model}')]
    Log To Console  Vyberám model ${model}
    Sleep  ${SLEEP_TIME}
    Click At Coordinates  100  100
    Log To Console  Klikám mimo scrollbaru
    Sleep  ${SLEEP_TIME}
    Log To Console  Zatváram listbox model
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Počet inzerátov s modelom: ${button_text_show}

Click Button And Wait For Listbox To Close
    [Arguments]  ${button_xpath}  ${listbox_xpath}
    Click Element Using JavaScript  ${button_xpath}
    Wait Until Element Is Not Visible  ${listbox_xpath}  timeout=20s
    Log To Console  Listbox zatvorený.

Select Year From Dropdown
    [Arguments]  ${year}
    ${option_value}=  Set Variable  od ${year}
    Wait Until Element Is Visible  //select[@name='yearFrom']
    Click Element Using JavaScript  //select[@name='yearFrom']
    Select From List By Label  //select[@name='yearFrom']  ${option_value}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadávam rok od: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Select Price From Dropdown
    [Arguments]  ${price}
    ${option_value}=  Set Variable  od ${price} €
    Wait Until Element Is Visible  //select[@name='priceFrom']
    Click Element Using JavaScript  //select[@name='priceFrom']
    Select From List By Value  //select[@name='priceFrom']  ${price}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadávam cenu od: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Select Fuel From Dropdown
    [Arguments]  ${fuel}
    ${option_value}=  Set Variable  ${fuel}
    Wait Until Element Is Visible  //select[@name='fuel']
    Click Element Using JavaScript  //select[@name='fuel']
    Select From List By Label  //select[@name='fuel']  ${fuel}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadávam palivo: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Input Value Km Into Dropdown
    [Arguments]  ${km}
    ${option_value}=  Set Variable  ${km}
    Wait Until Element Is Visible  //input[@name='mileageFrom']
    Click Element Using JavaScript  //input[@name='mileageFrom']
    Input Text  //input[@name='mileageFrom']  ${km}
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadávam kilometre: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Wait For Element And Compare Values
    [Arguments]  ${button_locator}  ${text_locator}
    [Documentation]  Počká, kým sa zobrazí element, a potom porovná jeho hodnotu s iným textovým elementom.
    Wait Until Element Is Visible  ${button_locator}
    ${button_text_show}=  Get Text  ${button_locator}
    Wait Until Element Is Visible  ${text_locator}
    ${results_text}=  Get Text  ${text_locator}
    Should Be Equal As Numbers  ${button_text_show}  ${results_text}

Click At Coordinates
    [Arguments]  ${x}  ${y}
    Execute Javascript  window.scrollTo(${x}, ${y});
    Click Element At Coordinates  xpath=//body  ${x}  ${y}

Select Bodywork
    [Arguments]  ${bodywork_option}
    Wait Until Element Is Visible  //select[@name='bodywork']
    Log To Console  Klikám na select: ${bodywork_option}
    Select From List By Label  //select[@name='bodywork']  ${bodywork_option}
    Sleep  ${SLEEP_TIME}
    Log To Console  Potvrdzujem select: ${bodywork_option}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadávam karosériu: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Check Sk Location Checkbox
    [Arguments]  ${location}
    Wait Until Element Is Visible  //label[input[@name='location']]//span[contains(text(), '${location}')]
    Click Element Using JavaScript  //label[input[@name='location']]//span[contains(text(), '${location}')]
    Sleep  ${SLEEP_TIME}
    Log To Console  Checkbox pre ${location} vybraný.
    Sleep  ${SLEEP_TIME}
    ${button_text_show}=    Get Text    //button[contains(., 'Zobraziť')]
    Log To Console  Vyhľadané inzeráty: ${button_text_show}
    Sleep  ${SLEEP_TIME}

Set Price From Input
    [Arguments]  ${price}
    Scroll Element Into View  //input[@placeholder='Cena od']
    Wait Until Element Is Visible  //input[@placeholder='Cena od']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Cena od']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Cena od']
    Input Text  //input[@placeholder='Cena od']  ${PRICE_FROM}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložená cena od: ${price}
    Sleep  20s

Set Price To Input
    [Arguments]  ${price}
    Scroll Element Into View  //input[@placeholder='Cena do']
    Wait Until Element Is Visible  //input[@placeholder='Cena do']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Cena do']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Cena do']
    Input Text  //input[@placeholder='Cena do']  ${PRICE_TO}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložená cena do: ${price}
    Sleep  10s

Set Km From Input
    [Arguments]  ${km}
    Scroll Element Into View  //input[@placeholder='Km od']
    Wait Until Element Is Visible  //input[@placeholder='Km od']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Km od']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Km od']
    Input Text  //input[@placeholder='Km od']  ${KM2}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložené km do: ${km}
    Sleep  10s

Set Km To Input
    [Arguments]  ${km}
    Scroll Element Into View  //input[@placeholder='Km do']
    Wait Until Element Is Visible  //input[@placeholder='Km do']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Km do']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Km do']
    Input Text  //input[@placeholder='Km do']  ${KM3}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložené km do: ${km}
    Sleep  10s

Set Year From Input
    [Arguments]  ${year}
    Scroll Element Into View  //input[@placeholder='Rok od']
    Wait Until Element Is Visible  //input[@placeholder='Rok od']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Rok od']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Rok od']
    Input Text  //input[@placeholder='Rok od']  ${YEAR_FROM}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložený rok do: ${year}
    Sleep  10s

Set Year To Input
    [Arguments]  ${year}
    Scroll Element Into View  //input[@placeholder='Rok do']
    Wait Until Element Is Visible  //input[@placeholder='Rok do']  20s
    Execute JavaScript  document.querySelector("input[placeholder='Rok do']").style.visibility='visible'
    Clear Element Text  //input[@placeholder='Rok do']
    Input Text  //input[@placeholder='Rok do']  ${YEAR_TO}
    Wait Until Element Is Visible   //div[@role='listbox']//div[@role='option']
    Click Element  //div[@role='listbox']//div[@role='option']
    Log To Console  Vložený rok do: ${year}
    Sleep  10s

Check Diesel Checkbox
    [Arguments]  ${fuel}
    ${xpath}=  Set Variable  //button[contains(., '${fuel}')]
    Wait Until Element Is Visible  ${xpath}  20s
    Click Element Using JavaScript  ${xpath}
    Sleep  ${SLEEP_TIME}
    Log To Console  Checkbox pre ${fuel} vybraný.
    Sleep  ${SLEEP_TIME}

Check Combi Checkbox
    [Arguments]  ${bodywork}
    ${xpath}=  Set Variable  //button[contains(., '${bodywork}')]
    Wait Until Element Is Visible  ${xpath}  20s
    Click Element Using JavaScript  ${xpath}
    Sleep  ${SLEEP_TIME}
    Log To Console  Checkbox pre ${bodywork} vybraný.
    Sleep  ${SLEEP_TIME}

Check Gearbox Checkbox
#prevodovka
    [Arguments]  ${gearbox}
    ${xpath}=  Set Variable  //button[contains(., '${gearbox}')]
    Wait Until Element Is Visible  ${xpath}  20s
    Click Element Using JavaScript  ${xpath}
    Sleep  ${SLEEP_TIME}
    Log To Console  Checkbox pre prevodovku ${gearbox} vybraný.
    Sleep  ${SLEEP_TIME}

Check Drive Checkbox
#pohon
    [Arguments]  ${drive}
    ${xpath}=  Set Variable  //button[contains(., '${drive}')]
    Wait Until Element Is Visible  ${xpath}  20s
    Click Element Using JavaScript  ${xpath}
    Sleep  ${SLEEP_TIME}
    Log To Console  Checkbox pre pohon ${drive} vybraný.
    Sleep  ${SLEEP_TIME}

