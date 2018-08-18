<table class="stats">
<tr><th colspan="5"><a href="<?=$page_prev;?>"><< 向前 100</a> | 页面 <?=$page_current;?> / <?=$page_total;?> | <a href="<?=$page_next;?>">向后 100 >></a></th></tr>
<tr><th>排名</th><th>玩家</th><th>得分</th><th>游戏时间</th><th>最后在线</th></tr>
<?php foreach ($players as $player): ?><?=$player;?><?php endforeach; ?>
<tr><th colspan="5"><a href="<?=$page_prev;?>"><< 向前 100</a> | 页面 <?=$page_current;?> / <?=$page_total;?> | <a href="<?=$page_next;?>">向后 100 >></a></th></tr>
</table>

