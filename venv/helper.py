from urllib.parse import urlparse, parse_qs


def get_next_page_url(current_url, url_list):
    current_page = extract_page_number(current_url)

    next_page_url = None
    next_page_number = None

    for url in url_list:
        page_number = extract_page_number(url)
        if page_number > current_page:
            if next_page_number is None or page_number < next_page_number:
                next_page_number = page_number
                next_page_url = url

    return next_page_url


def extract_page_number(url):
    query = urlparse(url).query
    params = parse_qs(query)
    return int(params.get('page', [0])[0])
