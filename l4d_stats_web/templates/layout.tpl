<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>Status Left 4 Dead 玩家信息统计 : <?=$title;?></title>
<link href="./style.css" rel="stylesheet" type="text/css" />
</head>
<body>

<!-- start header -->
<div id="header">
	<div id="logo">
		<h1>Status Left 4 Dead 加强服 玩家信息系统</h1>
		<h2><?=$site_name;?></h2>
	</div>
</div>
<!-- end header -->

<!-- start page -->
<div id="page">
	<!-- start content -->
	<div id="content">
                <div class="post">
			<h1 class="title" style="background: none; padding: 0; margin-top: -3px;"><?=$page_heading;?></h1>
		</div>

		<?=$body;?>

	</div>
	<!-- end content -->

	<!-- start sidebar -->
	<div id="sidebar">
		<ul>
			<li>
				<h2>Left 4 Dead 统计</h2>
				<ul>
					<li><a href="index.php">在线玩家</a></li>
					<li><a href="playerlist.php">玩家排名</a></li>
					<li><a href="search.php">玩家搜索</a></li>
					<li><a href="awards.php"><b>风云玩家</b></a></li>
					<li><a href="maps.php">战役统计</a></li>
				</ul>
			</li>

			<li>
				<h2>搜索玩家</h2>
				<ul>
					<li>搜索<b>玩家昵称或STEAMID</b></li>
					<li><form method="post" action="search.php">
					<input type="text" id="s" name="search" value="" />
					<input type="submit" id="x" name="submit" value="搜索" />
					</form></li>
				</ul>
			</li>

			<li>
				<h2>玩家排名前十</h2>
				<ul>
					<?php foreach ($top10 as $text): ?>
					<li><?=$text;?></li>
					<?php endforeach; ?>
				</ul>
			</li>
		</ul>
	</div>
	<!-- end sidebar -->
	<div style="clear: both;">&nbsp;</div>
</div>
<!-- end page -->

<!-- start footer -->
<div id="footer">
	<p id="legal">Copyright &copy; 2009 <a href="http://www.msleeper.com/" target=_blank>msleeper & Wind </a> | Left 4 Dead Stats written for <a href="http://forums.alliedmods.net/showthread.php?t=84022" target=_blank>SourceMod</a></p>
</div>
<!-- end footer -->

</body>
</html>
