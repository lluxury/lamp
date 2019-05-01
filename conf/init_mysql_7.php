
<?php


// for mysql 5.7.14+
// echo "mysql_password" >> account.log
// need test install ch pw

$password = randstr(10);
echo $password;

function randstr($length) {
    return substr(md5(num_rand($length)), mt_rand(0, 32 - $length), $length);
}
function num_rand($length) {
    mt_srand((double) microtime() * 1000000);
    $randVal = mt_rand(1, 9);
    for ($i = 1; $i < $length; $i++) {
        $randVal .= mt_rand(0, 9);
    }
    return $randVal;
}

 $mysqli = new mysqli("localhost", "root", "lamp.sh", "mysql");
// $sql = "SELECT * FROM user";
$sql = "UPDATE user SET authentication_string=password('{$password}') WHERE user='yann'";
$result = $mysqli->query($sql);

$update = "flush privileges";
$result = $mysqli->query($update);

// $row = $result->fetch_assoc();      // 从结果集中取得一行作为关联数组
// echo $row["authentication_string"];
/* free result set */
// $result->free();

/* close connection */
$mysqli->close();
file_put_contents('account.log', str_replace('mysql_password', $password, file_get_contents('account.log')));

?>
