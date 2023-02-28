SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CovidPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- Showing countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing continents with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1


-- Covid Vaccinations

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4

-- Looking at Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST (v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 1, 2, 3

-- CTE

WITH PopvsVac AS 
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST (v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric, 
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST (v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
ON d.location = v.location 
AND d.date = v.date
--WHERE d.continent IS NOT NULL
--ORDER BY 1, 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
GO
CREATE VIEW PercentPopulationVaccinatedView
AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST (v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 1, 2, 3
GO

DROP VIEW IF EXISTS PercentPopulationVaccinatedView


SELECT *
FROM PercentPopulationVaccinatedView