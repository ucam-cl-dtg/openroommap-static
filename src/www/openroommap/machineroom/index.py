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
