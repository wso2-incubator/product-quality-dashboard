-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Oct 19, 2017 at 02:26 PM
-- Server version: 5.7.19-0ubuntu0.16.04.1
-- PHP Version: 7.0.24-1+ubuntu16.04.1+deb.sury.org+1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pqd_issues_sonar_db`
--
CREATE DATABASE IF NOT EXISTS `pqd_issues_sonar_db` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `pqd_issues_sonar_db`;

-- --------------------------------------------------------

--
-- Table structure for table `pqd_area`
--

CREATE TABLE `pqd_area` (
  `pqd_area_id` int(11) NOT NULL,
  `pqd_area_name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pqd_area`
--

INSERT INTO `pqd_area` (`pqd_area_id`, `pqd_area_name`) VALUES
(1, 'API Management'),
(2, 'Analytics'),
(3, 'Ballerina'),
(4, 'Cloud'),
(5, 'IAM'),
(6, 'Integration'),
(7, 'IoT'),
(8, 'Platform'),
(9, 'Platform Extension'),
(10, 'Other');

-- --------------------------------------------------------

--
-- Table structure for table `pqd_area_issues`
--

CREATE TABLE `pqd_area_issues` (
  `pqd_area_id` int(11) NOT NULL,
  `pqd_issue_type_id` int(11) NOT NULL,
  `pqd_severity_id` int(11) NOT NULL,
  `pqd_issues_count` int(11) NOT NULL,
  `pqd_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pqd_area_issues`
--

INSERT INTO `pqd_area_issues` (`pqd_area_id`, `pqd_issue_type_id`, `pqd_severity_id`, `pqd_issues_count`, `pqd_updated`) VALUES
(1, 1, 1, 1, '2017-10-19 03:51:09'),
(1, 1, 2, 1, '2017-10-19 03:51:09'),
(1, 1, 3, 0, '2017-10-19 03:51:09'),
(1, 1, 4, 0, '2017-10-19 03:51:09'),
(1, 1, 6, 0, '2017-10-19 03:51:09'),
(1, 1, 7, 5, '2017-10-19 03:51:09'),
(1, 2, 1, 0, '2017-10-19 03:51:09'),
(1, 2, 2, 0, '2017-10-19 03:51:09'),
(1, 2, 3, 0, '2017-10-19 03:51:09'),
(1, 2, 4, 0, '2017-10-19 03:51:09'),
(1, 2, 6, 0, '2017-10-19 03:51:09'),
(1, 2, 7, 0, '2017-10-19 03:51:09'),
(1, 5, 1, 0, '2017-10-19 03:51:09'),
(1, 5, 2, 0, '2017-10-19 03:51:09'),
(1, 5, 3, 0, '2017-10-19 03:51:09'),
(1, 5, 4, 0, '2017-10-19 03:51:09'),
(1, 5, 6, 0, '2017-10-19 03:51:09'),
(1, 5, 7, 0, '2017-10-19 03:51:09'),
(1, 6, 1, 0, '2017-10-19 03:51:09'),
(1, 6, 2, 0, '2017-10-19 03:51:09'),
(1, 6, 3, 0, '2017-10-19 03:51:09'),
(1, 6, 4, 0, '2017-10-19 03:51:09'),
(1, 6, 6, 0, '2017-10-19 03:51:09'),
(1, 6, 7, 0, '2017-10-19 03:51:09'),
(1, 7, 1, 0, '2017-10-19 03:51:09'),
(1, 7, 2, 0, '2017-10-19 03:51:09'),
(1, 7, 3, 0, '2017-10-19 03:51:09'),
(1, 7, 4, 0, '2017-10-19 03:51:09'),
(1, 7, 6, 0, '2017-10-19 03:51:09'),
(1, 7, 7, 0, '2017-10-19 03:51:09'),
(1, 8, 1, 0, '2017-10-19 03:51:09'),
(1, 8, 2, 0, '2017-10-19 03:51:09'),
(1, 8, 3, 0, '2017-10-19 03:51:09'),
(1, 8, 4, 0, '2017-10-19 03:51:09'),
(1, 8, 6, 0, '2017-10-19 03:51:09'),
(1, 8, 7, 0, '2017-10-19 03:51:09'),
(1, 9, 1, 0, '2017-10-19 03:51:09'),
(1, 9, 2, 0, '2017-10-19 03:51:09'),
(1, 9, 3, 0, '2017-10-19 03:51:09'),
(1, 9, 4, 0, '2017-10-19 03:51:09'),
(1, 9, 6, 0, '2017-10-19 03:51:09'),
(1, 9, 7, 0, '2017-10-19 03:51:09'),
(1, 10, 1, 0, '2017-10-19 03:51:09'),
(1, 10, 2, 4, '2017-10-19 03:51:09'),
(1, 10, 3, 0, '2017-10-19 03:51:09'),
(1, 10, 4, 0, '2017-10-19 03:51:09'),
(1, 10, 6, 0, '2017-10-19 03:51:09'),
(1, 10, 7, 51, '2017-10-19 03:51:09'),
(2, 1, 1, 1, '2017-10-19 03:51:09'),
(2, 1, 2, 0, '2017-10-19 03:51:09'),
(2, 1, 3, 0, '2017-10-19 03:51:09'),
(2, 1, 4, 0, '2017-10-19 03:51:09'),
(2, 1, 6, 0, '2017-10-19 03:51:09'),
(2, 1, 7, 10, '2017-10-19 03:51:09'),
(2, 2, 1, 0, '2017-10-19 03:51:09'),
(2, 2, 2, 0, '2017-10-19 03:51:09'),
(2, 2, 3, 0, '2017-10-19 03:51:09'),
(2, 2, 4, 0, '2017-10-19 03:51:09'),
(2, 2, 6, 0, '2017-10-19 03:51:09'),
(2, 2, 7, 1, '2017-10-19 03:51:09'),
(2, 5, 1, 0, '2017-10-19 03:51:09'),
(2, 5, 2, 0, '2017-10-19 03:51:09'),
(2, 5, 3, 0, '2017-10-19 03:51:09'),
(2, 5, 4, 0, '2017-10-19 03:51:09'),
(2, 5, 6, 0, '2017-10-19 03:51:09'),
(2, 5, 7, 0, '2017-10-19 03:51:09'),
(2, 6, 1, 0, '2017-10-19 03:51:09'),
(2, 6, 2, 0, '2017-10-19 03:51:09'),
(2, 6, 3, 0, '2017-10-19 03:51:09'),
(2, 6, 4, 0, '2017-10-19 03:51:09'),
(2, 6, 6, 0, '2017-10-19 03:51:09'),
(2, 6, 7, 0, '2017-10-19 03:51:09'),
(2, 7, 1, 0, '2017-10-19 03:51:09'),
(2, 7, 2, 0, '2017-10-19 03:51:09'),
(2, 7, 3, 0, '2017-10-19 03:51:09'),
(2, 7, 4, 0, '2017-10-19 03:51:09'),
(2, 7, 6, 0, '2017-10-19 03:51:09'),
(2, 7, 7, 0, '2017-10-19 03:51:09'),
(2, 8, 1, 0, '2017-10-19 03:51:09'),
(2, 8, 2, 0, '2017-10-19 03:51:09'),
(2, 8, 3, 0, '2017-10-19 03:51:09'),
(2, 8, 4, 0, '2017-10-19 03:51:09'),
(2, 8, 6, 0, '2017-10-19 03:51:09'),
(2, 8, 7, 0, '2017-10-19 03:51:09'),
(2, 9, 1, 0, '2017-10-19 03:51:09'),
(2, 9, 2, 0, '2017-10-19 03:51:09'),
(2, 9, 3, 0, '2017-10-19 03:51:09'),
(2, 9, 4, 0, '2017-10-19 03:51:09'),
(2, 9, 6, 0, '2017-10-19 03:51:09'),
(2, 9, 7, 0, '2017-10-19 03:51:09'),
(2, 10, 1, 0, '2017-10-19 03:51:09'),
(2, 10, 2, 1, '2017-10-19 03:51:09'),
(2, 10, 3, 1, '2017-10-19 03:51:09'),
(2, 10, 4, 0, '2017-10-19 03:51:09'),
(2, 10, 6, 0, '2017-10-19 03:51:09'),
(2, 10, 7, 114, '2017-10-19 03:51:09'),
(3, 1, 1, 79, '2017-10-19 03:51:09'),
(3, 1, 2, 15, '2017-10-19 03:51:09'),
(3, 1, 3, 14, '2017-10-19 03:51:09'),
(3, 1, 4, 49, '2017-10-19 03:51:09'),
(3, 1, 6, 2, '2017-10-19 03:51:09'),
(3, 1, 7, 71, '2017-10-19 03:51:09'),
(3, 2, 1, 9, '2017-10-19 03:51:09'),
(3, 2, 2, 0, '2017-10-19 03:51:09'),
(3, 2, 3, 0, '2017-10-19 03:51:09'),
(3, 2, 4, 8, '2017-10-19 03:51:09'),
(3, 2, 6, 6, '2017-10-19 03:51:09'),
(3, 2, 7, 86, '2017-10-19 03:51:09'),
(3, 5, 1, 0, '2017-10-19 03:51:09'),
(3, 5, 2, 0, '2017-10-19 03:51:09'),
(3, 5, 3, 0, '2017-10-19 03:51:09'),
(3, 5, 4, 0, '2017-10-19 03:51:09'),
(3, 5, 6, 0, '2017-10-19 03:51:09'),
(3, 5, 7, 0, '2017-10-19 03:51:09'),
(3, 6, 1, 0, '2017-10-19 03:51:09'),
(3, 6, 2, 0, '2017-10-19 03:51:09'),
(3, 6, 3, 0, '2017-10-19 03:51:09'),
(3, 6, 4, 0, '2017-10-19 03:51:09'),
(3, 6, 6, 0, '2017-10-19 03:51:09'),
(3, 6, 7, 6, '2017-10-19 03:51:09'),
(3, 7, 1, 0, '2017-10-19 03:51:09'),
(3, 7, 2, 0, '2017-10-19 03:51:09'),
(3, 7, 3, 0, '2017-10-19 03:51:09'),
(3, 7, 4, 0, '2017-10-19 03:51:09'),
(3, 7, 6, 0, '2017-10-19 03:51:09'),
(3, 7, 7, 9, '2017-10-19 03:51:09'),
(3, 8, 1, 0, '2017-10-19 03:51:09'),
(3, 8, 2, 0, '2017-10-19 03:51:09'),
(3, 8, 3, 0, '2017-10-19 03:51:09'),
(3, 8, 4, 0, '2017-10-19 03:51:09'),
(3, 8, 6, 0, '2017-10-19 03:51:09'),
(3, 8, 7, 0, '2017-10-19 03:51:09'),
(3, 9, 1, 4, '2017-10-19 03:51:09'),
(3, 9, 2, 0, '2017-10-19 03:51:09'),
(3, 9, 3, 0, '2017-10-19 03:51:09'),
(3, 9, 4, 4, '2017-10-19 03:51:09'),
(3, 9, 6, 0, '2017-10-19 03:51:09'),
(3, 9, 7, 10, '2017-10-19 03:51:09'),
(3, 10, 1, 20, '2017-10-19 03:51:09'),
(3, 10, 2, 20, '2017-10-19 03:51:09'),
(3, 10, 3, 4, '2017-10-19 03:51:09'),
(3, 10, 4, 7, '2017-10-19 03:51:09'),
(3, 10, 6, 4, '2017-10-19 03:51:09'),
(3, 10, 7, 596, '2017-10-19 03:51:09'),
(4, 1, 1, 0, '2017-10-19 03:51:09'),
(4, 1, 2, 0, '2017-10-19 03:51:09'),
(4, 1, 3, 0, '2017-10-19 03:51:09'),
(4, 1, 4, 0, '2017-10-19 03:51:09'),
(4, 1, 6, 0, '2017-10-19 03:51:09'),
(4, 1, 7, 0, '2017-10-19 03:51:09'),
(4, 2, 1, 0, '2017-10-19 03:51:09'),
(4, 2, 2, 0, '2017-10-19 03:51:09'),
(4, 2, 3, 0, '2017-10-19 03:51:09'),
(4, 2, 4, 0, '2017-10-19 03:51:09'),
(4, 2, 6, 0, '2017-10-19 03:51:09'),
(4, 2, 7, 0, '2017-10-19 03:51:09'),
(4, 5, 1, 0, '2017-10-19 03:51:09'),
(4, 5, 2, 0, '2017-10-19 03:51:09'),
(4, 5, 3, 0, '2017-10-19 03:51:09'),
(4, 5, 4, 0, '2017-10-19 03:51:09'),
(4, 5, 6, 0, '2017-10-19 03:51:09'),
(4, 5, 7, 0, '2017-10-19 03:51:09'),
(4, 6, 1, 0, '2017-10-19 03:51:09'),
(4, 6, 2, 0, '2017-10-19 03:51:09'),
(4, 6, 3, 0, '2017-10-19 03:51:09'),
(4, 6, 4, 0, '2017-10-19 03:51:09'),
(4, 6, 6, 0, '2017-10-19 03:51:09'),
(4, 6, 7, 0, '2017-10-19 03:51:09'),
(4, 7, 1, 0, '2017-10-19 03:51:09'),
(4, 7, 2, 0, '2017-10-19 03:51:09'),
(4, 7, 3, 0, '2017-10-19 03:51:09'),
(4, 7, 4, 0, '2017-10-19 03:51:09'),
(4, 7, 6, 0, '2017-10-19 03:51:09'),
(4, 7, 7, 0, '2017-10-19 03:51:09'),
(4, 8, 1, 0, '2017-10-19 03:51:09'),
(4, 8, 2, 0, '2017-10-19 03:51:09'),
(4, 8, 3, 0, '2017-10-19 03:51:09'),
(4, 8, 4, 0, '2017-10-19 03:51:09'),
(4, 8, 6, 0, '2017-10-19 03:51:09'),
(4, 8, 7, 0, '2017-10-19 03:51:09'),
(4, 9, 1, 0, '2017-10-19 03:51:09'),
(4, 9, 2, 0, '2017-10-19 03:51:09'),
(4, 9, 3, 0, '2017-10-19 03:51:09'),
(4, 9, 4, 0, '2017-10-19 03:51:09'),
(4, 9, 6, 0, '2017-10-19 03:51:09'),
(4, 9, 7, 0, '2017-10-19 03:51:09'),
(4, 10, 1, 0, '2017-10-19 03:51:09'),
(4, 10, 2, 0, '2017-10-19 03:51:09'),
(4, 10, 3, 0, '2017-10-19 03:51:09'),
(4, 10, 4, 0, '2017-10-19 03:51:09'),
(4, 10, 6, 0, '2017-10-19 03:51:09'),
(4, 10, 7, 36, '2017-10-19 03:51:09'),
(5, 1, 1, 1, '2017-10-19 03:51:09'),
(5, 1, 2, 0, '2017-10-19 03:51:09'),
(5, 1, 3, 0, '2017-10-19 03:51:09'),
(5, 1, 4, 0, '2017-10-19 03:51:09'),
(5, 1, 6, 0, '2017-10-19 03:51:09'),
(5, 1, 7, 3, '2017-10-19 03:51:09'),
(5, 2, 1, 1, '2017-10-19 03:51:09'),
(5, 2, 2, 0, '2017-10-19 03:51:09'),
(5, 2, 3, 0, '2017-10-19 03:51:09'),
(5, 2, 4, 0, '2017-10-19 03:51:09'),
(5, 2, 6, 0, '2017-10-19 03:51:09'),
(5, 2, 7, 9, '2017-10-19 03:51:09'),
(5, 5, 1, 0, '2017-10-19 03:51:09'),
(5, 5, 2, 0, '2017-10-19 03:51:09'),
(5, 5, 3, 0, '2017-10-19 03:51:09'),
(5, 5, 4, 0, '2017-10-19 03:51:09'),
(5, 5, 6, 0, '2017-10-19 03:51:09'),
(5, 5, 7, 0, '2017-10-19 03:51:09'),
(5, 6, 1, 0, '2017-10-19 03:51:09'),
(5, 6, 2, 0, '2017-10-19 03:51:09'),
(5, 6, 3, 0, '2017-10-19 03:51:09'),
(5, 6, 4, 0, '2017-10-19 03:51:09'),
(5, 6, 6, 0, '2017-10-19 03:51:09'),
(5, 6, 7, 1, '2017-10-19 03:51:09'),
(5, 7, 1, 0, '2017-10-19 03:51:09'),
(5, 7, 2, 0, '2017-10-19 03:51:09'),
(5, 7, 3, 0, '2017-10-19 03:51:09'),
(5, 7, 4, 0, '2017-10-19 03:51:09'),
(5, 7, 6, 0, '2017-10-19 03:51:09'),
(5, 7, 7, 2, '2017-10-19 03:51:09'),
(5, 8, 1, 2, '2017-10-19 03:51:09'),
(5, 8, 2, 0, '2017-10-19 03:51:09'),
(5, 8, 3, 0, '2017-10-19 03:51:09'),
(5, 8, 4, 0, '2017-10-19 03:51:09'),
(5, 8, 6, 0, '2017-10-19 03:51:09'),
(5, 8, 7, 0, '2017-10-19 03:51:09'),
(5, 9, 1, 0, '2017-10-19 03:51:09'),
(5, 9, 2, 0, '2017-10-19 03:51:09'),
(5, 9, 3, 0, '2017-10-19 03:51:09'),
(5, 9, 4, 0, '2017-10-19 03:51:09'),
(5, 9, 6, 4, '2017-10-19 03:51:09'),
(5, 9, 7, 0, '2017-10-19 03:51:09'),
(5, 10, 1, 0, '2017-10-19 03:51:09'),
(5, 10, 2, 0, '2017-10-19 03:51:09'),
(5, 10, 3, 0, '2017-10-19 03:51:09'),
(5, 10, 4, 0, '2017-10-19 03:51:09'),
(5, 10, 6, 0, '2017-10-19 03:51:09'),
(5, 10, 7, 277, '2017-10-19 03:51:09'),
(6, 1, 1, 5, '2017-10-19 03:51:09'),
(6, 1, 2, 4, '2017-10-19 03:51:09'),
(6, 1, 3, 2, '2017-10-19 03:51:09'),
(6, 1, 4, 0, '2017-10-19 03:51:09'),
(6, 1, 6, 0, '2017-10-19 03:51:09'),
(6, 1, 7, 31, '2017-10-19 03:51:09'),
(6, 2, 1, 0, '2017-10-19 03:51:09'),
(6, 2, 2, 0, '2017-10-19 03:51:09'),
(6, 2, 3, 0, '2017-10-19 03:51:09'),
(6, 2, 4, 0, '2017-10-19 03:51:09'),
(6, 2, 6, 0, '2017-10-19 03:51:09'),
(6, 2, 7, 2, '2017-10-19 03:51:09'),
(6, 5, 1, 0, '2017-10-19 03:51:09'),
(6, 5, 2, 0, '2017-10-19 03:51:09'),
(6, 5, 3, 0, '2017-10-19 03:51:09'),
(6, 5, 4, 0, '2017-10-19 03:51:09'),
(6, 5, 6, 0, '2017-10-19 03:51:09'),
(6, 5, 7, 0, '2017-10-19 03:51:09'),
(6, 6, 1, 0, '2017-10-19 03:51:09'),
(6, 6, 2, 0, '2017-10-19 03:51:09'),
(6, 6, 3, 0, '2017-10-19 03:51:09'),
(6, 6, 4, 0, '2017-10-19 03:51:09'),
(6, 6, 6, 0, '2017-10-19 03:51:09'),
(6, 6, 7, 1, '2017-10-19 03:51:09'),
(6, 7, 1, 0, '2017-10-19 03:51:09'),
(6, 7, 2, 0, '2017-10-19 03:51:09'),
(6, 7, 3, 0, '2017-10-19 03:51:09'),
(6, 7, 4, 0, '2017-10-19 03:51:09'),
(6, 7, 6, 0, '2017-10-19 03:51:09'),
(6, 7, 7, 1, '2017-10-19 03:51:09'),
(6, 8, 1, 0, '2017-10-19 03:51:09'),
(6, 8, 2, 0, '2017-10-19 03:51:09'),
(6, 8, 3, 0, '2017-10-19 03:51:09'),
(6, 8, 4, 0, '2017-10-19 03:51:09'),
(6, 8, 6, 0, '2017-10-19 03:51:09'),
(6, 8, 7, 0, '2017-10-19 03:51:09'),
(6, 9, 1, 0, '2017-10-19 03:51:09'),
(6, 9, 2, 0, '2017-10-19 03:51:09'),
(6, 9, 3, 0, '2017-10-19 03:51:09'),
(6, 9, 4, 0, '2017-10-19 03:51:09'),
(6, 9, 6, 0, '2017-10-19 03:51:09'),
(6, 9, 7, 0, '2017-10-19 03:51:09'),
(6, 10, 1, 4, '2017-10-19 03:51:09'),
(6, 10, 2, 6, '2017-10-19 03:51:09'),
(6, 10, 3, 2, '2017-10-19 03:51:09'),
(6, 10, 4, 0, '2017-10-19 03:51:09'),
(6, 10, 6, 0, '2017-10-19 03:51:09'),
(6, 10, 7, 408, '2017-10-19 03:51:09'),
(7, 1, 1, 0, '2017-10-19 03:51:09'),
(7, 1, 2, 0, '2017-10-19 03:51:09'),
(7, 1, 3, 0, '2017-10-19 03:51:09'),
(7, 1, 4, 0, '2017-10-19 03:51:09'),
(7, 1, 6, 0, '2017-10-19 03:51:09'),
(7, 1, 7, 60, '2017-10-19 03:51:09'),
(7, 2, 1, 0, '2017-10-19 03:51:09'),
(7, 2, 2, 0, '2017-10-19 03:51:09'),
(7, 2, 3, 0, '2017-10-19 03:51:09'),
(7, 2, 4, 0, '2017-10-19 03:51:09'),
(7, 2, 6, 0, '2017-10-19 03:51:09'),
(7, 2, 7, 1, '2017-10-19 03:51:09'),
(7, 5, 1, 0, '2017-10-19 03:51:09'),
(7, 5, 2, 0, '2017-10-19 03:51:09'),
(7, 5, 3, 0, '2017-10-19 03:51:09'),
(7, 5, 4, 0, '2017-10-19 03:51:09'),
(7, 5, 6, 0, '2017-10-19 03:51:09'),
(7, 5, 7, 0, '2017-10-19 03:51:09'),
(7, 6, 1, 0, '2017-10-19 03:51:09'),
(7, 6, 2, 0, '2017-10-19 03:51:09'),
(7, 6, 3, 0, '2017-10-19 03:51:09'),
(7, 6, 4, 0, '2017-10-19 03:51:09'),
(7, 6, 6, 0, '2017-10-19 03:51:09'),
(7, 6, 7, 0, '2017-10-19 03:51:09'),
(7, 7, 1, 0, '2017-10-19 03:51:09'),
(7, 7, 2, 0, '2017-10-19 03:51:09'),
(7, 7, 3, 0, '2017-10-19 03:51:09'),
(7, 7, 4, 0, '2017-10-19 03:51:09'),
(7, 7, 6, 0, '2017-10-19 03:51:09'),
(7, 7, 7, 1, '2017-10-19 03:51:09'),
(7, 8, 1, 0, '2017-10-19 03:51:09'),
(7, 8, 2, 0, '2017-10-19 03:51:09'),
(7, 8, 3, 0, '2017-10-19 03:51:09'),
(7, 8, 4, 0, '2017-10-19 03:51:09'),
(7, 8, 6, 0, '2017-10-19 03:51:09'),
(7, 8, 7, 0, '2017-10-19 03:51:09'),
(7, 9, 1, 0, '2017-10-19 03:51:09'),
(7, 9, 2, 0, '2017-10-19 03:51:09'),
(7, 9, 3, 0, '2017-10-19 03:51:09'),
(7, 9, 4, 0, '2017-10-19 03:51:09'),
(7, 9, 6, 1, '2017-10-19 03:51:09'),
(7, 9, 7, 0, '2017-10-19 03:51:09'),
(7, 10, 1, 0, '2017-10-19 03:51:09'),
(7, 10, 2, 0, '2017-10-19 03:51:09'),
(7, 10, 3, 0, '2017-10-19 03:51:09'),
(7, 10, 4, 0, '2017-10-19 03:51:09'),
(7, 10, 6, 0, '2017-10-19 03:51:09'),
(7, 10, 7, 143, '2017-10-19 03:51:09'),
(8, 1, 1, 0, '2017-10-19 03:51:09'),
(8, 1, 2, 0, '2017-10-19 03:51:09'),
(8, 1, 3, 0, '2017-10-19 03:51:09'),
(8, 1, 4, 0, '2017-10-19 03:51:09'),
(8, 1, 6, 0, '2017-10-19 03:51:09'),
(8, 1, 7, 11, '2017-10-19 03:51:09'),
(8, 2, 1, 0, '2017-10-19 03:51:09'),
(8, 2, 2, 0, '2017-10-19 03:51:09'),
(8, 2, 3, 0, '2017-10-19 03:51:09'),
(8, 2, 4, 1, '2017-10-19 03:51:09'),
(8, 2, 6, 0, '2017-10-19 03:51:09'),
(8, 2, 7, 4, '2017-10-19 03:51:09'),
(8, 5, 1, 0, '2017-10-19 03:51:09'),
(8, 5, 2, 0, '2017-10-19 03:51:09'),
(8, 5, 3, 0, '2017-10-19 03:51:09'),
(8, 5, 4, 0, '2017-10-19 03:51:09'),
(8, 5, 6, 0, '2017-10-19 03:51:09'),
(8, 5, 7, 0, '2017-10-19 03:51:09'),
(8, 6, 1, 0, '2017-10-19 03:51:09'),
(8, 6, 2, 0, '2017-10-19 03:51:09'),
(8, 6, 3, 0, '2017-10-19 03:51:09'),
(8, 6, 4, 0, '2017-10-19 03:51:09'),
(8, 6, 6, 0, '2017-10-19 03:51:09'),
(8, 6, 7, 1, '2017-10-19 03:51:09'),
(8, 7, 1, 0, '2017-10-19 03:51:09'),
(8, 7, 2, 0, '2017-10-19 03:51:09'),
(8, 7, 3, 0, '2017-10-19 03:51:09'),
(8, 7, 4, 0, '2017-10-19 03:51:09'),
(8, 7, 6, 0, '2017-10-19 03:51:09'),
(8, 7, 7, 1, '2017-10-19 03:51:09'),
(8, 8, 1, 1, '2017-10-19 03:51:09'),
(8, 8, 2, 0, '2017-10-19 03:51:09'),
(8, 8, 3, 0, '2017-10-19 03:51:09'),
(8, 8, 4, 0, '2017-10-19 03:51:09'),
(8, 8, 6, 0, '2017-10-19 03:51:09'),
(8, 8, 7, 0, '2017-10-19 03:51:09'),
(8, 9, 1, 0, '2017-10-19 03:51:09'),
(8, 9, 2, 0, '2017-10-19 03:51:09'),
(8, 9, 3, 0, '2017-10-19 03:51:09'),
(8, 9, 4, 0, '2017-10-19 03:51:09'),
(8, 9, 6, 0, '2017-10-19 03:51:09'),
(8, 9, 7, 0, '2017-10-19 03:51:09'),
(8, 10, 1, 1, '2017-10-19 03:51:09'),
(8, 10, 2, 2, '2017-10-19 03:51:09'),
(8, 10, 3, 0, '2017-10-19 03:51:09'),
(8, 10, 4, 0, '2017-10-19 03:51:09'),
(8, 10, 6, 0, '2017-10-19 03:51:09'),
(8, 10, 7, 205, '2017-10-19 03:51:09'),
(9, 1, 1, 0, '2017-10-19 03:51:09'),
(9, 1, 2, 0, '2017-10-19 03:51:09'),
(9, 1, 3, 0, '2017-10-19 03:51:09'),
(9, 1, 4, 0, '2017-10-19 03:51:09'),
(9, 1, 6, 0, '2017-10-19 03:51:09'),
(9, 1, 7, 0, '2017-10-19 03:51:09'),
(9, 2, 1, 0, '2017-10-19 03:51:09'),
(9, 2, 2, 0, '2017-10-19 03:51:09'),
(9, 2, 3, 0, '2017-10-19 03:51:09'),
(9, 2, 4, 0, '2017-10-19 03:51:09'),
(9, 2, 6, 0, '2017-10-19 03:51:09'),
(9, 2, 7, 0, '2017-10-19 03:51:09'),
(9, 5, 1, 0, '2017-10-19 03:51:09'),
(9, 5, 2, 0, '2017-10-19 03:51:09'),
(9, 5, 3, 0, '2017-10-19 03:51:09'),
(9, 5, 4, 0, '2017-10-19 03:51:09'),
(9, 5, 6, 0, '2017-10-19 03:51:09'),
(9, 5, 7, 0, '2017-10-19 03:51:09'),
(9, 6, 1, 0, '2017-10-19 03:51:09'),
(9, 6, 2, 0, '2017-10-19 03:51:09'),
(9, 6, 3, 0, '2017-10-19 03:51:09'),
(9, 6, 4, 0, '2017-10-19 03:51:09'),
(9, 6, 6, 0, '2017-10-19 03:51:09'),
(9, 6, 7, 0, '2017-10-19 03:51:09'),
(9, 7, 1, 0, '2017-10-19 03:51:09'),
(9, 7, 2, 0, '2017-10-19 03:51:09'),
(9, 7, 3, 0, '2017-10-19 03:51:09'),
(9, 7, 4, 0, '2017-10-19 03:51:09'),
(9, 7, 6, 0, '2017-10-19 03:51:09'),
(9, 7, 7, 0, '2017-10-19 03:51:09'),
(9, 8, 1, 0, '2017-10-19 03:51:09'),
(9, 8, 2, 0, '2017-10-19 03:51:09'),
(9, 8, 3, 0, '2017-10-19 03:51:09'),
(9, 8, 4, 0, '2017-10-19 03:51:09'),
(9, 8, 6, 0, '2017-10-19 03:51:09'),
(9, 8, 7, 0, '2017-10-19 03:51:09'),
(9, 9, 1, 0, '2017-10-19 03:51:09'),
(9, 9, 2, 0, '2017-10-19 03:51:09'),
(9, 9, 3, 0, '2017-10-19 03:51:09'),
(9, 9, 4, 0, '2017-10-19 03:51:09'),
(9, 9, 6, 0, '2017-10-19 03:51:09'),
(9, 9, 7, 0, '2017-10-19 03:51:09'),
(9, 10, 1, 0, '2017-10-19 03:51:09'),
(9, 10, 2, 0, '2017-10-19 03:51:09'),
(9, 10, 3, 0, '2017-10-19 03:51:09'),
(9, 10, 4, 0, '2017-10-19 03:51:09'),
(9, 10, 6, 0, '2017-10-19 03:51:09'),
(9, 10, 7, 8, '2017-10-19 03:51:09'),
(10, 1, 1, 1, '2017-10-19 03:51:09'),
(10, 1, 2, 0, '2017-10-19 03:51:09'),
(10, 1, 3, 0, '2017-10-19 03:51:09'),
(10, 1, 4, 0, '2017-10-19 03:51:09'),
(10, 1, 6, 0, '2017-10-19 03:51:09'),
(10, 1, 7, 5, '2017-10-19 03:51:09'),
(10, 2, 1, 0, '2017-10-19 03:51:09'),
(10, 2, 2, 0, '2017-10-19 03:51:09'),
(10, 2, 3, 0, '2017-10-19 03:51:09'),
(10, 2, 4, 0, '2017-10-19 03:51:09'),
(10, 2, 6, 0, '2017-10-19 03:51:09'),
(10, 2, 7, 0, '2017-10-19 03:51:09'),
(10, 5, 1, 0, '2017-10-19 03:51:09'),
(10, 5, 2, 0, '2017-10-19 03:51:09'),
(10, 5, 3, 0, '2017-10-19 03:51:09'),
(10, 5, 4, 0, '2017-10-19 03:51:09'),
(10, 5, 6, 0, '2017-10-19 03:51:09'),
(10, 5, 7, 0, '2017-10-19 03:51:09'),
(10, 6, 1, 0, '2017-10-19 03:51:09'),
(10, 6, 2, 0, '2017-10-19 03:51:09'),
(10, 6, 3, 0, '2017-10-19 03:51:09'),
(10, 6, 4, 0, '2017-10-19 03:51:09'),
(10, 6, 6, 0, '2017-10-19 03:51:09'),
(10, 6, 7, 0, '2017-10-19 03:51:09'),
(10, 7, 1, 0, '2017-10-19 03:51:09'),
(10, 7, 2, 0, '2017-10-19 03:51:09'),
(10, 7, 3, 0, '2017-10-19 03:51:09'),
(10, 7, 4, 0, '2017-10-19 03:51:09'),
(10, 7, 6, 0, '2017-10-19 03:51:09'),
(10, 7, 7, 0, '2017-10-19 03:51:09'),
(10, 8, 1, 0, '2017-10-19 03:51:09'),
(10, 8, 2, 0, '2017-10-19 03:51:09'),
(10, 8, 3, 0, '2017-10-19 03:51:09'),
(10, 8, 4, 0, '2017-10-19 03:51:09'),
(10, 8, 6, 0, '2017-10-19 03:51:09'),
(10, 8, 7, 0, '2017-10-19 03:51:09'),
(10, 9, 1, 0, '2017-10-19 03:51:09'),
(10, 9, 2, 0, '2017-10-19 03:51:09'),
(10, 9, 3, 0, '2017-10-19 03:51:09'),
(10, 9, 4, 0, '2017-10-19 03:51:09'),
(10, 9, 6, 0, '2017-10-19 03:51:09'),
(10, 9, 7, 0, '2017-10-19 03:51:09'),
(10, 10, 1, 0, '2017-10-19 03:51:09'),
(10, 10, 2, 2, '2017-10-19 03:51:09'),
(10, 10, 3, 1, '2017-10-19 03:51:09'),
(10, 10, 4, 0, '2017-10-19 03:51:09'),
(10, 10, 6, 0, '2017-10-19 03:51:09'),
(10, 10, 7, 41, '2017-10-19 03:51:09');

-- --------------------------------------------------------

--
-- Table structure for table `pqd_component`
--

CREATE TABLE `pqd_component` (
  `pqd_component_id` int(11) NOT NULL,
  `pqd_component_name` varchar(200) NOT NULL,
  `pqd_area_id` int(11) NOT NULL,
  `pqd_product_id` int(11) NOT NULL,
  `pqd_product_version_id` int(11) NOT NULL,
  `github_repo_name` varchar(200) DEFAULT NULL,
  `github_repo_organization` varchar(100) NOT NULL,
  `jira_component_id` int(11) DEFAULT NULL,
  `sonar_project_key` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pqd_component`
--

INSERT INTO `pqd_component` (`pqd_component_id`, `pqd_component_name`, `pqd_area_id`, `pqd_product_id`, `pqd_product_version_id`, `github_repo_name`, `github_repo_organization`, `jira_component_id`, `sonar_project_key`) VALUES
(1, 'analytics-data-agents', 2, 4, 4, 'analytics-data-agents', 'wso2', 0, 'wso2:instrumentation-agent'),
(2, 'analytics-http', 8, 22, 0, 'analytics-http', 'wso2', 0, 'org.wso2.analytics.http:wso2analytics-http-parent'),
(3, 'analytics-iots', 7, 9, 10, 'analytics-iots', 'wso2', 0, 'org.wso2.carbon.analytics.iots:wso2analytics-iots-parent'),
(4, 'andes', 6, 21, 0, 'andes', 'wso2', 0, 'org.wso2.andes:andes-parent'),
(5, 'archetypes', 10, 24, 0, 'archetypes', '', 0, 'org.wso2.carbon.extension.archetype:carbon-extension-archetype'),
(6, 'carbon-analytics', 2, 5, 6, 'carbon-analytics', 'wso2', 0, 'org.wso2.carbon.analytics:carbon-analytics'),
(7, 'carbon-analytics-common', 2, 5, 6, 'carbon-analytics-common', 'wso2', 0, 'org.wso2.carbon.analytics-common:carbon-analytics-common'),
(8, 'carbon-apimgt', 1, 1, 1, 'carbon-apimgt', 'wso2', 0, 'org.wso2.carbon.apimgt:carbon-apimgt'),
(9, 'carbon-apimgt staged', 1, 1, 1, NULL, '', 0, 'org.wso2.carbon.apimgt:carbon-apimgt:staged'),
(11, 'carbon-appmgt', 5, 10, 11, 'carbon-appmgt', 'wso2', 0, 'org.wso2.carbon.appmgt:carbon-appmgt'),
(12, 'carbon-business-messaging', 6, 11, 12, 'carbon-business-messaging', 'wso2', 0, 'org.wso2.carbon.messaging:business-messaging'),
(13, 'carbon-business-process', 6, 3, 3, 'carbon-business-process', 'wso2', 0, 'org.wso2.carbon.business-process:carbon-business-process'),
(14, 'carbon-caching', 10, 24, 0, 'carbon-caching', 'wso2', 0, 'org.wso2.carbon.caching:org.wso2.carbon.caching.parent'),
(15, 'carbon-commons', 10, 24, 0, 'carbon-commons', 'wso2', 0, 'org.wso2.carbon.commons:carbon-commons'),
(16, 'carbon-dashboards', 2, 5, 6, 'carbon-dashboards', 'wso2', 0, 'org.wso2.carbon.dashboards:carbon-dashboards'),
(17, 'carbon-data', 6, 6, 7, 'carbon-data', 'wso2', 0, 'org.wso2.carbon.data:carbon-data'),
(18, 'carbon-datasources', 10, 24, 0, 'carbon-datasources', 'wso2', 0, 'org.wso2.carbon.datasources:carbon-datasources'),
(19, 'carbon-deployment', 8, 22, 0, 'carbon-deployment', 'wso2', 0, 'org.wso2.carbon.deployment:org.wso2.carbon.deployment.parent'),
(20, 'carbon-device-mgt', 7, 9, 10, 'carbon-device-mgt', 'wso2', 0, 'org.wso2.carbon.devicemgt:carbon-devicemgt'),
(21, 'carbon-device-mgt-maven-plugin', 7, 9, 10, 'carbon-device-mgt-maven-plugin', 'wso2', 0, 'org.wso2.cdmf.devicetype:cdmf-devicetype-archetype'),
(22, 'carbon-device-mgt-plugins', 7, 9, 10, 'carbon-device-mgt-plugins', 'wso2', 0, 'org.wso2.carbon.devicemgt-plugins:carbon-device-mgt-plugins-parent'),
(23, 'carbon-devicemgt-proprietary-plugins', 7, 9, 10, NULL, '', 0, 'org.wso2.carbon.devicemgt-proprietary:carbon-devicemgt-proprietary'),
(24, 'carbon-event-processing', 2, 5, 6, 'carbon-event-processing', 'wso2', 0, 'org.wso2.carbon.event-processing:carbon-event-processing'),
(25, 'carbon-governance', 8, 22, 0, 'carbon-governance', 'wso2', 0, 'org.wso2.carbon.governance:carbon-governance'),
(26, 'carbon-governance-extensions', 8, 22, 0, 'carbon-governance-extensions', 'wso2', 0, 'org.wso2.carbon.governance-extensions:carbon-governance-extensions'),
(27, 'carbon-identity-framework', 5, 10, 11, 'carbon-identity-framework', 'wso2', 0, 'org.wso2.carbon.identity.framework:identity-framework'),
(28, 'carbon-jndi', 10, 24, 0, 'carbon-jndi', 'wso2', 0, 'org.wso2.carbon.jndi:org.wso2.carbon.jndi.parent'),
(29, 'carbon-kernel', 8, 22, 0, 'carbon-kernel', 'wso2', 0, 'org.wso2.carbon:carbon-kernel'),
(30, 'carbon-maven-plugins', 10, 24, 0, 'carbon-maven-plugins', 'wso2', 0, 'org.wso2.carbon.maven:carbon-maven-plugins'),
(31, 'carbon-mediation', 6, 7, 8, 'carbon-mediation', 'wso2', 0, 'org.wso2.carbon.mediation:carbon-mediation'),
(32, 'carbon-messaging', 6, 11, 12, 'carbon-messaging', 'wso2', 0, 'org.wso2.carbon.messaging:org.wso2.carbon.messaging.parent'),
(33, 'carbon-ml', 2, 4, 4, 'carbon-ml', 'wso2-attic', 0, 'org.wso2.carbon.ml:carbon-ml'),
(34, 'carbon-multitenancy', 8, 22, 0, 'carbon-multitenancy', 'wso2', 0, 'org.wso2.carbon.multitenancy:carbon-multitenancy'),
(35, 'carbon-parent', 8, 22, 0, 'carbon-parent', 'wso2', 0, 'org.wso2:wso2'),
(36, 'carbon-platform-integration', 10, 24, 0, 'carbon-platform-integration', 'wso2', 0, 'org.wso2.carbon.automation:test-automation-framework'),
(37, 'carbon-registry', 8, 22, 0, 'carbon-registry', 'wso2', 0, 'org.wso2.carbon.registry:carbon-registry'),
(38, 'carbon-registry carbon-registry', 8, 22, 0, NULL, '', 0, 'org.wso2.carbon.registry:carbon-registry:carbon-registry'),
(39, 'carbon-rules', 6, 7, 8, 'carbon-rules', 'wso2', 0, 'org.wso2.carbon.rules:carbon-rule'),
(40, 'carbon-security', 5, 10, 11, 'carbon-security', 'wso2', 0, 'org.wso2.carbon.security.caas:org.wso2.carbon.security.caas.parent'),
(41, 'carbon-security-login-module-jwt', 5, 10, 11, 'carbon-security-login-module-jwt', 'wso2-extensions', 0, 'org.wso2.carbon.security.caas.module:org.wso2.carbon.security.caas.module.jwt.parent'),
(42, 'carbon-security-user-store-jdbc', 5, 10, 11, 'carbon-security-user-store-jdbc', 'wso2-extensions', 0, 'org.wso2.carbon.security.userstore:org.wso2.carbon.security.userstore.jdbc.parent'),
(43, 'carbon-storage-management', 4, 20, 0, 'carbon-storage-management', 'wso2', 0, 'org.wso2.carbon.storagemgt:carbon-storage-management'),
(44, 'carbon-store', 4, 20, 0, 'carbon-store', 'wso2', 0, 'org.wso2.carbon.store:carbon-store'),
(45, 'carbon-uuf-maven-tools', 3, 19, 0, 'carbon-uuf-maven-tools', 'wso2', 0, 'org.wso2.carbon.uuf.maven:carbon-uuf'),
(46, 'composer', 3, 13, 13, 'composer', 'ballerinalang', 0, 'org.ballerinalang:ballerina-composer-parent'),
(47, 'connectors', 3, 13, 13, 'connectors', 'ballerinalang', 0, 'org.wso2.ballerina.connectors:connectors'),
(48, 'container-support', 3, 13, 13, 'container-support', 'ballerinalang', 0, 'org.ballerinalang:ballerina-container-support'),
(49, 'docerina', 3, 13, 13, 'docerina', 'ballerinalang', 0, 'org.ballerinalang:docerina'),
(50, 'esb-connector-amazons3', 9, 23, 0, 'esb-connector-amazons3', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.amazons3'),
(51, 'esb-connector-amazonses', 9, 23, 0, 'esb-connector-amazonses', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.amazonses'),
(52, 'esb-connector-amazonsimpledb', 9, 23, 0, 'esb-connector-amazonsimpledb', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.amazonsdb'),
(53, 'esb-connector-amazonsqs', 9, 23, 0, 'esb-connector-amazonsqs', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.amazonsqs'),
(54, 'esb-connector-apple-push-notification', 9, 23, 0, 'esb-connector-apple-push-notification', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.apns'),
(55, 'esb-connector-beetrack', 9, 23, 0, 'esb-connector-beetrack', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.contactform'),
(56, 'esb-connector-bigquery', 9, 23, 0, 'esb-connector-bigquery', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.bigquery'),
(57, 'esb-connector-braintree', 9, 23, 0, 'esb-connector-braintree', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.braintree'),
(58, 'esb-connector-clevertimcrm', 9, 23, 0, 'esb-connector-clevertimcrm', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.clevertimcrm'),
(59, 'esb-connector-ejb2.0', 9, 23, 0, 'esb-connector-ejb2.0', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.ejb2'),
(60, 'esb-connector-evernote', 9, 23, 0, 'esb-connector-evernote', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.evernote'),
(61, 'esb-connector-feed', 9, 23, 0, 'esb-connector-feed', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.feed'),
(62, 'esb-connector-file', 9, 23, 0, 'esb-connector-file', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.fileconnector'),
(63, 'esb-connector-flickr', 9, 23, 0, 'esb-connector-flickr', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.flickr'),
(64, 'esb-connector-foursquare', 9, 23, 0, 'esb-connector-foursquare', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.foursquare'),
(65, 'esb-connector-gmail', 9, 23, 0, 'esb-connector-gmail', 'wso2-extensions', 0, 'org.wso2.carbon.connector:org.wso2.carbon.connector.gmail'),
(66, 'identity-agent-entitlement-filter', 5, 10, 11, 'identity-agent-entitlement-filter', 'wso2-extensions', 0, 'org.wso2.carbon.identity.agent.entitlement.filter:identity-agent-entitlement-filter'),
(67, 'identity-agent-entitlement-proxy', 5, 10, 11, 'identity-agent-entitlement-proxy', 'wso2-extensions', 0, 'org.wso2.carbon.identity.agent.entitlement.mediator:identity-agent-entitlement-proxy'),
(68, 'identity-agent-sso', 5, 10, 11, 'identity-agent-sso', 'wso2-extensions', 0, 'org.wso2.carbon.identity.agent.sso.java:identity-agent-sso'),
(69, 'identity-application-authz-xacml', 5, 10, 11, 'identity-application-authz-xacml', 'wso2-extensions', 0, 'org.wso2.carbon.identity.application.authz.xacml:identity-application-authz-xacml'),
(70, 'identity-carbon-auth-iwa', 5, 10, 11, 'identity-carbon-auth-iwa', 'wso2-extensions', 0, 'org.wso2.carbon.identity.carbon.auth.iwa:identity-carbon-auth-iwa'),
(71, 'identity-carbon-auth-mutual-ssl', 5, 10, 11, 'identity-carbon-auth-mutual-ssl', 'wso2-extensions', 0, 'org.wso2.carbon.identity.carbon.auth.mutualssl:identity-carbon-auth-mutual-ssl'),
(72, 'identity-carbon-auth-rest', 5, 10, 11, 'identity-carbon-auth-rest', 'wso2-extensions', 0, 'org.wso2.carbon.identity.auth.rest:identity-carbon-auth-rest'),
(73, 'identity-carbon-auth-saml2', 5, 10, 11, 'identity-carbon-auth-saml2', 'wso2-extensions', 0, 'org.wso2.carbon.identity.carbon.auth.saml2:identity-carbon-auth-saml2'),
(74, 'identity-carbon-auth-signedjwt', 5, 10, 11, 'identity-carbon-auth-signedjwt', 'wso2-extensions', 0, 'org.wso2.carbon.identity.carbon.auth.jwt:identity-carbon-auth-signedjwt'),
(75, 'identity-data-publisher-audit', 5, 10, 11, 'identity-data-publisher-audit', 'wso2-extensions', 11635, 'org.wso2.carbon.identity.data.publisher.audit:identity-data-publisher-audit'),
(76, 'identity-data-publisher-authentication', 5, 10, 11, 'identity-data-publisher-authentication', 'wso2-extensions', 11938, 'org.wso2.carbon.identity.datapublisher.authentication:identity-data-publisher-authentication'),
(77, 'identity-data-publisher-oauth', 5, 10, 11, 'identity-data-publisher-oauth', 'wso2-extensions', 10833, 'org.wso2.carbon.identity.data.publisher.oauth:identity-data-publisher-oauth'),
(78, 'identity-event-handler-account-lock', 5, 10, 11, 'identity-event-handler-account-lock', 'wso2-extensions', 0, 'org.wso2.carbon.identity.event.handler.accountlock:identity-handler-account-lock'),
(79, 'identity-event-handler-notification', 5, 10, 11, 'identity-event-handler-notification', 'wso2-extensions', 0, 'org.wso2.carbon.identity.event.handler.notification:identity-event-handler-notification'),
(80, 'identity-extension-parent', 5, 10, 11, 'identity-extension-parent', 'wso2-extensions', 0, 'org.wso2.carbon.identity:identity-extension-parent'),
(81, 'identity-feature-category', 5, 10, 11, 'identity-feature-category', 'wso2-extensions', 0, 'org.wso2.carbon.identity.feature.category:identity-feature-category'),
(82, 'identity-framework', 5, 10, 11, NULL, '', 0, 'org.wso2.carbon.identity:identity-framework'),
(83, 'identity-governance', 5, 10, 11, 'identity-governance', 'wso2-extensions', 0, 'org.wso2.carbon.identity.governance:identity-governance'),
(84, 'identity-inbound-auth-oauth', 5, 10, 11, 'identity-inbound-auth-oauth', 'wso2-extensions', 0, 'org.wso2.carbon.identity.inbound.auth.oauth2:identity-inbound-auth-oauth'),
(85, 'identity-inbound-auth-openid', 5, 10, 11, 'identity-inbound-auth-openid', 'wso2-extensions', 10836, 'org.wso2.carbon.identity.inbound.auth.openid:identity-inbound-auth-openid'),
(86, 'identity-inbound-auth-saml', 5, 10, 11, 'identity-inbound-auth-saml', 'wso2-extensions', 0, 'org.wso2.carbon.identity.inbound.auth.saml2:identity-inbound-auth-saml'),
(87, 'identity-inbound-auth-sts', 5, 10, 11, 'identity-inbound-auth-sts', 'wso2-extensions', 0, 'org.wso2.carbon.identity.inbound.auth.sts:identity-inbound-auth-sts'),
(88, 'identity-inbound-provisioning-scim', 5, 10, 11, 'identity-inbound-provisioning-scim', 'wso2-extensions', 10834, 'org.wso2.carbon.identity.inbound.provisioning.scim:identity-inbound-provisioning-scim'),
(89, 'identity-inbound-provisioning-scim2', 5, 10, 11, 'identity-inbound-provisioning-scim2', 'wso2-extensions', 0, 'org.wso2.carbon.identity.inbound.provisioning.scim2:org.wso2.carbon.identity.inbound.provisioning.scim2.parent'),
(90, 'identity-local-auth-basicauth', 5, 10, 11, 'identity-local-auth-basicauth', 'wso2-extensions', 0, 'org.wso2.carbon.identity.application.auth.basic:identity-application-auth-basicauth'),
(91, 'identity-local-auth-fido', 5, 10, 11, 'identity-local-auth-fido', 'wso2-extensions', 0, 'org.wso2.carbon.identity.local.auth.fido:identity-application-auth-fido'),
(92, 'identity-local-auth-iwa-kerberos', 5, 10, 11, 'identity-local-auth-iwa-kerberos', 'wso2-extensions', 11743, 'org.wso2.carbon.identity.local.auth.iwa:identity-application-auth-iwa'),
(93, 'identity-metadata-saml2', 5, 10, 11, 'identity-metadata-saml2', 'wso2-extensions', 0, 'org.wso2.carbon.identity.metadata.saml2:identity-metadata-saml2'),
(94, 'identity-notification-mgt-email', 5, 10, 11, 'identity-notification-mgt-email', 'wso2-extensions', 0, '"org.wso2.carbon.identity.notification.email:identity-notification-email'),
(95, 'identity-notification-mgt-json', 5, 10, 11, 'identity-notification-mgt-json', 'wso2-extensions', 0, 'org.wso2.carbon.identity.notification.json:identity-notification-json'),
(96, 'identity-oauth2-grant-jwt', 5, 10, 11, 'identity-oauth2-grant-jwt', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.oauth2.grantType.jwt:identity-inbound-oauth2-grant-jwt'),
(97, 'identity-outbound-auth-amazon', 5, 10, 11, 'identity-outbound-auth-amazon', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator.outbound.amazon:identity-outbound-auth-amazon'),
(98, 'identity-outbound-auth-basecamp', 5, 10, 11, 'identity-outbound-auth-basecamp', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.basecamp'),
(99, 'identity-outbound-auth-dropbox', 5, 10, 11, 'identity-outbound-auth-dropbox', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.dropbox'),
(100, 'identity-outbound-auth-email-otp', 5, 10, 11, 'identity-outbound-auth-email-otp', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator.outbound.emailotp:identity-outbound-auth-email-otp'),
(101, 'identity-outbound-auth-facebook', 5, 10, 11, 'identity-outbound-auth-facebook', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.auth.facebook:identity-outbound-auth-facebook'),
(102, 'identity-outbound-auth-foursquare', 5, 10, 11, 'identity-outbound-auth-foursquare', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator.outbound.foursquare:identity-outbound-auth-foursquare'),
(103, 'identity-outbound-auth-github', 5, 10, 11, 'identity-outbound-auth-github', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.github'),
(104, 'identity-outbound-auth-google', 5, 10, 11, 'identity-outbound-auth-google', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.auth.google:identity-outbound-auth-google'),
(105, 'identity-outbound-auth-instagram', 5, 10, 11, 'identity-outbound-auth-instagram', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator.outbound.instagram:identity-outbound-auth-instagram'),
(106, 'identity-outbound-auth-inwebo', 5, 10, 11, 'identity-outbound-auth-inwebo', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.inwebo'),
(107, 'identity-outbound-auth-mailchimp', 5, 10, 11, 'identity-outbound-auth-mailchimp', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.mailchimp'),
(108, 'identity-outbound-auth-mepin', 5, 10, 11, 'identity-outbound-auth-mepin', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator.outbound.mepin:identity-outbound-auth-mepin'),
(109, 'identity-outbound-auth-office365', 5, 10, 11, 'identity-outbound-auth-office365', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.office365'),
(110, 'identity-outbound-auth-oidc', 5, 10, 11, 'identity-outbound-auth-oidc', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.auth.oidc:identity-application-auth-oidc'),
(111, 'identity-outbound-auth-oidc-mobileconnect', 5, 10, 11, 'identity-outbound-auth-oidc-mobileconnect', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.mobileconnect'),
(112, 'identity-outbound-auth-openid', 5, 10, 11, 'identity-outbound-auth-openid', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.auth.openid:identity-application-auth-openid'),
(113, 'identity-outbound-auth-passive-sts', 5, 10, 11, 'identity-outbound-auth-passive-sts', 'wso2-extensions', 11038, 'org.wso2.carbon.identity.outbound.auth.sts.passive:identity-application-auth-passive-sts'),
(114, 'identity-outbound-auth-reddit', 5, 10, 11, 'identity-outbound-auth-reddit', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.reddit'),
(115, 'identity-outbound-auth-requestpath-basicauth', 5, 10, 11, 'identity-outbound-auth-requestpath-basicauth', 'wso2-extensions', 0, 'org.wso2.carbon.identity.local.auth.requestpath.basic:identity-application-auth-requestpath-basicauth'),
(116, 'identity-outbound-auth-requestpath-oauth', 5, 10, 11, 'identity-outbound-auth-requestpath-oauth', 'wso2-extensions', 0, 'org.wso2.carbon.identity.local.auth.requestpath.oauth:identity-application-auth-requestpath-oauth'),
(117, 'identity-outbound-auth-saml2sso', 5, 10, 11, 'identity-outbound-auth-samlsso', 'wso2-extensions', 10835, 'org.wso2.carbon.identity.authenticator.outbound.saml2sso:identity-auth-outbound-saml2sso'),
(118, 'identity-outbound-auth-samlsso', 5, 10, 11, 'identity-outbound-auth-samlsso', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.auth.saml2:identity-application-auth-samlsso'),
(119, 'identity-outbound-auth-sms-otp', 5, 10, 11, 'identity-outbound-auth-sms-otp', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator.outbound.smsotp:identity-outbound-auth-sms-otp'),
(120, 'identity-outbound-auth-tiqr', 5, 10, 11, 'identity-outbound-auth-tiqr', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.tiqr'),
(121, 'identity-outbound-auth-totp', 5, 10, 11, 'identity-outbound-auth-totp', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator.outbound.totp:identity-outbound-auth-totp'),
(122, 'identity-outbound-auth-windows-live', 5, 10, 11, 'identity-outbound-auth-windows-live', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.auth.live:identity-outbound-auth-windows-live'),
(123, 'identity-outbound-auth-wordpress', 5, 10, 11, 'identity-outbound-auth-wordpress', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.wordpress'),
(124, 'identity-outbound-auth-yahoo', 5, 10, 11, 'identity-outbound-auth-yahoo', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.auth.yahoo:identity-outbound-auth-yahoo'),
(125, 'identity-outbound-auth-yammer', 5, 10, 11, 'identity-outbound-auth-yammer', 'wso2-extensions', 0, 'org.wso2.carbon.extension.identity.authenticator:org.wso2.carbon.extension.identity.authenticator.yammer'),
(126, 'identity-outbound-provisioning-google', 5, 10, 11, 'identity-outbound-provisioning-google', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.provisioning.google:identity-outbound-provisioning-google'),
(127, 'identity-outbound-provisioning-salesforcee', 5, 10, 11, 'identity-outbound-provisioning-salesforcee', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.provisioning.salesforce:identity-outbound-provisioning-salesforce'),
(128, 'identity-outbound-provisioning-scim', 5, 10, 11, 'identity-outbound-provisioning-scim', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.provisioning.scim:identity-outbound-provisioning-scim'),
(129, 'identity-outbound-provisioning-spml', 5, 10, 11, 'identity-outbound-provisioning-spml', 'wso2-extensions', 0, 'org.wso2.carbon.identity.outbound.provisioning.spml:identity-outbound-provisioning-spml'),
(130, 'identity-tool-samlsso-validator', 5, 10, 11, 'identity-tool-samlsso-validator', 'wso2-extensions', 0, 'org.wso2.carbon.identity.tool.validator.sso.saml2:identity-tool-samlsso-validator'),
(131, 'identity-user-workflow', 5, 10, 11, 'identity-user-workflow', 'wso2-extensions', 0, 'org.wso2.carbon.identity.workflow.user:identity-user-workflow'),
(132, 'identity-usermgt-account-association', 5, 10, 11, 'identity-usermgt-account-association', 'wso2-extensions', 0, 'org.wso2.carbon.identity.association.account:identity-user-account-association'),
(133, 'identity-usermgt-ws', 5, 10, 11, 'identity-usermgt-ws', 'wso2-extensions', 0, 'org.wso2.carbon.identity.user.ws:identity-user-ws'),
(134, 'identity-userstore-cassandra', 5, 10, 11, 'identity-userstore-cassandra', 'wso2-extensions', 0, 'org.wso2.carbon.identity.userstore.cassandra:identity-userstore-cassandra'),
(135, 'identity-userstore-ldap', 5, 10, 11, 'identity-userstore-ldap', 'wso2-extensions', 0, 'org.wso2.carbon.identity.userstore.ldap:identity-userstore-ldap'),
(136, 'identity-userstore-onprem-agent', 5, 10, 11, 'identity-userstore-onprem-agent', 'wso2-extensions', 0, 'org.wso2.carbon.identity.userstore.onprem:identity-userstore-onprem'),
(137, 'identity-userstore-remote', 5, 10, 11, 'identity-userstore-remote', 'wso2-extensions', 0, 'org.wso2.carbon.identity.userstore.remote:identity-userstore-remote'),
(138, 'identity-workflow-mgt-bps-impl', 5, 10, 11, 'identity-workflow-mgt-bps-impl', 'wso2-extensions', 0, 'org.wso2.carbon.identity.workflow.impl.bps:identity-workflow-impl-bps'),
(139, 'identity-workflow-mgt-multisteps-template', 5, 10, 11, 'identity-workflow-mgt-multisteps-template', 'wso2-extensions', 0, 'org.wso2.carbon.identity.workflow.template.multisteps:identity-workflow-template-multisteps'),
(140, 'msf4j', 8, 22, 0, 'msf4j', 'wso2', 0, 'org.wso2.msf4j:msf4j'),
(141, 'plugin-maven', 10, 24, 0, 'plugin-maven', 'ballerinalang', 0, 'org.ballerinalang:ballerina-maven-plugins'),
(142, 'sonar-carbon-dashboards mvnizing-portal', 10, 24, 0, NULL, '', 0, 'org.wso2.carbon.dashboards:carbon-dashboards:mvnizing-portal'),
(143, 'testerina', 3, 13, 13, 'testerina', 'ballerinalang', 0, 'org.ballerinalang:testerina'),
(144, 'tool-swagger-ballerina', 3, 13, 13, 'tool-swagger-ballerina', 'ballerinalang', 0, 'org.ballerinalang:swagger-ballerina'),
(145, 'tools-distribution', 3, 13, 13, 'tools-distribution', 'ballerinalang', 0, 'org.ballerinalang.tools:tools-distribution'),
(146, 'ws2-rampart', 5, 10, 11, 'wso2-rampart', 'wso2', 0, 'org.apache.rampart:rampart-project'),
(147, 'wso2-axiom', 10, 24, 0, 'wso2-axiom', 'wso2', 0, 'org.apache.ws.commons.axiom:axiom'),
(148, 'wso2-axis2', 8, 22, 0, 'wso2-axis2', 'wso2', 0, 'org.apache.axis2:axis2'),
(149, 'wso2-axis2-transports', 6, 8, 9, 'wso2-axis2-transports', 'wso2', 0, 'org.apache.axis2.transport:axis2-transports'),
(150, 'wso2-balana', 5, 10, 11, 'balana', 'wso2', 0, 'org.wso2.balana:balana'),
(151, 'wso2-cassandra', 10, 24, 0, 'wso2-cassandra', 'wso2', 0, 'org.apache.cassandra:apache-cassandra'),
(152, 'wso2-charon', 10, 24, 0, 'wso2-charon', 'wso2', 0, 'org.wso2.charon:charon-parent'),
(153, 'wso2-commons-httpclient', 10, 24, 0, 'wso2-commons-httpclient', 'wso2', 0, 'org.wso2.commons-httpclient:commons-httpclient-parent'),
(154, 'wso2-ode', 6, 7, 8, 'wso2-ode', 'wso2', 0, 'org.wso2.bpel:ode'),
(155, 'wso2-synapse', 6, 7, 8, 'wso2-synapse', 'wso2', 0, 'org.apache.synapse:Apache-Synapse'),
(156, 'wso2-wsdl4j', 10, 24, 0, 'wso2-wsdl4j', 'wso2', 0, 'org.wso2.wsdl4j:wsdl4j-parent'),
(157, 'product_apim', 1, 1, 1, 'product_apim', 'wso2', 0, 'org.wso2.am:am-parent'),
(158, 'product-as', 8, 2, 0, 'product-as', 'wso2', 0, 'org.wso2.appserver:wso2appserver'),
(159, 'product-bps', 6, 3, 0, 'product-bps', 'wso2-attic', 0, 'org.wso2.bps:wso2bps-parent'),
(160, 'product-cep', 2, 4, 0, 'product-cep', 'wso2', 0, 'org.wso2.cep:wso2cep-parent'),
(161, 'product-das', 2, 5, 0, 'product-das', 'wso2', 0, 'org.wso2.das:wso2das-parent'),
(162, 'product-dss', 6, 6, 0, 'product-dss', 'wso2', 10090, 'org.wso2.dss:dataservices-parent'),
(163, 'product-ei', 6, 7, 0, 'product-ei', 'wso2', 0, 'org.wso2.ei:wso2ei-parent'),
(164, 'product-esb', 6, 8, 0, 'product-esb', 'wso2', 0, 'org.wso2.esb:esb-parent'),
(165, 'product-iots', 7, 9, 0, 'product-iots', 'wso2', 0, 'org.wso2.iot:wso2iot-parent'),
(166, 'product-is', 5, 10, 0, 'product-is', 'wso2', 0, 'org.wso2.is:product-is'),
(167, 'product-mb', 6, 11, 0, 'product-mb', 'wso2', 0, 'org.wso2.mb:mb-parent'),
(168, 'siddhi', 2, 12, 0, 'siddhi', 'wso2', 0, 'org.wso2.siddhi:siddhi'),
(169, 'ballerina', 3, 13, 0, 'ballerina', 'ballerinalang', 0, 'org.ballerinalang:ballerina-parent'),
(170, 'transports', 3, 14, 0, 'carbon-transports', 'wso2', 0, 'org.wso2.carbon.transport:org.wso2.carbon.transport.parent'),
(171, 'analytics-apim', 1, 15, 0, 'analytics-apim', 'wso2', 0, 'org.wso2.analytics.apim:analytics-apim'),
(172, 'analytics-is', 5, 16, 0, 'analytics-is', 'wso2', 0, 'org.wso2.analytics.is:wso2analytics-is-parent'),
(173, 'analytics-mb', 6, 17, 0, 'analytics-mb', 'wso2-attic', 0, 'org.wso2.analytics.mb:wso2analytics-mb-parent'),
(174, 'analytics-esb', 6, 18, 0, 'analytics-esb', 'wso2', 0, 'org.wso2.analytics.esb:wso2esb-analytics-parent');

-- --------------------------------------------------------

--
-- Table structure for table `pqd_component_issues`
--

CREATE TABLE `pqd_component_issues` (
  `pqd_component_id` int(11) NOT NULL,
  `pqd_issue_type_id` int(11) NOT NULL,
  `pqd_severity_id` int(11) NOT NULL,
  `pqd_issues_count` int(11) NOT NULL,
  `pqd_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pqd_github_area_issues_history`
--

CREATE TABLE `pqd_github_area_issues_history` (
  `pqd_area_id` int(11) NOT NULL,
  `pqd_issue_type_id` int(11) NOT NULL,
  `pqd_severity_id` int(11) NOT NULL,
  `pqd_issues_count` int(200) DEFAULT NULL,
  `pqd_date` date NOT NULL,
  `pqd_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pqd_github_component_issues_history`
--

CREATE TABLE `pqd_github_component_issues_history` (
  `pqd_component_id` int(11) NOT NULL,
  `pqd_issue_type_id` int(11) NOT NULL,
  `pqd_severity_id` int(11) NOT NULL,
  `pqd_issues_count` int(200) DEFAULT NULL,
  `pqd_date` date NOT NULL,
  `pqd_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pqd_github_product_issues_history`
--

CREATE TABLE `pqd_github_product_issues_history` (
  `pqd_product_id` int(11) NOT NULL,
  `pqd_issue_type_id` int(11) NOT NULL,
  `pqd_severity_id` int(11) NOT NULL,
  `pqd_issues_count` int(200) DEFAULT NULL,
  `pqd_date` date NOT NULL,
  `pqd_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pqd_issue_type`
--

CREATE TABLE `pqd_issue_type` (
  `pqd_issue_type_id` int(11) NOT NULL,
  `pqd_issue_type` varchar(200) NOT NULL,
  `pqd_issue_type_github_label_text` varchar(200) DEFAULT NULL,
  `pqd_issue_type_github_label_color` varchar(100) DEFAULT NULL,
  `pqd_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pqd_issue_type`
--

INSERT INTO `pqd_issue_type` (`pqd_issue_type_id`, `pqd_issue_type`, `pqd_issue_type_github_label_text`, `pqd_issue_type_github_label_color`, `pqd_updated`) VALUES
(1, 'Bug', 'Type/Bug', '1d76db', '2017-09-23 21:16:24'),
(2, 'Improvement', 'Type/Improvement', '1d76db', '2017-09-23 21:16:29'),
(5, 'Epic', 'Type/Epic', '1d76db', '2017-09-23 21:16:46'),
(6, 'New Feature', 'Type/New Feature', '1d76db', '2017-09-23 21:17:04'),
(7, 'Question', 'Type/Question', '1d76db', '2017-09-23 21:17:25'),
(8, 'Task', 'Type/Task', '1d76db', '2017-09-23 21:17:39'),
(9, 'UX', 'Type/UX', '1d76db', '2017-09-23 21:17:53'),
(10, 'Unknown', NULL, NULL, '2017-09-23 21:22:52');

-- --------------------------------------------------------

--
-- Table structure for table `pqd_product`
--

CREATE TABLE `pqd_product` (
  `pqd_product_id` int(11) NOT NULL,
  `pqd_area_id` int(11) NOT NULL,
  `pqd_product_name` varchar(200) NOT NULL,
  `github_repo_name` varchar(200) DEFAULT NULL,
  `jira_project_id` int(11) DEFAULT NULL,
  `sonar_project_key` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pqd_product`
--

INSERT INTO `pqd_product` (`pqd_product_id`, `pqd_area_id`, `pqd_product_name`, `github_repo_name`, `jira_project_id`, `sonar_project_key`) VALUES
(1, 1, 'product_apim', 'product_apim', 10251, 'org.wso2.am:am-parent'),
(2, 8, 'product-as', 'product-as', 10000, 'org.wso2.appserver:wso2appserver'),
(3, 6, 'product-bps', NULL, 10140, 'org.wso2.bps:wso2bps-parent'),
(4, 2, 'product-cep', 'product-cep', 0, 'org.wso2.cep:wso2cep-parent'),
(5, 2, 'product-das', 'product-das', 10800, 'org.wso2.das:wso2das-parent'),
(6, 6, 'product-dss', NULL, 10090, 'org.wso2.dss:dataservices-parent'),
(7, 6, 'product-ei', 'product-ei', 0, 'org.wso2.ei:wso2ei-parent'),
(8, 6, 'product-esb', 'product-esb', 10023, 'org.wso2.esb:esb-parent'),
(9, 7, 'product-iots', 'product-iots', 0, 'org.wso2.iot:wso2iot-parent'),
(10, 5, 'product-is', 'product-is', 10041, 'org.wso2.is:product-is'),
(11, 6, 'product-mb', NULL, 10200, 'org.wso2.mb:mb-parent'),
(12, 2, 'siddhi', 'siddhi', 0, 'org.wso2.siddhi:siddhi'),
(13, 3, 'ballerina', 'ballerina', 0, 'org.ballerinalang:ballerina-parent'),
(14, 3, 'transports', 'carbon-transports', 0, 'org.wso2.carbon.transport:org.wso2.carbon.transport.parent'),
(15, 1, 'analytics-apim', 'analytics-apim', 11105, 'org.wso2.analytics.apim:analytics-apim'),
(16, 5, 'analytics-is', 'analytics-is', 11104, 'org.wso2.analytics.is:wso2analytics-is-parent'),
(17, 6, 'analytics-mb', 'analytics-mb', 11118, 'org.wso2.analytics.mb:wso2analytics-mb-parent'),
(18, 6, 'analytics-esb', 'analytics-esb', 11002, 'org.wso2.analytics.esb:wso2esb-analytics-parent'),
(19, 3, 'No Product', NULL, NULL, NULL),
(20, 4, 'No Product', NULL, NULL, NULL),
(21, 6, 'No Product', NULL, NULL, NULL),
(22, 8, 'No Product', NULL, NULL, NULL),
(23, 9, 'No Product', NULL, NULL, NULL),
(24, 10, 'No Product', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pqd_product_issues`
--

CREATE TABLE `pqd_product_issues` (
  `pqd_product_id` int(11) NOT NULL,
  `pqd_issue_type_id` int(11) NOT NULL,
  `pqd_severity_id` int(11) NOT NULL,
  `pqd_issues_count` int(11) NOT NULL,
  `pqd_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pqd_product_version`
--

CREATE TABLE `pqd_product_version` (
  `pqd_product_version_id` int(11) NOT NULL,
  `pqd_product_id` int(11) NOT NULL,
  `pqd_product_version` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pqd_product_version`
--

INSERT INTO `pqd_product_version` (`pqd_product_version_id`, `pqd_product_id`, `pqd_product_version`) VALUES
(0, 0, 'No Version'),
(1, 1, '2.1.0'),
(2, 2, '4.0.0'),
(3, 3, '4.0.0'),
(4, 4, '2.1.0'),
(5, 12, '4.0.0'),
(6, 5, '3.1.0'),
(7, 6, '3.0.0'),
(8, 7, '6.0.0'),
(9, 8, '5.1.0'),
(10, 9, '3.1.0'),
(11, 10, '5.2.0'),
(12, 11, '3.2.0'),
(13, 13, '3.4.0'),
(14, 14, '6.0.20');

-- --------------------------------------------------------

--
-- Table structure for table `pqd_severity`
--

CREATE TABLE `pqd_severity` (
  `pqd_severity_id` int(11) NOT NULL,
  `pqd_severity` varchar(200) NOT NULL,
  `pqd_severity_github_label_text` varchar(200) DEFAULT NULL,
  `pqd_severity_github_label_color` varchar(100) DEFAULT NULL,
  `pqd_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pqd_severity`
--

INSERT INTO `pqd_severity` (`pqd_severity_id`, `pqd_severity`, `pqd_severity_github_label_text`, `pqd_severity_github_label_color`, `pqd_updated`) VALUES
(1, 'Major', 'Severity/Major', 'b60205', '2017-09-23 21:18:44'),
(2, 'Critical', 'Severity/Critical', 'b60205', '2017-09-23 21:18:47'),
(3, 'Blocker', 'Severity/Blocker', 'b60205', '2017-09-23 21:19:32'),
(4, 'Minor', 'Severity/Minor', 'b60205', '2017-09-23 21:19:32'),
(6, 'Trivial', 'Severity/Trivial', 'b60205', '2017-09-23 21:20:21'),
(7, 'Unknown', NULL, NULL, '2017-09-23 21:23:02');

-- --------------------------------------------------------

--
-- Table structure for table `sonar_issues_date_table`
--

CREATE TABLE `sonar_issues_date_table` (
  `snapshot_id` int(11) NOT NULL,
  `date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `sonar_issues_table`
--

CREATE TABLE `sonar_issues_table` (
  `sonar_component_issue_id` int(11) NOT NULL,
  `snapshot_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `project_key` varchar(200) NOT NULL,
  `BLOCKER_BUG` int(11) NOT NULL,
  `CRITICAL_BUG` int(11) NOT NULL,
  `MAJOR_BUG` int(11) NOT NULL,
  `MINOR_BUG` int(11) NOT NULL,
  `INFO_BUG` int(11) NOT NULL,
  `BLOCKER_CODE_SMELL` int(11) NOT NULL,
  `CRITICAL_CODE_SMELL` int(11) NOT NULL,
  `MAJOR_CODE_SMELL` int(11) NOT NULL,
  `MINOR_CODE_SMELL` int(11) NOT NULL,
  `INFO_CODE_SMELL` int(11) NOT NULL,
  `BLOCKER_VULNERABILITY` int(11) NOT NULL,
  `CRITICAL_VULNERABILITY` int(11) NOT NULL,
  `MAJOR_VULNERABILITY` int(11) NOT NULL,
  `MINOR_VULNERABILITY` int(11) NOT NULL,
  `INFO_VULNERABILITY` int(11) NOT NULL,
  `total` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pqd_area`
--
ALTER TABLE `pqd_area`
  ADD PRIMARY KEY (`pqd_area_id`);

--
-- Indexes for table `pqd_component`
--
ALTER TABLE `pqd_component`
  ADD PRIMARY KEY (`pqd_component_id`,`pqd_component_name`),
  ADD KEY `fk_pqd_component_pqd_product_version1_idx` (`pqd_product_version_id`),
  ADD KEY `pqd_product_id_idx` (`pqd_product_id`),
  ADD KEY `pqd_area_id_idx` (`pqd_area_id`);

--
-- Indexes for table `pqd_issue_type`
--
ALTER TABLE `pqd_issue_type`
  ADD PRIMARY KEY (`pqd_issue_type_id`),
  ADD UNIQUE KEY `pqd_issue_type` (`pqd_issue_type`);

--
-- Indexes for table `pqd_product`
--
ALTER TABLE `pqd_product`
  ADD PRIMARY KEY (`pqd_product_id`),
  ADD KEY `pqd_area_id_idx` (`pqd_area_id`);

--
-- Indexes for table `pqd_product_version`
--
ALTER TABLE `pqd_product_version`
  ADD PRIMARY KEY (`pqd_product_version_id`),
  ADD KEY `fk_pqd_product_version_pqd_product1_idx` (`pqd_product_id`);

--
-- Indexes for table `pqd_severity`
--
ALTER TABLE `pqd_severity`
  ADD PRIMARY KEY (`pqd_severity_id`),
  ADD UNIQUE KEY `pqd_severity` (`pqd_severity`);

--
-- Indexes for table `sonar_issues_date_table`
--
ALTER TABLE `sonar_issues_date_table`
  ADD PRIMARY KEY (`snapshot_id`);

--
-- Indexes for table `sonar_issues_table`
--
ALTER TABLE `sonar_issues_table`
  ADD PRIMARY KEY (`sonar_component_issue_id`),
  ADD KEY `snapshot_id_idx` (`snapshot_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pqd_area`
--
ALTER TABLE `pqd_area`
  MODIFY `pqd_area_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT for table `pqd_component`
--
ALTER TABLE `pqd_component`
  MODIFY `pqd_component_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=175;
--
-- AUTO_INCREMENT for table `pqd_issue_type`
--
ALTER TABLE `pqd_issue_type`
  MODIFY `pqd_issue_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT for table `pqd_product`
--
ALTER TABLE `pqd_product`
  MODIFY `pqd_product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;
--
-- AUTO_INCREMENT for table `pqd_product_version`
--
ALTER TABLE `pqd_product_version`
  MODIFY `pqd_product_version_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT for table `pqd_severity`
--
ALTER TABLE `pqd_severity`
  MODIFY `pqd_severity_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `sonar_issues_date_table`
--
ALTER TABLE `sonar_issues_date_table`
  MODIFY `snapshot_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT for table `sonar_issues_table`
--
ALTER TABLE `sonar_issues_table`
  MODIFY `sonar_component_issue_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2899;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `pqd_product`
--
ALTER TABLE `pqd_product`
  ADD CONSTRAINT `pqd_area_id` FOREIGN KEY (`pqd_area_id`) REFERENCES `pqd_area` (`pqd_area_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `sonar_issues_table`
--
ALTER TABLE `sonar_issues_table`
  ADD CONSTRAINT `snapshot_id` FOREIGN KEY (`snapshot_id`) REFERENCES `sonar_issues_date_table` (`snapshot_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
