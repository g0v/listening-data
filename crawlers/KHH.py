# -*- coding: utf-8 -*-

import json
import httplib2
from lxml import etree

BASE_URL = "http://socbu.kcg.gov.tw/"

URL = [ "http://socbu.kcg.gov.tw/?prog=1&b_id=2",
    "http://socbu.kcg.gov.tw/?prog=1&b_id=25",
    "http://socbu.kcg.gov.tw/?prog=1&b_id=4",
    "http://socbu.kcg.gov.tw/?prog=1&b_id=5",
    "http://socbu.kcg.gov.tw/?prog=1&b_id=3",
    "http://socbu.kcg.gov.tw/?prog=1&b_id=7"
    ]


def get_data(url):
    """get data
    
    type: string
    return type: dict
    """
    h = httplib2.Http("")
    resp, cont = h.request(url)
    
    root = etree.HTML(cont)
    url_content = root.xpath("//div[@class='content']")
    
    result = []
    for content in url_content:
        for info in content.iter("a"):
            url, title = BASE_URL + info.values()[0], info.values()[1]
            result.append({
                "title": title,
                "url": url,
                "content": "",
                "files": []
            })
                
    return result


def to_json(d, path):
    with open(path, "w") as f:
        f.write(json.dumps(d, ensure_ascii=False, indent=4, sort_keys=True))

if __name__ == '__main__':
    results = []
    for url in URL:
        results += get_data(url)
        
                
    to_json(results, "../data/KHH/data.json")