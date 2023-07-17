import hashlib
import tarfile
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

HASH_ALGORITHMS = "sha256"

class Item(object):

    def __init__(self, item_folder):
        self.path = Path(item_folder)
        if not self.path.is_dir():
            raise RuntimeError("Please specify an existing item folder.")

    def name(self):
        """item name"""
        return str(self.path)

    def package_name(self, suffix=""):
        """filename of the resulting package"""
        return self.path.name + suffix

    def package_folder(self, basefolder):
        """path to the folder of the resulting package"""
        return Path(basefolder).joinpath(self.path.parent)

    def package_path(self, basefolder, suffix=""):
        """path to the resulting package"""
        return self.package_folder(basefolder).joinpath(
                    self.package_name(suffix))

    def file_list(self, exculde_suffixes=()):
        """returns list of of all files"""
        rtn = []
        for fl in self.path.rglob("*"):
            if fl.is_file():
                excl = [fl.name.endswith(s) for s in exculde_suffixes]
                if sum(excl) == 0:
                    rtn.append(fl)
        return rtn

    def zip(self, pkg_basefolder, exculde_suffixes):
        """creates zip file"""
        zip_path = self.package_path(pkg_basefolder, ".zip")
        print(zip_path.name)
        zipf = ZipFile(zip_path, 'w', ZIP_DEFLATED)
        for fl in self.file_list(exculde_suffixes):
            rel_path = fl.relative_to(self.path.parent)
            #print("-", rel_path)
            zipf.write(fl, rel_path)
        zipf.close()

    def tar(self, pkg_basefolder, exculde_suffixes):
        """creates tar file, if update is required"""
        tar_path = self.package_path(pkg_basefolder, ".tar")
        print(tar_path.name)
        tarf = tarfile.open(tar_path, "w")
        for fl in self.file_list(exculde_suffixes):
            rel_path = fl.relative_to(self.path.parent)
            #print("-", rel_path)
            tarf.add(fl, rel_path)
        tarf.close()

    def rmd_file(self):
        """name of the Rmd file"""
        return self.path.joinpath(self.path.name + ".Rmd")

    def fingerprint(self):
        """Data finger print
        Hashes all file, sorts hashes and generates hash of sorted hashes
        see https://expyriment.org/dataintegrityfingerprint/
        """

        fl_hashes = [_hash_file(fl) for fl in self.file_list()]

        hasher = hashlib.new(HASH_ALGORITHMS)
        for h in sorted(fl_hashes):
            hasher.update(h.encode("utf-8"))

        return hasher.hexdigest()

    def package_needs_update(self, package_basefolder, package_suffix, fingerprint_dict):
        """returns True, if
        - package file not defined,
        - old package fingerprint is unknown (not in fingerprint_dict) or
        - package has different fingerprint
        """
        assert isinstance(fingerprint_dict, dict)
        pp = self.package_path(package_basefolder, package_suffix)
        if not pp.is_file() or self.name() not in fingerprint_dict:
            return True
        else:
            return fingerprint_dict[self.name()] != self.fingerprint()



def _hash_file(filepath):
    # helper function for file hashing
    hasher = hashlib.new(HASH_ALGORITHMS)
    with open(filepath, 'rb') as f:
        for block in iter(lambda: f.read(64 * 1024), b''):
            hasher.update(block)
    return hasher.hexdigest()
