dummy:

init-db:
	rm -f machinerooms.sqlite3
	cat db.sql | sqlite3 machinerooms.sqlite3

install:
	scp *.py *.html root@open-room-map.cl.cam.ac.uk:/var/www/research/dtg/openroommap/machineroom
	ssh root@open-room-map.cl.cam.ac.uk chown www-data.www-data "/var/www/research/dtg/openroommap/machineroom/*"

install-db:
	scp machinerooms.sqlite3 root@open-room-map.cl.cam.ac.uk:/var/www/research/dtg/openroommap/machineroom
	ssh root@open-room-map.cl.cam.ac.uk chown www-data.www-data "/var/www/research/dtg/openroommap/machineroom/*"