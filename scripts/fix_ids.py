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
        if file_path in ids:
            print("DUPLICATE FILE PATH???", file_path)
        try:
            ids[file_path] = rmd.meta_info.parameter[ID_FIELD]
        except KeyError:
            ids[file_path] = None
    return ids

def write_file_and_add_id(file_path:str,
                      file_content: list[str],
                      new_id: str,
                      add_after_line: str="exsection:") -> None:

    with open(file_path, "w", encoding="utf-8") as fl:
        for line in file_content:
            fl.write(line)
            if line.startswith(add_after_line):
                fl.write(f"{ID_FIELD}: {new_id}\n")

if __name__ == "__main__":
    ids = read_ids()
    existing_ids = {i for i in ids.values() if i is not None}
    no_id_files = [fp for fp, i in ids.items() if i is None]
    for file_path in no_id_files:
        rmd = rmd_file.RmdFile(file_path)
        rmd.parse()
        new_unique_id = new_id()
        while new_unique_id in existing_ids:
            new_unique_id = new_id()
        print(f"[new ID] {new_unique_id} to {file_path}")
        write_file_and_add_id(file_path, rmd.content, new_unique_id)

