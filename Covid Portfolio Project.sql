Select * 
From portfolio..CovidDeaths
Where continent is not null
order by 3, 4

--Select * 
--	From portfolio..CovidVaccinations
--	order by 3, 4

-- Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolio..CovidDeaths
order by 1, 2



-- Looking at Total Cases vs Total Deaths
-- Shows the liklihood of dying if you get covid in your country (have to *100 for a percentage)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio..CovidDeaths
where location like '%states%'
order by 1, 2

-- Looking at the Total Cases Vs Population
--Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From portfolio..CovidDeaths
where location like '%states%'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HightestInfectionCount, Max((total_deaths/total_cases))*100 as PercentPopulationInfected
From portfolio..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
--Showing Countries with Hightest Death Count Per continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing Countries with Hightest Death Count Per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS  
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
--Group By date
order by 1, 2


Select * 
From portfolio..CovidVaccinations

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

--JOIN TABLES TOGETHER
--Looking at Total Polulation vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date  datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * FROM PercentPopulationVaccinated