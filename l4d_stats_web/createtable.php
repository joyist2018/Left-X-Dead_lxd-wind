<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Table Creation page - "createtable.php"
================================================
*/

// Include the primary PHP functions file
include("./common.php");

$i = 0;
$result = mysql_query ("SHOW TABLES");

while ($row = mysql_fetch_array($result)) {
    if ($row[0] == "maps" || $row[0] == "players")
        $i++;
}

if ($i == 2) {
    echo "Tables already exist!<br />\n";
    exit;
}

$create_version = "CREATE TABLE version (
version varchar(16) not null,
PRIMARY KEY (version)
);";

$insert_version = "INSERT INTO version (version) VALUES ('1.3.4');";


$create_maps = "CREATE TABLE maps (
	name varchar(255) not null,
	playtime_nor int(11) not null,
	playtime_adv int(11) not null,
	playtime_exp int(11) not null,
	restarts_nor int(11) not null,
	restarts_adv int(11) not null,
	restarts_exp int(11) not null,
	points_nor int(11) not null,
	points_adv int(11) not null,
	points_exp int(11) not null,
	kills_nor int(11) not null,
	kills_adv int(11) not null,
	kills_exp int(11) not null,
	PRIMARY KEY (name)
);";

$insert_maps = "INSERT INTO maps (name) VALUES ('l4d_airport01_greenhouse'),
('l4d_airport02_offices'),
('l4d_airport03_garage'),
('l4d_airport04_terminal'),
('l4d_airport05_runway'),
('l4d_farm01_hilltop'),
('l4d_farm02_traintunnel'),
('l4d_farm03_bridge'),
('l4d_farm04_barn'),
('l4d_farm05_cornfield'),
('l4d_hospital01_apartment'),
('l4d_hospital02_subway'),
('l4d_hospital03_sewers'),
('l4d_hospital04_interior'),
('l4d_hospital05_rooftop'),
('l4d_smalltown01_caves'),
('l4d_smalltown02_drainage'),
('l4d_smalltown03_ranchhouse'),
('l4d_smalltown04_mainstreet'),
('l4d_smalltown05_houseboat'),
('l4d_garage01_alleys'),
('l4d_garage02_lots');";

$create_players = "CREATE TABLE players (
	id mediumint(8) unsigned not null auto_increment,
	steamid varchar(255) character set utf8 collate utf8_general_ci not null,
	name varchar(255) character set utf8 collate utf8_general_ci not null,
	ServerName varchar(255) character set utf8 collate utf8_general_ci not null,
	password varchar(255) character set utf8 collate utf8_general_ci not null,
	lastontime varchar(255) not null,
	playtime int(11) not null,
	points int(11) not null,
	kills int(11) not null,
	headshots int(11) not null,
	kill_infected int(11) not null,
	kill_hunter int(11) not null,
	kill_smoker int(11) not null,
	kill_boomer int(11) not null,
	award_pills int(11) not null,
	award_medkit int(11) not null,
	award_hunter int(11) not null,
	award_smoker int(11) not null,
	award_protect int(11) not null,
	award_revive int(11) not null,
	award_rescue int(11) not null,
	award_campaigns int(11) not null,
	award_tankkill int(11) not null,
	award_tankkillnodeaths int(11) not null,
	award_allinsafehouse int(11) not null,
	award_friendlyfire int(11) not null,
	award_teamkill int(11) not null,
	award_left4dead int(11) not null,
	award_letinsafehouse int(11) not null,
	award_witchdisturb int(11) not null,
	lastbuytime int(11) not null,
	weapon int(11) not null,
	items int(11) not null,
	lastbuyitem int(11) not null,
	PRIMARY KEY (id)
);";

if (mysql_query($create_maps)) echo "Maps table created successfully!<br /><br />\n"; else echo mysql_error() . "<br /><br />\n";
if (mysql_query($insert_maps)) echo "Maps data inserted successfully!<br /><br />\n"; else echo mysql_error() . "<br /><br />\n";
if (mysql_query($create_players)) echo "Players table created successfully!<br /><br />\n"; else echo mysql_error() . "<br /><br />\n";
if (mysql_query($create_version)) echo "version table created successfully!<br /><br />\n"; else echo mysql_error() . "<br /><br />\n";
if (mysql_query($insert_version)) echo "version data inserted successfully!<br /><br />\n"; else echo mysql_error() . "<br /><br />\n";

echo "All tables created successfully!<br />\n";
?>
