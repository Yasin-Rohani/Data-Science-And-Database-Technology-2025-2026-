#EXtended SQl 3 points
-- SWIMMING_POOL(CodSP, SwimmingPoolName, Municipality, Region, Country)
-- ATHLETE (CodA, FirstName, LastName)
-- DATE (CodD, Date, Month, Year)
-- ENTRY (CodSP, CodA, CodD, totalDuration, numberOfEntries)

-- Separately for each region and year, compute:

-- the percentage of the total number of entries with respect to the total by country and year
-- the average monthly duration
-- the rank according to the average monthly duration decreasing, separately for each year

SELECT Year , Region
100*SUM(numberOFEntries)/SUM(SUM(numberOFEntries))OVER(PARTITION BY Year , Country)
SUM(totalDuration)/COUNT(DISTINCT Month),
RANK()OVER(PARTITION BY Year ORDER BY SUM(totalDuration)/COUNT(DISTINCT Month) DESC)
FROM ENTRY E , SWIMMING _POOL SP , DATE D 
WHERE E.CodSp=SP.Codsp AND D.CodD=E.CodD 
GROUP BY Year , Region , Country , Month

#####################################################################################################################################################
#Materialied View 5 Points

-- SWIMMING_POOL(CodSP, SwimmingPoolName, Municipality, Region, Country)
-- ATHLETE (CodA, FirstName, LastName)
-- DATE (CodD, Date, Month, Year)
-- ENTRY (CodSP, CodA, CodD, totalDuration, numberOfEntries)

-- Given the above logical schema, consider the following queries of interest:

-- a. Considering the years 2021 and 2022, display the monthly average of the total number of hours.
-- b. For pools located in the municipality of Turin, separately by month, display the monthly cumulative
-- of the total number of hours since the beginning of each year.
-- c. For the year 2022, separately by month and municipality,
--     display the fraction of each municipality's total number of entries compared to the total for the region in which the municipality is located.

-- Given the above logical schema, answer the following requests:

-- 1. Define a materialized view with the CREATE MATERIALIZED VIEW,
--  that can be used to efficiently answer all three of the above queries (i.e., a, b, c). Specifically,
--   define the query in SQL associated with BLOCK A in the following instruction. Please note that the SQL statements for queries (a), (b),
--    and (c) are not required.

-- CREATE MATERIALIZED VIEW ViewPools
-- BUILD IMMEDIATE
-- REFRESH FAST ON COMMIT
-- AS
-- Block A
-- 2. Define the minimal set of attributes that allows identifying the tuples belonging to the materialized ViewPools view.

-- 3. Assume that the management of the materialized view (derived table) is carried out by means of triggers.
--  Write the trigger to propagate to the ViewPool materialized view the changes due to the insertion of a new record into the ENTRY table.

CREATE MATERIALIZED VIEW ViewPools
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
AS
Block A

SELECT Year , Municipality , Month , SUM(totalDuration) AS TotDuration , SUM(NumberOfEntries) AS TotEntries , Region
FROM ENTRY E , DATE D , SWIMMING-POOl SP
WHERE E.CodSP= SP.CodSP , D.CodT=E.CodT
GROUP BY Year , Municipality , Month , Region

2. The minimal set of attributes : Year , Municipality , Month , Region

3. 
CREATE OR REPLACE TRIGGER MATVIEW
AFTER INSERT ON TO ENTRY
FOR EACH ROW
DECLARE 

YearVar INTEGER , MunicipalityVar VARCHAR(50), MonthVar VARCHAR(30) , RegionAVar VARCHAR(30) , N INTEGER;
BEGIN

SELECT Municipality , Region INTO MunicipalityVar, RegionAVar
FROM  SWIMMING_POOL
WHERE CodSP= :NEW.CodSP

SELECT Month Year  INTO Monthvar , YearVar
FROM  DATE 
WHERE CodD= :NEW.CodD

SELECT COUNT(*) INTO N
FROM  MATVIEW
WHERE Municipality = MunicipalityVar AND Month = MonthVar

IF (N=0) THEN
INSERT INTO MATVIEW(
    Year , Municipality , Month , , Region
)
VALUES(YearVar , MunicipalityVar, MonthVar ,RegionAVar , :NEW.totalDuration, :NEW.NumberOfEntries )

ELSE 
UPDATE  MATVIEW
SET  TotEntries = TotEntries + :NEW.NumberOfEntries, TotDuration = TotDuration + :NEW.totalDuration 
WHERE Month = MonthVar AND Municipality = MunicipalityVar; 

END IF ;
END;

########################################################################################################################################################

#Extended SQL (4 points)

-- WIMMING_POOL(CodSP, SwimmingPoolName, Municipality, Region, Country)
-- ATHLETE (CodA, FirstName, LastName)
-- DATE (CodD, Date, Month, Year)
-- ENTRY (CodSP, CodA, CodD, totalDuration, numberOfEntries)

-- For swimming pools in Italy, separately for month and region, compute:

-- The average daily number of entries
-- The percentage of entries from each region compared to all entries in Italy, for each month
-- Rank by decreasing number of entries separately for each year

SELECT Month , Region 
SUM(numberOfEntries)/COUNT(DISTINCT DATE),
100*SUM(numberOfEntries)/ SUM(SUM(numberOfEntries))OVER(PARTITION BY Month),
RANK()OVER(PARTITION BY Year ORDER BY SUM(numberOfEntries) DESC)
FROM ENTRY E , DATE D , SWIMMING_POOL SP
WHERE Country = 'Italy'  AND E.CodSP=Sp.CodSP AND D.CodD=E.CodD
GROUP BY Month , Region , Year 


#########################################################################################################################################################
#Extended SQL (4 Points)

-- SWIMMING_POOL(CodSP, SwimmingPoolName, Municipality, Region, Country)
-- ATHLETE (CodA, FirstName, LastName)
-- DATE (CodD, Date, Month, Year)
-- ENTRY (CodSP, CodA, CodD, totalDuration, numberOfEntries)

-- For 2020 and 2021, separately by month and pool (SwimmingPoolName), compute:
-- The total number of entries
-- The monthly cumulative of entries since the beginning of the year
-- Separately for each month, the ratio between the number of entries for each pool and, 
-- -- considering pools in the same municipality, the number of entries of the pool with the highest number of entries.

SELECT Month ,SwimmingPoolName
SUM(numberOfEntries) , 
SUM(SUM(numberOfEntries))OVER(PARTITION BY  SwimmingPoolName ,Year ORDER BY Month ROWS UNBOUNDED PROCEDING)
SUM(numberOfEntries)/MAX(SUM(numberOfEntries))OVER(PARTITION BY month , municipality)
WHERE Year >= 2020 AND Year <=2021 , E.CodSP=Sp.CodSP AND D.CodD=E.CodD
GROUP BY Month ,SwimmingPoolName , Municipality, Year
