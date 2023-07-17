import hashlib
import os
from pathlib import Path


def hash_file(flname):
    hasher = hashlib.sha1()
    with open(flname, 'rb') as f:
        for block in iter(lambda: f.read(64 * 1024), b''):
            hasher.update(block)

    return hasher.digest()


def fix_foldername(file_path, dryrun=True):
    file_path = Path(file_path)
    sub_folder = file_path.parts[-2]
    correct_subfolder = os.path.splitext(file_path.parts[-1])[0]
    if sub_folder != correct_subfolder:
        new = file_path.parts[:-2] + (correct_subfolder,
                                      file_path.parts[-1])
        new = Path(*new)
        print(f"Rename {file_path.parent} ->\n       {new.parent}")
        if not dryrun:
            os.rename(file_path.parent, new.parent)
        return True
    else:
        return False


def check_duplicates(file_list):
    print("checking for duplicate items.")
    fl_dict = {}
    for fl in file_list:
        flhash = hash_file(fl)
        if flhash in fl_dict:
            fl_dict[flhash].append(fl)
        else:
            fl_dict[flhash] = [fl]

    duplicates = {}
    for k, v in fl_dict.items():
        if len(v)>1:
            duplicates[k] = v

    if len(duplicates):
        print("duplicates found")
        for cnt, files in enumerate(duplicates.values()):
            print(f"{cnt+1}.")
            for x in files:
                print(f"   - {x}")

    return duplicates

