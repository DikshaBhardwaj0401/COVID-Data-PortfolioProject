-- Since, we can not connect Tableau public with the DB. 
-- Therefore here are the queries for the required views.

-- 1.
SELECT SUM(new_cases) as TotalCases,
	   SUM(CAST(new_deaths as int)) as TotalDeaths, 
	   SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2
	
-- --Just a double check based off the data provided
-- --numbers are extremely close so we will keep them - The Second includes "International"  Location

--Select SUM(new_cases) as total_cases, 
--       SUM(cast(new_deaths as int)) as total_deaths, 
--	   SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--where location = 'World'
--order by 1,2


-- 2.
-- In accordance with the data, the following locations are inconsistent.
-- Therefore, we take them out.

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3.
Select location, population, MAX(total_cases) as HighestInfectionCount,  
       MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

-- 4. 
Select location, population, MAX(total_deaths) as HighestDeathCount,  
       MAX((total_deaths/population))*100 as PercentPopulationDeceased
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationDeceased desc

-- 5.
Select Location, Population,date, 
       MAX(total_cases) as HighestInfectionCount,  
	   Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc