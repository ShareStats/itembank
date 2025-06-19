import csv
import json
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

from .common import item_list, subfolder
from .item import Item

BASEFOLDER = "."
PACK_FOLDER = "packages/"
HTML_FOLDER = "docs/"
PLATTFORMS = ("qti", "tv", "canvas", "ans", "wooclap")
EXCLUDE_FOLDER = ("scripts", "packaging", "packages", "build", "docs")
FILE_TBL = "files.tsv"

def all_items():
    return item_list(subfolder(BASEFOLDER, EXCLUDE_FOLDER))

def file_table(formats, only_changed=True):
    """Make table with source and destination files that changed to prepare
    compilation. If only_changed=False, returns all files.

    * generate instruction file that is read by tarballs and compile.R
    * the function also creates the required folder structure for the packages
    """

    if not isinstance(formats, (list, tuple)):
        formats = (formats, )

    html_folder = Path(HTML_FOLDER)
    html_folder.mkdir(parents=True, exist_ok=True)
    pkg_folder = Path(PACK_FOLDER)
    pkg_folder.mkdir(parents=True, exist_ok=True)

    # finger print file
    if only_changed:
        try:
            hash_dict = load_fingerprints()
        except FileNotFoundError:
            hash_dict = {}
    else:
        hash_dict = {}

    # make file
    fl = open(pkg_folder.joinpath(FILE_TBL), "w", encoding="utf-8")
    fl.write('"format"\t"file"\t"name"\t"dir"\n')
    for frmt in formats:
        for item in all_items():
            if frmt in PLATTFORMS:
                pack_name = item.name + "-" + frmt
                fld = pkg_folder.joinpath(frmt, item.path.parent)
                pkg_path = fld.joinpath(pack_name + ".zip")
            elif frmt in ("tar", "zip"):
                pack_name = item.name
                fld = pkg_folder.joinpath(frmt, item.path.parent)
                pkg_path = fld.joinpath(pack_name + "." + frmt)
            elif frmt in ("html"):
                pack_name = item.name
                fld = html_folder.joinpath(item.path.parent)
                pkg_path = fld.joinpath(pack_name, pack_name + "1.html")
            else:
                raise RuntimeError(f"Unknown format: {frmt}")

            if item.package_needs_update(pkg_path, hash_dict):
                pkg_fld = pkg_path.parent
                pkg_fld.mkdir(parents=True, exist_ok=True)
                fl.write(
                    f'"{frmt}"\t"{item.rmd_file()}"\t"{pack_name}"\t"{pkg_fld}"\n')

    fl.close()

def fingerprints():
    """dictionary of fingerprint"""
    source_folders = subfolder(BASEFOLDER, EXCLUDE_FOLDER)
    hash_dict = {}
    for item in item_list(source_folders):
        hash_dict[item.path_str] = item.fingerprint()
    return hash_dict

def load_fingerprints(filename="fingerprints.json"):
    """load hashes of items"""
    flname = Path(PACK_FOLDER).joinpath(filename)
    with open(flname, 'r', encoding="utf-8") as fl:
        return json.load(fl)

def save_fingerprints(filename="fingerprints.json"):
    """save hashes of current items"""
    p = Path(PACK_FOLDER)
    p.mkdir(parents=True, exist_ok=True)
    flname = p.joinpath(filename)
    with open(flname, 'w', encoding="utf-8") as fl:
        json.dump(fingerprints(), fl, indent=2)


def tarballs():

    exclude_files = [f"-{x}.zip" for x in PLATTFORMS] + [".html"] # platform zip file and html file
    pkg_folder = Path(PACK_FOLDER)
    tz = ZoneInfo('Europe/Amsterdam')
    log_folder = pkg_folder.joinpath("log")
    log_folder.mkdir(parents=True, exist_ok=True)
    date_str = datetime.now(tz).strftime("%y%m%d")
    log_file = open(log_folder.joinpath("log-" + date_str + ".txt"), "a", encoding="utf-8")
    log_file.write(f"[PY LOG: {str(datetime.now(tz))}]\n")

    with open(PACK_FOLDER + FILE_TBL, "r", encoding="utf-8") as fl:
        csv_reader = csv.reader(fl, delimiter='\t')
        for row in csv_reader:
            if row[0] in ("tar", "zip"):
                item = Item(Path(row[1]).parent)
                if row[0] == "zip":
                    txt = f"[zip] {item.path}"
                    item.zip(PACK_FOLDER + "zip", exclude_files)
                else:
                    txt = f"[tar] {item.path}"
                    item.tar(PACK_FOLDER + "tar", exclude_files)

                log_file.write(txt + "\n")
                print(txt)

    log_file.close()