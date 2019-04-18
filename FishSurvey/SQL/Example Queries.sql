USE FISHSURVEY
GO

--Chapter 2

--Elements of the SELECT statement
--filters surveys where study area is east bank (1), group by year at years when survey count>40
SELECT
    year(s.SurveyDate) AS surveyyear,
    count(*) AS numsurveys
FROM
    SURVEY.Surveys AS s
WHERE s.StudyAreaId=1
GROUP BY year(s.SurveyDate)
HAVING count(*) > 40
ORDER BY surveyyear

--Predicates and operators
--select fish species where scientific name ends with 'atus'
SELECT
    CommonName,
    ScientificName
FROM
    FISH.Species
WHERE ScientificName LIKE N'%atus';

--CASE expressions
SELECT
    CommonName,
    ScientificName,
    CASE
    WHEN CommonName LIKE '%yellow%'   THEN 'yellow'
    WHEN CommonName LIKE '%black%'    THEN 'black'
    WHEN CommonName LIKE '%red%'      THEN 'red'
    WHEN CommonName LIKE '%blue%'     THEN 'blue'
    WHEN CommonName LIKE '%brown%'    THEN 'brown'
    WHEN CommonName LIKE '%orange%'   THEN 'orange'
    ELSE 'unknown'
  END AS Color
FROM
    FISH.Species
ORDER BY Color DESC

--nulls
--don't give me shark
SELECT
    CommonName,
    ScientificName
FROM
    FISH.Species
WHERE CommonName <> N'%shark%'

--working with character data
--proof all family ends with idae
SELECT
    DISTINCT
    RIGHT(FamilyName,4)
FROM
    FISH.Families

--working with date and time data
--select all the summer survey(june, july, august)
SELECT
    *
FROM
    SURVEY.Surveys
WHERE month(SurveyDate)=6 OR month(SurveyDate)=7 OR month(SurveyDate)=8
ORDER BY SurveyDate

--Querying metadata
SELECT
    SCHEMA_NAME(schema_id) AS table_schema_name,
    name AS table_name
FROM
    sys.tables


------------------------------------------------------------------------

--Chapter 3 Joins
--Cross joins
SELECT
    st.StructureTypeDescription,
    s.SurveyIndex
FROM
    SURVEY.StructureTypes AS st
    CROSS JOIN SURVEY.Surveys AS s

--inner joins
SELECT
    s.SurveyIndex,
    s.SurveyDate ,
    sa.StudyAreaName
FROM
    SURVEY.Surveys AS s
    INNER JOIN GEO.StudyAreas AS sa
    ON s.StudyAreaId = sa.StudyAreaId
ORDER BY SurveyIndex

--More join examples
SELECT
    s.SurveyIndex,
    s.SurveyDate ,
    sa.StudyAreaName,
    sr.SubRegionName,
    r.RegionName
FROM
    SURVEY.Surveys AS s
    INNER JOIN GEO.StudyAreas AS sa
    ON s.StudyAreaId = sa.StudyAreaId
    INNER JOIN GEO.SubRegions AS sr
    ON sa.SubRegionId = sr.SubRegionId
    INNER JOIN GEO.Regions AS r
    ON sr.RegionId = r.RegionId
ORDER BY SurveyIndex

--Outer joins
SELECT
    *
FROM
    FISH.Families AS f
    RIGHT OUTER JOIN FISH.Species AS s
    ON f.FamilyId = s.FamilyId
WHERE s.CommonName LIKE N'%hogfish%'

---------------------------------------------------------------------------------------
--Chapter 4 Subqueries 
--Self-contained subqueries
--select fish species where family name starts with holo
SELECT
    CommonName,
    ScientificName
FROM
    Fish.Species
WHERE FamilyId IN
  ( SELECT
    FamilyId
FROM
    FISH.Families
WHERE FamilyName LIKE N'holo%');

--correlated subqueries
--select species that have top 4 count from any single survey
SELECT
    CommonName,
    ScientificName,
    f.FishCount,
    f.SurveyIndex
FROM
    fish.Species AS s
    JOIN SURVEY.fishes AS f
    ON s.SpeciesId = f.SpeciesId
WHERE f.FishCount IN 
     (
	  SELECT
    TOP(4)
    FishCount
FROM
    survey.fishes
ORDER BY FishCount DESC
     )
ORDER BY fishcount DESC;

---------------------------------------------------------------------------------

--Chapter 5 Table Expressions
--Derived tables
--give each species with their avgfishlength, sum of all counts and order by fishlength
SELECT
    s.CommonName,
    s.ScientificName,
    avgfishlength,
    sumfishcount
FROM
    (SELECT
        f.SpeciesId,
        avg(fishlength) AS avgfishlength,
        sum(fishcount) AS sumfishcount
    FROM
        SURVEY.Fishes AS f
    GROUP BY f.SpeciesId) AS fishstat
    JOIN fish.Species AS s
    ON fishstat.SpeciesId = s.SpeciesId
ORDER BY avgfishlength DESC

--Common table expressions
--select family name, common name, avg fishlength, most rare fishes first then common name
WITH
    fishstat
    AS
    (
        SELECT
            f.SpeciesId,
            avg(fishlength) AS avgfishlength,
            sum(fishcount) AS sumfishcount
        FROM
            SURVEY.Fishes AS f
        GROUP BY f.SpeciesId
    )
SELECT
    fml.FamilyName,
    s.CommonName,
    avgfishlength,
    sumfishcount
FROM
    fishstat
    JOIN fish.Species AS s
    ON fishstat.SpeciesId = s.SpeciesId
    JOIN fish.Families AS fml
    ON s.FamilyId=fml.FamilyId
ORDER BY sumfishcount, CommonName

--views
--create a sharks view
DROP VIEW IF EXISTS fish.sharks
GO
CREATE VIEW fish.sharks
AS

    SELECT
        SpeciesId,
        FamilyName,
        TrophicLevel,
        CommonName,
        ScientificName
    FROM
        fish.Species AS s
        JOIN fish.Families AS fml
        ON s.FamilyId=fml.FamilyId
        JOIN fish.Trophics AS t
        ON t.TrophicId=s.TrophicId
    WHERE CommonName LIKE N'%shark%';
GO

SELECT
    *
FROM
    fish.sharks;

--inline table-valued functions
--select fish longer than @length and there total count

DROP FUNCTION IF EXISTS fish.longerthan;
GO
CREATE FUNCTION fish.longerthan
  (@length AS decimal) returns TABLE
AS
RETURN
   WITH
    fishl
    AS
    (
        SELECT
            f.SpeciesId,
            avg(fishlength) AS avgfishlength,
            sum(fishcount) AS sumfishcount
        FROM
            SURVEY.Fishes AS f
        GROUP BY f.SpeciesId
    )
   SELECT
    fishl.SpeciesId,
    avgfishlength,
    sumfishcount,
    s.CommonName,
    s.ScientificName,
    fml.FamilyName,
    t.TrophicLevel
FROM
    fishl
    JOIN fish.Species AS s
    ON fishl.SpeciesId = s.SpeciesId
    JOIN fish.Families AS fml
    ON s.FamilyId=fml.FamilyId
    JOIN fish.Trophics AS t
    ON t.TrophicId=s.TrophicId
WHERE avgfishlength >= @length
GO

--find fishes longer than 100 inch
SELECT
    *
FROM
    fish.longerthan(100)


--the APPLY operator

-------------------------------------------------------------------------
--Chap 6 set operators 

