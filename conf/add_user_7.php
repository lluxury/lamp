
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

array_shift($argv);
$username = $argv[0];
$userdb = $argv[1];
echo " $username,$userdb";

$mysqli = new mysqli("localhost", "root", "lamp.sh", "mysql");
$sql = "create database {$userdb}  DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci";
$result = $mysqli->query($sql);

$sql = "create user {$username}@localhost identified by 'password'";
$result = $mysqli->query($sql);

$sql = "grant select, insert, update, delete, index, alter, create, drop on {$userdb}.* to {$username} identified by 'password'";
$result = $mysqli->query($sql);

$sql = "UPDATE user SET authentication_string=password('{$password}') WHERE user='{$username}'";
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
