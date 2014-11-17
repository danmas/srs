﻿<?php
	include("../../db_connect.php");

$scenario = $_GET["scenario"];
//$time_game = $_GET["time_game"];
$player_name = $_GET["player_name"];
$score = $_GET["score"];
$success = $_GET["success"];
$comment = $_GET["comment"];
	
$EHC = $_GET["EHC"];
$FHC = $_GET["FHC"];
$ED = $_GET["ED"];
$FD = $_GET["FD"];
$EFC = $_GET["EFC"];
$FFC = $_GET["FFC"];
$TLP = $_GET["TLP"];
$TG = $_GET["TG"];
	
$session_id	= $_GET["session_id"];

	$strSQL = "INSERT INTO SCORES(scenario,time_game,player_name,success,comment,score,
	EHC,
	FHC,
	ED,
	FD,
	EFC,
	FFC,
	TLP,
	TG
	) VALUES('$scenario',NOW(),'$player_name','$success','$comment','$score',
	'$EHC',
	'$FHC',
	'$ED',
	'$FD',
	'$EFC',
	'$FFC',
	'$TLP',
	'$TG'
	)";
	//echo($strSQL);	
	
	// SQL-оператор выполняется
	mysql_query($strSQL) or die (mysql_error());

	$strSQL = "UPDATE SESSIONS SET time_end_game=NOW(),player_name='".$player_name."' WHERE id = ".$session_id."";
	mysql_query($strSQL);
	echo $strSQL." <br>";
	
	//$strSQL = "UPDATE SESSIONS SET player_name='".$player_name."' WHERE id = ".$session_id."";
	//mysql_query($strSQL);
	//echo $strSQL." <br>";
	
	//-- НЕ ИЗМЕНЯТЬ! Если успех то должно вернуться слово SUCCESS
	//echo("SUCCESS ".$session_id);
	print "success=SUCCESS&session_id=$session_id";
	
	//-- теперь перезапишем топлист
	$file_name = $scenario."_toplist.txt";
	$fp = fopen($file_name, "w"); // Открываем файл в режиме записи 
	
	$strSQL = "SELECT * FROM SCORES WHERE scenario='".$scenario."' order by score desc";

	// Выполнить запрос (набор данных $rs содержит результат)
	$rs = mysql_query($strSQL);
	
	// Цикл по recordset $rs
	// Каждый ряд становится массивом ($row) с помощью функции mysql_fetch_array
	$i = 0;
	while($row = mysql_fetch_array($rs)) {
		$i = $i + 1;
		// Записать значение столбца FirstName (который является теперь массивом $row)
		$mytext = $i." ".$row['player_name'] ." ". $row['score'] . "\n";
		$test = fwrite($fp, $mytext); // Запись в файл
		//if ($test) echo 'Данные в файл успешно занесены.';
		//else echo 'Ошибка при записи в файл.';
	}
	//Закрытие файла
	fclose($fp); 
	//if ($test) echo 'Данные в файле '.$file_name.' успешно обновлены.';
	//else echo 'Ошибка при записи в файл '.$file_name;
	// Закрыть соединение с БД
	mysql_close();
?>