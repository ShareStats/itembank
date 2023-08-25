"""Fixes incorrect item names

The script runs per default in dry mode and merely displaces the changes
to be made. Use option "--rename" to actually perform the changes

O. Lindemann

"""

import sys
import os
from fix.rmd_file import get_filelist, RmdFile


if __name__ == "__main__":
    try:
        dryrun = sys.argv[1] != "--rename"
    except IndexError:
        dryrun = True
    cnt = 0
    for file_path in get_filelist("."):
        fl_path = RmdFile(file_path).file_path
        name = fl_path.name
        correct = name.replace(" ", "_")

        if name != correct:
            cnt += 1
            print(f"{cnt} rename {name}")
            if not dryrun:
                cn = fl_path.parent.joinpath(correct)
                os.rename(fl_path, cn)

    if dryrun:
        print("\nDryrun: No data changed, call script with '--rename' to apply changes.")
