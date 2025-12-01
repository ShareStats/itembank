import uuid

from fix import rmd_file

ID_FIELD = "exextra[ID]"

def new_id():
    return uuid.uuid4().hex[:8]

def read_ids() -> dict[str, str | None]:
    file_list = rmd_file.get_filelist(".", ignore_error=True)
    ids = {}
    for file_path in file_list:
        rmd = rmd_file.RmdFile(file_path)
        rmd.parse()
        try:
            ids[file_path] = rmd.meta_info.parameter[ID_FIELD]
        except KeyError:
            ids[file_path] = None
    return ids


if __name__ == "__main__":
    ids = read_ids()
    existing_ids = {i for i in ids.values() if i is not None}
    no_id_files = [fp for fp, i in ids.items() if i is None]

