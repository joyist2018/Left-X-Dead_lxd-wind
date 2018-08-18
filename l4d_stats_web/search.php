<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Player Search page - "search.php"
================================================
*/

// Include the primary PHP functions file
include("./common.php");

// Load outer template
$tpl = new Template("./templates/layout.tpl");

// Set Steam ID as var, and quit on hack attempt
$searchstring = mysql_real_escape_string($_POST['search']);
if ($searchstring."" == "") $searchstring = md5("nostring");

$tpl->set("site_name", $site_name); // Site name
$tpl->set("title", "玩家搜索"); // Window title
$tpl->set("page_heading", "玩家搜索"); // Page header

$result = mysql_query("SELECT * FROM players WHERE name LIKE '%" . $searchstring . "%' OR steamid LIKE '%" . $searchstring . "%' ORDER BY points DESC LIMIT 100");
if (mysql_error()) {
    $output = "<p><b>MySQL Error:</b> " . mysql_error() . "</p>\n";
} else {
        $arr_online = array();
        $stats = & new Template('./templates/online.tpl');

        $i = 1;
        while ($row = mysql_fetch_array($result)) {
			$row['ServerNameDisplay']=($row['ServerName'] == '58.61.167.197:27017'?"<span style='color:red'>{$row['ServerName'] } 高难服</span>":$row['ServerName'] );
            $line = ($i & 1) ? "<tr>" : "<tr class=\"alt\">";
            $line .= "<td><a href=\"player.php?userid=" . $row['id']. "\">" . htmlentities($row['steamid'], ENT_COMPAT, "UTF-8") . "</a></td>";
            $line .= "<td>" . number_format($row['points']) . "</td><td>" . formatage($row['playtime'] * 60) . "</td><td>". $row['ServerNameDisplay']. "</td></tr>\n";

            $i++;
            $arr_online[] = $line;
        }

        if (mysql_num_rows($result) == 0) $arr_online[] = "<tr><td colspan=\"3\" align=\"center\">没有找到符合查询条件的信息!</td</tr>\n";
        $stats->set("online", $arr_online);
        $output = $stats->fetch("./templates/online.tpl");
    }


    $tpl->set('body', trim($output));

// Output the top10
$tpl->set("top10", $top10);

// Print out the page!
echo $tpl->fetch("./templates/layout.tpl");
?>
