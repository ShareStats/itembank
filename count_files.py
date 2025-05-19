import os
import pandas as pd

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

for folder in base_folders:
    for subdir, _, files in os.walk(folder):
        for file in files:
            extension = file.split('.')[-1]
            if extension != 'Rmd': 
                res.append((folder,subdir.split('/')[-1],extension.lower()))

df = pd.DataFrame(
    res,
    columns=[
        'folder',
        'item',
        'extension'
    ])


pivot_df = df.groupby(['folder', 'item', 'extension']).size().unstack(fill_value=0).reset_index()


pivot_df.to_excel('file_extensions.xlsx',index=False)