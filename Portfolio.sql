SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


-- Looking at Total Cases VS Total Deaths
-- Shows likelihood dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%state%' AND continent is not NULL
ORDER BY 1,2


-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


-- Looking at Countries with Highest Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,
	SUM(cast(new_deaths as int))/SUM(New_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths

WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2 


--Looking at Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM( cast(vac.new_vaccinations as int))
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--	(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea JOIN
	PortfolioProject..CovidVaccinations vac ON
	dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3


-- USE CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int))
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea JOIN
	PortfolioProject..CovidVaccinations vac ON
	dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint))
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea JOIN
	PortfolioProject..CovidVaccinations vac ON
	dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as bigint))
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea JOIN
		PortfolioProject..CovidVaccinations vac ON
		dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent is not NULL

SELECT *
FROM PercentPopulationVaccinated


