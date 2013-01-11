#!/usr/bin/python

import scipy
import scipy.linalg
import sqlite3
import jinja2
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

class MachineRoom:
    pass

class Measurement:
    pass

def main():
    conn = sqlite3.connect("machinerooms.sqlite3")
    c = conn.cursor()
    c2 = conn.cursor()
    form = cgi.FieldStorage()
    machineroomid = form["machineroomid"].value

    categories = load_categories(c)

    c.execute("SELECT name,location,purpose,comments,addedby FROM machineroom WHERE machineroomid = ?", [machineroomid])
    machineroom = MachineRoom()
    machineroom.machineroomid = machineroomid
    (machineroom.name,machineroom.location,machineroom.purpose,machineroom.comments,machineroom.addedby) = c.fetchone()
    
    c.execute("SELECT measurementsetid,datetime(updatetime,'unixepoch'),updatedby from measurementset where machineroomid=? order by updatetime desc", (machineroomid))
    row = c.fetchone()
    if row:
        (measurementsetid,machineroom.updatetime, machineroom.updateby) = row

        (A,B) = ([],[])
        for (measurementid,kiloWatt) in c.execute("SELECT measurementid,kiloWatt FROM measurement WHERE measurementsetid=?", [measurementsetid]):
            values = scipy.zeros(categories.__len__())
            for (prop,categoryid) in c2.execute("SELECT proportionPercent, categoryid FROM datacategory WHERE measurementid = ?",[measurementid]):
                values[int(categoryid)] = float(prop) / 100.0
            A.append(values)
            B.append([kiloWatt])
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
        (summary,total,pue) = (map(lambda (id,cat,prop):(cat,0),categories),0.0,0.0)

    details = []
    for (measurementid,kiloWatt,observation) in c.execute("SELECT measurementid,kiloWatt,observation FROM measurement WHERE measurementsetid = ? order by measurementid asc", ([measurementsetid])):
        m = Measurement()
        m.measurementid = measurementid
        m.observation = observation
        m.kiloWatt = kiloWatt
        m.categories = []
        for (datacategoryid, categoryid,prop) in c2.execute("SELECT datacategoryid, categories.categoryid, proportionPercent FROM categories left outer join datacategory on categories.categoryid = datacategory.categoryid and datacategory.measurementid = ? order by categories.categoryid",[measurementid]):
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
        details = details)

    conn.close()


if __name__ == "__main__":
    main()
