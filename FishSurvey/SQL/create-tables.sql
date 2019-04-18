-- 1. Create an empty database called FISHSURVEY

USE master;

-- Drop previous database
DROP DATABASE IF EXISTS FISHSURVEY;

-- If database could not be created due to open connections, abort
IF @@ERROR = 3702 
   RAISERROR(N'Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Create database
CREATE DATABASE FISHSURVEY;
GO

USE FISHSURVEY;
GO

---------------------------------------------------------------------
-- Create Schemas
---------------------------------------------------------------------
CREATE SCHEMA FISH AUTHORIZATION dbo
GO
CREATE SCHEMA SURVEY AUTHORIZATION dbo
GO
CREATE SCHEMA GEO AUTHORIZATION dbo
GO

---------------------------------------------------------------------
-- Create Tables
---------------------------------------------------------------------

-- Create table GEO.Regions

DROP TABLE IF EXISTS GEO.Regions
GO

CREATE TABLE GEO.Regions
(
    RegionId int          NOT NULL IDENTITY PRIMARY KEY,
    RegionName   nvarchar(50) NOT NULL UNIQUE,
);
GO

-- Create table GEO.SubRegion

DROP TABLE IF EXISTS GEO.SubRegions
GO

CREATE TABLE GEO.SubRegions
(
    SubRegionId int          NOT NULL IDENTITY PRIMARY KEY,
    SubRegionName   nvarchar(50) NOT NULL UNIQUE,
    RegionId    int          NOT NULL,
    CONSTRAINT FK_GEO_Regions FOREIGN KEY(RegionId)
	  REFERENCES GEO.Regions(RegionId)
);
GO


-- Create table GEO.StudyAreas

DROP TABLE IF EXISTS GEO.StudyAreas
GO

CREATE TABLE GEO.StudyAreas
(
    StudyAreaId int          NOT NULL IDENTITY PRIMARY KEY,
    StudyAreaName   nvarchar(50) NOT NULL UNIQUE,
    SubRegionId int          NOT NULL,
    CONSTRAINT FK_GEO_SubRegions FOREIGN KEY(SubRegionId)
	  REFERENCES GEO.SubRegions(SubRegionId)
);
GO




-- Create table SURVEY.BatchCodes

DROP TABLE IF EXISTS SURVEY.BatchCodes
GO

CREATE TABLE SURVEY.BatchCodes
(
    BatchCodeId int          NOT NULL IDENTITY PRIMARY KEY,
    BatchCodeDescription   nvarchar(50) NOT NULL UNIQUE,
    SurveyYear  int         NOT NULL
);
GO

-- Create table SURVEY.managements

DROP TABLE IF EXISTS SURVEY.Managements
GO

CREATE TABLE SURVEY.Managements
(
    ManagementId   int          NOT NULL IDENTITY PRIMARY KEY,
    ManagementName nvarchar(50) NOT NULL UNIQUE,
);
GO

-- Create table SURVEY.structuretypes

DROP TABLE IF EXISTS SURVEY.StructureTypes
GO

CREATE TABLE SURVEY.StructureTypes
(
    StructureTypeId                 int          NOT NULL IDENTITY PRIMARY KEY,
    StructureTypeDescription        nvarchar(50) NULL UNIQUE,

);
GO

-- Create table FISH.families

DROP TABLE IF EXISTS FISH.Families
GO

CREATE TABLE FISH.Families
(
    FamilyId   int          NOT NULL IDENTITY PRIMARY KEY,
    FamilyName     nvarchar(50) NOT NULL UNIQUE,
);
GO

-- Create table FISH.Trophics

DROP TABLE IF EXISTS FISH.Trophics
GO

CREATE TABLE FISH.Trophics
(
    TrophicId      int          NOT NULL IDENTITY PRIMARY KEY,
    TrophicLevel        nvarchar(5)  NOT NULL UNIQUE
);
GO

-- Create table FISH.species

DROP TABLE IF EXISTS FISH.Species
GO

CREATE TABLE FISH.Species
(
    SpeciesId      int          NOT NULL IDENTITY PRIMARY KEY,
    FamilyId       int          NOT NULL,
    TrophicId      int          NOT NULL,
    CommonName     nvarchar(50) NOT NULL UNIQUE,
    ScientificName nvarchar(50) NOT NULL UNIQUE,
    CONSTRAINT FK_FISH_Families FOREIGN KEY(FamilyId)
	  REFERENCES FISH.Families(FamilyId),
    CONSTRAINT FK_FISH_Trophics FOREIGN KEY(TrophicId)
	  REFERENCES FISH.Trophics(TrophicId)
);
GO



-- Create table SURVEY.surveys

DROP TABLE IF EXISTS SURVEY.Surveys
GO

CREATE TABLE SURVEY.Surveys
(
    SurveyIndex  int  NOT NULL PRIMARY KEY,
    Latitude     decimal(18,5) NOT NULL,
    Longitude   decimal(18,5) NOT NULL,
    SurveyDate   date NOT NULL,
    StudyAreaId     int  NOT NULL,
    ManagementId int  NOT NULL,
    BatchCodeId  int  NOT NULL,
    CONSTRAINT FK_GEO_StudyAreas FOREIGN KEY(StudyAreaId)
      REFERENCES GEO.StudyAreas (StudyAreaId),
    CONSTRAINT FK_SURVEY_Managements FOREIGN KEY(ManagementId)
      REFERENCES SURVEY.Managements (ManagementId),
    CONSTRAINT FK_SURVEY_BatchCodes FOREIGN KEY(BatchCodeId)
	  REFERENCES SURVEY.BatchCodes (BatchCodeId)
);
GO

-- Create table SURVEY.Fishes

DROP TABLE IF EXISTS SURVEY.Fishes
GO

CREATE TABLE SURVEY.Fishes
(
    FishId          int        NOT NULL IDENTITY PRIMARY KEY,
    StructureTypeId int        NOT NULL,
    FishLength      decimal(18,2) NOT NULL,
    FishCount       int        NOT NULL,
    SpeciesId       int        NOT NULL,
    SurveyIndex     int        NOT NULL

    CONSTRAINT FK_SURVEY_STRUCTURETYPEs FOREIGN KEY(StructureTypeId)
	  REFERENCES SURVEY.StructureTypes(StructureTypeId),
    CONSTRAINT FK_FISH_SPECIES FOREIGN KEY(SpeciesId)
	  REFERENCES FISH.Species(SpeciesId),
    CONSTRAINT FK_SURVEY_Surveys FOREIGN KEY(SurveyIndex)
	  REFERENCES SURVEY.Surveys (SurveyIndex)

);
GO