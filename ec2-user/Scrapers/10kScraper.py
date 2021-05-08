from bs4 import BeautifulSoup
import requests
from urllib.request import urlretrieve
from datetime import datetime as dt
import os, re
from pathlib import Path


import codecs





data_format = '10-k'
DOMIN = 'https://www.sec.gov'



class TenKDownloader:
    def __init__(self, cik, start_date, end_date):
        if type(cik) == str:
            cik = [cik]
        elif type(cik) == list:
            for i, ele in enumerate(cik):
                assert type(ele)==str, f'cik at index {i} is not string: %s'%type(ele)
        else:
            raise TypeError('CIK should be string or list of string, input type is %s'%type(cik))
        self.CIK = cik
        self.start_date = dt.strptime(start_date,'%Y%m%d')
        self.end_date = dt.strptime(end_date,'%Y%m%d')
        self.all_url = {}
        self.cwd = os.getcwd()

    def download(self, target = './data', reset_flag=False):
        os.chdir(self.cwd)
        os.chdir(target)
        for c in self.CIK:
            try:
                if reset_flag:
                    result = self._search_each(c)
                else:
                    if c in self.all_url:
                        continue
                    else:
                        result = self._search_each(c)
            except ValueError as info:
                print(info)
                continue
            try:
                os.mkdir(c)
            except FileExistsError:
                pass
            os.chdir(f'./{c}')
            for each in result:
                print(f'Downloading {c}:{each[0]} {each[1]}')
                filename = each[0]+str(each[each[1].rfind('.'):])
                urlretrieve(each[1], filename)
                print('File saved in {}'.format(os.getcwd()+'\\'+filename))
            self.all_url[c] = result
            os.chdir('..')
        os.chdir('..')

    def _search_each(self, cik):
        assert cik in self.CIK, '%s is not in CIK list'%cik
        url = f'https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK={cik}&type=10-k&dateb=&owner=exclude&count=40'
        search_page = requests.get(url)
        assert search_page.status_code == 200, 'request code for search page: %s' % search_page.status_code
        search_head = BeautifulSoup(search_page.content, 'html.parser')
        search_result = search_head.select('table.tableFile2 tr')
        if len(search_result)==0:
            raise ValueError(f'Result for {cik} is not available, {url}')
        search_result.pop(0)
        start_idx, end_idx = self._search_date([self._get(item, 'date') for item in search_result], self.start_date, self.end_date)
        # print(start_idx, end_idx)
        result = []
        for i in range(start_idx, end_idx+1):
            if self._get(search_result[i], 'type')!='10-K':

            date = self._get(search_result[i], 'date').strftime('%Y%m%d')
            sub_url = DOMIN + search_result[i].find('a', attrs={"id": "documentsbutton"})['href']
            company_page = requests.get(sub_url)
            assert  company_page.status_code == 200, 'request code for company page: %s' % company_page.status_code
            company_head = BeautifulSoup(company_page.content, 'html.parser')
            file_table = company_head.select('table.tableFile')[0].select('tr')
            file_table.pop(0)
            for item in file_table:
                if '10-K' in item.select('td')[3].contents[0]:
                    break
            doc_url = item.select('td a')[0]['href']
            result.append((date, DOMIN+doc_url))
        return result

    def _get(self, item, info):
        if info == 'date':
            date = item.select('td')[3].contents[0]
            ret = dt.strptime(date,'%Y-%m-%d')
        elif info == 'url':
            ret = DOMIN + item.find('a', attrs={"id": "documentsbutton"})['href']
        elif info == 'type':
            ret = item.select('td')[0].contents[0]
        else:
            raise NotImplementedError
        return ret

    def _search_date(self, ls, start, end):
        h, t = ls[-1], ls[0]
        n = len(ls)
        assert start <= t and end >= h, f'Available time interval: {h} to {t}, input: {start} to {end}'
        # print(h,t)
        if start >= h:
            ei, _ = self._bsearch_dec(ls, start)
        else:
            ei = len(ls)-1
        if end <= t:
            _, si = self._bsearch_dec(ls, end)
        else:
            si = 0
        return si, ei

    def _bsearch_dec(self, ls, point):
        a = 0
        b = len(ls)
        while b-a > 1:
            tmp = int((a+b)/2)
            if ls[tmp] >= point:
                a = tmp
            else:
                b = tmp
        return a,b


class TenKScraper:
    def __init__(self, section, next_section):
        self.all_section = [str(i) for i in range(1, 16)] + ['1A', '1B', '7A', '9A', '9B']
        section = re.findall(r'\d.*\w*', section.upper())[0]
        next_section = re.findall(r'\d.*\w*', next_section.upper())[0]
        if section  not in self.all_section:
            raise ValueError(f'Section: {section} is not avaiable, avaiable section: {self.all_section}')
        if next_section  not in self.all_section:
            raise ValueError(f'Section: {next_section} is not avaiable, avaiable section: {self.all_section}')
        self.section = 'Item ' + section
        self.next_section = 'Item ' + next_section

    def scrape(self, input_path, output_path):
        with open(input_path, 'rb') as input_file:
            page = input_file.read()  
            page = page.strip() 
            page = page.replace(b'\n', b' ')
            page = page.replace(b'\r', b'')  
            page = page.replace(b'&nbsp;',
                                b' ') 
            page = page.replace(b'&#160;',
                                b' ') 

            while b'  ' in page:
                page = page.replace(b'  ', b' ')  



            p1 = bytes(r'bold;\">\s*' + self.section + r'\.(.+?)bold;\">\s*' + self.next_section + r'\.',
                       encoding='utf-8')
            p2 = bytes(r'b>\s*' + self.section + r'\.(.+?)b>\s*' + self.next_section + r'\.', encoding='utf-8')
            p3 = bytes(r'' + self.section + r'\.\s*<\/b>(.+?)' + self.next_section + r'\.\s*<\/b>', encoding='utf-8')
            p4 = bytes(r'' + self.section + r'\.\s*[^<>]+\.\s*<\/b(.+?)' + self.next_section + r'\.\s*[^<>]+\.\s*<\/b',
                       encoding='utf-8')
            p5 = bytes(r'b>\s*<font[^>]+>\s*' + self.section + r'\.(.+?)b>\s*<font[^>]+>\s*' + self.next_section + r'\.', encoding='utf-8')
            p6 = bytes(r'' + self.section.upper() + r'\.\s*<\/b>(.+?)' + self.next_section.upper() + r'\.\s*<\/b>', encoding='utf-8')

            p7 = bytes(r'underline;\">\s*' + self.section + r'\<\/font>(.+?)underline;\">\s*'+ self.next_section + r'\.\s*\<\/font>',encoding = 'utf-8')
            p8 = bytes(r'underline;\">\s*' + self.section + r'\.\<\/font>(.+?)underline;\">\s*'+ self.next_section + r'\.\s*\<\/font>',encoding = 'utf-8')
            p9 = bytes(r'<font[^>]+>\s*' + self.section + r'\:(.+?)\<font[^>]+>\s*'+self.next_section + r'\:\s*',encoding = 'utf-8')
            p10 = bytes(r'<font[^>]+>\s*' + self.section + r'\.\<\/font>(.+?)\<font[^>]+>\s*' + self.next_section + r'\.',encoding = 'utf-8')
            p11 = bytes(r'' + self.section + r'\.(.+?)<font[^>]+>\s*' + self.next_section + r'\.\<\/font>',encoding = 'utf-8')
            p12 = bytes(r'b>\s*<font[^>]+>\s*' + self.section + r'(.+?)b>\s*<font[^>]+>\s*' + self.next_section + r'\s*\<\/font>', encoding='utf-8')
            p13 = bytes(r'' + self.section + r'\.\s*[^<>]+\.\s*<\/b(.+?)b>\s*' + self.next_section + r'\.',
                       encoding='utf-8')
            regexs = (
                p1,  
                p2,  
                p3,  
                p4,  
                p5,  
                p6,  
                p7,
                p8,
                p9,
                p10,
                p11,
                p12,
                p13)

            for regex in regexs:
                match = re.search(regex, page,
                                  flags=re.IGNORECASE)
                if match:


                    soup = BeautifulSoup(match.group(1),
                                         "html.parser") 
                    rawText = soup.text.encode('utf8') 
                    Path(output_path).touch()
                    with open(output_path, "wb") as output_file:
                        output_file.write(rawText)

                    break  
        if match is None:
            print(f'No matched sections: {self.section}, {self.next_section} found in {input_path}.')
            return None
        else:
            return rawText

if __name__=='__main__':
    pass


    scraper = TenKScraper('Item 1A', 'Item 1B') 
    scraper2 = TenKScraper('Item 7', 'Item 8')
    scraper.scrape('./data/1326160/20110225.htm', './data/txt/test.txt')
    scraper2.scrape('./data/1326160/20110225.htm', './data/txt/test2.txt')

