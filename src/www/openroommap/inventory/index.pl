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
#!/usr/bin/perl

use strict;
use DBI;

my $dbh = DBI->connect("dbi:Pg:dbname=openroommap;host=localhost;port=5432","orm","openroommap", {AutoCommit => 0}) or &error("Failed to connect to database\n");
my $r = $dbh->selectall_arrayref("select item_definition_table.name,item_definition_table.category, item_definition_table.image_file, item_definition_table.description,count(item_definition_table.name) from placed_item_table, placed_item_update_table, item_definition_table where placed_item_table.item_id = placed_item_update_table.item_id and placed_item_update_table.update_id = placed_item_table.last_update and deleted = 'f' and item_definition_table.def_id = placed_item_table.item_def_id group by item_definition_table.name,item_definition_table.ordering,item_definition_table.category, item_definition_table.image_file, item_definition_table.description order by item_definition_table.ordering");

&hdr();
my $ccat = "";
foreach my $row (@$r) {
    my ($name,$cat,$image_file,$desc,$count) = @$row;
    if ($ccat ne $cat) {
	print "<div class='category'>$cat</div>";
	$ccat = $cat;
    }
    print "<div class='item'><div class='name'>$name</div><div class='count'>$count</div></div>";
}
print "</body></html>";

sub error() {
    my ($m) = @_;
    print "Content-type:text/plain\n\n$m";
    exit(0);
}

sub hdr() {
    print<<EOF;
Content-type: text/html


<html>
  <head>
    <style>
.category { font-weight: bold; clear:both; padding-top:1em }
.item { clear:both; margin-left:1em } 
.name { float:left; width: 20em;}
.count { width: 5em; float:left }
    </style>
  </head>
  <body>
EOF
}
