import os
import sys
from os import path

class MetaInfo():

    def __init__(self):
        self.exsolution = ""
        self.parameter


    def parse(self, txtline: str, line_cnt: int):
        if txtline.startswith("exsolution:"):
            self.exsolution = txtline.split(":")[1].strip()


class SolutionAnswerList(object):
    """parses answerlist solution"""

    def __init__(self) -> None:
        self._solution_section = True
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

    def __init__(self, filename):
        self.filename = filename
        self.answerlist = SolutionAnswerList()
        self.meta_info = MetaInfo()
        try:
            with open(filename, "r", encoding="utf-8") as fl:
                self.content = fl.readlines()
        except:
            self.content = []

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


def get_filelist(folder):
    file_list = []
    for (dirpath, _, filenames) in os.walk(folder):
        for flname in filenames:
            if flname.lower().endswith(".rmd"):
                file_list.append(path.abspath(path.join(dirpath, flname)))
    return file_list


lst = get_filelist(".")
print(len(lst))
for name in lst:
    rmd = RmdFile(name)
    issues = rmd.issues()
    if len(issues):
        print(name)
        for cnt, txt in enumerate(issues):
            print(f"   {cnt+1}. {txt}")



