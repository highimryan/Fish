use FISHSURVEY
go

--select all fish
select * from SURVEY.Fishes;

--select all species
select * from FISH.Species
order by ScientificName;


--select all families
select * from FISH.Families;

--select all trophics
select * from FISH.Trophics;

--select all batchcodes
select * from SURVEY.BatchCodes;

--select all Structuretypes
select * from SURVEY.StructureTypes;

--select all managements
select * from SURVEY.Managements;

--select all surveys
select * from SURVEY.Surveys;

--select all regions
select * from GEO.Regions;

--select all subregions
select * from GEO.SubRegions;

--select all studyareas
select * from GEO.StudyAreas;

--select 2012 surveys
select * 
    from SURVEY.Surveys as s
    where year(s.SurveyDate)=2012;

--select surveys that have fish length > 100
select s.SurveyIndex, s.SurveyDate,s.Latitude,s.Longitude,f.FishLength, f.FishCount
   from SURVEY.Surveys as s
   join SURVEY.Fishes as f
   on f.SurveyIndex = s.SurveyIndex
   where f.FishLength>100;