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
-- SCRIPT	
SELECT p.height,
	p.namegiven,
	p.namelast,
	a.g_all AS games_played,
	t.name
FROM people AS p
LEFT JOIN appearances AS a
USING(playerid)
LEFT JOIN teams AS t
USING(teamid)
GROUP BY p.height,
	p.namegiven,
	p.namelast,
	a.g_all,
	t.name
ORDER BY p.height
LIMIT 1;	

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- ANSWER:
	-- Top earning Vanderbilt player: David Price (total salary: $81,851,296)
-- SCRIPT 1 (schoolid = vandy)
	SELECT *
	FROM schools
	ORDER BY schoolname DESC;
-- SCRIPT 2
	SELECT 
		p.namefirst,
		p.namelast,
		SUM(DISTINCT salary) AS total_salary
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
	SELECT
		ROUND(1.0*SUM(COALESCE(hr, 0))/SUM(COALESCE(g/2, 0)), 2) AS avg_homeruns,
		ROUND(1.0*SUM(COALESCE(so,0))/SUM(COALESCE(g/2, 0)), 2) AS avg_strikeouts,
		CONCAT(LEFT(CAST(yearid AS text), 3), '0s') AS decade
	FROM teams
	WHERE yearid >= '1920'
	GROUP BY CONCAT(LEFT(CAST(yearid AS text), 3), '0s')
	ORDER BY decade;

-- 6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
--ANSWER:
	-- Player with most success stealing in 2016: Chris Owings (91.304%)
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
	-- LARGEST number of wins for team that DID NOT win World Series: 116/Seattle Mariners/2001
	-- SMALLEST number of wins for team that DID win World Series: 83/St. Louis Cardinals/2006 (There was a players' strike in 1981, which is why the LA dodgers only won 63 games that season and went on to win the series)
	-- Number of times team with most wins won World Series: 12 times
	-- Percent of times team with most wins won World Series: 25%
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
	WITH top_scores AS
	(SELECT DISTINCT a.yearid,
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
		FROM top_scores;
--SCRIPT 4
	WITH top_scores AS
	(SELECT DISTINCT a.yearid,
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
	SELECT CAST(AVG(CASE WHEN wswin = 'Y' THEN 1.0
			   WHEN wswin = 'N' THEN 0.0 END)*100.0 AS DECIMAL(10,2)) AS avg
		FROM top_scores;	

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
-- ANSWER:
-- 	James Richard "Jim" Leland / Pittsburgh Pirates; Detroit Tigers (player id: leylaji99; years: 1988, 1990, 1992, 2006)
-- 	David Allen "Davey" Johnson / Baltimore Orioles, Washington Nationals (player id: johnsda02; years: 1997; 2012)
-- SCRIPT 1 (finding player ids and years)
	WITH nl_awards AS 
		(SELECT playerid,
			yearid
		FROM awardsmanagers
		WHERE awardid = 'TSN Manager of the Year'
			AND lgid = 'NL'),
	al_awards AS
		(SELECT playerid,
			yearid
		FROM awardsmanagers
		WHERE awardid = 'TSN Manager of the Year'
			AND lgid = 'AL')
	SELECT nl_awards.playerid,
		nl_awards.yearid,
		al_awards.yearid
	FROM nl_awards
	INNER JOIN al_awards
	USING(playerid)
-- SCRIPT 2 (checking work)
	SELECT playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid IN ('NL', 'AL')
	GROUP BY playerid
	HAVING COUNT(DISTINCT lgid) = 2
-- SCRIPT 3 (finding full names and teams)
SELECT playerid,
	namegiven,
	namefirst,
	namelast,
	teamID,
	t.name,
	am.yearid,
	am.lgid,
	awardid
FROM awardsmanagers AS am
LEFT JOIN people AS p
USING(playerid)
LEFT JOIN managers as m
USING(playerid, yearid)
LEFT JOIN teams AS t
USING(teamid, yearid)
WHERE awardid = 'TSN Manager of the Year'
	AND awardid <> 'BBWAA Manager of the Year'
	AND playerid = 'johnsda02' 
	OR playerid = 'leylaji99' 
ORDER BY playerid,
	awardid

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
-- ANSWER
	/*"Robinson"	"Cano"	"canoro01"	39
	"Bartolo"	"Colon"	"colonba01"	1
	"Rajai"	"Davis"	"davisra01"	12
	"Edwin"	"Encarnacion"	"encared01"	42
	"Francisco"	"Liriano"	"liriafr01"	1
	"Mike"	"Napoli"	"napolmi01"	34
	"Angel"	"Pagan"	"paganan01"	12
	"Adam"	"Wainwright"	"wainwad01"	2*/
-- SCRIPT
	SELECT p.namefirst,
		p.namelast,
		b1.playerid,
		b1.hr,
		b2.max_hr,
		b1.yearid
	FROM batting AS b1
	INNER JOIN 
		(SELECT DISTINCT playerid,
			MAX(hr) AS max_hr
		FROM batting
		GROUP BY playerid) AS b2
	ON b1.playerid = b2.playerid
		AND b1.hr = b2.max_hr
	LEFT JOIN people AS p
	ON b1.playerid = p.playerid
	WHERE hr >= 1
		AND yearid = 2016
		AND b1.playerid IN
			(SELECT playerid
			FROM people
			WHERE debut <= '2007-01-01')
	ORDER BY b1.playerid

--
--
--
--
--
--
--
--
--
--

-- Walkthrough w/ Taryn
SELECT playerid,
	SUM(bba) AS career_walks_allowed
FROM managers
LEFT JOIN teams
USING(teamid)
GROUP BY playerid
ORDER BY playerid;

SELECT *
FROM managers
WHERE playerid = 'actama99'

SELECT *
FROM teams
WHERE yearid BETWEEN 2007 AND 2009 AND teamid = 'WAS'
OR yearid BETWEEN 2010 AND 2012 AND teamid = 'CLE'

SELECT SUM(bba)
FROM teams
WHERE yearid BETWEEN 2007 AND 2009 AND teamid = 'WAS'
OR yearid BETWEEN 2010 AND 2012 AND teamid = 'CLE'

SELECT playerid,
	teamid,
	managers.yearid,
	bba
FROM managers
LEFT JOIN teams
USING(teamid)
WHERE playerid = 'actama99'

SELECT playerid,
	SUM(bba) AS career_walks_allowed
FROM managers
LEFT JOIN teams
USING(teamid, yearid)
GROUP BY playerid
ORDER BY playerid