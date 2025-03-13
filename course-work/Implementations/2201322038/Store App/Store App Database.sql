-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: ecommerce
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,'admin','$2b$12$GEGi7n9u.C245fhVTMI8FeKR75adWqRgA5aL2FWmk2Cb5QiVg17Hm');
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `finished_orders`
--

DROP TABLE IF EXISTS `finished_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `finished_orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` varchar(255) NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `order_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`),
  KEY `user_id` (`user_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `finished_orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `finished_orders_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_code`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `finished_orders`
--

LOCK TABLES `finished_orders` WRITE;
/*!40000 ALTER TABLE `finished_orders` DISABLE KEYS */;
INSERT INTO `finished_orders` VALUES (1,4,'1000097',7,0.49,'2025-03-04 11:21:44'),(2,4,'1000437',2,3.28,'2025-03-04 11:21:44'),(3,4,'1000801',1,2.23,'2025-03-04 11:21:44'),(4,4,'1001129',3,136.32,'2025-03-04 11:21:44'),(5,4,'1001208',2,3.76,'2025-03-04 11:21:44'),(6,4,'1001296',1,2.23,'2025-03-04 11:21:44'),(7,4,'1001210',4,3.55,'2025-03-04 11:21:44'),(8,4,'1001297',1,2.05,'2025-03-04 11:21:44'),(9,4,'1001310',6,4.49,'2025-03-04 11:21:44'),(10,5,'1002954',1,3.80,'2025-03-04 11:21:44'),(11,5,'1002878',1,5.08,'2025-03-04 11:21:44'),(12,5,'1002879',1,4.27,'2025-03-04 11:21:44'),(13,5,'1003007',1,1.12,'2025-03-04 11:21:44'),(14,5,'1003175',1,17.44,'2025-03-04 11:21:44'),(15,5,'1003082',4,80.76,'2025-03-04 11:21:44'),(16,4,'1004350',1,1.10,'2025-03-04 11:21:44');
/*!40000 ALTER TABLE `finished_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` varchar(45) DEFAULT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_id`),
  KEY `user_id` (`user_id`),
  KEY `fk_product_code` (`product_id`),
  CONSTRAINT `fk_product_code` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_code`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_code` varchar(45) NOT NULL,
  `name` varchar(255) NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`product_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES ('1000097','Olympus шоколадова напитка Шоко енерджи 200 мл.',24,0.49),('1000437','EKLEKTON ЦЕД. ПРОДУКТ 900 гр.',6,3.28),('1000801','Olympus Пастьоризирана Извара 5% 400 гр.',6,2.23),('1001095','Olympus Овче Сирене 800 гр.',5,10.96),('1001129','Olympus Краве Сирене 2 кг. - вакуум',6,136.32),('1001208','Olympus Натурален Сок Портокал 1 л.',12,3.76),('1001210','Olympus Натурален Сок Арония 1 л.',12,3.55),('1001296','Olympus Млечна сметана 35% масл. 200 мл.',24,2.23),('1001297','Olympus Млечна сметана 20% масл. 200 мл.',24,2.05),('1001310','Olympus Краве масло 82% 200 гр.',12,4.49),('1001401','Olympus Цедено мляко 10% 1 кг.',6,5.28),('1001402','Olympus Цедено мляко 2% 1 кг.',6,4.97),('1001404','TYRAS ЦЕД. ПРОДУКТ 25 кг. ',1,78.54),('1001405','EKLEKTON ЦЕД. ПРОДУКТ 5 кг.',1,15.96),('1001409','Olympus Цедено мляко 10% 350 гр.',12,2.10),('1001417','Olympus Био Прясно мляко 3,5% масл. 1 л.',12,2.80),('1001418','Olympus Прясно козе мляко 3,5% масл. 1 л.',12,3.82),('1001420','Olympus Заквасена сметана 20% 350 гр.',12,2.03),('1001421','Olympus Кефир 330 мл.',12,1.02),('1001430','Olympus Овче Сирене 350 гр.',6,5.48),('1001433','Olympus Козе Сирене 350 гр.',6,5.48),('1001438','Olympus Краве Сирене 10 кг. - кофа',1,103.49),('1001649','Olympus Натурален Сок Морков 1 л.',12,3.55),('1001651','Olympus Натурален Сок Морков 250 мл.',12,1.08),('1001742','Olympus Бадемова напитка подсладена 1 л.',12,3.56),('1001743','Olympus Бадемова напитка без захар 1 л.',12,3.56),('1001744','Olympus Напитка от шамфъстък подсладена 1л л.',12,3.80),('1001762','Млечна сметана от краве мляко 36% масл. 1 л.',12,8.06),('1001763','Olympus Био Kисело Мляко 3.6% 400 гр.',12,1.13),('1001795','Olympus Цедено мляко 10% 5 кг.',1,23.35),('1001818','Olympus Котидж Сирене 180 гр.',6,1.82),('1001833','Прясно Мляко Baron UHT 3.5% масл. 1 л.',12,2.24),('1001886','Delicio Lumi Напитка 3.6% масл. 1л.',12,1.55),('1001978','Olympus Фета 400 гр.',12,8.22),('1002011','Olympus Планински чай Арония 500 мл.',12,1.10),('1002012','Olympus Планински чай Лимон 500 мл.',12,1.10),('1002013','Olympus Планински чай Мента 500 мл.',12,1.10),('1002014','Olympus Планински чай Праскова 500 мл.',12,1.10),('1002032','Olympus Био Кефир 330 мл.',12,1.12),('1002296','Olympus Крема сирене 200 гр.',6,2.14),('1002507','Olympus Айрян 330 мл.',12,0.68),('1002514','Olympus шоколадова напитка Банана енерджи 200 мл.',24,0.59),('1002546','Olympus шоколадова напитка Ванила енерджи 200 мл.',24,0.59),('1002582','Olympus Натурален Сок Цитруси 1 л.',12,3.55),('1002768','Olympus Заквасена сметана 20% 5 кг.',1,24.36),('1002842','Olympus Планински чай Праскова 1,5 л.',6,3.14),('1002878','Olympus Натурален Сок Портокал 1,5л.',6,5.08),('1002879','Olympus Настъргано пекорино 150 гр.',6,4.27),('1002954','Olympus Напитка от овес и лешник 1 л.',12,3.80),('1002955','Olympus Напитка от овес 1 л.',12,3.80),('1002956','Olympus Напитка от кокос без захар 1 л.',12,3.80),('1003007','Olympus Йогурт Праскова 150 гр.',6,1.12),('1003082','Olympus Фета 1 кг.',4,20.19),('1003175','Olympus Крема сирене 2 кг.',1,17.44),('1003218','Olympus Натурален Сок 9 Червени Плода 1 л.',12,3.55),('1003220','Olympus Краве Сирене 400 гр. - тенекия',6,6.43),('1003258','КЛЯФА ПОРТОКАЛАДА 6x330мл Кен',1,3.37),('1003259','КЛЯФА ЛИМОНАДА 6x330мл Кен',1,3.37),('1003260','КЛЯФА СОДА 6x330мл Кен',1,2.93),('1003318','КЛЯФА ЛИМОНАДА 6х330мл PET',1,5.80),('1003319','КЛЯФА ВИШИНАДА 6х330мл PET',1,5.80),('1003320','КЛЯФА ЛИМОН И ЛАЙМ 6х330мл PET',1,5.80),('1003321','КЛЯФА ПОРТОКАЛАДА 6х330мл PET',1,5.80),('1003375','Olympus Фета 200 гр.',12,4.32),('1003377','Olympus Краве Сирене 300 гр. - вакуум',7,4.26),('1003528','Olympus Десерт Шоколад 170 гр.',6,1.38),('1003529','Olympus Мляко с Ориз 170 гр.',6,1.38),('1003530','Olympus Десерт Ванилия 170 гр.',6,1.38),('1003698','Olympus Кашкавал от Краве Мляко 400 гр.',6,8.83),('1003806','Грил сирене мезе Olympus 200 гр.',14,3.85),('1003861','Olympus Пастьоризирана Извара 1,8% 10 кг.',1,42.67),('1004065','Olympus Kисело мляко 4.5% 400 гр.',12,1.03),('1004066','Olympus Kисело мляко 3.6% 400 гр.',12,1.01),('1004087','Olympus Напитка с орех 1 л.',12,3.80),('1004144','Olympus Кефир Ягода 330 мл.',12,1.13),('1004145','Olympus Кефир Горски плодове 330 мл.',12,1.13),('1004203','Olympus Натурален Сок Портокал - Ябълка 250 мл.',12,1.08),('1004205','Olympus Натурален Сок Портокал - Ябълка 1,5 л.',6,4.87),('1004212','Olympus Натурален Сок 9 Жълти Плода 1 л.',12,3.55),('1004213','Olympus Натурален Сок 9 Жълти Плода 250 мл.',12,1.08),('1004295','Olympus Черен чай Праскова 500 мл.',12,1.10),('1004296','Olympus Зелен чай Ягода 500 мл.',12,1.10),('1004304','Olympus Овче Кисело мляко 240 гр.',6,1.92),('1004350','Olympus Зелен чай Тропически 500 мл.',12,1.10),('1004412','Olympus Натурален Сок Портокал - Ябълка 1 л.',12,3.55),('1004413','Olympus натурален Сок 100% Праскова 1л ',12,3.55),('1004414','Olympus Прясно мляко 3,7% масл. 1,5 л .',6,3.26),('1004415','Olympus Прясно мляко 1,7% масл. 1 л .',12,1.84),('1004448','Olympus Йогурт по гръцка рецепта 2% 150 гр.',6,0.95),('1004449','Olympus Йогурт по гръцка рецепта 10% 150 гр.',6,0.95);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'unknown','$2b$12$M2W3hS3KALJV3LKpWOo24Ov/s1mnOOxNNIS1/8CGk1ZhrO.Z6E306'),(2,'unknown2','$2b$12$14d8w7UqQImFZJQQbdSK5OM2pu5f/GOaZzeZa6YAVyaRflJCKrDhS'),(3,'unknown3','$2b$12$FBo2d/HBmTwP/R42qobwAeFi1Leak8DMLVCbVDR9K6wmRiSJJcdsy'),(4,'m.stanoichev','$2b$12$9GAbrBvZa4fBNiRRkM57CeWMws11gVg9Tq4w4roHN/sFLtHPtOhh6'),(5,'ivo','$2b$12$PIH3HiQaBWBO0m4bIWvpsuN779B0VILTfjBRFcAGea9.FdzwN1dEe'),(7,'m.stanoichev2','$2b$12$g/ltKtYa8.cMIL/CHCUMJ.7Dn9cn.xGZShV8SGu/qLmzhKtFyAUbq'),(8,'test_testov','$2b$12$qlV8Fw4/L7ul63syXUYQ7uFdyIE2YFALvMOev0jzRAQsBli5jTK4.');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-03-05 10:17:41
