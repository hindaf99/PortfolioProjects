--select* 
--from CovidDeaths$
--order by 3,4

--select* from CovidVaccinations$

select Location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%states%'

--Looking at Total Cases vs Population 

select Location, date, total_cases, Population, (total_cases/Population)*100 as DeathPercentage
from CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at countries with highest Infection Rate compared to population

select Location, Population, max(total_cases) as HighestInfectionCount, max ((total_cases/Population))*100 as PercentagepopulationInfected 
from CovidDeaths$
group by Location, Population 
order by PercentagepopulationInfected  desc

--Showing the countries with highest death counts per population
--, max ((total_Deaths/Population))*100 as Percentagepopulationdead

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by HighestDeathCount desc


-- Global Numbers

select Location, date, total_cases, Population, (total_cases/Population)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
order by 1,2

select dea.continent, dea.Location, dea.date, dea.Population, vac.new_vaccinations, 
sum (convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
    on dea.Location = vac.Location
    and dea.date = vac.date

where dea.continent is not null
order by 1,2


--use CTE

with PovsVac (continent, Location, Date, Population, RollingPeopleVaccinated) 
select dea.continent, dea.Location, dea.date, dea.Population, vac.new_vaccinations, 
sum (convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
    on dea.Location = vac.Location
    and dea.date = vac.date

where dea.continent is not null
order by 1,2

select *

--Temp Table

drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT into #PercentPopulationVaccinated

select dea.continent, dea.Location, dea.date, dea.Population, vac.new_vaccinations, 
sum (convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
    on dea.Location = vac.Location
    and dea.date = vac.date

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Create view to store data for latter 

create view PercentPopulationVaccinated as 
select dea.continent, dea.Location, dea.date, dea.Population, vac.new_vaccinations, 
sum (convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
    on dea.Location = vac.Location
    and dea.date = vac.date

where dea.continent is not null
order by 1,2


select * 
from PercentPopulationVaccinated
