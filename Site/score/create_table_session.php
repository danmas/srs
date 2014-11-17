<?php
	include("../../db_connect.php");

	//mysql_query("DROP TABLE SESSIONS");
	
	mysql_query("CREATE TABLE SESSIONS (
	  id INT AUTO_INCREMENT,
	  ip CHAR(128),
	  time_start_game DATETIME,
	  time_end_game DATETIME,
	  scenario CHAR(32),
	  player_name CHAR(32),
	  comment TEXT,
	  PRIMARY KEY(id)
	)") Or die(mysql_error());
	mysql_close ();
	echo("Таблица SESSIONS создана.");
?>	