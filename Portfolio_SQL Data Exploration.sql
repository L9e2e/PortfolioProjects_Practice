USE [Portfolio_SQL Data Exploration]
GO

--SELECT * FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
--WHERE continent IS NOT NULL
--ORDER BY 3,4

--SELECT * FROM [Portfolio_SQL Data Exploration].dbo.Covid_Vaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total cases vs total deaths
-- Shows likelihood of dying if you contract COVID in Poland
SELECT location, date, total_cases, total_deaths, (NULLIF(total_deaths,0)/NULLIF(total_cases, 0))*100 as DeathPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE location like '%poland%'
ORDER BY 1,2

-- Looking at Total cases vs population
-- Shows what percentage of population got COVID
SELECT location, date, population, total_cases, (NULLIF(total_cases,0)/NULLIF(population, 0))*100 as CasesPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE location like '%poland%'
ORDER BY 1,2

-- Looking at countries with higher infection rate compared to population
-- Population does not change in this database
SELECT location, population, MAX(total_cases) as HigehstInfectionCount, MAX((NULLIF(total_cases,0)/NULLIF(population, 0)))*100 as CasesPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY CasesPercentage DESC

-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) as HighestDeathCount, MAX((NULLIF(total_deaths,0)/NULLIF(population, 0)))*100 as DeathsPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC

-- Showing continents with highest death count per population_version 1
SELECT continent, MAX(total_deaths) as HighestDeathCount, MAX((NULLIF(total_deaths,0)/NULLIF(population, 0)))*100 as DeathsPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- Showing continents with highest death count per population_version 2
SELECT location, MAX(total_deaths) as HighestDeathCount, MAX((NULLIF(total_deaths,0)/NULLIF(population, 0)))*100 as DeathsPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--Global numbers
SELECT date, SUM(new_cases) AS SumOfCases, SUM(new_deaths) AS SumOfDeaths, (SUM(NULLIF(new_deaths,0))/SUM(NULLIF(new_cases,0))*100) AS PercentageOfDeaths
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL AND new_cases != 0
GROUP BY date
ORDER BY date ASC

--All cases/deaths for 04-08-2024
SELECT SUM(new_cases) AS SumOfCases, SUM(new_deaths) AS SumOfDeaths, (SUM(NULLIF(new_deaths,0))/SUM(NULLIF(new_cases,0))*100) AS PercentageOfDeaths
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL

--Joining deaths and vaccination tables. Looking at total population vs vaccinations
SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS vaccinations_so_far
FROM Covid_Deaths AS dea
JOIN Covid_Vaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations != 0
ORDER BY 2,3

--Population vs vaccinations
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, vaccinations_so_far) AS
(SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS vaccinations_so_far
FROM Covid_Deaths AS dea
JOIN Covid_Vaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations != 0)

SELECT *,
(vaccinations_so_far/Population)*100 AS PopulationVsVaccinations
FROM PopVsVac
ORDER BY 2,3

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated AS
SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS vaccinations_so_far
FROM Covid_Deaths AS dea
JOIN Covid_Vaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations != 0

Create View PopulationVsVaccinated AS
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, vaccinations_so_far) AS
(SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS vaccinations_so_far
FROM Covid_Deaths AS dea
JOIN Covid_Vaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations != 0)
SELECT *,
(vaccinations_so_far/Population)*100 AS PopulationVsVaccinations
FROM PopVsVac

Create View TotalcasesVstotaldeaths AS
SELECT location, date, total_cases, total_deaths, (NULLIF(total_deaths,0)/NULLIF(total_cases, 0))*100 as DeathPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE location like '%poland%'

Create View TotalcasesVsPopulation AS
SELECT location, date, population, total_cases, (NULLIF(total_cases,0)/NULLIF(population, 0))*100 as CasesPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE location like '%poland%'

Create View Higher_infection_rate_compared_to_population AS
SELECT location, population, MAX(total_cases) as HigehstInfectionCount, MAX((NULLIF(total_cases,0)/NULLIF(population, 0)))*100 as CasesPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population

Create View highest_death_count_per_population AS
SELECT location, MAX(total_deaths) as HighestDeathCount, MAX((NULLIF(total_deaths,0)/NULLIF(population, 0)))*100 as DeathsPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population

Create View continents_with_highest_death_count_per_population_1 AS
SELECT continent, MAX(total_deaths) as HighestDeathCount, MAX((NULLIF(total_deaths,0)/NULLIF(population, 0)))*100 as DeathsPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent

Create View continents_with_highest_death_count_per_population_2 AS
SELECT location, MAX(total_deaths) as HighestDeathCount, MAX((NULLIF(total_deaths,0)/NULLIF(population, 0)))*100 as DeathsPercentage
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NULL
GROUP BY location

Create View Global_Numbers AS
SELECT date, SUM(new_cases) AS SumOfCases, SUM(new_deaths) AS SumOfDeaths, (SUM(NULLIF(new_deaths,0))/SUM(NULLIF(new_cases,0))*100) AS PercentageOfDeaths
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL AND new_cases != 0
GROUP BY date

Create View All_cases_deaths AS
SELECT SUM(new_cases) AS SumOfCases, SUM(new_deaths) AS SumOfDeaths, (SUM(NULLIF(new_deaths,0))/SUM(NULLIF(new_cases,0))*100) AS PercentageOfDeaths
FROM [Portfolio_SQL Data Exploration].dbo.Covid_Deaths
WHERE continent IS NOT NULL