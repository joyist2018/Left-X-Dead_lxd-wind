<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Common PHP functions and code - "common.php"
================================================
*/

// Include configuration file
include("./config.php");

// Include Template engine class
include("./class_template.php");

function getfriendid($pszAuthID)
{
    $iServer = "0";
    $iAuthID = "0";

    $szAuthID = $pszAuthID;

    $szTmp = strtok($szAuthID, ":");

    while(($szTmp = strtok(":")) !== false)
    {
        $szTmp2 = strtok(":");
        if($szTmp2 !== false)
        {
            $iServer = $szTmp;
            $iAuthID = $szTmp2;
        }
    }

    if($iAuthID == "0")
        return "0";

    $i64friendID = bcmul($iAuthID, "2");

    //Friend ID's with even numbers are the 0 auth server.
    //Friend ID's with odd numbers are the 1 auth server.
    $i64friendID = bcadd($i64friendID, bcadd("76561197960265728", $iServer));

    return $i64friendID;
}

function formatage($date) {
    $nametable = array(" 秒", " 分", " 小时", " 天", " 周", " 月", " 年");
    $agetable = array("60", "60", "24", "7", "4", "12", "10");
    $ndx = 0;

    while ($date > $agetable[$ndx]) {
        @$date = $date / $agetable[$ndx];
        $ndx++;
        next($agetable);
    }

    return number_format($date, 2).$nametable[$ndx];
}

function getpopulation($population, $file, $cityonly) {
    $cityarr = array();
    $page = fopen($file, "r");
    while (($data = fgetcsv($page, 1000, ",")) !== FALSE) {
        if ((strstr($data[0], "County") || strstr($data[0], "Combined")) && $cityonly)
            continue;

        $cityarr[$data[1]] = $data[2];
    }

    fclose($page);
    asort($cityarr, SORT_NUMERIC);

    $returncity = "";
    $returncity2 = "";

    foreach ($cityarr as $city => $pop) {
        if ($population > $pop)
            $returncity = $city;
        else {
            $returncity2 = $city;
            break;
        }
    }

    $return = array($returncity,
                    $cityarr[$returncity],
                    $returncity2,
                    $cityarr[$returncity2]);

    return $return;
}

if (!function_exists('file_put_contents')) {
    function file_put_contents($filename, $data) {
        $f = @fopen($filename, 'w');
        if (!$f) {
            return false;
        } else {
            $bytes = fwrite($f, $data);
            fclose($f);
            return $bytes;
        }
    }
}

if (basename($_SERVER['PHP_SELF']) !== "createtable.php" && basename($_SERVER['PHP_SELF']) !== "updatetable.php") {
    if (file_exists("./createtable.php")) {
        echo "Delete the file <b>createtable.php</b> before running webstats!<br />\n";
        exit;
    }
    if (file_exists("./updatetable.php")) {
        echo "Delete the file <b>updatetable.php</b> before running webstats!<br />\n";
        exit;
    }
}

mysql_connect($mysql_server, $mysql_user, $mysql_password);
mysql_select_db($mysql_db);

mysql_query("SET NAMES 'utf8'");

$campaigns = array("l4d_hospital" => "毫不留情",
                   "l4d_airport" => "死亡机场",
                   "l4d_smalltown" => "死亡丧钟",
                   "l4d_farm" => "血腥收获",
				   "l4d_garage" => "迫在眉睫");

$i = 1;
$top10 = array();

$result = mysql_query("SELECT * FROM players ORDER BY points DESC LIMIT 10");
while ($row = mysql_fetch_array($result)) {
    $top10[] = "<b>" . $i . " ) <a href=\"player.php?userid=" . $row['id'] . "\">" . htmlentities($row['steamid'], ENT_COMPAT, "UTF-8") . "</a></b> (" . number_format($row['points']) . " 积分)";
    $i++;
}
?>
