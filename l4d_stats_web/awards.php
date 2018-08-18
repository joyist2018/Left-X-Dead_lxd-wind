<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Rank Awards page - "awards.php"
================================================
*/

// Include the primary PHP functions file
include("./common.php");

// Load outer template
$tpl = new Template("./templates/layout.tpl");

// Include award file
include("./" . $award_file);

$awardarr = array("kills" => $award_kills,
                  "headshots" => $award_headshots,

                  "kill_infected" => $award_killinfected,
                  "kill_hunter" => $award_killhunter,
                  "kill_smoker" => $award_killsmoker,
                  "kill_boomer" => $award_killboomer,

                  "award_pills" => $award_pills,
                  "award_medkit" => $award_medkit,
                  "award_hunter" => $award_hunter,
                  "award_smoker" => $award_smoker,
                  "award_protect" => $award_protect,
                  "award_revive" => $award_revive,
                  "award_rescue" => $award_rescue,
                  "award_campaigns" => $award_campaigns,
                  "award_tankkill" => $award_tankkill,
                  "award_tankkillnodeaths" => $award_tankkillnodeaths,
                  "award_allinsafehouse" => $award_allinsafehouse,

                  "award_friendlyfire" => $award_friendlyfire,
                  "award_teamkill" => $award_teamkill,
                  "award_left4dead" => $award_left4dead,
                  "award_letinsafehouse" => $award_letinsafehouse,
                  "award_witchdisturb" => $award_witchdisturb);

$cachedate = filemtime("./templates/awards_cache.html");
if ($cachedate < time() - (60*$award_cache_refresh)) {
    $row = mysql_fetch_array(mysql_query("SELECT * FROM players ORDER BY playtime DESC LIMIT 1"));
    $row2 = mysql_fetch_array(mysql_query("SELECT * FROM players ORDER BY playtime DESC LIMIT 1,1"));

    $table_body .= "<tr><td>" . sprintf($award_time, "player.php?userid=" . $row['id'], htmlentities($row['steamid'], ENT_COMPAT, "UTF-8"), formatage($row['playtime'] * 60)) . "<br />\n";
    $table_body .= "<i style=\"font-size: 12px;\">" . sprintf($award_second, "player.php?userid=" . $row2['id'], htmlentities($row2['steamid'], ENT_COMPAT, "UTF-8"), formatage($row2['playtime'] * 60)) . "</i></td></tr>\n";

    $headshotratiosql = "playtime >= " . $award_minplaytime . " AND points >= " . $award_minpoints . " AND kills >= " . $award_minkills . " AND headshots >= " . $award_minheadshots;
    $row = mysql_fetch_array(mysql_query("SELECT * FROM players WHERE " . $headshotratiosql . " ORDER BY (headshots/kills) DESC LIMIT 1"));
    $row2 = mysql_fetch_array(mysql_query("SELECT * FROM players WHERE " . $headshotratiosql . " ORDER BY (headshots/kills) DESC LIMIT 1,1"));

    if ($row['headshots'] && $row['kills']) {
        $table_body .= "<tr><td>" . sprintf($award_ratio, "player.php?userid=" . $row['id'], htmlentities($row['steamid'], ENT_COMPAT, "UTF-8"), number_format($row['headshots'] / $row['kills'], 4) * 100) . "<br />\n";
        $table_body .= "<i style=\"font-size: 12px;\">" . sprintf($award_second, "player.php?userid=" . $row2['id'], htmlentities($row2['steamid'], ENT_COMPAT, "UTF-8"), (number_format($row2['headshots'] / $row2['kills'], 4) * 100) . "&#37;") . "</i></td></tr>\n";
    }

    foreach ($awardarr as $award => $awardstring) {
        $awardtmp = array();
        $id = array();

        $awardsql = ($award !== "award_teamkill" || $award !== "award_friendlyfire") ? " WHERE playtime >= " . $award_minplaytime . " AND points >= " . $award_minpointstotal : "";

        $result = mysql_query("SELECT * FROM players " . $awardsql . " ORDER BY " . $award . " DESC LIMIT 2");
        while ($row = mysql_fetch_array($result)) {
            $awardtmp[] = array(htmlentities($row['steamid'], ENT_COMPAT, "UTF-8"), $row[$award]."");
            $id[] = $row['id'];
        }

        $table_body .= "<tr><td>" . sprintf($awardstring, "player.php?userid=" . $id[0], $awardtmp[0][0], number_format($awardtmp[0][1])) . "<br />\n";
        $table_body .= "<i style=\"font-size: 12px;\">" . sprintf($award_second, "player.php?userid=" . $id[1], $awardtmp[1][0], number_format($awardtmp[1][1])) . "</i></td></tr>\n";
    }

    $stats = & new Template('./templates/awards.tpl');
    $stats->set("awards_date", date("g:ia, m/d/y", time()));
    $stats->set("awards_body", $table_body);
    $award_output = $stats->fetch("./templates/awards.tpl");
    file_put_contents("./templates/awards_cache.html", trim($award_output));
}

$tpl->set("site_name", $site_name); // Site name
$tpl->set("title", "排名奖励"); // Window title
$tpl->set("page_heading", "排名奖励"); // Page header

$output = file_get_contents("./templates/awards_cache.html");

$tpl->set('body', trim($output));

// Output the top10
$tpl->set("top10", $top10);

// Print out the page!
echo $tpl->fetch("./templates/layout.tpl");
?>
