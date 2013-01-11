#!/usr/bin/python

import sqlite3
import jinja2
import cgi
import cgitb
cgitb.enable()

class MachineRoom:
    pass

def main():
    conn = sqlite3.connect("servers.sqlite3")
    c = conn.cursor()
    form = cgi.FieldStorage()

    machinerooms = []

    for (machineroomid,name,location,purpose,addedby) in c.execute("SELECT machineroomid,name,location,purpose,addedby FROM machineroom order by machineroomid asc"):
        m = MachineRoom()
        m.machineroomid = machineroomid
        m.name = name
        m.location = location
        m.purpose = purpose
        m.addedby = addedby
        machinerooms.append(m)
    
    env = jinja2.Environment(loader=jinja2.FileSystemLoader("/var/www/cgi-bin"),autoescape=True)
    template = env.get_template("list.html")
    print "Content-type: text/html\n\n"
    print template.render(                     
        machinerooms = machinerooms
        )

    conn.close()


if __name__ == "__main__":
    main()
