SASAVirtualStationBoard
=======================

1) General informations
2) License
3) How to install
4) Databasestructure
5) Contributors



1) General informations
-----------------------

This project provides you departing from a VDV-Database a stationboard connected with realtime information from freegis.net project. In this project, the instance is running the data from SASA SpA-AG, a Southtyrolean Public Transport Operator, which has [released it's data](http://www.sasabus.org/opendata) unter the [CC-3.0-BY-SA license](http://creativecommons.org/licenses/by-sa/3.0/). This project provides you a webservice, which gives you the possibility to build upon virtual station boards, with all departures in realtime (if you connect it to a realtime service).
For this project, a test-develop server is running under [devel.stationboard.opensasa.info](http://devel.stationboard.opensasa.info) and the official API server is running under [stationboard.opensasa.info](http://stationboard.opensasa.info).

2) License
----------

The license for all the code, databasestructure, etc is under the GPL V3 license, which is available under the folder license or [on the GNU's Website](http://www.gnu.org/copyleft/gpl.html).

3) How to install
-----------------

To run this project on your machine its necessary that you have installed some kind of webserver (like apache2) with php. You should have access to a database with the structure from the project (or you install directly mysql on your machine). the php mysql connector should be installed, the pdo driver should be made available/ should be installed by following the [instructions given on the PHP website](http://it1.php.net/manual/en/book.pdo.php).
Then you have to add a database (PDO) to read the VDV-Tables configuring the connection parameters in a file named config.php with the following three parameters (or simply rename the config.php.example file and fill the blanks).

$dsn = 'mysql:dbname=;host=localhost';

$password = '';

$user = '';

It's not required that the database is a mysql-database.

4) Databasestructure
--------------------

The databasestructure from this project is strongly connected with the [VDV-Format](http://mitglieder.vdv.de/module/layout_upload/452_sesv14.pdf), which is a format for exchanging data from PT-provider to PT-provider. The names are mostly connected to the table and field names from the project.

5) Contributors
---------------

The contributors of this project are members from [the SASAbus Community Team](http://sasabus.org/community), some for implementing, some for testing and improving it. Every one who contributed should add his name in this list:

- Tobias Bernard (Testing and improvements)
- Julian Sparber (Testing and improvements)
- Markus Windegger (Developer)