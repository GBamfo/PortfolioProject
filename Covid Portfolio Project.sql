select *
from PortfolioProject..CovidDeaths
where continent is not null

--select data to be worked with

select location, date, population, total_cases, new_cases, total_deaths
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vrs Total deaths
--Showing likelihood of dying from Covid

select location, date, population, total_cases, total_deaths, (total_deaths/cast(total_cases as numeric))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order  by 1,2

--Total cases vrs population
-- Showing percentage of the population that got Covid

select location, date, population, total_cases, (cast(total_cases as numeric)/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
where continent is not null
order  by 1,2

--Countries with Highest infection rate

select location, population, max(cast(total_cases as numeric)) as HighestInfectionCount,
max((cast(total_cases as numeric))/(cast(population as numeric)))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order  by PercentagePopulationInfected desc


-- Countries with highest death count per population

select location, population, max(cast(total_deaths as int)) as HighestDeathCount,
max((cast(total_deaths as numeric))/population)*100 as DeathPercentagePerPopulation
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order  by DeathPercentagePerPopulation desc

--Number of cases per Continent

select continent, max(cast(total_cases as int)) as TotalCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order  by TotalCount desc

--Number of Deaths per Continent

select continent, max(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order  by TotalDeaths desc

--Percentage of Deaths per Continent

select continent, sum(population) as ContinentPopulation, max(cast(total_deaths as int)) as TotalDeaths, max(cast(total_cases as int)) as TotalCount,
(max(cast(total_deaths as int))/max(cast(total_cases as numeric)))*100 DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order  by TotalDeaths desc

--World Figures

select sum(cast(new_cases as numeric)) as SumNewCases, sum(cast(new_deaths as numeric)) as SumNewDeath,
sum(cast(new_deaths as numeric))/sum(cast(new_cases as numeric))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and date > '2020-01-20 00:00:00.000'
--group by date
--order by date

--Total Population vrs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Total Population vs Vaccination using Continents
--Using CTE
--Drop table if exists PopVac
with PopVac(Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)* 100
from PopVac

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date

select *, (RollingPeopleVaccinated/population)* 100 PercentageVaccinated
from #PercentPopulationVaccinated


--Creating View for Visualization

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated