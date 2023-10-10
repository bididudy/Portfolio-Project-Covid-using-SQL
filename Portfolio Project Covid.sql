/* 

Explore the global data on confirmed COVID-19 deaths and vaccinations

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


/* ---------------------------------------------- ANALYSIS by COUNTRY ------------------------------------------------------------------ */


-- by sorting covid_deaths table by clumn number 3 and 4 
SELECT 
	*
FROM 
	covid_deaths
ORDER BY 
	3, 4;

-- by sorting covid_vaccinations table by clumn number 3 and 4 
SELECT 
	*
FROM 
	covid_vaccinations
ORDER BY 
	3, 4;

-- select Data from covid_deaths that we will be using, sorted by locationa nd date
SELECT
	location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
	covid_deaths
ORDER BY
	1, 2;
    
-- Loking at total cases vs total deaths in Italy
-- Shows likelihood of dying if you contract covid in your country
WITH ItalyDeaths AS
(
	SELECT
		location,
		date,
		total_cases,
		total_deaths,
		(total_deaths/total_cases)*100 as death_percentage
	FROM
		covid_deaths
	WHERE
		location LIKE 'Italy'
	ORDER BY
		2
)
SELECT
	MAX(death_percentage) as max_value
FROM
	ItalyDeaths;
-- Death percentage was in italy was very high max was 14.52

-- Looking at total cases vs population in Italy
-- Shows what percentage of population infected with Covid
WITH ItalyCases as
(
	SELECT
		location,
		date,
		total_cases,
		population,
		(total_cases/population)*100 as case_percentage
	FROM
		covid_deaths
	WHERE
		location LIKE 'Italy'
	ORDER BY
		2
 ) 
 
 SELECT 
	MAX(case_percentage) as max_value
FROM
	ItalyDeaths;
-- here max percentage of cases in the population was 6.65 

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT
			location,
			date,
			total_cases,
			population,
			(total_cases/population)*100 as case_percentage
FROM
			covid_deaths
WHERE
	continent IS NOT NULL
ORDER BY
			1, 2;
            
-- Countries with Highest Infection Rate compared to Population
SELECT
		location,
        population,
		max(total_cases) AS HighestInfectionCount,
		MAX((total_cases/population)*100) as PercentPopulationInfected
FROM
			covid_deaths
WHERE
	continent IS NOT NULL
GROUP BY
	location,
    population
ORDER BY
	PercentPopulationInfected DESC;
-- We can see that Andorra is with highest percent infection with 17.12 out of 77265 population

-- Italy's Infection Rate compared to Population
SELECT
		location,
        population,
		max(total_cases) AS HighestInfectionCount,
		MAX((total_cases/population)*100) as PercentPopulationInfected
FROM
			covid_deaths
WHERE
	location LIKE 'Italy';
-- We can see that Italy is with 6.65 percent infection which is 4022653 out of 60461828 population


-- Countries with Highest Infection compared to Population
SELECT
		location,
        MAX(total_cases) as max_infection
FROM
			covid_deaths
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	max_infection DESC;
    
-- We can see that America is highest in infections 32346971
-- Countries with Highest deaths
SELECT
		location,
		max(total_deaths) AS HighestDeathCount
FROM
			covid_deaths
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	HighestDeathCount DESC;
-- We can see that United States is with highest deaths with 576232


/* ---------------------------------------------- ANALYSIS by CONTINENT ------------------------------------------------------------------ */

-- Loking at total cases in every content
SELECT
		location,
		MAX(total_cases) AS max_infection
        
FROM
		covid_deaths
WHERE
	continent IS NULL
GROUP BY
	location
ORDER BY
	max_infection DESC;
-- You can see that Europe continent was highly infected with 44863478 cases

-- Loking at total deaths in every content
SELECT
		location,
		MAX(total_deaths) AS max_deaths
        
FROM
		covid_deaths
WHERE
	continent IS NULL
GROUP BY
	location
ORDER BY
	max_deaths DESC;
-- You can see that Europe continent had most deaths - 1016750 deaths

/* ---------------------------------------------- GLOBAL NUMBERS ------------------------------------------------------------------ */

-- GLOBAL NUMBERS
SELECT
	SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths, 
    SUM(new_deaths)/SUM(New_Cases)*100 AS DeathPercentage
FROM
	covid_deaths
where continent is not null 
order by 1,2;
-- Global Numbers are: Total cases-150574977, Total Deaths- 3180206, Death Percentage-2.1120 %

/* ---------------------------------------------- JOINS ----------------------------------------------------------------------------- */

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
	d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM covid_deaths d
JOIN
	covid_vaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE 
	d.continent IS NOT NULL
ORDER BY
	2,3;
    
-- Using CTE to perform Calculation on Partition By in previous query to check percentge of vaccinated people over population
WITH vaccinations AS
(
	SELECT 
		d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
	FROM covid_deaths d
	JOIN
		covid_vaccinations v
		ON d.location = v.location
		AND d.date = v.date
	WHERE 
		d.continent IS NOT NULL
	ORDER BY
		2,3
)
SELECT
	*, RollingPeopleVaccinated/population*100 as percent
FROM
	vaccinations;


-- For the same procedure we can create temporary table instead of CTE
-- creating temporary table
CREATE TEMPORARY TABLE PercentPopulationVaccinated 
(
	continent VARCHAR(1024),
	location VARCHAR(1024),
	date DATETIME,
	population BIGINT,
    new_vaccinations BIGINT,
    RollingPeopleVaccinated BIGINT
);
-- inserting values into table
INSERT INTO PercentPopulationVaccinated 
SELECT 
	d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM covid_deaths d
JOIN
	covid_vaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE 
	d.continent IS NOT NULL
ORDER BY
	2,3;
    
SELECT
	*, RollingPeopleVaccinated/population*100 as percent
FROM
	PercentPopulationVaccinated;
    


