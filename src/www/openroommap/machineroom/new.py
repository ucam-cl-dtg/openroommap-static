#!/usr/bin/python

#*******************************************************************************
# Copyright 2014 Digital Technology Group, Computer Laboratory
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#*******************************************************************************

import psycopg2 as db
import cgi
import cgitb
import os
cgitb.enable()

def main():
    conn = db.connect(database="machineroom",user="machineroom",password="machineroom",host="localhost")

    c = conn.cursor()

    form = cgi.FieldStorage()

    name = form.getfirst("name")
    location = form.getfirst("location")
    purpose = form.getfirst("purpose")
    comment = form.getfirst("comment")
    
    try:
        user = os.environ["REMOTE_USER"]
    except KeyError:
        user = None
    if not user:
        if os.uname()[1] == "earlybird.cl.cam.ac.uk":
            user = "TESTING"
        else:
            raise Exception("No REMOTE_USER available")

    c.execute("INSERT into machineroom(name,location,purpose,comments,addedby) values (%s,%s,%s,%s,%s)",[name,location,purpose,comment,user])
    c.execute("SELECT currval('seqmachineroomid')")
    machineroomid = c.fetchone()[0]
    conn.commit()
    conn.close()

    requesturi = "https://%s%s/show.py?machineroomid=%s" % (os.environ["HTTP_HOST"], os.path.dirname(os.environ["REQUEST_URI"]), machineroomid)
    
    print "Location: %s\n" % (requesturi)

if __name__ == "__main__":
    main()

