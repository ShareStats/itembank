from scripts.fix.item_ids import add_missing_ids, check_duplicate_ids, read_ids

if __name__ == "__main__":
    ids = read_ids()
    if add_missing_ids(ids, testrun=True):
        resp = input("\n\nShall I create IDs for these files (yes/no)? ")
        if resp.lower() == "yes":
            add_missing_ids(ids, testrun=False)
            print("Changes are not yet committed!")
        else:
            print("Nothing done!")

    print("\nChecking duplicates")
    check_duplicate_ids(ids)
