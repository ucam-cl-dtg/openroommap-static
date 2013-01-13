
all: tiles floor0-allocation floor1-allocation floor2-allocation install

install:
	scp tile/* open-room-map.cl.cam.ac.uk:/var/www/research/dtg/openroommap/static/tile/
	scp floor*-allocation.pdf open-room-map.cl.cam.ac.uk:/var/www/research/dtg/openroommap/static/
	perl clean-db.pl

connect:
	ssh open-room-map.cl.cam.ac.uk -n -N -L 5432:localhost:5432


tiles:
	for floor in `seq 0 1 2`; do ./make-tiles.sh $$floor rooms,objects subtile; done
	for floor in `seq 0 1 2`; do ./make-tiles.sh $$floor people subpeople; done


floor0-allocation:
	perl generate-tiles.pl 0 people,rooms,objects,desksOnly > floor0-allocation.svg
	inkscape floor0-allocation.svg -A floor0-allocation.pdf

floor1-allocation:
	perl generate-tiles.pl 1 people,rooms,objects,desksOnly > floor1-allocation.svg
	inkscape floor1-allocation.svg -A floor1-allocation.pdf

floor2-allocation:
	perl generate-tiles.pl 2 people,rooms,objects,desksOnly > floor2-allocation.svg
	inkscape floor2-allocation.svg -A floor2-allocation.pdf

labels:
	for floor in `seq 0 1 2`; do python floor$$floor-labels.svg temp sublabel-$$floor; done


copy-index:
	scp index.pl open-room-map:/var/www/research/dtg/openroommap/static

clean:
	rm -rf tile
	mkdir -p tile
