#!/usr/bin/python

import sqlite3
import cgi
import cgitb
cgitb.enable()

def load_categories(c):
    categories = []
    expectedid = 0
    for (categoryid,name,puePercent) in c.execute("SELECT categoryid,name,puePercent FROM categories order by categoryid asc"):
        assert(expectedid == categoryid)
        expectedid += 1
        categories.append( (categoryid,name,float(puePercent)/100.0) )
    return categories

def main():
    conn = sqlite3.connect("/var/www/cgi-bin/servers.sqlite3")
    c = conn.cursor()

    form = cgi.FieldStorage()
    machineroomid = form["machineroomid"].value
    user = os.environ["REMOTE_USER"]
    if not user:
        raise Exception("No REMOTE_USER available")

    categories = load_categories(c)
    
    c.execute("INSERT into measurementset(machineroomid,updatetime,updatedby) values(?,strftime('%s','now'),?)",(machineroomid,user))
    measurementsetid = c.lastrowid

    for recordid in form.getlist("record"):
        observation = form.getfirst("observation_%s" % recordid)
        kilowatt = form.getfirst("kilowatt_%s" % recordid)
        if (observation and kilowatt > 0):
            c.execute("INSERT into measurement(measurementsetid,kilowatt,observation) values (?,?,?)",[measurementsetid,kilowatt,observation])
            measurementid = c.lastrowid
            for (id,name,pue) in categories:
                proportionid = form.getfirst("proportionid_%s_%d" % (recordid,id))
                proportion = form.getfirst("proportion_%s_%d" % (recordid,id))
                if proportion == None:
                    proportion = 0
                proportion = int(proportion)
                if (proportion > 0 and proportion <= 100):
                        c.execute("INSERT INTO datacategory(measurementid,proportionPercent,categoryid) values (?,?,?)",[measurementid,proportion,id])
    
    conn.commit()
    conn.close()

    print "Location: http://localhost/cgi-bin/show.py?machineroomid=%s\n" % (machineroomid)

if __name__ == "__main__":
    main()

