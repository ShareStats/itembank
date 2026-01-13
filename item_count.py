import pandas as pd

from packaging import all_items

# count
d = {}
for item in all_items():
    x = item.name.split("-")
    lang = x[-1]
    item_name = "-".join(x[:-1]) # item name without extension
    if lang not in d:
        d[lang] = []
    d[lang].append({"name":item_name, lang: 1})


print(f"Languages based on item: {tuple(d.keys())}")
print("  Item names have to end with language codes (like '-nl'). If numbers appear as 'languages'\n"
      "  is a bug in the database. These items will not appear in the final database.\n"
      "  Please check these items!\n\n")

# merge NL & EN databases
df = pd.merge(pd.DataFrame(d["nl"]),
              pd.DataFrame(d["en"]),
              on='name', how='outer').fillna(0)
df['biling'] = (df['nl'] == 1) & (df['en'] == 1)
df['nl_only'] = (df['nl'] == 1) & (df['en'] == 0)
df['en_only'] = (df['nl'] == 0) & (df['en'] == 1)

print(f"n items: {len(df)}")
print(f"NL only: {df.nl_only.sum()}")
print(f"EN only: {df.en_only.sum()}")
print(f"Bilingual: {df.biling.sum()}")
