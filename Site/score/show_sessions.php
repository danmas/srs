﻿<?php
	include("../../db_connect.php");

	echo "<H2>Sessions</H2>";
	echo "<BR><BR>";
		
	// SQL-запрос
	$strSQL = "SELECT * FROM SESSIONS order by id desc";

	//echo($strSQL);

	// Выполнить запрос (набор данных $rs содержит результат)
	$rs = mysql_query($strSQL);
	
	// Цикл по recordset $rs
	// Каждый ряд становится массивом ($row) с помощью функции mysql_fetch_array
	$i = 0;
echo "<TABLE BORDER CELLPADDING=10 CELLSPACING=0>";
        echo "<TR>";
		        echo "<TH>№</TH>";
		        echo "<TH>ID</TH>";
		        echo "<TH>Scenario</TH>";
		        echo "<TH>Time start</TH>";
				echo "<TH>Time end</TH>";
				echo "<TH>player_name</TH>";
		        echo "<TH>Comment</TH>";
        echo "</TR>";

	while($row = mysql_fetch_array($rs)) {
		$i = $i +1;
        echo "<TR>";
		  echo "<TD>".$i."</TD><TD>". $row['id'] ."</TD><TD>". $row['scenario'] ."</TD><TD>". $row['time_start_game']
				."</TD><TD>".$row['time_end_game']."</TD><TD>".$row['player_name']."</TD>";  
        echo "</TR>";
        echo "<TR>";
			echo "<TD  COLSPAN=6>";
			echo $row['comment'];
			echo "</TD>";
        echo "</TR>";
	  }
echo("</TABLE>");	

/*
	$session_id = '2';

	$strSQL = "UPDATE SESSIONS SET time_end_game=NOW() WHERE id = '$session_id'";
	mysql_query($strSQL);
*/	
/*	
	$strSQL = "SELECT max(id) max_id FROM SESSIONS";
	$rs = mysql_query($strSQL);
	$row = mysql_fetch_array($rs);
	$mytext = $row['max_id'];
	echo $mytext;
*/
	// Закрыть соединение с БД
	mysql_close();
?>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-40773925-1', 'zz.mu');
  ga('send', 'pageview');

</script>