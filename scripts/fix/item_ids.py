import atexit
import uuid

from . import rmd_file

ID_FIELD = "exextra[ID]"
ID_LENGTH = 5

class Logger:

    def __init__(self, logfile: str):
        if len(logfile) > 3:
            self.fl = open(logfile, "a", encoding="utf-8")
        else:
            self.fl = None

    def log(self, message: str):
        print(message)
        if self.fl is not None:
            self.fl.write(message + "\n")

    def close(self):
        if self.fl is not None:
            self.fl.close()

log = Logger("") # file name or "" to disable logging
atexit.register(log.close)

def new_id():
    return uuid.uuid4().hex[:ID_LENGTH]

def read_ids() -> dict[str, str | None]:
    file_list = rmd_file.get_filelist(".", ignore_error=True)
    ids = {}
    for file_path in file_list:
        rmd = rmd_file.RmdFile(file_path)
        rmd.parse()
        if file_path in ids:
            print("DUPLICATE FILE PATH??? " + file_path)
        try:
            ids[file_path] = rmd.meta_info.parameter[ID_FIELD]
        except KeyError:
            ids[file_path] = None
    return ids

def check_duplicate_ids(id_dict:dict):
    check_dict = {}

    duplicates_occured = False
    for (fl, id_) in id_dict.items():
        if id_ is None:
            continue
        if id_ in check_dict:
            log.log(f"[Duplicate ID] {id_} {fl} and {check_dict[id_]}")
            duplicates_occured = True
        else:
            check_dict[id_] = fl

    if duplicates_occured:
        print("\nDuplicate IDs found! Please fix these issues! Delete ID in one file and create a new one.")


def write_file_and_add_id(file_path:str,
                      file_content: list[str],
                      new_id: str,
                      add_after_line: str="exsection:") -> None:

    with open(file_path, "w", encoding="utf-8") as fl:
        for line in file_content:
            fl.write(line)
            if line.startswith(add_after_line):
                fl.write(f"{ID_FIELD}: {new_id}\n")

def add_missing_ids(id_dict:dict, testrun:bool = True):

    existing_ids = {i for i in id_dict.values() if i is not None}
    no_id_files = [fp for fp, i in id_dict.items() if i is None]
    changes_required = False
    for file_path in no_id_files:
        if testrun:
            log.log(f"[ID missing] {file_path}")
            changes_required = True
        else:
            rmd = rmd_file.RmdFile(file_path)
            rmd.parse()
            new_unique_id = new_id()
            while new_unique_id in existing_ids:
                new_unique_id = new_id()
            log.log(f"[new ID] {new_unique_id} to {file_path}")
            existing_ids.add(new_unique_id)
            write_file_and_add_id(file_path, rmd.content, new_unique_id)
    return changes_required
