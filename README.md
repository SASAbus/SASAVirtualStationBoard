SASAVirtualStationBoard
=======================

This project provides you departing from a VDV-Database a stationboard connected with realtime information from freegis.net project.

For a full functionallity you have to add a database (PDO) to read the VDV-Tables and then adding a file named config.php with the following three parameters

$dsn = 'mysql:dbname=;host=localhost';
$password = '';
$user = '';

It's not required that the database is a mysql-database.
