<table class="stats">
    <tr valign="top"><td align="center" width="50%">

<table class="statsbox">
<tr><th colspan="2">玩家摘要</th></tr>
<tr><td>排名:</td><td><?=$player_rank;?></td></tr>
<tr><td>得分:</td><td><?=$player_points;?></td></tr>
<tr><td>杀敌:</td><td><?=$player_kills;?></td></tr>
<tr><td>爆头:</td><td><?=$player_headshots;?></td></tr>
<tr><td>爆头率:</td><td><?=$player_ratio;?> %</td></tr>
<tr><td>每分钟杀敌:</td><td><?=$player_kpm;?></td></tr>
<tr><td>每分钟得分:</td><td><?=$player_ppm;?></td></tr>
</table>

    </td><td align="center">

<table class="statsbox">
<tr><th colspan="2">玩家档案</th></tr>
<tr><td>昵称:</td><td><?=$player_name;?></td></tr>
<tr><td>STEAMID:</td><td><?=$player_steamid;?></td></tr>
<tr><td>最后所在:</td><td><?=$player_hostip;?></td></tr>
<tr><td>最后在线:</td><td><?=$player_lastonline;?></td></tr>
<tr><td>最长游戏时间:</td><td><?=$player_playtime;?></td></tr>
</table>

    </td></tr>
    <tr valign="top"><td align="center" width="50%">

<table class="statsbox">
<tr><th>感染者类型</th><th>杀死</th></tr>
<?php foreach ($arr_kills as $type => $kills): ?>
<tr><td><?=$type;?></td><td><?=number_format($kills);?></td></tr>
<?php endforeach;?>
</table><br />

<table class="statsbox">
<tr><th colspan="2">过失</th></tr>
<?php foreach ($arr_demerits as $demerit => $count): ?>
<tr><td align="right"><?=$demerit;?></td><td><?=number_format($count);?></td></tr>
<?php endforeach;?>
</table>

</td>
<td align="center" colspan="2">

<table class="statsbox">
<tr><th colspan="2">奖项</th></tr>
<?php foreach ($arr_awards as $award => $count): ?>
<tr><td align="right"><?=$award;?></td><td><?=number_format($count);?></td></tr>
<?php endforeach;?>
</table>

</td></tr>

<tr><td colspan="2" align="center" width="100%">

<table class="statsbox">
<tr><th colspan="2">成就</th></tr>
<?php foreach ($arr_achievements as $achievement): ?>
<tr><?=$achievement;?></tr>
<?php endforeach;?>
</table>

</td></tr>
</table>

