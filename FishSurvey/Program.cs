using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FishSurvey;

namespace FishSurvey
{
    public class RawDataRow
    {
        public string Region;
        public string SubRegion;
        public string StudyArea;
        public int SurveyYear;
        public string BatchCode;
        public int SurveyIndex;
        public DateTime SurveyDate;
        public decimal Latitude;
        public decimal Longitude;
        public string Management;
        public string StructureType;
        public string Family;
        public string ScientificName;
        public string CommonName;
        public string Trophic;
        public decimal FishLength;
        public int FishCount;


        public static RawDataRow FromCsv(string csvLine)
        {
            string[] values = csvLine.Split(',');
            RawDataRow row = new RawDataRow();
            row.Region = values[0];
            row.SubRegion = values[1];
            row.StudyArea = values[2];
            row.SurveyYear = Convert.ToInt16(values[3]);
            row.BatchCode = values[4];
            row.SurveyIndex = Convert.ToInt16(values[5]);
            row.SurveyDate = Convert.ToDateTime(values[6]);
            row.Latitude = Convert.ToDecimal(values[7]);
            row.Longitude = Convert.ToDecimal(values[8]);
            row.Management = values[9];
            row.StructureType = values[10];
            row.Family = values[11];
            row.ScientificName = values[12];
            row.CommonName = values[13];
            row.Trophic = values[14];
            row.FishLength = Convert.ToDecimal(values[15]);
            row.FishCount = Convert.ToInt16(values[16]);
            return row;
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            //before compile, make sure database is built with up-to-date create-table.sql 
            //and use EF to connect to your C# project
            //change the data source 1-data folder path to yours if this doesn't work
            string pathWithEnv = @"%USERPROFILE%\team4\external\survey\1-data\";
            var DataFolder = Environment.ExpandEnvironmentVariables(pathWithEnv);
            Console.WriteLine($"Your data folder is set at {DataFolder}.");

            //get a list of sub folders
            var paths = Directory.GetDirectories(DataFolder).Select(x => x += @"\Fish Dump.csv").ToArray();
            foreach (var pathname in paths)
            {
                Console.WriteLine(pathname);
            }

            //process each file
            foreach (var pathname in paths)
            {
                ParseFile(pathname);
                Console.WriteLine($"{pathname} added to database.");
            }
        }

        private static void ParseFile(string pathname)
        {
            List<RawDataRow> allrows = File.ReadAllLines(pathname)
                                          .Skip(1)
                                          .Select(v => RawDataRow.FromCsv(v))
                                          .ToList();
            // RawDataRow row1 = allrows[0];
            using (var db = new FISHSURVEYEntities())
            {
                foreach (var row in allrows)
                {
                    AddRowToDB(row, db);
                }
            }
        }

        private static void AddRowToDB(RawDataRow row1, FISHSURVEYEntities db)
        {
            //Fill GEO Schema

            //add new region
            if (!db.Regions.Any(x => x.RegionName == row1.Region))
            {
                var region1 = new Region { RegionName = row1.Region };
                db.Regions.Add(region1);
                Console.WriteLine($"Region {row1.Region}  added");
                db.SaveChanges();
            }


            //insert subregion

            if (!db.SubRegions.Any(x => x.SubRegionName == row1.SubRegion))
            {
                var subregion1 = new SubRegion { SubRegionName = row1.SubRegion, RegionId = db.Regions.Single(x => x.RegionName == row1.Region).RegionId };
                db.SubRegions.Add(subregion1);
                Console.WriteLine($"SubRegion {row1.SubRegion}  added");
                db.SaveChanges();
            }

            //insert study area

            if (!db.StudyAreas.Any(x => x.StudyAreaName == row1.StudyArea))
            {
                var studyarea1 = new StudyArea { StudyAreaName = row1.StudyArea, SubRegionId = db.SubRegions.Single(x => x.SubRegionName == row1.SubRegion).SubRegionId };
                db.StudyAreas.Add(studyarea1);
                Console.WriteLine($"StudyArea {row1.StudyArea}  added");
                db.SaveChanges();
            }


            //add batchcode
            if (!db.BatchCodes.Any(x => x.BatchCodeDescription == row1.BatchCode))
            {
                var batchcode1 = new BatchCode { BatchCodeDescription = row1.BatchCode, SurveyYear = row1.SurveyYear };
                db.BatchCodes.Add(batchcode1);
                Console.WriteLine($"BatchCode {row1.BatchCode}  added");
                db.SaveChanges();
            }

            //add Management
            if (!db.Managements.Any(x => x.ManagementName == row1.Management))
            {
                var management1 = new Management { ManagementName = row1.Management };
                db.Managements.Add(management1);
                Console.WriteLine($"Management {row1.Management}  added");
                db.SaveChanges();
            }


            //add Survey
            if (!db.Surveys.Any(x => x.SurveyIndex == row1.SurveyIndex))
            {
                var survey = new Survey
                {
                    SurveyIndex = row1.SurveyIndex,
                    Latitude = (decimal)row1.Latitude,
                    Longitude = (decimal)row1.Longitude,
                    SurveyDate = row1.SurveyDate,
                    StudyAreaId = db.StudyAreas.Single(x => x.StudyAreaName == row1.StudyArea).StudyAreaId,
                    ManagementId = db.Managements.Single(x => x.ManagementName == row1.Management).ManagementId,
                    BatchCodeId = db.BatchCodes.Single(x => x.BatchCodeDescription == row1.BatchCode).BatchCodeId
                };
                db.Surveys.Add(survey);
                Console.WriteLine($"Survey {row1.SurveyIndex}  added");
                db.SaveChanges();
            }

            //insert trophic
            if (!db.Trophics.Any(x => x.TrophicLevel == row1.Trophic))
            {
                var trophic = new Trophic { TrophicLevel = row1.Trophic };
                db.Trophics.Add(trophic);
                Console.WriteLine($"Trophoc {row1.Trophic} added");
                db.SaveChanges();
            }

            //insert family 
            if (!db.Families.Any(x => x.FamilyName == row1.Family))
            {
                var family = new Family { FamilyName = row1.Family };
                db.Families.Add(family);
                Console.WriteLine($"Family {row1.Family}  added");
                db.SaveChanges();
            }

            //insert species
            if (!db.Species.Any(x => x.ScientificName == row1.ScientificName))
            {
                var common = new Species
                {
                    CommonName = row1.CommonName,
                    ScientificName = row1.ScientificName,
                    FamilyId = db.Families.Single(x => x.FamilyName == row1.Family).FamilyId,
                    TrophicId = db.Trophics.Single(x => x.TrophicLevel == row1.Trophic).TrophicId
                };

                db.Species.Add(common);
                db.SaveChanges();
                Console.WriteLine($"Species {row1.ScientificName}  added");
            }

            //insert structure
            if (!db.StructureTypes.Any(x => x.StructureTypeDescription == row1.StructureType))
            {
                var structuretype = new StructureType
                {
                    StructureTypeDescription = row1.StructureType.Trim() //trim the extra space at the end
                };
                db.StructureTypes.Add(structuretype);
                db.SaveChanges();
                Console.WriteLine($"StructureType {row1.StructureType}  added");
            }



            //insert Fish
            var fish = new Fish
            {
                StructureTypeId = db.StructureTypes.Single(x => x.StructureTypeDescription == row1.StructureType).StructureTypeId,
                FishLength = (decimal)row1.FishLength,
                FishCount = row1.FishCount,
                SpeciesId = db.Species.Single(x => x.ScientificName == row1.ScientificName).SpeciesId,
                SurveyIndex = row1.SurveyIndex
            };
            db.Fishes.Add(fish);

            //save database
            db.SaveChanges();
        }
    }

}
