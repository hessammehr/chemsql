import json
import xmltodict

with open("heck_reaction.xdl", "r") as f:
    d = xmltodict.parse(f.read())

with open("heck_reaction_xdl.json", "w") as f:
    json.dump(d, f)