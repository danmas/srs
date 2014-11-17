
<?php
//===== login.php =====

echo('scenario:');
echo('scenario:');
echo($_GET["scenario"]);
echo('<br>name:');
echo($_GET["name"]);
echo('<br>score:');
echo($_GET["score"]);

$fp = fopen("score_".$_GET["scenario"].".txt", "a"); // Открываем файл в режиме записи 
$mytext = $_GET["name"].",".$_GET["score"]."\n"; // Исходная строка
$test = fwrite($fp, $mytext); // Запись в файл
if ($test) echo 'Данные в файл успешно занесены.';
else echo 'Ошибка при записи в файл.';
fclose($fp); //Закрытие файла
$login_ok = 1;
?>