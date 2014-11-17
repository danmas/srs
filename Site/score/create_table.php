<?php
	include("../../db_connect.php");

	//mysql_query("DROP TABLE SCORES");
	
	mysql_query("CREATE TABLE SCORES (
	  id INT AUTO_INCREMENT,
	  time_game DATETIME,
	  scenario CHAR(32),
	  player_name CHAR(32),
	  success CHAR(32),
	  comment TEXT,
	  score INT,
	  EHC INT,
	  FHC INT,
	  ED INT,
	  FD INT,
	  EFC INT,
	  FFC INT,
	  TLP INT,
	  TG INT,
	  PRIMARY KEY(id)
	)") Or die(mysql_error());
	mysql_close ();
	echo("Таблица SCORES создана.");
?>	