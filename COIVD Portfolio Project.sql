-- SELECT 
--     *
-- FROM
--     coviddeaths
-- ORDER BY 3 , 4;

-- SELECT 
--     *
-- FROM
--     covidvaccinations
-- ORDER BY 3 , 4;

-- Select Data that we are going to be usinng:
-- SELECT 
--     location,
--     date,
--     total_cases,
--     new_cases,
--     total_deaths,
--     population
-- FROM
--     coviddeaths
-- ORDER BY 1 , 2;

-- Looking at Total Cases vs Total Deaths:
-- Shows liklelihood of dying if you contract covid in your country
-- SELECT 
--     location,
--     date,
--     total_cases,
--     total_deaths,
--     (total_deaths / total_cases) * 100 AS DeathPercentage
-- FROM
--     coviddeaths
-- WHERE
--     location LIKE '%states%'
-- ORDER BY 1 , 2;

-- Total cases vs population: 
-- Whows waht percentage of population got covid
-- SELECT 
--     location,
--     date,
--     population,
--     total_cases,
--     (total_cases/population) * 100 AS PercentPopulationInfected
-- FROM
--     coviddeaths
-- WHERE
--     location LIKE '%states%'
-- ORDER BY 1 , 2;

-- Looking at countries with highest infection rate compared to population:
-- SELECT 
--     location,
--     population,
--     MAX(total_cases) AS HighestInfectionCount,
--     MAX((total_cases / population)) * 100 AS PercentPopulationInfected
-- FROM
--     coviddeaths
-- GROUP BY location , population
-- ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with highest death count per population:
-- SELECT 
--     location,
--     MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
-- FROM
--     coviddeaths
-- WHERE
--     continent IS NOT NULL
-- GROUP BY location
-- ORDER BY TotalDeathCount DESC;

-- Lets break things down by continent:

--  Showing contintents with highest death count per population:
-- SELECT 
--     continent,
--     MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
-- FROM
--     coviddeaths
-- WHERE
--     continent IS NOT NULL
-- GROUP BY continent
-- ORDER BY TotalDeathCount DESC;

-- Global numbers:
-- SELECT 
--     date,
--     SUM(new_cases) AS total_cases,
--     SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
--     SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
-- FROM
--     coviddeaths
-- WHERE
--     continent IS NOT NULL
-- GROUP BY date
-- ORDER BY 1 , 2

-- Looking at total population vs vaccinations:
-- SELECT 
--     dea.continent,
--     dea.location,
--     dea.date,
--     dea.population,
--     vac.new_vaccinations,
--     sum(convert(vac.new_vaccinations, signed)) over (partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
-- FROM
--     coviddeaths dea
--         JOIN
--     covidvaccinations vac ON dea.location = vac.location
--         AND dea.date = vac.date
-- WHERE
--     dea.continent IS NOT NULL
-- ORDER BY 2 , 3;


-- Use CTE:
-- with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPopulationVaccinated)
-- as (
-- SELECT 
--     dea.continent,
--     dea.location,
--     dea.date,
--     dea.population,
--     vac.new_vaccinations,
--     sum(CAST(vac.new_vaccinations AS SIGNED)) over (partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
-- FROM
--     coviddeaths dea
--         JOIN
--     covidvaccinations vac ON dea.location = vac.location
--         AND dea.date = vac.date
-- WHERE
--     dea.continent IS NOT NULL
-- -- ORDER BY 2 , 3
-- )
-- Select *, (RollingPopulationVaccinated/Population) * 100 from PopvsVac;

-- TEMP Table:

-- DROP Table if exists PercentPopulationVaccinated;
-- create temporary table PercentPopulationVaccinated (
-- Continent char(255),
-- Location char(255),
-- Date datetime,
-- Population numeric,
-- New_vaccinated numeric,
-- RollingPopulationVaccinated numeric
-- );
-- INSERT INTO PercentPopulationVaccinated
-- SELECT 
--     dea.continent,
--     dea.location,
--     STR_TO_DATE(dea.date, '%m/%d/%Y') AS Date,
--     dea.population,
--     CAST(NULLIF(vac.new_vaccinations, '') AS SIGNED) AS New_vaccinated,
--     SUM(CAST(NULLIF(vac.new_vaccinations, '') AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y')) AS RollingPopulationVaccinated
-- FROM
--     coviddeaths dea
-- JOIN
--     covidvaccinations vac ON dea.location = vac.location
--     AND dea.date = vac.date;
-- -- WHERE
-- --     dea.continent IS NOT NULL;

-- SELECT 
--     *, (RollingPopulationVaccinated / Population) * 100
-- FROM
--     PercentPopulationVaccinated;


-- Creating View to store data for later visulatizations:
Create View PercentPopulationVaccinated as 
SELECT 
    dea.continent,
    dea.location,
    STR_TO_DATE(dea.date, '%m/%d/%Y') AS Date,
    dea.population,
    CAST(NULLIF(vac.new_vaccinations, '') AS SIGNED) AS New_vaccinated,
    SUM(CAST(NULLIF(vac.new_vaccinations, '') AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y')) AS RollingPopulationVaccinated
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

SELECT * 
FROM PercentPopulationVaccinated;