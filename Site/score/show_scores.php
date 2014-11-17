<?php
	include("../../db_connect.php");

		
	// SQL-запрос
	$strSQL = "SELECT * FROM SCORES order by score desc";

	// Выполнить запрос (набор данных $rs содержит результат)
	$rs = mysql_query($strSQL);
	
	// Цикл по recordset $rs
	// Каждый ряд становится массивом ($row) с помощью функции mysql_fetch_array
	$i = 0;
	while($row = mysql_fetch_array($rs)) {
		$i = $i +1;
	   // Записать значение столбца FirstName (который является теперь массивом $row)
	  echo $i." ". $row['scenario'] ." ". $row['player_name'] ." ". $row['score'] ." ". $row['success'] ." ". $row['time_game'] 
		."<br/> ". $row['comment'] . "<br/><br/>";
	  }

	// Закрыть соединение с БД
	mysql_close();
?>