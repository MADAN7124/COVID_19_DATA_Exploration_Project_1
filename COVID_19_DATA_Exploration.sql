Select *
From Project_Covid_1..Deaths
Where continent is not null
Order by 3,4

Select *
From Project_Covid_1..Vaccinations
Where continent is not null
Order by 3,4

-- Select the data that we are going to using

Select location, date, total_cases, new_cases, total_deaths, population
From Project_Covid_1..Deaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project_Covid_1..Deaths
Where location like '%India%'
Where continent is not null
Order by 1,2

-- Total cases vs Population
-- Shows what percentage got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From Project_Covid_1..Deaths
--Where location like '%states%'
Where continent is not null
Order by 1,2

-- Looking at countries at highest infection rate compared to population

Select location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From Project_Covid_1..Deaths
--Where location like '%states%'
Where continent is not null
Group by location,  population
Order by PercentagePopulationInfected desc

-- Showing countries with highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Project_Covid_1..Deaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Lets break down the things by continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Project_Covid_1..Deaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Showing continent with highest death count per populations

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Project_Covid_1..Deaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers for total cases per toal death 
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project_Covid_1..Deaths
--Where location like '%India%'
Where continent is not null
Group by date
Order by 1,2

-- Global Numbers for total cases per toal death percentage
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project_Covid_1..Deaths
--Where location like '%India%'
Where continent is not null
--Group by date
Order by 1,2


-- Looking at Total population vs Total vaccinations.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Project_Covid_1..Deaths dea
Join Project_Covid_1..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using CTE

With PopVsVacc (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Project_Covid_1..Deaths dea
Join Project_Covid_1..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 
From PopVsVacc

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project_Covid_1..Deaths dea
Join Project_Covid_1..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating a view for further Visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project_Covid_1..Deaths dea
Join Project_Covid_1..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated

