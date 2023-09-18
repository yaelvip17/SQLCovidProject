--looking at everything
-- shows the table

select *
from CovidDeaths
where continent is not null

-- looking at total deaths vs total cases
-- shows the odds of dying from covid per country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 deathPercentage
from CovidDeaths
where continent is not null
order by location, date

-- create view for later vizualization

create view oddsOfDying as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 deathPercentage
from CovidDeaths
where continent is not null

-- looking at total cases vs population in Israel
-- shows the precentage of population that has covid

select location, date, total_cases, population, (total_cases/population)*100 populationPercentage
from CovidDeaths
where continent is not null and location like 'isra%'
order by location, population

-- looking at countries with highest infection rate compared to the population
-- shows the precentage of population that got infected

select location, population, max(total_cases) highetsInfectionCount,
max(total_cases/population)*100 populationPercentageInfected
from CovidDeaths
where continent is not null
group by population, location
order by populationPercentageInfected desc

-- create view for later vizualization

create view popInfected as
select location, population, max(total_cases) highetsInfectionCount,
max(total_cases/population)*100 populationPercentageInfected
from CovidDeaths
where continent is not null
group by population, location

-- looking at countries with highest deaths count
-- shows the highest total death counts

select location, max(cast(total_deaths as int)) totalDeathsCount
from CovidDeaths
where continent is not null
group by location
order by totalDeathsCount desc

-- create view for later vizualization

create view totalDeathsCount as
select location, max(cast(total_deaths as int)) totalDeathsCount
from CovidDeaths
where continent is not null
group by location

-- looking at global numbers
-- shows the total cases, deaths and the death percentage in the world

select sum(total_cases) totalCases, sum(cast(total_deaths as int)) totalDeaths,
sum(cast(total_deaths as int))/sum(total_cases)*100 deathPercentage
from CovidDeaths
where continent is not null
order by 1, 2

-- create view for later vizualization

create view globalNumbers as
select sum(total_cases) totalCases, sum(cast(total_deaths as int)) totalDeaths,
sum(cast(total_deaths as int))/sum(total_cases)*100 deathPercentage
from CovidDeaths
where continent is not null

-- "join" the two tables

select *
from CovidDeaths coD
join CovidVaccinations coV
on coD.location=coV.location and coD.date=coV.date

-- looking at total population vs vaccinations

select coD.continent, coD.location, coD.date, coD.population, coV.new_vaccinations,
sum(convert(int, coV.new_vaccinations)) over
(partition by coD.location order by coD.location, coD.date) rollingVaccinations
from CovidDeaths coD
join CovidVaccinations coV
on coD.location=coV.location and coD.date=coV.date
where coD.continent is not null
order by 2,3 

-- show rolling percentage of vaccinations compared to the population
--  option 1: create CTE for rollingVaccinations

--with popVSvac
--(continent, location, date, population, new_vaccinations, rollingVaccinations)
--as
--(select coD.continent, coD.location, coD.date, coD.population, coV.new_vaccinations,
--sum(convert(int, coV.new_vaccinations)) over
--(partition by coD.location order by coD.location, coD.date) rollingVaccinations
--from CovidDeaths coD
--join CovidVaccinations coV
--on coD.location=coV.location and coD.date=coV.date
--where coD.continent is not null
--)
--select *, (rollingVaccinations/population)*100 
--from popVSvac

-- show rolling percentage of vaccinations compared to the population
--  option 2: create temporary table for rollingVaccinations

drop table if exists #popVSvac
create table #popVSvac
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
 new_vaccinations numeric,
 rollingVaccinations numeric
 )
 insert into #popVSvac
select coD.continent, coD.location, coD.date, coD.population, coV.new_vaccinations,
sum(convert(int, coV.new_vaccinations)) over
(partition by coD.location order by coD.location, coD.date) rollingVaccinations
from CovidDeaths coD
join CovidVaccinations coV
on coD.location=coV.location and coD.date=coV.date
where coD.continent is not null

select *, (rollingVaccinations/population)*100 
from #popVSvac

-- create view for later vizualization

create view popVSvac as
select coD.continent, coD.location, coD.date, coD.population, coV.new_vaccinations,
sum(convert(int, coV.new_vaccinations)) over
(partition by coD.location order by coD.location, coD.date) rollingVaccinations
from CovidDeaths coD
join CovidVaccinations coV
on coD.location=coV.location and coD.date=coV.date
where coD.continent is not null
