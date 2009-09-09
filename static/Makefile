subtiles:
	for floor in `seq 2 -1 0`; do perl generate-tiles.pl $$floor > map.svg; for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape map.svg -e map.png -w $$WIDTH -b "#FFFFFF"; convert -crop 256x map.png tile-$$floor-$$a-%d.png; for b in tile-$$floor-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm tile-*; done; done

floor0-labels:
	for a in `seq 0 1 5`; do WIDTH=$$(( (1<<$$a)*256 )); inkscape floor0-labels.svg -e floor0-labels.png -w $$WIDTH; convert -crop 256x floor0-labels.png label-0-$$a-%d.png; for b in label-0-$$a-*; do convert -crop x256 $$b tile/sub`basename $$b .png`-%d.png;done;rm label-*; done;