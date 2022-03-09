-- 1. What range of years for baseball games played does the provided database cover?
-- ANSWER: 
	-- Range of years: 1871-2016
-- SCRIPT
	SELECT MIN(year),
		MAX(year)
		FROM homegames;

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- ANSWER: 
	-- 	Name: Eddie Gaedel/Edward Carl (ID: gaedeed01)
	-- 	Height: 43"
	-- 	Number games: 1
	-- 	Team name: St. Louis Browns (ID: SLA)
-- SCRIPT 1
	SELECT *
	FROM people
	ORDER BY height;
-- SCRIPT 2
	SELECT *
	FROM appearances
	WHERE playerID = 'gaedeed01';
-- SCRIPT 3
	SELECT name
	FROM teams
	WHERE teamid = 'SLA';

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- ANSWER:
	-- Top earning Vanderbilt player: David Price (total salary: $245,553,888)
-- SCRIPT 1 (schoolid = vandy)
	SELECT *
	FROM schools
	ORDER BY schoolname DESC;
-- SCRIPT 2
	SELECT 
		p.namefirst,
		p.namelast,
		SUM(salary) AS total_salary
	FROM collegeplaying AS cp
	LEFT JOIN people AS p
	ON cp.playerid = p.playerid
	LEFT JOIN salaries AS s
	ON p.playerid = s.playerid
	WHERE schoolid = 'vandy'
		AND salary IS NOT NULL
	GROUP BY 
		p.namefirst,
		p.namelast
	ORDER BY 
		SUM(salary) DESC;

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
-- ANSWER:
	-- 2016 Outfield putouts: 29,560
	-- 2016 Infield putouts: 58,934
	-- 2016 Battery putouts: 41,424
-- SCRIPT
	SELECT
		SUM(po) AS total_putouts,
		CASE
			WHEN pos = 'OF' THEN 'Outfield'
			WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			WHEN pos IN ('P', 'C') THEN 'Battery'
		END AS position
	FROM fielding
	WHERE yearid = '2016'
	GROUP BY position;

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- ANSWER:
	-- There was a general trend that both homeruns and strikeouts increased with time, but there was more variability in homeruns.
-- SCRIPT
SELECT ROUND(AVG(hr), 2) AS avg_homeruns,
	ROUND(AVG(so), 2) AS avg_strikeouts,
	CONCAT(LEFT(CAST(yearid AS text), 3), '0s') AS decade
FROM teams
WHERE yearid >= '1920'
GROUP BY CONCAT(LEFT(CAST(yearid AS text), 3), '0s')
ORDER BY decade;

-- 6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
--ANSWER:
	-- Player with most success stealing in 2016: Chris Owings
-- SCRIPT
	SELECT batting.playerid,
		namefirst,
		namelast,
		SUM(sb) AS successful_sb,
		SUM(sb + cs) AS total_attempts,
		SUM(sb)/CAST(SUM(sb +cs) AS decimal(10,2))*100 AS successful_attempts
	FROM batting
	LEFT JOIN people
	ON batting.playerid = people.playerid
	WHERE batting.yearid = '2016'
	GROUP BY batting.playerid,
		namefirst,
		namelast
	HAVING SUM(sb + cs) >= 20
	ORDER BY successful_attempts DESC;

-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
-- ANSWER:
	-- LARGEST number of wins for team that DID NOT win World Series: 116/Seattle Mariners
	-- SMALLEST number of wins for team that DID win World Series: 83/St. Louis Cardinals (There was a players' strike in 1981, which is why the LA dodgers only won 63 games that season and went on to win the series)
	-- Number of times team with most wins won World Series: 12 times
	-- Percent of times team with most wins won World Series: 23.08%
-- SCRIPT 1
	SELECT yearid,
		name, 
		MAX(w)
	FROM teams
	WHERE wswin = 'N'
		AND yearid BETWEEN 1970 AND 2016
	GROUP BY yearid,
		name
	ORDER BY MAX(w) DESC;
-- SCRIPT 2
	SELECT yearid,
		name, 
		MIN(w)
	FROM teams
	WHERE wswin = 'Y'
		AND yearid BETWEEN 1970 AND 2016
		AND yearid <> 1981
	GROUP BY yearid,
		name
	ORDER BY MIN(w);
-- SCRIPT 3: https://stackoverflow.com/questions/7745609/sql-select-only-rows-with-max-value-on-a-column
	WITH cte AS
	(SELECT a.yearid,
		a.name,
		a.w,
		a.wswin
	FROM teams AS a
	INNER JOIN (
		SELECT yearid,
				MAX(w) AS w
		FROM teams
		GROUP BY yearid
		ORDER BY yearid) AS b
	ON a.yearid = b.yearid AND a.w = b.w
	WHERE a.yearid BETWEEN 1970 AND 2016)
	SELECT SUM(CASE WHEN wswin = 'Y' THEN 1
			   WHEN wswin = 'N' THEN 0 END) AS total
		FROM cte;
--SCRIPT 4
	WITH cte AS
	(SELECT a.yearid,
		a.name,
		a.w,
		a.wswin
	FROM teams AS a
	INNER JOIN (
		SELECT yearid,
				MAX(w) AS w
		FROM teams
		GROUP BY yearid
		ORDER BY yearid) AS b
	ON a.yearid = b.yearid AND a.w = b.w
	WHERE a.yearid BETWEEN 1970 AND 2016)
	SELECT ROUND(AVG(CASE WHEN wswin = 'Y' THEN 1
			   WHEN wswin = 'N' THEN 0 END)*100, 2) AS avg
		FROM cte;	

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
-- TOP AVERAGE ATTENDANCE:
	/*"Dodger Stadium"	"Los Angeles Dodgers"	45719
	"Busch Stadium III"	"St. Louis Cardinals"	42524
	"Rogers Centre"	"Toronto Blue Jays"	41877
	"AT&T Park"	"San Francisco Giants"	41546
	"Wrigley Field"	"Chicago Cubs"	39906*/
-- BOTTOM AVERAGE ATTENDANCE:
	/*"Tropicana Field"	"Tampa Bay Rays"	15878
	"Oakland-Alameda County Coliseum"	"Oakland Athletics"	18784
	"Progressive Field"	"Cleveland Indians"	19650
	"Marlins Park"	"Miami Marlins"	21405
	"U.S. Cellular Field"	"Chicago White Sox"	21559*/
-- SCRIPT 1	
	SELECT 
		p.park_name,
		t.name,
		(h.attendance / h.games) AS avg_attendance
	FROM homegames AS h
	INNER JOIN parks AS p
	ON h.park = p.park
	INNER JOIN teams AS t
	ON h.team = t.teamid
	WHERE h.year = '2016' 
		AND t.yearid = '2016'
		AND h.games >= 10
	GROUP BY
		p.park_name,
		t.name,
		h.attendance,
		h.games
	ORDER BY avg_attendance DESC;
-- SCRIPT 2
	SELECT 
		p.park_name,
		t.name,
		(h.attendance / h.games) AS avg_attendance
	FROM homegames AS h
	INNER JOIN parks AS p
	ON h.park = p.park
	INNER JOIN teams AS t
	ON h.team = t.teamid
	WHERE h.year = '2016' 
		AND t.yearid = '2016'
		AND h.games >= 10
	GROUP BY
		p.park_name,
		t.name,
		h.attendance,
		h.games
	ORDER BY avg_attendance;

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
WITH nl_awards AS 
	(SELECT playerid,
	 	yearid,
	 	lgid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid = 'NL'),
al_awards AS
	(SELECT playerid,
		yearid,
	 	lgid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid = 'AL')
SELECT nl_awards.playerid,
	nl_awards.yearid,
	al_awards.yearid,
	nl_awards.lgid,
	al_awards.lgid
FROM nl_awards
INNER JOIN al_awards
ON nl_awards.playerid = al_awards.playerid 

SELECT playerid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
	AND lgid IN ('NL', 'AL')
GROUP BY playerid
HAVING COUNT(DISTINCT lgid) = 2

SELECT am_1.playerid
FROM awardsmanagers AS am_1
LEFT JOIN awardsmanagers AS am_2
ON am_1.playerid = am_2.playerid 
	AND am_2.lgid = 'NL'
WHERE am_1.lgid = 'Al'
	AND am_1.awardid = 'TSN Manager of the Year'

SELECT am.playerid,
	p.namegiven,
	am.yearid
FROM awardsmanagers AS am
LEFT JOIN people AS p
ON am.playerid = p.playerid
WHERE lgid = 'AL'
	AND awardid = 'TSN Manager of the Year'
	AND am.playerid IN
		(SELECT playerid
		FROM awardsmanagers
		WHERE awardid = 'TSN Manager of the Year'
			AND lgid = 'NL'
		ORDER BY playerid DESC)
GROUP BY am.playerid,
	p.namegiven,
	am.yearid
			

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.