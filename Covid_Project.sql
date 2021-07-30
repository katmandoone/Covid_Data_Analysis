Select *
From PortfolioProject..covid_deaths$
order by 3,4

--Select *
--From PortfolioProject..covid_vaccinations$
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_deaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths$
Where location like '%states%'
order by 1,2

-- looking at total cases vs. population

Select location, date, total_cases, population, (total_cases/population)*100 as PctContracted
From PortfolioProject..covid_deaths$
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population
Select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as
	PercentPopulationInfected
From PortfolioProject..covid_deaths$
Group by Location, Population
order by PercentPopulationInfected desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths$
Where continent is null
Group by location
order by TotalDeathCount desc

-- showing countries with highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

-- showing continents with highest death count per populationk

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))
From PortfolioProject..covid_deaths$
where continent is not null
Group by date
Order by 1,2

-- looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingVaccinations,

FROM PortfolioProject..covid_deaths$ dea
JOIN PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingVaccinations
FROM PortfolioProject..covid_deaths$ dea
JOIN PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinations/population)*100 as RollingPctVac
From PopvsVac
order by location, date

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

DROP View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PctVac
From PercentPopulationVaccinated
Where location like '%states%'