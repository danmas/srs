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
	
/*	
echo('scenario:');
echo($scenario);
echo('<br>');

echo('time_game:');
echo($time_game);
echo('<br>');

echo('player_name:');
echo($player_name);
echo('<br>');
echo('score:');
echo($score);
echo('<br>');
*/	

/*
EHC
FHC
ED
FD
EFC
FFC
TLP
TG
*/

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
echo($strSQL);	
	
	// SQL-оператор выполняется
	mysql_query($strSQL) or die (mysql_error());
	//mysql_close();
	
	//-- НЕ ИЗМЕНЯТЬ! Если успех то должно вернуться слово SUCCESS
	echo("SUCCESS");
	
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
	echo "SUCCESS";
?>