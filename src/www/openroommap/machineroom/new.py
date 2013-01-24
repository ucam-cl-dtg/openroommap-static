#!/usr/bin/python

import sqlite3
import cgi
import cgitb
import os
cgitb.enable()

def main():
    conn = sqlite3.connect("/var/www/cgi-bin/machinerooms.sqlite3")
    c = conn.cursor()

    form = cgi.FieldStorage()

    name = form.getfirst("name")
    location = form.getfirst("location")
    purpose = form.getfirst("purpose")
    comment = form.getfirst("comment")
    user = os.environ["REMOTE_USER"]
    if not user:
        raise Exception("No REMOTE_USER available")

    c.execute("INSERT into machineroom(name,location,purpose,comments,addedby) values (?,?,?,?,?)",[name,location,purpose,comment,user])
    machineroomid = c.lastrowid
    conn.commit()
    conn.close()

    print "Location: http://localhost/cgi-bin/show.py?machineroomid=%s\n" % (machineroomid)

if __name__ == "__main__":
    main()

