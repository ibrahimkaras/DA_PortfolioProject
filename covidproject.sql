select *
from PortfolioProject..coviddeath
where location like 'asi%'


--looking at new and total cases and deaths
select continent, Location, date, total_cases, new_cases, new_deaths, total_deaths, population

from PortfolioProject..coviddeath
where continent is not null
and location like 'TURKEY%'
order by 1,2

--looking at total cases vs total deaths
--shows what percentage of total cases got death
select Location, date, total_cases, total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
from PortfolioProject..coviddeath
where location like 'TURKEY%'
and continent is not null
order by 1,2

--looing at total cases vs population 
--shows what percentage of population got covid
select Location, date, total_cases, population, cast(total_cases as float)/cast(population as float)*100 as InfectedCovidPercentage
from PortfolioProject..coviddeath
where location like 'TURKEY%'
and continent is not null
order by 1,2

--Looking at countries with highest Infection rate compraed to population

select Location, population, max(cast(total_cases as int)) as HighestInfectionCount
, MAX(cast(total_cases as float)/cast(population as float)*100) as maxInfectedCovidPercentage
from PortfolioProject..coviddeath
where continent is not null
--and location like 'TURKEY%'
group by  Location, population 
order by maxInfectedCovidPercentage desc


--showing countries with highest death count per population 

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeath
where continent is not null
--and location like 'TURKEY%'
group by  Location 
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT  
--showing continent with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount, max(cast(total_deaths as float)/cast(population as float))*100 as DeatPercentage
from PortfolioProject..coviddeath
--where location like 'TURKEY%'
where continent is null
group by  location 
order by TotalDeathCount desc


--global numbers to date
select date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100  as DeathPercentage
from PortfolioProject..coviddeath
where continent is not null
group by date
having sum(new_cases)*100 > 0
order by 1,2


--looking at total populations vs vaccination

select
dea.continent
,dea.location
,dea.population
,dea.date
,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as cumulative_vaccinations
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.location = 'Turkey'
order by 1,2,3


--CTE

with PopvsVac (Continent, Locations, Population, Date, New_vaccinations, CumulativeVac)
as (
select
dea.continent
,dea.location
,dea.population
,dea.date
,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.location = 'Turkey'
)
select *
,CumulativeVac/cast(Population as float) *100 as vacRate
from PopvsVac


select *
from PortfolioProject..covidvaccination
where location = 'turkey'
order by date

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
Date datetime,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select 
dea.continent
,dea.location
,dea.population
,dea.date
,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.location = 'Turkey'

select *
,RollingPeopleVaccinated/cast(Population as float) *100 as vacRate
from #PercentPopulationVaccinated

--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
select 
dea.continent
,dea.location
,dea.population
,dea.date
,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as cumulative_vaccinations
from PortfolioProject..coviddeath dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'Turkey'

select *
from PercentPopulationVaccinated

