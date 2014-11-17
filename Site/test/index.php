<?php
//===== index.php =====
include("login.php");

if ($login_ok == 1) {
	echo "Программа работает";
} else {
	echo "Чего вам надо ?!";
};
?>