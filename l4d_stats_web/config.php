<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Configuration file - "config.php"
================================================
*/

// MySQL information for L4D Stats DB
$mysql_server = "localhost";
$mysql_user = "user";
$mysql_password = "password";
$mysql_db = "dbname";

// Heading for the stats page. You can add a HTML URL here!
$site_name = "游戏基础帮助<b>  ||  </b>游戏下载<b>  ||  </b>玩家交流 请 <a href=http://www.sy64.com/forum-6-1.html target=_blank>点这里</a>";

// Award definitions file
$award_file = "awards.en.php";

// Minimum playtime and points required to be eligible for any awards, in minutes
$award_minplaytime = 60;
$award_minpointstotal = 0;

// Minimum kills, headshots and points to be eligible for "Headshot Ratio" award
$award_minkills = 1000;
$award_minheadshots = 1000;
$award_minpoints = 1000;

// Amount of time in minutes between Awards page cache updates.
// 0 to disable cacheing
$award_cache_refresh = 60;

/*
Population CSV file. This is taken from the United States Census Bureau, you
can download a (possibly) more up-to-date file from this URL:

http://www.census.gov/popest/datasets.html

The file will be about half way down, under "Metropolitan, micropolitan, and
combined statistical area datasets", the CSV file under "Combined
statistical area population and estimated components of change". Or, check
the release thread and I can provide an exact URL for the download.

Keep in mind that the file has been drastically altered from it's original
state, including adding individual States as well as the entire US. If you
want to create your own CSV file, message me on Allied Modders and I will
help and possibly include it in a next release.
*/

$population_file = "population.usa.csv";

/*
Only display City results, and not Counties. Note: This will drastically
reduce the uniqueness of the results, cities only make up about 1/3rd of
the list. Set to True to enable. Default is False.

Also note, the minimum kills if you are using only citites needs to be
14000 or else you will get erroneous results! Default is 3000.
*/

$population_minkills = 3000;
$population_cities = False;
?>
