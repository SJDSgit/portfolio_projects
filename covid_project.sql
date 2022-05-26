--Overview of the Tables
SELECT *
FROM covid_project..covid_deaths
ORDER BY 3,4

SELECT *
FROM covid_project..covid_vaccinations
ORDER BY 3,4

--Select Data that we are going to use
SELECT location,date,total_cases,total_deaths,new_cases,population
FROM covid_project..covid_deaths
ORDER BY 3,4

--Total Cases vs Total Deaths in India
SELECT location,date,total_cases,total_deaths,new_cases,population,(total_deaths/total_cases)*100 AS DeathRate
FROM covid_project..covid_deaths
Where location='India'
ORDER BY 3,4

--Total Cases vs Population
SELECT location,date,total_cases,population,(total_cases/population)*100 AS TotalCovidPercent
FROM covid_project..covid_deaths
Where location='India'
ORDER BY 3,4

-- Highest Infection Rate in each Country
SELECT location,MAX(total_cases) AS HighestInfectionCount,population,MAX((total_cases/population))*100 AS HighestInfectionRate
FROM covid_project..covid_deaths
--Where location='India'
GROUP BY location,population
ORDER BY 4 DESC

--Countries with Highest Death Count per Population
SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM covid_project..covid_deaths
Where continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents by Highest Death Counts
SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM covid_project..covid_deaths
Where continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Breakdown of ASIA
SELECT continent,location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM covid_project..covid_deaths
Where continent ='Asia'
GROUP BY continent,location
ORDER BY TotalDeathCount DESC

SELECT	SUM(new_cases) AS total_cases, 
		SUM(CAST(new_deaths AS INT)) AS total_deaths, 
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM covid_project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total Population vs Vaccinations
SELECT	dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_project..covid_deaths dea
JOIN  covid_project..covid_vaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent ='Asia'
ORDER BY 2,3

--CTE
WITH PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT	dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_project..covid_deaths dea
JOIN  covid_project..covid_vaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT	dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_project..covid_deaths dea
JOIN  covid_project..covid_vaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating a VIEW
CREATE VIEW PercentPopulationVaccinated AS
SELECT	dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_project..covid_deaths dea
JOIN  covid_project..covid_vaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent = 'Asia'
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
