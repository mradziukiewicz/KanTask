-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 172.17.0.4
-- Generation Time: Jan 11, 2025 at 06:35 PM
-- Server version: 9.1.0
-- PHP Version: 8.2.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `djangodb`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`%` PROCEDURE `add_comment` (IN `task_id` BIGINT, IN `comment_text` TEXT)   BEGIN
    INSERT INTO authentication_comment (content, created_at, task_id, author_id)
    VALUES (comment_text, NOW(), task_id, 19);
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `assign_technician` ()   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE task_id BIGINT;
    DECLARE technician_id BIGINT;
    DECLARE task_cursor CURSOR FOR
        SELECT id FROM authentication_task
        WHERE assigned_user_id IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN task_cursor;

    read_loop: LOOP
        FETCH task_cursor INTO task_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Pobierz losowego użytkownika z grupy engineer
        SELECT user_id INTO technician_id
        FROM authentication_user_groups
        WHERE group_id = 3
        ORDER BY RAND()
        LIMIT 1;

        -- Przypisz technika do zadania
        UPDATE authentication_task
        SET assigned_user_id = technician_id
        WHERE id = task_id;

        -- Dodaj komentarz o przydziale
        CALL add_comment(task_id, CONCAT('Technician with ID ', technician_id, ' has been assigned to the task.'));
    END LOOP;

    CLOSE task_cursor;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `check_sla_deadline` ()   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE task_id BIGINT;
    DECLARE task_cursor CURSOR FOR
        SELECT id FROM authentication_task
        WHERE DATE(sla_deadline) = DATE_ADD(CURDATE(), INTERVAL 1 DAY)
          AND status != 'Completed'
          AND NOT EXISTS (
              SELECT 1 FROM authentication_comment
              WHERE task_id = authentication_task.id
              AND content = 'SLA deadline is approaching in less than 24 hours.'
          );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN task_cursor;

    read_loop: LOOP
        FETCH task_cursor INTO task_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        CALL add_comment(task_id, 'SLA deadline is approaching in less than 24 hours.');
    END LOOP;

    CLOSE task_cursor;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `check_sla_overdue` ()   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE task_id BIGINT;
    DECLARE task_cursor CURSOR FOR
        SELECT id FROM authentication_task
        WHERE sla_deadline < NOW() AND resolved_after_deadline = 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN task_cursor;

    read_loop: LOOP
        FETCH task_cursor INTO task_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        CALL add_comment(task_id, 'SLA deadline has been missed.');
        UPDATE authentication_task SET resolved_after_deadline = 1 WHERE id = task_id;
    END LOOP;

    CLOSE task_cursor;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `authentication_comment`
--

CREATE TABLE `authentication_comment` (
  `id` bigint NOT NULL,
  `content` longtext COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `author_id` bigint NOT NULL,
  `task_id` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `authentication_comment`
--

INSERT INTO `authentication_comment` (`id`, `content`, `created_at`, `author_id`, `task_id`) VALUES
(6, 'Task status changed to In Progress by admin.', '2025-01-02 00:00:00', 1, 4),
(7, 'Task status changed to Pending by admin.', '2025-01-02 00:00:00', 1, 4),
(8, 'Task status changed to In Progress by admin.', '2025-01-02 00:00:00', 1, 4),
(9, 'Task status changed to Pending by admin.', '2025-01-02 00:00:00', 1, 4),
(10, 'Task status changed to In Progress by admin.', '2025-01-02 00:00:00', 1, 2),
(11, 'Task status changed to Completed by admin.', '2025-01-02 00:00:00', 1, 2),
(12, 'Task status changed to Completed by admin.', '2025-01-02 00:00:00', 1, 3),
(15, 'Task status changed to In Progress by Szymon_Mazurek.', '2025-01-03 00:00:00', 2, 2),
(18, 'Task status changed to In Progress by admin.', '2025-01-03 00:00:00', 1, 7),
(19, 'Task status changed to Pending by admin.', '2025-01-03 00:00:00', 1, 7),
(21, 'Task status changed to Pending by admin.', '2025-01-03 00:00:00', 1, 3),
(24, 'Task status changed to Completed by admin.', '2025-01-04 00:00:00', 1, 2),
(29, 'Task status changed to Pending by admin.', '2025-01-04 00:00:00', 1, 1),
(30, 'Task status changed to Pending by admin.', '2025-01-04 00:00:00', 1, 1),
(31, 'Task status changed to In Progress by admin.', '2025-01-04 00:00:00', 1, 1),
(32, 'Task status changed to In Progress by admin.', '2025-01-04 00:00:00', 1, 1),
(36, 'Task status changed to In Progress by admin.', '2025-01-04 00:00:00', 1, 15),
(37, 'Task status changed to In Progress by admin.', '2025-01-04 00:00:00', 1, 16),
(38, 'Task status changed to Completed by admin.', '2025-01-04 00:00:00', 1, 16),
(39, 'Task status changed to In Progress by admin.', '2025-01-04 00:00:00', 1, 17),
(40, 'Task status changed to Completed by admin.', '2025-01-04 00:00:00', 1, 17),
(41, 'Task status changed to In Progress by admin.', '2025-01-04 00:00:00', 1, 23),
(42, 'Task status changed to Completed by admin.', '2025-01-04 00:00:00', 1, 23),
(43, 'Task status changed to Completed by admin.', '2025-01-04 00:00:00', 1, 12),
(44, 'Task status changed to In Progress by admin.', '2025-01-04 00:00:00', 1, 28),
(45, 'Task status changed to Completed by admin.', '2025-01-04 00:00:00', 1, 28),
(46, 'Task status changed to Completed by admin.', '2025-01-04 00:00:00', 1, 17),
(47, 'Task status changed to Completed by admin.', '2025-01-04 00:00:00', 1, 16),
(48, 'Task status changed to In Progress by admin.', '2025-01-04 00:00:00', 1, 28),
(49, 'Task status changed to In Progress by admin.', '2025-01-04 00:00:00', 1, 29),
(50, 'Task status changed to Completed by admin.', '2025-01-04 00:00:00', 1, 29),
(51, 'Task status changed to In Progress by Michał_radziuk.', '2025-01-04 00:00:00', 4, 2),
(52, 'Task status changed to Completed by Michał_radziuk.', '2025-01-04 00:00:00', 4, 2),
(53, 'Task status changed to In Progress by admin.', '2025-01-05 00:00:00', 1, 29),
(54, 'Task status changed to Completed by admin.', '2025-01-05 00:00:00', 1, 29),
(55, 'Task status changed to In Progress by admin.', '2025-01-05 00:00:00', 1, 7),
(56, 'Task status changed to In Progress by admin.', '2025-01-05 00:00:00', 1, 29),
(57, 'Task status changed to Pending by admin.', '2025-01-05 00:00:00', 1, 63),
(58, 'Task status changed to In Progress by admin.', '2025-01-05 00:00:00', 1, 106),
(59, 'Mail w sprawie kosztorysu został wysłany do dostawcy', '2025-01-05 00:00:00', 1, 106),
(60, 'Task status changed to In Progress by admin.', '2025-01-05 00:00:00', 1, 106),
(61, 'Task status changed to Completed by admin.', '2025-01-05 00:00:00', 1, 106),
(62, 'Task status changed to In Progress by admin.', '2025-01-05 00:00:00', 1, 106),
(63, 'Task status changed to Completed by admin.', '2025-01-05 00:00:00', 1, 1),
(64, 'Wygląda na no że wymagany jest update BIOS', '2025-01-05 00:00:00', 1, 112),
(65, 'Task status changed to In Progress by admin.', '2025-01-05 00:00:00', 1, 112),
(66, 'kom', '2025-01-05 00:00:00', 1, 111),
(67, 'Task status changed to Completed by admin.', '2025-01-05 00:00:00', 1, 112),
(68, 'do zrobienia', '2025-01-05 00:00:00', 7, 10),
(69, 'Task status changed to In Progress by Mariusz_Pudzianowski.', '2025-01-05 00:00:00', 7, 10),
(70, 'Task status changed to In Progress by admin.', '2025-01-11 00:00:00', 1, 62),
(71, 'Task status changed to Pending by admin.', '2025-01-11 00:00:00', 1, 62),
(72, 'Task status changed to In Progress by admin.', '2025-01-11 00:00:00', 1, 62),
(73, 'Task status changed to Pending by admin.', '2025-01-11 00:00:00', 1, 62),
(74, 'Task status changed to In Progress.', '2025-01-11 00:00:00', 19, 62),
(75, 'Task status changed to Pending.', '2025-01-11 00:00:00', 19, 62),
(76, 'Task status changed to In Progress.', '2025-01-11 00:00:00', 19, 62),
(77, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 7),
(78, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 28),
(79, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 29),
(80, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 103),
(81, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 106),
(82, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 107),
(83, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 108),
(84, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 109),
(85, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 111),
(86, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 112),
(87, 'SLA deadline has been missed.', '2025-01-11 00:00:00', 19, 62),
(90, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(91, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(92, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(93, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(94, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(95, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(96, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(97, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(98, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(99, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(100, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(101, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(102, 'Technician with ID 18 has been assigned to the task.', '2025-01-11 00:00:00', 19, 17),
(103, 'Technician with ID 4 has been assigned to the task.', '2025-01-11 00:00:00', 19, 23),
(104, 'Technician with ID 17 has been assigned to the task.', '2025-01-11 00:00:00', 19, 116),
(105, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(106, 'Technician with ID 16 has been assigned to the task.', '2025-01-11 00:00:00', 19, 18),
(107, 'Technician with ID 4 has been assigned to the task.', '2025-01-11 00:00:00', 19, 23),
(108, 'Technician with ID 16 has been assigned to the task.', '2025-01-11 00:00:00', 19, 116),
(109, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(110, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(111, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(112, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(113, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(114, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(115, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(116, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(117, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(118, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(119, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(120, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(121, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(122, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(123, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(124, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(125, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(126, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(127, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(128, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(129, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(130, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(131, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(132, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(133, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(134, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(135, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(136, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(137, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(138, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(139, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(140, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(141, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 11),
(142, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(143, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 11),
(144, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(145, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 11),
(146, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(147, 'Task status changed to In Progress.', '2025-01-11 00:00:00', 19, 116),
(148, 'Task status changed to Pending.', '2025-01-11 00:00:00', 19, 116),
(149, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(150, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(151, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(152, 'Technician with ID 16 has been assigned to the task.', '2025-01-11 00:00:00', 19, 117),
(153, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(154, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(155, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(156, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(157, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(158, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(159, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(160, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(161, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(162, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(163, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(164, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(165, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(166, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(167, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(168, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(169, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(170, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(171, 'SLA deadline is approaching on 2025-01-12.', '2025-01-11 00:00:00', 19, 115),
(172, 'SLA deadline is approaching on 2025-01-12.', '2025-01-11 00:00:00', 19, 117),
(173, 'SLA deadline is approaching on 2025-01-12.', '2025-01-11 00:00:00', 19, 115),
(174, 'SLA deadline is approaching on 2025-01-12.', '2025-01-11 00:00:00', 19, 117),
(175, 'SLA deadline is approaching on 2025-01-12.', '2025-01-11 00:00:00', 19, 115),
(176, 'SLA deadline is approaching on 2025-01-12.', '2025-01-11 00:00:00', 19, 117),
(177, 'SLA deadline is approaching on 2025-01-12.', '2025-01-11 00:00:00', 19, 115),
(178, 'SLA deadline is approaching on 2025-01-12.', '2025-01-11 00:00:00', 19, 117),
(179, 'SLA deadline is approaching on 2025-01-12.', '2025-01-11 00:00:00', 19, 115),
(180, 'SLA deadline is approaching on 2025-01-12.', '2025-01-11 00:00:00', 19, 117),
(181, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(182, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(183, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(184, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(185, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(186, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(187, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(188, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(189, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(190, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(191, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(192, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(193, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(194, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(195, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(196, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(197, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(198, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(199, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(200, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(201, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(202, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(203, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 115),
(204, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 00:00:00', 19, 117),
(205, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:38:50', 19, 115),
(206, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:38:50', 19, 117),
(207, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:39:50', 19, 115),
(208, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:39:50', 19, 117),
(209, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:40:50', 19, 115),
(210, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:40:50', 19, 117),
(211, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:41:50', 19, 115),
(212, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:41:50', 19, 117),
(213, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:42:50', 19, 115),
(214, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:42:50', 19, 117),
(215, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:43:50', 19, 115),
(216, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:43:50', 19, 117),
(217, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:44:50', 19, 115),
(218, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:44:50', 19, 117),
(219, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:45:50', 19, 115),
(220, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:45:50', 19, 117),
(221, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:46:50', 19, 115),
(222, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:46:50', 19, 117),
(223, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:47:50', 19, 115),
(224, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:47:50', 19, 117),
(225, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:48:50', 19, 115),
(226, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:48:50', 19, 117),
(227, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:49:50', 19, 115),
(228, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:49:50', 19, 117),
(229, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:50:50', 19, 115),
(230, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:50:50', 19, 117),
(231, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:51:50', 19, 115),
(232, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:51:50', 19, 117),
(233, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:52:50', 19, 115),
(234, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:52:50', 19, 117),
(235, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:53:50', 19, 115),
(236, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:53:50', 19, 117),
(237, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:54:50', 19, 115),
(238, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:54:50', 19, 117),
(239, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:55:50', 19, 115),
(240, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:55:50', 19, 117),
(241, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:56:50', 19, 115),
(242, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:56:50', 19, 117),
(243, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:57:50', 19, 115),
(244, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:57:50', 19, 117),
(245, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:58:50', 19, 115),
(246, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:58:50', 19, 117),
(247, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:59:50', 19, 115),
(248, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 17:59:50', 19, 117),
(249, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:00:50', 19, 115),
(250, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:00:50', 19, 117),
(251, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:01:50', 19, 115),
(252, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:01:50', 19, 117),
(253, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:02:50', 19, 115),
(254, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:02:50', 19, 117),
(255, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:03:50', 19, 115),
(256, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:03:50', 19, 117),
(257, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:04:50', 19, 115),
(258, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:04:50', 19, 117),
(259, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:05:50', 19, 115),
(260, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:05:50', 19, 117),
(261, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:06:50', 19, 115),
(262, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:06:50', 19, 117),
(263, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:07:50', 19, 115),
(264, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:07:50', 19, 117),
(265, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:08:50', 19, 115),
(266, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:08:50', 19, 117),
(267, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:09:50', 19, 115),
(268, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:09:50', 19, 117),
(269, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:10:50', 19, 115),
(270, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:10:50', 19, 117),
(271, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:11:50', 19, 115),
(272, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:11:50', 19, 117),
(273, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:12:50', 19, 115),
(274, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:12:50', 19, 117),
(275, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:13:50', 19, 115),
(276, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:13:50', 19, 117),
(277, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:14:50', 19, 115),
(278, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:14:50', 19, 117),
(279, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:15:50', 19, 115),
(280, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:15:50', 19, 117),
(281, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:16:50', 19, 115),
(282, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:16:50', 19, 117),
(283, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:17:50', 19, 115),
(284, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:17:50', 19, 117),
(285, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:18:50', 19, 115),
(286, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:18:50', 19, 117),
(287, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:19:50', 19, 115),
(288, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:19:50', 19, 117),
(289, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:20:50', 19, 115),
(290, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:20:50', 19, 117),
(291, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:21:50', 19, 115),
(292, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:21:50', 19, 117),
(293, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:22:50', 19, 115),
(294, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:22:50', 19, 117),
(295, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:23:50', 19, 115),
(296, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:23:50', 19, 117),
(297, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:24:50', 19, 115),
(298, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:24:50', 19, 117),
(299, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:25:50', 19, 115),
(300, 'SLA deadline is approaching in less than 24 hours.', '2025-01-11 18:25:50', 19, 117);

-- --------------------------------------------------------

--
-- Table structure for table `authentication_incident`
--

CREATE TABLE `authentication_incident` (
  `id` bigint NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `created_by_id` bigint NOT NULL,
  `project_id` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `authentication_incident`
--

INSERT INTO `authentication_incident` (`id`, `title`, `description`, `created_at`, `created_by_id`, `project_id`) VALUES
(1, 'Tworzenie Dokumentacji projektowej', 'Należy wykonać dokumentację projektową opisującą działanie aplikacji', '2025-01-05 12:50:39.149116', 1, 1),
(2, 'pomoc', 'prosze pomoc komputer nie dziala', '2025-01-05 15:51:20.973744', 5, 1),
(3, 'fdgfgdgfdgfdg', 'fdgfdgfgdfg', '2025-01-05 16:05:52.775153', 1, 4);

-- --------------------------------------------------------

--
-- Table structure for table `authentication_project`
--

CREATE TABLE `authentication_project` (
  `id` bigint NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `description` longtext COLLATE utf8mb4_general_ci NOT NULL,
  `owner_id` bigint NOT NULL,
  `customer_id` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `authentication_project`
--

INSERT INTO `authentication_project` (`id`, `name`, `description`, `owner_id`, `customer_id`) VALUES
(1, 'IT Helpdesk', 'Aplkacja do zgłaszania problemów IT', 6, 5),
(2, 'Server Management', 'Utrzymanie infrastryktury serwerów, aktualizacje oraz usprawnienia', 7, 8),
(3, 'Customer Feedback Portal', 'Budowa portalu do zbierania opinii klientów i analizy satysfakcji', 6, 8),
(4, 'Cloud Migration', 'Migracja infrastruktury IT do chmury obliczeniowej', 7, 5),
(5, 'Inventory Management System', 'Tworzenie systemu zarządzania stanami magazynowymi', 7, 8),
(6, 'Dział administracyjny', 'Projekt obejmuje zarządzanie incydentami, raportami oraz analizę danych operacyjnych w celu optymalizacji działań. Administratorzy mają dostęp do szczegółowych raportów i widoków analitycznych, takich jak średni czas realizacji zgłoszeń czy liczba zgłoszeń w podziale na kategorie.', 7, 5);

-- --------------------------------------------------------

--
-- Table structure for table `authentication_task`
--

CREATE TABLE `authentication_task` (
  `id` bigint NOT NULL,
  `subject` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `description` longtext COLLATE utf8mb4_general_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `priority` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `closed_at` datetime(6) DEFAULT NULL,
  `completion_percentage` double NOT NULL,
  `sla_deadline` date DEFAULT NULL,
  `resolved_after_deadline` tinyint(1) NOT NULL,
  `solution` longtext COLLATE utf8mb4_general_ci,
  `assigned_user_id` bigint DEFAULT NULL,
  `parent_task_id` bigint DEFAULT NULL,
  `project_id` bigint NOT NULL,
  `time_spent` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `authentication_task`
--

INSERT INTO `authentication_task` (`id`, `subject`, `description`, `status`, `priority`, `created_at`, `closed_at`, `completion_percentage`, `sla_deadline`, `resolved_after_deadline`, `solution`, `assigned_user_id`, `parent_task_id`, `project_id`, `time_spent`) VALUES
(1, 'Wydanie laptopa', 'Wydanie laptopa', 'Completed', 'normal', '2024-12-29 18:37:22.000000', NULL, 0, '2025-01-23', 1, 'Laptop został wydany', 3, NULL, 1, 1.00),
(2, 'Instalacja linux', 'Instalacja windowss', 'Completed', 'normal', '2024-12-29 18:37:58.000000', NULL, 0, '2025-01-27', 1, 'skonczone', 4, 4, 1, 1.00),
(3, 'Wymiana dysków', 'Wymiana dysków', 'Pending', 'normal', '2024-12-29 18:38:57.000000', NULL, 0, '2025-01-01', 1, 'zrobione', 3, NULL, 1, 1.00),
(4, 'Migracja danych', 'Migracja danych', 'In Progress', 'normal', '2024-12-29 18:39:34.000000', NULL, 0, '2024-12-31', 1, '', 4, NULL, 1, NULL),
(7, 'Kopia zapasowa', 'zrób żeby się nic nie zgubiło0', 'In Progress', 'normal', '2025-01-02 22:06:50.562665', NULL, 0, '2025-01-09', 1, NULL, 2, 4, 1, NULL),
(10, 'Wydanie AccesPointa', 'Wydanie AccesPointa dla klienta Zbigniew_Orzełl', 'In Progress', 'normal', '2025-01-03 12:55:20.366376', NULL, 0, '2025-01-14', 0, NULL, 4, NULL, 2, NULL),
(11, 'Stworzenie formularza opinii', 'Zaplanowanie i wdrożenie formularza opinii klientów', 'Completed', 'normal', '2025-01-04 12:57:47.000000', NULL, 0, '2025-01-12', 0, NULL, 2, NULL, 3, NULL),
(12, 'Analiza danych opinii', 'Przygotowanie narzędzi do analizy zebranych danych', 'Completed', 'normal', '2025-01-04 12:57:47.000000', NULL, 0, '2025-01-20', 0, NULL, 3, 11, 3, NULL),
(14, 'Zaprojektowanie interfejsu użytkownika', 'Stworzenie intuicyjnego UI dla portalu opinii', 'In Progress', 'high', '2025-01-04 13:01:06.000000', NULL, 0, '2025-01-18', 0, NULL, 2, NULL, 3, NULL),
(15, 'Makiety portalu', 'Przygotowanie makiet i prototypów interfejsu', 'Completed', 'normal', '2025-01-04 13:01:06.000000', NULL, 0, '2025-01-20', 0, NULL, 2, 14, 3, NULL),
(16, 'Walidacja makiet', 'Sprawdzenie makiet z zespołem UX/UI', 'Completed', 'normal', '2025-01-04 13:01:06.000000', NULL, 0, '2025-01-22', 0, 'Makiety są poprawne, zakończono', 4, 15, 3, 3.00),
(17, 'Implementacja interfejsu', 'Kodowanie zaprojektowanego interfejsu w systemie', 'Completed', 'high', '2025-01-04 13:01:06.000000', NULL, 0, '2025-01-30', 0, 'Utworzono interfejs', 18, 15, 3, 12.00),
(18, 'Integracja z bazą danych', 'Połączenie portalu z bazą opinii klientów', 'Pending', 'high', '2025-01-04 13:01:06.000000', NULL, 0, '2025-01-25', 0, NULL, 16, NULL, 3, NULL),
(19, 'Stworzenie modelu danych', 'Zaprojektowanie struktury tabel dla opinii', 'Pending', 'normal', '2025-01-04 13:01:06.000000', NULL, 0, '2025-01-18', 0, NULL, 6, 18, 3, NULL),
(20, 'Implementacja modelu danych', 'Wdrożenie modelu danych do systemu', 'Pending', 'high', '2025-01-04 13:01:06.000000', NULL, 0, '2025-01-22', 0, NULL, 5, 19, 3, NULL),
(21, 'Testy integracyjne', 'Sprawdzenie poprawności integracji portalu z bazą danych', 'Pending', 'normal', '2025-01-04 13:01:06.000000', NULL, 0, '2025-01-30', 0, NULL, 7, 18, 3, NULL),
(22, 'Monitorowanie błędów', 'Wdrożenie systemu logowania błędów w bazie', 'Pending', 'normal', '2025-01-04 13:01:06.000000', NULL, 0, '2025-02-05', 0, NULL, 6, 18, 3, NULL),
(23, 'Tworzenie dokumentacji użytkownika', 'Przygotowanie instrukcji obsługi portalu opinii', 'Completed', 'normal', '2025-01-04 13:01:06.000000', NULL, 0, '2025-02-10', 0, 'zrobione', 4, NULL, 3, 1.00),
(24, 'Szkolenie zespołu', 'Przeprowadzenie szkolenia dla zespołu obsługi portalu', 'In Progress', 'normal', '2025-01-04 13:01:06.000000', NULL, 0, '2025-02-15', 0, NULL, 4, NULL, 3, NULL),
(28, 'Wyszkól pracownika Andrzje Golara', 'Przeprowadź szczegółowe szkolenie dla tego pracownika', 'In Progress', 'low', '2025-01-04 22:09:00.031705', NULL, 0, '2025-01-11', 1, 'Wyszkolono', 3, 24, 3, 2.00),
(29, 'Szkolenie z obsługi panelu helpdesk', 'Szkolenie z obsługi panelu helpdesk dokładne', 'In Progress', 'normal', '2025-01-04 22:11:33.313473', NULL, 0, '2025-01-11', 1, 'Wyszkolono', 2, 28, 3, 1.00),
(60, 'Organizacja szkoleń zespołowych', 'Zaplanowanie i przeprowadzenie cyklu szkoleń.', 'Pending', 'high', '2025-01-05 13:25:56.000000', NULL, 0, '2025-01-20', 0, NULL, 2, NULL, 1, NULL),
(61, 'Modernizacja infrastruktury sieciowej', 'Wymiana sprzętu sieciowego i aktualizacja oprogramowania.', 'In Progress', 'medium', '2025-01-05 13:25:56.000000', NULL, 20, '2025-02-15', 0, NULL, 3, NULL, 2, NULL),
(62, 'Zarządzanie dokumentacją działu IT', 'Stworzenie repozytorium dokumentów projektowych.', 'In Progress', 'normal', '2025-01-05 13:25:56.000000', NULL, 0, '2025-01-11', 1, NULL, 4, NULL, 3, NULL),
(63, 'Audyt bezpieczeństwa systemów', 'Przeprowadzenie szczegółowego audytu w zakresie bezpieczeństwa.', 'In Progress', 'high', '2025-01-05 13:25:56.000000', NULL, 100, '2025-01-10', 1, NULL, 2, NULL, 4, NULL),
(64, 'Opracowanie strategii działań na rok 2025', 'Przygotowanie planu operacyjnego dla zespołu.', 'Pending', 'low', '2025-01-05 13:25:56.000000', NULL, 0, '2025-03-01', 0, NULL, 16, NULL, 5, NULL),
(100, 'Przygotowanie dokumentacji wewnętrznej', 'Utworzenie kompletu dokumentów dla zespołu administracyjnego.', 'Pending', 'normal', '2025-01-05 12:55:37.000000', NULL, 0, '2025-01-15', 0, NULL, 2, NULL, 6, NULL),
(101, 'Organizacja szkoleń dla nowych pracowników', 'Zorganizowanie cyklu szkoleń z zasad pracy w systemie.', 'In Progress', 'medium', '2025-01-05 12:55:37.000000', NULL, 50, '2025-01-20', 0, NULL, 3, NULL, 6, NULL),
(102, 'Zamówienie sprzętu biurowego', 'Zakup niezbędnych materiałów biurowych, takich jak papier i tonery.', 'Pending', 'low', '2025-01-05 12:55:37.000000', NULL, 0, '2025-01-25', 0, NULL, 4, NULL, 6, NULL),
(103, 'Weryfikacja dokumentów kadrowych', 'Sprawdzenie poprawności i kompletności danych pracowników w systemie.', 'Completed', 'high', '2025-01-05 12:55:37.000000', NULL, 100, '2025-01-10', 1, NULL, 16, NULL, 6, NULL),
(104, 'Opracowanie polityki bezpieczeństwa', 'Przygotowanie polityki bezpieczeństwa danych dla działu administracyjnego.', 'Pending', 'high', '2025-01-05 12:55:37.000000', NULL, 0, '2025-01-18', 0, NULL, 2, NULL, 6, NULL),
(105, 'Sprawdzanie jakości zabezpieczeń dla pracowników firmy', 'Weryfikacja jakości zabezpieczeń dla każdego pracownika', 'In Progress', 'normal', '2025-01-05 13:30:20.460209', NULL, 0, '2025-01-15', 0, NULL, 4, 63, 4, NULL),
(106, 'Logowanie dwuetapowe', 'Weryfikacja ustawień logowania dwuetapowego w strukturze organizacji', 'In Progress', 'normal', '2025-01-05 13:31:34.321512', NULL, 0, '2025-01-09', 1, 'Zarząd zgodził się na warunki zaproponowane kosztorysie od dostawcyi zewnętrzny vendor jest w trakcie\r\nimplementacji', 4, 105, 4, 2.00),
(107, 'Zmiana haseł', 'Kwartalna zmiana haseł dla pracowników organizacji', 'Pending', 'normal', '2025-01-05 13:32:23.350939', NULL, 0, '2025-01-10', 1, NULL, 3, 63, 4, NULL),
(108, 'Wymiana Routerów', 'Wymiana Routerów na urządzenia firmy Cisco', 'In Progress', 'normal', '2025-01-05 13:33:44.712107', NULL, 0, '2025-01-08', 1, NULL, 2, 61, 2, NULL),
(109, 'Konfiguracja urządzeń sieciowych', 'Konfiguracja nowych routerów Cisco na potrzeby organizacji', 'In Progress', 'normal', '2025-01-05 13:35:01.337595', NULL, 0, '2025-01-09', 1, NULL, 18, 61, 2, NULL),
(111, 'Wiesławowi Wirzurze nie działa komputer', 'Proszę się skontaktować z użytkownikiem, zdiagnozować problem i postarać się go rozwiązać.\r\n\r\nTo pilne!', 'Completed', 'high', '2025-01-05 15:53:33.944282', NULL, 0, '2025-01-07', 1, NULL, 17, NULL, 1, NULL),
(112, 'Bład BIOS', 'Podczas uruchamiania komputera wyskakuje błąd BIOS nr 0x23243', 'Completed', 'normal', '2025-01-05 15:56:28.024531', NULL, 0, '2025-01-07', 1, 'zrobione', 16, 111, 1, 1.10),
(113, 'Napraw komputer', 'opis', 'Pending', 'normal', '2025-01-05 16:17:23.719086', NULL, 0, '2025-01-15', 0, NULL, 17, NULL, 1, NULL),
(115, 'SLA deadline sql trigger test', 'SLA deadline sql trigger test', 'Pending', 'normal', '2025-01-11 16:22:22.631714', NULL, 0, '2025-01-12', 0, NULL, 2, NULL, 3, NULL),
(116, 'zz', 'zz', 'Pending', 'normal', '2025-01-11 16:27:19.313203', NULL, 0, '2025-01-24', 0, NULL, 16, NULL, 3, NULL),
(117, 'test SQL procedure', 'test SQL procedure', 'Pending', 'normal', '2025-01-11 17:11:08.669459', NULL, 0, '2025-01-12', 0, NULL, 16, 116, 3, NULL);

--
-- Triggers `authentication_task`
--
DELIMITER $$
CREATE TRIGGER `trigger_status_change` AFTER UPDATE ON `authentication_task` FOR EACH ROW BEGIN
    IF OLD.status != NEW.status THEN
        CALL add_comment(NEW.id, CONCAT('Task status changed to ', NEW.status, '.'));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `authentication_user`
--

CREATE TABLE `authentication_user` (
  `id` bigint NOT NULL,
  `password` varchar(128) COLLATE utf8mb4_general_ci NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) COLLATE utf8mb4_general_ci NOT NULL,
  `first_name` varchar(150) COLLATE utf8mb4_general_ci NOT NULL,
  `last_name` varchar(150) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_general_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `authentication_user`
--

INSERT INTO `authentication_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `first_name`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`) VALUES
(1, 'pbkdf2_sha256$870000$wfwbYPfwE8p515iA3QVOq4$9su4lMUoRWpk+Fvrf69xsPDb+NxQz6D2k6qhFC3N6cY=', '2025-01-11 15:50:45.768359', 1, 'admin', '', '', 'mazurekszymon@gmail.com', 1, 1, '2024-12-29 13:37:29.637296'),
(2, 'pbkdf2_sha256$870000$SyxEM63Y48yGOvTsuztLCb$mGh/QXFFYcb/23csRK5DU+P4tO1Qow9uawUhZ66BmMQ=', '2025-01-05 14:57:41.529084', 0, 'Szymon_Mazurek', 'Szymon', 'Mazurek', 'jane.doe@example.com', 0, 1, '2024-12-29 15:03:47.941278'),
(3, 'pbkdf2_sha256$870000$tv02wXGSRehir0BWA3Z6RF$+AbO6s+t+SELqE2YqNcIab/x7ZHu7kpKbrAvCyUbFGg=', '2025-01-05 15:54:00.814250', 0, 'Jakub_sado', 'Jakub', 'Sado', 'support@services.com', 0, 1, '2024-12-29 15:04:33.832119'),
(4, 'pbkdf2_sha256$870000$9rsoSgwruSgN0uia8y6WMh$p32onbC2dzWcjDLRcLkpEqyfLvSTGFuTLOCXSkqAwRM=', '2025-01-04 22:21:42.715263', 0, 'Michał_radziuk', 'Michał', 'Radziuk', 'sales@onlineshop.co', 0, 1, '2024-12-29 15:05:11.385414'),
(5, 'pbkdf2_sha256$870000$smPHLkJ6tJSuPgyeGCxtVX$YgRubT6jNNJ8NV5LpLwigkkhI8iaRYqfVhYJwmImnbc=', '2025-01-05 15:50:55.258626', 0, 'Wieslaw_wychura', 'Wiesław', 'Wychura', 'support@services.com', 0, 1, '2024-12-29 15:06:17.564034'),
(6, 'pbkdf2_sha256$870000$YFst3bVQivaDtICQWIyQEf$DDiB/zd6JkQJAlEgpjMsf866lu3AfKRXCbUDqf5pvw0=', '2024-12-29 19:54:05.495251', 0, 'Adam_Dorota', 'Adam', 'Dorota', 'sales@onlineshop.com', 0, 1, '2024-12-29 15:06:56.741601'),
(7, 'pbkdf2_sha256$870000$iQzialeWUZrmFBemyatJk7$VefwhmIFQpGInRMjZvaKfk10qhGbsq4SiMCamYxQ5mk=', '2025-01-05 16:09:25.407199', 0, 'Mariusz_Pudzianowski', 'Mariusz', 'Pudzianowski', 'admin@platform.biz', 0, 1, '2024-12-29 19:48:37.167931'),
(8, 'pbkdf2_sha256$870000$Jkl9DfN5pjTOQHWxP8CPaL$dtIIexj3z2dNhRmQ0jogLcQ7h4IKHkX2OgumYPhStds=', '2025-01-05 14:53:16.049423', 0, 'Zbigniew_Orzeł', 'Zbigniew', 'Orzeł', 'support@services.com', 0, 1, '2024-12-29 19:49:34.697030'),
(16, 'pbkdf2_sha256$870000$zlZR0T2dYWxIFmON7JYTae$tgYSEc6wwC4Sq9bulpevBspM8XvM0DIX4g14ARkwR1U=', '2025-01-05 16:11:27.265721', 0, 'Katarzyna_Zielińska', '', '', 'katarzyna.zielinska@company.com', 0, 1, '2025-01-05 13:15:05.357703'),
(17, 'pbkdf2_sha256$870000$pJSmZRjnB9VhvYfdJN1UMm$Le+SeloIdYFsQTCYDZ0/g1fBR62EMIFYmERcp/u5b/k=', NULL, 0, 'Jan_Nowak', '', '', 'jan.nowak@company.com', 0, 1, '2025-01-05 13:15:51.871709'),
(18, 'pbkdf2_sha256$870000$U2Q6CsbbkElGUmgwGvL4Lw$HDoGJC5uZ977HwnkWW4JsK2eFpAMX+ESRO84LYjFUAg=', NULL, 0, 'Michal_Wojciechowski', '', '', 'michal.wojciechowski@company.com', 0, 1, '2025-01-05 13:17:43.737871'),
(19, 'pbkdf2_sha256$870000$llVFm8wEZnJsCefmT55qD9$oi+OhzA4E18I5O+21wqD8GiL5s079htqrfQwEOSA+QM=', NULL, 0, 'AutoBot', '', '', '', 0, 1, '2025-01-11 16:02:02.742228');

-- --------------------------------------------------------

--
-- Table structure for table `authentication_user_groups`
--

CREATE TABLE `authentication_user_groups` (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `group_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `authentication_user_groups`
--

INSERT INTO `authentication_user_groups` (`id`, `user_id`, `group_id`) VALUES
(1, 2, 3),
(2, 3, 3),
(3, 4, 3),
(4, 5, 1),
(5, 6, 2),
(6, 7, 2),
(7, 8, 1),
(8, 16, 3),
(9, 17, 3),
(10, 18, 3);

-- --------------------------------------------------------

--
-- Table structure for table `authentication_user_user_permissions`
--

CREATE TABLE `authentication_user_user_permissions` (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `permission_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auth_group`
--

INSERT INTO `auth_group` (`id`, `name`) VALUES
(1, 'customer'),
(3, 'engineer'),
(2, 'manager');

-- --------------------------------------------------------

--
-- Table structure for table `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auth_group_permissions`
--

INSERT INTO `auth_group_permissions` (`id`, `group_id`, `permission_id`) VALUES
(29, 1, 24),
(30, 1, 28),
(24, 1, 32),
(25, 1, 33),
(26, 1, 34),
(28, 1, 36),
(42, 2, 26),
(43, 2, 28),
(1, 2, 29),
(2, 2, 30),
(44, 2, 31),
(37, 2, 32),
(38, 2, 33),
(39, 2, 34),
(40, 2, 35),
(41, 2, 36),
(35, 3, 24),
(36, 3, 28),
(3, 3, 30),
(31, 3, 32),
(32, 3, 33),
(33, 3, 34),
(34, 3, 36);

-- --------------------------------------------------------

--
-- Table structure for table `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add log entry', 1, 'add_logentry'),
(2, 'Can change log entry', 1, 'change_logentry'),
(3, 'Can delete log entry', 1, 'delete_logentry'),
(4, 'Can view log entry', 1, 'view_logentry'),
(5, 'Can add permission', 3, 'add_permission'),
(6, 'Can change permission', 3, 'change_permission'),
(7, 'Can delete permission', 3, 'delete_permission'),
(8, 'Can view permission', 3, 'view_permission'),
(9, 'Can add group', 4, 'add_group'),
(10, 'Can change group', 4, 'change_group'),
(11, 'Can delete group', 4, 'delete_group'),
(12, 'Can view group', 4, 'view_group'),
(13, 'Can add content type', 5, 'add_contenttype'),
(14, 'Can change content type', 5, 'change_contenttype'),
(15, 'Can delete content type', 5, 'delete_contenttype'),
(16, 'Can view content type', 5, 'view_contenttype'),
(17, 'Can add session', 6, 'add_session'),
(18, 'Can change session', 6, 'change_session'),
(19, 'Can delete session', 6, 'delete_session'),
(20, 'Can view session', 6, 'view_session'),
(21, 'Can add user', 7, 'add_user'),
(22, 'Can change user', 7, 'change_user'),
(23, 'Can delete user', 7, 'delete_user'),
(24, 'Can view user', 7, 'view_user'),
(25, 'Can add project', 8, 'add_project'),
(26, 'Can change project', 8, 'change_project'),
(27, 'Can delete project', 8, 'delete_project'),
(28, 'Can view project', 8, 'view_project'),
(29, 'Can add task', 2, 'add_task'),
(30, 'Can change task', 2, 'change_task'),
(31, 'Can delete task', 2, 'delete_task'),
(32, 'Can view task', 2, 'view_task'),
(33, 'Can add comment', 9, 'add_comment'),
(34, 'Can change comment', 9, 'change_comment'),
(35, 'Can delete comment', 9, 'delete_comment'),
(36, 'Can view comment', 9, 'view_comment'),
(37, 'Can add incident', 10, 'add_incident'),
(38, 'Can change incident', 10, 'change_incident'),
(39, 'Can delete incident', 10, 'delete_incident'),
(40, 'Can view incident', 10, 'view_incident');

-- --------------------------------------------------------

--
-- Table structure for table `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext COLLATE utf8mb4_general_ci,
  `object_repr` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `action_flag` smallint UNSIGNED NOT NULL,
  `change_message` longtext COLLATE utf8mb4_general_ci NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` bigint NOT NULL
) ;

--
-- Dumping data for table `django_admin_log`
--

INSERT INTO `django_admin_log` (`id`, `action_time`, `object_id`, `object_repr`, `action_flag`, `change_message`, `content_type_id`, `user_id`) VALUES
(1, '2024-12-29 14:35:03.888994', '4', 'Customer2', 1, '[{\"added\": {}}]', 4, 1),
(2, '2024-12-29 14:35:18.296877', '4', 'Customer2', 3, '', 4, 1),
(3, '2024-12-29 14:35:26.039869', '1', 'customer', 2, '[]', 4, 1),
(4, '2024-12-29 14:50:39.834744', '1', 'customer', 2, '[{\"changed\": {\"fields\": [\"Permissions\"]}}]', 4, 1),
(5, '2024-12-29 14:52:09.859388', '3', 'engineer', 2, '[{\"changed\": {\"fields\": [\"Permissions\"]}}]', 4, 1),
(6, '2024-12-29 14:52:24.687428', '1', 'customer', 2, '[{\"changed\": {\"fields\": [\"Permissions\"]}}]', 4, 1),
(7, '2024-12-29 14:52:28.189267', '3', 'engineer', 2, '[]', 4, 1),
(8, '2024-12-29 15:01:35.095258', '2', 'manager', 2, '[{\"changed\": {\"fields\": [\"Permissions\"]}}]', 4, 1),
(9, '2024-12-29 15:03:48.265894', '2', 'Szymon_Mazurek', 1, '[{\"added\": {}}]', 7, 1),
(10, '2024-12-29 15:04:04.875613', '2', 'Szymon_Mazurek', 2, '[]', 7, 1),
(11, '2024-12-29 15:04:34.160515', '3', 'Jakub_sado', 1, '[{\"added\": {}}]', 7, 1),
(12, '2024-12-29 15:05:11.719493', '4', 'Michał_radziuk', 1, '[{\"added\": {}}]', 7, 1),
(13, '2024-12-29 15:06:17.901490', '5', 'Wieslaw_wychura', 1, '[{\"added\": {}}]', 7, 1),
(14, '2024-12-29 15:06:57.086757', '6', 'Adam_Dorota', 1, '[{\"added\": {}}]', 7, 1),
(15, '2024-12-29 15:55:55.176023', '1', 'Aplikacja Helpdesk', 1, '[{\"added\": {}}]', 8, 1),
(16, '2024-12-29 18:37:45.628781', '1', 'Wydanie laptopa', 1, '[{\"added\": {}}]', 2, 1),
(17, '2024-12-29 18:38:36.938696', '2', 'Instalacja windows', 1, '[{\"added\": {}}]', 2, 1),
(18, '2024-12-29 18:39:30.816398', '3', 'Wymiana dysków', 1, '[{\"added\": {}}]', 2, 1),
(19, '2024-12-29 18:40:07.449767', '4', 'Migracja danych', 1, '[{\"added\": {}}]', 2, 1),
(20, '2024-12-29 19:48:37.512028', '7', 'Mariusz_Pudzianowski', 1, '[{\"added\": {}}]', 7, 1),
(21, '2024-12-29 19:48:41.010405', '7', 'Mariusz_Pudzianowski', 2, '[]', 7, 1),
(22, '2024-12-29 19:49:35.031064', '8', 'Zbigniew_Orzeł', 1, '[{\"added\": {}}]', 7, 1),
(23, '2024-12-29 19:51:50.251411', '2', 'Serwerownia', 1, '[{\"added\": {}}]', 8, 1),
(24, '2024-12-29 19:52:28.299369', '5', 'Migracja danych', 1, '[{\"added\": {}}]', 2, 1),
(25, '2025-01-02 20:22:39.852226', '6', 'Konfiguracja windows', 1, '[{\"added\": {}}]', 2, 1),
(26, '2025-01-03 22:42:09.239888', '13', 'fghgfhfgh', 1, '[{\"added\": {}}]', 2, 1),
(27, '2025-01-03 22:42:18.979652', '13', 'fghgfhfgh', 3, '', 2, 1),
(28, '2025-01-03 22:43:07.794860', '14', 'retertetert', 1, '[{\"added\": {}}]', 2, 1),
(29, '2025-01-03 22:43:16.102161', '14', 'retertetert', 3, '', 2, 1),
(30, '2025-01-04 10:59:33.772809', '20', 'tyyryrty', 1, '[{\"added\": {}}]', 2, 1),
(31, '2025-01-04 11:24:17.872475', '21', 'fdgdggfdgfd', 1, '[{\"added\": {}}]', 2, 1),
(32, '2025-01-04 11:24:30.383684', '21', 'fdgdggfdgfd', 3, '', 2, 1),
(33, '2025-01-04 11:29:36.579586', '22', 'jhgjhjhgjgh', 1, '[{\"added\": {}}]', 2, 1),
(34, '2025-01-04 12:48:58.975661', '1', 'IT Helpdesk', 2, '[{\"changed\": {\"fields\": [\"Name\", \"Description\"]}}]', 8, 1),
(35, '2025-01-04 12:49:54.281421', '2', 'Server Management', 2, '[{\"changed\": {\"fields\": [\"Name\", \"Description\"]}}]', 8, 1),
(36, '2025-01-04 12:50:30.737515', '2', 'Server Management', 2, '[{\"changed\": {\"fields\": [\"Description\"]}}]', 8, 1),
(37, '2025-01-04 12:51:22.341409', '1', 'IT Helpdesk', 2, '[{\"changed\": {\"fields\": [\"Description\"]}}]', 8, 1),
(38, '2025-01-05 12:16:48.130662', '6', 'Dział administracyjny', 1, '[{\"added\": {}}]', 8, 1),
(39, '2025-01-05 13:15:05.809274', '16', 'Katarzyna_Zielińska', 1, '[{\"added\": {}}]', 7, 1),
(40, '2025-01-05 13:15:52.336774', '17', 'Jan_Nowak', 1, '[{\"added\": {}}]', 7, 1),
(41, '2025-01-05 13:17:44.194523', '18', 'Michal_Wojciechowski', 1, '[{\"added\": {}}]', 7, 1),
(42, '2025-01-05 14:38:15.487641', '3', 'Customer Feedback Portal', 2, '[{\"changed\": {\"fields\": [\"owner\", \"customer\"]}}]', 8, 1),
(43, '2025-01-05 14:38:19.255589', '1', 'IT Helpdesk', 2, '[]', 8, 1),
(44, '2025-01-05 14:38:22.945264', '2', 'Server Management', 2, '[]', 8, 1),
(45, '2025-01-05 14:38:34.076352', '4', 'Cloud Migration', 2, '[{\"changed\": {\"fields\": [\"owner\", \"customer\"]}}]', 8, 1),
(46, '2025-01-05 14:38:40.866842', '5', 'Inventory Management System', 2, '[{\"changed\": {\"fields\": [\"owner\"]}}]', 8, 1),
(47, '2025-01-05 14:38:44.462322', '6', 'Dział administracyjny', 2, '[]', 8, 1),
(48, '2025-01-11 16:02:03.030133', '19', 'AutoBot', 1, '[{\"added\": {}}]', 7, 1);

-- --------------------------------------------------------

--
-- Table structure for table `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int NOT NULL,
  `app_label` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `model` varchar(100) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(1, 'admin', 'logentry'),
(4, 'auth', 'group'),
(3, 'auth', 'permission'),
(9, 'authentication', 'comment'),
(10, 'authentication', 'incident'),
(8, 'authentication', 'project'),
(2, 'authentication', 'task'),
(7, 'authentication', 'user'),
(5, 'contenttypes', 'contenttype'),
(6, 'sessions', 'session');

-- --------------------------------------------------------

--
-- Table structure for table `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL,
  `app` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2024-12-29 13:26:44.128878'),
(2, 'contenttypes', '0002_remove_content_type_name', '2024-12-29 13:26:44.165321'),
(3, 'auth', '0001_initial', '2024-12-29 13:26:44.265119'),
(4, 'auth', '0002_alter_permission_name_max_length', '2024-12-29 13:26:44.289276'),
(5, 'auth', '0003_alter_user_email_max_length', '2024-12-29 13:26:44.293702'),
(6, 'auth', '0004_alter_user_username_opts', '2024-12-29 13:26:44.297678'),
(7, 'auth', '0005_alter_user_last_login_null', '2024-12-29 13:26:44.302580'),
(8, 'auth', '0006_require_contenttypes_0002', '2024-12-29 13:26:44.305113'),
(9, 'auth', '0007_alter_validators_add_error_messages', '2024-12-29 13:26:44.308685'),
(10, 'auth', '0008_alter_user_username_max_length', '2024-12-29 13:26:44.313602'),
(11, 'auth', '0009_alter_user_last_name_max_length', '2024-12-29 13:26:44.317670'),
(12, 'auth', '0010_alter_group_name_max_length', '2024-12-29 13:26:44.332735'),
(13, 'auth', '0011_update_proxy_permissions', '2024-12-29 13:26:44.337662'),
(14, 'auth', '0012_alter_user_first_name_max_length', '2024-12-29 13:26:44.341534'),
(15, 'authentication', '0001_initial', '2024-12-29 13:26:44.680414'),
(16, 'admin', '0001_initial', '2024-12-29 13:26:44.763289'),
(17, 'admin', '0002_logentry_remove_auto_add', '2024-12-29 13:26:44.768938'),
(18, 'admin', '0003_logentry_add_action_flag_choices', '2024-12-29 13:26:44.774761'),
(19, 'sessions', '0001_initial', '2024-12-29 13:26:44.800916'),
(20, 'authentication', '0002_project_customer_alter_project_owner', '2024-12-29 15:19:32.836391'),
(21, 'authentication', '0003_alter_project_customer', '2024-12-29 15:55:27.689077'),
(22, 'authentication', '0004_remove_task_due_date', '2024-12-29 16:18:47.694047'),
(23, 'authentication', '0005_alter_task_work_time', '2024-12-29 18:29:31.097975'),
(24, 'authentication', '0006_remove_task_work_time', '2024-12-29 18:37:04.616882'),
(25, 'authentication', '0007_task_time_spent', '2025-01-02 19:20:28.097973'),
(26, 'authentication', '0008_alter_task_sla_deadline', '2025-01-04 11:28:32.025210'),
(27, 'authentication', '0009_incident', '2025-01-04 17:13:37.279316');

-- --------------------------------------------------------

--
-- Table structure for table `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) COLLATE utf8mb4_general_ci NOT NULL,
  `session_data` longtext COLLATE utf8mb4_general_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_session`
--

INSERT INTO `django_session` (`session_key`, `session_data`, `expire_date`) VALUES
('0jjupiyeu33hrtjn0dfheu4ltyz5ms4q', '.eJxVjEEOwiAQRe_C2hAow1BcuvcMZIahtmpoUtqV8e7apAvd_vfef6lE2zqmrZUlTaLOqlOn340pP0rdgdyp3mad57ouE-td0Qdt-jpLeV4O9-9gpDZ-62B6KijiTYluAGtZ0AGxkw4MS5_FUCDEyGD8gGB6AAzZAduIvjj1_gDjxzdq:1tUS4T:zqzp2is9c4P8yh6wRy-NlhZJ1THZOwn-u-TYk5nHumo', '2025-01-19 14:57:41.554043'),
('5dkx5hzg25k6w65lme5gw6j3299w27c3', '.eJxVjMsOwiAQRf-FtSFQHgMu3fsNBGamUjU0Ke3K-O_apAvd3nPOfYmUt7WmrfOSJhJnocXpdysZH9x2QPfcbrPEua3LVOSuyIN2eZ2Jn5fD_TuouddvjTkyKGXAalNMRPbgx8GxBh08OXDkQzBeFRVHRrbRBLJeMQ5AjiCL9wfG2jdc:1tUSsu:HAg48-u08ymZCXiyOLjhZY7E_aY5VGbY-9iSEV3c3zs', '2025-01-19 15:49:48.900930'),
('a6wyzxnkhzcwykfwzizvibg7e9cq1dlf', '.eJxVjMsOwiAQRf-FtSFQHgMu3fsNBGamUjU0Ke3K-O_apAvd3nPOfYmUt7WmrfOSJhJnocXpdysZH9x2QPfcbrPEua3LVOSuyIN2eZ2Jn5fD_TuouddvjTkyKGXAalNMRPbgx8GxBh08OXDkQzBeFRVHRrbRBLJeMQ5AjiCL9wfG2jdc:1tUTIO:TKsCuoG-dQorJes-SNGkeQiABK1UCYbu-mTVmsfleSA', '2025-01-19 16:16:08.474683'),
('d5za19d6y356cpnfvdyasrdnt6xn0oqc', '.eJxVjMsOwiAQRf-FtSFQHgMu3fsNBGamUjU0Ke3K-O_apAvd3nPOfYmUt7WmrfOSJhJnocXpdysZH9x2QPfcbrPEua3LVOSuyIN2eZ2Jn5fD_TuouddvjTkyKGXAalNMRPbgx8GxBh08OXDkQzBeFRVHRrbRBLJeMQ5AjiCL9wfG2jdc:1tU4GZ:yiNNhRLpM60E6Xg7UwMnUJ8tnrY-xvlooO87K1YiEfQ', '2025-01-18 13:32:35.562751'),
('ebzatsnabxp3yl07rnz5ncq1vx9axnn5', '.eJxVjMsOwiAQRf-FtSFQHgMu3fsNBGamUjU0Ke3K-O_apAvd3nPOfYmUt7WmrfOSJhJnocXpdysZH9x2QPfcbrPEua3LVOSuyIN2eZ2Jn5fD_TuouddvjTkyKGXAalNMRPbgx8GxBh08OXDkQzBeFRVHRrbRBLJeMQ5AjiCL9wfG2jdc:1tWdl7:cVTWF6uh2O2e37J_ygaeOq-_qURHgo2g30N8A2KZNKs', '2025-01-25 15:50:45.781570'),
('fbyvi3rae6bkq42ua6cgq1s2z5hmub5j', '.eJxVjEEOwiAQRe_C2hAHCh1cuvcMZIBBqoYmpV0Z7y5NutDtf-_9t_C0rcVvjRc_JXERWpx-t0DxyXUH6UH1Pss413WZgtwVedAmb3Pi1_Vw_w4KtdJr55ABswVjQTmKgdgNGhMrVAky2HFEl89gNUUTAV2X9WDRqNi5ZvH5AsjfNwA:1tUSwy:z_wdBAnFsz8FAfyImebAGI-lXTkfPgM_7FGIBuJu1lA', '2025-01-19 15:54:00.841738'),
('w3junzzpzz3lvdzup8yia076pro1ubbp', '.eJxVjMsOwiAQRf-FtSFQHgMu3fsNBGamUjU0Ke3K-O_apAvd3nPOfYmUt7WmrfOSJhJnocXpdysZH9x2QPfcbrPEua3LVOSuyIN2eZ2Jn5fD_TuouddvjTkyKGXAalNMRPbgx8GxBh08OXDkQzBeFRVHRrbRBLJeMQ5AjiCL9wfG2jdc:1tURvJ:YXkXsYJ0BbkXUZ2hj3PvnhZFqRyfgy9Z76oqzTIKmN4', '2025-01-19 14:48:13.049224'),
('y7vlrsxrb6t7jw6u42d3tbcav6bftlrw', '.eJxVjMsOwiAQRf-FtSFQHgMu3fsNBGamUjU0Ke3K-O_apAvd3nPOfYmUt7WmrfOSJhJnocXpdysZH9x2QPfcbrPEua3LVOSuyIN2eZ2Jn5fD_TuouddvjTkyKGXAalNMRPbgx8GxBh08OXDkQzBeFRVHRrbRBLJeMQ5AjiCL9wfG2jdc:1tTku8:MMpWYb_YBa5Z4aND65OYM62zlFMPflDthlLcoNtBrDY', '2025-01-17 16:52:08.545920');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `authentication_comment`
--
ALTER TABLE `authentication_comment`
  ADD PRIMARY KEY (`id`),
  ADD KEY `authentication_comme_author_id_7e76ef7a_fk_authentic` (`author_id`),
  ADD KEY `authentication_comme_task_id_d81f297d_fk_authentic` (`task_id`);

--
-- Indexes for table `authentication_incident`
--
ALTER TABLE `authentication_incident`
  ADD PRIMARY KEY (`id`),
  ADD KEY `authentication_incid_created_by_id_ce849bdf_fk_authentic` (`created_by_id`),
  ADD KEY `authentication_incid_project_id_ed5b3a00_fk_authentic` (`project_id`);

--
-- Indexes for table `authentication_project`
--
ALTER TABLE `authentication_project`
  ADD PRIMARY KEY (`id`),
  ADD KEY `authentication_proje_owner_id_77480ad4_fk_authentic` (`owner_id`),
  ADD KEY `authentication_project_customer_id_32e86774` (`customer_id`);

--
-- Indexes for table `authentication_task`
--
ALTER TABLE `authentication_task`
  ADD PRIMARY KEY (`id`),
  ADD KEY `authentication_task_assigned_user_id_876ce4c1_fk_authentic` (`assigned_user_id`),
  ADD KEY `authentication_task_parent_task_id_4d998a7f_fk_authentic` (`parent_task_id`),
  ADD KEY `authentication_task_project_id_74954277_fk_authentic` (`project_id`);

--
-- Indexes for table `authentication_user`
--
ALTER TABLE `authentication_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `authentication_user_groups`
--
ALTER TABLE `authentication_user_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `authentication_user_groups_user_id_group_id_8af031ac_uniq` (`user_id`,`group_id`),
  ADD KEY `authentication_user_groups_group_id_6b5c44b7_fk_auth_group_id` (`group_id`);

--
-- Indexes for table `authentication_user_user_permissions`
--
ALTER TABLE `authentication_user_user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `authentication_user_user_user_id_permission_id_ec51b09f_uniq` (`user_id`,`permission_id`),
  ADD KEY `authentication_user__permission_id_ea6be19a_fk_auth_perm` (`permission_id`);

--
-- Indexes for table `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indexes for table `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indexes for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  ADD KEY `django_admin_log_user_id_c564eba6_fk_authentication_user_id` (`user_id`);

--
-- Indexes for table `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indexes for table `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `authentication_comment`
--
ALTER TABLE `authentication_comment`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=301;

--
-- AUTO_INCREMENT for table `authentication_incident`
--
ALTER TABLE `authentication_incident`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `authentication_project`
--
ALTER TABLE `authentication_project`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `authentication_task`
--
ALTER TABLE `authentication_task`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT for table `authentication_user`
--
ALTER TABLE `authentication_user`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `authentication_user_groups`
--
ALTER TABLE `authentication_user_groups`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `authentication_user_user_permissions`
--
ALTER TABLE `authentication_user_user_permissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=480;

--
-- AUTO_INCREMENT for table `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `authentication_comment`
--
ALTER TABLE `authentication_comment`
  ADD CONSTRAINT `authentication_comme_author_id_7e76ef7a_fk_authentic` FOREIGN KEY (`author_id`) REFERENCES `authentication_user` (`id`),
  ADD CONSTRAINT `authentication_comme_task_id_d81f297d_fk_authentic` FOREIGN KEY (`task_id`) REFERENCES `authentication_task` (`id`);

--
-- Constraints for table `authentication_incident`
--
ALTER TABLE `authentication_incident`
  ADD CONSTRAINT `authentication_incid_created_by_id_ce849bdf_fk_authentic` FOREIGN KEY (`created_by_id`) REFERENCES `authentication_user` (`id`),
  ADD CONSTRAINT `authentication_incid_project_id_ed5b3a00_fk_authentic` FOREIGN KEY (`project_id`) REFERENCES `authentication_project` (`id`);

--
-- Constraints for table `authentication_project`
--
ALTER TABLE `authentication_project`
  ADD CONSTRAINT `authentication_proje_customer_id_32e86774_fk_authentic` FOREIGN KEY (`customer_id`) REFERENCES `authentication_user` (`id`),
  ADD CONSTRAINT `authentication_proje_owner_id_77480ad4_fk_authentic` FOREIGN KEY (`owner_id`) REFERENCES `authentication_user` (`id`);

--
-- Constraints for table `authentication_task`
--
ALTER TABLE `authentication_task`
  ADD CONSTRAINT `authentication_task_assigned_user_id_876ce4c1_fk_authentic` FOREIGN KEY (`assigned_user_id`) REFERENCES `authentication_user` (`id`),
  ADD CONSTRAINT `authentication_task_parent_task_id_4d998a7f_fk_authentic` FOREIGN KEY (`parent_task_id`) REFERENCES `authentication_task` (`id`),
  ADD CONSTRAINT `authentication_task_project_id_74954277_fk_authentic` FOREIGN KEY (`project_id`) REFERENCES `authentication_project` (`id`);

--
-- Constraints for table `authentication_user_groups`
--
ALTER TABLE `authentication_user_groups`
  ADD CONSTRAINT `authentication_user__user_id_30868577_fk_authentic` FOREIGN KEY (`user_id`) REFERENCES `authentication_user` (`id`),
  ADD CONSTRAINT `authentication_user_groups_group_id_6b5c44b7_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Constraints for table `authentication_user_user_permissions`
--
ALTER TABLE `authentication_user_user_permissions`
  ADD CONSTRAINT `authentication_user__permission_id_ea6be19a_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `authentication_user__user_id_736ebf7e_fk_authentic` FOREIGN KEY (`user_id`) REFERENCES `authentication_user` (`id`);

--
-- Constraints for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Constraints for table `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Constraints for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  ADD CONSTRAINT `django_admin_log_user_id_c564eba6_fk_authentication_user_id` FOREIGN KEY (`user_id`) REFERENCES `authentication_user` (`id`);

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`%` EVENT `event_check_sla` ON SCHEDULE EVERY 1 MINUTE STARTS '2025-01-11 16:12:50' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    #CALL check_sla_deadline();
    CALL check_sla_overdue();
    CALL assign_technician();
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
