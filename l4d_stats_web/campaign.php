<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Campaign detailed stats - "campaign.php"
================================================
*/

// Include the primary PHP functions file
include("./common.php");

// Load outer template
$tpl = new Template("./templates/layout.tpl");

// Set Campaign ID as var, and quit on hack attempt
if (strstr($_GET['id'], "/")) exit;
$campaign = $_GET['id'];

$title = $campaigns[$campaign];
if ($title."" == "") {
    $tpl->set("site_name", $site_name); // Site name
    $tpl->set("title", "错误的战役信息"); // Window title
    $tpl->set("page_heading", "错误的战役信息"); // Page header

    $output = "你选择了一个错误战役信息,请返回并联系管理员QQ:264590.";
    $tpl->set("body", trim($output));

    // Output the top 10
    $tpl->set("top10", $top10);

    // Print out the page!
    echo $tpl->fetch("./templates/layout.tpl");

    exit;
}

$tpl->set("site_name", $site_name); // Site name
$tpl->set("title", $title . " 状态"); // Window title
$tpl->set("page_heading", $title . " 状态"); // Page header

$totalkills = 0;
$result = mysql_query("SELECT * FROM maps WHERE name LIKE '" . $campaign . "%' ORDER BY name ASC");
while ($row = mysql_fetch_array($result)) {
    $stats = & new Template('./templates/page.tpl');
    $stats->set("page_subject", $row['steamid']);

    $map = & new Template('./templates/maps_detailed.tpl');
    $playtime_arr = array(formatage($row['playtime_nor'] * 60),
                          formatage($row['playtime_adv'] * 60),
                          formatage($row['playtime_exp'] * 60),
                          formatage(($row['playtime_nor'] * 60) + ($row['playtime_adv'] * 60) + ($row['playtime_exp'] * 60)));

    $points_arr = array(number_format($row['points_nor']),
                        number_format($row['points_adv']),
                        number_format($row['points_exp']),
                        number_format($row['points_nor'] + $row['points_adv'] + $row['points_exp']));

    $kills_arr = array(number_format($row['kills_nor']),
                       number_format($row['kills_adv']),
                       number_format($row['kills_exp']),
                       number_format($row['kills_nor'] + $row['kills_adv'] + $row['kills_exp']));

    $restarts_arr = array(number_format($row['restarts_nor']),
                          number_format($row['restarts_adv']),
                          number_format($row['restarts_exp']),
                          number_format($row['restarts_nor'] + $row['restarts_adv'] + $row['restarts_exp']));

    $totalkills = $totalkills + ($row['kills_nor'] + $row['kills_adv'] + $row['kills_exp']);

    $map->set("playtime", $playtime_arr);
    $map->set("points", $points_arr);
    $map->set("kills", $kills_arr);
    $map->set("restarts", $restarts_arr);
    $body = $map->fetch("./templates/maps_detailed.tpl");

    $stats->set("page_body", $body);
    $output .= $stats->fetch("./templates/page.tpl");
}

$campaignpop = getpopulation($totalkills, $population_file, False);
$campaigninfo = "<p>在 <b>" . $title . "</b> 战役中死亡的僵尸已超过了 <a href=\"http://google.com/search?q=site:en.wikipedia.org+" . $campaignpop[0] . "&btnI=1\">" . $campaignpop[0] . "</a>, 的总人口数量 <b>" . number_format($campaignpop[1]) . "</b>.<br />几乎要达到了 <a href=\"http://google.com/search?q=site:en.wikipedia.org+" . $campaignpop[2] . "&btnI=1\">" . $campaignpop[2] . "</a>, 的总人口数量 <b>" . number_format($campaignpop[3]) . "</b>!</p>\n";

$tpl->set("body", trim($campaigninfo . $output));

// Output the top 10 
$tpl->set("top10", $top10);

// Print out the page!
echo $tpl->fetch("./templates/layout.tpl");
?>
