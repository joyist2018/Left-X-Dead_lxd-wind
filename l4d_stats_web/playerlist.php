<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Player Ranking list page - "playerlist.php"
================================================
*/

// Include the primary PHP functions file
include("./common.php");

// Load outer template
$tpl = new Template("./templates/layout.tpl");

// Set Steam ID as var, and quit on hack attempt
if (strstr($_GET['page'], "/")) exit;
$page = $_GET['page'];

$tpl->set("site_name", $site_name); // Site name
$tpl->set("title", "玩家排名"); // Window title
$tpl->set("page_heading", "玩家排名"); // Page header

$result = mysql_query("SELECT * FROM players WHERE playtime > 0 AND lastontime > 0 ORDER BY points DESC");

if (mysql_error()) {
    $output = "<p><b>MySQL Error:</b> " . mysql_error() . "</p>\n";

} else {
    $arr_players = array();
    $stats = & new Template('./templates/ranking.tpl');

    $page_current = intval($page);
    $page_perpage = 100;
    $page_maxpages = ceil(intval(mysql_num_rows(mysql_query("SELECT * FROM players ORDER BY points DESC"))) / $page_perpage) - 1;
    $page_nextpage = (intval($page_current + 1) > $page_maxpages) ? "0" : intval($page_current + 1);
    $page_prevpage = intval($page_current - 1);

    if ($page_prevpage < 0) $page_prevpage = $page_maxpages;
    if ($page_prevpage < 1) $page_prevpage = 0;

    $stats->set("page_prev", "playerlist.php?page=" . $page_prevpage);
    $stats->set("page_current", $page_current + 1);
    $stats->set("page_total", $page_maxpages + 1);
    $stats->set("page_next", "playerlist.php?page=" . $page_nextpage);

    $result = mysql_query("SELECT * FROM players ORDER BY points DESC LIMIT ". intval($page_current * $page_perpage) .",". $page_perpage);
    $i = ($page_current !== 0) ? 1 + intval($page_current * 100) : 1;
    while ($row = mysql_fetch_array($result)) {
        $line = ($i & 1) ? "<tr>" : "<tr class=\"alt\">";
        $line .= "<td align=\"center\">" . number_format($i) . "</td><td><a href=\"player.php?userid=" . $row['id']. "\">" . htmlentities($row['steamid'], ENT_COMPAT, "UTF-8") . "</a></td>";
        $line .= "<td>" . number_format($row['points']) . "</td>";
        $line .= "<td>" . formatage($row['playtime'] * 60) . "</td>";
        $line .= "<td>" . formatage(time() - $row['lastontime']) . " 之前</td></tr>\n";
        $arr_players[] = $line;
        $i++;
    }

    $stats->set("players", $arr_players);
    $output = $stats->fetch("./templates/ranking.tpl");
}

$tpl->set('body', trim($output));

// Output the sidebar
$tpl->set("top10", $top10);

// Print out the page!
echo $tpl->fetch("./templates/layout.tpl");
?>
