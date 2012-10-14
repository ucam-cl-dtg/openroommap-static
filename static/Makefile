all: subtiles floor0-labels floor1-labels floor2-labels floor0-people floor1-people floor2-people
	scp tile/* root@open-room-map:/var/www/research/dtg/openroommap/static/tile/
	perl clean-db.pl

connect:
	ssh open-room-map -L 5432:localhost:5432

subtiles:
	for floor in `seq 2 -1 0`; do perl generate-tiles.pl $$floor 0 > map.svg; for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape map.svg -e map.png -w $$WIDTH -b "#FFFFFF"; convert -crop 256x map.png tile-$$floor-$$a-%d.png; for b in tile-$$floor-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm tile-*; done; done

floor0-people:
	perl generate-tiles.pl 0 1 > floor0-people.svg;	for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape floor0-people.svg -e floor0-people.png -w $$WIDTH; convert -crop 256x floor0-people.png people-0-$$a-%d.png; for b in people-0-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm people-*; done;

floor1-people:
	perl generate-tiles.pl 1 1 > floor1-people.svg;	for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape floor1-people.svg -e floor1-people.png -w $$WIDTH; convert -crop 256x floor1-people.png people-1-$$a-%d.png; for b in people-1-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm people-*; done;

floor2-people:
	perl generate-tiles.pl 2 1 > floor2-people.svg;	for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape floor2-people.svg -e floor2-people.png -w $$WIDTH; convert -crop 256x floor2-people.png people-2-$$a-%d.png; for b in people-2-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm people-*; done;

floor0-labels:
	for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape floor0-labels.svg -e floor0-labels.png -w $$WIDTH; convert -crop 256x floor0-labels.png label-0-$$a-%d.png; for b in label-0-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm label-*; done;

floor1-labels:
	for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape floor1-labels.svg -e floor1-labels.png -w $$WIDTH; convert -crop 256x floor1-labels.png label-1-$$a-%d.png; for b in label-1-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm label-*; done;

floor2-labels:
	for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape floor2-labels.svg -e floor2-labels.png -w $$WIDTH; convert -crop 256x floor2-labels.png label-2-$$a-%d.png; for b in label-2-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm label-*; done;

copy-index:
	scp index.pl root@open-room-map:/var/www/research/dtg/openroommap/static

clean:
	rm -rf tile
	mkdir -p tile
