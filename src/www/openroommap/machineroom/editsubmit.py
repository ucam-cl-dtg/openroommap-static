#!/usr/bin/python

import psycopg2 as db
import cgi
import cgitb
import os
cgitb.enable()

def main():
    conn = db.connect(database="machineroom",user="machineroom",password="machineroom",host="localhost")

    c = conn.cursor()

    form = cgi.FieldStorage()
    
    id = form.getfirst("id")
    name = form.getfirst("name")
    location = form.getfirst("location")
    purpose = form.getfirst("purpose")
    comment = form.getfirst("comment")
    
    try:
        user = os.environ["REMOTE_USER"]
    except KeyError:
        user = None
    if not user:
        if os.uname()[1] == "open-room-map-2":
            user = "TESTING"
        else:
            raise Exception("No REMOTE_USER available on machine %s" % os.uname()[1])

    c.execute("update machineroom set name=%s,location=%s,purpose=%s,comments=%s where machineroomid=%s",[name,location,purpose,comment,id])
    conn.commit()
    conn.close()

    requesturi = "https://%s%s/show.py?machineroomid=%s" % (os.environ["HTTP_HOST"], os.path.dirname(os.environ["REQUEST_URI"]), id)
    
    print "Location: %s\n" % (requesturi)

if __name__ == "__main__":
    main()

