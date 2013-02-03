#!/usr/bin/python

import psycopg2 as db
import jinja2
import cgi
import cgitb
cgitb.enable()

class MachineRoom:
    pass

def main():
    conn = db.connect(database="machineroom",user="machineroom",password="machineroom",host="localhost")
    c = conn.cursor()
    form = cgi.FieldStorage()

    machinerooms = []

    c.execute("SELECT machineroomid,name,location,purpose,addedby FROM machineroom order by machineroomid asc")
    for (machineroomid,name,location,purpose,addedby) in c.fetchall():
        m = MachineRoom()
        m.machineroomid = machineroomid
        m.name = name
        m.location = location
        m.purpose = purpose
        m.addedby = addedby
        machinerooms.append(m)
    
    env = jinja2.Environment(loader=jinja2.FileSystemLoader("."),autoescape=True)
    template = env.get_template("list.html")
    print "Content-type: text/html\n\n"
    print template.render(                     
        machinerooms = machinerooms
        )

    conn.close()


if __name__ == "__main__":
    main()
