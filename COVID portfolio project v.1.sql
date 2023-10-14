SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Likelihood of dying if you contract covid in your country
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases) * 100 AS DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE location like 'Italy'
ORDER BY 1,2

-- Total Cases vs Population
-- Percentage of Population got covid
SELECT
	location,
	date,
	total_cases,
	population,
	(total_cases/population) * 100 AS CovidPercent
FROM
	PortfolioProject..CovidDeaths
WHERE location like 'India'
ORDER BY 1,2

-- Countries with highest infection rate compared to population
SELECT
	location,
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population)) * 100 AS population_infected_percent
FROM
	PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY 4 DESC

-- Countries with Highest Death Count per Population
SELECT
	location,
	MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM
	PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Breaking things down by continent death count per population
SELECT
	location,
	MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM
	PortfolioProject..CovidDeaths

WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC

-- GLOBAL NUMBERS
SELECT
	--date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



--Total Population vs Vaccinations
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--cte for rolling people vaccinated
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
  dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/Population)*100
From PopvsVac
ORDER BY 2,3

--Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
  dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/Population)*100
From #PercentPopulationVaccinated

--View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
  dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated