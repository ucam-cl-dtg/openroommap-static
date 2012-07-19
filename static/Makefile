all: clean subtiles floor0-labels floor1-labels floor2-labels
	scp tile/* root@open-room-map:/var/www/research/dtg/openroommap/static/tile/

connect:
	ssh open-room-map -L 5432:localhost:5432

subtiles:
	for floor in `seq 2 -1 0`; do perl generate-tiles.pl $$floor > map.svg; for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape map.svg -e map.png -w $$WIDTH -b "#FFFFFF"; convert -crop 256x map.png tile-$$floor-$$a-%d.png; for b in tile-$$floor-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm tile-*; done; done

floor0-labels:
	for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape floor0-labels.svg -e floor0-labels.png -w $$WIDTH; convert -crop 256x floor0-labels.png label-0-$$a-%d.png; for b in label-0-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm label-*; done;

floor1-labels:
	for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape floor1-labels.svg -e floor1-labels.png -w $$WIDTH; convert -crop 256x floor1-labels.png label-1-$$a-%d.png; for b in label-1-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm label-*; done;

floor2-labels:
	for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape floor2-labels.svg -e floor2-labels.png -w $$WIDTH; convert -crop 256x floor2-labels.png label-2-$$a-%d.png; for b in label-2-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm label-*; done;

clean:
	rm -rf tile
	mkdir -p tile
