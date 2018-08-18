<?php
/*
================================================
LEFT 4 DEAD PLAYER RANK
Copyright (c) 2009 Mitchell Sleeper
Originally developed for WWW.F7LANS.COM
================================================
Index / Players Online page - "index.php"
================================================
*/

// Include the primary PHP functions file
include("./common.php");

// Load outer template
$tpl = new Template("./templates/layout.tpl");

$result = mysql_query("SELECT * FROM players WHERE lastontime >= '" . intval(time() - 300) . "' ORDER BY points DESC");
$playercount = number_format(mysql_num_rows($result));

$tpl->set("site_name", $site_name); // Site name
$tpl->set("title", "在线玩家"); // Window title
$tpl->set("page_heading", "在线玩家信息 - [ " . $playercount." ]"); // Page header

if (mysql_error()) {
    $output = "<p><b>MySQL 错误,请联系QQ:264590:</b> " . mysql_error() . "</p>\n";

} else {
    $arr_online = array();
    $stats = & new Template('./templates/online.tpl');

    $i = 1;
    while ($row = mysql_fetch_array($result)) {
        if ($row['lastontime'] > time()) $row['lastontime'] = time();

    $row['ServerNameDisplay']=($row['ServerName'] == '58.61.167.197:27017'?"<span style='color:red'>{$row['ServerName'] } 高难服</span>":$row['ServerName'] );

        $line = ($i & 1) ? "<tr>" : "<tr class=\"alt\">";
        $line .= "<td><a href=\"player.php?userid=" . $row['id']. "\">" . htmlentities($row['steamid'], ENT_COMPAT, "UTF-8") . "</a></td>";
       $line .= "<td>" . number_format($row['points']) . "</td><td>" . formatage($row['playtime'] * 60) . "</td><td>" . $row['ServerNameDisplay'] . "</td></tr>\n";

        $i++;
        $arr_online[] = $line;
    }

    if (mysql_num_rows($result) == 0) $arr_online[] = "<tr><td colspan=\"3\" align=\"center\">当前服务器为空!</td</tr>\n";

    $stats->set("online", $arr_online);
    $output = $stats->fetch("./templates/online.tpl");
}

$tpl->set('body', trim($output));

// Output the top 10 
$tpl->set("top10", $top10);

// Print out the page!
echo $tpl->fetch("./templates/layout.tpl");
?>