
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4


-- Selecting the required Data. 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2


-- Total cases vs total deaths. 
-- Displays the likelihood of dying if anyone had covid around that time in India. 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
order by 1, 2


-- Total cases vs population
-- Shows the percentage of population that got covid.
SELECT location, date, total_cases, population, (total_cases/population)*100 as PopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
order by 1, 2


-- Countries with highest Infection Rate compared to Population.
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
group by location, population
order by PercentPopulationInfected desc


-- BREAKING THE SITUATION DOWN BASED ON CONTINENTS. 
-- Continents with the highest death count. 

-- Instead of using the continents columns directly, we use the locations where the continents are null. 
-- Because the Data set is arranged like that. 
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL  
group by location
order by HighestDeathCount desc


---- KEEPING THE CONTINENT CODE. (The values seem off compared to the results of the query above.)
--SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL  
--group by continent
--order by HighestDeathCount desc


-- Showing continents with the highest death count. 
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL  
group by continent 
order by HighestDeathCount desc

/* 
Looking at the data from a global pov - by using continents instead of locations. 
But since the data set is divided in such a way, that the global stats seem more 
relevant when the location is taken into consideration instead of the continents 
themselves. 
*/


-- Global numbers 
SELECT SUM(new_cases) as TotalCases, 
			SUM(CAST(new_deaths as int)) as TotalDeaths, 
			SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
order by 1, 2


-- Looking at Total Population vs Vaccinations. 
SELECT dea.continent, dea.location, dea.date, dea.population, 
	   vac.new_vaccinations, SUM(CONVERT(int, new_vaccinations)) OVER (
	   PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- CTE 
WITH PopulationVsVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, 
	   vac.new_vaccinations, SUM(CONVERT(int, new_vaccinations)) OVER (
	   PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, ( RollingPeopleVaccinated/ population)*100 
FROM PopulationVsVaccination


-- Or we can use, Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
( continent nvarchar(255), 
  location nvarchar(255), 
  date datetime, 
  population numeric, 
  new_vaccinations numeric, 
  RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, 
	   vac.new_vaccinations, SUM(CONVERT(int, new_vaccinations)) OVER (
	   PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM #PercentPopulationVaccinated

