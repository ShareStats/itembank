import csv
import json
from pathlib import Path
from datetime import datetime


from .item import Item
from .common import item_list, subfolder, load_fingerprint_file

BASEFOLDER = "."
PACK_FOLDER = "packages/"
EXCLUDE_FOLDER = ("scripts", "packaging", "packages", "build")
EXCLUDE_FILES = ("-qti.zip", "-tv.zip", ".html")
COMPILATION_INSTRUCTION = "compl.instr"


def compilation_file(formats, fingerprint_filename="fingerprints.json"):
    """Prepare compilation
    * generate instruction file that is read by tarballs and compile.R
    * the function also creates the required folder structure for the packages
    """
    if not isinstance(formats, (list, tuple)):
        formats = (formats, )

    all_items = item_list(subfolder(BASEFOLDER, EXCLUDE_FOLDER))

    pkg_folder = Path(PACK_FOLDER)
    pkg_folder.mkdir(parents=True, exist_ok=True)
    # finger print file
    fp_file = pkg_folder.joinpath(fingerprint_filename)
    try:
        hash_dict = load_fingerprint_file(fp_file)
    except FileNotFoundError:
        hash_dict = {}
    # make file
    fl = open(pkg_folder.joinpath(COMPILATION_INSTRUCTION), "w", encoding="utf-8")
    fl.write('"format"\t"file"\t"name"\t"dir"\n')
    for frmt in formats:
        for item in all_items:
            pkg_basefld = pkg_folder.joinpath(frmt, item.path.parent)
            if frmt in ("qti", "tv"):
                pack_name = item.name + "-" + frmt
                pkg_path = pkg_basefld.joinpath(pack_name + ".zip")
            elif frmt in ("tar", "zip"):
                pack_name = item.name
                pkg_path = pkg_basefld.joinpath(pack_name + "." + frmt)
            elif frmt in ("html"):
                pack_name = item.name
                pkg_path = pkg_basefld.joinpath(pack_name, pack_name + "1.html")
            else:
                raise RuntimeError(f"Unknown format: {frmt}")

            if item.package_needs_update(pkg_path, hash_dict):
                pkg_fld = pkg_path.parent
                pkg_fld.mkdir(parents=True, exist_ok=True)
                fl.write(
                    f'"{frmt}"\t"{item.rmd_file()}"\t"{pack_name}"\t"{pkg_fld}"\n')

    fl.close()


def fingerprint_file(filename="fingerprints.json"):
    """save hashes of current items"""
    source_folders = subfolder(BASEFOLDER, EXCLUDE_FOLDER)
    hash_dict = {}
    for item in item_list(source_folders):
        hash_dict[item.path_str] = item.fingerprint()
    # save
    p = Path(PACK_FOLDER)
    p.mkdir(parents=True, exist_ok=True)
    with open(p.joinpath(filename), 'w', encoding="utf-8") as fl:
        json.dump(hash_dict, fl, indent=2)


def tarballs():
    pkg_folder = Path(PACK_FOLDER)

    log_folder = pkg_folder.joinpath("log")
    log_folder.mkdir(parents=True, exist_ok=True)
    date_str = datetime.now().strftime("%y%m%d")
    log_file = open(log_folder.joinpath("log-" + date_str + ".txt"), "a", encoding="utf-8")
    log_file.write(f"[PY LOG: {str(datetime.now())}]\n")

    with open(PACK_FOLDER + COMPILATION_INSTRUCTION, "r", encoding="utf-8") as fl:
        csv_reader = csv.reader(fl, delimiter='\t')
        for row in csv_reader:
            if row[0] in ("tar", "zip"):
                item = Item(Path(row[1]).parent)

                if row[0] == "zip":
                    txt = f"[zip] {item.path}\n"
                    item.zip(PACK_FOLDER + "zip", EXCLUDE_FILES)
                else:
                    txt = f"[tar] {item.path}\n"
                    item.tar(PACK_FOLDER + "tar", EXCLUDE_FILES)

                log_file.write(txt)

    log_file.close()