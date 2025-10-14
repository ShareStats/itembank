import os
import re
import json
import deepl
import csv
import click
import shutil
from collections import Counter

def is_header_underline(line):
    stripped = line.strip()
    if len(stripped) < 3:
        return False
    return all(c == '=' for c in stripped) or all(c == '-' for c in stripped)

def merge_wrapped_text(lines):
    lines = lines.split('\n')
    output = []
    current_line = ''
    prev_was_header_underline = False
    inside_meta_info = False
    for line in lines:
        stripped = line.rstrip('\n')
        if stripped == '':
            if current_line:
                output.append(current_line)
                current_line = ''
            output.append('')
            prev_was_header_underline = False
        else:
            # Handle Meta-information section separately
            if stripped.startswith("Meta-information"):
                inside_meta_info = True
                if current_line:
                    output.append(current_line)
                    current_line = ''
                output.append(stripped)
                continue  # Skip merging the following lines under Meta-information

            if inside_meta_info:
                output.append(stripped)
                continue  # Do not merge this content with the previous one

            if prev_was_header_underline:
                output.append(current_line)
                current_line = stripped
                prev_was_header_underline = False
            else:
                if not current_line:
                    current_line = stripped
                    prev_was_header_underline = is_header_underline(current_line)
                else:
                    if current_line.endswith('  '):
                        output.append(current_line)
                        current_line = stripped
                        prev_was_header_underline = is_header_underline(current_line)
                    else:
                        if stripped.startswith(('*', '#', '=', '-', '`', 'Answerlist','Antwoordlijst','Meta-information', 'Solution')):
                            output.append(current_line)
                            current_line = stripped
                            prev_was_header_underline = is_header_underline(current_line)
                        else:
                            current_line += ' ' + stripped.lstrip()
                            prev_was_header_underline = is_header_underline(current_line)

    if current_line:
        output.append(current_line)

    return '\n'.join(output)

def post_cleanup(text):

    # Extract the meta-information block at the end
    match = re.search(r'\nMeta-information\n=+\n.*$', text, re.DOTALL)
    meta_info = match.group(0) if match else ''

    # Remove meta-information temporarily
    text_without_meta = text.replace(meta_info, '') if meta_info else text

    fixed_text = re.sub(r'\n{4,}', '\n\n', text_without_meta) # Replace 4 or more newlines with a double newline
    
    # Restore meta-information at the end
    merged_text = fixed_text.strip() + '\n'+meta_info if meta_info else fixed_text.strip()
    # Fix capitalization of answers
    lines = merged_text.split('\n')
    final_text = []
    for s in lines:
        if s.startswith('*'):
            s = '* ' + s[2].upper() + s[3:]
        final_text.append(s)

    return '\n'.join(final_text)

def find_refs(text):
    pattern = r'!\[\]\(.*?\)|\[[^\]]+\]\(.*?\)'  # Matches both images and links
    refs = re.findall(pattern, text)
    return refs 

def find_math_expressions(text):
    pattern = r"\$[^$]+\$"  # Matches inline math expressions enclosed in single dollar signs
    return re.findall(pattern, text)

def extract_r_code_blocks(rmd_text):
    
    pattern = r"(```.*?\n.*?```)" # Matches R code blocks enclosed by triple backticks.
    code_blocks = re.findall(pattern, rmd_text, re.DOTALL)
    return code_blocks

def parse_text_to_dict(text):
    meta_info = {}
    current_key = None
    current_value = []

    for line in text.split("\n"):
        if ":" in line:  # Detects a new key-value pair
            if current_key is not None:  # Save previous key-value pair
                meta_info[current_key] = "\n".join(current_value).strip()
            
            key, value = line.split(":", 1)  # Split only on first ":"
            current_key = key.strip()
            current_value = [value.strip()]
        else:
            # Append to the current value (handling multi-line text)
            current_value.append(line.strip())

    # Add the last key-value pair
    if current_key is not None:
        meta_info[current_key] = "\n".join(current_value).strip()

    return meta_info


def parse_file(path_to_file):

    with open(path_to_file, 'r') as f:
        plain_text = f.read()

    question = {
        'start':'Question',
        'end':"Solution"
    }

    solution = {
        'start':'Solution',
        'end':"Meta-information"
    }

    question_text = plain_text[plain_text.find(question['start'])+len(question['start']):plain_text.find(question['end'])]
    solution_text = plain_text[plain_text.find(solution['start'])+len(solution['start']):plain_text.find(solution['end'])]
    meta_text = plain_text[plain_text.find(solution['end'])+len(solution['end']):]

    meta_info = parse_text_to_dict(meta_text)
    if meta_info['exname'].endswith('.Rmd'):
        meta_info['exname'] = meta_info['exname'][:-len('.Rmd')]

    folder, _ = os.path.split(path_to_file)
    if folder.endswith('-nl'):
        meta_info['exextra[Language]'] = "English"
        
        meta_info['exname'] = meta_info['exname'][:-3]+'-en'
        
        src_lang = 'NL'
        trg_lang = 'EN'

    elif folder.endswith('-en'):
        meta_info['exextra[Language]'] = "Dutch"
        meta_info['exname'] = meta_info['exname'][:-3]+'-nl'
        src_lang = 'EN'
        trg_lang = 'NL'
    
    return {
        'file':path_to_file,
        'full_text':plain_text,
        'question': question_text.strip(),
        'solution':solution_text.strip(),
        'meta_info':meta_info,
        'meta_text': meta_text.strip(),
        'question_refs':find_refs(question_text),
        'solution_refs':find_refs(solution_text),
        'code_blocks_question':extract_r_code_blocks(question_text),
        'code_blocks_solution':extract_r_code_blocks(solution_text),
        'math_question': find_math_expressions(question_text),
        'math_solution': find_math_expressions(solution_text),
        'trg_lang':trg_lang,
        'src_lang':src_lang
    }


def extract_text_sections(question, refs, code_blocks, math):
    # Collect all separators
    separators = refs + code_blocks + math

    # Ensure each separator exists in the text before proceeding
    separators = [sep for sep in separators if sep in question]

    # Sort separators by their position in the text
    sorted_separators = sorted(separators, key=lambda sep: question.find(sep))

    result = []
    start = 0

    for index, sep in enumerate(sorted_separators):
        pos = question.find(sep, start)
        
        if pos != -1:  # Only proceed if the separator is found
            chunk_text = question[start:pos].strip()  # Trim spaces
            if chunk_text:  # Avoid empty chunks
                result.append({
                    "index": index,
                    "text": chunk_text,
                    "sep": sep
                })
            start = pos + len(sep)

    # Capture any remaining text after the last separator
    remaining_text = question[start:].strip()
    if remaining_text:
        result.append({
            "index": len(result),
            "text": remaining_text,
            "sep": None
        })

    return result

def create_glossaries(path_to_csv_file, deepl_client):
    # Find and delete old glossaries
    glossaries = deepl_client.list_glossaries()
    for glossary in glossaries:
        deepl_client.delete_glossary(glossary)

    with open(path_to_csv_file, 'r',encoding='latin') as csv_file:
        reader = csv.reader(csv_file) 
        nl_en = {}
        en_nl = {}
        for row in reader:
            if row[-1] == "EN":
                nl_en[row[0]] = row[1]
            elif row[-1] == "NL":
                en_nl[row[0]] = row[1]
        
        nl_en_glossary = deepl_client.create_glossary(
            "nl_en",
            source_lang="NL",
            target_lang="EN",
            entries=nl_en,
        )
        
        en_nl_glossary = deepl_client.create_glossary(
            "en_nl",
            source_lang="EN",
            target_lang="NL",
            entries=en_nl,
        )

        for glossary in deepl_client.list_glossaries():
            print(f"CREATED {glossary.name} WITH ID: {glossary.glossary_id}")
    
    target_glossaries = {
        'NL':en_nl_glossary,
        'EN':nl_en_glossary}

    return target_glossaries



def copy_folder_contents(src_folder, dest_folder,trg_lang):

    renamed_src_folder = src_folder[:-2]+ trg_lang.lower()

    if not os.path.exists(os.path.join(dest_folder,renamed_src_folder)):
        os.makedirs(os.path.join(dest_folder,renamed_src_folder))
    
    for filename in os.listdir(src_folder):
        src_file = os.path.join(src_folder, filename)
        dest_file = os.path.join(os.path.join(dest_folder,renamed_src_folder), filename)
        
        if os.path.isfile(src_file) and not src_file.endswith('.Rmd'):
            shutil.copy2(src_file, dest_file)
            print(f"Copied: {src_file} -> {dest_file}")
    return renamed_src_folder


@click.command()
@click.option('--deepl_api_key', required=True, help='DeepL API Key')
@click.option('--input_folder', required=True, help='Folder containing Rmd files')
@click.option('--output_folder', required=True, help='Folder to write the translated files to')
@click.option('--path_to_csv_file', required=True, help='Path to CSV glossary file')
def main(deepl_api_key, input_folder,output_folder, path_to_csv_file):
    
    deepl_client = deepl.Translator(deepl_api_key)
    target_glossaries = create_glossaries(path_to_csv_file=path_to_csv_file, deepl_client=deepl_client)
    parsed = [parse_file(os.path.join(input_folder,i)) for i in os.listdir(input_folder) if i.endswith('.Rmd')]
    
    for data in parsed:
        res = extract_text_sections(data["question"], data["question_refs"], data["code_blocks_question"],data["math_question"])
        data.update({'question_chunks':res})
        res = extract_text_sections(data["solution"], data["solution_refs"], data["code_blocks_solution"],data["math_solution"])
        data.update({'solution_chunks':res})
    
    for content in parsed:
        new_text = content['full_text']
        for chunk in content['question_chunks']:
            if chunk['text'] in content['full_text']:
                try:
                    translation = deepl_client.translate_text(chunk['text'],source_lang=content['src_lang'],  target_lang=content['trg_lang'],glossary=target_glossaries[content['trg_lang']])
                except: # Wierd stuff where transaltion to English has to be EN-US or EN-GB. Not very foolproof???
                    translation = deepl_client.translate_text(chunk['text'],source_lang=content['src_lang'],  target_lang='EN-US',glossary=target_glossaries[content['trg_lang']])
                new_text = new_text.replace(chunk['text'],merge_wrapped_text(translation.text))

        for chunk in content['solution_chunks']:
            if chunk['text'] in content['full_text']:
                try:
                    translation = deepl_client.translate_text(chunk['text'],source_lang=content['src_lang'], target_lang=content['trg_lang'], glossary=target_glossaries[content['trg_lang']])
                except: # Wierd stuff where transaltion to English has to be EN-US or EN-GB. Not very foolproof???
                    translation = deepl_client.translate_text(chunk['text'],source_lang=content['src_lang'], target_lang='EN-US', glossary=target_glossaries[content['trg_lang']])
                new_text = new_text.replace(chunk['text'],merge_wrapped_text(translation.text))
        
        if content['meta_info']['extype'] == 'string':
            try:
                content['meta_info']['exsolution'] = deepl_client.translate_text(content['meta_info']['exsolution'], source_lang=content['src_lang'], target_lang=content['trg_lang'],glossary=target_glossaries[content['trg_lang']]).text
            except: # Wierd stuff where transaltion to English has to be EN-US or EN-GB. Not very foolproof???
                content['meta_info']['exsolution'] = deepl_client.translate_text(content['meta_info']['exsolution'], source_lang=content['src_lang'], target_lang='EN-US',glossary=target_glossaries[content['trg_lang']]).text
        

        new_meta = 16*"="+'\n'+'\n'.join([f"{k}: {v}" for k,v in content['meta_info'].items()])
        new_text = new_text.replace(content['meta_text'],new_meta)
        new_text = post_cleanup(new_text)
        new_file_name = content['meta_info']['exname']+'.Rmd'

        renamed_input_folder = copy_folder_contents(input_folder,output_folder,content['trg_lang'])
        with open(os.path.join(os.path.join(output_folder,renamed_input_folder),new_file_name),'w') as f:
            f.write(new_text)

if __name__ == "__main__":
    # EXAMPLE USAGE:
    # ~$ python3 translate_folder.py \
    # --deepl_api_key 'your-deepl-api-key' \
    # --input_folder ./Assumptions/eur-assumptions-105-nl \
    # --output_folder ./ \
    # --path_to_csv_file ./glossary.csv
    main()


