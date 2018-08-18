<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Campaign stats - "maps.php"
================================================
*/

// Include the primary PHP functions file
include("./common.php");

// Load outer template
$tpl = new Template("./templates/layout.tpl");

$tpl->set("site_name", $site_name); // Site name
$tpl->set("title", "战役统计"); // Window title
$tpl->set("page_heading", "战役统计"); // Page header

$maparr = array();
$totals = array();

foreach ($campaigns as $prefix => $title) {
    $result = mysql_query("SELECT playtime_nor + playtime_adv + playtime_exp as playtime,
                                  points_nor + points_adv + points_exp as points,
                                  kills_nor + kills_adv + kills_exp as kills,
                                  restarts_nor + restarts_adv + restarts_exp as restarts FROM maps WHERE name like '" . $prefix . "%'");

    $playtime = 0;
    $points = 0;
    $kills = 0;
    $restarts = 0;

    while ($row = mysql_fetch_array($result)) {
        $playtime = $playtime + $row['playtime'];
        $points = $points + $row['points'];
        $kills = $kills + $row['kills'];
        $restarts = $restarts + $row['restarts'];
    }

    $totals['playtime'] = $totals['playtime'] + ($playtime * 60);
    $totals['points'] = $totals['points'] + $points;
    $totals['kills'] = $totals['kills'] + $kills;
    $totals['restarts'] = $totals['restarts'] + $restarts;

    $line = ($i & 1) ? "<tr>" : "<tr class=\"alt\">";
    $maparr[] = $line . "<td>" . $title . "</td><td>" . formatage($playtime * 60) . "</td><td>" . number_format($points) . "</td><td>" . number_format($kills) . "</td><td>" . number_format($restarts) . "</td></tr>\n";
    $i++;
}

$line = ($i & 1) ? "<tr>" : "<tr class=\"alt\">";
    $maparr[] = $line . "<td><b>共计</b></td><td><b>" . formatage($totals['playtime']) . "</b></td><td><b>" . number_format($totals['points']) . "</b></td><td><b>" . number_format($totals['kills']) . "</b></td><td><b>" . number_format($totals['restarts']) . "</b></td></tr>\n";

$stats = & new Template('./templates/maps_overview.tpl');
$totalpop = getpopulation($totals['kills'], $population_file, True);
$stats->set("totalpop", $totalpop);
$stats->set("maps", $maparr);
$output = $stats->fetch("./templates/maps_overview.tpl");

foreach ($campaigns as $prefix => $title) {

$stats = & new Template('./templates/page.tpl');
$stats->set("page_subject", $title);

$maps = & new Template('./templates/maps_campaign.tpl');
$maparr = array();

$result = mysql_query("SELECT name, playtime_nor + playtime_adv + playtime_exp as playtime,
                              points_nor + points_adv + points_exp as points,
                              kills_nor + kills_adv + kills_exp as kills,
                              restarts_nor + restarts_adv + restarts_exp as restarts FROM maps WHERE name like '" . $prefix . "%' ORDER BY name ASC");

$i = 1;
while ($row = mysql_fetch_array($result)) {
    $line = ($i & 1) ? "<tr>" : "<tr class=\"alt\">";
    $maparr[] = $line . "<td>" . $row['name'] . "</td><td>" . formatage($row['playtime'] * 60) . "</td><td>" . number_format($row['points']) . "</td><td>" . number_format($row['kills']) . "</td><td>" . number_format($row['restarts']) . "</td></tr>\n";
    $i++;
}

$maps->set("maps", $maparr);
$body = $maps->fetch("./templates/maps_campaign.tpl");

$stats->set("page_body", $body);
$stats->set("page_link", "<a href=\"campaign.php?id=" . $prefix . "\">查看详细的 " . $title . "</a>");
$output .= $stats->fetch("./templates/page.tpl");
}

$tpl->set("body", trim($output));

// Output the top 10 
$tpl->set("top10", $top10);

// Print out the page!
echo $tpl->fetch("./templates/layout.tpl");
?>
