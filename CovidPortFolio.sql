
SELECT * From PortfolioProject..CovidDeath

Select * From PortfolioProject..CovidVaccinations


--showing the deathrate per per location
Select location, date, total_deaths,total_cases, round(cast(total_deaths as float)/total_cases,4) * 100 as DeathRatePercentage
from PortfolioProject..CovidDeath
where total_deaths is not null and total_cases is not null and not total_deaths >= total_cases and location = 'Asia'
order by date desc


--showing the top 10 Deaths of Covid 19 Virus per location
Select top 10 location, max(total_deaths) as TotalDeaths from PortfolioProject..CovidDeath
where not location = 'World' and not location = 'High income' and not location = 'Upper Middle Income' and not location = 'lower Middle Income'
group by location 
order by TotalDeaths desc


--showing the top 6 Deaths of Covid 19 Virus per continents
Select top 6 continent, max(total_deaths) as TotalDeaths from PortfolioProject..CovidDeath
where continent is not null
group by continent 
order by TotalDeaths desc

--showing the result of Rolling People Death in different locations
Select location, date, new_deaths as New_Deaths, total_deaths from PortfolioProject..CovidDeath
where not new_deaths = 0 and location = 'Philippines'
order by date asc

--showing continents with highest death count per population
select continent, max(total_deaths) as TotalCovidDeaths from PortfolioProject..CovidDeath
where continent is Null
group by continent
order by TotalCovidDeaths asc

--showing location with highest death count per population
select location, max(total_deaths) as TotalCovidDeaths from PortfolioProject..CovidDeath
group by location
order by TotalCovidDeaths desc


--showing the total vaccinations per continent
select cd.continent, max(cast(total_vaccinations as bigint)) as TotalVaccinations From PortfolioProject..CovidDeath cd
inner join PortfolioProject..CovidVaccinations cv On cv.continent = cd.continent
group by cd.continent
order by TotalVaccinations desc


--showing the total vaccinations per location
select cd.location, max(total_vaccinations) as TotalVaccinations From PortfolioProject..CovidDeath cd
inner join PortfolioProject..CovidVaccinations cv On cv.location = cd.location
where cd.continent is Not Null
group by cd.location
order by TotalVaccinations desc



--Using CTE
--Rolling People Vaccinated each day in Philippines in CTE table

with PopVsVac(continent, location, date,population, new_vaccinations,RollingPeopleVaccinated)
as
(Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(bigint,new_vaccinations)) 
	over (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeath cd
join PortfolioProject..CovidVaccinations cv 
	On cd.location = cv.location and cd.date = cv.date
	where cv.new_vaccinations is not null and cd.location = 'Philippines'
	--order by 2,3
)
Select *, Round(convert(float,RollingPeopleVaccinated/population),4)*100 as Percentage From PopVsVac



--Using Temp Table
--Rolling People Vaccinated 

Drop Table if Exists #PercentagePeopleVaccinated
Create Table #PercentagePeopleVaccinated(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population bigint,
People_Vaccinated bigint,
RollingPeopleVaccinated bigint
)

Insert Into #PercentagePeopleVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(bigint,new_vaccinations)) 
	over (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeath cd
join PortfolioProject..CovidVaccinations cv 
	On cd.location = cv.location and cd.date = cv.date
	where cv.new_vaccinations is not null

--SAVED in Temp Table

Select *, Round(convert(float,RollingPeopleVaccinated/Population),4)*100 as Percentage From #PercentagePeopleVaccinated
where location = 'Philippines'
order by 2,3


--Create Table For Visualization Later

Create View PercentPeopleVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(bigint,new_vaccinations)) 
	over (Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeath cd
join PortfolioProject..CovidVaccinations cv 
	On cd.location = cv.location and cd.date = cv.date
	where cv.new_vaccinations is not null