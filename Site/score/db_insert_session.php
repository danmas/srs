﻿<?php
	include("../../db_connect.php");

	//$ip = $_GET["ip"];
	$scenario = $_GET["scenario"];
	$player_name = $_GET["player_name"];
	$comment = $_GET["comment"];

	$strSQL = "INSERT INTO SESSIONS(scenario,time_start_game,player_name,comment
	) VALUES('$scenario',NOW(),'$player_name','$comment'
	)";
	//echo($strSQL);	
	
	// SQL-оператор выполняется
	mysql_query($strSQL) or die (mysql_error());

	$strSQL = "SELECT max(id) max_id FROM SESSIONS";
	$rs = mysql_query($strSQL);
	$row = mysql_fetch_array($rs);
	$v = $row['max_id'];
	$mytext = "gameid=35&hh=$v&par=76";
	
	print $mytext;

	//echo $mytext;
	//-- НЕ ИЗМЕНЯТЬ! Если успех то должно вернуться слово SUCCESS
	//echo("SUCCESS");
?>