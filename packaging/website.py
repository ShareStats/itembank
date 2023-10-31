
def simplify_item_html(html_file:str):
    """Simplify html file resulting from tree

    i.e. remove second level folders and supplements
    """

    with open(html_file, "r", encoding="utf-8") as fl:
        content = fl.readlines()

    print(f"converting {html_file}: {len(content)} lines")

    with open(html_file, "w", encoding="utf-8") as fl:
        for l in content:
            if not (l.count("&nbsp;") == 2 or
                    l.find("│   ├── <a class=")>=0 or
                    l.find(">media<")>=0 or
                    l.find(">supplements")>=0):
                fl.write(l)
