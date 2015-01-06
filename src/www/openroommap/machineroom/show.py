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


import scipy
import scipy.linalg
import psycopg2 as db
import jinja2
import cgi
import cgitb
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

class MachineRoom:
    pass

class Measurement:
    pass

def main():
    conn = db.connect(database="machineroom",user="machineroom",password="machineroom",host="localhost")
    c = conn.cursor()
    c2 = conn.cursor()
    form = cgi.FieldStorage()
    machineroomid = form["machineroomid"].value

    edit_proportions = form.getfirst("prop") == "y"

    categories = load_categories(c)

    c.execute("SELECT name,location,purpose,comments,addedby FROM machineroom WHERE machineroomid = %s", [machineroomid])
    machineroom = MachineRoom()
    machineroom.machineroomid = machineroomid
    (machineroom.name,machineroom.location,machineroom.purpose,machineroom.comments,machineroom.addedby) = c.fetchone()

    (summary,total,pue) = (map(lambda (id,cat,prop):(cat,0),categories),0.0,0.0)
    
    c.execute("SELECT measurementsetid,updatetime,updatedby from measurementset where machineroomid=%s order by updatetime desc", (machineroomid))
    row = c.fetchone()
    if row:
        (measurementsetid,machineroom.updatetime, machineroom.updateby) = row
        machineroom.updatetime = machineroom.updatetime.strftime("%Y-%m-%d %H:%M:%S")
        (A,B) = ([],[])
        c.execute("SELECT measurementid,kiloWatt FROM measurement WHERE measurementsetid=%s", [measurementsetid])
        for (measurementid,kiloWatt) in c.fetchall():
            values = scipy.zeros(categories.__len__())
            c2.execute("SELECT proportionPercent, categoryid FROM datacategory WHERE measurementid = %s",[measurementid])
            for (prop,categoryid) in c2.fetchall():
                values[int(categoryid)] = float(prop) / 100.0
            A.append(values)
            B.append([kiloWatt])
        if (A.__len__() != 0 and B.__len__() != 0):
            A = scipy.mat(A)
            B = scipy.mat(B)
            C = scipy.linalg.lstsq(A,B)[0]

            (summary,total,puetotal) = ([],0.0,0.0)
            for (i,(id,cat,prop)) in enumerate(categories):
                summary.append((cat,C[i][0]))
                total += C[i][0]
                puetotal += C[i][0] * prop
                pue = total / puetotal
    else:
        (measurementsetid,machineroom.updatetime, machineroom.updateby) = (-1,'N/A','N/A')        


    details = []
    c.execute("SELECT measurementid,kiloWatt,observation FROM measurement WHERE measurementsetid = %s order by measurementid asc", ([measurementsetid]))
    for (measurementid,kiloWatt,observation) in c.fetchall():
        m = Measurement()
        m.measurementid = measurementid
        m.observation = observation
        m.kiloWatt = kiloWatt
        m.categories = []
        c2.execute("SELECT datacategoryid, categories.categoryid, proportionPercent FROM categories left outer join datacategory on categories.categoryid = datacategory.categoryid and datacategory.measurementid = %s order by categories.categoryid",[measurementid])
        for (datacategoryid, categoryid,prop) in c2.fetchall():
            if not (prop > 0 and prop <= 100):
                prop = 0
            m.categories.append((datacategoryid,categoryid,prop))
        details.append(m)

    for i in ['NEW1','NEW2','NEW3']:
        m = Measurement()
        m.measurementid = i
        m.categories = map(lambda (i,n,p):('NEW',i,0),categories)
        details.append(m)

    env = jinja2.Environment(loader=jinja2.FileSystemLoader("."),autoescape=True)
    template = env.get_template("show.html")
    print "Content-type: text/html\n\n"
    print template.render(                     
        machineroom = machineroom,
        categories = categories, 
        summary = summary, 
        total = total,
        pue = pue,
        details = details,
        edit_proportions = edit_proportions)

    conn.close()


if __name__ == "__main__":
    main()
