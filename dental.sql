/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.2-MariaDB, for osx10.20 (arm64)
--
-- Host: localhost    Database: dental
-- ------------------------------------------------------
-- Server version	11.8.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `activity_log`
--

DROP TABLE IF EXISTS `activity_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `log_name` varchar(255) DEFAULT NULL,
  `description` text NOT NULL,
  `subject_type` varchar(255) DEFAULT NULL,
  `subject_id` bigint(20) unsigned DEFAULT NULL,
  `event` varchar(255) DEFAULT NULL,
  `causer_type` varchar(255) DEFAULT NULL,
  `causer_id` bigint(20) unsigned DEFAULT NULL,
  `attribute_changes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attribute_changes`)),
  `properties` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`properties`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subject` (`subject_type`,`subject_id`),
  KEY `causer` (`causer_type`,`causer_id`),
  KEY `activity_log_log_name_index` (`log_name`)
) ENGINE=InnoDB AUTO_INCREMENT=349 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_log`
--

LOCK TABLES `activity_log` WRITE;
/*!40000 ALTER TABLE `activity_log` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `activity_log` VALUES
(1,'dental_chart_entries','created','App\\Models\\DentalChartEntry',13,'created','App\\Models\\User',1,'[]','[]','2026-08-05 06:28:41','2026-08-05 06:28:41'),
(2,'default','chart.updated','App\\Models\\DentalChartEntry',13,NULL,'App\\Models\\User',1,'[]','[]','2026-08-05 06:28:41','2026-08-05 06:28:41'),
(3,'dental_chart_entries','created','App\\Models\\DentalChartEntry',14,'created','App\\Models\\User',2,'[]','[]','2026-08-05 06:45:53','2026-08-05 06:45:53'),
(4,'default','chart.updated','App\\Models\\DentalChartEntry',14,NULL,'App\\Models\\User',2,'[]','[]','2026-08-05 06:45:53','2026-08-05 06:45:53'),
(5,'dental_chart_entries','created','App\\Models\\DentalChartEntry',15,'created','App\\Models\\User',2,'[]','[]','2026-08-05 06:45:55','2026-08-05 06:45:55'),
(6,'default','chart.updated','App\\Models\\DentalChartEntry',15,NULL,'App\\Models\\User',2,'[]','[]','2026-08-05 06:45:55','2026-08-05 06:45:55'),
(7,'dental_chart_entries','created','App\\Models\\DentalChartEntry',16,'created','App\\Models\\User',2,'[]','[]','2026-08-05 06:45:58','2026-08-05 06:45:58'),
(8,'default','chart.updated','App\\Models\\DentalChartEntry',16,NULL,'App\\Models\\User',2,'[]','[]','2026-08-05 06:45:58','2026-08-05 06:45:58'),
(9,'default','patient.registered','App\\Models\\Patient',7,NULL,'App\\Models\\User',1,'[]','[]','2026-08-05 06:55:07','2026-08-05 06:55:07'),
(10,'default','medical_history.saved','App\\Models\\MedicalHistory',6,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-05 06:55:26','2026-08-05 06:55:26'),
(11,'consents','created','App\\Models\\ConsentForm',3,'created','App\\Models\\User',1,'[]','[]','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(12,'default','consent.created','App\\Models\\ConsentForm',3,NULL,'App\\Models\\User',1,'[]','[]','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(13,'default','consent.sections_initialed','App\\Models\\ConsentForm',3,NULL,'App\\Models\\User',1,'[]','[]','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(14,'default','patient.registered','App\\Models\\Patient',8,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:38:22','2026-08-06 09:38:22'),
(15,'default','medical_history.saved','App\\Models\\MedicalHistory',7,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-06 09:38:57','2026-08-06 09:38:57'),
(16,'default','medical_history.saved','App\\Models\\MedicalHistory',7,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-06 09:40:13','2026-08-06 09:40:13'),
(17,'default','medical_history.saved','App\\Models\\MedicalHistory',7,NULL,'App\\Models\\User',1,'[]','{\"changes\":{\"updated_at\":\"2026-08-06 17:40:37\",\"conditions_checklist\":\"[\\\"arthritis\\\",\\\"others\\\"]\"},\"recorded_by\":1}','2026-08-06 09:40:37','2026-08-06 09:40:37'),
(18,'consents','created','App\\Models\\ConsentForm',4,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(19,'default','consent.created','App\\Models\\ConsentForm',4,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(20,'default','consent.sections_initialed','App\\Models\\ConsentForm',4,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(21,'consents','created','App\\Models\\ConsentForm',5,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(22,'default','consent.created','App\\Models\\ConsentForm',5,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(23,'default','consent.sections_initialed','App\\Models\\ConsentForm',5,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(24,'consents','updated','App\\Models\\ConsentForm',4,'updated','App\\Models\\User',1,'[]','[]','2026-08-06 09:54:50','2026-08-06 09:54:50'),
(25,'default','consent.patient_signed','App\\Models\\ConsentForm',4,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:54:50','2026-08-06 09:54:50'),
(26,'consultations','created','App\\Models\\Consultation',4,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:02','2026-08-06 09:55:02'),
(27,'default','consultation.created','App\\Models\\Consultation',4,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:02','2026-08-06 09:55:02'),
(28,'dental_chart_entries','created','App\\Models\\DentalChartEntry',17,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:20','2026-08-06 09:55:20'),
(29,'default','chart.updated','App\\Models\\DentalChartEntry',17,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:20','2026-08-06 09:55:20'),
(30,'dental_chart_entries','created','App\\Models\\DentalChartEntry',18,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:21','2026-08-06 09:55:21'),
(31,'default','chart.updated','App\\Models\\DentalChartEntry',18,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:21','2026-08-06 09:55:21'),
(32,'dental_chart_entries','created','App\\Models\\DentalChartEntry',19,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:34','2026-08-06 09:55:34'),
(33,'default','chart.updated','App\\Models\\DentalChartEntry',19,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:34','2026-08-06 09:55:34'),
(34,'dental_chart_entries','created','App\\Models\\DentalChartEntry',20,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:39','2026-08-06 09:55:39'),
(35,'default','chart.updated','App\\Models\\DentalChartEntry',20,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:39','2026-08-06 09:55:39'),
(36,'dental_chart_entries','created','App\\Models\\DentalChartEntry',21,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:42','2026-08-06 09:55:42'),
(37,'default','chart.updated','App\\Models\\DentalChartEntry',21,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:42','2026-08-06 09:55:42'),
(38,'dental_chart_entries','created','App\\Models\\DentalChartEntry',22,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:43','2026-08-06 09:55:43'),
(39,'default','chart.updated','App\\Models\\DentalChartEntry',22,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:43','2026-08-06 09:55:43'),
(40,'dental_chart_entries','created','App\\Models\\DentalChartEntry',23,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:45','2026-08-06 09:55:45'),
(41,'default','chart.updated','App\\Models\\DentalChartEntry',23,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:45','2026-08-06 09:55:45'),
(42,'dental_chart_entries','created','App\\Models\\DentalChartEntry',24,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:47','2026-08-06 09:55:47'),
(43,'default','chart.updated','App\\Models\\DentalChartEntry',24,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:47','2026-08-06 09:55:47'),
(44,'dental_chart_entries','created','App\\Models\\DentalChartEntry',25,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:49','2026-08-06 09:55:49'),
(45,'default','chart.updated','App\\Models\\DentalChartEntry',25,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:49','2026-08-06 09:55:49'),
(46,'dental_chart_entries','created','App\\Models\\DentalChartEntry',26,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:52','2026-08-06 09:55:52'),
(47,'default','chart.updated','App\\Models\\DentalChartEntry',26,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:52','2026-08-06 09:55:52'),
(48,'dental_chart_entries','created','App\\Models\\DentalChartEntry',27,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:52','2026-08-06 09:55:52'),
(49,'default','chart.updated','App\\Models\\DentalChartEntry',27,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:52','2026-08-06 09:55:52'),
(50,'dental_chart_entries','created','App\\Models\\DentalChartEntry',28,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:55:58','2026-08-06 09:55:58'),
(51,'default','chart.updated','App\\Models\\DentalChartEntry',28,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:55:58','2026-08-06 09:55:58'),
(52,'dental_chart_entries','created','App\\Models\\DentalChartEntry',29,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:56:01','2026-08-06 09:56:01'),
(53,'default','chart.updated','App\\Models\\DentalChartEntry',29,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:56:01','2026-08-06 09:56:01'),
(54,'treatments','created','App\\Models\\Treatment',5,'created','App\\Models\\User',1,'[]','[]','2026-08-06 09:56:29','2026-08-06 09:56:29'),
(55,'default','treatment.created','App\\Models\\Treatment',5,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:56:29','2026-08-06 09:56:29'),
(56,'treatments','updated','App\\Models\\Treatment',5,'updated','App\\Models\\User',1,'[]','[]','2026-08-06 09:56:36','2026-08-06 09:56:36'),
(57,'default','treatment.signed','App\\Models\\Treatment',5,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 09:56:36','2026-08-06 09:56:36'),
(58,'consents','created','App\\Models\\ConsentForm',6,'created','App\\Models\\User',1,'[]','[]','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(59,'default','consent.created','App\\Models\\ConsentForm',6,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(60,'default','consent.sections_initialed','App\\Models\\ConsentForm',6,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(61,'consents','updated','App\\Models\\ConsentForm',6,'updated','App\\Models\\User',1,'[]','[]','2026-08-06 11:10:19','2026-08-06 11:10:19'),
(62,'default','consent.patient_signed','App\\Models\\ConsentForm',6,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:10:19','2026-08-06 11:10:19'),
(63,'default','medical_history.saved','App\\Models\\MedicalHistory',7,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-06 11:10:33','2026-08-06 11:10:33'),
(64,'consents','created','App\\Models\\ConsentForm',7,'created','App\\Models\\User',1,'[]','[]','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(65,'default','consent.created','App\\Models\\ConsentForm',7,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(66,'default','consent.sections_initialed','App\\Models\\ConsentForm',7,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(67,'consultations','created','App\\Models\\Consultation',5,'created','App\\Models\\User',1,'[]','[]','2026-08-06 11:24:48','2026-08-06 11:24:48'),
(68,'default','consultation.created','App\\Models\\Consultation',5,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:24:48','2026-08-06 11:24:48'),
(69,'default','medical_history.saved','App\\Models\\MedicalHistory',7,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-06 11:25:00','2026-08-06 11:25:00'),
(70,'consents','created','App\\Models\\ConsentForm',8,'created','App\\Models\\User',1,'[]','[]','2026-08-06 11:25:02','2026-08-06 11:25:02'),
(71,'default','consent.created','App\\Models\\ConsentForm',8,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:25:02','2026-08-06 11:25:02'),
(72,'consents','created','App\\Models\\ConsentForm',9,'created','App\\Models\\User',1,'[]','[]','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(73,'default','consent.created','App\\Models\\ConsentForm',9,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(74,'default','consent.sections_initialed','App\\Models\\ConsentForm',9,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(75,'consents','updated','App\\Models\\ConsentForm',9,'updated','App\\Models\\User',1,'[]','[]','2026-08-06 11:25:18','2026-08-06 11:25:18'),
(76,'default','consent.patient_signed','App\\Models\\ConsentForm',9,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:25:18','2026-08-06 11:25:18'),
(77,'consultations','created','App\\Models\\Consultation',6,'created','App\\Models\\User',1,'[]','[]','2026-08-06 11:25:26','2026-08-06 11:25:26'),
(78,'default','consultation.created','App\\Models\\Consultation',6,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:25:26','2026-08-06 11:25:26'),
(79,'treatments','created','App\\Models\\Treatment',6,'created','App\\Models\\User',1,'[]','[]','2026-08-06 11:25:35','2026-08-06 11:25:35'),
(80,'default','treatment.created','App\\Models\\Treatment',6,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:25:35','2026-08-06 11:25:35'),
(81,'treatments','updated','App\\Models\\Treatment',6,'updated','App\\Models\\User',1,'[]','[]','2026-08-06 11:25:49','2026-08-06 11:25:49'),
(82,'default','treatment.signed','App\\Models\\Treatment',6,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 11:25:49','2026-08-06 11:25:49'),
(83,'consultations','created','App\\Models\\Consultation',7,'created','App\\Models\\User',2,'[]','[]','2026-08-06 11:49:26','2026-08-06 11:49:26'),
(84,'default','consultation.created','App\\Models\\Consultation',7,NULL,'App\\Models\\User',2,'[]','[]','2026-08-06 11:49:26','2026-08-06 11:49:26'),
(85,'default','appointment.created','App\\Models\\Appointment',8,NULL,'App\\Models\\User',3,'[]','{\"changes\":[]}','2026-08-06 11:51:29','2026-08-06 11:51:29'),
(86,'consultations','created','App\\Models\\Consultation',8,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(87,'consultations','created','App\\Models\\Consultation',9,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(88,'consultations','created','App\\Models\\Consultation',10,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(89,'consultations','created','App\\Models\\Consultation',11,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(90,'consultations','created','App\\Models\\Consultation',12,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(91,'consultations','created','App\\Models\\Consultation',13,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(92,'consultations','created','App\\Models\\Consultation',14,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(93,'consultations','created','App\\Models\\Consultation',15,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(94,'consultations','created','App\\Models\\Consultation',16,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(95,'consultations','created','App\\Models\\Consultation',17,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(96,'consultations','created','App\\Models\\Consultation',18,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(97,'consultations','created','App\\Models\\Consultation',19,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:10','2026-08-06 12:37:10'),
(98,'treatments','created','App\\Models\\Treatment',7,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(99,'treatments','created','App\\Models\\Treatment',8,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(100,'treatments','created','App\\Models\\Treatment',9,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(101,'treatments','created','App\\Models\\Treatment',10,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(102,'treatments','created','App\\Models\\Treatment',11,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(103,'treatments','created','App\\Models\\Treatment',12,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(104,'treatments','created','App\\Models\\Treatment',13,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(105,'treatments','created','App\\Models\\Treatment',14,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(106,'treatments','created','App\\Models\\Treatment',15,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(107,'treatments','created','App\\Models\\Treatment',16,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(108,'treatments','created','App\\Models\\Treatment',17,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(109,'treatments','created','App\\Models\\Treatment',18,'created',NULL,NULL,'[]','[]','2026-08-06 12:37:21','2026-08-06 12:37:21'),
(110,'default','patient.registered','App\\Models\\Patient',9,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 14:02:25','2026-08-06 14:02:25'),
(111,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-06 14:02:27','2026-08-06 14:02:27'),
(112,'consents','created','App\\Models\\ConsentForm',10,'created','App\\Models\\User',1,'[]','[]','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(113,'default','consent.created','App\\Models\\ConsentForm',10,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(114,'default','consent.sections_initialed','App\\Models\\ConsentForm',10,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(115,'consents','updated','App\\Models\\ConsentForm',10,'updated','App\\Models\\User',1,'[]','[]','2026-08-06 14:07:18','2026-08-06 14:07:18'),
(116,'default','consent.patient_signed','App\\Models\\ConsentForm',10,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 14:07:18','2026-08-06 14:07:18'),
(117,'consultations','created','App\\Models\\Consultation',20,'created','App\\Models\\User',1,'[]','[]','2026-08-06 14:07:38','2026-08-06 14:07:38'),
(118,'default','consultation.created','App\\Models\\Consultation',20,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 14:07:38','2026-08-06 14:07:38'),
(119,'dental_chart_entries','created','App\\Models\\DentalChartEntry',30,'created','App\\Models\\User',1,'[]','[]','2026-08-06 14:07:53','2026-08-06 14:07:53'),
(120,'default','chart.updated','App\\Models\\DentalChartEntry',30,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 14:07:53','2026-08-06 14:07:53'),
(121,'dental_chart_entries','created','App\\Models\\DentalChartEntry',31,'created','App\\Models\\User',1,'[]','[]','2026-08-06 14:07:54','2026-08-06 14:07:54'),
(122,'default','chart.updated','App\\Models\\DentalChartEntry',31,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 14:07:54','2026-08-06 14:07:54'),
(123,'consultations','created','App\\Models\\Consultation',21,'created','App\\Models\\User',1,'[]','[]','2026-08-06 14:08:28','2026-08-06 14:08:28'),
(124,'default','consultation.created','App\\Models\\Consultation',21,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 14:08:28','2026-08-06 14:08:28'),
(125,'treatments','created','App\\Models\\Treatment',19,'created','App\\Models\\User',1,'[]','[]','2026-08-06 14:08:41','2026-08-06 14:08:41'),
(126,'default','treatment.created','App\\Models\\Treatment',19,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 14:08:41','2026-08-06 14:08:41'),
(127,'treatments','updated','App\\Models\\Treatment',19,'updated','App\\Models\\User',1,'[]','[]','2026-08-06 14:08:49','2026-08-06 14:08:49'),
(128,'default','treatment.signed','App\\Models\\Treatment',19,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 14:08:49','2026-08-06 14:08:49'),
(129,'default','patient.registered','App\\Models\\Patient',10,NULL,'App\\Models\\User',1,'[]','[]','2026-08-06 20:59:31','2026-08-06 20:59:31'),
(130,'default','patient.updated','App\\Models\\Patient',9,NULL,'App\\Models\\User',2,'[]','{\"changes\":[]}','2026-08-08 03:58:47','2026-08-08 03:58:47'),
(131,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',2,'[]','{\"changes\":{\"recorded_by\":2,\"updated_at\":\"2026-08-08 11:59:09\"},\"recorded_by\":2}','2026-08-08 03:59:09','2026-08-08 03:59:09'),
(132,'consents','created','App\\Models\\ConsentForm',11,'created','App\\Models\\User',2,'[]','[]','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(133,'default','consent.created','App\\Models\\ConsentForm',11,NULL,'App\\Models\\User',2,'[]','[]','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(134,'default','consent.sections_initialed','App\\Models\\ConsentForm',11,NULL,'App\\Models\\User',2,'[]','[]','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(135,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":{\"recorded_by\":1,\"updated_at\":\"2026-08-08 12:02:34\"},\"recorded_by\":1}','2026-08-08 04:02:34','2026-08-08 04:02:34'),
(136,'consents','created','App\\Models\\ConsentForm',12,'created','App\\Models\\User',1,'[]','[]','2026-08-08 04:02:41','2026-08-08 04:02:41'),
(137,'default','consent.created','App\\Models\\ConsentForm',12,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:02:41','2026-08-08 04:02:41'),
(138,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-08 04:09:05','2026-08-08 04:09:05'),
(139,'consents','created','App\\Models\\ConsentForm',13,'created','App\\Models\\User',1,'[]','[]','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(140,'default','consent.created','App\\Models\\ConsentForm',13,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(141,'default','consent.sections_initialed','App\\Models\\ConsentForm',13,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(142,'consents','updated','App\\Models\\ConsentForm',13,'updated','App\\Models\\User',1,'[]','[]','2026-08-08 04:10:42','2026-08-08 04:10:42'),
(143,'default','consent.patient_signed','App\\Models\\ConsentForm',13,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:10:42','2026-08-08 04:10:42'),
(144,'consents','updated','App\\Models\\ConsentForm',13,'updated',NULL,NULL,'[]','[]','2026-08-08 04:18:05','2026-08-08 04:18:05'),
(145,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-08 04:19:37','2026-08-08 04:19:37'),
(146,'consents','created','App\\Models\\ConsentForm',14,'created','App\\Models\\User',1,'[]','[]','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(147,'default','consent.created','App\\Models\\ConsentForm',14,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(148,'default','consent.sections_initialed','App\\Models\\ConsentForm',14,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(149,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-08 04:26:22','2026-08-08 04:26:22'),
(150,'consents','created','App\\Models\\ConsentForm',15,'created','App\\Models\\User',1,'[]','[]','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(151,'default','consent.created','App\\Models\\ConsentForm',15,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(152,'default','consent.sections_initialed','App\\Models\\ConsentForm',15,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(153,'consents','updated','App\\Models\\ConsentForm',15,'updated','App\\Models\\User',1,'[]','[]','2026-08-08 04:26:56','2026-08-08 04:26:56'),
(154,'default','consent.patient_signed','App\\Models\\ConsentForm',15,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:26:56','2026-08-08 04:26:56'),
(155,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-08 04:28:27','2026-08-08 04:28:27'),
(156,'consents','created','App\\Models\\ConsentForm',16,'created','App\\Models\\User',1,'[]','[]','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(157,'default','consent.created','App\\Models\\ConsentForm',16,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(158,'default','consent.sections_initialed','App\\Models\\ConsentForm',16,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(159,'consents','updated','App\\Models\\ConsentForm',16,'updated','App\\Models\\User',1,'[]','[]','2026-08-08 04:29:14','2026-08-08 04:29:14'),
(160,'default','consent.patient_signed','App\\Models\\ConsentForm',16,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:29:14','2026-08-08 04:29:14'),
(161,'default','patient.updated','App\\Models\\Patient',9,NULL,'App\\Models\\User',1,'[]','{\"changes\":[]}','2026-08-08 04:41:09','2026-08-08 04:41:09'),
(162,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-08 04:41:35','2026-08-08 04:41:35'),
(163,'consents','created','App\\Models\\ConsentForm',17,'created','App\\Models\\User',1,'[]','[]','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(164,'default','consent.created','App\\Models\\ConsentForm',17,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(165,'default','consent.sections_initialed','App\\Models\\ConsentForm',17,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(166,'consents','updated','App\\Models\\ConsentForm',17,'updated','App\\Models\\User',1,'[]','[]','2026-08-08 04:41:53','2026-08-08 04:41:53'),
(167,'default','consent.patient_signed','App\\Models\\ConsentForm',17,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:41:53','2026-08-08 04:41:53'),
(168,'consultations','created','App\\Models\\Consultation',22,'created','App\\Models\\User',1,'[]','[]','2026-08-08 04:42:01','2026-08-08 04:42:01'),
(169,'default','consultation.created','App\\Models\\Consultation',22,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:42:01','2026-08-08 04:42:01'),
(170,'consents','updated','App\\Models\\ConsentForm',17,'updated','App\\Models\\User',1,'[]','[]','2026-08-08 04:42:29','2026-08-08 04:42:29'),
(171,'default','consent.dentist_signed','App\\Models\\ConsentForm',17,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 04:42:29','2026-08-08 04:42:29'),
(172,'attachments','created','App\\Models\\Attachment',4,'created','App\\Models\\User',1,'[]','[]','2026-08-08 05:38:27','2026-08-08 05:38:27'),
(173,'default','attachment.uploaded','App\\Models\\Attachment',4,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 05:38:27','2026-08-08 05:38:27'),
(174,'attachments','deleted','App\\Models\\Attachment',4,'deleted','App\\Models\\User',1,'[]','[]','2026-08-08 05:38:48','2026-08-08 05:38:48'),
(175,'default','attachment.deleted','App\\Models\\Attachment',4,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 05:38:48','2026-08-08 05:38:48'),
(176,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-08 05:40:04','2026-08-08 05:40:04'),
(177,'consents','created','App\\Models\\ConsentForm',18,'created','App\\Models\\User',1,'[]','[]','2026-08-08 05:40:24','2026-08-08 05:40:24'),
(178,'default','consent.created','App\\Models\\ConsentForm',18,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 05:40:24','2026-08-08 05:40:24'),
(179,'default','consent.sections_initialed','App\\Models\\ConsentForm',18,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 05:40:24','2026-08-08 05:40:24'),
(180,'consents','deleted','App\\Models\\ConsentForm',18,'deleted',NULL,NULL,'[]','[]','2026-08-08 05:42:13','2026-08-08 05:42:13'),
(181,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-08 05:45:24','2026-08-08 05:45:24'),
(182,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":{\"updated_at\":\"2026-08-08 16:51:41\",\"blood_type\":\"O+\"},\"recorded_by\":1}','2026-08-08 08:51:41','2026-08-08 08:51:41'),
(183,'consents','created','App\\Models\\ConsentForm',19,'created','App\\Models\\User',1,'[]','[]','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(184,'default','consent.created','App\\Models\\ConsentForm',19,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(185,'default','consent.sections_initialed','App\\Models\\ConsentForm',19,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(186,'consents','updated','App\\Models\\ConsentForm',19,'updated','App\\Models\\User',1,'[]','[]','2026-08-08 08:52:21','2026-08-08 08:52:21'),
(187,'default','consent.patient_signed','App\\Models\\ConsentForm',19,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 08:52:21','2026-08-08 08:52:21'),
(188,'default','medical_history.saved','App\\Models\\MedicalHistory',9,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-08 12:38:09','2026-08-08 12:38:09'),
(189,'consents','created','App\\Models\\ConsentForm',20,'created','App\\Models\\User',1,'[]','[]','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(190,'default','consent.created','App\\Models\\ConsentForm',20,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(191,'default','consent.sections_initialed','App\\Models\\ConsentForm',20,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(192,'consents','updated','App\\Models\\ConsentForm',20,'updated','App\\Models\\User',1,'[]','[]','2026-08-08 12:38:22','2026-08-08 12:38:22'),
(193,'default','consent.patient_signed','App\\Models\\ConsentForm',20,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:38:22','2026-08-08 12:38:22'),
(194,'consultations','created','App\\Models\\Consultation',23,'created','App\\Models\\User',1,'[]','[]','2026-08-08 12:38:29','2026-08-08 12:38:29'),
(195,'default','consultation.created','App\\Models\\Consultation',23,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:38:29','2026-08-08 12:38:29'),
(196,'dental_chart_entries','created','App\\Models\\DentalChartEntry',32,'created','App\\Models\\User',1,'[]','[]','2026-08-08 12:38:37','2026-08-08 12:38:37'),
(197,'default','chart.updated','App\\Models\\DentalChartEntry',32,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:38:37','2026-08-08 12:38:37'),
(198,'dental_chart_entries','created','App\\Models\\DentalChartEntry',33,'created','App\\Models\\User',1,'[]','[]','2026-08-08 12:38:40','2026-08-08 12:38:40'),
(199,'default','chart.updated','App\\Models\\DentalChartEntry',33,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:38:40','2026-08-08 12:38:40'),
(200,'dental_chart_entries','created','App\\Models\\DentalChartEntry',34,'created','App\\Models\\User',1,'[]','[]','2026-08-08 12:38:42','2026-08-08 12:38:42'),
(201,'default','chart.updated','App\\Models\\DentalChartEntry',34,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:38:42','2026-08-08 12:38:42'),
(202,'dental_chart_entries','created','App\\Models\\DentalChartEntry',35,'created','App\\Models\\User',1,'[]','[]','2026-08-08 12:38:44','2026-08-08 12:38:44'),
(203,'default','chart.updated','App\\Models\\DentalChartEntry',35,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:38:44','2026-08-08 12:38:44'),
(204,'dental_chart_entries','created','App\\Models\\DentalChartEntry',36,'created','App\\Models\\User',1,'[]','[]','2026-08-08 12:38:58','2026-08-08 12:38:58'),
(205,'default','chart.updated','App\\Models\\DentalChartEntry',36,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:38:58','2026-08-08 12:38:58'),
(206,'dental_chart_entries','created','App\\Models\\DentalChartEntry',37,'created','App\\Models\\User',1,'[]','[]','2026-08-08 12:39:24','2026-08-08 12:39:24'),
(207,'default','chart.updated','App\\Models\\DentalChartEntry',37,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:39:24','2026-08-08 12:39:24'),
(208,'default','patient.registered','App\\Models\\Patient',11,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 12:59:17','2026-08-08 12:59:17'),
(209,'default','patient.registered','App\\Models\\Patient',12,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 13:02:30','2026-08-08 13:02:30'),
(210,'dental_chart_entries','created','App\\Models\\DentalChartEntry',38,'created','App\\Models\\User',1,'[]','[]','2026-08-08 15:16:19','2026-08-08 15:16:19'),
(211,'default','chart.updated','App\\Models\\DentalChartEntry',38,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 15:16:19','2026-08-08 15:16:19'),
(212,'dental_chart_entries','deleted','App\\Models\\DentalChartEntry',38,'deleted',NULL,NULL,'[]','[]','2026-08-08 15:16:40','2026-08-08 15:16:40'),
(213,'dental_chart_entries','created','App\\Models\\DentalChartEntry',39,'created','App\\Models\\User',1,'[]','[]','2026-08-08 15:25:14','2026-08-08 15:25:14'),
(214,'default','chart.updated','App\\Models\\DentalChartEntry',39,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 15:25:14','2026-08-08 15:25:14'),
(215,'dental_chart_entries','created','App\\Models\\DentalChartEntry',40,'created','App\\Models\\User',1,'[]','[]','2026-08-08 15:25:35','2026-08-08 15:25:35'),
(216,'default','chart.updated','App\\Models\\DentalChartEntry',40,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 15:25:35','2026-08-08 15:25:35'),
(217,'dental_chart_entries','deleted','App\\Models\\DentalChartEntry',39,'deleted',NULL,NULL,'[]','[]','2026-08-08 15:28:04','2026-08-08 15:28:04'),
(218,'dental_chart_entries','deleted','App\\Models\\DentalChartEntry',40,'deleted',NULL,NULL,'[]','[]','2026-08-08 15:28:04','2026-08-08 15:28:04'),
(219,'dental_chart_entries','created','App\\Models\\DentalChartEntry',41,'created','App\\Models\\User',1,'[]','[]','2026-08-08 18:23:17','2026-08-08 18:23:17'),
(220,'default','chart.updated','App\\Models\\DentalChartEntry',41,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 18:23:17','2026-08-08 18:23:17'),
(221,'dental_chart_entries','created','App\\Models\\DentalChartEntry',42,'created','App\\Models\\User',1,'[]','[]','2026-08-08 18:23:21','2026-08-08 18:23:21'),
(222,'default','chart.updated','App\\Models\\DentalChartEntry',42,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 18:23:21','2026-08-08 18:23:21'),
(223,'dental_chart_entries','created','App\\Models\\DentalChartEntry',43,'created','App\\Models\\User',1,'[]','[]','2026-08-08 18:23:32','2026-08-08 18:23:32'),
(224,'default','chart.updated','App\\Models\\DentalChartEntry',43,NULL,'App\\Models\\User',1,'[]','[]','2026-08-08 18:23:32','2026-08-08 18:23:32'),
(225,'dental_chart_entries','created','App\\Models\\DentalChartEntry',44,'created','App\\Models\\User',1,'[]','[]','2026-08-09 04:20:08','2026-08-09 04:20:08'),
(226,'default','chart.updated','App\\Models\\DentalChartEntry',44,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 04:20:08','2026-08-09 04:20:08'),
(227,'dental_chart_entries','created','App\\Models\\DentalChartEntry',45,'created','App\\Models\\User',1,'[]','[]','2026-08-09 04:20:13','2026-08-09 04:20:13'),
(228,'default','chart.updated','App\\Models\\DentalChartEntry',45,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 04:20:13','2026-08-09 04:20:13'),
(229,'dental_chart_entries','created','App\\Models\\DentalChartEntry',46,'created','App\\Models\\User',1,'[]','[]','2026-08-09 04:20:14','2026-08-09 04:20:14'),
(230,'default','chart.updated','App\\Models\\DentalChartEntry',46,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 04:20:14','2026-08-09 04:20:14'),
(231,'dental_chart_entries','created','App\\Models\\DentalChartEntry',47,'created','App\\Models\\User',1,'[]','[]','2026-08-09 04:20:21','2026-08-09 04:20:21'),
(232,'default','chart.updated','App\\Models\\DentalChartEntry',47,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 04:20:21','2026-08-09 04:20:21'),
(233,'dental_chart_entries','created','App\\Models\\DentalChartEntry',48,'created','App\\Models\\User',1,'[]','[]','2026-08-09 04:20:22','2026-08-09 04:20:22'),
(234,'default','chart.updated','App\\Models\\DentalChartEntry',48,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 04:20:22','2026-08-09 04:20:22'),
(235,'dental_chart_entries','created','App\\Models\\DentalChartEntry',49,'created','App\\Models\\User',1,'[]','[]','2026-08-09 04:20:28','2026-08-09 04:20:28'),
(236,'default','chart.updated','App\\Models\\DentalChartEntry',49,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 04:20:28','2026-08-09 04:20:28'),
(237,'dental_chart_entries','created','App\\Models\\DentalChartEntry',50,'created','App\\Models\\User',1,'[]','[]','2026-08-09 04:20:30','2026-08-09 04:20:30'),
(238,'default','chart.updated','App\\Models\\DentalChartEntry',50,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 04:20:30','2026-08-09 04:20:30'),
(239,'dental_chart_entries','created','App\\Models\\DentalChartEntry',51,'created','App\\Models\\User',1,'[]','[]','2026-08-09 04:20:35','2026-08-09 04:20:35'),
(240,'default','chart.updated','App\\Models\\DentalChartEntry',51,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 04:20:35','2026-08-09 04:20:35'),
(241,'dental_chart_entries','created','App\\Models\\DentalChartEntry',52,'created','App\\Models\\User',1,'[]','[]','2026-08-09 04:20:39','2026-08-09 04:20:39'),
(242,'default','chart.updated','App\\Models\\DentalChartEntry',52,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 04:20:39','2026-08-09 04:20:39'),
(243,'dental_chart_entries','created','App\\Models\\DentalChartEntry',53,'created','App\\Models\\User',1,'[]','[]','2026-08-09 04:20:44','2026-08-09 04:20:44'),
(244,'default','chart.updated','App\\Models\\DentalChartEntry',53,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 04:20:44','2026-08-09 04:20:44'),
(245,'consents','created','App\\Models\\ConsentForm',21,'created','App\\Models\\User',1,'[]','[]','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(246,'default','consent.created','App\\Models\\ConsentForm',21,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(247,'default','consent.sections_initialed','App\\Models\\ConsentForm',21,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(248,'default','medical_history.saved','App\\Models\\MedicalHistory',3,NULL,'App\\Models\\User',1,'[]','{\"changes\":{\"recorded_by\":1,\"updated_at\":\"2026-08-09 14:27:18\",\"conditions_checklist\":\"[]\"},\"recorded_by\":1}','2026-08-09 06:27:18','2026-08-09 06:27:18'),
(249,'consents','created','App\\Models\\ConsentForm',22,'created','App\\Models\\User',1,'[]','[]','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(250,'default','consent.created','App\\Models\\ConsentForm',22,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(251,'default','consent.sections_initialed','App\\Models\\ConsentForm',22,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(252,'consents','updated','App\\Models\\ConsentForm',22,'updated','App\\Models\\User',1,'[]','[]','2026-08-09 06:28:14','2026-08-09 06:28:14'),
(253,'default','consent.patient_signed','App\\Models\\ConsentForm',22,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:28:14','2026-08-09 06:28:14'),
(254,'consultations','created','App\\Models\\Consultation',24,'created','App\\Models\\User',1,'[]','[]','2026-08-09 06:28:21','2026-08-09 06:28:21'),
(255,'default','consultation.created','App\\Models\\Consultation',24,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:28:21','2026-08-09 06:28:21'),
(256,'consents','updated','App\\Models\\ConsentForm',22,'updated','App\\Models\\User',1,'[]','[]','2026-08-09 06:28:38','2026-08-09 06:28:38'),
(257,'default','consent.dentist_signed','App\\Models\\ConsentForm',22,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:28:38','2026-08-09 06:28:38'),
(258,'consents','updated','App\\Models\\ConsentForm',4,'updated','App\\Models\\User',1,'[]','[]','2026-08-09 06:28:43','2026-08-09 06:28:43'),
(259,'default','consent.dentist_signed','App\\Models\\ConsentForm',4,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:28:43','2026-08-09 06:28:43'),
(260,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-09 06:32:41','2026-08-09 06:32:41'),
(261,'consents','created','App\\Models\\ConsentForm',23,'created','App\\Models\\User',1,'[]','[]','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(262,'default','consent.created','App\\Models\\ConsentForm',23,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(263,'default','consent.sections_initialed','App\\Models\\ConsentForm',23,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(264,'consents','updated','App\\Models\\ConsentForm',23,'updated','App\\Models\\User',1,'[]','[]','2026-08-09 06:33:03','2026-08-09 06:33:03'),
(265,'default','consent.patient_signed','App\\Models\\ConsentForm',23,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:33:03','2026-08-09 06:33:03'),
(266,'treatments','created','App\\Models\\Treatment',20,'created','App\\Models\\User',1,'[]','[]','2026-08-09 06:34:14','2026-08-09 06:34:14'),
(267,'default','treatment.created','App\\Models\\Treatment',20,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:34:14','2026-08-09 06:34:14'),
(268,'treatments','updated','App\\Models\\Treatment',20,'updated','App\\Models\\User',1,'[]','[]','2026-08-09 06:34:21','2026-08-09 06:34:21'),
(269,'default','treatment.signed','App\\Models\\Treatment',20,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 06:34:21','2026-08-09 06:34:21'),
(270,'default','appointment.created','App\\Models\\Appointment',9,NULL,'App\\Models\\User',4,'[]','{\"changes\":[]}','2026-08-09 06:38:54','2026-08-09 06:38:54'),
(271,'default','appointment.cancelled','App\\Models\\Appointment',9,NULL,'App\\Models\\User',4,'[]','{\"changes\":{\"status\":\"cancelled\",\"notes\":\"Cancelled: test\",\"updated_at\":\"2026-08-09 14:39:11\"},\"reason\":\"test\"}','2026-08-09 06:39:11','2026-08-09 06:39:11'),
(272,'default','appointment.created','App\\Models\\Appointment',10,NULL,'App\\Models\\User',4,'[]','{\"changes\":[]}','2026-08-09 06:39:18','2026-08-09 06:39:18'),
(273,'default','appointment.confirmed','App\\Models\\Appointment',10,NULL,'App\\Models\\User',4,'[]','{\"changes\":{\"status\":\"confirmed\",\"updated_at\":\"2026-08-09 14:39:22\"}}','2026-08-09 06:39:22','2026-08-09 06:39:22'),
(274,'consents','created','App\\Models\\ConsentForm',24,'created','App\\Models\\User',2,'[]','[]','2026-08-09 06:40:36','2026-08-09 06:40:36'),
(275,'default','consent.created','App\\Models\\ConsentForm',24,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:40:36','2026-08-09 06:40:36'),
(276,'default','consent.sections_initialed','App\\Models\\ConsentForm',24,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:40:37','2026-08-09 06:40:37'),
(277,'consents','updated','App\\Models\\ConsentForm',24,'updated','App\\Models\\User',2,'[]','[]','2026-08-09 06:40:40','2026-08-09 06:40:40'),
(278,'default','consent.patient_signed','App\\Models\\ConsentForm',24,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:40:40','2026-08-09 06:40:40'),
(279,'consultations','created','App\\Models\\Consultation',25,'created','App\\Models\\User',2,'[]','[]','2026-08-09 06:40:48','2026-08-09 06:40:48'),
(280,'default','consultation.created','App\\Models\\Consultation',25,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:40:48','2026-08-09 06:40:48'),
(281,'treatments','created','App\\Models\\Treatment',21,'created','App\\Models\\User',2,'[]','[]','2026-08-09 06:41:15','2026-08-09 06:41:15'),
(282,'default','treatment.created','App\\Models\\Treatment',21,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:41:15','2026-08-09 06:41:15'),
(283,'default','medical_history.saved','App\\Models\\MedicalHistory',2,NULL,'App\\Models\\User',2,'[]','{\"changes\":{\"remarks\":\"qwe\",\"updated_at\":\"2026-08-09 14:41:50\",\"conditions_checklist\":\"[]\"},\"recorded_by\":2}','2026-08-09 06:41:50','2026-08-09 06:41:50'),
(284,'consents','created','App\\Models\\ConsentForm',25,'created','App\\Models\\User',2,'[]','[]','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(285,'default','consent.created','App\\Models\\ConsentForm',25,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(286,'default','consent.sections_initialed','App\\Models\\ConsentForm',25,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(287,'consents','updated','App\\Models\\ConsentForm',25,'updated','App\\Models\\User',2,'[]','[]','2026-08-09 06:41:59','2026-08-09 06:41:59'),
(288,'default','consent.patient_signed','App\\Models\\ConsentForm',25,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:41:59','2026-08-09 06:41:59'),
(289,'consultations','created','App\\Models\\Consultation',26,'created','App\\Models\\User',2,'[]','[]','2026-08-09 06:42:11','2026-08-09 06:42:11'),
(290,'default','consultation.created','App\\Models\\Consultation',26,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:42:11','2026-08-09 06:42:11'),
(291,'treatments','created','App\\Models\\Treatment',22,'created','App\\Models\\User',2,'[]','[]','2026-08-09 06:42:24','2026-08-09 06:42:24'),
(292,'default','treatment.created','App\\Models\\Treatment',22,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:42:24','2026-08-09 06:42:24'),
(293,'treatments','updated','App\\Models\\Treatment',22,'updated','App\\Models\\User',2,'[]','[]','2026-08-09 06:42:29','2026-08-09 06:42:29'),
(294,'default','treatment.signed','App\\Models\\Treatment',22,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:42:29','2026-08-09 06:42:29'),
(295,'treatments','updated','App\\Models\\Treatment',21,'updated','App\\Models\\User',2,'[]','[]','2026-08-09 06:42:31','2026-08-09 06:42:31'),
(296,'default','treatment.signed','App\\Models\\Treatment',21,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:42:31','2026-08-09 06:42:31'),
(297,'treatments','updated','App\\Models\\Treatment',3,'updated','App\\Models\\User',2,'[]','[]','2026-08-09 06:42:34','2026-08-09 06:42:34'),
(298,'default','treatment.signed','App\\Models\\Treatment',3,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:42:34','2026-08-09 06:42:34'),
(299,'consents','updated','App\\Models\\ConsentForm',25,'updated','App\\Models\\User',2,'[]','[]','2026-08-09 06:42:45','2026-08-09 06:42:45'),
(300,'default','consent.dentist_signed','App\\Models\\ConsentForm',25,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:42:45','2026-08-09 06:42:45'),
(301,'consultations','created','App\\Models\\Consultation',27,'created','App\\Models\\User',2,'[]','[]','2026-08-09 06:44:23','2026-08-09 06:44:23'),
(302,'default','consultation.created','App\\Models\\Consultation',27,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:44:23','2026-08-09 06:44:23'),
(303,'treatments','created','App\\Models\\Treatment',23,'created','App\\Models\\User',2,'[]','[]','2026-08-09 06:57:47','2026-08-09 06:57:47'),
(304,'default','treatment.created','App\\Models\\Treatment',23,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:57:47','2026-08-09 06:57:47'),
(305,'treatments','updated','App\\Models\\Treatment',23,'updated','App\\Models\\User',2,'[]','[]','2026-08-09 06:59:21','2026-08-09 06:59:21'),
(306,'default','treatment.signed','App\\Models\\Treatment',23,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:59:21','2026-08-09 06:59:21'),
(307,'treatments','created','App\\Models\\Treatment',24,'created','App\\Models\\User',2,'[]','[]','2026-08-09 06:59:41','2026-08-09 06:59:41'),
(308,'default','treatment.created','App\\Models\\Treatment',24,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 06:59:41','2026-08-09 06:59:41'),
(309,'consultations','created','App\\Models\\Consultation',28,'created','App\\Models\\User',2,'[]','[]','2026-08-09 07:01:09','2026-08-09 07:01:09'),
(310,'default','consultation.created','App\\Models\\Consultation',28,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 07:01:09','2026-08-09 07:01:09'),
(311,'treatments','created','App\\Models\\Treatment',25,'created','App\\Models\\User',2,'[]','[]','2026-08-09 07:01:59','2026-08-09 07:01:59'),
(312,'default','treatment.created','App\\Models\\Treatment',25,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 07:01:59','2026-08-09 07:01:59'),
(313,'treatments','updated','App\\Models\\Treatment',25,'updated','App\\Models\\User',2,'[]','[]','2026-08-09 07:02:03','2026-08-09 07:02:03'),
(314,'default','treatment.signed','App\\Models\\Treatment',25,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 07:02:03','2026-08-09 07:02:03'),
(315,'default','medical_history.saved','App\\Models\\MedicalHistory',8,NULL,'App\\Models\\User',2,'[]','{\"changes\":{\"recorded_by\":2,\"updated_at\":\"2026-08-09 15:02:28\"},\"recorded_by\":2}','2026-08-09 07:02:28','2026-08-09 07:02:28'),
(316,'consents','created','App\\Models\\ConsentForm',26,'created','App\\Models\\User',2,'[]','[]','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(317,'default','consent.created','App\\Models\\ConsentForm',26,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(318,'default','consent.sections_initialed','App\\Models\\ConsentForm',26,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(319,'consents','updated','App\\Models\\ConsentForm',26,'updated','App\\Models\\User',2,'[]','[]','2026-08-09 07:02:37','2026-08-09 07:02:37'),
(320,'default','consent.patient_signed','App\\Models\\ConsentForm',26,NULL,'App\\Models\\User',2,'[]','[]','2026-08-09 07:02:37','2026-08-09 07:02:37'),
(321,'consents','created','App\\Models\\ConsentForm',27,'created',NULL,NULL,'[]','[]','2026-08-09 07:14:31','2026-08-09 07:14:31'),
(322,'default','medical_history.saved','App\\Models\\MedicalHistory',7,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-09 07:19:16','2026-08-09 07:19:16'),
(323,'default','medical_history.saved','App\\Models\\MedicalHistory',7,NULL,'App\\Models\\User',1,'[]','{\"changes\":[],\"recorded_by\":1}','2026-08-09 07:19:20','2026-08-09 07:19:20'),
(324,'consents','created','App\\Models\\ConsentForm',28,'created','App\\Models\\User',1,'[]','[]','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(325,'default','consent.created','App\\Models\\ConsentForm',28,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(326,'default','consent.sections_initialed','App\\Models\\ConsentForm',28,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(327,'consents','updated','App\\Models\\ConsentForm',28,'updated','App\\Models\\User',1,'[]','[]','2026-08-09 07:19:36','2026-08-09 07:19:36'),
(328,'default','consent.patient_signed','App\\Models\\ConsentForm',28,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 07:19:36','2026-08-09 07:19:36'),
(329,'default','appointment.created','App\\Models\\Appointment',11,NULL,'App\\Models\\User',1,'[]','{\"changes\":[]}','2026-08-09 07:43:14','2026-08-09 07:43:14'),
(330,'consultations','created','App\\Models\\Consultation',29,'created','App\\Models\\User',1,'[]','[]','2026-08-09 08:01:13','2026-08-09 08:01:13'),
(331,'default','consultation.created','App\\Models\\Consultation',29,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 08:01:13','2026-08-09 08:01:13'),
(332,'treatments','created','App\\Models\\Treatment',26,'created','App\\Models\\User',1,'[]','[]','2026-08-09 08:01:36','2026-08-09 08:01:36'),
(333,'default','treatment.created','App\\Models\\Treatment',26,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 08:01:36','2026-08-09 08:01:36'),
(334,'treatments','updated','App\\Models\\Treatment',26,'updated','App\\Models\\User',1,'[]','[]','2026-08-09 08:01:44','2026-08-09 08:01:44'),
(335,'default','treatment.signed','App\\Models\\Treatment',26,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 08:01:44','2026-08-09 08:01:44'),
(336,'default','appointment.created','App\\Models\\Appointment',12,NULL,'App\\Models\\User',1,'[]','{\"changes\":[]}','2026-08-09 08:07:28','2026-08-09 08:07:28'),
(337,'default','appointment.created','App\\Models\\Appointment',13,NULL,'App\\Models\\User',1,'[]','{\"changes\":[]}','2026-08-09 08:15:37','2026-08-09 08:15:37'),
(338,'default','appointment.created','App\\Models\\Appointment',14,NULL,'App\\Models\\User',1,'[]','{\"changes\":[]}','2026-08-09 08:16:43','2026-08-09 08:16:43'),
(339,'consents','updated','App\\Models\\ConsentForm',26,'updated','App\\Models\\User',1,'[]','[]','2026-08-09 09:11:03','2026-08-09 09:11:03'),
(340,'default','consent.dentist_signed','App\\Models\\ConsentForm',26,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 09:11:03','2026-08-09 09:11:03'),
(341,'consents','updated','App\\Models\\ConsentForm',23,'updated','App\\Models\\User',1,'[]','[]','2026-08-09 09:11:06','2026-08-09 09:11:06'),
(342,'default','consent.dentist_signed','App\\Models\\ConsentForm',23,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 09:11:06','2026-08-09 09:11:06'),
(343,'consents','updated','App\\Models\\ConsentForm',19,'updated','App\\Models\\User',1,'[]','[]','2026-08-09 09:11:09','2026-08-09 09:11:09'),
(344,'default','consent.dentist_signed','App\\Models\\ConsentForm',19,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 09:11:09','2026-08-09 09:11:09'),
(345,'default','appointment.confirmed','App\\Models\\Appointment',14,NULL,'App\\Models\\User',1,'[]','{\"changes\":{\"status\":\"confirmed\",\"updated_at\":\"2026-08-09 18:25:03\"}}','2026-08-09 10:25:03','2026-08-09 10:25:03'),
(346,'default','patient.registered','App\\Models\\Patient',14,NULL,'App\\Models\\User',1,'[]','[]','2026-08-09 11:31:59','2026-08-09 11:31:59'),
(347,'default','patients.imported',NULL,NULL,NULL,'App\\Models\\User',1,'[]','{\"imported\":1,\"skipped_duplicate\":0,\"failed\":0}','2026-08-09 11:31:59','2026-08-09 11:31:59'),
(348,'default','patient.deleted','App\\Models\\Patient',14,NULL,'App\\Models\\User',1,'[]','{\"name\":\"Test Imported Patient\",\"patient_number\":\"2026-0011\"}','2026-08-09 11:33:52','2026-08-09 11:33:52');
/*!40000 ALTER TABLE `activity_log` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `dentist_id` bigint(20) unsigned DEFAULT NULL,
  `appointment_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `is_follow_up` tinyint(1) NOT NULL DEFAULT 0,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `attended_at` timestamp NULL DEFAULT NULL,
  `created_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `appointments_patient_id_foreign` (`patient_id`),
  KEY `appointments_created_by_foreign` (`created_by`),
  KEY `appointments_appointment_date_status_index` (`appointment_date`,`status`),
  KEY `appointments_dentist_id_index` (`dentist_id`),
  CONSTRAINT `appointments_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `appointments_dentist_id_foreign` FOREIGN KEY (`dentist_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `appointments_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `appointments` VALUES
(1,1,NULL,'2026-08-05','09:00:00','09:30:00','Regular checkup',0,'pending',NULL,NULL,4,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(2,2,2,'2026-08-05','10:00:00','10:30:00','Composite restoration',0,'confirmed',NULL,NULL,4,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(3,1,2,'2026-08-05','11:00:00','11:30:00','Scaling and polishing',0,'completed',NULL,'2026-08-05 03:30:00',4,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(4,3,2,'2026-08-07','14:00:00','14:30:00','Follow-up after composite restoration',1,'confirmed',NULL,NULL,4,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(5,5,NULL,'2026-08-12','09:00:00','09:30:00','Initial consultation',0,'pending',NULL,NULL,4,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(6,4,2,'2026-08-02','15:00:00','15:30:00','Root canal treatment',0,'no_show',NULL,'2026-08-02 07:30:00',4,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(7,6,NULL,'2026-07-26','10:00:00','10:30:00','Extraction',0,'cancelled',NULL,NULL,4,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(8,8,2,'2026-08-07','08:00:00','08:30:00','test',0,'pending',NULL,NULL,3,'2026-08-06 11:51:29','2026-08-06 11:51:29'),
(9,2,NULL,'2026-08-09','18:38:00','19:38:00',NULL,0,'cancelled','Cancelled: test',NULL,4,'2026-08-09 06:38:54','2026-08-09 06:39:11'),
(11,9,NULL,'2026-08-09','09:53:00','17:00:00',NULL,0,'pending',NULL,NULL,1,'2026-08-09 07:43:14','2026-08-09 07:43:14'),
(12,9,NULL,'2026-08-09','14:30:00','17:30:00',NULL,0,'pending',NULL,NULL,1,'2026-08-09 08:07:28','2026-08-09 08:07:28'),
(13,9,NULL,'2026-08-09','14:30:00','17:00:00',NULL,0,'pending',NULL,NULL,1,'2026-08-09 08:15:37','2026-08-09 08:15:37'),
(14,9,2,'2026-08-09','14:00:00','15:00:00','test reason',0,'confirmed',NULL,NULL,1,'2026-08-09 08:16:43','2026-08-09 10:25:03');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `attachments`
--

DROP TABLE IF EXISTS `attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `attachments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `uploaded_by` bigint(20) unsigned DEFAULT NULL,
  `category` varchar(255) NOT NULL DEFAULT 'image',
  `xray_type` varchar(255) DEFAULT NULL,
  `original_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `mime_type` varchar(255) NOT NULL,
  `file_size` bigint(20) unsigned NOT NULL,
  `notes` text DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `attachments_uploaded_by_foreign` (`uploaded_by`),
  KEY `attachments_patient_id_category_index` (`patient_id`,`category`),
  CONSTRAINT `attachments_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attachments_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attachments`
--

LOCK TABLES `attachments` WRITE;
/*!40000 ALTER TABLE `attachments` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `attachments` VALUES
(1,1,3,'xray','panoramic','pano-2026-07-01.png','uploads/1/6d04e641-eccb-4746-ba4e-976609015976.png','image/png',70,'Pre-operative panoramic radiograph',NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(2,2,3,'image',NULL,'intraoral-photo-2026-07-12.png','uploads/2/4a8a4931-4b28-4dec-aea1-06124a0260ac.png','image/png',70,'Intraoral photo — upper right arch',NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(3,4,3,'pdf',NULL,'referral-letter-dr-lim.pdf','uploads/4/9c6fca6e-63d3-4eba-a874-410e68d0d5ea.pdf','application/pdf',302,'Referral letter from Dr. Lim (Cardiologist)',NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(4,9,1,'image',NULL,'smoke-1px.png','uploads/9/303a8228-a249-43fa-b4c7-f7ab36680a88.png','image/png',70,NULL,'2026-08-08 05:38:48','2026-08-08 05:38:27','2026-08-08 05:38:48');
/*!40000 ALTER TABLE `attachments` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `cache` VALUES
('dental-record-cache-settings.appointment.overlap','s:5:\"false\";',1786263463),
('dental-record-cache-settings.clinic.address','s:0:\"\";',1786276945),
('dental-record-cache-settings.clinic.name','s:22:\"Jerrmond Dental Clinic\";',1786276945),
('dental-record-cache-spatie.permission.cache','a:3:{s:5:\"alias\";a:4:{s:1:\"a\";s:2:\"id\";s:1:\"b\";s:4:\"name\";s:1:\"c\";s:10:\"guard_name\";s:1:\"r\";s:5:\"roles\";}s:11:\"permissions\";a:35:{i:0;a:4:{s:1:\"a\";i:1;s:1:\"b\";s:10:\"users.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:1:{i:0;i:1;}}i:1;a:4:{s:1:\"a\";i:2;s:1:\"b\";s:12:\"users.create\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:1:{i:0;i:1;}}i:2;a:4:{s:1:\"a\";i:3;s:1:\"b\";s:12:\"users.update\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:1:{i:0;i:1;}}i:3;a:4:{s:1:\"a\";i:4;s:1:\"b\";s:12:\"users.delete\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:1:{i:0;i:1;}}i:4;a:4:{s:1:\"a\";i:5;s:1:\"b\";s:13:\"patients.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:5;a:4:{s:1:\"a\";i:6;s:1:\"b\";s:15:\"patients.create\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:6;a:4:{s:1:\"a\";i:7;s:1:\"b\";s:15:\"patients.update\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:7;a:4:{s:1:\"a\";i:8;s:1:\"b\";s:15:\"patients.delete\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:1:{i:0;i:1;}}i:8;a:4:{s:1:\"a\";i:9;s:1:\"b\";s:22:\"medical-histories.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:9;a:4:{s:1:\"a\";i:10;s:1:\"b\";s:24:\"medical-histories.create\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:10;a:4:{s:1:\"a\";i:11;s:1:\"b\";s:24:\"medical-histories.update\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:11;a:4:{s:1:\"a\";i:12;s:1:\"b\";s:17:\"appointments.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:12;a:4:{s:1:\"a\";i:13;s:1:\"b\";s:19:\"appointments.create\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:3;}}i:13;a:4:{s:1:\"a\";i:14;s:1:\"b\";s:19:\"appointments.update\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:14;a:4:{s:1:\"a\";i:15;s:1:\"b\";s:19:\"appointments.cancel\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:15;a:4:{s:1:\"a\";i:16;s:1:\"b\";s:23:\"appointments.attendance\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:16;a:4:{s:1:\"a\";i:17;s:1:\"b\";s:18:\"consultations.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:17;a:4:{s:1:\"a\";i:18;s:1:\"b\";s:20:\"consultations.create\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:18;a:4:{s:1:\"a\";i:19;s:1:\"b\";s:20:\"consultations.update\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:19;a:4:{s:1:\"a\";i:20;s:1:\"b\";s:17:\"dental-chart.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:20;a:4:{s:1:\"a\";i:21;s:1:\"b\";s:19:\"dental-chart.update\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:21;a:4:{s:1:\"a\";i:22;s:1:\"b\";s:15:\"treatments.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:22;a:4:{s:1:\"a\";i:23;s:1:\"b\";s:17:\"treatments.create\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:23;a:4:{s:1:\"a\";i:24;s:1:\"b\";s:17:\"treatments.update\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:24;a:4:{s:1:\"a\";i:25;s:1:\"b\";s:15:\"treatments.sign\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:25;a:4:{s:1:\"a\";i:26;s:1:\"b\";s:16:\"attachments.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:26;a:4:{s:1:\"a\";i:27;s:1:\"b\";s:18:\"attachments.upload\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:27;a:4:{s:1:\"a\";i:28;s:1:\"b\";s:18:\"attachments.delete\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:1:{i:0;i:1;}}i:28;a:4:{s:1:\"a\";i:29;s:1:\"b\";s:13:\"consents.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:29;a:4:{s:1:\"a\";i:30;s:1:\"b\";s:15:\"consents.create\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:30;a:4:{s:1:\"a\";i:31;s:1:\"b\";s:21:\"consents.sign-patient\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}i:31;a:4:{s:1:\"a\";i:32;s:1:\"b\";s:21:\"consents.sign-dentist\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:2:{i:0;i:1;i:1;i:2;}}i:32;a:4:{s:1:\"a\";i:33;s:1:\"b\";s:12:\"reports.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:1:{i:0;i:1;}}i:33;a:4:{s:1:\"a\";i:34;s:1:\"b\";s:13:\"settings.view\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:1:{i:0;i:1;}}i:34;a:4:{s:1:\"a\";i:35;s:1:\"b\";s:15:\"settings.update\";s:1:\"c\";s:3:\"web\";s:1:\"r\";a:1:{i:0;i:1;}}}s:5:\"roles\";a:3:{i:0;a:3:{s:1:\"a\";i:1;s:1:\"b\";s:13:\"Administrator\";s:1:\"c\";s:3:\"web\";}i:1;a:3:{s:1:\"a\";i:2;s:1:\"b\";s:7:\"Dentist\";s:1:\"c\";s:3:\"web\";}i:2;a:3:{s:1:\"a\";i:3;s:1:\"b\";s:9:\"Assistant\";s:1:\"c\";s:3:\"web\";}}}',1786357870);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `consent_forms`
--

DROP TABLE IF EXISTS `consent_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `consent_forms` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `version` varchar(10) NOT NULL DEFAULT '1.0',
  `consent_text` text NOT NULL,
  `patient_name` varchar(255) NOT NULL,
  `patient_signature_path` varchar(255) DEFAULT NULL,
  `guardian_name` varchar(255) DEFAULT NULL,
  `guardian_signature_path` varchar(255) DEFAULT NULL,
  `dentist_id` bigint(20) unsigned NOT NULL,
  `dentist_signature_path` varchar(255) DEFAULT NULL,
  `patient_signed_at` timestamp NULL DEFAULT NULL,
  `dentist_signed_at` timestamp NULL DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'unsigned',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `consent_forms_dentist_id_foreign` (`dentist_id`),
  KEY `consent_forms_patient_id_status_index` (`patient_id`,`status`),
  CONSTRAINT `consent_forms_dentist_id_foreign` FOREIGN KEY (`dentist_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `consent_forms_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consent_forms`
--

LOCK TABLES `consent_forms` WRITE;
/*!40000 ALTER TABLE `consent_forms` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `consent_forms` VALUES
(1,1,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','Maria Concepcion Dizon Santos','signatures/consents/1-demo-patient.svg',NULL,NULL,2,'signatures/consents/1-demo-dentist.svg','2026-07-15 01:40:00','2026-07-15 01:45:00','127.0.0.1','Seeder','signed','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(2,4,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','Antonio Cruz Bautista','signatures/consents/4-demo-patient.svg',NULL,NULL,2,NULL,'2026-06-20 05:30:00',NULL,'127.0.0.1','Seeder','patient_signed','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(3,7,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','Pedro Garcia',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,'unsigned','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(4,3,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','Angela Ramos Fernandez','signatures/consents/4-patient.svg','Elena Ramos','signatures/consents/4-guardian.svg',1,'signatures/consents/4-dentist.svg','2026-08-06 09:54:50','2026-08-09 06:28:43','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','signed','2026-08-06 09:47:19','2026-08-09 06:28:43'),
(5,6,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','Ramon Salazar Villanueva',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,'unsigned','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(6,8,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bautista Bernardo','signatures/consents/6-patient.svg',NULL,NULL,1,NULL,'2026-08-06 11:10:19',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','patient_signed','2026-08-06 11:10:12','2026-08-06 11:10:19'),
(7,8,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bautista Bernardo',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,'voided','2026-08-06 11:10:38','2026-08-06 11:25:02'),
(8,8,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bautista Bernardo',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,'voided','2026-08-06 11:25:02','2026-08-06 11:25:09'),
(9,8,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bautista Bernardo','signatures/consents/9-patient.svg',NULL,NULL,1,NULL,'2026-08-06 11:25:18',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','patient_signed','2026-08-06 11:25:09','2026-08-06 11:25:18'),
(10,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo','signatures/consents/10-patient.svg',NULL,NULL,1,NULL,'2026-08-06 14:07:18',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','patient_signed','2026-08-06 14:02:31','2026-08-06 14:07:18'),
(11,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo',NULL,NULL,NULL,2,NULL,NULL,NULL,NULL,NULL,'voided','2026-08-08 03:59:19','2026-08-08 04:41:41'),
(12,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,'voided','2026-08-08 04:02:41','2026-08-08 04:29:52'),
(13,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo','signatures/consents/13-patient.svg',NULL,NULL,1,NULL,'2026-08-08 04:10:42',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','voided','2026-08-08 04:10:11','2026-08-08 04:29:52'),
(14,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,'voided','2026-08-08 04:20:15','2026-08-08 04:29:52'),
(15,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo','signatures/consents/15-patient.svg',NULL,NULL,1,NULL,'2026-08-08 04:26:56',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','voided','2026-08-08 04:26:34','2026-08-08 04:29:52'),
(16,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo','signatures/consents/16-patient.svg',NULL,NULL,1,NULL,'2026-08-08 04:29:14',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','voided','2026-08-08 04:28:43','2026-08-08 04:29:52'),
(17,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo','signatures/consents/17-patient.svg',NULL,NULL,1,'signatures/consents/17-dentist.svg','2026-08-08 04:41:53','2026-08-08 04:42:29','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','signed','2026-08-08 04:41:41','2026-08-08 04:42:29'),
(19,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo','signatures/consents/19-patient.svg',NULL,NULL,1,'signatures/consents/19-dentist.svg','2026-08-08 08:52:21','2026-08-09 09:11:09','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','signed','2026-08-08 08:52:01','2026-08-09 09:11:09'),
(20,10,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','qwe wqe qweqwe','signatures/consents/20-patient.svg',NULL,NULL,1,NULL,'2026-08-08 12:38:21',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','patient_signed','2026-08-08 12:38:15','2026-08-08 12:38:21'),
(21,2,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','Juan Dela Cruz',NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,'voided','2026-08-09 05:54:10','2026-08-09 06:40:36'),
(22,3,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','Angela Ramos Fernandez','signatures/consents/22-patient.svg','Elena Ramos','signatures/consents/22-guardian.svg',1,'signatures/consents/22-dentist.svg','2026-08-09 06:28:14','2026-08-09 06:28:38','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','signed','2026-08-09 06:27:25','2026-08-09 06:28:38'),
(23,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo','signatures/consents/23-patient.svg',NULL,NULL,1,'signatures/consents/23-dentist.svg','2026-08-09 06:33:03','2026-08-09 09:11:06','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','signed','2026-08-09 06:32:55','2026-08-09 09:11:06'),
(24,2,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','Juan Dela Cruz','signatures/consents/24-patient.svg',NULL,NULL,2,NULL,'2026-08-09 06:40:40',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','patient_signed','2026-08-09 06:40:36','2026-08-09 06:40:40'),
(25,2,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','Juan Dela Cruz','signatures/consents/25-patient.svg',NULL,NULL,2,'signatures/consents/25-dentist.svg','2026-08-09 06:41:59','2026-08-09 06:42:45','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','signed','2026-08-09 06:41:55','2026-08-09 06:42:45'),
(26,9,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bernardo','signatures/consents/26-patient.svg',NULL,NULL,2,'signatures/consents/26-dentist.svg','2026-08-09 07:02:37','2026-08-09 09:11:03','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','signed','2026-08-09 07:02:33','2026-08-09 09:11:03'),
(28,8,'1.0','{\"acknowledgment\":\"I understand that dentistry is not an exact science and that no dentist can guarantee accurate results at all times.\",\"authorization\":\"I authorize the dentist and dental personnel to perform the necessary procedures and treatments.\",\"sections\":{\"treatment_to_be_done\":{\"label\":\"Treatment to be done\",\"text\":\"I understand and consent to the treatment proposed by the dentist.\"},\"drugs_and_medications\":{\"label\":\"Drugs and medications\",\"text\":\"I understand that medications may cause allergic reactions, including swelling, itching, vomiting, pain, and anaphylactic shock.\"},\"changes_in_treatment_plan\":{\"label\":\"Changes in treatment plan\",\"text\":\"I understand that changes in treatment may become necessary as new conditions are discovered during treatment.\"},\"radiographs\":{\"label\":\"Radiographs\",\"text\":\"I understand that radiographs may be necessary for diagnosis and treatment planning.\"},\"removal_of_teeth\":{\"label\":\"Removal of teeth\",\"text\":\"I understand the risks, alternatives, and possible complications associated with tooth extraction.\"},\"crowns_caps_and_bridges\":{\"label\":\"Crowns, caps, and bridges\",\"text\":\"I understand the risks, limitations, and responsibilities related to crowns, caps, and bridges.\"},\"endodontics\":{\"label\":\"Endodontics (root canal treatment)\",\"text\":\"I understand that root canal treatment does not guarantee that a tooth will be saved.\"},\"periodontal_disease\":{\"label\":\"Periodontal disease\",\"text\":\"I understand the risks associated with periodontal disease and its treatment.\"},\"fillings\":{\"label\":\"Fillings\",\"text\":\"I understand the risks associated with dental fillings.\"},\"dentures\":{\"label\":\"Dentures\",\"text\":\"I understand the possible complications and limitations associated with dentures.\"}}}','John Dennis Bautista Bernardo','signatures/consents/28-patient.svg',NULL,NULL,1,NULL,'2026-08-09 07:19:36',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','patient_signed','2026-08-09 07:19:25','2026-08-09 07:19:36');
/*!40000 ALTER TABLE `consent_forms` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `consent_sections`
--

DROP TABLE IF EXISTS `consent_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `consent_sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `consent_form_id` bigint(20) unsigned NOT NULL,
  `key` varchar(255) NOT NULL,
  `label` varchar(255) NOT NULL,
  `initial_svg_path` varchar(255) DEFAULT NULL,
  `initialed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `consent_sections_consent_form_id_key_unique` (`consent_form_id`,`key`),
  CONSTRAINT `consent_sections_consent_form_id_foreign` FOREIGN KEY (`consent_form_id`) REFERENCES `consent_forms` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=261 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consent_sections`
--

LOCK TABLES `consent_sections` WRITE;
/*!40000 ALTER TABLE `consent_sections` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `consent_sections` VALUES
(1,1,'treatment_to_be_done','Treatment to be done','signatures/consents/1-initial-treatment_to_be_done.svg','2026-07-15 01:35:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(2,1,'drugs_and_medications','Drugs and medications','signatures/consents/1-initial-drugs_and_medications.svg','2026-07-15 01:35:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(3,1,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/1-initial-changes_in_treatment_plan.svg','2026-07-15 01:35:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(4,1,'radiographs','Radiographs','signatures/consents/1-initial-radiographs.svg','2026-07-15 01:35:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(5,1,'removal_of_teeth','Removal of teeth','signatures/consents/1-initial-removal_of_teeth.svg','2026-07-15 01:35:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(6,1,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/1-initial-crowns_caps_and_bridges.svg','2026-07-15 01:35:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(7,1,'endodontics','Endodontics (root canal treatment)','signatures/consents/1-initial-endodontics.svg','2026-07-15 01:35:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(8,1,'periodontal_disease','Periodontal disease','signatures/consents/1-initial-periodontal_disease.svg','2026-07-15 01:35:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(9,1,'fillings','Fillings','signatures/consents/1-initial-fillings.svg','2026-07-15 01:35:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(10,1,'dentures','Dentures','signatures/consents/1-initial-dentures.svg','2026-07-15 01:35:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(11,3,'treatment_to_be_done','Treatment to be done','signatures/consents/3-initial-treatment_to_be_done.svg','2026-08-05 06:56:00','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(12,3,'drugs_and_medications','Drugs and medications','signatures/consents/3-initial-drugs_and_medications.svg','2026-08-05 06:56:00','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(13,3,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/3-initial-changes_in_treatment_plan.svg','2026-08-05 06:56:00','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(14,3,'radiographs','Radiographs','signatures/consents/3-initial-radiographs.svg','2026-08-05 06:56:00','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(15,3,'removal_of_teeth','Removal of teeth','signatures/consents/3-initial-removal_of_teeth.svg','2026-08-05 06:56:00','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(16,3,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/3-initial-crowns_caps_and_bridges.svg','2026-08-05 06:56:00','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(17,3,'endodontics','Endodontics (root canal treatment)','signatures/consents/3-initial-endodontics.svg','2026-08-05 06:56:00','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(18,3,'periodontal_disease','Periodontal disease','signatures/consents/3-initial-periodontal_disease.svg','2026-08-05 06:56:00','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(19,3,'fillings','Fillings','signatures/consents/3-initial-fillings.svg','2026-08-05 06:56:00','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(20,3,'dentures','Dentures','signatures/consents/3-initial-dentures.svg','2026-08-05 06:56:00','2026-08-05 06:56:00','2026-08-05 06:56:00'),
(21,4,'treatment_to_be_done','Treatment to be done','signatures/consents/4-initial-treatment_to_be_done.svg','2026-08-06 09:47:19','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(22,4,'drugs_and_medications','Drugs and medications','signatures/consents/4-initial-drugs_and_medications.svg','2026-08-06 09:47:19','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(23,4,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/4-initial-changes_in_treatment_plan.svg','2026-08-06 09:47:19','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(24,4,'radiographs','Radiographs','signatures/consents/4-initial-radiographs.svg','2026-08-06 09:47:19','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(25,4,'removal_of_teeth','Removal of teeth','signatures/consents/4-initial-removal_of_teeth.svg','2026-08-06 09:47:19','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(26,4,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/4-initial-crowns_caps_and_bridges.svg','2026-08-06 09:47:19','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(27,4,'endodontics','Endodontics (root canal treatment)','signatures/consents/4-initial-endodontics.svg','2026-08-06 09:47:19','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(28,4,'periodontal_disease','Periodontal disease','signatures/consents/4-initial-periodontal_disease.svg','2026-08-06 09:47:19','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(29,4,'fillings','Fillings','signatures/consents/4-initial-fillings.svg','2026-08-06 09:47:19','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(30,4,'dentures','Dentures','signatures/consents/4-initial-dentures.svg','2026-08-06 09:47:19','2026-08-06 09:47:19','2026-08-06 09:47:19'),
(31,5,'treatment_to_be_done','Treatment to be done','signatures/consents/5-initial-treatment_to_be_done.svg','2026-08-06 09:50:49','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(32,5,'drugs_and_medications','Drugs and medications','signatures/consents/5-initial-drugs_and_medications.svg','2026-08-06 09:50:49','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(33,5,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/5-initial-changes_in_treatment_plan.svg','2026-08-06 09:50:49','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(34,5,'radiographs','Radiographs','signatures/consents/5-initial-radiographs.svg','2026-08-06 09:50:49','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(35,5,'removal_of_teeth','Removal of teeth','signatures/consents/5-initial-removal_of_teeth.svg','2026-08-06 09:50:49','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(36,5,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/5-initial-crowns_caps_and_bridges.svg','2026-08-06 09:50:49','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(37,5,'endodontics','Endodontics (root canal treatment)','signatures/consents/5-initial-endodontics.svg','2026-08-06 09:50:49','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(38,5,'periodontal_disease','Periodontal disease','signatures/consents/5-initial-periodontal_disease.svg','2026-08-06 09:50:49','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(39,5,'fillings','Fillings','signatures/consents/5-initial-fillings.svg','2026-08-06 09:50:49','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(40,5,'dentures','Dentures','signatures/consents/5-initial-dentures.svg','2026-08-06 09:50:49','2026-08-06 09:50:49','2026-08-06 09:50:49'),
(41,6,'treatment_to_be_done','Treatment to be done','signatures/consents/6-initial-treatment_to_be_done.svg','2026-08-06 11:10:12','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(42,6,'drugs_and_medications','Drugs and medications','signatures/consents/6-initial-drugs_and_medications.svg','2026-08-06 11:10:12','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(43,6,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/6-initial-changes_in_treatment_plan.svg','2026-08-06 11:10:12','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(44,6,'radiographs','Radiographs','signatures/consents/6-initial-radiographs.svg','2026-08-06 11:10:12','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(45,6,'removal_of_teeth','Removal of teeth','signatures/consents/6-initial-removal_of_teeth.svg','2026-08-06 11:10:12','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(46,6,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/6-initial-crowns_caps_and_bridges.svg','2026-08-06 11:10:12','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(47,6,'endodontics','Endodontics (root canal treatment)','signatures/consents/6-initial-endodontics.svg','2026-08-06 11:10:12','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(48,6,'periodontal_disease','Periodontal disease','signatures/consents/6-initial-periodontal_disease.svg','2026-08-06 11:10:12','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(49,6,'fillings','Fillings','signatures/consents/6-initial-fillings.svg','2026-08-06 11:10:12','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(50,6,'dentures','Dentures','signatures/consents/6-initial-dentures.svg','2026-08-06 11:10:12','2026-08-06 11:10:12','2026-08-06 11:10:12'),
(51,7,'treatment_to_be_done','Treatment to be done','signatures/consents/7-initial-treatment_to_be_done.svg','2026-08-06 11:10:38','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(52,7,'drugs_and_medications','Drugs and medications','signatures/consents/7-initial-drugs_and_medications.svg','2026-08-06 11:10:38','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(53,7,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/7-initial-changes_in_treatment_plan.svg','2026-08-06 11:10:38','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(54,7,'radiographs','Radiographs','signatures/consents/7-initial-radiographs.svg','2026-08-06 11:10:38','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(55,7,'removal_of_teeth','Removal of teeth','signatures/consents/7-initial-removal_of_teeth.svg','2026-08-06 11:10:38','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(56,7,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/7-initial-crowns_caps_and_bridges.svg','2026-08-06 11:10:38','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(57,7,'endodontics','Endodontics (root canal treatment)','signatures/consents/7-initial-endodontics.svg','2026-08-06 11:10:38','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(58,7,'periodontal_disease','Periodontal disease','signatures/consents/7-initial-periodontal_disease.svg','2026-08-06 11:10:38','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(59,7,'fillings','Fillings','signatures/consents/7-initial-fillings.svg','2026-08-06 11:10:38','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(60,7,'dentures','Dentures','signatures/consents/7-initial-dentures.svg','2026-08-06 11:10:38','2026-08-06 11:10:38','2026-08-06 11:10:38'),
(61,8,'treatment_to_be_done','Treatment to be done',NULL,NULL,'2026-08-06 11:25:02','2026-08-06 11:25:02'),
(62,8,'drugs_and_medications','Drugs and medications',NULL,NULL,'2026-08-06 11:25:02','2026-08-06 11:25:02'),
(63,8,'changes_in_treatment_plan','Changes in treatment plan',NULL,NULL,'2026-08-06 11:25:02','2026-08-06 11:25:02'),
(64,8,'radiographs','Radiographs',NULL,NULL,'2026-08-06 11:25:02','2026-08-06 11:25:02'),
(65,8,'removal_of_teeth','Removal of teeth',NULL,NULL,'2026-08-06 11:25:02','2026-08-06 11:25:02'),
(66,8,'crowns_caps_and_bridges','Crowns, caps, and bridges',NULL,NULL,'2026-08-06 11:25:02','2026-08-06 11:25:02'),
(67,8,'endodontics','Endodontics (root canal treatment)',NULL,NULL,'2026-08-06 11:25:02','2026-08-06 11:25:02'),
(68,8,'periodontal_disease','Periodontal disease',NULL,NULL,'2026-08-06 11:25:02','2026-08-06 11:25:02'),
(69,8,'fillings','Fillings',NULL,NULL,'2026-08-06 11:25:02','2026-08-06 11:25:02'),
(70,8,'dentures','Dentures',NULL,NULL,'2026-08-06 11:25:02','2026-08-06 11:25:02'),
(71,9,'treatment_to_be_done','Treatment to be done','signatures/consents/9-initial-treatment_to_be_done.svg','2026-08-06 11:25:09','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(72,9,'drugs_and_medications','Drugs and medications','signatures/consents/9-initial-drugs_and_medications.svg','2026-08-06 11:25:09','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(73,9,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/9-initial-changes_in_treatment_plan.svg','2026-08-06 11:25:09','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(74,9,'radiographs','Radiographs','signatures/consents/9-initial-radiographs.svg','2026-08-06 11:25:09','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(75,9,'removal_of_teeth','Removal of teeth','signatures/consents/9-initial-removal_of_teeth.svg','2026-08-06 11:25:09','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(76,9,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/9-initial-crowns_caps_and_bridges.svg','2026-08-06 11:25:09','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(77,9,'endodontics','Endodontics (root canal treatment)','signatures/consents/9-initial-endodontics.svg','2026-08-06 11:25:09','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(78,9,'periodontal_disease','Periodontal disease','signatures/consents/9-initial-periodontal_disease.svg','2026-08-06 11:25:09','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(79,9,'fillings','Fillings','signatures/consents/9-initial-fillings.svg','2026-08-06 11:25:09','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(80,9,'dentures','Dentures','signatures/consents/9-initial-dentures.svg','2026-08-06 11:25:09','2026-08-06 11:25:09','2026-08-06 11:25:09'),
(81,10,'treatment_to_be_done','Treatment to be done','signatures/consents/10-initial-treatment_to_be_done.svg','2026-08-06 14:02:31','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(82,10,'drugs_and_medications','Drugs and medications','signatures/consents/10-initial-drugs_and_medications.svg','2026-08-06 14:02:31','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(83,10,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/10-initial-changes_in_treatment_plan.svg','2026-08-06 14:02:31','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(84,10,'radiographs','Radiographs','signatures/consents/10-initial-radiographs.svg','2026-08-06 14:02:31','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(85,10,'removal_of_teeth','Removal of teeth','signatures/consents/10-initial-removal_of_teeth.svg','2026-08-06 14:02:31','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(86,10,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/10-initial-crowns_caps_and_bridges.svg','2026-08-06 14:02:31','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(87,10,'endodontics','Endodontics (root canal treatment)','signatures/consents/10-initial-endodontics.svg','2026-08-06 14:02:31','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(88,10,'periodontal_disease','Periodontal disease','signatures/consents/10-initial-periodontal_disease.svg','2026-08-06 14:02:31','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(89,10,'fillings','Fillings','signatures/consents/10-initial-fillings.svg','2026-08-06 14:02:31','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(90,10,'dentures','Dentures','signatures/consents/10-initial-dentures.svg','2026-08-06 14:02:31','2026-08-06 14:02:31','2026-08-06 14:02:31'),
(91,11,'treatment_to_be_done','Treatment to be done','signatures/consents/11-initial-treatment_to_be_done.svg','2026-08-08 03:59:19','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(92,11,'drugs_and_medications','Drugs and medications','signatures/consents/11-initial-drugs_and_medications.svg','2026-08-08 03:59:19','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(93,11,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/11-initial-changes_in_treatment_plan.svg','2026-08-08 03:59:19','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(94,11,'radiographs','Radiographs','signatures/consents/11-initial-radiographs.svg','2026-08-08 03:59:19','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(95,11,'removal_of_teeth','Removal of teeth','signatures/consents/11-initial-removal_of_teeth.svg','2026-08-08 03:59:19','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(96,11,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/11-initial-crowns_caps_and_bridges.svg','2026-08-08 03:59:19','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(97,11,'endodontics','Endodontics (root canal treatment)','signatures/consents/11-initial-endodontics.svg','2026-08-08 03:59:19','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(98,11,'periodontal_disease','Periodontal disease','signatures/consents/11-initial-periodontal_disease.svg','2026-08-08 03:59:19','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(99,11,'fillings','Fillings','signatures/consents/11-initial-fillings.svg','2026-08-08 03:59:19','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(100,11,'dentures','Dentures','signatures/consents/11-initial-dentures.svg','2026-08-08 03:59:19','2026-08-08 03:59:19','2026-08-08 03:59:19'),
(101,12,'treatment_to_be_done','Treatment to be done',NULL,NULL,'2026-08-08 04:02:41','2026-08-08 04:02:41'),
(102,12,'drugs_and_medications','Drugs and medications',NULL,NULL,'2026-08-08 04:02:41','2026-08-08 04:02:41'),
(103,12,'changes_in_treatment_plan','Changes in treatment plan',NULL,NULL,'2026-08-08 04:02:41','2026-08-08 04:02:41'),
(104,12,'radiographs','Radiographs',NULL,NULL,'2026-08-08 04:02:41','2026-08-08 04:02:41'),
(105,12,'removal_of_teeth','Removal of teeth',NULL,NULL,'2026-08-08 04:02:41','2026-08-08 04:02:41'),
(106,12,'crowns_caps_and_bridges','Crowns, caps, and bridges',NULL,NULL,'2026-08-08 04:02:41','2026-08-08 04:02:41'),
(107,12,'endodontics','Endodontics (root canal treatment)',NULL,NULL,'2026-08-08 04:02:41','2026-08-08 04:02:41'),
(108,12,'periodontal_disease','Periodontal disease',NULL,NULL,'2026-08-08 04:02:41','2026-08-08 04:02:41'),
(109,12,'fillings','Fillings',NULL,NULL,'2026-08-08 04:02:41','2026-08-08 04:02:41'),
(110,12,'dentures','Dentures',NULL,NULL,'2026-08-08 04:02:41','2026-08-08 04:02:41'),
(111,13,'treatment_to_be_done','Treatment to be done','signatures/consents/13-initial-treatment_to_be_done.svg','2026-08-08 04:10:11','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(112,13,'drugs_and_medications','Drugs and medications','signatures/consents/13-initial-drugs_and_medications.svg','2026-08-08 04:10:11','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(113,13,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/13-initial-changes_in_treatment_plan.svg','2026-08-08 04:10:11','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(114,13,'radiographs','Radiographs','signatures/consents/13-initial-radiographs.svg','2026-08-08 04:10:11','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(115,13,'removal_of_teeth','Removal of teeth','signatures/consents/13-initial-removal_of_teeth.svg','2026-08-08 04:10:11','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(116,13,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/13-initial-crowns_caps_and_bridges.svg','2026-08-08 04:10:11','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(117,13,'endodontics','Endodontics (root canal treatment)','signatures/consents/13-initial-endodontics.svg','2026-08-08 04:10:11','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(118,13,'periodontal_disease','Periodontal disease','signatures/consents/13-initial-periodontal_disease.svg','2026-08-08 04:10:11','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(119,13,'fillings','Fillings','signatures/consents/13-initial-fillings.svg','2026-08-08 04:10:11','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(120,13,'dentures','Dentures','signatures/consents/13-initial-dentures.svg','2026-08-08 04:10:11','2026-08-08 04:10:11','2026-08-08 04:10:11'),
(121,14,'treatment_to_be_done','Treatment to be done','signatures/consents/14-initial-treatment_to_be_done.svg','2026-08-08 04:20:15','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(122,14,'drugs_and_medications','Drugs and medications','signatures/consents/14-initial-drugs_and_medications.svg','2026-08-08 04:20:15','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(123,14,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/14-initial-changes_in_treatment_plan.svg','2026-08-08 04:20:15','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(124,14,'radiographs','Radiographs','signatures/consents/14-initial-radiographs.svg','2026-08-08 04:20:15','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(125,14,'removal_of_teeth','Removal of teeth','signatures/consents/14-initial-removal_of_teeth.svg','2026-08-08 04:20:15','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(126,14,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/14-initial-crowns_caps_and_bridges.svg','2026-08-08 04:20:15','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(127,14,'endodontics','Endodontics (root canal treatment)','signatures/consents/14-initial-endodontics.svg','2026-08-08 04:20:15','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(128,14,'periodontal_disease','Periodontal disease','signatures/consents/14-initial-periodontal_disease.svg','2026-08-08 04:20:15','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(129,14,'fillings','Fillings','signatures/consents/14-initial-fillings.svg','2026-08-08 04:20:15','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(130,14,'dentures','Dentures','signatures/consents/14-initial-dentures.svg','2026-08-08 04:20:15','2026-08-08 04:20:15','2026-08-08 04:20:15'),
(131,15,'treatment_to_be_done','Treatment to be done','signatures/consents/15-initial-treatment_to_be_done.svg','2026-08-08 04:26:34','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(132,15,'drugs_and_medications','Drugs and medications','signatures/consents/15-initial-drugs_and_medications.svg','2026-08-08 04:26:34','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(133,15,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/15-initial-changes_in_treatment_plan.svg','2026-08-08 04:26:34','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(134,15,'radiographs','Radiographs','signatures/consents/15-initial-radiographs.svg','2026-08-08 04:26:34','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(135,15,'removal_of_teeth','Removal of teeth','signatures/consents/15-initial-removal_of_teeth.svg','2026-08-08 04:26:34','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(136,15,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/15-initial-crowns_caps_and_bridges.svg','2026-08-08 04:26:34','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(137,15,'endodontics','Endodontics (root canal treatment)','signatures/consents/15-initial-endodontics.svg','2026-08-08 04:26:34','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(138,15,'periodontal_disease','Periodontal disease','signatures/consents/15-initial-periodontal_disease.svg','2026-08-08 04:26:34','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(139,15,'fillings','Fillings','signatures/consents/15-initial-fillings.svg','2026-08-08 04:26:34','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(140,15,'dentures','Dentures','signatures/consents/15-initial-dentures.svg','2026-08-08 04:26:34','2026-08-08 04:26:34','2026-08-08 04:26:34'),
(141,16,'treatment_to_be_done','Treatment to be done','signatures/consents/16-initial-treatment_to_be_done.svg','2026-08-08 04:28:43','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(142,16,'drugs_and_medications','Drugs and medications','signatures/consents/16-initial-drugs_and_medications.svg','2026-08-08 04:28:43','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(143,16,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/16-initial-changes_in_treatment_plan.svg','2026-08-08 04:28:43','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(144,16,'radiographs','Radiographs','signatures/consents/16-initial-radiographs.svg','2026-08-08 04:28:43','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(145,16,'removal_of_teeth','Removal of teeth','signatures/consents/16-initial-removal_of_teeth.svg','2026-08-08 04:28:43','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(146,16,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/16-initial-crowns_caps_and_bridges.svg','2026-08-08 04:28:43','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(147,16,'endodontics','Endodontics (root canal treatment)','signatures/consents/16-initial-endodontics.svg','2026-08-08 04:28:43','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(148,16,'periodontal_disease','Periodontal disease','signatures/consents/16-initial-periodontal_disease.svg','2026-08-08 04:28:43','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(149,16,'fillings','Fillings','signatures/consents/16-initial-fillings.svg','2026-08-08 04:28:43','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(150,16,'dentures','Dentures','signatures/consents/16-initial-dentures.svg','2026-08-08 04:28:43','2026-08-08 04:28:43','2026-08-08 04:28:43'),
(151,17,'treatment_to_be_done','Treatment to be done','signatures/consents/17-initial-treatment_to_be_done.svg','2026-08-08 04:41:41','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(152,17,'drugs_and_medications','Drugs and medications','signatures/consents/17-initial-drugs_and_medications.svg','2026-08-08 04:41:41','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(153,17,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/17-initial-changes_in_treatment_plan.svg','2026-08-08 04:41:41','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(154,17,'radiographs','Radiographs','signatures/consents/17-initial-radiographs.svg','2026-08-08 04:41:41','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(155,17,'removal_of_teeth','Removal of teeth','signatures/consents/17-initial-removal_of_teeth.svg','2026-08-08 04:41:41','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(156,17,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/17-initial-crowns_caps_and_bridges.svg','2026-08-08 04:41:41','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(157,17,'endodontics','Endodontics (root canal treatment)','signatures/consents/17-initial-endodontics.svg','2026-08-08 04:41:41','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(158,17,'periodontal_disease','Periodontal disease','signatures/consents/17-initial-periodontal_disease.svg','2026-08-08 04:41:41','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(159,17,'fillings','Fillings','signatures/consents/17-initial-fillings.svg','2026-08-08 04:41:41','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(160,17,'dentures','Dentures','signatures/consents/17-initial-dentures.svg','2026-08-08 04:41:41','2026-08-08 04:41:41','2026-08-08 04:41:41'),
(171,19,'treatment_to_be_done','Treatment to be done','signatures/consents/19-initial-treatment_to_be_done.svg','2026-08-08 08:52:01','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(172,19,'drugs_and_medications','Drugs and medications','signatures/consents/19-initial-drugs_and_medications.svg','2026-08-08 08:52:01','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(173,19,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/19-initial-changes_in_treatment_plan.svg','2026-08-08 08:52:01','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(174,19,'radiographs','Radiographs','signatures/consents/19-initial-radiographs.svg','2026-08-08 08:52:01','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(175,19,'removal_of_teeth','Removal of teeth','signatures/consents/19-initial-removal_of_teeth.svg','2026-08-08 08:52:01','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(176,19,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/19-initial-crowns_caps_and_bridges.svg','2026-08-08 08:52:01','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(177,19,'endodontics','Endodontics (root canal treatment)','signatures/consents/19-initial-endodontics.svg','2026-08-08 08:52:01','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(178,19,'periodontal_disease','Periodontal disease','signatures/consents/19-initial-periodontal_disease.svg','2026-08-08 08:52:01','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(179,19,'fillings','Fillings','signatures/consents/19-initial-fillings.svg','2026-08-08 08:52:01','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(180,19,'dentures','Dentures','signatures/consents/19-initial-dentures.svg','2026-08-08 08:52:01','2026-08-08 08:52:01','2026-08-08 08:52:01'),
(181,20,'treatment_to_be_done','Treatment to be done','signatures/consents/20-initial-treatment_to_be_done.svg','2026-08-08 12:38:15','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(182,20,'drugs_and_medications','Drugs and medications','signatures/consents/20-initial-drugs_and_medications.svg','2026-08-08 12:38:15','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(183,20,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/20-initial-changes_in_treatment_plan.svg','2026-08-08 12:38:15','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(184,20,'radiographs','Radiographs','signatures/consents/20-initial-radiographs.svg','2026-08-08 12:38:15','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(185,20,'removal_of_teeth','Removal of teeth','signatures/consents/20-initial-removal_of_teeth.svg','2026-08-08 12:38:15','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(186,20,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/20-initial-crowns_caps_and_bridges.svg','2026-08-08 12:38:15','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(187,20,'endodontics','Endodontics (root canal treatment)','signatures/consents/20-initial-endodontics.svg','2026-08-08 12:38:15','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(188,20,'periodontal_disease','Periodontal disease','signatures/consents/20-initial-periodontal_disease.svg','2026-08-08 12:38:15','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(189,20,'fillings','Fillings','signatures/consents/20-initial-fillings.svg','2026-08-08 12:38:15','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(190,20,'dentures','Dentures','signatures/consents/20-initial-dentures.svg','2026-08-08 12:38:15','2026-08-08 12:38:15','2026-08-08 12:38:15'),
(191,21,'treatment_to_be_done','Treatment to be done','signatures/consents/21-initial-treatment_to_be_done.svg','2026-08-09 05:54:10','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(192,21,'drugs_and_medications','Drugs and medications','signatures/consents/21-initial-drugs_and_medications.svg','2026-08-09 05:54:10','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(193,21,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/21-initial-changes_in_treatment_plan.svg','2026-08-09 05:54:10','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(194,21,'radiographs','Radiographs','signatures/consents/21-initial-radiographs.svg','2026-08-09 05:54:10','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(195,21,'removal_of_teeth','Removal of teeth','signatures/consents/21-initial-removal_of_teeth.svg','2026-08-09 05:54:10','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(196,21,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/21-initial-crowns_caps_and_bridges.svg','2026-08-09 05:54:10','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(197,21,'endodontics','Endodontics (root canal treatment)','signatures/consents/21-initial-endodontics.svg','2026-08-09 05:54:10','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(198,21,'periodontal_disease','Periodontal disease','signatures/consents/21-initial-periodontal_disease.svg','2026-08-09 05:54:10','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(199,21,'fillings','Fillings','signatures/consents/21-initial-fillings.svg','2026-08-09 05:54:10','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(200,21,'dentures','Dentures','signatures/consents/21-initial-dentures.svg','2026-08-09 05:54:10','2026-08-09 05:54:10','2026-08-09 05:54:10'),
(201,22,'treatment_to_be_done','Treatment to be done','signatures/consents/22-initial-treatment_to_be_done.svg','2026-08-09 06:27:25','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(202,22,'drugs_and_medications','Drugs and medications','signatures/consents/22-initial-drugs_and_medications.svg','2026-08-09 06:27:25','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(203,22,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/22-initial-changes_in_treatment_plan.svg','2026-08-09 06:27:25','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(204,22,'radiographs','Radiographs','signatures/consents/22-initial-radiographs.svg','2026-08-09 06:27:25','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(205,22,'removal_of_teeth','Removal of teeth','signatures/consents/22-initial-removal_of_teeth.svg','2026-08-09 06:27:25','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(206,22,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/22-initial-crowns_caps_and_bridges.svg','2026-08-09 06:27:25','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(207,22,'endodontics','Endodontics (root canal treatment)','signatures/consents/22-initial-endodontics.svg','2026-08-09 06:27:25','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(208,22,'periodontal_disease','Periodontal disease','signatures/consents/22-initial-periodontal_disease.svg','2026-08-09 06:27:25','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(209,22,'fillings','Fillings','signatures/consents/22-initial-fillings.svg','2026-08-09 06:27:25','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(210,22,'dentures','Dentures','signatures/consents/22-initial-dentures.svg','2026-08-09 06:27:25','2026-08-09 06:27:25','2026-08-09 06:27:25'),
(211,23,'treatment_to_be_done','Treatment to be done','signatures/consents/23-initial-treatment_to_be_done.svg','2026-08-09 06:32:55','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(212,23,'drugs_and_medications','Drugs and medications','signatures/consents/23-initial-drugs_and_medications.svg','2026-08-09 06:32:55','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(213,23,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/23-initial-changes_in_treatment_plan.svg','2026-08-09 06:32:55','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(214,23,'radiographs','Radiographs','signatures/consents/23-initial-radiographs.svg','2026-08-09 06:32:55','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(215,23,'removal_of_teeth','Removal of teeth','signatures/consents/23-initial-removal_of_teeth.svg','2026-08-09 06:32:55','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(216,23,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/23-initial-crowns_caps_and_bridges.svg','2026-08-09 06:32:55','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(217,23,'endodontics','Endodontics (root canal treatment)','signatures/consents/23-initial-endodontics.svg','2026-08-09 06:32:55','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(218,23,'periodontal_disease','Periodontal disease','signatures/consents/23-initial-periodontal_disease.svg','2026-08-09 06:32:55','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(219,23,'fillings','Fillings','signatures/consents/23-initial-fillings.svg','2026-08-09 06:32:55','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(220,23,'dentures','Dentures','signatures/consents/23-initial-dentures.svg','2026-08-09 06:32:55','2026-08-09 06:32:55','2026-08-09 06:32:55'),
(221,24,'treatment_to_be_done','Treatment to be done','signatures/consents/24-initial-treatment_to_be_done.svg','2026-08-09 06:40:36','2026-08-09 06:40:36','2026-08-09 06:40:36'),
(222,24,'drugs_and_medications','Drugs and medications','signatures/consents/24-initial-drugs_and_medications.svg','2026-08-09 06:40:36','2026-08-09 06:40:36','2026-08-09 06:40:36'),
(223,24,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/24-initial-changes_in_treatment_plan.svg','2026-08-09 06:40:36','2026-08-09 06:40:36','2026-08-09 06:40:36'),
(224,24,'radiographs','Radiographs','signatures/consents/24-initial-radiographs.svg','2026-08-09 06:40:36','2026-08-09 06:40:36','2026-08-09 06:40:36'),
(225,24,'removal_of_teeth','Removal of teeth','signatures/consents/24-initial-removal_of_teeth.svg','2026-08-09 06:40:36','2026-08-09 06:40:36','2026-08-09 06:40:36'),
(226,24,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/24-initial-crowns_caps_and_bridges.svg','2026-08-09 06:40:36','2026-08-09 06:40:36','2026-08-09 06:40:36'),
(227,24,'endodontics','Endodontics (root canal treatment)','signatures/consents/24-initial-endodontics.svg','2026-08-09 06:40:36','2026-08-09 06:40:36','2026-08-09 06:40:36'),
(228,24,'periodontal_disease','Periodontal disease','signatures/consents/24-initial-periodontal_disease.svg','2026-08-09 06:40:36','2026-08-09 06:40:36','2026-08-09 06:40:36'),
(229,24,'fillings','Fillings','signatures/consents/24-initial-fillings.svg','2026-08-09 06:40:37','2026-08-09 06:40:36','2026-08-09 06:40:37'),
(230,24,'dentures','Dentures','signatures/consents/24-initial-dentures.svg','2026-08-09 06:40:37','2026-08-09 06:40:36','2026-08-09 06:40:37'),
(231,25,'treatment_to_be_done','Treatment to be done','signatures/consents/25-initial-treatment_to_be_done.svg','2026-08-09 06:41:55','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(232,25,'drugs_and_medications','Drugs and medications','signatures/consents/25-initial-drugs_and_medications.svg','2026-08-09 06:41:55','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(233,25,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/25-initial-changes_in_treatment_plan.svg','2026-08-09 06:41:55','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(234,25,'radiographs','Radiographs','signatures/consents/25-initial-radiographs.svg','2026-08-09 06:41:55','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(235,25,'removal_of_teeth','Removal of teeth','signatures/consents/25-initial-removal_of_teeth.svg','2026-08-09 06:41:55','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(236,25,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/25-initial-crowns_caps_and_bridges.svg','2026-08-09 06:41:55','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(237,25,'endodontics','Endodontics (root canal treatment)','signatures/consents/25-initial-endodontics.svg','2026-08-09 06:41:55','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(238,25,'periodontal_disease','Periodontal disease','signatures/consents/25-initial-periodontal_disease.svg','2026-08-09 06:41:55','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(239,25,'fillings','Fillings','signatures/consents/25-initial-fillings.svg','2026-08-09 06:41:55','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(240,25,'dentures','Dentures','signatures/consents/25-initial-dentures.svg','2026-08-09 06:41:55','2026-08-09 06:41:55','2026-08-09 06:41:55'),
(241,26,'treatment_to_be_done','Treatment to be done','signatures/consents/26-initial-treatment_to_be_done.svg','2026-08-09 07:02:33','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(242,26,'drugs_and_medications','Drugs and medications','signatures/consents/26-initial-drugs_and_medications.svg','2026-08-09 07:02:33','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(243,26,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/26-initial-changes_in_treatment_plan.svg','2026-08-09 07:02:33','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(244,26,'radiographs','Radiographs','signatures/consents/26-initial-radiographs.svg','2026-08-09 07:02:33','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(245,26,'removal_of_teeth','Removal of teeth','signatures/consents/26-initial-removal_of_teeth.svg','2026-08-09 07:02:33','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(246,26,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/26-initial-crowns_caps_and_bridges.svg','2026-08-09 07:02:33','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(247,26,'endodontics','Endodontics (root canal treatment)','signatures/consents/26-initial-endodontics.svg','2026-08-09 07:02:33','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(248,26,'periodontal_disease','Periodontal disease','signatures/consents/26-initial-periodontal_disease.svg','2026-08-09 07:02:33','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(249,26,'fillings','Fillings','signatures/consents/26-initial-fillings.svg','2026-08-09 07:02:33','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(250,26,'dentures','Dentures','signatures/consents/26-initial-dentures.svg','2026-08-09 07:02:33','2026-08-09 07:02:33','2026-08-09 07:02:33'),
(251,28,'treatment_to_be_done','Treatment to be done','signatures/consents/28-initial-treatment_to_be_done.svg','2026-08-09 07:19:25','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(252,28,'drugs_and_medications','Drugs and medications','signatures/consents/28-initial-drugs_and_medications.svg','2026-08-09 07:19:25','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(253,28,'changes_in_treatment_plan','Changes in treatment plan','signatures/consents/28-initial-changes_in_treatment_plan.svg','2026-08-09 07:19:25','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(254,28,'radiographs','Radiographs','signatures/consents/28-initial-radiographs.svg','2026-08-09 07:19:25','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(255,28,'removal_of_teeth','Removal of teeth','signatures/consents/28-initial-removal_of_teeth.svg','2026-08-09 07:19:25','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(256,28,'crowns_caps_and_bridges','Crowns, caps, and bridges','signatures/consents/28-initial-crowns_caps_and_bridges.svg','2026-08-09 07:19:25','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(257,28,'endodontics','Endodontics (root canal treatment)','signatures/consents/28-initial-endodontics.svg','2026-08-09 07:19:25','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(258,28,'periodontal_disease','Periodontal disease','signatures/consents/28-initial-periodontal_disease.svg','2026-08-09 07:19:25','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(259,28,'fillings','Fillings','signatures/consents/28-initial-fillings.svg','2026-08-09 07:19:25','2026-08-09 07:19:25','2026-08-09 07:19:25'),
(260,28,'dentures','Dentures','signatures/consents/28-initial-dentures.svg','2026-08-09 07:19:25','2026-08-09 07:19:25','2026-08-09 07:19:25');
/*!40000 ALTER TABLE `consent_sections` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `consultations`
--

DROP TABLE IF EXISTS `consultations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `consultations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `dentist_id` bigint(20) unsigned NOT NULL,
  `consultation_date` date NOT NULL,
  `chief_complaint` text NOT NULL,
  `examination_findings` text DEFAULT NULL,
  `diagnosis` text DEFAULT NULL,
  `treatment_plan` text DEFAULT NULL,
  `recommendations` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `periodontal_screening` varchar(255) DEFAULT NULL,
  `occlusion_class` varchar(255) DEFAULT NULL,
  `overjet` varchar(255) DEFAULT NULL,
  `overbite` varchar(255) DEFAULT NULL,
  `midline_deviation` varchar(255) DEFAULT NULL,
  `crossbite` varchar(255) DEFAULT NULL,
  `appliances` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`appliances`)),
  `tmd_findings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tmd_findings`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `consultations_dentist_id_foreign` (`dentist_id`),
  KEY `consultations_patient_id_consultation_date_index` (`patient_id`,`consultation_date`),
  CONSTRAINT `consultations_dentist_id_foreign` FOREIGN KEY (`dentist_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `consultations_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consultations`
--

LOCK TABLES `consultations` WRITE;
/*!40000 ALTER TABLE `consultations` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `consultations` VALUES
(1,1,2,'2026-07-15','Pain when biting on the upper left molar for the past two weeks.','Deep occlusal caries on 26 with tenderness to percussion; mild generalized gingivitis; teeth 16 and 46 healthy.','Dental caries (moderate) — tooth 26; gingivitis.','Composite restoration on 26; scaling and polishing; oral hygiene instructions.','Avoid hard foods for 24 hours after restoration; schedule a 6-month recall.',NULL,'gingivitis','class_i','2mm','1mm',NULL,NULL,'[\"orthodontic\"]','[\"clicking\"]','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(2,4,2,'2026-06-20','Bleeding gums and loose lower front teeth.','Generalized moderate periodontitis with heavy calculus deposits; tooth 31 missing (other causes); deep pockets on lower anteriors.','Moderate periodontitis.','Full-mouth scaling and polishing; review in 3 months; possible periodontal maintenance program.','Quarterly prophylaxis; coordinate with cardiologist Dr. Lim before any surgical procedure.',NULL,'moderate_periodontitis','class_ii','3mm','2mm','1mm to the right',NULL,'[\"stayplate\"]','[\"clenching\",\"muscle_spasm\"]','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(3,3,2,'2026-07-28','Decayed upper baby tooth (parent concern).','Occlusal caries on 55; tooth 65 unerupted; healthy gingiva.','Dental caries — tooth 55 (primary dentition).','Composite filling on 55; fluoride varnish application.','Parent to assist brushing twice daily; limit sugary snacks and drinks.',NULL,NULL,'class_i','2mm','1mm',NULL,NULL,NULL,NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(4,3,1,'2026-08-06','adcdsdf',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-06 09:55:02','2026-08-06 09:55:02'),
(5,8,1,'2026-08-06','asdasd',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-06 11:24:48','2026-08-06 11:24:48'),
(6,8,1,'2026-08-06','ghgfhgfhgfh',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-06 11:25:26','2026-08-06 11:25:26'),
(7,1,2,'2026-08-07','qweqwe',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-06 11:49:26','2026-08-06 11:49:26'),
(20,9,1,'2026-08-06','tooth extraction',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-06 14:07:38','2026-08-06 14:07:38'),
(21,9,1,'2026-08-06','test',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-06 14:08:28','2026-08-06 14:08:28'),
(22,9,1,'2026-08-08','qweqwe',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[\"clicking\",\"trismus\"]','2026-08-08 04:42:01','2026-08-08 04:42:01'),
(23,10,1,'2026-08-08','qwe',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-08 12:38:29','2026-08-08 12:38:29'),
(24,3,1,'2026-08-09','qweqwe',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-09 06:28:21','2026-08-09 06:28:21'),
(25,2,2,'2026-08-09','test',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-09 06:40:48','2026-08-09 06:40:48'),
(26,2,2,'2026-08-09','this is  new',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-09 06:42:11','2026-08-09 06:42:11'),
(27,10,2,'2026-08-09','qweqwe',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-09 06:44:23','2026-08-09 06:44:23'),
(28,9,2,'2026-08-09','crooked','test findings','test diagnosis','treatment 1','need to have braces',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]','[]','2026-08-09 07:01:09','2026-08-09 07:01:09'),
(29,10,1,'2026-08-09','testing','test','test','test','test','immediately','gingivitis','class_i','2mm','2mm','test','test','[\"orthodontic\"]','[\"trismus\"]','2026-08-09 08:01:13','2026-08-09 08:01:13');
/*!40000 ALTER TABLE `consultations` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `dental_chart_entries`
--

DROP TABLE IF EXISTS `dental_chart_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dental_chart_entries` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `tooth_number` tinyint(3) unsigned NOT NULL,
  `dentition` varchar(255) NOT NULL DEFAULT 'adult',
  `condition` varchar(255) NOT NULL,
  `restoration_type` varchar(255) DEFAULT NULL,
  `surface` varchar(255) DEFAULT NULL,
  `color_code` varchar(32) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `recorded_at` date NOT NULL,
  `recorded_by` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dental_chart_entries_recorded_by_foreign` (`recorded_by`),
  KEY `dental_chart_entries_patient_tooth_surface_date_idx` (`patient_id`,`tooth_number`,`surface`,`recorded_at`),
  CONSTRAINT `dental_chart_entries_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `dental_chart_entries_recorded_by_foreign` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dental_chart_entries`
--

LOCK TABLES `dental_chart_entries` WRITE;
/*!40000 ALTER TABLE `dental_chart_entries` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `dental_chart_entries` VALUES
(1,1,16,'adult','caries',NULL,'occlusal','cond-caries','Occlusal caries noted on examination','2026-07-10',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(2,1,26,'adult','present','filling_composite',NULL,'cond-present','Composite restoration placed','2026-07-10',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(3,1,36,'adult','missing_caries',NULL,NULL,'cond-missing-caries','Extracted due to caries (2025)','2026-06-01',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(4,1,46,'adult','present',NULL,NULL,'cond-present',NULL,'2026-07-10',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(5,3,55,'primary','caries',NULL,'occlusal','cond-caries',NULL,'2026-07-28',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(6,3,65,'primary','unerupted',NULL,NULL,'cond-unerupted',NULL,'2026-07-28',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(7,2,11,'adult','present',NULL,NULL,'cond-present',NULL,'2026-06-15',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(8,2,12,'adult','present','crown',NULL,'cond-present','Porcelain jacket crown','2026-06-15',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(9,2,21,'adult','root_fragment',NULL,NULL,'cond-root-fragment',NULL,'2026-06-15',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(10,2,47,'adult','impacted',NULL,NULL,'cond-impacted',NULL,'2026-06-15',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(11,4,31,'adult','missing_other',NULL,NULL,'cond-missing-other',NULL,'2026-05-20',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(12,4,44,'adult','present','filling_amalgam','occlusal','cond-present','Amalgam filling (old)','2026-05-20',2,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(13,1,26,'adult','caries',NULL,'occlusal','cond-caries',NULL,'2026-08-05',1,'2026-08-05 06:28:41','2026-08-05 06:28:41'),
(14,1,43,'adult','caries',NULL,'occlusal','cond-caries',NULL,'2026-08-05',2,'2026-08-05 06:45:53','2026-08-05 06:45:53'),
(15,1,41,'adult','caries',NULL,'distal','cond-caries',NULL,'2026-08-05',2,'2026-08-05 06:45:55','2026-08-05 06:45:55'),
(16,1,33,'adult','missing_other',NULL,NULL,'cond-missing-other',NULL,'2026-08-05',2,'2026-08-05 06:45:58','2026-08-05 06:45:58'),
(17,3,15,'adult','caries',NULL,'occlusal','cond-caries',NULL,'2026-08-06',1,'2026-08-06 09:55:20','2026-08-06 09:55:20'),
(18,3,14,'adult','caries',NULL,'occlusal','cond-caries',NULL,'2026-08-06',1,'2026-08-06 09:55:21','2026-08-06 09:55:21'),
(19,3,13,'adult','caries',NULL,'mesial','cond-caries',NULL,'2026-08-06',1,'2026-08-06 09:55:34','2026-08-06 09:55:34'),
(20,3,21,'adult','impacted',NULL,NULL,'cond-impacted',NULL,'2026-08-06',1,'2026-08-06 09:55:39','2026-08-06 09:55:39'),
(21,3,45,'adult','present','filling_amalgam','occlusal','cond-present',NULL,'2026-08-06',1,'2026-08-06 09:55:42','2026-08-06 09:55:42'),
(22,3,44,'adult','present','filling_amalgam','buccal','cond-present',NULL,'2026-08-06',1,'2026-08-06 09:55:43','2026-08-06 09:55:43'),
(23,3,42,'adult','present','inlay','distal','cond-present',NULL,'2026-08-06',1,'2026-08-06 09:55:45','2026-08-06 09:55:45'),
(24,3,31,'adult','present','inlay','occlusal','cond-present',NULL,'2026-08-06',1,'2026-08-06 09:55:47','2026-08-06 09:55:47'),
(25,3,33,'adult','present','implant',NULL,'cond-present',NULL,'2026-08-06',1,'2026-08-06 09:55:49','2026-08-06 09:55:49'),
(26,3,35,'adult','present','removable_denture','occlusal','cond-present',NULL,'2026-08-06',1,'2026-08-06 09:55:52','2026-08-06 09:55:52'),
(27,3,36,'adult','present','removable_denture','distal','cond-present',NULL,'2026-08-06',1,'2026-08-06 09:55:52','2026-08-06 09:55:52'),
(28,3,48,'adult','present','pontic',NULL,'cond-present',NULL,'2026-08-06',1,'2026-08-06 09:55:58','2026-08-06 09:55:58'),
(29,3,47,'adult','present','pontic','buccal','cond-present',NULL,'2026-08-06',1,'2026-08-06 09:56:01','2026-08-06 09:56:01'),
(30,9,46,'adult','missing_other',NULL,NULL,'cond-missing-other',NULL,'2026-08-06',1,'2026-08-06 14:07:53','2026-08-06 14:07:53'),
(31,9,35,'adult','missing_other',NULL,NULL,'cond-missing-other',NULL,'2026-08-06',1,'2026-08-06 14:07:54','2026-08-06 14:07:54'),
(32,10,14,'adult','caries',NULL,'buccal','cond-caries',NULL,'2026-08-08',1,'2026-08-08 12:38:37','2026-08-08 12:38:37'),
(33,10,13,'adult','caries',NULL,'buccal','cond-caries',NULL,'2026-08-08',1,'2026-08-08 12:38:40','2026-08-08 12:38:40'),
(34,10,12,'adult','caries',NULL,'lingual','cond-caries',NULL,'2026-08-08',1,'2026-08-08 12:38:42','2026-08-08 12:38:42'),
(35,10,11,'adult','caries',NULL,'occlusal','cond-caries',NULL,'2026-08-08',1,'2026-08-08 12:38:44','2026-08-08 12:38:44'),
(36,10,46,'adult','present',NULL,'mesial','cond-present',NULL,'2026-08-08',1,'2026-08-08 12:38:58','2026-08-08 12:38:58'),
(37,10,23,'adult','present',NULL,NULL,'cond-present',NULL,'2026-08-08',1,'2026-08-08 12:39:24','2026-08-08 12:39:24'),
(41,9,42,'adult','caries',NULL,'lingual','cond-caries',NULL,'2026-08-08',1,'2026-08-08 18:23:17','2026-08-08 18:23:17'),
(42,9,41,'adult','caries',NULL,'occlusal','cond-caries',NULL,'2026-08-08',1,'2026-08-08 18:23:21','2026-08-08 18:23:21'),
(43,9,31,'adult','caries',NULL,NULL,'cond-caries',NULL,'2026-08-08',1,'2026-08-08 18:23:32','2026-08-08 18:23:32'),
(44,8,16,'adult','caries',NULL,NULL,'cond-caries',NULL,'2026-08-09',1,'2026-08-09 04:20:08','2026-08-09 04:20:08'),
(45,8,15,'adult','missing_caries',NULL,NULL,'cond-missing-caries',NULL,'2026-08-09',1,'2026-08-09 04:20:13','2026-08-09 04:20:13'),
(46,8,14,'adult','missing_caries',NULL,NULL,'cond-missing-caries',NULL,'2026-08-09',1,'2026-08-09 04:20:14','2026-08-09 04:20:14'),
(47,8,26,'adult','impacted',NULL,NULL,'cond-impacted',NULL,'2026-08-09',1,'2026-08-09 04:20:21','2026-08-09 04:20:21'),
(48,8,27,'adult','impacted',NULL,NULL,'cond-impacted',NULL,'2026-08-09',1,'2026-08-09 04:20:22','2026-08-09 04:20:22'),
(49,8,11,'adult','present','crown',NULL,'cond-present',NULL,'2026-08-09',1,'2026-08-09 04:20:28','2026-08-09 04:20:28'),
(50,8,21,'adult','present','crown',NULL,'cond-present',NULL,'2026-08-09',1,'2026-08-09 04:20:30','2026-08-09 04:20:30'),
(51,8,32,'adult','present','abutment',NULL,'cond-present',NULL,'2026-08-09',1,'2026-08-09 04:20:35','2026-08-09 04:20:35'),
(52,8,36,'adult','present','pontic',NULL,'cond-present',NULL,'2026-08-09',1,'2026-08-09 04:20:39','2026-08-09 04:20:39'),
(53,8,41,'adult','present','removable_denture',NULL,'cond-present',NULL,'2026-08-09',1,'2026-08-09 04:20:44','2026-08-09 04:20:44');
/*!40000 ALTER TABLE `dental_chart_entries` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `medical_histories`
--

DROP TABLE IF EXISTS `medical_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `medical_histories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `hypertension` varchar(255) NOT NULL DEFAULT 'no',
  `diabetes` varchar(255) NOT NULL DEFAULT 'no',
  `tuberculosis` varchar(255) NOT NULL DEFAULT 'no',
  `heart_disease` varchar(255) NOT NULL DEFAULT 'no',
  `pregnancy` varchar(255) NOT NULL DEFAULT 'no',
  `allergies` varchar(255) NOT NULL DEFAULT 'no',
  `medications` varchar(255) NOT NULL DEFAULT 'no',
  `smoking_history` varchar(255) NOT NULL DEFAULT 'no',
  `alcohol_consumption` varchar(255) NOT NULL DEFAULT 'no',
  `previous_surgeries` varchar(255) NOT NULL DEFAULT 'no',
  `allergies_details` text DEFAULT NULL,
  `medications_details` text DEFAULT NULL,
  `smoking_details` text DEFAULT NULL,
  `alcohol_details` text DEFAULT NULL,
  `surgeries_details` text DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `recorded_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `good_health` varchar(255) DEFAULT NULL,
  `under_medical_treatment` varchar(255) DEFAULT NULL,
  `medical_treatment_details` text DEFAULT NULL,
  `hospitalized` varchar(255) DEFAULT NULL,
  `hospitalization_details` text DEFAULT NULL,
  `nursing` varchar(255) DEFAULT NULL,
  `birth_control_pills` varchar(255) DEFAULT NULL,
  `bleeding_time` varchar(255) DEFAULT NULL,
  `blood_type` varchar(255) DEFAULT NULL,
  `blood_pressure` varchar(255) DEFAULT NULL,
  `conditions_checklist` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`conditions_checklist`)),
  `physician_name` varchar(255) DEFAULT NULL,
  `physician_specialty` varchar(255) DEFAULT NULL,
  `physician_address` varchar(255) DEFAULT NULL,
  `physician_phone` varchar(255) DEFAULT NULL,
  `dental_history_previous_dentist` varchar(255) DEFAULT NULL,
  `dental_history_last_visit` date DEFAULT NULL,
  `referral_source` varchar(255) DEFAULT NULL,
  `drug_use` varchar(255) DEFAULT NULL,
  `drug_use_details` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `medical_histories_patient_id_unique` (`patient_id`),
  KEY `medical_histories_recorded_by_foreign` (`recorded_by`),
  CONSTRAINT `medical_histories_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `medical_histories_recorded_by_foreign` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medical_histories`
--

LOCK TABLES `medical_histories` WRITE;
/*!40000 ALTER TABLE `medical_histories` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `medical_histories` VALUES
(1,1,'no','no','no','no','no','yes','no','no','no','no','Penicillin — mild skin rash',NULL,NULL,NULL,NULL,NULL,2,'2026-08-05 04:52:12','2026-08-05 04:52:12','yes','no',NULL,'no',NULL,'no','no','normal','A+','110/70',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'no',NULL),
(2,2,'no','yes','no','no','no','no','no','no','no','no',NULL,NULL,NULL,NULL,NULL,'qwe',2,'2026-08-05 04:52:12','2026-08-09 06:41:50','yes','no',NULL,'no',NULL,'no','no','normal','B+','130/85','[]',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'no',NULL),
(3,3,'no','no','no','no','no','no','no','no','no','no',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-08-05 04:52:12','2026-08-09 06:27:18','yes','no',NULL,'no',NULL,'no','no','normal','O+','120/80','[]',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'no',NULL),
(4,4,'yes','yes','no','no','no','no','yes','no','no','no',NULL,'Losartan 50 mg daily, Metformin 500 mg twice daily',NULL,NULL,NULL,NULL,2,'2026-08-05 04:52:12','2026-08-05 04:52:12','yes','no',NULL,'no',NULL,'no','no','normal','O+','120/80','[\"high_blood_pressure\",\"diabetes\",\"asthma\"]','Dr. Lim','Cardiologist','2nd Floor, Medical Plaza Manila, Ermita, Manila','8231-9090','Dr. Cruz','2025-11-02','Friend','no',NULL),
(5,6,'no','no','no','no','no','no','no','yes','yes','no',NULL,NULL,'1 pack/day for 12 years','Social drinker, weekends only',NULL,NULL,2,'2026-08-05 04:52:12','2026-08-05 04:52:12','yes','no',NULL,'no',NULL,'no','no','normal','AB+','125/80',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'no',NULL),
(6,7,'no','no','no','no','no','no','no','no','no','no',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-08-05 06:55:26','2026-08-05 06:55:26',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(7,8,'no','no','no','no','no','no','no','no','no','no',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-08-06 09:38:57','2026-08-06 09:40:37','yes','no',NULL,'no',NULL,NULL,NULL,NULL,'O+',NULL,'[\"arthritis\",\"others\"]',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'no',NULL),
(8,9,'no','no','no','no','no','no','no','no','no','no',NULL,NULL,NULL,NULL,NULL,NULL,2,'2026-08-06 14:02:27','2026-08-09 07:02:28',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'O+',NULL,'[]',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(9,10,'no','no','no','no','no','no','no','no','no','no',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-08-08 12:38:09','2026-08-08 12:38:09',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[]',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `medical_histories` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `migrations` VALUES
(1,'0001_01_01_000000_create_users_table',1),
(2,'0001_01_01_000001_create_cache_table',1),
(3,'0001_01_01_000002_create_jobs_table',1),
(4,'2026_01_01_000003_create_patients_table',1),
(5,'2026_01_01_000004_create_medical_histories_table',1),
(6,'2026_01_01_000005_create_appointments_table',1),
(7,'2026_01_01_000011_create_settings_table',1),
(8,'2026_08_01_000001_add_is_follow_up_to_appointments_table',1),
(9,'2026_08_01_000002_create_consultations_table',1),
(10,'2026_08_01_000003_create_dental_chart_entries_table',1),
(11,'2026_08_01_000004_extend_medical_histories_for_pda',1),
(12,'2026_08_01_000005_extend_patients_for_pda',1),
(13,'2026_08_01_000006_create_treatments_table',1),
(14,'2026_08_01_000007_create_attachments_table',1),
(15,'2026_08_01_000008_create_consent_forms_table',1),
(16,'2026_08_01_000009_create_consent_sections_table',1),
(17,'2026_08_01_050622_create_activity_log_table',1),
(18,'2026_08_01_050622_create_permission_tables',1),
(19,'2026_08_01_060000_add_is_active_to_users_table',1),
(20,'2026_08_02_000001_add_username_to_users_table',1),
(21,'2026_08_08_000001_make_emergency_contact_columns_nullable',2);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `model_has_permissions`
--

DROP TABLE IF EXISTS `model_has_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_has_permissions` (
  `permission_id` bigint(20) unsigned NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`),
  CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_has_permissions`
--

LOCK TABLES `model_has_permissions` WRITE;
/*!40000 ALTER TABLE `model_has_permissions` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `model_has_permissions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `model_has_roles`
--

DROP TABLE IF EXISTS `model_has_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_has_roles` (
  `role_id` bigint(20) unsigned NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`),
  CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_has_roles`
--

LOCK TABLES `model_has_roles` WRITE;
/*!40000 ALTER TABLE `model_has_roles` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `model_has_roles` VALUES
(1,'App\\Models\\User',1),
(2,'App\\Models\\User',2),
(3,'App\\Models\\User',3),
(3,'App\\Models\\User',4),
(3,'App\\Models\\User',5),
(3,'App\\Models\\User',6),
(3,'App\\Models\\User',7),
(3,'App\\Models\\User',8),
(3,'App\\Models\\User',9),
(3,'App\\Models\\User',10),
(3,'App\\Models\\User',11),
(3,'App\\Models\\User',12),
(3,'App\\Models\\User',13),
(3,'App\\Models\\User',14),
(3,'App\\Models\\User',15),
(3,'App\\Models\\User',16),
(3,'App\\Models\\User',17),
(3,'App\\Models\\User',18),
(3,'App\\Models\\User',19),
(3,'App\\Models\\User',20),
(3,'App\\Models\\User',21),
(3,'App\\Models\\User',22),
(3,'App\\Models\\User',23),
(3,'App\\Models\\User',24);
/*!40000 ALTER TABLE `model_has_roles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `patients` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_number` varchar(20) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `middle_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) NOT NULL,
  `sex` varchar(255) NOT NULL,
  `birth_date` date NOT NULL,
  `civil_status` varchar(255) NOT NULL DEFAULT 'single',
  `nationality` varchar(255) NOT NULL DEFAULT 'Filipino',
  `occupation` varchar(255) DEFAULT NULL,
  `contact_number` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `email_address` varchar(255) DEFAULT NULL,
  `emergency_contact_person` varchar(255) DEFAULT NULL,
  `emergency_contact_number` varchar(255) DEFAULT NULL,
  `created_by` bigint(20) unsigned DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `religion` varchar(255) DEFAULT NULL,
  `nickname` varchar(255) DEFAULT NULL,
  `home_phone` varchar(255) DEFAULT NULL,
  `office_phone` varchar(255) DEFAULT NULL,
  `fax_number` varchar(255) DEFAULT NULL,
  `dental_insurance` varchar(255) DEFAULT NULL,
  `effective_date` date DEFAULT NULL,
  `guardian_name` varchar(255) DEFAULT NULL,
  `guardian_occupation` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `patients_patient_number_unique` (`patient_number`),
  KEY `patients_created_by_foreign` (`created_by`),
  KEY `patients_last_name_first_name_index` (`last_name`,`first_name`),
  KEY `patients_birth_date_index` (`birth_date`),
  CONSTRAINT `patients_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `patients` VALUES
(1,'2026-0101','Maria Concepcion','Dizon','Santos','female','1988-04-12','married','Filipino','Accountant','09171234567','45 Sampaguita St., Brgy. San Lorenzo, Makati City','maria.santos@example.com','Juan Santos','09181234568',1,NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12','Roman Catholic','Maricel','8123-4567','8812-3456',NULL,'PhilHealth','2026-01-15',NULL,NULL),
(2,'2026-0102','Juan',NULL,'Dela Cruz','male','1975-09-30','married','Filipino','Civil Engineer','09175551234','12 Katipunan Ave., Brgy. Bagumbayan, Quezon City','juan.delacruz@example.com','Maria Dela Cruz','09175559876',1,NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12','Roman Catholic',NULL,'8721-3344',NULL,NULL,'Sun Life','2025-06-01',NULL,NULL),
(3,'2026-0103','Angela','Ramos','Fernandez','female','2014-03-15','single','Filipino',NULL,'09173334455','8 Ilang-Ilang St., Brgy. San Isidro, Parañaque City',NULL,'Elena Ramos','09173336677',1,NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12','Roman Catholic','Angel','8534-2211',NULL,NULL,NULL,NULL,'Elena Ramos','Teacher'),
(4,'2026-0104','Antonio','Cruz','Bautista','male','1950-01-22','widowed','Filipino','Retired','09178889900','230 Taft Ave., Brgy. 700, Manila','antonio.bautista@example.com','Lito Bautista','09178884455',1,NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12','Iglesia ni Cristo','Tonio','8231-7788','8231-7799',NULL,'PhilHealth','2024-03-10',NULL,NULL),
(5,'2026-0105','Sofia','Lim','Reyes','female','1995-07-08','single','Filipino','Nurse','09174445566','5 Burgos Circle, Brgy. Poblacion, Makati City','sofia.reyes@example.com','Carmen Reyes','09174447788',1,NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12','Born Again','Pia',NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(6,'2026-0106','Ramon','Salazar','Villanueva','male','1980-11-17','separated','Filipino','Business Owner','09175556677','22 Ortigas Ave., Brgy. San Antonio, Pasig City','ramon.villanueva@example.com','Rosa Villanueva','09175559988',1,NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12','Roman Catholic',NULL,'8644-9900',NULL,NULL,'Sun Life','2026-02-01',NULL,NULL),
(7,'2026-0007','Pedro',NULL,'Garcia','male','1995-02-20','single','Filipino',NULL,'09171234007','7 Banawe St, QC',NULL,'Luz Garcia','09179876547',1,NULL,'2026-08-05 06:55:07','2026-08-05 06:55:07',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(8,'2026-0008','John Dennis','Bautista','Bernardo','male','1997-02-16','married','Filipino','Web Developer','09560934971','205 Bayan-bayanan, Prenza 2, Marilao, Bulacan','jdbernardo16@gmail.com','Ona Elledan Bernardo','0917123123123',1,NULL,'2026-08-06 09:38:22','2026-08-06 09:38:22',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(9,'2026-0009','John Dennis',NULL,'Bernardo','male','1997-02-16','married','Filipino',NULL,'09560934971','205 Bayan-bayanan, Prenza 2',NULL,'John Dennis Bernardo','09560934971',1,NULL,'2026-08-06 14:02:25','2026-08-06 14:02:25',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(10,'2026-0010','qwe','wqe','qweqwe','female','1997-02-16','married','Filipino','Web Developer','09560934971','205 Bayan-bayanan, Prenza 2',NULL,'John Dennis Bernardo','09560934971',1,NULL,'2026-08-06 20:59:31','2026-08-06 20:59:31',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(14,'2026-0011','Test','Imported','Patient','male','1995-05-05','single','Filipino','Dentist','09171234567','123 Test St.','test.import@example.com',NULL,NULL,1,'2026-08-09 11:33:52','2026-08-09 11:31:59','2026-08-09 11:33:52',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `patients` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `permissions` VALUES
(1,'users.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(2,'users.create','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(3,'users.update','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(4,'users.delete','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(5,'patients.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(6,'patients.create','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(7,'patients.update','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(8,'patients.delete','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(9,'medical-histories.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(10,'medical-histories.create','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(11,'medical-histories.update','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(12,'appointments.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(13,'appointments.create','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(14,'appointments.update','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(15,'appointments.cancel','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(16,'appointments.attendance','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(17,'consultations.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(18,'consultations.create','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(19,'consultations.update','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(20,'dental-chart.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(21,'dental-chart.update','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(22,'treatments.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(23,'treatments.create','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(24,'treatments.update','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(25,'treatments.sign','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(26,'attachments.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(27,'attachments.upload','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(28,'attachments.delete','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(29,'consents.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(30,'consents.create','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(31,'consents.sign-patient','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(32,'consents.sign-dentist','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(33,'reports.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(34,'settings.view','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(35,'settings.update','web','2026-08-05 04:52:11','2026-08-05 04:52:11');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `role_has_permissions`
--

DROP TABLE IF EXISTS `role_has_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_has_permissions` (
  `permission_id` bigint(20) unsigned NOT NULL,
  `role_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`role_id`),
  KEY `role_has_permissions_role_id_foreign` (`role_id`),
  CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_has_permissions`
--

LOCK TABLES `role_has_permissions` WRITE;
/*!40000 ALTER TABLE `role_has_permissions` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `role_has_permissions` VALUES
(1,1),
(2,1),
(3,1),
(4,1),
(5,1),
(6,1),
(7,1),
(8,1),
(9,1),
(10,1),
(11,1),
(12,1),
(13,1),
(14,1),
(15,1),
(16,1),
(17,1),
(18,1),
(19,1),
(20,1),
(21,1),
(22,1),
(23,1),
(24,1),
(25,1),
(26,1),
(27,1),
(28,1),
(29,1),
(30,1),
(31,1),
(32,1),
(33,1),
(34,1),
(35,1),
(5,2),
(6,2),
(7,2),
(9,2),
(10,2),
(11,2),
(12,2),
(14,2),
(15,2),
(16,2),
(17,2),
(18,2),
(19,2),
(20,2),
(21,2),
(22,2),
(23,2),
(24,2),
(25,2),
(26,2),
(27,2),
(29,2),
(30,2),
(31,2),
(32,2),
(5,3),
(6,3),
(7,3),
(10,3),
(12,3),
(13,3),
(14,3),
(15,3),
(16,3),
(20,3),
(26,3),
(27,3),
(29,3),
(30,3),
(31,3);
/*!40000 ALTER TABLE `role_has_permissions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `roles` VALUES
(1,'Administrator','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(2,'Dentist','web','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(3,'Assistant','web','2026-08-05 04:52:11','2026-08-05 04:52:11');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `sessions` VALUES
('7BgpYu6sQxhU8Zm1kwZTJwyHgQGSdrZ5ELe5KuWp',1,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.7922.34 Safari/537.36','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiM1AwTmVvOWNHZUlIWlhrc1ROdWJ3Q054MGp0MU1qZlZZc0VsS1JmWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9jb25zZW50cy8yOCI7czo1OiJyb3V0ZSI7czoxMzoiY29uc2VudHMuc2hvdyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==',1786269560),
('7POXmvWzNqRmmSBomikMYNeO8WMI7HkbOTS6B43z',1,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.7922.34 Safari/537.36','YTo0OntzOjY6Il90b2tlbiI7czo0MDoidU82b2puTnhYcGlBUnY1TGw1RGdBSlFJREE4TW95VGRDaHlPRnBqVCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9jb25zZW50cy8yOCI7czo1OiJyb3V0ZSI7czoxMzoiY29uc2VudHMuc2hvdyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==',1786269415),
('hLlbZXSdXrHQkx1ERuyLgtG9Ni2onb1CSqkHREtw',1,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.7922.34 Safari/537.36','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiSWw2Y0JtMkF5elkwb2k3NGw4eWJtRUt1blEzSnNKOE9qUlJVMVNVSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9jb25zZW50cy8yOCI7czo1OiJyb3V0ZSI7czoxMzoiY29uc2VudHMuc2hvdyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==',1786269346),
('IseZ3YzmlQvszS7Vl3TzrJ24EHhyNpgwGCEE2BWx',1,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiZzhSczlGT1NVb3pEZjZaUGpiSkR6bDFwbWhaRndpc1Z2d2Fvb3RDciI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTtzOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czozNzoiaHR0cDovL2xvY2FsaG9zdDo4MDAwL3BhdGllbnRzL2V4cG9ydCI7czo1OiJyb3V0ZSI7czoxOToicGF0aWVudHMuZXhwb3J0LWNzdiI7fXM6MTQ6InBhdGllbnQtaW1wb3J0IjthOjI6e3M6NDA6IjY5WEtnY0hhREM2RGVaUVdPZ3VIaHhXaFZDZGVvVGMyUnUzN1FIT2IiO2E6Mjp7czo0OiJyb3dzIjthOjEwOntpOjA7YTo0OntzOjEwOiJyb3dfbnVtYmVyIjtpOjE7czo0OiJkYXRhIjthOjExOntzOjEwOiJmaXJzdF9uYW1lIjtzOjk6IjIwMjYtMDAxMCI7czoxMToibWlkZGxlX25hbWUiO3M6MzoicXdlIjtzOjk6Imxhc3RfbmFtZSI7czozOiJ3cWUiO3M6Mzoic2V4IjtzOjY6InF3ZXF3ZSI7czoxMDoiYmlydGhfZGF0ZSI7czo2OiJmZW1hbGUiO3M6MTI6ImNpdmlsX3N0YXR1cyI7czoxMDoiMTk5Ny0wMi0xNiI7czoxMToibmF0aW9uYWxpdHkiO3M6NzoibWFycmllZCI7czoxMDoib2NjdXBhdGlvbiI7czo4OiJGaWxpcGlubyI7czoxNDoiY29udGFjdF9udW1iZXIiO3M6MTM6IldlYiBEZXZlbG9wZXIiO3M6NzoiYWRkcmVzcyI7czoxMToiMDk1NjA5MzQ5NzEiO3M6MTM6ImVtYWlsX2FkZHJlc3MiO3M6Mjc6IjIwNSBCYXlhbi1iYXlhbmFuLCBQcmVuemEgMiI7fXM6Njoic3RhdHVzIjtzOjc6ImludmFsaWQiO3M6NjoiZXJyb3JzIjthOjU6e2k6MDtzOjI4OiJUaGUgc2VsZWN0ZWQgc2V4IGlzIGludmFsaWQuIjtpOjE7czo0MjoiVGhlIGJpcnRoIGRhdGUgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGRhdGUuIjtpOjI7czozNzoiVGhlIHNlbGVjdGVkIGNpdmlsIHN0YXR1cyBpcyBpbnZhbGlkLiI7aTozO3M6NDM6IlRoZSBjb250YWN0IG51bWJlciBmaWVsZCBmb3JtYXQgaXMgaW52YWxpZC4iO2k6NDtzOjU0OiJUaGUgZW1haWwgYWRkcmVzcyBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZW1haWwgYWRkcmVzcy4iO319aToxO2E6NDp7czoxMDoicm93X251bWJlciI7aToyO3M6NDoiZGF0YSI7YToxMTp7czoxMDoiZmlyc3RfbmFtZSI7czo5OiIyMDI2LTAwMDkiO3M6MTE6Im1pZGRsZV9uYW1lIjtzOjExOiJKb2huIERlbm5pcyI7czo5OiJsYXN0X25hbWUiO3M6MDoiIjtzOjM6InNleCI7czo4OiJCZXJuYXJkbyI7czoxMDoiYmlydGhfZGF0ZSI7czo0OiJtYWxlIjtzOjEyOiJjaXZpbF9zdGF0dXMiO3M6MTA6IjE5OTctMDItMTYiO3M6MTE6Im5hdGlvbmFsaXR5IjtzOjc6Im1hcnJpZWQiO3M6MTA6Im9jY3VwYXRpb24iO3M6ODoiRmlsaXBpbm8iO3M6MTQ6ImNvbnRhY3RfbnVtYmVyIjtzOjA6IiI7czo3OiJhZGRyZXNzIjtzOjExOiIwOTU2MDkzNDk3MSI7czoxMzoiZW1haWxfYWRkcmVzcyI7czoyNzoiMjA1IEJheWFuLWJheWFuYW4sIFByZW56YSAyIjt9czo2OiJzdGF0dXMiO3M6NzoiaW52YWxpZCI7czo2OiJlcnJvcnMiO2E6Njp7aTowO3M6MzI6IlRoZSBsYXN0IG5hbWUgZmllbGQgaXMgcmVxdWlyZWQuIjtpOjE7czoyODoiVGhlIHNlbGVjdGVkIHNleCBpcyBpbnZhbGlkLiI7aToyO3M6NDI6IlRoZSBiaXJ0aCBkYXRlIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBkYXRlLiI7aTozO3M6Mzc6IlRoZSBzZWxlY3RlZCBjaXZpbCBzdGF0dXMgaXMgaW52YWxpZC4iO2k6NDtzOjM3OiJUaGUgY29udGFjdCBudW1iZXIgZmllbGQgaXMgcmVxdWlyZWQuIjtpOjU7czo1NDoiVGhlIGVtYWlsIGFkZHJlc3MgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGVtYWlsIGFkZHJlc3MuIjt9fWk6MjthOjQ6e3M6MTA6InJvd19udW1iZXIiO2k6MztzOjQ6ImRhdGEiO2E6MTE6e3M6MTA6ImZpcnN0X25hbWUiO3M6OToiMjAyNi0wMDA4IjtzOjExOiJtaWRkbGVfbmFtZSI7czoxMToiSm9obiBEZW5uaXMiO3M6OToibGFzdF9uYW1lIjtzOjg6IkJhdXRpc3RhIjtzOjM6InNleCI7czo4OiJCZXJuYXJkbyI7czoxMDoiYmlydGhfZGF0ZSI7czo0OiJtYWxlIjtzOjEyOiJjaXZpbF9zdGF0dXMiO3M6MTA6IjE5OTctMDItMTYiO3M6MTE6Im5hdGlvbmFsaXR5IjtzOjc6Im1hcnJpZWQiO3M6MTA6Im9jY3VwYXRpb24iO3M6ODoiRmlsaXBpbm8iO3M6MTQ6ImNvbnRhY3RfbnVtYmVyIjtzOjEzOiJXZWIgRGV2ZWxvcGVyIjtzOjc6ImFkZHJlc3MiO3M6MTE6IjA5NTYwOTM0OTcxIjtzOjEzOiJlbWFpbF9hZGRyZXNzIjtzOjQ1OiIyMDUgQmF5YW4tYmF5YW5hbiwgUHJlbnphIDIsIE1hcmlsYW8sIEJ1bGFjYW4iO31zOjY6InN0YXR1cyI7czo3OiJpbnZhbGlkIjtzOjY6ImVycm9ycyI7YTo1OntpOjA7czoyODoiVGhlIHNlbGVjdGVkIHNleCBpcyBpbnZhbGlkLiI7aToxO3M6NDI6IlRoZSBiaXJ0aCBkYXRlIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBkYXRlLiI7aToyO3M6Mzc6IlRoZSBzZWxlY3RlZCBjaXZpbCBzdGF0dXMgaXMgaW52YWxpZC4iO2k6MztzOjQzOiJUaGUgY29udGFjdCBudW1iZXIgZmllbGQgZm9ybWF0IGlzIGludmFsaWQuIjtpOjQ7czo1NDoiVGhlIGVtYWlsIGFkZHJlc3MgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGVtYWlsIGFkZHJlc3MuIjt9fWk6MzthOjQ6e3M6MTA6InJvd19udW1iZXIiO2k6NDtzOjQ6ImRhdGEiO2E6MTE6e3M6MTA6ImZpcnN0X25hbWUiO3M6OToiMjAyNi0wMDA3IjtzOjExOiJtaWRkbGVfbmFtZSI7czo1OiJQZWRybyI7czo5OiJsYXN0X25hbWUiO3M6MDoiIjtzOjM6InNleCI7czo2OiJHYXJjaWEiO3M6MTA6ImJpcnRoX2RhdGUiO3M6NDoibWFsZSI7czoxMjoiY2l2aWxfc3RhdHVzIjtzOjEwOiIxOTk1LTAyLTIwIjtzOjExOiJuYXRpb25hbGl0eSI7czo2OiJzaW5nbGUiO3M6MTA6Im9jY3VwYXRpb24iO3M6ODoiRmlsaXBpbm8iO3M6MTQ6ImNvbnRhY3RfbnVtYmVyIjtzOjA6IiI7czo3OiJhZGRyZXNzIjtzOjExOiIwOTE3MTIzNDAwNyI7czoxMzoiZW1haWxfYWRkcmVzcyI7czoxNToiNyBCYW5hd2UgU3QsIFFDIjt9czo2OiJzdGF0dXMiO3M6NzoiaW52YWxpZCI7czo2OiJlcnJvcnMiO2E6Njp7aTowO3M6MzI6IlRoZSBsYXN0IG5hbWUgZmllbGQgaXMgcmVxdWlyZWQuIjtpOjE7czoyODoiVGhlIHNlbGVjdGVkIHNleCBpcyBpbnZhbGlkLiI7aToyO3M6NDI6IlRoZSBiaXJ0aCBkYXRlIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBkYXRlLiI7aTozO3M6Mzc6IlRoZSBzZWxlY3RlZCBjaXZpbCBzdGF0dXMgaXMgaW52YWxpZC4iO2k6NDtzOjM3OiJUaGUgY29udGFjdCBudW1iZXIgZmllbGQgaXMgcmVxdWlyZWQuIjtpOjU7czo1NDoiVGhlIGVtYWlsIGFkZHJlc3MgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGVtYWlsIGFkZHJlc3MuIjt9fWk6NDthOjQ6e3M6MTA6InJvd19udW1iZXIiO2k6NTtzOjQ6ImRhdGEiO2E6MTE6e3M6MTA6ImZpcnN0X25hbWUiO3M6OToiMjAyNi0wMTAxIjtzOjExOiJtaWRkbGVfbmFtZSI7czoxNjoiTWFyaWEgQ29uY2VwY2lvbiI7czo5OiJsYXN0X25hbWUiO3M6NToiRGl6b24iO3M6Mzoic2V4IjtzOjY6IlNhbnRvcyI7czoxMDoiYmlydGhfZGF0ZSI7czo2OiJmZW1hbGUiO3M6MTI6ImNpdmlsX3N0YXR1cyI7czoxMDoiMTk4OC0wNC0xMiI7czoxMToibmF0aW9uYWxpdHkiO3M6NzoibWFycmllZCI7czoxMDoib2NjdXBhdGlvbiI7czo4OiJGaWxpcGlubyI7czoxNDoiY29udGFjdF9udW1iZXIiO3M6MTA6IkFjY291bnRhbnQiO3M6NzoiYWRkcmVzcyI7czoxMToiMDkxNzEyMzQ1NjciO3M6MTM6ImVtYWlsX2FkZHJlc3MiO3M6NDk6IjQ1IFNhbXBhZ3VpdGEgU3QuLCBCcmd5LiBTYW4gTG9yZW56bywgTWFrYXRpIENpdHkiO31zOjY6InN0YXR1cyI7czo3OiJpbnZhbGlkIjtzOjY6ImVycm9ycyI7YTo1OntpOjA7czoyODoiVGhlIHNlbGVjdGVkIHNleCBpcyBpbnZhbGlkLiI7aToxO3M6NDI6IlRoZSBiaXJ0aCBkYXRlIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBkYXRlLiI7aToyO3M6Mzc6IlRoZSBzZWxlY3RlZCBjaXZpbCBzdGF0dXMgaXMgaW52YWxpZC4iO2k6MztzOjQzOiJUaGUgY29udGFjdCBudW1iZXIgZmllbGQgZm9ybWF0IGlzIGludmFsaWQuIjtpOjQ7czo1NDoiVGhlIGVtYWlsIGFkZHJlc3MgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGVtYWlsIGFkZHJlc3MuIjt9fWk6NTthOjQ6e3M6MTA6InJvd19udW1iZXIiO2k6NjtzOjQ6ImRhdGEiO2E6MTE6e3M6MTA6ImZpcnN0X25hbWUiO3M6OToiMjAyNi0wMTAyIjtzOjExOiJtaWRkbGVfbmFtZSI7czo0OiJKdWFuIjtzOjk6Imxhc3RfbmFtZSI7czowOiIiO3M6Mzoic2V4IjtzOjk6IkRlbGEgQ3J1eiI7czoxMDoiYmlydGhfZGF0ZSI7czo0OiJtYWxlIjtzOjEyOiJjaXZpbF9zdGF0dXMiO3M6MTA6IjE5NzUtMDktMzAiO3M6MTE6Im5hdGlvbmFsaXR5IjtzOjc6Im1hcnJpZWQiO3M6MTA6Im9jY3VwYXRpb24iO3M6ODoiRmlsaXBpbm8iO3M6MTQ6ImNvbnRhY3RfbnVtYmVyIjtzOjE0OiJDaXZpbCBFbmdpbmVlciI7czo3OiJhZGRyZXNzIjtzOjExOiIwOTE3NTU1MTIzNCI7czoxMzoiZW1haWxfYWRkcmVzcyI7czo0ODoiMTIgS2F0aXB1bmFuIEF2ZS4sIEJyZ3kuIEJhZ3VtYmF5YW4sIFF1ZXpvbiBDaXR5Ijt9czo2OiJzdGF0dXMiO3M6NzoiaW52YWxpZCI7czo2OiJlcnJvcnMiO2E6Njp7aTowO3M6MzI6IlRoZSBsYXN0IG5hbWUgZmllbGQgaXMgcmVxdWlyZWQuIjtpOjE7czoyODoiVGhlIHNlbGVjdGVkIHNleCBpcyBpbnZhbGlkLiI7aToyO3M6NDI6IlRoZSBiaXJ0aCBkYXRlIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBkYXRlLiI7aTozO3M6Mzc6IlRoZSBzZWxlY3RlZCBjaXZpbCBzdGF0dXMgaXMgaW52YWxpZC4iO2k6NDtzOjQzOiJUaGUgY29udGFjdCBudW1iZXIgZmllbGQgZm9ybWF0IGlzIGludmFsaWQuIjtpOjU7czo1NDoiVGhlIGVtYWlsIGFkZHJlc3MgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGVtYWlsIGFkZHJlc3MuIjt9fWk6NjthOjQ6e3M6MTA6InJvd19udW1iZXIiO2k6NztzOjQ6ImRhdGEiO2E6MTE6e3M6MTA6ImZpcnN0X25hbWUiO3M6OToiMjAyNi0wMTAzIjtzOjExOiJtaWRkbGVfbmFtZSI7czo2OiJBbmdlbGEiO3M6OToibGFzdF9uYW1lIjtzOjU6IlJhbW9zIjtzOjM6InNleCI7czo5OiJGZXJuYW5kZXoiO3M6MTA6ImJpcnRoX2RhdGUiO3M6NjoiZmVtYWxlIjtzOjEyOiJjaXZpbF9zdGF0dXMiO3M6MTA6IjIwMTQtMDMtMTUiO3M6MTE6Im5hdGlvbmFsaXR5IjtzOjY6InNpbmdsZSI7czoxMDoib2NjdXBhdGlvbiI7czo4OiJGaWxpcGlubyI7czoxNDoiY29udGFjdF9udW1iZXIiO3M6MDoiIjtzOjc6ImFkZHJlc3MiO3M6MTE6IjA5MTczMzM0NDU1IjtzOjEzOiJlbWFpbF9hZGRyZXNzIjtzOjUyOiI4IElsYW5nLUlsYW5nIFN0LiwgQnJneS4gU2FuIElzaWRybywgUGFyYcOxYXF1ZSBDaXR5Ijt9czo2OiJzdGF0dXMiO3M6NzoiaW52YWxpZCI7czo2OiJlcnJvcnMiO2E6NTp7aTowO3M6Mjg6IlRoZSBzZWxlY3RlZCBzZXggaXMgaW52YWxpZC4iO2k6MTtzOjQyOiJUaGUgYmlydGggZGF0ZSBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZGF0ZS4iO2k6MjtzOjM3OiJUaGUgc2VsZWN0ZWQgY2l2aWwgc3RhdHVzIGlzIGludmFsaWQuIjtpOjM7czozNzoiVGhlIGNvbnRhY3QgbnVtYmVyIGZpZWxkIGlzIHJlcXVpcmVkLiI7aTo0O3M6NTQ6IlRoZSBlbWFpbCBhZGRyZXNzIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBlbWFpbCBhZGRyZXNzLiI7fX1pOjc7YTo0OntzOjEwOiJyb3dfbnVtYmVyIjtpOjg7czo0OiJkYXRhIjthOjExOntzOjEwOiJmaXJzdF9uYW1lIjtzOjk6IjIwMjYtMDEwNCI7czoxMToibWlkZGxlX25hbWUiO3M6NzoiQW50b25pbyI7czo5OiJsYXN0X25hbWUiO3M6NDoiQ3J1eiI7czozOiJzZXgiO3M6ODoiQmF1dGlzdGEiO3M6MTA6ImJpcnRoX2RhdGUiO3M6NDoibWFsZSI7czoxMjoiY2l2aWxfc3RhdHVzIjtzOjEwOiIxOTUwLTAxLTIyIjtzOjExOiJuYXRpb25hbGl0eSI7czo3OiJ3aWRvd2VkIjtzOjEwOiJvY2N1cGF0aW9uIjtzOjg6IkZpbGlwaW5vIjtzOjE0OiJjb250YWN0X251bWJlciI7czo3OiJSZXRpcmVkIjtzOjc6ImFkZHJlc3MiO3M6MTE6IjA5MTc4ODg5OTAwIjtzOjEzOiJlbWFpbF9hZGRyZXNzIjtzOjMyOiIyMzAgVGFmdCBBdmUuLCBCcmd5LiA3MDAsIE1hbmlsYSI7fXM6Njoic3RhdHVzIjtzOjc6ImludmFsaWQiO3M6NjoiZXJyb3JzIjthOjU6e2k6MDtzOjI4OiJUaGUgc2VsZWN0ZWQgc2V4IGlzIGludmFsaWQuIjtpOjE7czo0MjoiVGhlIGJpcnRoIGRhdGUgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGRhdGUuIjtpOjI7czozNzoiVGhlIHNlbGVjdGVkIGNpdmlsIHN0YXR1cyBpcyBpbnZhbGlkLiI7aTozO3M6NDM6IlRoZSBjb250YWN0IG51bWJlciBmaWVsZCBmb3JtYXQgaXMgaW52YWxpZC4iO2k6NDtzOjU0OiJUaGUgZW1haWwgYWRkcmVzcyBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZW1haWwgYWRkcmVzcy4iO319aTo4O2E6NDp7czoxMDoicm93X251bWJlciI7aTo5O3M6NDoiZGF0YSI7YToxMTp7czoxMDoiZmlyc3RfbmFtZSI7czo5OiIyMDI2LTAxMDUiO3M6MTE6Im1pZGRsZV9uYW1lIjtzOjU6IlNvZmlhIjtzOjk6Imxhc3RfbmFtZSI7czozOiJMaW0iO3M6Mzoic2V4IjtzOjU6IlJleWVzIjtzOjEwOiJiaXJ0aF9kYXRlIjtzOjY6ImZlbWFsZSI7czoxMjoiY2l2aWxfc3RhdHVzIjtzOjEwOiIxOTk1LTA3LTA4IjtzOjExOiJuYXRpb25hbGl0eSI7czo2OiJzaW5nbGUiO3M6MTA6Im9jY3VwYXRpb24iO3M6ODoiRmlsaXBpbm8iO3M6MTQ6ImNvbnRhY3RfbnVtYmVyIjtzOjU6Ik51cnNlIjtzOjc6ImFkZHJlc3MiO3M6MTE6IjA5MTc0NDQ1NTY2IjtzOjEzOiJlbWFpbF9hZGRyZXNzIjtzOjQ1OiI1IEJ1cmdvcyBDaXJjbGUsIEJyZ3kuIFBvYmxhY2lvbiwgTWFrYXRpIENpdHkiO31zOjY6InN0YXR1cyI7czo3OiJpbnZhbGlkIjtzOjY6ImVycm9ycyI7YTo1OntpOjA7czoyODoiVGhlIHNlbGVjdGVkIHNleCBpcyBpbnZhbGlkLiI7aToxO3M6NDI6IlRoZSBiaXJ0aCBkYXRlIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBkYXRlLiI7aToyO3M6Mzc6IlRoZSBzZWxlY3RlZCBjaXZpbCBzdGF0dXMgaXMgaW52YWxpZC4iO2k6MztzOjQzOiJUaGUgY29udGFjdCBudW1iZXIgZmllbGQgZm9ybWF0IGlzIGludmFsaWQuIjtpOjQ7czo1NDoiVGhlIGVtYWlsIGFkZHJlc3MgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGVtYWlsIGFkZHJlc3MuIjt9fWk6OTthOjQ6e3M6MTA6InJvd19udW1iZXIiO2k6MTA7czo0OiJkYXRhIjthOjExOntzOjEwOiJmaXJzdF9uYW1lIjtzOjk6IjIwMjYtMDEwNiI7czoxMToibWlkZGxlX25hbWUiO3M6NToiUmFtb24iO3M6OToibGFzdF9uYW1lIjtzOjc6IlNhbGF6YXIiO3M6Mzoic2V4IjtzOjEwOiJWaWxsYW51ZXZhIjtzOjEwOiJiaXJ0aF9kYXRlIjtzOjQ6Im1hbGUiO3M6MTI6ImNpdmlsX3N0YXR1cyI7czoxMDoiMTk4MC0xMS0xNyI7czoxMToibmF0aW9uYWxpdHkiO3M6OToic2VwYXJhdGVkIjtzOjEwOiJvY2N1cGF0aW9uIjtzOjg6IkZpbGlwaW5vIjtzOjE0OiJjb250YWN0X251bWJlciI7czoxNDoiQnVzaW5lc3MgT3duZXIiO3M6NzoiYWRkcmVzcyI7czoxMToiMDkxNzU1NTY2NzciO3M6MTM6ImVtYWlsX2FkZHJlc3MiO3M6NDY6IjIyIE9ydGlnYXMgQXZlLiwgQnJneS4gU2FuIEFudG9uaW8sIFBhc2lnIENpdHkiO31zOjY6InN0YXR1cyI7czo3OiJpbnZhbGlkIjtzOjY6ImVycm9ycyI7YTo1OntpOjA7czoyODoiVGhlIHNlbGVjdGVkIHNleCBpcyBpbnZhbGlkLiI7aToxO3M6NDI6IlRoZSBiaXJ0aCBkYXRlIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBkYXRlLiI7aToyO3M6Mzc6IlRoZSBzZWxlY3RlZCBjaXZpbCBzdGF0dXMgaXMgaW52YWxpZC4iO2k6MztzOjQzOiJUaGUgY29udGFjdCBudW1iZXIgZmllbGQgZm9ybWF0IGlzIGludmFsaWQuIjtpOjQ7czo1NDoiVGhlIGVtYWlsIGFkZHJlc3MgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGVtYWlsIGFkZHJlc3MuIjt9fX1zOjc6ImV4cGlyZXMiO086MjU6IklsbHVtaW5hdGVcU3VwcG9ydFxDYXJib24iOjM6e3M6NDoiZGF0ZSI7czoyNjoiMjAyNi0wOC0wOSAyMDozMToyNS4zNjAwMjIiO3M6MTM6InRpbWV6b25lX3R5cGUiO2k6MztzOjg6InRpbWV6b25lIjtzOjExOiJBc2lhL01hbmlsYSI7fX1zOjQwOiJiQ095Qzg1dkRKOUV3UTJzZDlwYTlEV0lKenU3MDdiaHg0VTJiOHlKIjthOjI6e3M6NDoicm93cyI7YToxMDp7aTowO2E6NDp7czoxMDoicm93X251bWJlciI7aToxO3M6NDoiZGF0YSI7YToxMTp7czoxMDoiZmlyc3RfbmFtZSI7czo5OiIyMDI2LTAwMTAiO3M6MTE6Im1pZGRsZV9uYW1lIjtzOjM6InF3ZSI7czo5OiJsYXN0X25hbWUiO3M6Mzoid3FlIjtzOjM6InNleCI7czo2OiJxd2Vxd2UiO3M6MTA6ImJpcnRoX2RhdGUiO3M6NjoiZmVtYWxlIjtzOjEyOiJjaXZpbF9zdGF0dXMiO3M6MTA6IjE5OTctMDItMTYiO3M6MTE6Im5hdGlvbmFsaXR5IjtzOjc6Im1hcnJpZWQiO3M6MTA6Im9jY3VwYXRpb24iO3M6ODoiRmlsaXBpbm8iO3M6MTQ6ImNvbnRhY3RfbnVtYmVyIjtzOjEzOiJXZWIgRGV2ZWxvcGVyIjtzOjc6ImFkZHJlc3MiO3M6MTE6IjA5NTYwOTM0OTcxIjtzOjEzOiJlbWFpbF9hZGRyZXNzIjtzOjI3OiIyMDUgQmF5YW4tYmF5YW5hbiwgUHJlbnphIDIiO31zOjY6InN0YXR1cyI7czo3OiJpbnZhbGlkIjtzOjY6ImVycm9ycyI7YTo1OntpOjA7czoyODoiVGhlIHNlbGVjdGVkIHNleCBpcyBpbnZhbGlkLiI7aToxO3M6NDI6IlRoZSBiaXJ0aCBkYXRlIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBkYXRlLiI7aToyO3M6Mzc6IlRoZSBzZWxlY3RlZCBjaXZpbCBzdGF0dXMgaXMgaW52YWxpZC4iO2k6MztzOjQzOiJUaGUgY29udGFjdCBudW1iZXIgZmllbGQgZm9ybWF0IGlzIGludmFsaWQuIjtpOjQ7czo1NDoiVGhlIGVtYWlsIGFkZHJlc3MgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGVtYWlsIGFkZHJlc3MuIjt9fWk6MTthOjQ6e3M6MTA6InJvd19udW1iZXIiO2k6MjtzOjQ6ImRhdGEiO2E6MTE6e3M6MTA6ImZpcnN0X25hbWUiO3M6OToiMjAyNi0wMDA5IjtzOjExOiJtaWRkbGVfbmFtZSI7czoxMToiSm9obiBEZW5uaXMiO3M6OToibGFzdF9uYW1lIjtzOjA6IiI7czozOiJzZXgiO3M6ODoiQmVybmFyZG8iO3M6MTA6ImJpcnRoX2RhdGUiO3M6NDoibWFsZSI7czoxMjoiY2l2aWxfc3RhdHVzIjtzOjEwOiIxOTk3LTAyLTE2IjtzOjExOiJuYXRpb25hbGl0eSI7czo3OiJtYXJyaWVkIjtzOjEwOiJvY2N1cGF0aW9uIjtzOjg6IkZpbGlwaW5vIjtzOjE0OiJjb250YWN0X251bWJlciI7czowOiIiO3M6NzoiYWRkcmVzcyI7czoxMToiMDk1NjA5MzQ5NzEiO3M6MTM6ImVtYWlsX2FkZHJlc3MiO3M6Mjc6IjIwNSBCYXlhbi1iYXlhbmFuLCBQcmVuemEgMiI7fXM6Njoic3RhdHVzIjtzOjc6ImludmFsaWQiO3M6NjoiZXJyb3JzIjthOjY6e2k6MDtzOjMyOiJUaGUgbGFzdCBuYW1lIGZpZWxkIGlzIHJlcXVpcmVkLiI7aToxO3M6Mjg6IlRoZSBzZWxlY3RlZCBzZXggaXMgaW52YWxpZC4iO2k6MjtzOjQyOiJUaGUgYmlydGggZGF0ZSBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZGF0ZS4iO2k6MztzOjM3OiJUaGUgc2VsZWN0ZWQgY2l2aWwgc3RhdHVzIGlzIGludmFsaWQuIjtpOjQ7czozNzoiVGhlIGNvbnRhY3QgbnVtYmVyIGZpZWxkIGlzIHJlcXVpcmVkLiI7aTo1O3M6NTQ6IlRoZSBlbWFpbCBhZGRyZXNzIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBlbWFpbCBhZGRyZXNzLiI7fX1pOjI7YTo0OntzOjEwOiJyb3dfbnVtYmVyIjtpOjM7czo0OiJkYXRhIjthOjExOntzOjEwOiJmaXJzdF9uYW1lIjtzOjk6IjIwMjYtMDAwOCI7czoxMToibWlkZGxlX25hbWUiO3M6MTE6IkpvaG4gRGVubmlzIjtzOjk6Imxhc3RfbmFtZSI7czo4OiJCYXV0aXN0YSI7czozOiJzZXgiO3M6ODoiQmVybmFyZG8iO3M6MTA6ImJpcnRoX2RhdGUiO3M6NDoibWFsZSI7czoxMjoiY2l2aWxfc3RhdHVzIjtzOjEwOiIxOTk3LTAyLTE2IjtzOjExOiJuYXRpb25hbGl0eSI7czo3OiJtYXJyaWVkIjtzOjEwOiJvY2N1cGF0aW9uIjtzOjg6IkZpbGlwaW5vIjtzOjE0OiJjb250YWN0X251bWJlciI7czoxMzoiV2ViIERldmVsb3BlciI7czo3OiJhZGRyZXNzIjtzOjExOiIwOTU2MDkzNDk3MSI7czoxMzoiZW1haWxfYWRkcmVzcyI7czo0NToiMjA1IEJheWFuLWJheWFuYW4sIFByZW56YSAyLCBNYXJpbGFvLCBCdWxhY2FuIjt9czo2OiJzdGF0dXMiO3M6NzoiaW52YWxpZCI7czo2OiJlcnJvcnMiO2E6NTp7aTowO3M6Mjg6IlRoZSBzZWxlY3RlZCBzZXggaXMgaW52YWxpZC4iO2k6MTtzOjQyOiJUaGUgYmlydGggZGF0ZSBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZGF0ZS4iO2k6MjtzOjM3OiJUaGUgc2VsZWN0ZWQgY2l2aWwgc3RhdHVzIGlzIGludmFsaWQuIjtpOjM7czo0MzoiVGhlIGNvbnRhY3QgbnVtYmVyIGZpZWxkIGZvcm1hdCBpcyBpbnZhbGlkLiI7aTo0O3M6NTQ6IlRoZSBlbWFpbCBhZGRyZXNzIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBlbWFpbCBhZGRyZXNzLiI7fX1pOjM7YTo0OntzOjEwOiJyb3dfbnVtYmVyIjtpOjQ7czo0OiJkYXRhIjthOjExOntzOjEwOiJmaXJzdF9uYW1lIjtzOjk6IjIwMjYtMDAwNyI7czoxMToibWlkZGxlX25hbWUiO3M6NToiUGVkcm8iO3M6OToibGFzdF9uYW1lIjtzOjA6IiI7czozOiJzZXgiO3M6NjoiR2FyY2lhIjtzOjEwOiJiaXJ0aF9kYXRlIjtzOjQ6Im1hbGUiO3M6MTI6ImNpdmlsX3N0YXR1cyI7czoxMDoiMTk5NS0wMi0yMCI7czoxMToibmF0aW9uYWxpdHkiO3M6Njoic2luZ2xlIjtzOjEwOiJvY2N1cGF0aW9uIjtzOjg6IkZpbGlwaW5vIjtzOjE0OiJjb250YWN0X251bWJlciI7czowOiIiO3M6NzoiYWRkcmVzcyI7czoxMToiMDkxNzEyMzQwMDciO3M6MTM6ImVtYWlsX2FkZHJlc3MiO3M6MTU6IjcgQmFuYXdlIFN0LCBRQyI7fXM6Njoic3RhdHVzIjtzOjc6ImludmFsaWQiO3M6NjoiZXJyb3JzIjthOjY6e2k6MDtzOjMyOiJUaGUgbGFzdCBuYW1lIGZpZWxkIGlzIHJlcXVpcmVkLiI7aToxO3M6Mjg6IlRoZSBzZWxlY3RlZCBzZXggaXMgaW52YWxpZC4iO2k6MjtzOjQyOiJUaGUgYmlydGggZGF0ZSBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZGF0ZS4iO2k6MztzOjM3OiJUaGUgc2VsZWN0ZWQgY2l2aWwgc3RhdHVzIGlzIGludmFsaWQuIjtpOjQ7czozNzoiVGhlIGNvbnRhY3QgbnVtYmVyIGZpZWxkIGlzIHJlcXVpcmVkLiI7aTo1O3M6NTQ6IlRoZSBlbWFpbCBhZGRyZXNzIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBlbWFpbCBhZGRyZXNzLiI7fX1pOjQ7YTo0OntzOjEwOiJyb3dfbnVtYmVyIjtpOjU7czo0OiJkYXRhIjthOjExOntzOjEwOiJmaXJzdF9uYW1lIjtzOjk6IjIwMjYtMDEwMSI7czoxMToibWlkZGxlX25hbWUiO3M6MTY6Ik1hcmlhIENvbmNlcGNpb24iO3M6OToibGFzdF9uYW1lIjtzOjU6IkRpem9uIjtzOjM6InNleCI7czo2OiJTYW50b3MiO3M6MTA6ImJpcnRoX2RhdGUiO3M6NjoiZmVtYWxlIjtzOjEyOiJjaXZpbF9zdGF0dXMiO3M6MTA6IjE5ODgtMDQtMTIiO3M6MTE6Im5hdGlvbmFsaXR5IjtzOjc6Im1hcnJpZWQiO3M6MTA6Im9jY3VwYXRpb24iO3M6ODoiRmlsaXBpbm8iO3M6MTQ6ImNvbnRhY3RfbnVtYmVyIjtzOjEwOiJBY2NvdW50YW50IjtzOjc6ImFkZHJlc3MiO3M6MTE6IjA5MTcxMjM0NTY3IjtzOjEzOiJlbWFpbF9hZGRyZXNzIjtzOjQ5OiI0NSBTYW1wYWd1aXRhIFN0LiwgQnJneS4gU2FuIExvcmVuem8sIE1ha2F0aSBDaXR5Ijt9czo2OiJzdGF0dXMiO3M6NzoiaW52YWxpZCI7czo2OiJlcnJvcnMiO2E6NTp7aTowO3M6Mjg6IlRoZSBzZWxlY3RlZCBzZXggaXMgaW52YWxpZC4iO2k6MTtzOjQyOiJUaGUgYmlydGggZGF0ZSBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZGF0ZS4iO2k6MjtzOjM3OiJUaGUgc2VsZWN0ZWQgY2l2aWwgc3RhdHVzIGlzIGludmFsaWQuIjtpOjM7czo0MzoiVGhlIGNvbnRhY3QgbnVtYmVyIGZpZWxkIGZvcm1hdCBpcyBpbnZhbGlkLiI7aTo0O3M6NTQ6IlRoZSBlbWFpbCBhZGRyZXNzIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBlbWFpbCBhZGRyZXNzLiI7fX1pOjU7YTo0OntzOjEwOiJyb3dfbnVtYmVyIjtpOjY7czo0OiJkYXRhIjthOjExOntzOjEwOiJmaXJzdF9uYW1lIjtzOjk6IjIwMjYtMDEwMiI7czoxMToibWlkZGxlX25hbWUiO3M6NDoiSnVhbiI7czo5OiJsYXN0X25hbWUiO3M6MDoiIjtzOjM6InNleCI7czo5OiJEZWxhIENydXoiO3M6MTA6ImJpcnRoX2RhdGUiO3M6NDoibWFsZSI7czoxMjoiY2l2aWxfc3RhdHVzIjtzOjEwOiIxOTc1LTA5LTMwIjtzOjExOiJuYXRpb25hbGl0eSI7czo3OiJtYXJyaWVkIjtzOjEwOiJvY2N1cGF0aW9uIjtzOjg6IkZpbGlwaW5vIjtzOjE0OiJjb250YWN0X251bWJlciI7czoxNDoiQ2l2aWwgRW5naW5lZXIiO3M6NzoiYWRkcmVzcyI7czoxMToiMDkxNzU1NTEyMzQiO3M6MTM6ImVtYWlsX2FkZHJlc3MiO3M6NDg6IjEyIEthdGlwdW5hbiBBdmUuLCBCcmd5LiBCYWd1bWJheWFuLCBRdWV6b24gQ2l0eSI7fXM6Njoic3RhdHVzIjtzOjc6ImludmFsaWQiO3M6NjoiZXJyb3JzIjthOjY6e2k6MDtzOjMyOiJUaGUgbGFzdCBuYW1lIGZpZWxkIGlzIHJlcXVpcmVkLiI7aToxO3M6Mjg6IlRoZSBzZWxlY3RlZCBzZXggaXMgaW52YWxpZC4iO2k6MjtzOjQyOiJUaGUgYmlydGggZGF0ZSBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZGF0ZS4iO2k6MztzOjM3OiJUaGUgc2VsZWN0ZWQgY2l2aWwgc3RhdHVzIGlzIGludmFsaWQuIjtpOjQ7czo0MzoiVGhlIGNvbnRhY3QgbnVtYmVyIGZpZWxkIGZvcm1hdCBpcyBpbnZhbGlkLiI7aTo1O3M6NTQ6IlRoZSBlbWFpbCBhZGRyZXNzIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBlbWFpbCBhZGRyZXNzLiI7fX1pOjY7YTo0OntzOjEwOiJyb3dfbnVtYmVyIjtpOjc7czo0OiJkYXRhIjthOjExOntzOjEwOiJmaXJzdF9uYW1lIjtzOjk6IjIwMjYtMDEwMyI7czoxMToibWlkZGxlX25hbWUiO3M6NjoiQW5nZWxhIjtzOjk6Imxhc3RfbmFtZSI7czo1OiJSYW1vcyI7czozOiJzZXgiO3M6OToiRmVybmFuZGV6IjtzOjEwOiJiaXJ0aF9kYXRlIjtzOjY6ImZlbWFsZSI7czoxMjoiY2l2aWxfc3RhdHVzIjtzOjEwOiIyMDE0LTAzLTE1IjtzOjExOiJuYXRpb25hbGl0eSI7czo2OiJzaW5nbGUiO3M6MTA6Im9jY3VwYXRpb24iO3M6ODoiRmlsaXBpbm8iO3M6MTQ6ImNvbnRhY3RfbnVtYmVyIjtzOjA6IiI7czo3OiJhZGRyZXNzIjtzOjExOiIwOTE3MzMzNDQ1NSI7czoxMzoiZW1haWxfYWRkcmVzcyI7czo1MjoiOCBJbGFuZy1JbGFuZyBTdC4sIEJyZ3kuIFNhbiBJc2lkcm8sIFBhcmHDsWFxdWUgQ2l0eSI7fXM6Njoic3RhdHVzIjtzOjc6ImludmFsaWQiO3M6NjoiZXJyb3JzIjthOjU6e2k6MDtzOjI4OiJUaGUgc2VsZWN0ZWQgc2V4IGlzIGludmFsaWQuIjtpOjE7czo0MjoiVGhlIGJpcnRoIGRhdGUgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGRhdGUuIjtpOjI7czozNzoiVGhlIHNlbGVjdGVkIGNpdmlsIHN0YXR1cyBpcyBpbnZhbGlkLiI7aTozO3M6Mzc6IlRoZSBjb250YWN0IG51bWJlciBmaWVsZCBpcyByZXF1aXJlZC4iO2k6NDtzOjU0OiJUaGUgZW1haWwgYWRkcmVzcyBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZW1haWwgYWRkcmVzcy4iO319aTo3O2E6NDp7czoxMDoicm93X251bWJlciI7aTo4O3M6NDoiZGF0YSI7YToxMTp7czoxMDoiZmlyc3RfbmFtZSI7czo5OiIyMDI2LTAxMDQiO3M6MTE6Im1pZGRsZV9uYW1lIjtzOjc6IkFudG9uaW8iO3M6OToibGFzdF9uYW1lIjtzOjQ6IkNydXoiO3M6Mzoic2V4IjtzOjg6IkJhdXRpc3RhIjtzOjEwOiJiaXJ0aF9kYXRlIjtzOjQ6Im1hbGUiO3M6MTI6ImNpdmlsX3N0YXR1cyI7czoxMDoiMTk1MC0wMS0yMiI7czoxMToibmF0aW9uYWxpdHkiO3M6Nzoid2lkb3dlZCI7czoxMDoib2NjdXBhdGlvbiI7czo4OiJGaWxpcGlubyI7czoxNDoiY29udGFjdF9udW1iZXIiO3M6NzoiUmV0aXJlZCI7czo3OiJhZGRyZXNzIjtzOjExOiIwOTE3ODg4OTkwMCI7czoxMzoiZW1haWxfYWRkcmVzcyI7czozMjoiMjMwIFRhZnQgQXZlLiwgQnJneS4gNzAwLCBNYW5pbGEiO31zOjY6InN0YXR1cyI7czo3OiJpbnZhbGlkIjtzOjY6ImVycm9ycyI7YTo1OntpOjA7czoyODoiVGhlIHNlbGVjdGVkIHNleCBpcyBpbnZhbGlkLiI7aToxO3M6NDI6IlRoZSBiaXJ0aCBkYXRlIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBkYXRlLiI7aToyO3M6Mzc6IlRoZSBzZWxlY3RlZCBjaXZpbCBzdGF0dXMgaXMgaW52YWxpZC4iO2k6MztzOjQzOiJUaGUgY29udGFjdCBudW1iZXIgZmllbGQgZm9ybWF0IGlzIGludmFsaWQuIjtpOjQ7czo1NDoiVGhlIGVtYWlsIGFkZHJlc3MgZmllbGQgbXVzdCBiZSBhIHZhbGlkIGVtYWlsIGFkZHJlc3MuIjt9fWk6ODthOjQ6e3M6MTA6InJvd19udW1iZXIiO2k6OTtzOjQ6ImRhdGEiO2E6MTE6e3M6MTA6ImZpcnN0X25hbWUiO3M6OToiMjAyNi0wMTA1IjtzOjExOiJtaWRkbGVfbmFtZSI7czo1OiJTb2ZpYSI7czo5OiJsYXN0X25hbWUiO3M6MzoiTGltIjtzOjM6InNleCI7czo1OiJSZXllcyI7czoxMDoiYmlydGhfZGF0ZSI7czo2OiJmZW1hbGUiO3M6MTI6ImNpdmlsX3N0YXR1cyI7czoxMDoiMTk5NS0wNy0wOCI7czoxMToibmF0aW9uYWxpdHkiO3M6Njoic2luZ2xlIjtzOjEwOiJvY2N1cGF0aW9uIjtzOjg6IkZpbGlwaW5vIjtzOjE0OiJjb250YWN0X251bWJlciI7czo1OiJOdXJzZSI7czo3OiJhZGRyZXNzIjtzOjExOiIwOTE3NDQ0NTU2NiI7czoxMzoiZW1haWxfYWRkcmVzcyI7czo0NToiNSBCdXJnb3MgQ2lyY2xlLCBCcmd5LiBQb2JsYWNpb24sIE1ha2F0aSBDaXR5Ijt9czo2OiJzdGF0dXMiO3M6NzoiaW52YWxpZCI7czo2OiJlcnJvcnMiO2E6NTp7aTowO3M6Mjg6IlRoZSBzZWxlY3RlZCBzZXggaXMgaW52YWxpZC4iO2k6MTtzOjQyOiJUaGUgYmlydGggZGF0ZSBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZGF0ZS4iO2k6MjtzOjM3OiJUaGUgc2VsZWN0ZWQgY2l2aWwgc3RhdHVzIGlzIGludmFsaWQuIjtpOjM7czo0MzoiVGhlIGNvbnRhY3QgbnVtYmVyIGZpZWxkIGZvcm1hdCBpcyBpbnZhbGlkLiI7aTo0O3M6NTQ6IlRoZSBlbWFpbCBhZGRyZXNzIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBlbWFpbCBhZGRyZXNzLiI7fX1pOjk7YTo0OntzOjEwOiJyb3dfbnVtYmVyIjtpOjEwO3M6NDoiZGF0YSI7YToxMTp7czoxMDoiZmlyc3RfbmFtZSI7czo5OiIyMDI2LTAxMDYiO3M6MTE6Im1pZGRsZV9uYW1lIjtzOjU6IlJhbW9uIjtzOjk6Imxhc3RfbmFtZSI7czo3OiJTYWxhemFyIjtzOjM6InNleCI7czoxMDoiVmlsbGFudWV2YSI7czoxMDoiYmlydGhfZGF0ZSI7czo0OiJtYWxlIjtzOjEyOiJjaXZpbF9zdGF0dXMiO3M6MTA6IjE5ODAtMTEtMTciO3M6MTE6Im5hdGlvbmFsaXR5IjtzOjk6InNlcGFyYXRlZCI7czoxMDoib2NjdXBhdGlvbiI7czo4OiJGaWxpcGlubyI7czoxNDoiY29udGFjdF9udW1iZXIiO3M6MTQ6IkJ1c2luZXNzIE93bmVyIjtzOjc6ImFkZHJlc3MiO3M6MTE6IjA5MTc1NTU2Njc3IjtzOjEzOiJlbWFpbF9hZGRyZXNzIjtzOjQ2OiIyMiBPcnRpZ2FzIEF2ZS4sIEJyZ3kuIFNhbiBBbnRvbmlvLCBQYXNpZyBDaXR5Ijt9czo2OiJzdGF0dXMiO3M6NzoiaW52YWxpZCI7czo2OiJlcnJvcnMiO2E6NTp7aTowO3M6Mjg6IlRoZSBzZWxlY3RlZCBzZXggaXMgaW52YWxpZC4iO2k6MTtzOjQyOiJUaGUgYmlydGggZGF0ZSBmaWVsZCBtdXN0IGJlIGEgdmFsaWQgZGF0ZS4iO2k6MjtzOjM3OiJUaGUgc2VsZWN0ZWQgY2l2aWwgc3RhdHVzIGlzIGludmFsaWQuIjtpOjM7czo0MzoiVGhlIGNvbnRhY3QgbnVtYmVyIGZpZWxkIGZvcm1hdCBpcyBpbnZhbGlkLiI7aTo0O3M6NTQ6IlRoZSBlbWFpbCBhZGRyZXNzIGZpZWxkIG11c3QgYmUgYSB2YWxpZCBlbWFpbCBhZGRyZXNzLiI7fX19czo3OiJleHBpcmVzIjtPOjI1OiJJbGx1bWluYXRlXFN1cHBvcnRcQ2FyYm9uIjozOntzOjQ6ImRhdGUiO3M6MjY6IjIwMjYtMDgtMDkgMjA6MzI6MTEuNjMwNDU2IjtzOjEzOiJ0aW1lem9uZV90eXBlIjtpOjM7czo4OiJ0aW1lem9uZSI7czoxMToiQXNpYS9NYW5pbGEiO319fX0=',1786276931),
('JI6yKy9BLR0duci591ribQeZIMq4EOtZB2CG8KLN',NULL,'127.0.0.1','curl/8.7.1','YTozOntzOjY6Il90b2tlbiI7czo0MDoiTWdscThhVVhIRTRBTVBiVTFRa3hva3FXa3lJMU5VaVVYN2lNdXVWeiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1786266269),
('mfNjpXGtHohlLqO8fAIU4ygtZ6VpGxLn7vZu4Gxs',NULL,'127.0.0.1','curl/8.7.1','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiR3Q0OU9zdjFtRFZPNVRaUW9XWGQxU1NCZzBaenRUNWpzeXhscFJCQiI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozMzoiaHR0cDovL2xvY2FsaG9zdDo4MDAwL2NvbnNlbnRzLzI4Ijt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9jb25zZW50cy8yOCI7czo1OiJyb3V0ZSI7czoxMzoiY29uc2VudHMuc2hvdyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1786268897),
('QDvFtjBBcOFZnuRCZfGTDplHHIvWQinFB3lOvVO7',1,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.7922.34 Safari/537.36','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiMElDTUd3QVJVSG5OWlVWNFhHOWpFRUFNVGVPeVJNOGpkd0RmQjBqMiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9jb25zZW50cy8yOCI7czo1OiJyb3V0ZSI7czoxMzoiY29uc2VudHMuc2hvdyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==',1786269362),
('T6F5OWAmfkQUT5JvAcyRsJuiIMqAoBwwjMPZHPsk',1,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','YTo2OntzOjY6Il90b2tlbiI7czo0MDoiVTVJOVN3ZU5HTm5jNE9kdjVQdjdweURHd1Vrd3AzSmM4blV3T0RwOCI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjMwOiJodHRwOi8vbG9jYWxob3N0OjgwMDAvcGF0aWVudHMiO3M6NToicm91dGUiO3M6MTQ6InBhdGllbnRzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTtzOjE0OiJwYXRpZW50LWltcG9ydCI7YToyOntzOjQwOiJ3eHQ3NHcwOEtpdWpGaE10MktEd2h0YnZaTEVwalhJZjN0ejhIcEZ6IjthOjI6e3M6NDoicm93cyI7YToxOntpOjA7YTo0OntzOjEwOiJyb3dfbnVtYmVyIjtpOjE7czo0OiJkYXRhIjthOjExOntzOjEwOiJmaXJzdF9uYW1lIjtzOjQ6IlRlc3QiO3M6MTE6Im1pZGRsZV9uYW1lIjtzOjg6IkltcG9ydGVkIjtzOjk6Imxhc3RfbmFtZSI7czo3OiJQYXRpZW50IjtzOjM6InNleCI7czo0OiJtYWxlIjtzOjEwOiJiaXJ0aF9kYXRlIjtzOjEwOiIxOTk1LTA1LTA1IjtzOjEyOiJjaXZpbF9zdGF0dXMiO3M6Njoic2luZ2xlIjtzOjExOiJuYXRpb25hbGl0eSI7czo4OiJGaWxpcGlubyI7czoxMDoib2NjdXBhdGlvbiI7czo3OiJEZW50aXN0IjtzOjE0OiJjb250YWN0X251bWJlciI7czoxMToiMDkxNzEyMzQ1NjciO3M6NzoiYWRkcmVzcyI7czoxMjoiMTIzIFRlc3QgU3QuIjtzOjEzOiJlbWFpbF9hZGRyZXNzIjtzOjIzOiJ0ZXN0LmltcG9ydEBleGFtcGxlLmNvbSI7fXM6Njoic3RhdHVzIjtzOjk6ImR1cGxpY2F0ZSI7czo2OiJlcnJvcnMiO2E6MDp7fX19czo3OiJleHBpcmVzIjtPOjI1OiJJbGx1bWluYXRlXFN1cHBvcnRcQ2FyYm9uIjozOntzOjQ6ImRhdGUiO3M6MjY6IjIwMjYtMDgtMDkgMjA6MDI6NDYuMjgzOTU2IjtzOjEzOiJ0aW1lem9uZV90eXBlIjtpOjM7czo4OiJ0aW1lem9uZSI7czoxMToiQXNpYS9NYW5pbGEiO319czo0MDoielYwQ3RmdUhBamxvcVducUxtOEJ0S3ZYTTBKSDIwVUh2VFcxd0FrQiI7YToyOntzOjQ6InJvd3MiO2E6MTp7aTowO2E6NDp7czoxMDoicm93X251bWJlciI7aToxO3M6NDoiZGF0YSI7YToxMTp7czoxMDoiZmlyc3RfbmFtZSI7czo0OiJUZXN0IjtzOjExOiJtaWRkbGVfbmFtZSI7czo4OiJJbXBvcnRlZCI7czo5OiJsYXN0X25hbWUiO3M6NzoiUGF0aWVudCI7czozOiJzZXgiO3M6NDoibWFsZSI7czoxMDoiYmlydGhfZGF0ZSI7czoxMDoiMTk5NS0wNS0wNSI7czoxMjoiY2l2aWxfc3RhdHVzIjtzOjY6InNpbmdsZSI7czoxMToibmF0aW9uYWxpdHkiO3M6ODoiRmlsaXBpbm8iO3M6MTA6Im9jY3VwYXRpb24iO3M6NzoiRGVudGlzdCI7czoxNDoiY29udGFjdF9udW1iZXIiO3M6MTE6IjA5MTcxMjM0NTY3IjtzOjc6ImFkZHJlc3MiO3M6MTI6IjEyMyBUZXN0IFN0LiI7czoxMzoiZW1haWxfYWRkcmVzcyI7czoyMzoidGVzdC5pbXBvcnRAZXhhbXBsZS5jb20iO31zOjY6InN0YXR1cyI7czozOiJuZXciO3M6NjoiZXJyb3JzIjthOjA6e319fXM6NzoiZXhwaXJlcyI7TzoyNToiSWxsdW1pbmF0ZVxTdXBwb3J0XENhcmJvbiI6Mzp7czo0OiJkYXRlIjtzOjI2OiIyMDI2LTA4LTA5IDIwOjA0OjI4LjE2NzY1NiI7czoxMzoidGltZXpvbmVfdHlwZSI7aTozO3M6ODoidGltZXpvbmUiO3M6MTE6IkFzaWEvTWFuaWxhIjt9fX19',1786275308),
('uMVdGJcGsDrHSqnewzxWgqHlKx25eyND15SkwOkr',NULL,'127.0.0.1','curl/8.7.1','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiNGJ2bUN4VXVxU1N2VHMyZWlnV2UzTUF0U1VGVDAxN1VqTVpId3IzeSI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozNjoiaHR0cDovL2xvY2FsaG9zdDo4MDAwL3BhdGllbnRzLzkvcGRmIjt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzY6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9wYXRpZW50cy85L3BkZiI7czo1OiJyb3V0ZSI7czoxMjoicGF0aWVudHMucGRmIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1786266269),
('W2VmnKl923TzTqso0SyPalb1REhRAimLpDjbrBNU',NULL,'127.0.0.1','curl/8.7.1','YTo0OntzOjY6Il90b2tlbiI7czo0MDoiaTR5Q0pQSVlSV3VWTzJrak9nY1hrZVJuZ0cwVzBCcWo5MGh1SDE4UiI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozNjoiaHR0cDovL2xvY2FsaG9zdDo4MDAwL3BhdGllbnRzLzkvcGRmIjt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzY6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9wYXRpZW50cy85L3BkZiI7czo1OiJyb3V0ZSI7czoxMjoicGF0aWVudHMucGRmIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1786266387);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `value` text DEFAULT NULL,
  `group` varchar(255) NOT NULL DEFAULT 'general',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `settings_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `settings` VALUES
(1,'clinic.name','Jerrmond Dental Clinic','general','2026-08-05 04:52:11','2026-08-06 12:42:54'),
(2,'clinic.address',NULL,'general','2026-08-05 04:52:11','2026-08-05 05:12:45'),
(3,'consent.version','1.0','general','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(4,'patient.number.prefix','year','general','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(5,'appointment.overlap','false','general','2026-08-05 04:52:11','2026-08-05 05:13:14'),
(6,'attachment.max_size_mb','25','general','2026-08-05 04:52:11','2026-08-05 04:52:11'),
(7,'archive.inactivity_years','5','general','2026-08-05 04:52:11','2026-08-05 04:52:11');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `treatments`
--

DROP TABLE IF EXISTS `treatments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `treatments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `consultation_id` bigint(20) unsigned DEFAULT NULL,
  `tooth_number` tinyint(3) unsigned DEFAULT NULL,
  `procedure_name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `dentist_id` bigint(20) unsigned NOT NULL,
  `treatment_date` date NOT NULL,
  `signature_path` varchar(255) DEFAULT NULL,
  `signed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `treatments_consultation_id_foreign` (`consultation_id`),
  KEY `treatments_dentist_id_foreign` (`dentist_id`),
  KEY `treatments_patient_id_treatment_date_index` (`patient_id`,`treatment_date`),
  CONSTRAINT `treatments_consultation_id_foreign` FOREIGN KEY (`consultation_id`) REFERENCES `consultations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `treatments_dentist_id_foreign` FOREIGN KEY (`dentist_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `treatments_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `treatments`
--

LOCK TABLES `treatments` WRITE;
/*!40000 ALTER TABLE `treatments` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `treatments` VALUES
(1,1,1,26,'Composite restoration','Composite filling on tooth 26',NULL,2,'2026-07-18','signatures/treatments/1.svg','2026-07-18 02:15:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(2,4,2,NULL,'Scaling and polishing','Full-mouth scaling and polishing',NULL,2,'2026-06-25','signatures/treatments/2.svg','2026-06-25 06:05:00','2026-08-05 04:52:12','2026-08-05 04:52:12'),
(3,2,NULL,NULL,'Scaling and polishing','Routine prophylaxis',NULL,2,'2026-07-22','signatures/treatments/3.svg','2026-08-09 06:42:34','2026-08-05 04:52:12','2026-08-09 06:42:34'),
(4,6,NULL,48,'Extraction','Extraction of impacted lower right third molar',NULL,2,'2026-07-05',NULL,NULL,'2026-08-05 04:52:12','2026-08-05 04:52:12'),
(5,3,4,12,'Extraction',NULL,NULL,1,'2026-08-06','signatures/treatments/5.svg','2026-08-06 09:56:36','2026-08-06 09:56:28','2026-08-06 09:56:36'),
(6,8,NULL,NULL,'Root canal treatment',NULL,NULL,1,'2026-08-06','signatures/treatments/6.svg','2026-08-06 11:25:49','2026-08-06 11:25:35','2026-08-06 11:25:49'),
(19,9,21,NULL,'Extraction',NULL,NULL,1,'2026-08-06','signatures/treatments/19.svg','2026-08-06 14:08:49','2026-08-06 14:08:41','2026-08-06 14:08:49'),
(20,9,NULL,NULL,'Amalgam filling','qweqw','qwe',1,'2026-08-09','signatures/treatments/20.svg','2026-08-09 06:34:21','2026-08-09 06:34:14','2026-08-09 06:34:21'),
(21,2,25,NULL,'Amalgam filling','weqqwe','qwe',2,'2026-08-09','signatures/treatments/21.svg','2026-08-09 06:42:31','2026-08-09 06:41:15','2026-08-09 06:42:31'),
(22,2,26,12,'Amalgam filling','qweqwe','qwe',2,'2026-08-09','signatures/treatments/22.svg','2026-08-09 06:42:29','2026-08-09 06:42:24','2026-08-09 06:42:29'),
(23,9,NULL,NULL,'test',NULL,NULL,2,'2026-08-09','signatures/treatments/23.svg','2026-08-09 06:59:21','2026-08-09 06:57:47','2026-08-09 06:59:21'),
(24,9,NULL,23,'Crown placement','qweqwe','qweqwe',2,'2026-08-09',NULL,NULL,'2026-08-09 06:59:41','2026-08-09 06:59:41'),
(25,9,28,22,'Extraction','removal of tooth',NULL,2,'2026-08-09','signatures/treatments/25.svg','2026-08-09 07:02:03','2026-08-09 07:01:59','2026-08-09 07:02:03'),
(26,10,29,26,'Extraction','extraction',NULL,1,'2026-08-09','signatures/treatments/26.svg','2026-08-09 08:01:44','2026-08-09 08:01:36','2026-08-09 08:01:44');
/*!40000 ALTER TABLE `treatments` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_username_unique` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `users` VALUES
(1,'Administrator','admin','admin@test.com',NULL,'$2y$12$Cy8c4ZKA6kEU3mlXodWWqubnO7Mtm599mdCjDW4wxK0.jYlx/mk72',1,'fUFFdKmfGPMf0ePSbNU2E6bqWSgZl5mEl4CqMF91OKiVs2dZVY9anF1xun1B','2026-08-05 04:52:11','2026-08-09 08:31:36'),
(2,'Jerrmond De Jesus','dentist','dentist@test.com',NULL,'$2y$12$PkIgAopJ8vL6aCvZ/8ePXetYjDlrfZFgQ5HwaPGUyuJ2q1Mblr2eu',1,NULL,'2026-08-05 04:52:11','2026-08-09 08:31:36'),
(3,'Mia Santos','assistant','assistant@test.com',NULL,'$2y$12$w.IWCvLuDMN/YhDBQZL9x.hVTcAv8tgGHPfasc2EaXx6tDYZfOAqq',1,NULL,'2026-08-05 04:52:12','2026-08-09 08:31:37'),
(4,'Joy Cruz','receptionist','receptionist@test.com',NULL,'$2y$12$2yHK.wbAf.4rABIl4q1JK.g/6r.Xwq.fJ1yC.F2PJHcFxjezKJOX2',1,NULL,'2026-08-05 04:52:12','2026-08-09 08:31:37');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-08-09 21:15:22
