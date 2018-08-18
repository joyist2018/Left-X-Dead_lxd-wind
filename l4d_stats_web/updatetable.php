<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Table Update page - "updatetable.php"
================================================
Changelog

-- 1/27/09
Added alter to Players table
================================================
*/

// Include the primary PHP functions file
include("./common.php");

$alter_players = "ALTER TABLE players CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;";
if (mysql_query($alter_players)) echo "Players table altered successfully!<br /><br />\n"; else echo mysql_error() . "<br /><br />\n";

echo "All changes made successfully!<br />\n";
?>
