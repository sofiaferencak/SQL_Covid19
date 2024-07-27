SELECT *
	FROM PortfolioProjects..Covid19
	ORDER BY 3,4

--Select data needed
SELECT location, date, total_cases, total_deaths, population
	FROM PortfolioProjects..Covid19
	ORDER BY 1,2

--Calculate Total Cases vs Total Deaths percentage
--Shows how likelihood of dying if someone gets Covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
	FROM PortfolioProjects..Covid19
	ORDER BY 1,2

--Calculate Total Cases vs Total Deaths percentage
--Shows how likelihood of dying if someone gets Covid in Unitated States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
	FROM PortfolioProjects..Covid19
	WHERE location like '%states%'
	ORDER BY 1,2

--Calculate Total Cases vs Population percentage
--Shows porcentage of population that got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PositiveCasesPercentage
	FROM PortfolioProjects..Covid19
	ORDER BY 1,2

--Countries with highest infection rate
SELECT location, population, MAX(total_cases) AS HighestInfection, MAX((total_cases/population))*100 AS PositiveCasesPercentage
	FROM PortfolioProjects..Covid19
	GROUP BY location, population
	ORDER BY PositiveCasesPercentage DESC

--Countries with highest death rate
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeath
	FROM PortfolioProjects..Covid19
	--We need to take to continent grouping thats on the table out so it just countries
	--Viewing the data we can see where continent is null that is a grouping of countries, for example Asia
	WHERE continent is not null
	GROUP BY location
	ORDER BY TotalDeath DESC

--Cotinents sorted by highest death rate (Using table grouping)
SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeath
	FROM PortfolioProjects..Covid19
	--We can do this by using the continent grouping thats on the table
	--Viewing the data we can see where continent is null that is a grouping of countries, for example Asia
	--And we need to take out the incomes grouping the table has
	WHERE (continent is null) AND NOT location like '%income%'
	GROUP BY location, population
	ORDER BY TotalDeath DESC

--Cotinents sorted by highest death rate (Grouping with SQL)
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeath
	FROM PortfolioProjects..Covid19
	--We need to take to continent grouping thats on the table out so it just countries
	--Viewing the data we can see where continent is null that is a grouping of countries, for example Asia
	--And we need to take out the incomes grouping the table has
	WHERE (continent is not null) AND NOT location like '%income%'
	GROUP BY continent
	ORDER BY TotalDeath DESC

--Calculate Worlwide (GLOBAL NUMBERS)
--Death Percentage Worldwide, chances of dying if someone gets Covid in the world with overall data
SELECT SUM(total_cases) AS GlobalCases, SUM(total_deaths) AS GlobalDeaths, SUM(total_deaths)/SUM(total_cases)*100 AS GlobalPercentage
	FROM PortfolioProjects..Covid19
	WHERE continent is not null
	ORDER BY 1,2
--Death Percentage Worldwide, chances of dying if someone gets Covid in the world, depending the date
SELECT date, SUM(total_cases) AS GlobalCases, SUM(total_deaths) AS GlobalDeaths, SUM(total_deaths)/SUM(total_cases)*100 AS GlobalPercentage
	FROM PortfolioProjects..Covid19
	GROUP BY date
	ORDER BY 1,2

--Looking at Total Population vs Vaccinations
SELECT continent, location, date, population, new_vaccinations, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by location Order by location, date) AS SumPeopleVaccinated
	FROM PortfolioProjects..Covid19 
	WHERE continent is not null
	ORDER BY 2,3

--In order to use that new variable we new to do something first, there's 2 ways of using it
--1º method: use CTE
WITH PopulationVsVaccination (continent, location, date, population, new_vaccinations, SumPeopleVaccinated)
AS(
	SELECT continent, location, date, population, new_vaccinations, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by location Order by location, date) AS SumPeopleVaccinated
	FROM PortfolioProjects..Covid19 
	WHERE continent is not null
)
SELECT *, (SumPeopleVaccinated/population)*100 AS PorcentagePopulationVaccinated
FROM PopulationVsVaccination
--2º method: temp table
DROP TABLE if exists #PopulationVsVaccination
	--You need to include that so if it was used before it'll be drop and create a new one
CREATE TABLE #PopulationVsVaccination(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	SumPeopleVaccinated numeric
)
INSERT INTO #PopulationVsVaccination
	SELECT continent, location, date, population, new_vaccinations, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by location Order by location, date) AS SumPeopleVaccinated
	FROM PortfolioProjects..Covid19 
	WHERE continent is not null
SELECT *, (SumPeopleVaccinated/population)*100 AS PorcentagePopulationVaccinated
FROM #PopulationVsVaccination

--Create View to store data for later visualization
CREATE VIEW PorcentagePopulationVaccinated AS
SELECT continent, location, date, population, new_vaccinations, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by location Order by location, date) AS SumPeopleVaccinated
	FROM PortfolioProjects..Covid19 
	WHERE continent is not null

--Whenever you run a querie you can right click the corner of the resulting table and you can save as a file in your computer
--For example I did that saving the files as csv to later use in Tableau
