<?php

  /*

   SASAVirtualStationBoard - This project provides you departing from a 
   VDV-Database a stationboard connected with realtime information from 
   freegis.net project

   Copyright (C) 2014 Markus Windegger

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

   */

$REALTIMEURL = "http://realtime.opensasa.info";

if (! isset ( $_REQUEST ['ORT_NR'] ) || $_REQUEST ['ORT_NR'] <= 0)
  {
    echo "ORT_NR as parameter is required";
    exit ();
  }

date_default_timezone_set("Europe/Berlin");

//Loading db configs
include("config.php");

try
{
  $mysql = new PDO ( $dsn, $user, $password, array (
						    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8" 
						    ) );
} catch ( PDOException $e )
{
  if (isset ( $_REQUEST ['jsonp'] ))
    {
      echo $_REQUEST ['jsonp'] . json_encode ( 'Connection failed: ' . $e->getMessage () );
    } 
  else if (isset ( $_REQUEST ['JSONP'] ))
    {
      echo $_REQUEST ['JSONP'] . json_encode ( 'Connection failed: ' . $e->getMessage () );
    }
  else
    {
      echo json_encode ( 'Connection failed: ' . $e->getMessage () );
    }
  exit ();
}


$ortliste = getOrtliste($mysql);

$ort_nr = getOrtnr ( $mysql, $_REQUEST ['ORT_NR'] );

if(count($ort_nr) == 0)
  {
    echo "A valid ORT_NR as parameter is required";
    exit ();
  }

$linelist = getLines ( $mysql, $ort_nr["O_Id"] );

$passlist = array();

$linerequeststring = "";

foreach ( $linelist as $line )
  {
    $verlaufliste [$line ["L_Id"]] ["verlauf"] = getVerlauf ( $mysql, $line ["L_Id"] );
    $verlaufliste [$line ["L_Id"]] ["abfahrten"] = getFahrten ( $mysql, $line ["L_Id"] );
    if (count ( $verlaufliste [$line ["L_Id"]] ["abfahrten"] ) > 0)
      {
	$verlaufliste [$line ["L_Id"]] ["fahrzeiten"] = getFahrzeit ( $mysql, $verlaufliste [$line ["L_Id"]] ["verlauf"], $ort_nr["O_Id"], $line);
	foreach($verlaufliste [$line ["L_Id"]] ["abfahrten"] as $abfahrt)
	  {
	    $pass = calculatePasstime($abfahrt, $verlaufliste [$line ["L_Id"]] ["verlauf"], $verlaufliste [$line ["L_Id"]] ["fahrzeiten"], $ort_nr["O_Id"]);
			
	    $passlist[$abfahrt['START'] + $pass["start"]][$abfahrt['FRT_FID']]["abfahrt"] = $abfahrt;
	    $passlist[$abfahrt['START'] + $pass["start"]][$abfahrt['FRT_FID']]["linie"] = $line;
	    $passlist[$abfahrt['START'] + $pass["start"]][$abfahrt['FRT_FID']]["passtimes"] = $pass;
	    $passlist[$abfahrt['START'] + $pass["start"]][$abfahrt['FRT_FID']]["verlauf"] = $verlaufliste [$line ["L_Id"]] ["verlauf"];
	    
	  }		

	if($linerequeststring == "")
	  {
	    $linerequeststring = $line["LI_NR"].":".$line["STR_LI_VAR"];
	  }
	else
	  {
	    $linerequeststring .= ",".$line["LI_NR"].":".$line["STR_LI_VAR"];
	  }
      }
	
  }

$realtimearray = array();

$request_url = $REALTIMEURL."/positions?lines=".$linerequeststring;//$line["LI_NR"].":".$line["STR_LI_VAR"];

$request = new HttpRequest($request_url);
try 
{
  $request->send();
  if ($request->getResponseCode() == 200) 
    {
      if($response = json_decode($request->getResponseBody(), true))
	{
	  foreach($response["features"] as $position)
	    {
	      $realtimearray[$position["properties"]["frt_fid"]] = $position["properties"];
	    }
	}
    }
} 
catch (HttpException $ex) 
{
  echo $ex->getMessage();
}



ksort($passlist);

$anz = 1;

$jsonarray = array();
$outputstring = "";

foreach($passlist as $timedpass)
  {
    foreach($timedpass as $singlepass)
      {
	if(!isset($_REQUEST['ALL']) && isset($_REQUEST['LINES']) && $_REQUEST['LINES'] < $anz)
	  {
	    break;
	  }
	$start = $singlepass["abfahrt"]["START"] + $singlepass["passtimes"]["start"];
	$stop = $singlepass["abfahrt"]["START"] + $singlepass["passtimes"]["stop"];
	$realstart = $start;
	$realstop = $stop;
	if(isset($realtimearray[$singlepass["abfahrt"]["FRT_FID"]]))
	  {
	    $realstart += $realtimearray[$singlepass["abfahrt"]["FRT_FID"]]["delay_sec"];
	    $realstop += $realtimearray[$singlepass["abfahrt"]["FRT_FID"]]["delay_sec"];
	  }
	$acttime = time() - strtotime("today");
	if(isset($_REQUEST['type']) && ($_REQUEST['type'] == "json" || $_REQUEST['type'] == "jsonp"))
	  {
	    if(isset($_REQUEST['ALL']))
	      {
		$departureitem["stationname"] = $ort_nr["ORT_NAME"];
		$departureitem["lidname"] = $singlepass["linie"]["LIDNAME"];
		$departureitem["last_station"] = $ortliste[$singlepass["verlauf"][count($singlepass["verlauf"])]]["ORT_NAME"];
		$departureitem["arrival"] = getFormatTime($stop);
		$departureitem["departure"] = getFormatTime($start);

		if(isset($realtimearray[$singlepass["abfahrt"]["FRT_FID"]]))
		  {
		    $departureitem["delay"] = floor($realtimearray[$singlepass["abfahrt"]["FRT_FID"]]["delay_sec"] / 60);
		  }
		else
		  {
		    $departureitem["delay"] = null;
		  }
		$jsonarray[] = $departureitem;
	      }
	    else
	      {
		if($realstart >= $acttime || $realstop >= $acttime)
		  {

		    $departureitem["stationname"] = $ort_nr["ORT_NAME"];
		    $departureitem["lidname"] = $singlepass["linie"]["LIDNAME"];
		    $departureitem["last_station"] = $ortliste[$singlepass["verlauf"][count($singlepass["verlauf"])]]["ORT_NAME"];
		    $departureitem["arrival"] = getFormatTime($stop);
		    $departureitem["departure"] = getFormatTime($start);

		    if(isset($realtimearray[$singlepass["abfahrt"]["FRT_FID"]]))
		      {
			$departureitem["delay"] = floor($realtimearray[$singlepass["abfahrt"]["FRT_FID"]]["delay_sec"] / 60);
		      }
		    else
		      {
			$departureitem["delay"] = null;
		      }
		    $jsonarray[] = $departureitem;
		    ++$anz;
		  }
	      }
		
	  }
	else
	  {
	    if(isset($_REQUEST['ALL']))
	      {
		
		$outputstring .= $ort_nr["ORT_NAME"].";".$singlepass["linie"]["LIDNAME"].";".getFormatTime($stop).";".getFormatTime($start).";".$ortliste[$singlepass["verlauf"][count($singlepass["verlauf"])]]["ORT_NAME"].";";
		if(isset($realtimearray[$singlepass["abfahrt"]["FRT_FID"]]))
		  {
		    $outputstring .= floor($realtimearray[$singlepass["abfahrt"]["FRT_FID"]]["delay_sec"] / 60).";";
		  }
		else
		  {
		    $outputstring .= ";";
		  }
		$outputstring .= "\n";
	      }
	    else
	      {
		if($realstart >= $acttime || $realstop >= $acttime)
		  {
		    $outputstring .= $ort_nr["ORT_NAME"].";".$singlepass["linie"]["LIDNAME"].";".getFormatTime($stop).";".getFormatTime($start).";".$ortliste[$singlepass["verlauf"][count($singlepass["verlauf"])]]["ORT_NAME"].";";
		    if(isset($realtimearray[$singlepass["abfahrt"]["FRT_FID"]]))
		      {
			$outputstring .= floor($realtimearray[$singlepass["abfahrt"]["FRT_FID"]]["delay_sec"] / 60).";";
		      }
		    else
		      {
			$outputstring .= ";";
		      }
		    $outputstring .= "\n";
		    ++$anz;
		  }
	      }
	  }
      }
  }

//ob_clean();
if(isset($_REQUEST['type']) && $_REQUEST['type'] == "json")
  {
    header("Content-type: application/json; charset=utf-8");
    echo json_encode($jsonarray);
  }
elseif(isset($_REQUEST['type']) && $_REQUEST['type'] == "jsonp")
  {
    if(isset($_REQUEST['jsonp']))
      {
	header("Content-type: text/javascript; charset=utf-8");	
	echo $_REQUEST['jsonp']."(".json_encode($jsonarray).")";
      }
    else if(isset($_REQUEST['JSONP']))
      {
	header("Content-type: text/javascript; charset=utf-8");	
	echo $_REQUEST['JSONP']."(".json_encode($jsonarray).")";
      }
    else
      {
	header("Content-type: application/json; charset=utf-8");	
	echo json_encode($jsonarray);
      }
  }
else
  {
    header("Content-type: text/plain; charset=utf-8");	
    echo $outputstring;
  }

exit;


function getOrtliste($mysql)
{
  $query = "Select * from Ort where V_Id = :version";
	
  if (! ($mysqlresult = $mysql->prepare ( $query )))
    {
      echo "Failure " . var_dump ( $mysql->errorInfo () ) . ")";
      exit ();
    }
	
  $mysqlresult->bindValue ( ":version", getVersion ( $mysql ) );
	
  if (! ($mysqlresult->execute ()))
    {
      echo "Failure " . var_dump ( $mysqlresult->errorInfo () ) . ")";
      exit ();
    }
	
  $ortliste = array();
	
  while ($erg = $mysqlresult->fetch ())
    {
      $ortliste[$erg ['O_Id']]["O_Id"] = $erg ['O_Id'];
      $ortliste[$erg ['O_Id']]["ORT_NR"] = $erg ['ORT_NR'];
      $ortliste[$erg ['O_Id']]["ORT_NAME"] = $erg ['ORT_NAME'];
      $ortliste[$erg ['O_Id']]["ORT_POS_LAENGE"] = $erg ['ORT_POS_LAENGE'];
      $ortliste[$erg ['O_Id']]["ORT_POS_BREITE"] = $erg ['ORT_POS_BREITE'];
    }
  return $ortliste;
}


function getFormatTime($timeinseconds)
{
  $hour = (int)($timeinseconds / 3600);
  $minutes = (($timeinseconds % 3600) / 60);
  if($minutes < 10)
    {
      $minutes = "0".$minutes;
    }
  return $hour.":".$minutes;
}


function calculatePasstime($abfahrt, $verlauf, $fahrzeiten, $ortnr)
{

  $ankunft = 0;
  $start = 0;
  $i = 1;

  while($verlauf[$i] != $ortnr)
    {
      $pass = $verlauf[$i];
      if(!isset($fahrzeiten [$pass] ["ausnahme_fahrt"] [$abfahrt['F_Id']]))
	{
	  $ankunft += $fahrzeiten [$pass] ["fahrzeit"][$abfahrt['FG_Id']];
	}
      else
	{
	  $ankunft += $fahrzeiten [$pass] ["ausnahme_fahrt"] [$abfahrt['F_Id']];
	}
      if(isset($fahrzeiten [$pass] ["haltezeit"] [$abfahrt['F_Id']]))
	{
	  $ankunft += $fahrzeiten [$pass] ["haltezeit"] [$abfahrt['F_Id']];
	}
      elseif(isset($fahrzeiten [$pass] ["linienhaltezeit"] [$abfahrt['FG_Id']] ))
	{
	  $ankunft += $fahrzeiten [$pass] ["linienhaltezeit"] [$abfahrt ['FG_Id']];
	}
      elseif(isset($fahrzeit [$pass] ["orthaltezeit"] [$abfahrt ['FG_Id']] ))
	{
	  $ankunft += $fahrzeiten [$pass] ["orthaltezeit"] [$abfahrt ['FG_Id']];
	}
      ++$i;
    }
  $pass = $verlauf[$i];
  $start = $ankunft;
  if($ankunft != 0 && $i != count($verlauf))
    {
      if(isset($fahrzeiten [$pass] ["haltezeit"] [$abfahrt['F_Id']]))
	{
	  $start += $fahrzeiten [$pass] ["haltezeit"] [$abfahrt['F_Id']];
	}
      elseif(isset($fahrzeiten [$pass] ["linienhaltezeit"] [$abfahrt['FG_Id']] ))
	{
	  $start += $fahrzeiten [$pass] ["linienhaltezeit"] [$abfahrt ['FG_Id']];
	}
      elseif(isset($fahrzeiten [$pass] ["orthaltezeit"] [$abfahrt ['FG_Id']] ))
	{
	  $start += $fahrzeiten [$pass] ["orthaltezeit"] [$abfahrt ['FG_Id']];
	}
    }
  $passtime["stop"] = $ankunft;
  $passtime["start"] = $start;
  return $passtime;
}


function getFahrten($mysql, $line)
{
  $verlaufquery = "Select * from Fahrt f, Kalender k where f.T_Id = k.T_Id AND k.DATUM = CURDATE() AND f.L_Id = :line order by START";
	
  if (! ($mysqlresult = $mysql->prepare ( $verlaufquery )))
    {
      echo "Failure " . var_dump ( $mysql->errorInfo () ) . ")";
      exit ();
    }
	
  $mysqlresult->bindValue ( ":line", $line );
	
  if (! ($mysqlresult->execute ()))
    {
      echo "Failure " . var_dump ( $mysqlresult->errorInfo () ) . ")";
      exit ();
    }
	
  $fahrtenarray = array ();
	
  while ( $erg = $mysqlresult->fetch () )
    {
      $fahrtenarray [$erg ['F_Id']] ["F_Id"] = $erg ['F_Id'];
      $fahrtenarray [$erg ['F_Id']] ["START"] = $erg ['START'];
      $fahrtenarray [$erg ['F_Id']] ["FG_Id"] = $erg ['FG_Id'];
      $fahrtenarray [$erg ['F_Id']] ["FRT_FID"] = $erg ['FRT_FID'];
    }
	
  return $fahrtenarray;
}

/**
 *
 * @param unknown $mysql        	
 * @param unknown $verlauf        	
 * @param unknown $ortnr        	
 */
function getFahrzeit($mysql, $verlauf, $ortnr, $linie)
{
  $fahrzeit = array ();
  $weiter = true;
  for($i = 1; $i <= count ( $verlauf ) && $weiter; ++ $i)
    {
      /*
       * ******************************** Fahrzeit **************
       */
      if ($i < count ( $verlauf ))
	{
	  $fahrzeitquery = "Select * from Fahrzeit where START = :start AND ZIEL = :ziel";
	  if (! ($mysqlresult = $mysql->prepare ( $fahrzeitquery )))
	    {
	      echo "Failure " . var_dump ( $mysql->errorInfo () ) . ")";
	      exit ();
	    }
			
	  $mysqlresult->bindValue ( ":start", $verlauf [$i] );
	  $mysqlresult->bindValue ( ":ziel", $verlauf [$i + 1] );
			
	  if (! ($mysqlresult->execute ()))
	    {
	      echo "Failure " . var_dump ( $mysqlresult->errorInfo () ) . ")";
	      exit ();
	    }
			
	  while ( $erg = $mysqlresult->fetch () )
	    {
	      $fahrzeit [$verlauf [$i]] ["fahrzeit"] [$erg ['FG_Id']] = $erg ['SEL_FZT'];
	    }
	}
      /*
       * ********************************************************************************* Fahrzeit Ausnahme (Fahrtbezogen) *********************************************************************************
       */
      $fahrzeitquery = "Select * from Fahrzeit_Ausnahme where O_Id = :start";
      if (! ($mysqlresult = $mysql->prepare ( $fahrzeitquery )))
	{
	  echo "Failure " . var_dump ( $mysql->errorInfo () ) . ")";
	  exit ();
	}
		
      $mysqlresult->bindValue ( ":start", $verlauf [$i] );
		
      if (! ($mysqlresult->execute ()))
	{
	  echo "Failure " . var_dump ( $mysqlresult->errorInfo () ) . ")";
	  exit ();
	}
		
      while ( $erg = $mysqlresult->fetch () )
	{
	  $fahrzeit [$verlauf [$i]] ["ausnahme_fahrt"] [$erg ['F_Id']] = $erg ['FRT_FZT_ZEIT'];
	}
		
      /*
       * ********************************************************************************* Haltezeit an Haltestellen fahrtbezogen *********************************************************************************
       */
      $fahrzeitquery = "Select * from Haltezeit where O_Id = :start";
      if (! ($mysqlresult = $mysql->prepare ( $fahrzeitquery )))
	{
	  echo "Failure " . var_dump ( $mysql->errorInfo () ) . ")";
	  exit ();
	}
		
      $mysqlresult->bindValue ( ":start", $verlauf [$i] );
		
      if (! ($mysqlresult->execute ()))
	{
	  echo "Failure " . var_dump ( $mysqlresult->errorInfo () ) . ")";
	  exit ();
	}
		
      while ( $erg = $mysqlresult->fetch () )
	{
	  $fahrzeit [$verlauf [$i]] ["haltezeit"] [$erg ['F_Id']] = $erg ['FRT_HZT_ZEIT'];
	}
		
      /*
       * ********************************************************************************* Haltezeit an Haltestellen fahrzeitengruppen bezogen *********************************************************************************
       */
      $fahrzeitquery = "Select lh.FG_Id as FG_Id, lh.LIVAR_HZT_ZEIT as LIVAR_HZT_ZEIT from LinienHaltezeit lh, Verlauf v where O_Id = :start AND lh.VR_Id = v.VR_Id AND v.L_Id = :linie";
      if (! ($mysqlresult = $mysql->prepare ( $fahrzeitquery )))
	{
	  echo "Failure " . var_dump ( $mysql->errorInfo () ) . ")";
	  exit ();
	}
		
      $mysqlresult->bindValue ( ":start", $verlauf [$i] );
      $mysqlresult->bindValue ( ":linie", $linie["L_Id"] );
		
      if (! ($mysqlresult->execute ()))
	{
	  echo "Failure " . var_dump ( $mysqlresult->errorInfo () ) . ")";
	  exit ();
	}
		
      while ( $erg = $mysqlresult->fetch () )
	{
	  $fahrzeit [$verlauf [$i]] ["linienhaltezeit"] [$erg ['FG_Id']] = $erg ['LIVAR_HZT_ZEIT'];
	}
		
      /*
       * ********************************************************************************* Haltezeit an Haltestellen haltestellenbezogen *********************************************************************************
       */
      $fahrzeitquery = "Select * from OrtHaltezeit where O_Id = :start";
      if (! ($mysqlresult = $mysql->prepare ( $fahrzeitquery )))
	{
	  echo "Failure " . var_dump ( $mysql->errorInfo () ) . ")";
	  exit ();
	}
		
      $mysqlresult->bindValue ( ":start", $verlauf [$i] );
		
      if (! ($mysqlresult->execute ()))
	{
	  echo "Failure " . var_dump ( $mysqlresult->errorInfo () ) . ")";
	  exit ();
	}
		
      while ( $erg = $mysqlresult->fetch () )
	{
	  $fahrzeit [$verlauf [$i]] ["orthaltezeit"] [$erg ['FG_Id']] = $erg ['HP_HZT'];
	}
		
      if ($ortnr == $verlauf [$i])
	{
	  $weiter = false;
	}
    }
  return $fahrzeit;
}

/**
 *
 * @param unknown $mysql        	
 * @param unknown $line        	
 * @return multitype:unknown
 */
function getVerlauf($mysql, $line)
{
  $verlaufquery = "Select * from Verlauf where L_Id = :line order by LI_LFD_NR";
	
  if (! ($mysqlresult = $mysql->prepare ( $verlaufquery )))
    {
      echo "Failure " . var_dump ( $mysql->errorInfo () ) . ")";
      exit ();
    }
	
  $mysqlresult->bindValue ( ":line", $line );
	
  if (! ($mysqlresult->execute ()))
    {
      echo "Failure " . var_dump ( $mysqlresult->errorInfo () ) . ")";
      exit ();
    }
	
  $verlaufarray = array ();
	
  while ( $erg = $mysqlresult->fetch () )
    {
      $verlaufarray [$erg ['LI_LFD_NR']] = $erg ['O_Id'];
    }
	
  return $verlaufarray;
}

/**
 * This function provides the Version of the actual time table
 *
 * @param PDO $mysql        	
 * @return int version the versionnumber of the actual time table
 */
function getVersion($mysql)
{
  $versionquery = "Select * from Version where VALID_FROM <= CURDATE() ORDER BY V_Id DESC LIMIT 1";
	
  if (! ($mysqlresult = $mysql->query ( $versionquery )))
    {
      echo "Failure getting the Versionnumber";
      exit ();
    }
	
  $erg = $mysqlresult->fetch ();
	
  $version = $erg ['V_Id'];
	
  $mysqlresult->closeCursor ();
  return $version;
}






function getOrtnr($mysql, $ortnr)
{
  $query = "Select * from Ort where ORT_NR = :ortnr AND V_Id = :version";
	
  if (! ($mysqlresult = $mysql->prepare ( $query )))
    {
      echo "Failure " . var_dump ( $mysql->errorInfo () ) . ")";
      exit ();
    }
	
  $mysqlresult->bindValue ( ":ortnr", $ortnr );
  $mysqlresult->bindValue ( ":version", getVersion ( $mysql ) );
	
  if (! ($mysqlresult->execute ()))
    {
      echo "Failure " . var_dump ( $mysqlresult->errorInfo () ) . ")";
      exit ();
    }
	
  $ortnr = array();
	
  if ($erg = $mysqlresult->fetch ())
    {
      $ortnr["O_Id"] = $erg ['O_Id'];
      $ortnr["ORT_NR"] = $erg ['ORT_NR'];
      $ortnr["ORT_NAME"] = $erg ['ORT_NAME'];
      $ortnr["ORT_POS_LAENGE"] = $erg ['ORT_POS_LAENGE'];
      $ortnr["ORT_POS_BREITE"] = $erg ['ORT_POS_BREITE'];

    }
  return $ortnr;
}

/**
 *
 * @param unknown $mysql        	
 * @param unknown $ortnr        	
 * @return multitype:unknown
 */
function getLines($mysql, $ortnr)
{
  $query = "Select * from Verlauf v, Linie l where v.L_Id = l.L_Id AND O_Id = :ortnr";
	
  if (! ($mysqlresult = $mysql->prepare ( $query )))
    {
      echo "Failure " . var_dump ( $mysql->errorInfo () ) . ")";
      exit ();
    }
	
  $mysqlresult->bindValue ( ":ortnr", $ortnr );
	
  if (! ($mysqlresult->execute ()))
    {
      echo "Failure " . var_dump ( $mysqlresult->errorInfo () ) . ")";
      exit ();
    }
	
  $linienarray = array ();
	
  while ( $erg = $mysqlresult->fetch () )
    {
      $linie ["L_Id"] = $erg ['L_Id'];
      $linie ["LI_NR"] = $erg ['LI_NR'];
      $linie ["STR_LI_VAR"] = $erg ['STR_LI_VAR'];
      $linie ["LIDNAME"] = $erg ['LIDNAME'];
      $linienarray [] = $linie;
    }
  return $linienarray;
}

exit ();

?>