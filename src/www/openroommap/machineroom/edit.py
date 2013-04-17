#!/usr/bin/python

import scipy
import scipy.linalg
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
    c2 = conn.cursor()
    form = cgi.FieldStorage()
    machineroomid = form["machineroomid"].value

    c.execute("SELECT name,location,purpose,comments,addedby FROM machineroom WHERE machineroomid = %s", [machineroomid])
    machineroom = MachineRoom()
    machineroom.machineroomid = machineroomid
    (machineroom.name,machineroom.location,machineroom.purpose,machineroom.comments,machineroom.addedby) = c.fetchone()

    env = jinja2.Environment(loader=jinja2.FileSystemLoader("."),autoescape=True)
    template = env.get_template("edit.html")
    print "Content-type: text/html\n\n"
    print template.render(                     
        machineroom = machineroom
    )

    conn.close()


if __name__ == "__main__":
    main()
