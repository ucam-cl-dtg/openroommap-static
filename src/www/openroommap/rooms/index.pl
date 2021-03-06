#!/usr/bin/perl

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


use strict;
use DBI;
use Math::Polygon;

my $dbh = DBI->connect("dbi:Pg:dbname=openroommap;host=localhost;port=5432","orm","openroommap", {AutoCommit => 0}) or &error("Failed to connect to database\n");

sub readfile
{
	my ($filepath, $die) = @_;
	local $/; # slurp mode, allows to read whole file at once
	my $contents = "";
	if (open FILE, $filepath) {$contents = <FILE>; close FILE;}
	elsif ($die) {die "Could not read file \"$filepath\"";}
	return $contents;
} 

# returns a reference to a hash table
# the keys of the hash table are people
# the values are the room they are in
# if a person appears more than once then they are given suffix (2) (3) etc.
sub roomlist
{
    my %people = ();
    # 47 is the magic number for a person object
    my $t = $dbh->selectall_arrayref("select x,y,label,floor_id,timestamp,placed_item_table.item_id from placed_item_table, placed_item_update_table where placed_item_table.last_update = placed_item_update_table.update_id and placed_item_table.item_def_id=47 and deleted = false");
    for my $tow (@$t) {
	my ($x,$y,$label,$floor,$timestamp,$itemid) = @$tow;
	if ($timestamp =~ /(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d).\d+/) {
	    $timestamp = "$1-$2-$3 $4:$5";
	}

	if (!$label) {
	    $label = "UNKNOWN";
	}
	my $suffix = 1;
	while (exists($people{$label.($suffix==1?"":"-$suffix")})) {
	    $suffix++;
	}
	$label = $label.($suffix==1?"":"-$suffix");
	$people{$label} = [$x,$y,$floor,"UNKNOWN",$timestamp,$itemid];
    }

    # we now have a map of people labels to location,floor,room(unknown) and time of update


    my @rooms = ();
    # recover the floor_id by cross linking the room polygon with the submap polygon table
    my $r = $dbh->selectall_arrayref("SELECT name,roompoly_table.polyid,submapid from room_table,roompoly_table,submappoly_table where room_table.roomid = roompoly_table.roomid and roompoly_table.polyid = submappoly_table.polyid");
    for my $row (@$r) {
	my ($roomname,$polyid,$floor) = @$row;
	my $s = $dbh->selectall_arrayref("SELECT x,y from floorpoly_table where polyid = $polyid order by vertexnum");
	my @poly = ();
	for my $sow (@$s) {
	    my ($x,$y) = @$sow;
	    push(@poly,[$x,$y]);
	}
	my $poly = Math::Polygon->new(@poly,$poly[0]);
	push(@rooms,[$roomname,$floor,$poly]);
    }

    # we now have a list of rooms with names, floor and polygon


    foreach my $q (@rooms) {
	my ($roomname,$floor,$poly) = @$q;
	foreach my $p (keys(%people)) {
	    my $p2 = $people{$p};
	    # if the person has not been mapped and they are on the same floor as this room
	    if ($p2->[3] eq "UNKNOWN" and $p2->[2] == $floor) {
		if ($poly->contains([$p2->[0],$p2->[1]])) {
		    $people{$p}->[3] = $roomname;
		}
	    }
	}
    }

    foreach my $person (keys(%people)) {
	my ($x,$y,$floor,$room,$timestamp,$itemid) = @{$people{$person}};
	my $minDist = 1e10;
	my $minRoom = $room;
	if ($room eq "UNKNOWN") {
	    foreach my $q (@rooms) {		
		my ($roomname,$rfloor,$poly) = @$q;
		if ($rfloor == $floor) {
		    my ($cx, $cy) = @{$poly->centroid()};
		    my $dist = ($x - $cx)**2 + ($y - $cy) ** 2;
		    if ($dist < $minDist) {
			$minDist = $dist;
			$minRoom = $roomname;
		    }
		}
	    }
	}
	$people{$person}->[6] = $minRoom;
    }

    return \%people;
}

my $site = readfile("static.html", 1);

my $ccat = "";

my $peopleref = &roomlist();
# peopleref is a reference to a hash of people labels to [x,y,floor,roomname,timestamp]

# unpack the people in to a list of hashtables
# $rooms[0] = Ground floor
# $rooms[1] = First floor
# $rooms[2] = Second floor
# $rooms[3] = Other
# The keys of each hashtable are roomnames
# The values are references to arrays of crsids
my @rooms = ({},{},{},{});
foreach my $name (keys(%$peopleref)) {
    my $room = $peopleref->{$name}->[3];
    my $ref;
    if ($room =~ /^G/) { $ref = $rooms[0]; }
    elsif ($room =~ /^F/) { $ref = $rooms[1]; }
    elsif ($room =~ /^S/) { $ref = $rooms[2]; }
    else { $ref = $rooms[3]; }
    if (!exists($ref->{$room})) { $ref->{$room} = []; }
    my $roomlistref = $ref->{$room};
    my $timestamp = $peopleref->{$name}->[4];
    my $itemid = $peopleref->{$name}->[5];
    my $nearest = $peopleref->{$name}->[6];
    push(@$roomlistref,[$name,$timestamp,$itemid,$nearest]);
}

# now rooms is a list of 4 references to hashes
# each hash contains a mapping from room name to a list reference
# each list contains a list of pairs of people labels and timestamps

my $body="";
my @strings = ("Ground Floor","First Floor", "Second Floor", "Other");
# build a separate table for each floor
for(my $i=0;$i<4;$i++) {
    # if there are any assignments for this floow
    if (%{$rooms[$i]}) {
	$body .= "<div class='subtitle'>$strings[$i]</div>";
	# foreach room assigned
	foreach my $room (sort keys(%{$rooms[$i]})) {
	    my @people = sort {$a->[0] cmp $b->[0]} @{$rooms[$i]->{$room}};
	    my $first = 1;
	    foreach my $person (@people) {
		my ($name,$timestamp,$itemid,$nearest) = @$person;
		if ($first ==1) {
		    $body .= "<div style='clear:both;height:1em'></div>";
		    $body .= "<div style='width:7em;float:left'>$room</div>";
		    $first = 0;
		}
		else {		
		    $body .= "<div style='width:7em;float:left'>&nbsp;</div>";
		}
		$body .= "\n<div style='width:15em;float:left'>$name</div><!-- id = $itemid, nearest = $nearest -->";
		$body .= "<div style='width:20em;float:left'>$timestamp</div>";
		$body .= "<div style='clear:both'></div>";
	    }
	}
    }
}

$site =~ s/<!--ORM_BODY-->/$body/;
print "Content-type: text/html

$site";

sub error() {
    my ($m) = @_;
    print "Content-type:text/plain\n\n$m";
    exit(0);
}
