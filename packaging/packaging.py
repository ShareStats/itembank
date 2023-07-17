import csv
import json
from pathlib import Path

from .item import Item
from .common import item_list, subfolder, load_fingerprint_file, changed_items_list

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
    Path(PACK_FOLDER).mkdir(parents=True, exist_ok=True)
    source_folders = subfolder(BASEFOLDER, EXCLUDE_FOLDER)
    # finger print file
    fp_file = Path(PACK_FOLDER).joinpath(fingerprint_filename)
    try:
        hash_dict = load_fingerprint_file(fp_file)
    except FileNotFoundError:
        hash_dict ={}

    changed_items = changed_items_list(source_folders, hash_dict)
    # make file
    fl = open(PACK_FOLDER + COMPILATION_INSTRUCTION, "w", encoding="utf-8")
    fl.write('"format"\t"file"\t"name"\t"dir"\n')
    for frmt in formats:
        pkg_base_fld = Path(PACK_FOLDER + frmt)
        for item in changed_items:
            if frmt in ("qti", "tv"):
                pack_name = item.package_name(suffix="-" + frmt)
            else:
                pack_name = item.package_name()
            pkg_fld = item.package_folder(pkg_base_fld)
            pkg_fld.mkdir(parents=True, exist_ok=True)

            fl.write(
                f'"{frmt}"\t"{item.rmd_file()}"\t"{pack_name}"\t"{pkg_fld}"\n')
    fl.close()


def fingerprint_file(filename="fingerprints.json"):
    """save hashes of current items"""
    source_folders = subfolder(BASEFOLDER, EXCLUDE_FOLDER)
    hash_dict = {}
    for item in item_list(source_folders):
        hash_dict[item.name()] = item.fingerprint()
    # save
    p = Path(PACK_FOLDER)
    p.mkdir(parents=True, exist_ok=True)
    with open(p.joinpath(filename), 'w', encoding="utf-8") as fl:
        json.dump(hash_dict, fl)


def tarballs():
    with open(PACK_FOLDER + COMPILATION_INSTRUCTION, "r", encoding="utf-8") as fl:
        csv_reader = csv.reader(fl, delimiter='\t')
        for row in csv_reader:
            if row[0] in ("tar", "zip"):
                item = Item(Path(row[1]).parent)
                if row[0] == "zip":
                    item.zip(PACK_FOLDER + "zip", EXCLUDE_FILES)
                else:
                    item.tar(PACK_FOLDER + "tar", EXCLUDE_FILES)
