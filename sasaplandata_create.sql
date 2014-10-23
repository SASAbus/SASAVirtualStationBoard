-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: SASAplandata
-- ------------------------------------------------------
-- Server version	5.1.73

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Fahrt`
--

DROP TABLE IF EXISTS `Fahrt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Fahrt` (
  `F_Id` int(11) NOT NULL AUTO_INCREMENT,
  `FRT_FID` bigint(20) NOT NULL,
  `L_Id` int(11) NOT NULL,
  `FG_Id` int(11) NOT NULL,
  `START` int(11) NOT NULL,
  `T_Id` int(11) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`F_Id`),
  KEY `fk_Fahrt_1_idx` (`L_Id`),
  KEY `fk_Fahrt_2_idx` (`FG_Id`),
  KEY `fk_Fahrt_3_idx` (`T_Id`),
  KEY `fk_Fahrt_4_idx` (`V_Id`),
  KEY `index6` (`FRT_FID`),
  KEY `index7` (`START`),
  CONSTRAINT `fk_Fahrt_1` FOREIGN KEY (`L_Id`) REFERENCES `Linie` (`L_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Fahrt_2` FOREIGN KEY (`FG_Id`) REFERENCES `Fahrzeitengruppe` (`FG_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Fahrt_3` FOREIGN KEY (`T_Id`) REFERENCES `Tagesart` (`T_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Fahrt_4` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=577190 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Fahrzeit`
--

DROP TABLE IF EXISTS `Fahrzeit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Fahrzeit` (
  `FZ_Id` int(11) NOT NULL AUTO_INCREMENT,
  `START` int(11) NOT NULL,
  `ZIEL` int(11) NOT NULL,
  `SEL_FZT` int(11) NOT NULL,
  `FG_Id` int(11) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`FZ_Id`),
  KEY `fk_Fahrzeit_1_idx` (`START`),
  KEY `fk_Fahrzeit_2_idx` (`ZIEL`),
  KEY `fk_Fahrzeit_3_idx` (`FG_Id`),
  KEY `fk_Fahrzeit_4_idx` (`V_Id`),
  CONSTRAINT `fk_Fahrzeit_1` FOREIGN KEY (`START`) REFERENCES `Ort` (`O_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Fahrzeit_2` FOREIGN KEY (`ZIEL`) REFERENCES `Ort` (`O_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Fahrzeit_3` FOREIGN KEY (`FG_Id`) REFERENCES `Fahrzeitengruppe` (`FG_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Fahrzeit_4` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=88329 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Fahrzeit_Ausnahme`
--

DROP TABLE IF EXISTS `Fahrzeit_Ausnahme`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Fahrzeit_Ausnahme` (
  `H_Id` int(11) NOT NULL AUTO_INCREMENT,
  `F_Id` int(11) NOT NULL,
  `O_Id` int(11) NOT NULL,
  `FRT_FZT_ZEIT` int(11) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`H_Id`),
  KEY `fk_Fahrzeit_Ausnahme_1_idx` (`F_Id`),
  KEY `fk_Fahrzeit_Ausnahme_2_idx` (`O_Id`),
  KEY `fk_Fahrzeit_Ausnahme_3_idx` (`V_Id`),
  CONSTRAINT `fk_Fahrzeit_Ausnahme_1` FOREIGN KEY (`F_Id`) REFERENCES `Fahrt` (`F_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Fahrzeit_Ausnahme_2` FOREIGN KEY (`O_Id`) REFERENCES `Ort` (`O_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Fahrzeit_Ausnahme_3` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=565 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Fahrzeitengruppe`
--

DROP TABLE IF EXISTS `Fahrzeitengruppe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Fahrzeitengruppe` (
  `FG_Id` int(11) NOT NULL AUTO_INCREMENT,
  `FGR_NR` int(11) NOT NULL,
  `FGR_TEXT` varchar(512) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`FG_Id`),
  KEY `fk_Fahrzeitengruppe_1_idx` (`V_Id`),
  CONSTRAINT `fk_Fahrzeitengruppe_1` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Haltezeit`
--

DROP TABLE IF EXISTS `Haltezeit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Haltezeit` (
  `H_Id` int(11) NOT NULL AUTO_INCREMENT,
  `F_Id` int(11) NOT NULL,
  `O_Id` int(11) NOT NULL,
  `FRT_HZT_ZEIT` int(11) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`H_Id`),
  KEY `fk_Haltezeit_1_idx` (`F_Id`),
  KEY `fk_Haltezeit_2_idx` (`O_Id`),
  KEY `fk_Haltezeit_3_idx` (`V_Id`),
  CONSTRAINT `fk_Haltezeit_1` FOREIGN KEY (`F_Id`) REFERENCES `Fahrt` (`F_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Haltezeit_2` FOREIGN KEY (`O_Id`) REFERENCES `Ort` (`O_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Haltezeit_3` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1949 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Kalender`
--

DROP TABLE IF EXISTS `Kalender`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Kalender` (
  `K_Id` int(11) NOT NULL AUTO_INCREMENT,
  `DATUM` date NOT NULL,
  `T_Id` int(11) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`K_Id`),
  KEY `fk_Kalender_1_idx` (`T_Id`),
  KEY `fk_Kalender_2_idx` (`V_Id`),
  CONSTRAINT `fk_Kalender_1` FOREIGN KEY (`T_Id`) REFERENCES `Tagesart` (`T_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Kalender_2` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2618 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Linie`
--

DROP TABLE IF EXISTS `Linie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Linie` (
  `L_Id` int(11) NOT NULL AUTO_INCREMENT,
  `LI_NR` bigint(20) NOT NULL COMMENT '	',
  `STR_LI_VAR` int(11) NOT NULL,
  `LI_RI_NR` int(11) NOT NULL,
  `LI_KUERZEL` varchar(512) NOT NULL,
  `LIDNAME` varchar(512) NOT NULL DEFAULT '""',
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`L_Id`),
  KEY `fk_Linie_1_idx` (`V_Id`),
  KEY `index3` (`LI_NR`),
  KEY `index4` (`STR_LI_VAR`),
  KEY `index5` (`LI_RI_NR`),
  CONSTRAINT `fk_Linie_1` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7683 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `LinienHaltezeit`
--

DROP TABLE IF EXISTS `LinienHaltezeit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LinienHaltezeit` (
  `LH_Id` int(11) NOT NULL AUTO_INCREMENT,
  `VR_Id` int(11) NOT NULL,
  `FG_Id` int(11) NOT NULL,
  `LIVAR_HZT_ZEIT` int(11) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`LH_Id`),
  KEY `index2` (`LIVAR_HZT_ZEIT`),
  KEY `fk_LinienHaltezeit_1_idx` (`FG_Id`),
  KEY `fk_LinienHaltezeit_2_idx` (`VR_Id`),
  KEY `fk_LinienHaltezeit_3_idx` (`V_Id`),
  CONSTRAINT `fk_LinienHaltezeit_1` FOREIGN KEY (`FG_Id`) REFERENCES `Fahrzeitengruppe` (`FG_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_LinienHaltezeit_2` FOREIGN KEY (`VR_Id`) REFERENCES `Verlauf` (`VR_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_LinienHaltezeit_3` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=397 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Ort`
--

DROP TABLE IF EXISTS `Ort`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Ort` (
  `O_Id` int(11) NOT NULL AUTO_INCREMENT,
  `ORT_NR` int(11) NOT NULL,
  `ORT_NAME` varchar(512) NOT NULL,
  `ORT_REF_ORT_NAME` varchar(512) NOT NULL,
  `ORT_POS_LAENGE` double NOT NULL,
  `ORT_POS_BREITE` double NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`O_Id`),
  KEY `fk_ort_1_idx` (`V_Id`),
  KEY `index3` (`ORT_NR`),
  CONSTRAINT `fk_ort_1` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28296 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `OrtHaltezeit`
--

DROP TABLE IF EXISTS `OrtHaltezeit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `OrtHaltezeit` (
  `OH_Id` int(11) NOT NULL AUTO_INCREMENT,
  `FG_Id` int(11) NOT NULL,
  `O_Id` int(11) NOT NULL,
  `HP_HZT` int(11) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`OH_Id`),
  KEY `index2` (`FG_Id`),
  KEY `index3` (`O_Id`),
  KEY `fk_OrtHaltezeit_1_idx` (`V_Id`),
  CONSTRAINT `fk_OrtHaltezeit_1` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_OrtHaltezeit_2` FOREIGN KEY (`O_Id`) REFERENCES `Ort` (`O_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_OrtHaltezeit_3` FOREIGN KEY (`FG_Id`) REFERENCES `Fahrzeitengruppe` (`FG_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=136 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `REC_FRT_TMP`
--

DROP TABLE IF EXISTS `REC_FRT_TMP`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `REC_FRT_TMP` (
  `FRT_FID` bigint(20) NOT NULL,
  `FRT_START` bigint(20) NOT NULL,
  `T_Id` int(11) NOT NULL,
  `TL_Id` int(11) NOT NULL,
  `UM_UID` int(11) NOT NULL,
  `LI_KU_NR` int(11) NOT NULL,
  PRIMARY KEY (`FRT_FID`),
  KEY `index1` (`TL_Id`),
  KEY `index3` (`FRT_START`),
  KEY `index4` (`T_Id`),
  CONSTRAINT `fk_REC_FRT_TMP_1` FOREIGN KEY (`TL_Id`) REFERENCES `REC_LID_TMP` (`TL_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_REC_FRT_TMP_2` FOREIGN KEY (`T_Id`) REFERENCES `Tagesart` (`T_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `REC_LID_TMP`
--

DROP TABLE IF EXISTS `REC_LID_TMP`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `REC_LID_TMP` (
  `TL_Id` int(11) NOT NULL AUTO_INCREMENT,
  `LI_NR` bigint(20) NOT NULL,
  `STR_LI_VAR` int(11) NOT NULL,
  `LI_RI_NR` int(11) NOT NULL,
  PRIMARY KEY (`TL_Id`),
  KEY `index2` (`LI_NR`),
  KEY `index3` (`STR_LI_VAR`),
  KEY `index4` (`LI_RI_NR`)
) ENGINE=InnoDB AUTO_INCREMENT=1044 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TEQ_Codes`
--

DROP TABLE IF EXISTS `TEQ_Codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TEQ_Codes` (
  `TC_Id` int(11) NOT NULL AUTO_INCREMENT,
  `F_Id` int(11) NOT NULL,
  `LI_KU_NR` int(11) NOT NULL,
  `TEQ_NUMMER` bigint(20) NOT NULL,
  `UM_Id` int(11) DEFAULT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`TC_Id`),
  KEY `fk_TEQ_Codes_1_idx` (`F_Id`),
  KEY `fk_TEQ_Codes_2_idx` (`V_Id`),
  KEY `index4` (`TEQ_NUMMER`),
  KEY `index5` (`UM_Id`),
  CONSTRAINT `fk_TEQ_Codes_1` FOREIGN KEY (`F_Id`) REFERENCES `Fahrt` (`F_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_TEQ_Codes_2` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_TEQ_Codes_3` FOREIGN KEY (`UM_Id`) REFERENCES `Umlauf` (`UM_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=292566 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Tagesart`
--

DROP TABLE IF EXISTS `Tagesart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Tagesart` (
  `T_Id` int(11) NOT NULL AUTO_INCREMENT,
  `TAGESART_NUMMER` int(11) NOT NULL,
  `TAGESART_TEXT` varchar(512) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`T_Id`),
  KEY `fk_Tagesart_1_idx` (`V_Id`),
  CONSTRAINT `fk_Tagesart_1` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=297 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Umlauf`
--

DROP TABLE IF EXISTS `Umlauf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Umlauf` (
  `UM_Id` int(11) NOT NULL AUTO_INCREMENT,
  `UM_UID` int(11) NOT NULL,
  `T_Id` int(11) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`UM_Id`),
  KEY `fk_Umlauf_1_idx` (`V_Id`),
  KEY `fk_Umlauf_2_idx` (`T_Id`),
  CONSTRAINT `fk_Umlauf_1` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_Umlauf_2` FOREIGN KEY (`T_Id`) REFERENCES `Tagesart` (`T_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8808 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Verlauf`
--

DROP TABLE IF EXISTS `Verlauf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Verlauf` (
  `VR_Id` int(11) NOT NULL AUTO_INCREMENT,
  `L_Id` int(11) NOT NULL,
  `LI_LFD_NR` int(11) NOT NULL,
  `O_Id` int(11) NOT NULL,
  `V_Id` int(11) NOT NULL,
  PRIMARY KEY (`VR_Id`),
  KEY `fk_verlauf_1_idx` (`L_Id`),
  KEY `fk_verlauf_2_idx` (`O_Id`),
  KEY `fk_Verlauf_3_idx` (`V_Id`),
  KEY `index5` (`LI_LFD_NR`),
  CONSTRAINT `fk_verlauf_1` FOREIGN KEY (`L_Id`) REFERENCES `Linie` (`L_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_verlauf_2` FOREIGN KEY (`O_Id`) REFERENCES `Ort` (`O_Id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_verlauf_3` FOREIGN KEY (`V_Id`) REFERENCES `Version` (`V_Id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=175888 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Version`
--

DROP TABLE IF EXISTS `Version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Version` (
  `V_Id` int(11) NOT NULL AUTO_INCREMENT,
  `V_NAME` varchar(512) NOT NULL,
  `CREATETIME` datetime NOT NULL,
  `VALID_FROM` date NOT NULL,
  PRIMARY KEY (`V_Id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-10-23  9:20:21
