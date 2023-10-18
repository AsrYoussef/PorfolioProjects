--select*
--From PortfolioProject..CovidDeaths
--order by 3,4

--select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

select Location , date, total_cases ,new_cases , total_deaths , Population 
From PortfolioProject .. CovidDeaths
order by 1,2

--Looking at Total Cases VS Total Deaths

select Location , date, total_cases  , total_deaths , (total_deaths/total_cases)*100 as DeathPercantage
From PortfolioProject .. CovidDeaths
where location like '%Egypt%'
order by 1,2

--looking at Total cases Vs Population

select Location , date, Population, total_cases   , (total_cases/population)*100 as CasesPercentage 
From PortfolioProject .. CovidDeaths
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population 
select Location , Population , MAX(total_cases) as HighestInfectionCount , MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject .. CovidDeaths
Group by Location,population 
order by PercentPopulationInfected desc

--showing Countries with Highest Death count per population 
select Location  , MAX(cast(total_deaths as int)) as TotalDEATHcount 
From PortfolioProject .. CovidDeaths
where continent is not null
Group by Location
order by TotalDEATHcount DESC

select continent  , MAX(cast(total_deaths as int)) as TotalDEATHcount 
From PortfolioProject .. CovidDeaths
where continent is not null
Group by continent 
order by TotalDEATHcount DESC


--Global Numbers

select   sum(new_cases) as TOTALCASES  , sum(cast(new_deaths as int)) as TOTALDEATHS , (sum(cast(new_deaths as int))/sum(new_cases))*100 as GlobalDeathPercantageRatio
From PortfolioProject .. CovidDeaths
--where location like '%Egypt%'
where continent is not null 
--group by date
order by 1,2


--merging data

select*
from PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
on dea.location = vac.location
and dea.date = vac.date



--Looking at Total Population vs Vaccinations

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
,
from PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3 
 
 --USE CTE
 with PopvsVac (continent,location ,date,population,New_Vaccinations ,PeopleVaccinated)
 as
 (
 select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
 SUM(CONVERT(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as PeopleVaccinated

from PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 
 )
 select* ,(PeopleVaccinated/population)*100
 from PopvsVac

 --Temp table
 Drop Table if exists #PercentPopulationVaccinated
 Create Table   #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 Population numeric,
 New_vaccinations numeric,
 PeopleVaccinated numeric
 )
 Insert into #PercentPopulationVaccinated
 select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3 
  select* ,(PeopleVaccinated/population)*100
 from #PercentPopulationVaccinated


 --Creating View to store data for later visualizations
 Create View PercentPopulationVaccinated as
 select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 

select*
from PercentPopulationVaccinated