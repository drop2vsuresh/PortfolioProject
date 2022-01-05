SELECT * 
FROM PortfolioProject.dbo.CovidDeath 
WHERE continent is not NULL
ORDER BY 3,4;

-- SELECT * 
-- FROM PortfolioProject.dbo.CovidVaccinations 
-- ORDER BY 3,4;


-- Select data that we are going to be using

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeath
WHERE continent is not NULL
ORDER BY 1,2 

-- Looking at Total Cases vs Total Deaths
-- Show what percentage of population got covid

SELECT Location,date,total_cases,total_deaths,( total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of Population got Covid

SELECT Location,date,population,total_cases,(total_cases/population)*100 AS PercentageofPopulationinfected
FROM PortfolioProject..CovidDeath
WHERE location LIKE '%india%'
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate Compared to Population

SELECT Location,population,MAX(total_cases)as HighestInfectionCount,MAX((total_cases/population))*100 AS PercentageofPopulationinfected
FROM PortfolioProject..CovidDeath
--WHERE location LIKE '%india%'
GROUP BY Location,population
ORDER BY PercentageofPopulationinfected DESC


-- Showing countries with Highest Death Count per Population

SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeath
--WHERE location LIKE '%india%'
WHERE continent is  NULL
GROUP BY Location
ORDER BY TotalDeathsCount DESC

-- Let's Break Things Down By Continent

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeath
--WHERE location LIKE '%india%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC


--Global Number
SELECT SUM(new_cases) AS Total_Cases ,SUM(CAST(new_deaths as int)) AS Total_Death,(SUM(CAST
(new_deaths as int))/SUM(new_cases)) * 100 AS PercentageofPopulationinfected
FROM PortfolioProject..CovidDeath
WHERE continent is not NULL
--WHERE location LIKE '%india%'
--GROUP BY date
ORDER BY 1,2




--looking at total population vs vaccination
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as numeric )) 
	OVER (Partition By dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccination
	--,(RollingPeopleVaccination/population)*100
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL 
ORDER BY 2,3

--Use CTE
WITH PopvsVac (continent,location,Data,population,new_vaccinations,RollingPeopleVaccination)
as
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as numeric )) 
	OVER (Partition By dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccination
	--,(RollingPeopleVaccination/population)*100
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL 
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccination/population)*100 AS pep
FROM PopvsVac 


--Temp Table

DROP Table if exists #percentpopulationVaccinated
CREATE Table #percentpopulationVaccinated
(
continent nvarchar(255),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric
)

INSERT into #percentpopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as numeric )) 
	OVER (Partition By dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccination
	--,(RollingPeopleVaccination/population)*100
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--WHERE dea.continent is not NULL 
--ORDER BY 2,3


SELECT * , (RollingPeopleVaccination/population)*100 
FROM #percentpopulationVaccinated 

--------------------------------------------------------------------------------
--Creating View to store data for later visualizations
DROP View if exists percentpopulationVaccinated
Create View percentpopulationVaccinated as
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as numeric )) 
	OVER (Partition By dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccination
	--,(RollingPeopleVaccination/population)*100
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL 
--ORDER BY 2,3