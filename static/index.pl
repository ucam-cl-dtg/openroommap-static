#!/usr/bin/perl

use strict;
use CGI;

my $q = new CGI;

my $search = $q->param("q");
my $reqhighlight = $q->param("highlight");
my $reqzoom = $q->param("zoom");
my $reqlabels = $q->param("labels") == 1 ? "true" : "false";
my $reqfloor = $q->param("floor");

if ($q->param("h")) {
    $search = $q->param("h");
    $reqhighlight = 1;
    $reqzoom = 0;
    $reqlabels = "true";
    $reqfloor = "";
}

if ($q->param("s")) {
    $search = $q->param("s");
    $reqhighlight = 0;
    $reqzoom = 1;
    $reqlabels = "false";
    $reqfloor = "";
}

$reqzoom =~ s/\D//g;
$reqfloor =~ s/\D//g;

my %rooms = (
    "Corr" => [998.81,1038.27,1001.54,1046.15,0],
    "C_Stairs_L1" => [971.43,1002.66,975.81,1008.93,1],
    "C_Stairs_L2" => [971.43,1002.66,975.81,1008.76,2],
    "FC01" => [970.66,1042.77,975.93,1046.16,1],
    "FC03" => [970.66,1037.97,975.93,1042.67,1],
    "FC04" => [964.18,1041.27,968.81,1046.16,1],
    "FC05" => [970.66,1034.37,975.93,1037.87,1],
    "FC06" => [964.18,1037.97,968.81,1041.17,1],
    "FC07" => [970.66,1031.37,975.93,1034.27,1],
    "FC08" => [964.18,1034.37,968.81,1037.87,1],
    "FC09" => [970.56,1028.37,975.93,1031.27,1],
    "FC10" => [964.18,1031.37,968.21,1034.27,1],
    "FC11" => [970.66,1025.37,975.93,1028.27,1],
    "FC12" => [964.18,1028.37,968.21,1031.27,1],
    "FC13" => [970.66,1022.37,975.93,1025.27,1],
    "FC14" => [964.18,1025.37,968.21,1028.27,1],
    "FC15" => [970.66,1019.37,975.93,1022.27,1],
    "FC16" => [964.18,1022.37,968.31,1025.27,1],
    "FC17" => [970.66,1016.79,975.93,1019.27,1],
    "FC18" => [964.18,1019.37,968.21,1022.27,1],
    "FC20" => [964.18,1016.42,968.21,1019.27,1],
    "FC22" => [964.22,1010.92,968.21,1016.22,1],
    "FC24" => [964.07,999.12,971.31,1009.05,1],
    "FC_Balcony" => [964.23,997.17,971.17,999.12,1],
    "FC_Corridor" => [968.21,1010.82,971.39,1046.16,1],
    "FC_Kitchen" => [971.31,998.45,975.93,1002.38,1],
    "FC_Toilet" => [971.35,1010.96,976.04,1016.6,1],
    "FE01" => [991.11,1004.45,993.89,1009.08,1],
    "FE02" => [991.11,1010.92,993.89,1016.2,1],
    "FE03" => [988.1,1004.45,991.01,1009.08,1],
    "FE04" => [987.51,1010.92,991.01,1016.2,1],
    "FE05" => [985.11,1004.45,988.01,1009.08,1],
    "FE06" => [984.51,1010.82,987.41,1016.2,1],
    "FE07" => [982.1,1004.45,985.01,1009.08,1],
    "FE08" => [979.71,1010.92,984.41,1016.2,1],
    "FE09" => [979.11,1004.45,982.01,1009.08,1],
    "FE10" => [976.22,1010.92,979.61,1016.2,1],
    "FE11" => [976.22,1004.45,979.01,1009.08,1],
    "FE12" => [960.51,1010.92,963.89,1016.2,1],
    "FE13" => [961.11,1004.45,963.89,1009.07,1],
    "FE14" => [955.11,1010.92,960.41,1016.2,1],
    "FE15" => [958.11,1004.45,961.01,1009.07,1],
    "FE17" => [955.11,1004.45,958.01,1009.17,1],
    "FE18" => [952.11,1010.92,955.01,1016.2,1],
    "FE19" => [951.51,1004.45,955.01,1009.07,1],
    "FE20" => [949.11,1010.92,952.01,1016.2,1],
    "FE21" => [946.71,1004.45,951.41,1009.07,1],
    "FE22" => [943.31,1010.92,949.01,1016.2,1],
    "FE23" => [943.11,1004.45,946.61,1009.07,1],
    "FE24" => [940.22,1010.82,943.01,1016.2,1],
    "FE25" => [940.22,1004.45,943.01,1009.07,1],
    "FE_Corridor" => [935.21,1002.55,998.91,1011,1],
    "FE_Kitchen" => [935.39,1011,937.4,1012.66,1],
    "FN01" => [1000.21,1034.07,1005.93,1046.16,1],
    "FN04" => [994.18,1041.27,998.21,1046.16,1],
    "FN05" => [1000.21,1028.57,1005.93,1034.07,1],
    "FN06" => [994.18,1037.37,998.21,1041.17,1],
    "FN07" => [1000.21,1016.37,1005.93,1028.57,1],
    "FN08" => [994.18,1033.47,998.21,1037.27,1],
    "FN10" => [994.18,1028.37,998.21,1033.37,1],
    "FN11" => [1000.21,1013.37,1005.93,1016.27,1],
    "FN12" => [994.18,1024.77,998.21,1028.27,1],
    "FN13" => [1000.21,1010.37,1005.93,1013.27,1],
    "FN14" => [994.18,1019.97,998.21,1024.67,1],
    "FN15" => [1000.21,1007.37,1005.93,1010.27,1],
    "FN16" => [994.18,1016.79,998.21,1019.87,1],
    "FN17" => [1000.21,1004.37,1005.93,1007.27,1],
    "FN19" => [1000.21,1001.37,1005.93,1004.27,1],
    "FN21" => [1001.31,998.45,1005.93,1001.27,1],
    "FN34" => [994.18,999.12,1001.31,1001.88,1],
    "FN_Balcony" => [994.31,997.17,1001.17,999.12,1],
    "FN_Corridor" => [997.11,1001.88,1000.21,1054.77,1],
    "FN_Kitchen" => [996.87,1014.91,998.73,1016.61,1],
    "FN_Toilet" => [994.07,1011,998.77,1016.65,1],
    "FS02" => [928.18,1042.77,932.21,1046.16,1],
    "FS03" => [934.11,1040.37,939.93,1046.16,1],
    "FS04" => [928.18,1037.97,932.21,1042.67,1],
    "FS05" => [934.11,1037.37,939.93,1040.27,1],
    "FS06" => [928.18,1034.37,932.21,1037.87,1],
    "FS07" => [934.11,1025.37,939.93,1037.27,1],
    "FS08" => [928.18,1031.97,932.21,1034.27,1],
    "FS10" => [928.18,1028.37,932.21,1031.87,1],
    "FS12" => [928.18,1024.77,932.21,1028.27,1],
    "FS13" => [934.11,1022.37,939.93,1025.27,1],
    "FS14" => [928.18,1019.97,932.21,1024.67,1],
    "FS15" => [934.11,1019.37,939.93,1022.27,1],
    "FS16" => [928.18,1016.37,932.21,1019.87,1],
    "FS17" => [934.11,1016.79,939.93,1019.27,1],
    "FS18" => [928.18,1011.27,932.21,1016.27,1],
    "FS20" => [928.18,1007.97,932.21,1011.17,1],
    "FS22" => [928.18,1004.97,932.21,1007.87,1],
    "FS24" => [928.18,1001.97,932.21,1004.87,1],
    "FS35" => [935.31,998.45,939.93,1002.38,1],
    "FS_Balcony" => [928.26,997.17,935.21,999.12,1],
    "FS_Corridor" => [928.18,999.12,935.43,1046.16,1],
    "FS_Toilet" => [935.35,1010.96,940.04,1016.6,1],
    "FW01" => [1000.21,1046.49,1006.29,1052.16,1],
    "FW03" => [995.91,1052.49,998.21,1054.67,1],
    "FW04" => [993.03,1052.49,995.81,1054.67,1],
    "FW05" => [990.16,1052.49,992.93,1054.67,1],
    "FW06" => [988.25,1052.16,990.16,1059.56,1],
    "FW07" => [985.8,1052.49,988.25,1054.67,1],
    "FW08" => [985.8,1054.77,988.25,1059.46,1],
    "FW09" => [982.18,1059.56,990.06,1064.2,1],
    "FW11" => [990.16,1054.77,1000.11,1065.6,1],
    "FW13" => [1000.21,1052.49,1001.41,1060.77,1],
    "FW14" => [1000.2,1060.77,1005.93,1064.2,1],
    "FW15" => [1001.41,1055.97,1005.93,1060.67,1],
    "FW16" => [1001.41,1052.45,1005.93,1055.87,1],
    "FW19" => [971.31,1052.29,974.21,1054.93,1],
    "FW22" => [957.79,1052.49,962.62,1054.98,1],
    "FW26" => [933.87,1053.57,942.32,1064.2,1],
    "FW27" => [942.32,1058.61,946.12,1059.87,1],
    "FW28" => [942.42,1059.87,946.12,1063.12,1],
    "FW_Landing" => [931.94,1046.16,997.11,1059.82,1],
    "Reception" => [971.31,1042.77,975.94,1046.15,0], # alias
    "GC01" => [971.31,1042.77,975.94,1046.15,0],
    "GC03" => [971.31,1037.37,975.94,1042.77,0],
    "GC04" => [964.19,1041.27,968.81,1046.15,0],
    "GC05" => [971.31,1033.77,975.94,1037.27,0],
    "GC06" => [964.19,1036.77,968.81,1041.17,0],
    "GC07" => [971.31,1029.27,975.94,1033.67,0],
    "GC08" => [964.19,1033.37,968.81,1036.67,0],
    "GC09" => [971.31,1025.37,975.94,1029.17,0],
    "GC10" => [964.19,1027.47,968.81,1033.37,0],
    "GC11" => [971.31,1022.37,975.94,1025.27,0],
    "GC12" => [964.19,1023.27,968.81,1027.37,0],
    "GC13" => [971.31,1019.37,975.94,1022.27,0],
    "GC14" => [964.19,1019.97,968.81,1023.17,0],
    "GC15" => [971.31,1016.78,975.94,1019.27,0],
    "GC16" => [964.19,1016.42,968.81,1019.87,0],
    "GC18" => [964.23,1010.92,968.81,1016.22,0],
    "GC20" => [964.23,1005.57,968.81,1009.07,0],
    "GC22" => [964.23,999.17,968.81,1005.47,0],
    "GC33" => [971.31,998.44,975.94,1002.38,0],
    "GC_Corridor" => [968.81,1010.82,971.39,1046.15,0],
    "GC_Toilet" => [971.35,1010.96,976.05,1016.59,0],
    "GE01" => [990.51,1004.44,993.94,1009.07,0],
    "GE03" => [985.71,1004.44,990.41,1009.07,0],
    "GE05" => [982.71,1004.44,985.61,1009.17,0],
    "GE07" => [979.11,1004.44,982.61,1009.07,0],
    "GE09" => [976.19,1004.44,979.01,1009.07,0],
    "GE10" => [960.51,1010.92,963.9,1016.19,0],
    "GE11" => [961.11,1004.44,963.9,1009.17,0],
    "GE12" => [957.21,1010.92,960.41,1016.19,0],
    "GE13" => [958.11,1004.44,961.01,1009.07,0],
    "GE14" => [953.01,1010.92,957.11,1016.19,0],
    "GE15" => [954.51,1004.44,958.01,1009.07,0],
    "GE16" => [949.71,1010.92,952.91,1016.19,0],
    "GE17" => [951.21,1004.44,954.41,1009.07,0],
    "GE18" => [946.71,1010.82,949.61,1016.19,0],
    "GE19" => [947.01,1004.44,951.11,1009.07,0],
    "GE20" => [943.21,1010.92,946.61,1016.2,0],
    "GE21" => [943.71,1004.44,946.91,1009.07,0],
    "GE22" => [940.23,1010.92,943.01,1016.19,0],
    "GE23" => [940.19,1004.44,943.61,1009.07,0],
    "GE_Corridor" => [935.21,999.12,994,1011,0],
    "GE_Kitchen" => [971.39,1011,973.4,1012.66,0],
    "GN01" => [1001.54,1042.83,1005.92,1046.14,0],
    "GN04" => [994.19,1043.05,997.71,1046.15,0],
    "GN06" => [976.23,1010.92,1000.01,1043.05,0],
    "GN09" => [1001.54,1021.03,1005.94,1042.61,0],
    "GN13" => [1001.54,1018,1005.94,1020.81,0],
    "GN17" => [1001.5,1009.04,1005.94,1017.82,0],
    "GN19" => [995.69,998.44,1005.94,1008.9,0],
    "GN_Corridor" => [994,1008.9,1001.54,1038.27,0],
    "GS02" => [928.19,1043.37,932.81,1046.27,0],
    "GS03" => [938.52,1036.68,939.94,1046.32,0],
    "GS04" => [928.19,1040.37,932.81,1043.27,0],
    "GS05" => [936.42,1044.89,938.52,1046.34,0],
    "GS06" => [928.19,1034.37,932.81,1040.27,0],
    "GS07" => [936.42,1043.19,938.52,1044.79,0],
    "GS08" => [928.19,1028.37,932.81,1034.27,0],
    "GS09" => [935.35,1036.78,938.77,1043.09,0],
    "GS10" => [928.19,1025.37,932.91,1028.27,0],
    "GS11" => [935.35,1031.62,939.94,1036.68,0],
    "GS12" => [928.19,1022.37,932.81,1025.27,0],
    "GS13" => [935.31,1028.37,939.94,1031.48,0],
    "GS14" => [928.19,1019.37,932.81,1022.27,0],
    "GS15" => [935.31,1022.37,939.94,1028.27,0],
    "GS16" => [928.19,1016.37,932.81,1019.27,0],
    "GS17" => [935.31,1019.37,939.94,1022.27,0],
    "GS18" => [928.19,1012.77,932.81,1016.27,0],
    "GS19" => [935.31,1016.78,939.94,1019.27,0],
    "GS20" => [928.19,1009.47,932.81,1012.67,0],
    "GS22" => [928.19,1005.27,932.81,1009.37,0],
    "GS24" => [928.19,999.12,932.81,1005.17,0],
    "GS37" => [935.31,998.44,939.94,1002.38,0],
    "GS_Corridor" => [932.81,999.12,935.43,1046.15,0],
    "GS_Toilet" => [935.35,1010.96,940.05,1016.59,0],
    "GW01" => [1001.19,1046.45,1006.3,1052.16,0],
    "GW02" => [994.75,1052.49,998.27,1058.21,0],
    "Stores" => [989.78,1052.49,994.75,1058.21,0], # alias
    "GW03" => [989.78,1052.49,994.75,1058.21,0],
    "GW04" => [985.8,1052.49,989.56,1058.21,0],
    "GW05" => [982.19,1058.21,987.13,1064.2,0],
    "GW06" => [987.13,1058.21,998.27,1064.2,0],
    "GW08" => [998.27,1059.29,1001.95,1061.09,0],
    "GW09" => [998.27,1061.09,1002.79,1064.2,0],
    "GW10" => [1001.95,1059.15,1005.94,1064.2,0],
    "GW11" => [998.27,1055.99,1005.94,1059.15,0],
    "GW12" => [998.27,1052.34,1005.94,1055.85,0],
    "GW13" => [974.55,1052.28,975.9,1059.63,0],
    "GW14" => [971.35,1052.28,974.55,1054.84,0],
    "GW16" => [970.28,1055.02,974.59,1059.45,0],
    "GW17" => [970.32,1059.63,975.9,1064.39,0],
    "GW18" => [970.28,1064.39,975.94,1072.25,0],
    "GW24" => [936.04,1052.2,942.35,1058.69,0],
    "GW26" => [936.18,1061.21,939.34,1063,0],
    "GW27" => [936.27,1063,942.36,1064.2,0],
    "GW29" => [939.44,1061.21,942.36,1063,0],
    "GW30" => [936.04,1058.69,942.36,1061.77,0],
    "GW31" => [942.36,1062.81,946.06,1064.2,0],
    "GW32" => [942.46,1057.8,946.09,1062.67,0],
    "LT1" => [960.01,1052.29,975.85,1072.17,0], # alias
    "Lecture Theatre 1" => [960.01,1052.29,975.85,1072.17,0], # alias
    "LargeLectureRoom" => [960.01,1052.29,975.85,1072.17,0],
    "LargeLectureRoom_Lobby" => [957.75,1052.49,964.26,1054.94,0],
    "LargeLectureRoom_ProjectorRoom" => [973.87,1059.78,975.85,1067.33,0],
    "LectureRooms_Preparation" => [952.01,1055.67,960.01,1058,0],
    "N_FrontStairs_L1" => [982.52,1052.5,985.22,1057.88,1],
    "N_FrontStairs_L2" => [982.52,1052.5,985.22,1057.88,2],
    "N_Stairs_L1" => [994.31,1001.62,998.88,1008.95,1],
    "N_Stairs_L2" => [994.31,1002.16,998.69,1008.76,2],
    "SC01" => [971.31,1040.37,975.94,1046.16,2],
    "SC03" => [971.31,1037.37,975.94,1040.27,2],
    "SC04" => [964.19,1040.37,968.81,1046.15,2],
    "SC06" => [964.19,1037.37,968.81,1040.27,2],
    "SC07" => [971.31,1031.37,975.94,1037.27,2],
    "SC08" => [964.19,1034.33,968.81,1037.27,2],
    "SC10" => [964.19,1031.33,968.91,1034.23,2],
    "SC11" => [971.31,1022.43,975.94,1031.27,2],
    "SC12" => [964.19,1028.33,968.81,1031.23,2],
    "SC14" => [964.19,1025.33,968.81,1028.23,2],
    "SC18" => [964.19,1019.29,968.81,1025.23,2],
    "SC20" => [964.19,1016.42,968.91,1019.27,2],
    "SC22" => [967.35,1011.04,968.69,1016.2,2],
    "SC24" => [964.38,1011.04,967.35,1012.61,2],
    "SC26" => [964.38,1012.83,967.35,1014.41,2],
    "SC28" => [964.38,1014.63,967.35,1016.21,2],
    "SC30" => [964.11,1006.76,968.8,1009.07,2],
    "SC32" => [964.11,999.12,968.8,1006.66,2],
    "SC35" => [971.31,998.44,975.94,1002.42,2],
    "SC_Balcony" => [964.24,997.17,971.15,999,2],
    "SC_Corridor" => [968.8,999,971.43,1046.15,2],
    "SC_Toilet" => [971.35,1010.96,976.05,1016.59,2],
    "SE01" => [988.13,1004.45,993.94,1009.07,2],
    "SE02" => [988.13,1010.92,993.94,1016.2,2],
    "SE04" => [976.24,1010.92,987.99,1016.2,2],
    "SE05" => [982.18,1004.45,987.99,1009.07,2],
    "SE09" => [976.23,1004.45,982.04,1009.07,2],
    "SE12" => [959.3,1010.92,963.9,1016.2,2],
    "SE13" => [961.11,1004.44,964.01,1009.07,2],
    "SE14" => [955.11,1010.92,959.2,1016.2,2],
    "SE15" => [958.11,1004.44,961.01,1009.07,2],
    "SE17" => [952.11,1004.44,958.01,1009.07,2],
    "SE18" => [946.11,1010.92,955.01,1016.2,2],
    "SE21" => [949.11,1004.44,952.01,1009.07,2],
    "SE22" => [940.23,1010.92,946.01,1016.2,2],
    "SE23" => [946.11,1004.44,949.01,1009.07,2],
    "SE25" => [940.23,1004.44,946.01,1009.07,2],
    "SE_Corridor" => [935.21,1009.07,998.91,1011.04,2],
    "S_FrontStairs_L1" => [942.9,1052.5,945.6,1057.88,2],
    "S_FrontStairs_L2" => [942.9,1052.5,945.6,1057.88,2],
    "LT2" => [948.58,1055.02,959.67,1072.2,0], # alias
    "Lecture Theatre 2" => [948.58,1055.02,959.67,1072.2,0], # alias 
    "SmallLectureRoom" => [948.58,1055.02,959.67,1072.2,0],
    "SmallLectureRoom_Lobby" => [948.58,1055.67,952.01,1058,0],
    "SmallLectureRoom_ProjectorRoom" => [957.65,1061.93,959.64,1068.77,0],
    "SN01" => [1001.21,1043.37,1005.94,1046.15,2],
    "SN03" => [1001.31,1040.37,1005.94,1043.27,2],
    "SN04" => [994.19,1040.37,998.81,1046.15,2],
    "SN05" => [1001.31,1034.37,1005.94,1040.37,2],
    "SN06" => [994.19,1037.37,998.81,1040.27,2],
    "SN08" => [994.19,1031.33,998.81,1037.27,2],
    "SN09" => [1001.31,1031.37,1005.94,1034.27,2],
    "SN10" => [994.19,1028.33,998.81,1031.23,2],
    "SN11" => [1001.21,1028.37,1005.94,1031.27,2],
    "SN12" => [994.19,1025.33,998.81,1028.23,2],
    "SN13" => [1001.31,1025.37,1005.94,1028.27,2],
    "SN14" => [994.19,1019.29,998.81,1025.23,2],
    "SN15" => [1001.31,1022.43,1005.94,1025.27,2],
    "SN16" => [994.19,1016.8,998.81,1019.19,2],
    "SN17" => [1001.31,1016.39,1005.94,1022.33,2],
    "SN21" => [1001.31,1010.35,1005.94,1016.29,2],
    "SN25" => [1001.31,1007.35,1005.94,1010.25,2],
    "SN27" => [1001.31,1001.31,1005.94,1007.25,2],
    "SN31" => [1001.31,998.44,1005.94,1001.21,2],
    "SN34" => [994.11,999.12,998.91,1001.82,2],
    "SN_Balcony" => [994.24,997.17,1001.15,999,2],
    "SN_Corridor" => [998.69,999,1001.31,1046.15,2],
    "SN_Kitchen" => [996.88,1014.9,998.73,1016.6,2],
    "SN_Toilet" => [994.08,1011,998.73,1016.64,2],
    "SS02" => [928.19,1043.37,932.91,1046.15,2],
    "SS03" => [935.31,1034.37,939.94,1046.15,2],
    "SS04" => [928.19,1040.37,932.81,1043.27,2],
    "SS06" => [928.19,1034.37,932.81,1040.27,2],
    "SS08" => [928.19,1031.37,932.81,1034.27,2],
    "SS09" => [935.31,1025.37,939.94,1034.27,2],
    "SS10" => [928.19,1028.37,932.81,1031.27,2],
    "SS12" => [928.19,1025.37,932.81,1028.27,2],
    "SS13" => [935.31,1022.37,939.94,1025.27,2],
    "SS14" => [928.19,1022.37,932.81,1025.27,2],
    "SS15" => [935.31,1019.37,939.94,1022.27,2],
    "SS16" => [928.19,1019.37,932.81,1022.27,2],
    "SS17" => [935.31,1016.78,939.94,1019.27,2],
    "SS18" => [928.19,1016.37,932.81,1019.27,2],
    "SS20" => [928.19,1013.37,932.81,1016.27,2],
    "SS22" => [928.19,1010.37,932.81,1013.27,2],
    "SS24" => [928.19,1007.37,932.81,1010.27,2],
    "SS26" => [928.19,1004.37,932.81,1007.27,2],
    "SS28" => [928.19,999.12,932.81,1004.27,2],
    "SS35" => [935.31,998.44,939.94,1002.38,2],
    "SS_Balcony" => [928.28,997.17,935.15,999,2],
    "SS_Corridor" => [932.81,999,935.43,1046.15,2],
    "S_Stairs_L1" => [935.43,1002.66,939.81,1008.89,2],
    "S_Stairs_L2" => [935.43,1002.66,939.81,1008.76,2],
    "SS_Toilet" => [935.35,1010.96,940.05,1016.59,2],
    "SW00" => [1001.31,1046.48,1006.29,1052.15,2],
    "SW01" => [1000.01,1052.48,1005.94,1064.19,2],
    "SW02" => [985.8,1052.48,1000.01,1065.6,2],
    "SW04" => [982.19,1060.34,987.94,1065.6,2],
    "SW11" => [927.83,1052.29,974.81,1064.73,2],
    "SW12" => [954.83,1064.73,976.44,1072.5,2],
    "SW_Landing" => [931.95,1046.15,1006.29,1064.73,2],
    "SW_Toilet" => [940.14,1052.37,952.01,1057.95,2],
    "The Street" => [927.83,1045.91,1001.19,1064.58,0]
    );


my $bounds = "";
my $baseLayer = "layer0";
my @floorchecked = ("","","");

if ($reqfloor >= 0 && $reqfloor < 3) {
    $floorchecked[$reqfloor] = " CHECKED";
}
if (exists($rooms{$search})) {
    my ($left,$bottom,$right,$top,$floor) = @{$rooms{$search}};
    $bounds = "bounds = convertBounds(map,new OpenLayers.Bounds($left-($reqzoom-1),$bottom-($reqzoom-1),$right+($reqzoom-1),$top+($reqzoom-1)));";
    if ($floor == 0) { $baseLayer = "layer0"; $floorchecked[0] = " CHECKED"; }
    elsif ($floor == 1) { $baseLayer = "layer1"; $floorchecked[1] = " CHECKED"; }
    elsif ($floor == 2) { $baseLayer = "layer2"; $floorchecked[2] = " CHECKED"; }
}

my $highlight = "";
my $highChecked = "";
if ($bounds ne "" && $reqhighlight > 0) {
    my ($left,$bottom,$right,$top,$floor) = @{$rooms{$search}};

    $highlight = 
	"boxbounds = convertBounds(map,new OpenLayers.Bounds($left-$reqhighlight,$bottom-$reqhighlight,$right+$reqhighlight,$top+$reqhighlight)); ".
	"boxes = new OpenLayers.Layer.Boxes( \"Highlight $search\" ); ".
	"box = new OpenLayers.Marker.Box(boxbounds,\"red\",3); ".
	"boxes.addMarker(box); ".
	"map.addLayer(boxes); ";
    $highChecked = "CHECKED='yes'";
}

my $zoom = "";
my $zoomChecked ="";
if ($bounds ne "" && $reqzoom > 0) {
    $zoom = "map.zoomToExtent(bounds);";
    $zoomChecked = "CHECKED='yes'";
}
else {
    $zoom = "mapBounds = convertBounds(map,new OpenLayers.Bounds(927.83,997.17,1006.3,1072.5)); map.zoomToExtent(mapBounds);";
}

my $labelsChecked = ($reqlabels eq "true") ? " CHECKED" : "";

print <<EOF;
Content-type: text/html

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta content="text/html; charset=UTF-8" http-equiv="Content-Type" />
  <meta content="text/css" http-equiv="Content-Style-Type" />
  <title>The Computer Laboratory</title>
  <link href="http://www.cl.cam.ac.uk/style/camstyle2.css" media="screen" rel="stylesheet" type="text/css" />
  <link href="http://www.cl.cam.ac.uk/style/print2.css" media="print" rel="stylesheet" type="text/css" />
  <meta content="The Computer Science department of the University of Cambridge, England" name="description" />
  <meta content="computer science department, general information" name="keywords" />
  <script src="OpenLayers.js"></script>
  <script src="prototype.js"></script>
  <script>
    var currentfloor,showlabels,map,layer0,layer1,layer2,layer0label,layer1label,layer2label;
function init(){
    size = new OpenLayers.Bounds(-1006.3,997.17,-927.83,1075.64);
    maxRes = (size.top - size.bottom)/256;

    \$('map').style.height = (document.viewport.getHeight()-\$('map').viewportOffset()[1]-\$('footerdiv').getHeight()-20) +"px";


    map = new OpenLayers.Map( 'map', { 
	maxExtent : size,
      maxResolution: maxRes,
      units: "m",
	numZoomLevels : 6   } );
    layer0 = new OpenLayers.Layer.XYZ( "Ground Floor",
				       "tile/subtile-0-\${z}-\${x}-\${y}.png" );
    map.addLayer(layer0);
    layer1 = new OpenLayers.Layer.XYZ( "First Floor",
				       "tile/subtile-1-\${z}-\${x}-\${y}.png" );
    map.addLayer(layer1);
    layer2 = new OpenLayers.Layer.XYZ( "Second Floor",
				       "tile/subtile-2-\${z}-\${x}-\${y}.png" );
    map.addLayer(layer2);

    layer0label = new OpenLayers.Layer.XYZ( "Ground Floor Labels",
					    "tile/sublabel-0-\${z}-\${x}-\${y}.png");
    layer0label.setIsBaseLayer(false);
    map.addLayer(layer0label);

    layer1label = new OpenLayers.Layer.XYZ( "First Floor Labels",
					    "tile/sublabel-1-\${z}-\${x}-\${y}.png");
    layer1label.setIsBaseLayer(false);
    map.addLayer(layer1label);

    layer2label = new OpenLayers.Layer.XYZ( "Second Floor Labels",
					    "tile/sublabel-2-\${z}-\${x}-\${y}.png");
    layer2label.setIsBaseLayer(false);
    map.addLayer(layer2label);

    map.setBaseLayer($baseLayer);
    currentfloor = $baseLayer;
    showlabels = $reqlabels;

    $bounds
    $highlight
    $zoom

    showlayers();

}

function setfloor(floor) {
    currentfloor = floor;
    showlayers();
    return true;
}

function showlayers() {
    map.setBaseLayer(currentfloor);
    layer0label.setVisibility(false);
    layer1label.setVisibility(false);
    layer2label.setVisibility(false);
    if (showlabels) {
	if (currentfloor == layer0) {
	    layer0label.setVisibility(true);
	}
	else if (currentfloor == layer1) {
	    layer1label.setVisibility(true);
	}
	else {
	    layer2label.setVisibility(true);
	}
    }
}

function setvisibility(box) {
    showlabels = box.checked;
    showlayers();
}

function convertBounds(map,b) {
    maxExtent = map.getMaxExtent();    
    return new OpenLayers.Bounds(-b.right,
				 maxExtent.top - (b.top - maxExtent.bottom),
				 -b.left,
				 maxExtent.top - (b.bottom - maxExtent.bottom));
}

   </script>
  </head>
  <body onload="init()">
   <div id="page">
    <div id="navigation">
     <div id="insert"><span class="noshow">|</span><a accesskey="4" href="search/"><img alt="[Search]" height="18" src="http://www.cl.cam.ac.uk/images/search.gif" width="53" /></a><span class="noshow">|</span><a href="http://www.cl.cam.ac.uk/az/"><img alt="[A-Z Index]" height="18" src="http://www.cl.cam.ac.uk/images/az.gif" width="53" /></a><span class="noshow">|</span><a href="http://www.cl.cam.ac.uk/contact/"><img alt="[Contact]" height="18" src="http://www.cl.cam.ac.uk/images/contact.gif" width="53" /></a></div>
    </div>

    <table id="header" summary="page header">
     <tbody>
      <tr>
       <td class="identifier">
        <a href="http://www.cam.ac.uk/"><img alt="[University of Cambridge]" height="46" src="http://www.cl.cam.ac.uk/images/identifier2.gif" width="192" /></a>
       </td>
       <td class="deptitle">Computer Laboratory</td>
      </tr>
     </tbody>
    </table>
    <div id="topbgline">&#160;</div>
    <div id="bread"><p>&#160;</p></div>
    <div id="content">
     <h1>Internal layout of the William Gates Building</h1>
    <p>This map is a snapshot generated from OpenRoomMap, a building-occupant maintained plan of the building.  If you see a mistake please use the <a href="http://www.cl.cam.ac.uk/research/dtg/openroommap/edit/applet2.html">edit</a> link to correct it.  This snapshot is generated nightly.</p>
    <form method="get">
    <div style="float:left;width:13em;height:3.7em;border:1px solid black;margin:0.5em;padding:0.5em">
      <div>Room</div>
      <div style="padding:0.5em">
      <input type="text" value="$search" name="q" size="12"/><input type="hidden" name="zoom" value="3"/><input type="submit" value="Go"/>
      </div>
    </div>
    
    <div style="float:left;width:16em;height:3.7em;border:1px solid black;margin:0.5em;padding:0.5em">
      <div>Floor</div>
      <div style="padding:0.5em">Ground <input type="radio" name="floor" value="0" onclick="setfloor(layer0)" $floorchecked[0]/> First <input type="radio" name="floor" value="1" onclick="setfloor(layer1)" $floorchecked[1]/> Second <input type="radio" name="floor"  value="2" onclick="setfloor(layer2)" $floorchecked[2]/></div>
    </div>
    <div style="float:left;width:13em;height:3.7em;border:1px solid black;margin:0.5em;padding:0.5em">
    <div>Annotations</div>
    <div style="padding:0.5em">
    Room labels: <input name="labels" type="checkbox" onclick="setvisibility(this)" value="1" $labelsChecked/>
    </div>
    </div>
    <div style="float:right;width:2em;height:3.7em;border:1px solid black;margin:0.5em;padding:0.5em">
    <a href="http://www.cl.cam.ac.uk/research/dtg/openroommap/edit/applet2.html">edit
    <br/>
    <img src="stock_edit.png" width="24" height="24"/></a>
    </div>
    </form>
    <div style="height:500px;border:solid 1px black;padding:0px;margin:0.5em;clear:both" id="map"></div>
    </div>
    <div id="footerdiv">
    <div id="bottombgline">&#160;</div>
    <p class="footer">&#169; 2009 Computer Laboratory, University of Cambridge<br />Please send any comments on this page to <a href="mailto:dtg-www\@cl.cam.ac.uk">dtg-www\@cl.cam.ac.uk</a><br /></p><p class="rfooter"><a href="http://www.cl.cam.ac.uk/privacy.html">Privacy policy</a></p>
    <div style="clear:both"></div>
    </div>
    </div>
    </body>
</html>
EOF



