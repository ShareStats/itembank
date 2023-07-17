"""Fixes incorrect folder structure

The script runs per default in dry mode and merely displaces the changes
to be made. Use option "--rename" to actually perform the changes

O. Lindemann

"""

import sys
from fix.folder_structure import check_duplicates, fix_foldername
from fix.rmd_file import get_filelist


if __name__ == "__main__":
    try:
        dryrun = sys.argv[1] != "--rename"
    except:
        dryrun = True

    d = check_duplicates(get_filelist(".", ignore_error=True))

    #fix folder names
    cnt = 0
    for file_path in get_filelist("."):
        if fix_foldername(file_path, dryrun):
            cnt += 1

    print(f"{cnt} folders renamed.")
    if dryrun:
        print("\nDryrun: No data changed, call script with '--rename' to apply changes.")
