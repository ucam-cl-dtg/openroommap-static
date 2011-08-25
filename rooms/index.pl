#!/usr/bin/perl

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
    my $t = $dbh->selectall_arrayref("select x,y,label,floor_id from placed_item_table, placed_item_update_table where placed_item_table.last_update = placed_item_update_table.update_id and placed_item_table.item_def_id=47 and deleted = false");
    for my $tow (@$t) {
	my ($x,$y,$label,$floor) = @$tow;
	if (!$label) {
	    $label = "UNKNOWN";
	}
	my $suffix = 1;
	while (exists($people{$label.($suffix==1?"":"-$suffix")})) {
	    $suffix++;
	}
	$label = $label.($suffix==1?"":"-$suffix");
	$people{$label} = [$x,$y,$floor,"UNKNOWN"];
    }

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

    foreach my $q (@rooms) {
	my ($roomname,$floor,$poly) = @$q;
	foreach my $p (keys(%people)) {
	    my $p2 = $people{$p};
	    # if the person has not been mapped and they are on the same floor as this room
	    if ($p2->[3] eq "UNKNOWN" and $p2->[2] == $floor) {
		if ($poly->contains([$p2->[0],$p2->[1]])) {
		    $people{$p}->[2] = $roomname;
		}
	    }
	}
    }
    return \%people;
}

my $site = readfile("static.html", 1);

my $ccat = "";
my $peopleref = &roomlist();

# unpack the people in to a list of hashtables
# $rooms[0] = Ground floor
# $rooms[1] = First floor
# $rooms[2] = Second floor
# $rooms[3] = Other
# The keys of each hashtable are roomnames
# The values are references to arrays of crsids
my @rooms = ({},{},{},{});
foreach my $name (keys(%$peopleref)) {
    my $room = $peopleref->{$name}->[2];
    my $ref;
    if ($room =~ /^G/) { $ref = $rooms[0]; }
    elsif ($room =~ /^F/) { $ref = $rooms[1]; }
    elsif ($room =~ /^S/) { $ref = $rooms[2]; }
    else { $ref = $rooms[3]; }
    if (!exists($ref->{$room})) { $ref->{$room} = []; }
    push(@{$ref->{$room}},$name);
}

my $body="";
my @strings = ("Ground Floor","First Floor", "Second Floor", "Other");
# build a separate table for each floor
for(my $i=0;$i<4;$i++) {
    if (%{$rooms[$i]}) {
	$body .= "<div class='subtitle'>$strings[$i]</div>
<table style='margin: 0 1em'>";
	foreach my $room (sort keys(%{$rooms[$i]})) {
	    my $list = join(", ",sort @{$rooms[$i]->{$room}});
	    $body .= "<tr><td>&nbsp; $room &nbsp; </td><td>$list</td></tr>";
	}
	$body .= "</table>";
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
