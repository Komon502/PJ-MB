-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 13, 2024 at 09:06 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `MFUrooms`
--

-- --------------------------------------------------------

--
-- Table structure for table `Building`
--

CREATE TABLE `Building` (
  `ID` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Building`
--

INSERT INTO `Building` (`ID`) VALUES
('C1'),
('C2'),
('D1');

-- --------------------------------------------------------

--
-- Table structure for table `request`
--

CREATE TABLE `request` (
  `id` int(11) NOT NULL,
  `room_slot_ID` int(11) DEFAULT NULL,
  `requestBy` int(11) DEFAULT NULL,
  `request_status` enum('0','1') DEFAULT NULL COMMENT 'Null = pending, 0 = Unapproved, 1 = approved',
  `request_reason` varchar(500) DEFAULT NULL,
  `request_date` date DEFAULT current_timestamp(),
  `approver` int(5) DEFAULT NULL,
  `borrow_status` enum('0','1','2') DEFAULT NULL COMMENT '0 = Disapproved, 1 = borrowing, 2 = returned'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `request`
--

INSERT INTO `request` (`id`, `room_slot_ID`, `requestBy`, `request_status`, `request_reason`, `request_date`, `approver`, `borrow_status`) VALUES
(1, 1, 1, '0', 'test 55900wdadksdlawdjaslkdj lkwjdkl asjdklj awkldjlkawj dlkasj lkdjwal sdopi wapdi a;sldk ;lwka ;lskd;lkwa;ls kd;lwk a;ksd ;lwk;l dka;ld kas;lkd ;lwak ;ldwkad ;lawkl;d awk;dl kwal;d sapodi wapodi wpoadk l;askd wpoadipoasd l; kwa;ld k', '2024-10-30', 2, '0'),
(13, 2, 5, '1', 'Good room jubjub', '2024-11-01', 2, '2'),
(14, 5, 6, '0', 'Test1\n', '2024-11-01', NULL, '0');

-- --------------------------------------------------------

--
-- Table structure for table `Room`
--

CREATE TABLE `Room` (
  `ID` int(11) NOT NULL,
  `building` varchar(10) DEFAULT NULL,
  `image` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Room`
--

INSERT INTO `Room` (`ID`, `building`, `image`) VALUES
(1, 'C1', 'room1.jpg'),
(2, 'C1', 'room1.jpg'),
(3, 'C1', 'room1.jpg'),
(4, 'C1', 'room1.jpg'),
(5, 'C1', 'room1.jpg'),
(6, 'C2', 'room2.jpg'),
(7, 'D1', 'room3.jpg'),
(8, 'D1', 'room3.jpg'),
(9, 'D1', 'room3.jpg'),
(10, 'C2', 'room2.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `room_time_slots`
--

CREATE TABLE `room_time_slots` (
  `slotID` int(11) NOT NULL,
  `roomID` int(11) DEFAULT NULL,
  `time_slot_id` int(11) DEFAULT NULL,
  `room_time_status` enum('0','1') NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `room_time_slots`
--

INSERT INTO `room_time_slots` (`slotID`, `roomID`, `time_slot_id`, `room_time_status`) VALUES
(1, 1, 1, '1'),
(2, 1, 2, '1'),
(3, 1, 3, '1'),
(4, 1, 4, '1'),
(5, 6, 1, '1'),
(6, 6, 3, '1'),
(7, 2, 1, '1'),
(8, 2, 2, '1'),
(9, 2, 3, '1'),
(10, 2, 4, '1'),
(11, 3, 1, '1'),
(12, 3, 2, '1');

-- --------------------------------------------------------

--
-- Table structure for table `time_slots`
--

CREATE TABLE `time_slots` (
  `time_slot_id` int(11) NOT NULL,
  `borrow_time` time NOT NULL,
  `return_time` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `time_slots`
--

INSERT INTO `time_slots` (`time_slot_id`, `borrow_time`, `return_time`) VALUES
(1, '08:00:00', '10:00:00'),
(2, '10:00:00', '12:00:00'),
(3, '13:00:00', '15:00:00'),
(4, '15:00:00', '17:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `User`
--

CREATE TABLE `User` (
  `id` int(11) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0 = user, 1 = approver, 2 = staff',
  `borrowQuota` int(1) NOT NULL DEFAULT 1,
  `username` varchar(50) DEFAULT NULL,
  `studentID` bigint(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `User`
--

INSERT INTO `User` (`id`, `email`, `password`, `role`, `borrowQuota`, `username`, `studentID`) VALUES
(1, 'user@example.com', '$2b$10$Mezb8Ek15oSk32T.JZu2cOmHV0J.mhK/x5PeIHlYlAS9zWj3nRL/i', 0, 0, 'user', 6531501999),
(2, 'approver@example.com', '$2b$10$Mezb8Ek15oSk32T.JZu2cOmHV0J.mhK/x5PeIHlYlAS9zWj3nRL/i', 1, 1, 'approver', NULL),
(3, 'staff@example.com', '$2b$10$Mezb8Ek15oSk32T.JZu2cOmHV0J.mhK/x5PeIHlYlAS9zWj3nRL/i', 2, 1, 'staff', NULL),
(4, 'Tese@Email.com', '$2b$10$okDFzW1mksE2TebzP3trHupcHmFgvcBrXJbR2FahyJ6k6rR42LKMy', 0, 1, 'test', 6531501998),
(5, 'nes@gmail.com', '$2b$10$ZJd9v4ZTrsx3sJmZMtj5tOd4PNoaKrew/JbqgsR0wQBMh2UNt4hfu', 0, 1, 'Nes', 6531501997),
(6, 'test2@gmail.com', '$2b$10$d41II6qT6YyZ9.kgAQbBxeI.VoxG8ApIzhtM2nj8KIsoqMLHbflTa', 0, 1, 'test2', 6531501922);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Building`
--
ALTER TABLE `Building`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `request`
--
ALTER TABLE `request`
  ADD PRIMARY KEY (`id`),
  ADD KEY `room_slot_ID` (`room_slot_ID`),
  ADD KEY `requestBy` (`requestBy`),
  ADD KEY `request_ibfk_3` (`approver`);

--
-- Indexes for table `Room`
--
ALTER TABLE `Room`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `building` (`building`);

--
-- Indexes for table `room_time_slots`
--
ALTER TABLE `room_time_slots`
  ADD PRIMARY KEY (`slotID`),
  ADD KEY `roomID` (`roomID`),
  ADD KEY `time_slot_id` (`time_slot_id`);

--
-- Indexes for table `time_slots`
--
ALTER TABLE `time_slots`
  ADD PRIMARY KEY (`time_slot_id`);

--
-- Indexes for table `User`
--
ALTER TABLE `User`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `request`
--
ALTER TABLE `request`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `room_time_slots`
--
ALTER TABLE `room_time_slots`
  MODIFY `slotID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `time_slots`
--
ALTER TABLE `time_slots`
  MODIFY `time_slot_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `User`
--
ALTER TABLE `User`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `request`
--
ALTER TABLE `request`
  ADD CONSTRAINT `request_ibfk_1` FOREIGN KEY (`room_slot_ID`) REFERENCES `room_time_slots` (`slotID`),
  ADD CONSTRAINT `request_ibfk_2` FOREIGN KEY (`requestBy`) REFERENCES `User` (`id`),
  ADD CONSTRAINT `request_ibfk_3` FOREIGN KEY (`approver`) REFERENCES `User` (`id`);

--
-- Constraints for table `Room`
--
ALTER TABLE `Room`
  ADD CONSTRAINT `room_ibfk_1` FOREIGN KEY (`building`) REFERENCES `Building` (`ID`);

--
-- Constraints for table `room_time_slots`
--
ALTER TABLE `room_time_slots`
  ADD CONSTRAINT `room_time_slots_ibfk_1` FOREIGN KEY (`roomID`) REFERENCES `room` (`ID`),
  ADD CONSTRAINT `room_time_slots_ibfk_2` FOREIGN KEY (`time_slot_id`) REFERENCES `time_slots` (`time_slot_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
