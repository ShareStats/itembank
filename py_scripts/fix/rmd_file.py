import os
import re
from collections import OrderedDict
from os import path
from pathlib import Path
import chardet


class MetaInfo():

    def __init__(self):
        self.parameter = OrderedDict({})
        self.meta_section_line = -1


    def parse(self, txtline: str, line_cnt: int):

        if self.meta_section_line > -1:
            para = MetaInfo.extract_parameter(txtline)
            if para is not None:
                self.parameter.update(para)
        elif txtline.startswith("Meta-information"):
            self.meta_section_line = line_cnt

    @property
    def exsolution(self):
        try:
            return self.parameter["exsolution"]
        except:
            return ""

    @staticmethod
    def extract_parameter(txt):
        # extract parameter for text line

        m = re.match(r"\s*\w+[\[\]\w]+:", txt)
        if m is not None:
            return {txt[:m.end()-1].strip(): txt[m.end():].strip()}

        return None

    def parameter_str(self):
        rtn = ""
        for k, v in self.parameter.items():
            rtn += "{}: {}\n".format(k, v)
        return rtn

class SolutionAnswerList(object):
    """parses answerlist solution"""

    def __init__(self) -> None:
        self._solution_section = False
        self.solution_str = ""
        self.answerlist_content = []
        self.answer_list_line = -1

    def parse(self, txtline: str, line_cnt: int):
        if txtline.startswith("Solution"):
            self._solution_section = True
        elif self._solution_section and txtline.startswith("Answerlist"):
                self.answer_list_line = line_cnt
        elif txtline.startswith("Meta-information"):
                self._solution_section = False
        elif self._solution_section and self.answer_list_line > -1:
            self.answerlist_content.append(txtline)
            if txtline.startswith("* Correct") or txtline.startswith("* True"):
                self.solution_str += "1"
            elif txtline.startswith("* Incorrect") or txtline.startswith("* False"):
                self.solution_str += "0"

    def has_empty_answerlist(self):
        return len(self.solution_str)==0 and self.answer_list_line>0



class RmdFile(object):

    def __init__(self, file_path):
        self.file_path = Path(file_path)
        self.answerlist = SolutionAnswerList()
        self.meta_info = MetaInfo()
        self.content = []

    def guess_encoding(self):
        if self.file_path.is_file():
            with open(self.file_path, "rb") as fl:
                return chardet.detect(fl.read())
        else:
            return None


    def parse(self):

        if self.file_path.is_file():
            with open(self.file_path, "r", encoding="utf-8") as fl:
                self.content = fl.readlines()

        for cnt, txtline in enumerate(self.content):
            self.answerlist.parse(txtline, cnt)
            self.meta_info.parse(txtline, cnt)

    def issues(self):
        issues = []



        if self.answerlist.has_empty_answerlist():
            issues.append("Empty Answerlist")
        elif len(self.answerlist.solution_str) >0 and \
            self.meta_info.exsolution != self.answerlist.solution_str:
            issues.append("Mismatch answerlist & exsolution : "
                          f"{self.answerlist.solution_str} != {self.meta_info.exsolution}")

        return issues


def get_filelist(folder, ignore_error=False):
    file_list = []
    multiple_rmd = {}
    for (dirpath, _, filenames) in os.walk(folder):
        multiple_rmd[dirpath] = []
        for flname in filenames:
            if flname.lower().endswith(".rmd"):
                file_list.append(path.join(dirpath, flname))
                multiple_rmd[dirpath].append(flname)
        if len(multiple_rmd[dirpath]) < 2:
            del multiple_rmd[dirpath]

    if len(multiple_rmd) and not ignore_error:
        print("---- Multiple rmd files in one folder:")
        for key, value in multiple_rmd.items():
            print(f"   {key}: {value}")
        print("----")
        raise RuntimeError("Multiple rmd files in one folders (see list above)")
    return file_list

