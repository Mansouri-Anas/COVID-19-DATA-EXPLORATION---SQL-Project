/*
Anas Mansouri 
SQL COVID 19 DATA EXPLORATION PROJECT
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Data im using
Select location, date,total_cases,new_cases,total_cases,total_deaths,population
From PortflioProject..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid Morocco

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
Select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortflioProject..CovidDeaths
WHERE location like 'Morocco'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of Moroccan population infected with Covid

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
Select location, date,total_cases,population,(total_cases/population)*100 as CasesPercentage
From PortflioProject..CovidDeaths
WHERE location like 'Morocco'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
Select location,max(total_cases) as HighestTotalCases,population,max((total_cases/population))*100 as CasesPercentage
From PortflioProject..CovidDeaths
Group by location,population
order by CasesPercentage desc

-- Countries with highest death count per population

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
Select location,population,max(total_deaths) as TotalDeaths
From PortflioProject..CovidDeaths
where continent != ' '
Group by location,population
order by TotalDeaths desc

-- Showing contintents with the highest death count per population

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
Select continent,max(total_deaths) as TotalDeaths
From PortflioProject..CovidDeaths
where continent = ' '
Group by continent
order by TotalDeaths desc

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
Select location,max(total_deaths) as TotalDeaths
From PortflioProject..CovidDeaths
where continent = ' '
Group by location
order by TotalDeaths desc

-- global cases and deaths and death percentage per day

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
Select date,sum(new_cases) as totalcases,SUM(new_deaths) as totaldeaths,SUM(new_deaths)/SUM(new_cases)*100 as deathpercentage
From PortflioProject..CovidDeaths
--where continent = ' '
Group by date
order by 1,2

-- total cases and deaths and death percentage

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
Select sum(new_cases) as totalcases,SUM(new_deaths) as totaldeaths,SUM(new_deaths)/SUM(new_cases)*100 as deathpercentage
From PortflioProject..CovidDeaths
--where continent = ' '
order by 1,2


-- Showing Percentage of Population that has recieved at least one Covid Vaccine
-- Using CTE to perform Calculation on Partition By 

with PopulvsVaccin(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortflioProject..CovidDeaths dea
Join PortflioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date=vac.date
where dea.continent != ' '
) 
select *,RollingPeopleVaccinated/population*100 as PercentageOfVaccinated 
from PopulvsVaccin
order by 2,3

-- Showing Percentage of Population that has recieved at least one Covid Vaccine
-- Using Temp Table to perform Calculation on Partition By

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)
insert into #PercentagePopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortflioProject..CovidDeaths dea
Join PortflioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date=vac.date
where dea.continent != ' '

select * from #PercentagePopulationVaccinated
where location='Morocco'
order by 2,3


-- Views for later visualisations
Create view PercentagePopulationVaccinated 
as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortflioProject..CovidDeaths dea
Join PortflioProject..CovidVaccinations vac
On dea.location = vac.location and dea.date=vac.date
where dea.continent != ' '
select * from PercentagePopulationVaccinated