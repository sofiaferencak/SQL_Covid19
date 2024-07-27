-- 1. 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..Covid19
where continent is not null 
order by 1,2


-- 2. 

-- I take some out as they are not included in the previous query and I want to stay consistent
-- European Union is part of Europe
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProjects..Covid19
Where continent is null 
and location not in ('World', 'European Union', 'International')
and location not like '%income%'
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..Covid19
--I took the nulls out because there's some names that are not repeated but they are the same, like united kingdom and england, and only one has the data
where total_cases is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.

Select Location, Population, date, SUM(total_cases) as HighestInfectionCount,  (SUM(total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProjects..Covid19
WHERE total_cases IS NOT NULL
Group by Location, Population, date
order by PercentPopulationInfected desc

--When using this data in Tableau the csv file is recognized with the percentage as string
--So you need a new calculated field with this:
	--IFNULL(FLOAT(REPLACE([field], ",", ".")), 0)


-- 5

--1º method: use CTE
With PopulationVsVaccination (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select continent, location, date, population, new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by Location Order by location, Date) as PeopleVaccinated
From PortfolioProjects..Covid19
Where continent is null 
AND Location not in ('World', 'European Union', 'International')
AND location not like '%income%'
)
Select location, date, population, new_vaccinations, PeopleVaccinated, (PeopleVaccinated/Population)*100 as PercentPeopleVaccinated
	From PopulationVsVaccination
	--I took the nulls out because this data starts in 2020 but vaccines started later, so just to make the graph more clean
	WHERE PeopleVaccinated is not null

--2º method: temp table
DROP TABLE if exists #PopulationVsVaccination
	--You need to include that so if it was used before it'll be drop and create a new one
CREATE TABLE #PopulationVsVaccination(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	PeopleVaccinated numeric
)
INSERT INTO #PopulationVsVaccination
	Select continent, location, date, population, new_vaccinations
	, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by Location Order by location, Date) as PeopleVaccinated
	From PortfolioProjects..Covid19
	Where continent is null 
	AND Location not in ('World', 'European Union', 'International')
	AND location not like '%income%'
SELECT location, date, population, new_vaccinations, PeopleVaccinated, (PeopleVaccinated/population)*100 AS PorcentagePopulationVaccinated
	FROM #PopulationVsVaccination
	--I took the nulls out because this data starts in 2020 but vaccines started later, so just to make the graph more clean
	WHERE PeopleVaccinated is not null


--6

--Since we have number of people fully vaccinated we can just use that, instead of the methods above
Select location, date, population, people_fully_vaccinated, (people_fully_vaccinated/Population)*100 as PercentPeopleVaccinated
	From PortfolioProjects..Covid19
	--I took the nulls out because this data starts in 2020 but vaccines started later, so just to make the graph more clean
	Where people_fully_vaccinated is not null and continent is null 
AND Location not in ('World', 'European Union', 'International')
AND location not like '%income%'
order by 5
