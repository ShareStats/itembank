# This script fixes certain translation errors that were missed when generating the glossary. 
# For further translations, please incorporate these fixes into the glossary when possible. 
import os

# Fix Antwoordlijst -> Answerlist

base_folders = [
    "Assumptions",
    "Descriptive-statistics",
    "Distributions",
    "Factor-analysis",
    "Inferential_Statistics",
    "Measurement-Level",
    "Probability",
    "Reliability",
    "Variable-type"]


res = []

counter=0

for folder in base_folders:
    for subdir, _, files in os.walk(folder):
        if subdir.endswith('-nl'):
            for file in files:
                fpath = os.path.join(subdir,file)
                if fpath.endswith('.Rmd'):
                    with open(fpath,'r') as f:
                        content = f.read()
                    if 'Antwoordlijst' in content:
                        updated_content = content.replace('Antwoordlijst','Answerlist')
                        with open(fpath,'w') as f:
                            f = f.write(updated_content)
                        counter+=1

print(f"Fixed {counter} occurances of 'Antwoordlijst' in -nl items")