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
