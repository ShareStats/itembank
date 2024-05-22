"""simple website functions"""

from os import path, listdir
from typing import List

DOCS_PATH = "docs"

def format_website(html_file:str):
    with open(html_file, "r", encoding="utf-8") as fl:
        content = fl.readlines()
    print(f"converting {html_file}: {len(content)} lines")

    content = _simplify_item_html(content)
    content = _add_counter(content)

    with open(html_file, "w", encoding="utf-8") as fl:
        fl.writelines(content)

def _add_counter(content:List[str])-> List[str]:
    #count
    counter = {}
    for topic in _dirs(DOCS_PATH):
        d = _dirs(path.join(DOCS_PATH, topic))
        counter[topic] = len(d)

    rtn = []
    list_written = False
    for l in content:
        rtn.append(l)
        if not list_written and l.find("<h1>Packages")>0:
            # add list
            total = sum(counter.values())
            rtn.append(f"<h2>Number of items: {total}</h2><ul>")
            for k,v in counter.items():
                rtn.append(f"<li>{k}:&nbsp;&nbsp;{v}</li>")
            rtn.append("</ul><h2>Items</h2>")
            list_written = True
    return rtn

def errorlog2html(error_log, html_file_path):

    with open(error_log, 'r', encoding="utf-8") as csv_file:
        lines = csv_file.readlines()

    html_content = f'<h2>{lines[0]}</h2> \n<table border="0">\n'

    # Adding the data rows
    cnt  = 0
    for line in lines[1:]:
        cells = line.split('] ')
        bcell = cells[0].split(",")
        item = bcell[0][1:]
        type_ = bcell[1]
        err = cells[1].strip()
        cnt  += 1
        html_content += '  <tr>\n'
        html_content += f'    <td>{cnt}</td><td>{type_}</td><td><b>{item}</b></td><td><i>{err}</i></td>\n'
        html_content += '  </tr>\n'

    html_content += '</table>'

    # Step 3: Save the HTML table to a file
    with open(html_file_path, 'w', encoding="utf-8") as html_file:
        html_file.write(html_content)


def _dirs(path_str:str) -> List[str]:
    return [d for d in listdir(path_str)
            if path.isdir(path.join(path_str, d))]

def _simplify_item_html(content:List[str]) -> List[str]:
    """Simplify html file resulting from tree

    i.e. remove second level folders and supplements
    """
    rtn = []
    for l in content:
        if not (l.count("&nbsp;") == 2 or
                l.find('│   ├── <a class="DIR"')>=0 or
                l.find('│   └── <a class="DIR"')>=0 or
                l.find(">media<")>=0 or
                l.find(">supplements")>=0):
            rtn.append(l)
    return rtn
