#!/usr/bin/python

import psycopg2 as db
import cgi
import cgitb
import os
cgitb.enable()

def load_categories(c):
    categories = []
    expectedid = 0
    c.execute("SELECT categoryid,name,puePercent FROM categories order by categoryid asc")
    for (categoryid,name,puePercent) in c.fetchall():
        assert(expectedid == categoryid)
        expectedid += 1
        categories.append( (categoryid,name,float(puePercent)/100.0) )
    return categories

def main():
    conn = db.connect(database="machineroom",user="machineroom",password="machineroom",host="localhost")
    c = conn.cursor()

    form = cgi.FieldStorage()
    machineroomid = form["machineroomid"].value
    try:
        user = os.environ["REMOTE_USER"]
    except KeyError:
        user = None
    if not user:
        if os.uname()[1] == "earlybird.cl.cam.ac.uk":
            user = "TESTING"
        else:
            raise Exception("No REMOTE_USER available")

    categories = load_categories(c)
    
    c.execute("INSERT into measurementset(machineroomid,updatetime,updatedby) values(%s,now(),%s)",(machineroomid,user))
    c.execute("SELECT currval('seqmeasurementsetid')")
    measurementsetid = c.fetchone()[0]

    for recordid in form.getlist("record"):
        observation = form.getfirst("observation_%s" % recordid)
        kilowatt = form.getfirst("kilowatt_%s" % recordid)
        if (observation and kilowatt > 0):
            c.execute("INSERT into measurement(measurementsetid,kilowatt,observation) values (%s,%s,%s)",[measurementsetid,kilowatt,observation])
            c.execute("SELECT currval('seqmeasurementid')")
            measurementid = c.fetchone()[0]
            for (id,name,pue) in categories:
                proportionid = form.getfirst("proportionid_%s_%d" % (recordid,id))
                proportion = form.getfirst("proportion_%s_%d" % (recordid,id))
                if proportion == None:
                    proportion = 0
                proportion = int(proportion)
                if (proportion > 0 and proportion <= 100):
                        c.execute("INSERT INTO datacategory(measurementid,proportionPercent,categoryid) values (%s,%s,%s)",[measurementid,proportion,id])
    
    conn.commit()
    conn.close()

    requesturi = "http://%s%s/show.py?machineroomid=%s" % (os.environ["HTTP_HOST"], os.path.dirname(os.environ["REQUEST_URI"]), machineroomid)
    print "Location: %s\n" % (requesturi)

if __name__ == "__main__":
    main()

