import json
from pathlib import Path

from .item import Item


def item_list(source_folders):
    """list of all items in multiple folders"""
    rtn = []
    for fld in source_folders:
        for src in Path(fld).iterdir():
            try:
                rtn.append(Item(src))
            except RuntimeError:
                pass
    return rtn


def subfolder(base_folder, exclude_folder):
    """list of all items in multiple folders"""
    rtn = []
    for subdir in Path(base_folder).iterdir():
        if subdir.is_dir() and not subdir.name.startswith(".") \
                and subdir.name not in exclude_folder:
            rtn.append(subdir)
    return rtn


def load_fingerprint_file(flpath):
    with open(flpath, 'r', encoding="utf-8") as fl:
        return json.load(fl)


def changed_items_list(source_folders, hash_dict):
    """returns list with item that have a different fingerprint as in the
    hash_dict"""
    rtn = []
    for item in item_list(source_folders):
        try:
            changed = hash_dict[item.name()] != item.fingerprint()
        except KeyError:
            changed = True
        if changed:
            rtn.append(item)
    return rtn
