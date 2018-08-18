<div class="post">
	<div class="entry">
		<p>被消灭的僵尸数量已经超过了总人口为<b><?=number_format($totalpop[1]);?></b>的<a href="http://google.com/search?q=site:zh.wikipedia.org+<?=$totalpop[0];?>&btnI=1"><?=$totalpop[0];?></a>.<br />
		几乎要达到总人口为<b><?=number_format($totalpop[3]);?></b>的<a href="http://google.com/search?q=site:zh.wikipedia.org+<?=$totalpop[2];?>&btnI=1"><?=$totalpop[2];?></a> !</p>

		<table class="stats">
		<tr><th>战役名称</th><th>总游戏时间</th><th>获得分数总计</th><th>杀敌总计</th><th>重新开始总计</th></tr>
		<?php foreach ($maps as $map): ?><?=$map;?><?php endforeach; ?>
		</table>
	</div>
</div>
