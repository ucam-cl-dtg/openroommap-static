#!/usr/bin/perl

use strict;
use CGI;

my $q = new CGI;

my $search = $q->param("q");
my $reqhighlight = $q->param("highlight");
my $reqzoom = $q->param("zoom");
my $reqlabels = $q->param("labels") eq "on" ? "true" : "false";

my %rooms = (
    "Corr" => [998.81,1038.27,1001.54,1046.15],
    "C_Stairs_L1" => [971.43,1002.66,975.81,1008.93],
    "C_Stairs_L2" => [971.43,1002.66,975.81,1008.76],
    "FC01" => [970.66,1042.77,975.93,1046.16],
    "FC03" => [970.66,1037.97,975.93,1042.67],
    "FC04" => [964.18,1041.27,968.81,1046.16],
    "FC05" => [970.66,1034.37,975.93,1037.87],
    "FC06" => [964.18,1037.97,968.81,1041.17],
    "FC07" => [970.66,1031.37,975.93,1034.27],
    "FC08" => [964.18,1034.37,968.81,1037.87],
    "FC09" => [970.56,1028.37,975.93,1031.27],
    "FC10" => [964.18,1031.37,968.21,1034.27],
    "FC11" => [970.66,1025.37,975.93,1028.27],
    "FC12" => [964.18,1028.37,968.21,1031.27],
    "FC13" => [970.66,1022.37,975.93,1025.27],
    "FC14" => [964.18,1025.37,968.21,1028.27],
    "FC15" => [970.66,1019.37,975.93,1022.27],
    "FC16" => [964.18,1022.37,968.31,1025.27],
    "FC17" => [970.66,1016.79,975.93,1019.27],
    "FC18" => [964.18,1019.37,968.21,1022.27],
    "FC20" => [964.18,1016.42,968.21,1019.27],
    "FC22" => [964.22,1010.92,968.21,1016.22],
    "FC24" => [964.07,999.12,971.31,1009.05],
    "FC_Balcony" => [964.23,997.17,971.17,999.12],
    "FC_Corridor" => [968.21,1010.82,971.39,1046.16],
    "FC_Kitchen" => [971.31,998.45,975.93,1002.38],
    "FC_Toilet" => [971.35,1010.96,976.04,1016.6],
    "FE01" => [991.11,1004.45,993.89,1009.08],
    "FE02" => [991.11,1010.92,993.89,1016.2],
    "FE03" => [988.1,1004.45,991.01,1009.08],
    "FE04" => [987.51,1010.92,991.01,1016.2],
    "FE05" => [985.11,1004.45,988.01,1009.08],
    "FE06" => [984.51,1010.82,987.41,1016.2],
    "FE07" => [982.1,1004.45,985.01,1009.08],
    "FE08" => [979.71,1010.92,984.41,1016.2],
    "FE09" => [979.11,1004.45,982.01,1009.08],
    "FE10" => [976.22,1010.92,979.61,1016.2],
    "FE11" => [976.22,1004.45,979.01,1009.08],
    "FE12" => [960.51,1010.92,963.89,1016.2],
    "FE13" => [961.11,1004.45,963.89,1009.07],
    "FE14" => [955.11,1010.92,960.41,1016.2],
    "FE15" => [958.11,1004.45,961.01,1009.07],
    "FE17" => [955.11,1004.45,958.01,1009.17],
    "FE18" => [952.11,1010.92,955.01,1016.2],
    "FE19" => [951.51,1004.45,955.01,1009.07],
    "FE20" => [949.11,1010.92,952.01,1016.2],
    "FE21" => [946.71,1004.45,951.41,1009.07],
    "FE22" => [943.31,1010.92,949.01,1016.2],
    "FE23" => [943.11,1004.45,946.61,1009.07],
    "FE24" => [940.22,1010.82,943.01,1016.2],
    "FE25" => [940.22,1004.45,943.01,1009.07],
    "FE_Corridor" => [935.21,1002.55,998.91,1011],
    "FE_Kitchen" => [935.39,1011,937.4,1012.66],
    "FN01" => [1000.21,1034.07,1005.93,1046.16],
    "FN04" => [994.18,1041.27,998.21,1046.16],
    "FN05" => [1000.21,1028.57,1005.93,1034.07],
    "FN06" => [994.18,1037.37,998.21,1041.17],
    "FN07" => [1000.21,1016.37,1005.93,1028.57],
    "FN08" => [994.18,1033.47,998.21,1037.27],
    "FN10" => [994.18,1028.37,998.21,1033.37],
    "FN11" => [1000.21,1013.37,1005.93,1016.27],
    "FN12" => [994.18,1024.77,998.21,1028.27],
    "FN13" => [1000.21,1010.37,1005.93,1013.27],
    "FN14" => [994.18,1019.97,998.21,1024.67],
    "FN15" => [1000.21,1007.37,1005.93,1010.27],
    "FN16" => [994.18,1016.79,998.21,1019.87],
    "FN17" => [1000.21,1004.37,1005.93,1007.27],
    "FN19" => [1000.21,1001.37,1005.93,1004.27],
    "FN21" => [1001.31,998.45,1005.93,1001.27],
    "FN34" => [994.18,999.12,1001.31,1001.88],
    "FN_Balcony" => [994.31,997.17,1001.17,999.12],
    "FN_Corridor" => [997.11,1001.88,1000.21,1054.77],
    "FN_Kitchen" => [996.87,1014.91,998.73,1016.61],
    "FN_Toilet" => [994.07,1011,998.77,1016.65],
    "FS02" => [928.18,1042.77,932.21,1046.16],
    "FS03" => [934.11,1040.37,939.93,1046.16],
    "FS04" => [928.18,1037.97,932.21,1042.67],
    "FS05" => [934.11,1037.37,939.93,1040.27],
    "FS06" => [928.18,1034.37,932.21,1037.87],
    "FS07" => [934.11,1025.37,939.93,1037.27],
    "FS08" => [928.18,1031.97,932.21,1034.27],
    "FS10" => [928.18,1028.37,932.21,1031.87],
    "FS12" => [928.18,1024.77,932.21,1028.27],
    "FS13" => [934.11,1022.37,939.93,1025.27],
    "FS14" => [928.18,1019.97,932.21,1024.67],
    "FS15" => [934.11,1019.37,939.93,1022.27],
    "FS16" => [928.18,1016.37,932.21,1019.87],
    "FS17" => [934.11,1016.79,939.93,1019.27],
    "FS18" => [928.18,1011.27,932.21,1016.27],
    "FS20" => [928.18,1007.97,932.21,1011.17],
    "FS22" => [928.18,1004.97,932.21,1007.87],
    "FS24" => [928.18,1001.97,932.21,1004.87],
    "FS35" => [935.31,998.45,939.93,1002.38],
    "FS_Balcony" => [928.26,997.17,935.21,999.12],
    "FS_Corridor" => [928.18,999.12,935.43,1046.16],
    "FS_Toilet" => [935.35,1010.96,940.04,1016.6],
    "FW01" => [1000.21,1046.49,1006.29,1052.16],
    "FW03" => [995.91,1052.49,998.21,1054.67],
    "FW04" => [993.03,1052.49,995.81,1054.67],
    "FW05" => [990.16,1052.49,992.93,1054.67],
    "FW06" => [988.25,1052.16,990.16,1059.56],
    "FW07" => [985.8,1052.49,988.25,1054.67],
    "FW08" => [985.8,1054.77,988.25,1059.46],
    "FW09" => [982.18,1059.56,990.06,1064.2],
    "FW11" => [990.16,1054.77,1000.11,1065.6],
    "FW13" => [1000.21,1052.49,1001.41,1060.77],
    "FW14" => [1000.2,1060.77,1005.93,1064.2],
    "FW15" => [1001.41,1055.97,1005.93,1060.67],
    "FW16" => [1001.41,1052.45,1005.93,1055.87],
    "FW19" => [971.31,1052.29,974.21,1054.93],
    "FW22" => [957.79,1052.49,962.62,1054.98],
    "FW26" => [933.87,1053.57,942.32,1064.2],
    "FW27" => [942.32,1058.61,946.12,1059.87],
    "FW28" => [942.42,1059.87,946.12,1063.12],
    "FW_Landing" => [931.94,1046.16,997.11,1059.82],
    "GC01" => [971.31,1042.77,975.94,1046.15],
    "GC03" => [971.31,1037.37,975.94,1042.77],
    "GC04" => [964.19,1041.27,968.81,1046.15],
    "GC05" => [971.31,1033.77,975.94,1037.27],
    "GC06" => [964.19,1036.77,968.81,1041.17],
    "GC07" => [971.31,1029.27,975.94,1033.67],
    "GC08" => [964.19,1033.37,968.81,1036.67],
    "GC09" => [971.31,1025.37,975.94,1029.17],
    "GC10" => [964.19,1027.47,968.81,1033.37],
    "GC11" => [971.31,1022.37,975.94,1025.27],
    "GC12" => [964.19,1023.27,968.81,1027.37],
    "GC13" => [971.31,1019.37,975.94,1022.27],
    "GC14" => [964.19,1019.97,968.81,1023.17],
    "GC15" => [971.31,1016.78,975.94,1019.27],
    "GC16" => [964.19,1016.42,968.81,1019.87],
    "GC18" => [964.23,1010.92,968.81,1016.22],
    "GC20" => [964.23,1005.57,968.81,1009.07],
    "GC22" => [964.23,999.17,968.81,1005.47],
    "GC33" => [971.31,998.44,975.94,1002.38],
    "GC_Corridor" => [968.81,1010.82,971.39,1046.15],
    "GC_Toilet" => [971.35,1010.96,976.05,1016.59],
    "GE01" => [990.51,1004.44,993.94,1009.07],
    "GE03" => [985.71,1004.44,990.41,1009.07],
    "GE05" => [982.71,1004.44,985.61,1009.17],
    "GE07" => [979.11,1004.44,982.61,1009.07],
    "GE09" => [976.19,1004.44,979.01,1009.07],
    "GE10" => [960.51,1010.92,963.9,1016.19],
    "GE11" => [961.11,1004.44,963.9,1009.17],
    "GE12" => [957.21,1010.92,960.41,1016.19],
    "GE13" => [958.11,1004.44,961.01,1009.07],
    "GE14" => [953.01,1010.92,957.11,1016.19],
    "GE15" => [954.51,1004.44,958.01,1009.07],
    "GE16" => [949.71,1010.92,952.91,1016.19],
    "GE17" => [951.21,1004.44,954.41,1009.07],
    "GE18" => [946.71,1010.82,949.61,1016.19],
    "GE19" => [947.01,1004.44,951.11,1009.07],
    "GE20" => [943.21,1010.92,946.61,1016.2],
    "GE21" => [943.71,1004.44,946.91,1009.07],
    "GE22" => [940.23,1010.92,943.01,1016.19],
    "GE23" => [940.19,1004.44,943.61,1009.07],
    "GE_Corridor" => [935.21,999.12,994,1011],
    "GE_Kitchen" => [971.39,1011,973.4,1012.66],
    "GN01" => [1001.54,1042.83,1005.92,1046.14],
    "GN04" => [994.19,1043.05,997.71,1046.15],
    "GN06" => [976.23,1010.92,1000.01,1043.05],
    "GN09" => [1001.54,1021.03,1005.94,1042.61],
    "GN13" => [1001.54,1018,1005.94,1020.81],
    "GN17" => [1001.5,1009.04,1005.94,1017.82],
    "GN19" => [995.69,998.44,1005.94,1008.9],
    "GN_Corridor" => [994,1008.9,1001.54,1038.27],
    "GS02" => [928.19,1043.37,932.81,1046.27],
    "GS03" => [938.52,1036.68,939.94,1046.32],
    "GS04" => [928.19,1040.37,932.81,1043.27],
    "GS05" => [936.42,1044.89,938.52,1046.34],
    "GS06" => [928.19,1034.37,932.81,1040.27],
    "GS07" => [936.42,1043.19,938.52,1044.79],
    "GS08" => [928.19,1028.37,932.81,1034.27],
    "GS09" => [935.35,1036.78,938.77,1043.09],
    "GS10" => [928.19,1025.37,932.91,1028.27],
    "GS11" => [935.35,1031.62,939.94,1036.68],
    "GS12" => [928.19,1022.37,932.81,1025.27],
    "GS13" => [935.31,1028.37,939.94,1031.48],
    "GS14" => [928.19,1019.37,932.81,1022.27],
    "GS15" => [935.31,1022.37,939.94,1028.27],
    "GS16" => [928.19,1016.37,932.81,1019.27],
    "GS17" => [935.31,1019.37,939.94,1022.27],
    "GS18" => [928.19,1012.77,932.81,1016.27],
    "GS19" => [935.31,1016.78,939.94,1019.27],
    "GS20" => [928.19,1009.47,932.81,1012.67],
    "GS22" => [928.19,1005.27,932.81,1009.37],
    "GS24" => [928.19,999.12,932.81,1005.17],
    "GS37" => [935.31,998.44,939.94,1002.38],
    "GS_Corridor" => [932.81,999.12,935.43,1046.15],
    "GS_Toilet" => [935.35,1010.96,940.05,1016.59],
    "GW01" => [1001.19,1046.45,1006.3,1052.16],
    "GW02" => [994.75,1052.49,998.27,1058.21],
    "GW03" => [989.78,1052.49,994.75,1058.21],
    "GW04" => [985.8,1052.49,989.56,1058.21],
    "GW05" => [982.19,1058.21,987.13,1064.2],
    "GW06" => [987.13,1058.21,998.27,1064.2],
    "GW08" => [998.27,1059.29,1001.95,1061.09],
    "GW09" => [998.27,1061.09,1002.79,1064.2],
    "GW10" => [1001.95,1059.15,1005.94,1064.2],
    "GW11" => [998.27,1055.99,1005.94,1059.15],
    "GW12" => [998.27,1052.34,1005.94,1055.85],
    "GW13" => [974.55,1052.28,975.9,1059.63],
    "GW14" => [971.35,1052.28,974.55,1054.84],
    "GW16" => [970.28,1055.02,974.59,1059.45],
    "GW17" => [970.32,1059.63,975.9,1064.39],
    "GW18" => [970.28,1064.39,975.94,1072.25],
    "GW24" => [936.04,1052.2,942.35,1058.69],
    "GW26" => [936.18,1061.21,939.34,1063],
    "GW27" => [936.27,1063,942.36,1064.2],
    "GW29" => [939.44,1061.21,942.36,1063],
    "GW30" => [936.04,1058.69,942.36,1061.77],
    "GW31" => [942.36,1062.81,946.06,1064.2],
    "GW32" => [942.46,1057.8,946.09,1062.67],
    "LargeLectureRoom" => [960.01,1052.29,975.85,1072.17],
    "LargeLectureRoom_Lobby" => [957.75,1052.49,964.26,1054.94],
    "LargeLectureRoom_ProjectorRoom" => [973.87,1059.78,975.85,1067.33],
    "LectureRooms_Preparation" => [952.01,1055.67,960.01,1058],
    "N_FrontStairs_L1" => [982.52,1052.5,985.22,1057.88],
    "N_FrontStairs_L2" => [982.52,1052.5,985.22,1057.88],
    "N_Stairs_L1" => [994.31,1001.62,998.88,1008.95],
    "N_Stairs_L2" => [994.31,1002.16,998.69,1008.76],
    "SC01" => [971.31,1040.37,975.94,1046.16],
    "SC03" => [971.31,1037.37,975.94,1040.27],
    "SC04" => [964.19,1040.37,968.81,1046.15],
    "SC06" => [964.19,1037.37,968.81,1040.27],
    "SC07" => [971.31,1031.37,975.94,1037.27],
    "SC08" => [964.19,1034.33,968.81,1037.27],
    "SC10" => [964.19,1031.33,968.91,1034.23],
    "SC11" => [971.31,1022.43,975.94,1031.27],
    "SC12" => [964.19,1028.33,968.81,1031.23],
    "SC14" => [964.19,1025.33,968.81,1028.23],
    "SC18" => [964.19,1019.29,968.81,1025.23],
    "SC20" => [964.19,1016.42,968.91,1019.27],
    "SC22" => [967.35,1011.04,968.69,1016.2],
    "SC24" => [964.38,1011.04,967.35,1012.61],
    "SC26" => [964.38,1012.83,967.35,1014.41],
    "SC28" => [964.38,1014.63,967.35,1016.21],
    "SC30" => [964.11,1006.76,968.8,1009.07],
    "SC32" => [964.11,999.12,968.8,1006.66],
    "SC35" => [971.31,998.44,975.94,1002.42],
    "SC_Balcony" => [964.24,997.17,971.15,999],
    "SC_Corridor" => [968.8,999,971.43,1046.15],
    "SC_Toilet" => [971.35,1010.96,976.05,1016.59],
    "SE01" => [988.13,1004.45,993.94,1009.07],
    "SE02" => [988.13,1010.92,993.94,1016.2],
    "SE04" => [976.24,1010.92,987.99,1016.2],
    "SE05" => [982.18,1004.45,987.99,1009.07],
    "SE09" => [976.23,1004.45,982.04,1009.07],
    "SE12" => [959.3,1010.92,963.9,1016.2],
    "SE13" => [961.11,1004.44,964.01,1009.07],
    "SE14" => [955.11,1010.92,959.2,1016.2],
    "SE15" => [958.11,1004.44,961.01,1009.07],
    "SE17" => [952.11,1004.44,958.01,1009.07],
    "SE18" => [946.11,1010.92,955.01,1016.2],
    "SE21" => [949.11,1004.44,952.01,1009.07],
    "SE22" => [940.23,1010.92,946.01,1016.2],
    "SE23" => [946.11,1004.44,949.01,1009.07],
    "SE25" => [940.23,1004.44,946.01,1009.07],
    "SE_Corridor" => [935.21,1009.07,998.91,1011.04],
    "S_FrontStairs_L1" => [942.9,1052.5,945.6,1057.88],
    "S_FrontStairs_L2" => [942.9,1052.5,945.6,1057.88],
    "SmallLectureRoom" => [948.58,1055.02,959.67,1072.2],
    "SmallLectureRoom_Lobby" => [948.58,1055.67,952.01,1058],
    "SmallLectureRoom_ProjectorRoom" => [957.65,1061.93,959.64,1068.77],
    "SN01" => [1001.21,1043.37,1005.94,1046.15],
    "SN03" => [1001.31,1040.37,1005.94,1043.27],
    "SN04" => [994.19,1040.37,998.81,1046.15],
    "SN05" => [1001.31,1034.37,1005.94,1040.37],
    "SN06" => [994.19,1037.37,998.81,1040.27],
    "SN08" => [994.19,1031.33,998.81,1037.27],
    "SN09" => [1001.31,1031.37,1005.94,1034.27],
    "SN10" => [994.19,1028.33,998.81,1031.23],
    "SN11" => [1001.21,1028.37,1005.94,1031.27],
    "SN12" => [994.19,1025.33,998.81,1028.23],
    "SN13" => [1001.31,1025.37,1005.94,1028.27],
    "SN14" => [994.19,1019.29,998.81,1025.23],
    "SN15" => [1001.31,1022.43,1005.94,1025.27],
    "SN16" => [994.19,1016.8,998.81,1019.19],
    "SN17" => [1001.31,1016.39,1005.94,1022.33],
    "SN21" => [1001.31,1010.35,1005.94,1016.29],
    "SN25" => [1001.31,1007.35,1005.94,1010.25],
    "SN27" => [1001.31,1001.31,1005.94,1007.25],
    "SN31" => [1001.31,998.44,1005.94,1001.21],
    "SN34" => [994.11,999.12,998.91,1001.82],
    "SN_Balcony" => [994.24,997.17,1001.15,999],
    "SN_Corridor" => [998.69,999,1001.31,1046.15],
    "SN_Kitchen" => [996.88,1014.9,998.73,1016.6],
    "SN_Toilet" => [994.08,1011,998.73,1016.64],
    "SS02" => [928.19,1043.37,932.91,1046.15],
    "SS03" => [935.31,1034.37,939.94,1046.15],
    "SS04" => [928.19,1040.37,932.81,1043.27],
    "SS06" => [928.19,1034.37,932.81,1040.27],
    "SS08" => [928.19,1031.37,932.81,1034.27],
    "SS09" => [935.31,1025.37,939.94,1034.27],
    "SS10" => [928.19,1028.37,932.81,1031.27],
    "SS12" => [928.19,1025.37,932.81,1028.27],
    "SS13" => [935.31,1022.37,939.94,1025.27],
    "SS14" => [928.19,1022.37,932.81,1025.27],
    "SS15" => [935.31,1019.37,939.94,1022.27],
    "SS16" => [928.19,1019.37,932.81,1022.27],
    "SS17" => [935.31,1016.78,939.94,1019.27],
    "SS18" => [928.19,1016.37,932.81,1019.27],
    "SS20" => [928.19,1013.37,932.81,1016.27],
    "SS22" => [928.19,1010.37,932.81,1013.27],
    "SS24" => [928.19,1007.37,932.81,1010.27],
    "SS26" => [928.19,1004.37,932.81,1007.27],
    "SS28" => [928.19,999.12,932.81,1004.27],
    "SS35" => [935.31,998.44,939.94,1002.38],
    "SS_Balcony" => [928.28,997.17,935.15,999],
    "SS_Corridor" => [932.81,999,935.43,1046.15],
    "S_Stairs_L1" => [935.43,1002.66,939.81,1008.89],
    "S_Stairs_L2" => [935.43,1002.66,939.81,1008.76],
    "SS_Toilet" => [935.35,1010.96,940.05,1016.59],
    "SW01" => [1000.01,1052.48,1005.94,1064.19],
    "SW02" => [985.8,1052.48,1000.01,1065.6],
    "SW04" => [982.19,1060.34,987.94,1065.6],
    "SW11" => [927.83,1052.29,974.81,1064.73],
    "SW12" => [954.83,1064.73,976.44,1072.5],
    "SW_Landing" => [931.95,1046.15,1006.29,1064.73],
    "SW_Toilet" => [940.14,1052.37,952.01,1057.95],
    "TheStreet" => [927.83,1045.91,1001.19,1064.58]
    );

my $bounds = "";
my $baseLayer = "layer0";
if (exists($rooms{$search})) {
    my ($left,$bottom,$right,$top) = @{$rooms{$search}};
    $bounds = "bounds = convertBounds(map,new OpenLayers.Bounds($left,$bottom,$right,$top));";
    if ($search =~ /^G/) { $baseLayer = "layer0"; }
    elsif ($search =~ /^F/) { $baseLayer = "layer1"; }
    elsif ($search =~ /^S/) { $baseLayer = "layer2"; }
}

my $highlight = "";
my $highChecked = "";
if ($bounds ne "" && $reqhighlight =~ /1/) {
    $highlight = 
	"boxes = new OpenLayers.Layer.Boxes( \"Highlight $search\" ); ".
	"box = new OpenLayers.Marker.Box(bounds,\"red\",3); ".
	"boxes.addMarker(box); ".
	"map.addLayer(boxes); ";
    $highChecked = "CHECKED='yes'";
}

my $zoom = "";
my $zoomChecked ="";
if ($bounds ne "" && $reqzoom =~ /1/) {
    $zoom = "map.zoomToExtent(bounds);";
    $zoomChecked = "CHECKED='yes'";
}
else {
    $zoom = "map.zoomToMaxExtent();";
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
  <script>
    var currentfloor,showlabels,map,layer0,layer1,layer2,layer0label,layer1label;
function init(){
    size = new OpenLayers.Bounds(-1006.3,997.17,-927.83,1075.64);
    maxRes = (size.top - size.bottom)/256;

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
    showlabels = false;
    showlayers();
}

function showlayers() {
    map.setBaseLayer(currentfloor);
    layer0label.setVisibility(false);
    layer1label.setVisibility(false);
    if (currentfloor == layer0) {
	layer0label.setVisibility(showlabels);
    }
    else if (currentfloor == layer1) {
	layer1label.setVisibility(showlabels);
    }
    else {
//	layer2label.setVisibility(showlabels);
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
				 maxExtent.top - (b.bottom - maxExtent.bottom)).scale(1.1);
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
    <table width="100%">
    <tr>
    <td>Show room: <input type="text" value="$search" name="q"/><input type="hidden" name="zoom" value="1"/><input type="submit" value="Go"/></td>
    <td>Show floor: <input type="submit" value="Ground floor" onclick="setfloor(layer0)"/><input type="submit" value="First floor" onclick="setfloor(layer1)"/><input type="submit" value="Second floor" onclick="setfloor(layer2)"/></td>
    <td>Show labels: <input name="labels" type="checkbox" onclick="setvisibility(this)" $labelsChecked/></td>
    <td><a href="http://www.cl.cam.ac.uk/research/dtg/openroommap/edit/applet2.html">edit</a> <img src="stock_edit.png" width="24" height="24"/></td>
    </tr>
    </table>
    </form>
    <div style="height:600px;border:solid 1px black;padding:2px;margin:1em;clear:both" id="map"></div>
</div>
<div id="bottombgline">&#160;</div>
<p class="footer">&#169; 2009 Computer Laboratory, University of Cambridge<br />Please send any comments on this page to <a href="mailto:dtg-www\@cl.cam.ac.uk">dtg-www\@cl.cam.ac.uk</a><br /></p><p class="rfooter"><a href="http://www.cl.cam.ac.uk/privacy.html">Privacy policy</a></p>

</div>
  </body>
</html>
EOF



