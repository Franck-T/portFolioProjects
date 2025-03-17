Select *
From portfolio.coviddeaths
Where continent is not null 
order by 3,4
Limit 100 ;

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolio.coviddeaths
Where continent is not null 
order by 1,2
Limit 100 ;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio.CovidDeaths
Where location like '%can%'
and continent is not null 
order by 1,2 
Limit 100 ;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From portfolio.CovidDeaths
order by 1,2
Limit 100 ;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
-- in your or a given country
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From portfolio.CovidDeaths
Where location like '%can%'
order by 1,2
Limit 100 ;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio.CovidDeaths
-- Where location like '%can%'
Group by Location, Population
order by PercentPopulationInfected desc ;


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as unsigned)) as TotalDeathCount
From portfolio.CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc ;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as unsigned)) as TotalDeathCount
From portfolio.CovidDeaths
Where continent is not null  -- and location like '%can%'
Group by continent
order by TotalDeathCount desc ;


-- GLOBAL NUMBERS

Select SUM(cast(population as unsigned)) as total_population, SUM(cast(new_cases as unsigned)) as total_new_cases, 
	   SUM(cast(new_deaths as unsigned)) as total_new_deaths, 
       -- (SUM(cast(new_cases as unsigned))/SUM(cast(population as unsigned)))*100 as NewCasesPercentage,
       (SUM(cast(new_deaths as unsigned))/SUM(cast(new_deaths as unsigned)))*100 as DeathsPercentage
From portfolio.CovidDeaths
where continent is not null 
-- Group By date
order by 1,2 ;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	  SUM(Cast(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated,
	  ((SUM(Cast(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date))/population)*100 as PercentageVaccinated
From portfolio.CovidDeaths dea
Join portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3 ;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) -- ,PercentageVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- ((SUM(Cast(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date))/population)*100 as PercentageVaccinated
From portfolio.CovidDeaths dea
Join portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac ;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
) ;

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From portfolio.CovidDeaths dea
Join portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3 ;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated ;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, ((SUM(Cast(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date))/population)*100 as PercentageVaccinated
From portfolio.CovidDeaths dea
Join portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;

Select * 
From PercentPopulationVaccinated ;


