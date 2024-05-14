use CovidProject;

-- COSTA RICA DATA

--% of deaths in costa rica
CREATE VIEW TrendCovidDeathsCostaRica AS
SELECT
	d.location, 
	d.date, 
	d.population,
	d.new_deaths,
	CASE
		WHEN d.total_deaths IS NULL THEN 0
		ELSE ROUND((d.total_deaths/d.population) * 100, 3)
	END AS "%_of_deaths"
FROM Deaths d
WHERE d.location = 'Costa Rica'

--Trend of cases during time
CREATE VIEW TrendCovidCasesCostaRica AS
SELECT 
	d.location, 
	d.date, 
	CASE	
		WHEN d.total_cases IS NULL THEN 0
		ELSE d.total_cases
	END as costarica_total_cases,
	d.new_cases
FROM Deaths d
WHERE d.location LIKE 'costa%';

--Day with the most new cases reported
SELECT TOP 1
	d.location, 
	d.date, 
	d.new_cases
FROM Deaths d
WHERE d.location LIKE 'costa%'
ORDER BY d.new_cases DESC;


-- GENERAL COUNTRIES DATA

--% of infection rate by country
CREATE VIEW InfectionRateByCountry AS
WITH InfectionRateByCountry 
AS
(SELECT
	d.continent,
	d.location, 
	d.population, 
	MAX(d.total_cases) max_cases,
	ROUND(MAX((d.total_cases/d.population)) * 100, 2) "percent_infection_rate"
FROM Deaths d
WHERE d.continent IS NOT NULL
GROUP BY d.location, d.population, d.continent)
SELECT 
	continent,
	location, 
	population, 
	max_cases, 
	percent_infection_rate,
	CASE 
		WHEN percent_infection_rate > 49 THEN 'HIGH RISK'
		WHEN percent_infection_rate > 29 AND percent_infection_rate < 50 THEN 'MEDIUM RISK'
		ELSE 'LOW RISK'
	END AS risk_classification
FROM InfectionRateByCountry


SELECT TOP 10
	d.location, 
	MAX(d.total_deaths) AS total_deaths_by_country,
	MAX(d.total_deaths/d.population)*100 AS "death_%"
FROM Deaths d 
WHERE d.continent IS NOT NULL
GROUP BY d.location
ORDER BY total_deaths_by_country DESC

SELECT 
	d.continent,
	MAX(total_deaths) max_deaths_per_continent
FROM Deaths d
WHERE d.continent IS NOT NULL
GROUP BY d.continent
ORDER BY max_deaths_per_continent DESC

--WORLD
SELECT 
	d.location,
	d.date,
	d.total_deaths
FROM Deaths d
WHERE d.location LIKE 'World'
ORDER BY date ASC

SELECT 
	d.location,
	d.date,
	d.new_cases
FROM Deaths d
WHERE d.location LIKE 'World'
ORDER BY d.date ASC

SELECT 
	d.location,
	d.date,
	d.total_deaths
FROM Deaths d
WHERE d.location LIKE 'World'
ORDER BY d.total_deaths DESC

--VACCINATIONS
SELECT TOP 5 *
FROM Deaths

SELECT TOP 5 * 
FROM Vaccines

SELECT *
FROM Deaths d
JOIN Vaccines v
	ON d.iso_code = v.iso_code AND d.date = v.date
ORDER BY d.location, d.date

CREATE VIEW VaccinationsPerCountry AS
SELECT 
	d.location, 
	d.date, 
	d.population, 
	CASE
		WHEN v.people_fully_vaccinated IS NULL THEN '0'
		ELSE v.people_fully_vaccinated
	END AS people_vaccinated,
	CASE 
		WHEN ROUND((v.people_fully_vaccinated/d.population) * 100, 2) IS NULL THEN 0
		ELSE ROUND((v.people_fully_vaccinated/d.population) * 100, 2)
	END AS "%_people vaccinated"
FROM Deaths d
JOIN Vaccines v
	ON d.iso_code = v.iso_code AND d.date = v.date
WHERE d.continent IS NOT NULL;