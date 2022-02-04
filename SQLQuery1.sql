Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we're going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying of COVID in the US

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as FatalPercentage
From PortfolioProject..CovidDeaths
Where location like '%state%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

Select location, date, population, total_cases, (total_cases/population)*100 as PercentageInfected
From PortfolioProject..CovidDeaths
Where location like '%state%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Breaking down by continent
-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS by date

Select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as bigint)) as TotalNewDeaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as FatalPercentageWorld
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

-- Using CTE, looking at Total Population vs Vaccinations 

With PopVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccineCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccineCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingVaccineCount/Population)*100 as PercentageVaccinated
From PopVac

-- Creating View to store data for visualizations

Create View PercentageVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccineCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



Select *
From PercentageVaccinated