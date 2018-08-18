<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Player stats page - "player.php"
================================================
*/

// Include the primary PHP functions file
include("./common.php");

// Load outer template
$tpl = new Template("./templates/layout.tpl");

// Set Steam ID as var, and quit on hack attempt
if (strstr($_GET['userid'], "/")) exit;
$id = $_GET['userid'];

$tpl->set("site_name", $site_name); // Site name

$row = mysql_fetch_array(mysql_query("SELECT * FROM players WHERE id = '" . $id . "'"));
$rank = mysql_num_rows(mysql_query("SELECT id FROM players WHERE points >= '" . $row['points'] . "'"));

$arr_kills = array();
$arr_kills['僵尸'] = $row['kill_infected'];
$arr_kills['亨特'] = $row['kill_hunter'];
$arr_kills['烟鬼'] = $row['kill_smoker'];
$arr_kills['胖子'] = $row['kill_boomer'];

$arr_awards = array();
$arr_awards['赠于药丸次数'] = $row['award_pills'];
$arr_awards['赠于血包次数'] = $row['award_medkit'];
$arr_awards['从亨特抓下帮助队友逃脱'] = $row['award_hunter'];
$arr_awards['从烟鬼的舌头下帮助队友逃脱'] = $row['award_smoker'];
$arr_awards['保护队友次数'] = $row['award_protect'];
$arr_awards['拯救队友次数'] = $row['award_revive'];
$arr_awards['营救队友次数'] = $row['award_rescue'];
$arr_awards['所在团队杀死的TANK次数'] = $row['award_tankkill'];
$arr_awards['无死亡杀死TANK的次数'] = $row['award_tankkillnodeaths'];
$arr_awards['所有玩家安全到达安全屋次数'] = $row['award_allinsafehouse'];
$arr_awards['战役完成次数'] = $row['award_campaigns'];

$arr_demerits = array();
$arr_demerits['火焰伤害队友次数'] = $row['award_friendlyfire'];
$arr_demerits['使队友死亡次数'] = $row['award_teamkill'];
$arr_demerits['TK队友次数'] = $row['award_left4dead'];
$arr_demerits['使僵尸跑进安全屋次数'] = $row['award_letinsafehouse'];
$arr_demerits['使得女巫不安次数'] = $row['award_witchdisturb'];

if (mysql_num_rows(mysql_query("SELECT * FROM players WHERE id='" . $row['id'] . "'")) > 0)
{
    $tpl->set("title", "玩家状态: " . htmlentities($row['steamid'], ENT_COMPAT, "UTF-8")); // Window title
    $tpl->set("page_heading", "玩家状态: " . htmlentities($row['steamid'], ENT_COMPAT, "UTF-8")); // Page header

    $stats = & new Template('./templates/player.tpl');
    $stats->set("player_name", htmlentities($row['steamid'], ENT_COMPAT, "UTF-8"));
	$stats->set("player_steamid", "<a href=\"http://steamcommunity.com/profiles/" . getfriendid($row['name']) . "\" target=_blank>".htmlentities($row['name'], ENT_COMPAT, "UTF-8"));
	$stats->set("player_hostip", htmlentities($row['ServerName'], ENT_COMPAT, "UTF-8"));


    $stats->set("player_lastonline", date("M d, Y g:ia", $row['lastontime']) . " (" . formatage(time() - $row['lastontime']) . " 之前)");
    $stats->set("player_playtime", formatage($row['playtime'] * 60) . " (" . number_format($row['playtime']) . " 分钟)");
    $stats->set("player_rank", $rank);
    $stats->set("player_points", number_format($row['points']));
    $stats->set("player_kills", number_format($row['kills']));
    $stats->set("player_headshots", number_format($row['headshots']));

    if ($row['kills'] == 0 || $row['headshots'] == 0) $stats->set("player_ratio", "0");
    else $stats->set("player_ratio", number_format($row['headshots'] / $row['kills'], 4) * 100);

    $stats->set("player_kpm", number_format($row['kills'] / $row['playtime'], 4));
    $stats->set("player_ppm", number_format($row['points'] / $row['playtime'], 4));

    $arr_achievements = array();

    if ($row['kills'] > $population_minkills) {
        $popkills = getpopulation($row['kills'], $population_file, $population_cities);
        $arr_achievements[] = "<td><b>城市猎人</b></td>
        <td>你已杀死的僵尸数量相当于 <a href=\"http://google.com/search?q=site:en.wikipedia.org+" . $popkills[0] . "&btnI=1\">" . $popkills[0] . "</a> 这个城市居民数 " . number_format($popkills[1]) . ".<br />
        这几乎超过 <a href=\"http://google.com/search?q=site:en.wikipedia.org+" . $popkills[2] . "&btnI=1\">" . $popkills[2] . "</a>, 这个城市的居民数 " . number_format($popkills[3]) . ".</td>";
    }

    if (count($arr_achievements) === 0)
        $arr_achievements[] = "<td><b>N/A</b></td><td>您还没有获得任何成就.</td>";

    arsort($arr_kills);
    arsort($arr_awards);
    arsort($arr_demerits);

    $stats->set("arr_kills", $arr_kills);
    $stats->set("arr_awards", $arr_awards);
    $stats->set("arr_demerits", $arr_demerits);
    $stats->set("arr_achievements", $arr_achievements);

    $output = $stats->fetch("./templates/player.tpl");
} else {
    $tpl->set("title", "玩家状态: INVALID"); // Window title
    $tpl->set("page_heading", "玩家状态: INVALID"); // Page header

    $output = "该ID的玩家并未在我们的统计系统中被登记过.";
}

$tpl->set('body', trim($output));

// Output the top 10
$tpl->set("top10", $top10);

// Print out the page!
echo $tpl->fetch("./templates/layout.tpl");
?>
