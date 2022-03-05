-- 1. What range of years for baseball games played does the provided database cover?
-- ANSWER: 
	-- Range of years: 1871-2016
-- SCRIPT
	-- SELECT MIN(year),
	-- 	MAX(year)
	-- 	FROM homegames;

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- ANSWER: 
	-- 	Name: Eddie Gaedel/Edward Carl (ID: gaedeed01)
	-- 	Height: 43"
	-- 	Number games: 1
	-- 	Team name: St. Louis Browns (ID: SLA)
-- SCRIPT 1
	-- SELECT *
	-- FROM people
	-- ORDER BY height;
-- SCRIPT 2
	-- SELECT *
	-- FROM appearances
	-- WHERE playerID = 'gaedeed01';
-- SCRIPT 3
	-- SELECT name
	-- FROM teams
	-- WHERE teamid = 'SLA';

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- ANSWER:
	-- Top earning Vanderbilt player: David Price (total salary: $245,553,888)
-- SCRIPT 1 (schoolid = vandy)
	-- SELECT *
	-- FROM schools
	-- ORDER BY schoolname DESC;
-- SCRIPT 2
	-- SELECT 
	-- 	p.namefirst,
	-- 	p.namelast,
	-- 	SUM(salary) AS total_salary
	-- FROM collegeplaying AS cp
	-- LEFT JOIN people AS p
	-- ON cp.playerid = p.playerid
	-- LEFT JOIN salaries AS s
	-- ON p.playerid = s.playerid
	-- WHERE schoolid = 'vandy'
	-- 	AND salary IS NOT NULL
	-- GROUP BY 
	-- 	p.namefirst,
	-- 	p.namelast
	-- ORDER BY 
	-- 	SUM(salary) DESC;

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
-- ANSWER:
	-- 2016 Outfield putouts: 29,560
	-- 2016 Infield putouts: 58,934
	-- 2016 Battery putouts: 41,424
-- SCRIPT
	-- SELECT
	-- 	SUM(po) AS total_putouts,
	-- 	CASE
	-- 		WHEN pos = 'OF' THEN 'Outfield'
	-- 		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	-- 		WHEN pos IN ('P', 'C') THEN 'Battery'
	-- 	END AS position
	-- FROM fielding
	-- WHERE yearid = '2016'
	-- GROUP BY position;

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- ANSWER:
	-- There was a general trend that both homeruns and strikeouts increased with time.
-- SCRIPT
	-- SELECT ROUND(AVG(hr), 2) AS avg_homeruns,
	-- 	ROUND(AVG(so), 2) AS avg_strikeouts,
	-- 	CONCAT(LEFT(CAST(yearid AS text), 3), '0s') AS decade
	-- FROM batting
	-- WHERE yearid >= '1920'
	-- GROUP BY CONCAT(LEFT(CAST(yearid AS text), 3), '0s')
	-- ORDER BY decade;

-- 6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.