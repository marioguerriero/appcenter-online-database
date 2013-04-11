import apt
from ConfigParser import SafeConfigParser
import os
import json

# APT Cache
print "Opening Cache..."
cache = apt.Cache()

# Info class
class Info:
    def __init__(self, id, name, summary, description, version, category, icon, author, website, license, cost=0.0):
        self.id = id
        self.name = name
        self.summary = summary
        self.description = description
        self.version = version
        self.category = category
        self.icon = icon
        self.author = author
        self.website = website
        self.license = license
        self.cost = cost
        
    def to_dictionary(self, data=None):
        dic = { "appid": self.id,
                "name": self.name,
                "description": self.description,
                "summary": self.summary,
                "category": self.category,
                "version": self.version,
                "icon": self.icon,
                "author": self.author,
                "website": self.website,
                "license": self.license,
                "cost": self.cost }
        return dic
      
        

# Load app-install-data infos
print "Parsing infos..."
infos = []

for file in os.listdir("/usr/share/app-install/desktop"):
    try:
        path = "/usr/share/app-install/desktop/" + file
        parser = SafeConfigParser()
        parser.read(path)
        pkg = cache[parser.get("Desktop Entry", "X-AppInstall-Package")]
        # id
        try:
            id = parser.get("Desktop Entry", "X-AppInstall-Package")
        except:
            id = ""
        # name
        try:
            name = parser.get("Desktop Entry", "Name")
        except:
            name = ""
        # description
        try:
            description = pkg.description
        except:
            description = ""
        # summary
        try:
            summary = pkg.summary
        except:
            summary = ""
        # version
        try:
            version = pkg.versions[0].version
        except:
            version = "0.1"
        # icon
        try:
            icon = parser.get("Desktop Entry", "Icon")
        except:
            icon = "applications-other"
        # icon
        try:
            category = parser.get("Desktop Entry", "Category").split(";")[0]
        except:
            category = "Others"
        # author FIXME
        try:
            author = "Unknown"
        except:
            author = "Unknown"
        # website
        try:
            website = pkg.versions[0].homepage
        except:
            website = "http://elementaryos.org"
        # license FIXME
        try:
            license = "Open source"
        except:
            license = "Open source"
        # Load app info
        info = Info(id, name, summary, description, version, category, icon, author, website, license)
        infos.append(info)
    except:
        pass

# Everything in JSON file
output = open("apps-database.json", "wb")

for info in infos:
    output.write(json.dumps(info.to_dictionary(), indent=4, separators=(",", ": ")))

output.close()

print "Done!"