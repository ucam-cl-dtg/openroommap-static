drop table datacategory;
drop table categories;
drop table measurement;
drop table measurementset;
drop table machineroom;

drop sequence seqmachineroomid;
drop sequence seqmeasurementsetid;
drop sequence seqmeasurementid;
drop sequence seqcategoryid;
drop sequence seqdatacategoryid;

create sequence seqmachineroomid;
create sequence seqmeasurementsetid;
create sequence seqmeasurementid;
create sequence seqcategoryid;
create sequence seqdatacategoryid;

CREATE TABLE machineroom (machineroomid integer not null primary key default nextval('seqmachineroomid'), name varchar(255) not null, location text not null, purpose text not null, comments text,addedby varchar(255) not null);

create table measurementset(measurementsetid integer not null primary key default nextval('seqmeasurementsetid'), machineroomid integer not null references machineroom(machineroomid), updatetime timestamp not null, updatedby varchar(255) not null);

CREATE TABLE measurement (measurementid integer not null primary key default nextval('seqmeasurementid'), measurementsetid integer not null references measurementset(measurementsetid), kiloWatt integer not null, observation text);

create table categories(categoryid integer not null primary key default nextval('seqcategoryid'), name varchar(255) not null, puePercent integer not null);
CREATE TABLE datacategory(datacategoryid integer not null primary key default nextval('seqdatacategoryid'), measurementid integer not null references measurement(measurementid), proportionPercent integer not null, categoryid integer not null references categories(categoryid));

insert into categories(categoryid,name,puePercent) values (0,'Computers',100);
insert into categories(categoryid,name,puePercent) values (1,'Networking',100);
insert into categories(categoryid,name,puePercent) values (2,'Cooling',0);
insert into categories(categoryid,name,puePercent) values (3,'UPS',0);
insert into categories(categoryid,name,puePercent) values (4,'Lighting',0);

insert into machineroom(machineroomid,name,location,purpose,comments,addedby) values (0,'WGB-GN09','Computer Laboratory, William Gates Building, 15 JJ Thomson Avenue, CB3 0FD','Main infrastructure machine room','Originally designed for higher power levels.  Great deal of power reduction means air con system over capacity (and 10 years old). Monitoring system available via http://www.cl.cam.ac/meters/','acr31');
insert into measurementset(measurementsetid,machineroomid,updatetime,updatedby) values (0,0,now(),'acr31');
insert into measurement(measurementid, measurementsetid, kiloWatt, observation) values (0,0,23.3,'Total');
insert into measurement(measurementid, measurementsetid, kiloWatt, observation) values (1,0,12.2,'IT Power');
insert into measurement(measurementid, measurementsetid, kiloWatt, observation) values (2,0,11.5,'Cooling');
insert into datacategory(datacategoryid, measurementid, proportionPercent, categoryid) values (0,0,100,0);
insert into datacategory(datacategoryid, measurementid, proportionPercent, categoryid) values (1,0,100,2);
insert into datacategory(datacategoryid, measurementid, proportionPercent, categoryid) values (2,0,100,1);
insert into datacategory(datacategoryid, measurementid, proportionPercent, categoryid) values (3,1,100,0);
insert into datacategory(datacategoryid, measurementid, proportionPercent, categoryid) values (4,1,100,1);
insert into datacategory(datacategoryid, measurementid, proportionPercent, categoryid) values (5,2,100,2);

insert into machineroom(machineroomid,name,location,purpose,comments,addedby) values (1,'WGB-SE11','Computer Laboratory, William Gates Building, 15 JJ Thomson Avenue, CB3 0FD','Machine room for research machines','Cold/warm isle separation not yet in place. Monitoring system available via http://www.cl.cam.ac/meters/','acr31');
insert into measurementset(measurementsetid,machineroomid,updatetime,updatedby) values (1,1,now(),'acr31');
insert into measurement(measurementid, measurementsetid, kiloWatt, observation) values (3,1,17,'IT Power');
insert into measurement(measurementid, measurementsetid, kiloWatt, observation) values (4,1,12.2,'AirCon');
insert into datacategory(datacategoryid, measurementid, proportionPercent, categoryid) values (6,3,100,0);
insert into datacategory(datacategoryid, measurementid, proportionPercent, categoryid) values (7,3,100,1);
insert into datacategory(datacategoryid, measurementid, proportionPercent, categoryid) values (8,4,100,2);

select setval('seqmachineroomid',max(machineroomid)) from machineroom;
select setval('seqmeasurementsetid',max(measurementsetid)) from measurementset;
select setval('seqmeasurementid',max(measurementid)) from measurement;
select setval('seqcategoryid', max(categoryid)) from categories;
select setval('seqdatacategoryid', max(datacategoryid)) from datacategory;
