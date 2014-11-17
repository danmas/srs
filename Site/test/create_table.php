<?php
	mysql_connect("mysql.hostinger.ru", "u710668860_srs", "12345678") or die(mysql_error());
	mysql_select_db("u710668860_srs") or die(mysql_error());

	mysql_query("DROP TABLE SCORES");
	
	mysql_query("CREATE TABLE SCORES (
	  id INT AUTO_INCREMENT,
	  time_game DATETIME,
	  scenario CHAR(32),
	  player_name CHAR(32),
	  success CHAR(32),
	  comment TEXT,
	  score INT,
	  PRIMARY KEY(id)
	)") Or die(mysql_error());
	mysql_close ();
	echo("Таблица SCORES создана.");
?>	