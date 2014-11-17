﻿<?php
	include("../../db_connect.php");

	echo "<H2>".$scenario_name."</H2>";
	echo "<BR><BR>";
		
	// SQL-запрос
	$strSQL = "SELECT * FROM SCORES WHERE scenario  = '".$scenario_name."' order by score desc";

	//echo($strSQL);

	// Выполнить запрос (набор данных $rs содержит результат)
	$rs = mysql_query($strSQL);
	
	// Цикл по recordset $rs
	// Каждый ряд становится массивом ($row) с помощью функции mysql_fetch_array
	$i = 0;
echo "<TABLE BORDER CELLPADDING=10 CELLSPACING=0>";
        echo "<TR>";
		        echo "<TH>№</TH>";
		        echo "<TH>Score</TH>";
		        echo "<TH>Player</TH>";
		        echo "<TH>Success</TH>";
				echo "<TH>Date</TH>";
        echo "</TR>";

	while($row = mysql_fetch_array($rs)) {
		$i = $i +1;
        echo "<TR>";
		   // Записать значение столбца FirstName (который является теперь массивом $row)
		  //echo "<TD>".$i."</TD><TD>". $row['score'] ."</TD><TD>". $row['player_name'] ."</TD><TD>". $row['success']."</TD>";  
		  echo "<TD>".$i."</TD><TD>". $row['score'] ."</TD><TD>". $row['player_name'] ."</TD><TD>". $row['success']."</TD><TD>".$row['time_game']."</TD>";  
			
		//."  ". $row['time_game']
        echo "</TR>";
        echo "<TR>";
			echo "<TD  COLSPAN=5>";
			echo $row['comment'];
			echo "</TD>";
        echo "</TR>";
	  }
echo("</TABLE>");	

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