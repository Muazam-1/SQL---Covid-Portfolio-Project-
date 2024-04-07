-- Covid 19 Data Exploration
SELECT * 
FROM CovidDeaths$

-- Select The data required (location, date, total_cases, new_cases, total_deaths, population)
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Total Deaths vs Total Cases in Pakistan
-- Shows liklihood of dying people
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
FROM CovidDeaths$
WHERE location like '%Pak%'
ORDER BY 1,2

-- Total cases vs Total Population in Pakistan
-- Shows the percentage of people got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage 
FROM CovidDeaths$
WHERE location like '%Pak%' 
ORDER BY 1,2

-- Conutries with highest Infection rate compared to Population
SELECT location,population, Max(total_cases) as MaxInfectionCount, Max((total_cases/population))*100 as MaxInfectedPercentage 
FROM CovidDeaths$
WHERE continent is not null
GROUP BY  location, population
ORDER BY MaxInfectedPercentage DESC

-- Countries with Maximum Death Count
SELECT location, Max(cast(total_deaths as int)) as MaximumDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY MaximumDeathCount DESC


-- Continent with highest/Maximum Death Count
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Population vs Vaccination using CTE
WITH POPvsVACC(continent, location, date, population, new_vaccinations, RollingPopVaccinated)
AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location
 ORDER BY d.location, d.date) as RollingPopVaccinated
FROM CovidDeaths$ d
Join CovidVaccinations$ v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null

)

SELECT *, (RollingPopVaccinated/population)*100 as Percenatge_RollingPopVaccinated
FROM POPvsVACC
ORDER BY location, date


-- Using Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ d
Join CovidVaccinations$ v
	On d.location = v.location
	and d.date = v.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From CovidDeaths$ d
Join CovidVaccinations$ v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 

-- Verifying View
SELECT * FROM PercentPopulationVaccinated