*** Settings ***
Resource  SharedKeywords.robot
Library    helper.py

*** Variables ***
${Sub_URL}  predajcovia-aut/
@{Links}    # Tento zoznam bude obsahovať všetky odkazy (href)
@{Broken_Links}
@{Valid_Links}  # Tento zoznam bude obsahovať všetky odkazy s statusom 200
${TOTAL_LINKS}  0
${REMAINING_LINKS}  0
${SLEEP_TIME}  2s
@{Search_Terms}  Impa Žiar nad Hronom  Autodado    BB Auto  AP cars
@{Paginator_Links}
${NEXT_BUTTON_XPATH}  //a[contains(@class, 'cursor-pointer') and contains(text(), 'Ďalší predajcovia')]
${PAGINATOR_WRAPPER_SELLER}  //div[@class="float-none mx-0 my-0"]

*** Test Cases ***
Seller check
    [Documentation]  Tento test otvorí prehliadač, načíta stránku predajcov aut, overí HTTP status kód, odklikne consent popup a vyplní text do vyhľadávacieho políčka.
    Disable Insecure Request Warnings
    Create Session  predajcovia_aut  ${Base_URL}${Sub_URL}  verify=False
    ${response}  GET On Session  predajcovia_aut  /
    Should Be Equal As Numbers  ${response.status_code}  200
    Open Browser  ${Base_URL}${Sub_URL}  chrome
    Maximize Browser Window
    Switch To Frame And Accept All
    Wait Until Page Is Fully Loaded
    FOR  ${term}  IN  @{Search_Terms}
        Log To Console  Searching for: ${term}
        Wait Until Page Is Fully Loaded
        Sleep  ${SLEEP_TIME}
        Input Search Term And Click Button  ${term}
        Sleep  ${SLEEP_TIME}
        Wait Until Page Is Fully Loaded
        Get All Links And Check Status For All Pages
    END
    Fail Test If Broken Links Exist
    Log All Valid Links

Seller Links Check
    [Documentation]  Tento test otvorí prehliadač, načíta stránku predajcov aut, overí HTTP status kód každého inzerátu kliknutím na obrázok.
    Disable Insecure Request Warnings
    FOR  ${url}  IN  @{Valid_Links}
        Open Valid Link And Check Inner Links  ${url}
    END
    Navigate ThroughPages Until Last Span
    [Teardown]  Close Browser
    Fail Test If Broken Links Exist

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
    Input Text  //input[@type='search' and @placeholder='Napíšte hľadaný výraz']  ${term}
    Wait Until Loader Disappears And Click Button  //button[contains(@class, 'mt-5 w-full space-x-2 rounded-lg bg-[#0071e3] px-[15px] py-[14px] font-semibold disabled:cursor-not-allowed disabled:bg-[#0071e3]/80 disabled:text-white/80 lg:w-[170px]')]

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

CheckPhotos
    [Documentation]  Skontroluje stav všetkých odkazov, otvorí, načíta, nájde....
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
    ${response}=  GET On Session  predajcovia_aut  ${page}
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

Open Valid Link And Check Inner Linkssss
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

Open Valid Link And Check Inner Links
    [Arguments]  @{Valid_Links}
    [Documentation]  Iteruje cez zoznam platných odkazov a kontroluje vnútorné odkazy na každej URL.

    FOR  ${url}  IN  @{Valid_Links}
        Log To Console  Otváram odkaz: ${url}
        Go To    ${url}
        Wait Until Page Is Fully Loaded
        # Kontrola vnútorných odkazov na danej URL
        Check Inner Links
    END

Check Inner Links
    [Documentation]  Kontroluje vnútorné odkazy na aktuálnej stránke.
    # Overiť, či sú prvky prítomné
    ${has_elements}=  Run Keyword And Return Status  Wait Until Element Is Visible  //div[contains(@class, 'relative') and contains(@class, 'flex') and contains(@class, 'min-h-[122px]') and contains(@class, 'w-full') and contains(@class, 'justify-between') and contains(@class, 'gap-0.5')]/div[contains(@class, 'relative') and contains(@class, 'z-50')]/a  10s
    Run Keyword If  ${has_elements}  Log To Console  Links are visible on the page
    Run Keyword If  not ${has_elements}  Log To Console  ERROR: No links found with the specified XPath

    ${image_a}=  Get WebElements  //div[contains(@class, 'relative') and contains(@class, 'flex') and contains(@class, 'min-h-[122px]') and contains(@class, 'w-full') and contains(@class, 'justify-between') and contains(@class, 'gap-0.5')]/div[contains(@class, 'relative') and contains(@class, 'z-50')]/a
    ${image_a_count}=  Get Length  ${image_a}
    Log To Console  Number of links found: ${image_a_count}

    FOR  ${link}  IN  @{image_a}
        ${href}=  Get Element Attribute  ${link}  href
        Log To Console  Checking status for link: ${href}

        ${status}=  Run Keyword And Ignore Error  Check Single Href Status  ${href}
        ${status_passed}=  Set Variable  ${status}[0]
        ${status_code}=  Set Variable  ${status}[1]

        # Kontrola pre úspech RUNNING status pre keyword
        Run Keyword And Continue On Failure  Should Be Equal  ${status_passed}  PASS

        # Alternatívna kontrola hodnôt
        ${status_code}=  Set Variable If  '${status_passed}' == 'FAIL'  -1  ${status_code}

        Log To Console  Status code for link ${href} is ${status_code}

        Run Keyword If  '${status_code}' == '200'  Log Valid Link Client  ${href}
        Run Keyword If  '${status_code}' != '200'  Log Broken Link Client  ${href}  ${status_code}
    END

Log Valid Link Client
    [Arguments]  ${href}
    Log To Console  Valid link: ${href}

Log Broken Link Client
    [Arguments]  ${href}  ${status_code}
    Log To Console  Broken link: ${href}, status code: ${status_code}

Log Totall Links Found
    [Arguments]  @{hrefs}
    ${num_links}  Evaluate  len(${hrefs})
    Log To Console  Total links found: ${num_links}
    FOR  ${href}  IN  @{hrefs}
        Log To Console  ${href}
    END

