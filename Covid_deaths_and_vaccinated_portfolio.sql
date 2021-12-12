


-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country 
select location,  date_, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from deaths_covid_22_11_2021
where location = 'Poland'
order by 1,2;


-- looking at total cases vs population
-- Shows what percentage population gain covid 
select location,  date_, total_cases, population, (total_cases/population)*100 as DeathPercentage
from deaths_covid_22_11_2021
where location = 'United States'
order by 1,2;


-- looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as Highest_Infection_Rate, MAX((total_cases/population))*100 as Highest_infectionPercentage
from deaths_covid_22_11_2021
group by location, population
order by Highest_infectionPercentage desc

-- showing countries with highest died

select location, population, MAX(total_deaths) as Highest_Died_Rate, MAX((total_deaths/population))*100 as Highest_DeathPercentage
from deaths_covid_22_11_2021
where CONTINENT  is not null -- remove aggregated data by continet
group by location, population
order by Highest_Died_Rate desc


-- Break down by continent
select location, MAX(total_deaths) as Highest_Died_Rate, MAX((total_deaths/population))*100 as Highest_DeathPercentage
from deaths_covid_22_11_2021

WHERE (continent  is null and ISO_CODE <> 'OWID_HIC' AND ISO_CODE <> 'OWID_LMC' AND ISO_CODE <> 'OWID_WRL'  AND ISO_CODE <> 'OWID_UMC'
AND ISO_CODE <> 'OWID_EUN' AND ISO_CODE <> 'OWID_LIC' AND ISO_CODE <> 'OWID_INT')
group by location
order by Highest_Died_Rate desc



-- Global numbers by date
select date_, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,(case when SUM(new_cases) <> 0 then SUM(new_deaths)/SUM(new_cases)*100 end) 
as DeathPercentage
from deaths_covid_22_11_2021
group by date_
order by 1

-- looking at total population vs vaccination
With PopvsVac (continent, location ,population, date_, new_vaccinations, RollingPeopleVaccinated)
as -- USE CTE
(
select dea.continent,dea.location, dea.population, dea.date_, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as number)) over (partition by dea.location order by dea.location, dea.date_) as RollingPeopleVaccinated
from deaths_covid_22_11_2021 dea
join  vaccination_covid_22_11_2021 vac
on dea.location = vac.location
and dea.date_ = vac.date_
where dea.continent is not null
--order by 1,2 desc
)
select continent, location ,population, date_, new_vaccinations, RollingPeopleVaccinated,(RollingPeopleVaccinated/population)*100 as PercentPopVaccinated
from PopvsVac
where location = 'Poland'
order by 4 


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent,dea.location, dea.population, dea.date_, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as number)) over (partition by dea.location order by dea.location, dea.date_) as RollingPeopleVaccinated
from deaths_covid_22_11_2021 dea
join  vaccination_covid_22_11_2021 vac
on dea.location = vac.location
and dea.date_ = vac.date_
where dea.continent is not null
order by 1,2 desc

select *
from PercentPopulationVaccinated
