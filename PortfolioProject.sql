Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4


--Select the Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'Australia'
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (cast(total_cases as float)/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
where location = 'Australia'

-- Looking at countries with highest infection rates compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, max((convert(float, total_cases))/population)*100 as
 PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by 4 desc


SELECT cd.location, cd.population, cd.HighestInfectionCount,
    (CONVERT(FLOAT, cd.HighestInfectionCount) / cd.population) * 100 AS PercentPopulationInfected
FROM (SELECT location, population, MAX(total_cases) AS HighestInfectionCount
    FROM PortfolioProject..CovidDeaths
    GROUP BY location, population) AS cd
ORDER BY PercentPopulationInfected DESC;


-- Showing countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK IT DOWN BY CONTINENT

-- Showing continents with the highest deaths

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
and location not like '%income%'
Group by location
order by TotalDeathCount desc


-- Showing continents withe the highest death rate per poulation

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount,
(MAX(cast(total_deaths as int))/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is null
and location not like '%income%'
Group by location, population
order by population desc


-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
CASE 
  WHEN SUM(new_cases) = 0 THEN 0 -- Handle divide by zero error
  ELSE (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100 
END AS DeathPercentage
from PortfolioProject..CovidDeaths
where continent is null
--group by date
order by 1,2


-- Looking at Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from PopVsVac


-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3

select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from #PercentPopulationVaccinated
order by 2, 3



-- Creating View to store data for later visualizations



Create View PopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3

select *
from PopulationVaccinated


