select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccination
--order by 3,4

--select Data to be use

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at the Total cases Vs Total Deaths


select location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2), total_cases) )*100 as DeathPercent
from PortfolioProject..CovidDeaths
order by 1,2

select location, date, total_cases, total_deaths,(convert(decimal(18,2), total_deaths) / convert(decimal(18,2), total_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and total_cases is not null and total_deaths is not null
order by 1,2

--Looking at the Total Cases Vs Population
--Shows percentage of population that got Covid
select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%igeria%'
order by 1,2

--Looking at the Countries with the Highest Infection Rate compared to  Population
select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc


--Showing Countries with the Highest Deaths Count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Break things up by Continents

--Showing the continents with the Highest Death Count per Population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by  continent
order by TotalDeathCount desc

--Global Numbers
select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(cast (v.new_vaccinations as bigint)) OVER (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
   on d.location = v.location
   and  d.date =  v.date
where d.continent is not null
order by 2,3

--Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(cast (v.new_vaccinations as bigint)) OVER (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
   on d.location = v.location
   and  d.date =  v.date
where d.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac

--creating view to store data for visualization
create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(cast (v.new_vaccinations as bigint)) OVER (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
   on d.location = v.location
   and  d.date =  v.date
where d.continent is not null

select * from PercentPopulationVaccinated