Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..Covidvaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioProject..CovidDeaths
order by 1,2

--exploring Total cases vs Total Deaths
--in Egypt

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Egypt%'
order by 1,2

-- Exploring Total cases vs Population

Select Location, date, population, total_cases,  (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths
Where location like '%Egypt%'
order by 1,2


--Exploring countries with Highest Infection rate compared to population

Select Location, population, MAX (total_cases) as HighestInfectionCount,  Max ((total_cases/population))*100 as CasesPopulationPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
Group by Location, population
order by CasesPopulationPercentage desc

--Showing Countries with highest death count per population

Select Location, MAX (cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
where continent is not null
Group by Location
order by TotalDeathsCount desc

--Showing continents with the highest death count per population

Select Location, MAX (cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
where continent is null
Group by Location
order by TotalDeathsCount desc

--Global Numbers

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Egypt%'
where continent is not null
--Group by date
order by 1,2 

--Looking at Total Population vs Vaccinations


--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
	--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select*
From PercentPopulationVaccinated
