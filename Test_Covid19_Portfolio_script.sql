--Covid19_Portfolio_Project cleaning and analysis code--
--Originally done by Alex Freberg--
--Open source data: https://ourworldindata.org/covid-deaths--
select *
from CovidPortfolioProject..CovidDeaths
order by 3,4

--select *
--from CovidPortfolioProject..CovidVaccinations
--order by 3,4

-- Data to be used
select Location, date, total_cases, new_cases, total_deaths, population
from CovidPortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percent_Died 
from CovidPortfolioProject..CovidDeaths
where location like '%trinidad%'
order by 1,2


-- looking at total cases vs population
-- Percent of people who contracted Covid
select Location, date, population, total_cases, (total_cases/population)*100 as Covid_Contracted_Percent 
from CovidPortfolioProject..CovidDeaths
where location like '%trinidad%'
order by 1,2

--Highest covid infections per country
select Location, population, max(total_cases) as Highest_Infection_Count,
max((total_cases/population))*100 as Covid_Infected_Percent
from CovidPortfolioProject..CovidDeaths
group by location, population
order by Covid_Infected_Percent desc

--Highest Death Count per Country
select Location, max(cast(total_deaths as int)) as Total_Death_Count
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc

--Highest per continent
select continent, max(cast(total_deaths as int)) as Total_Death_Count
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc

select location, max(cast(total_deaths as int)) as Total_Death_Count
from CovidPortfolioProject..CovidDeaths
where continent is null
group by location
order by Total_Death_Count desc

--Global Numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Percent_Died 
from CovidPortfolioProject..CovidDeaths
--where location like '%trinidad%'
where continent is not null
group by date 
order by 1,2


--Total Population vs Total Vaccinations
select de.continent, de.location, de.date, de.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over
(partition by de.location order by de.location, de.date) as People_Being_Vaccinated
from CovidPortfolioProject..CovidDeaths de
join CovidPortfolioProject..CovidVaccinations vac
on de.location = vac.location
and de.date = vac.date
where de.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, population, new_vaccinations, People_Being_Vaccinated)
as
(
select de.continent, de.location, de.date, de.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(partition by de.location order by de.location, de.date) as People_Being_Vaccinated
from CovidPortfolioProject..CovidDeaths de
join CovidPortfolioProject..CovidVaccinations vac
on de.location = vac.location
and de.date = vac.date
where de.continent is not null
--order by 2,3
)
Select *, (People_Being_Vaccinated/population)*100
from PopvsVac


--TEMP TABLE
drop table if exists #Percent_Population_Vaccinated
create table #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
People_Being_Vaccinated numeric
)

insert into #Percent_Population_Vaccinated
select de.continent, de.location, de.date, de.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(partition by de.location order by de.location, de.date) as People_Being_Vaccinated
from CovidPortfolioProject..CovidDeaths de
join CovidPortfolioProject..CovidVaccinations vac
on de.location = vac.location
and de.date = vac.date
where de.continent is not null
--order by 2,3

Select *, (People_Being_Vaccinated/population)*100
from #Percent_Population_Vaccinated

--View creation for later visualization

create view Percent_Population_Vaccinated as
select de.continent, de.location, de.date, de.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over
(partition by de.location order by de.location, de.date) as People_Being_Vaccinated
from CovidPortfolioProject..CovidDeaths de
join CovidPortfolioProject..CovidVaccinations vac
on de.location = vac.location
and de.date = vac.date
where de.continent is not null
--order by 2,3

select * 
from Percent_Population_Vaccinated
