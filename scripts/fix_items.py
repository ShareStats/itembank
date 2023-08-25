from fix import rmd_file


if __name__ == "__main__":
    lst = rmd_file.get_filelist(".")
    print(len(lst))

    for file_path in lst:
        rmd = rmd_file.RmdFile(file_path)
        issues = rmd.issues()

        if len(issues):
            print(file_path)
            for cnt, txt in enumerate(issues):
                print(f"   {cnt+1}. {txt}")
        exit()

