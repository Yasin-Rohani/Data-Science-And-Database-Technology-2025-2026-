# Extended SQL (4 points)

-- TENNIS-CLUB (IDClub, ClubName, City, Province, Region, LoungeArea, Showers, Bar, ChangingRooms)
-- COACH (IDCoach, CoachName, Nationality, AgeRange)
-- TIME-DATE (IDTimeD, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- TIME-HOUR (IDTimeH, TimeSlot)
-- JUNK-LESSON (IDJL, LessonType, LessonLevel, PaymentMethod)
-- TENNIS-LESSONS (IDClub, IDCoach, IDTimeD, IDTimeH, IDJL, NumHours, NumStudents, Revenue)

-- For each tennis-club that has showers and a lounge area, and for each two-month period, show:
-- average number of lesson hours per student and average revenue per lesson
-- ratio between the tennis club’s lesson hours and the total lesson hours of all tennis clubs located in the
-- same region
-- cumulative number of lesson hours over successive two-month periods, separately by year
-- Perform the analyses for each lesson type.

SELECT TC.ClubName, TD.2_Months, JL.LessonType , TD.Year, TC.Region, 
SUM(TL.NumHours)/SUM(TL.NumStudent) , SUM(TL.Revenue)/Count(*) , 
SUM(TL.NumHours)/SUM(SUM(TL.Numhours)) OVER (PARTITION BY TC.Region , TD.2_Months, JL.LessonType)
SUM(SUM(TL.NumHours))OVER(PARTION BY TC.ClubName, JL.LessonType, TD.Year ORDER BY TD.2_Months ROWS UNBOUNDED PRECEDING) 
FROM TENNIS-CLUB TC,  JUNk-LESSON JL , TENNIS-LESSONS TL ,TIME-DATE TD 
WHERE TC.Showers = "yes" AND TC.LoungeArea = "yes" AND TL.IDTimeD= TD.IDTimeD AND TL.IDLL= JL.IDJL AND TL.IDClub = TC.IDClub
GROUP BY TD.2_Months, JL.LessonType, TC.Region , TC.ClubName , TD.Year , TC.ClubName

#######################################################################################################################

# Extended SQL (3 points)

-- TENNIS-CLUB (IDClub, ClubName, City, Province, Region, LoungeArea, Showers, Bar, ChangingRooms)
-- COACH (IDCoach, CoachName, Nationality, AgeRange)
-- TIME-DATE (IDTimeD, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- TIME-HOUR (IDTimeH, TimeSlot)
-- JUNK-LESSON (IDJL, LessonType, LessonLevel, PaymentMethod)
-- TENNIS-LESSONS (IDClub, IDCoach, IDTimeD, IDTimeH, IDJL, NumHours, NumStudents, Revenue)

-- For each time slot, month, and city of the tennis club, show:
-- Average revenue per student.
-- Average number of lesson hours per student, separately by quarter.
-- Ratio between the number of students and the total number of students, considering all tennis club
-- located in the same province.
-- Perform the analyses separately by payment method.

SELECT TH.TimeSlot, TD.Month, TC.City, JL.PaymentMethod
SUM(TL.Revenue)/SUM(TL.NumStudents) ,
SUM(SUM(TL.NumHours))OVER(PARTITION BY TD.3_Months, TC.City, JL.PaymentMethod , TH.TimeSlot, TD.Year)
/
SUM(SUM(TL.NumStudents))OVER(PARTITION BY TD.3_Months, TC.City, JL.PaymentMethod , TH.TimeSlot, TD.Year),
SUM(TL.NumStudents)/SUM(SUM(TL.NumStudents))OVER(PARTITION BY TC.Province, JL.PaymentMethod , TH.TimeSlot, TD.Month , TD.Year)
FROM TENNIS-CLUB TC,  JUNk-LESSON JL , TENNIS-LESSONS TL ,TIME-DATE TD , TIME-HOUR TH
WHERE TL.IDclub= TC.IDClub AND TL.IDTimeD= TD.IDTimeD AND TL.IDJL= JL.IDJL AND TL.IDTimeH = TH.IDTimeH
GROUP BY TD.3_Months, TC.City, JL.PaymentMethod , TH.TimeSlot, TD.Year ,TD.Month ,TC.Province

########################################################################################################################

# Extended SQL (4 points)

-- TENNIS-CLUB (IDClub, ClubName, City, Province, Region, LoungeArea, Showers, Bar, ChangingRooms)
-- COACH (IDCoach, CoachName, Nationality, AgeRange)
-- TIME-DATE (IDTimeD, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- TIME-HOUR (IDTimeH, TimeSlot)
-- JUNK-LESSON (IDJL, LessonType, LessonLevel, PaymentMethod)
-- TENNIS-LESSONS (IDClub, IDCoach, IDTimeD, IDTimeH, IDJL, NumHours, NumStudents, Revenue)

-- For each coach, lesson level, and for each semester, show:
-- average number of lesson hours per month
-- total number of lesson hours, separately by year
-- percentage of lesson hours with respect to the total lesson hours delivered by all instructors of the same
-- nationality
-- Assign a ranking position for each record, calculated based on the total number of lesson hours, separately by
-- nationality

SELECT CoachName, LessonLevel, 6_Months,
SUM(NumHours)/COUNT(DISTINCT Month) , 
SUM(SUM(NumHours))OVER(PARTITION BY CoachName, LessonLevel, Year),
100*SUM(NumHours)/SUM(SUM(NumHours))OVER(PARTITION BY LessonLevel, 6_Months, Nationality),
RANK()OVER(PARTITION BY Nationality ORDER BY SUM(NumHours) DESC)
FROM COACH C, JUNk-LESSON JL , TENNIS-LESSONS TL , TIME-DATE TD
WHERE C.IDCoach = TL.IDCoach AND JL.IDJL = TL.IDJL AND TD.IDTimeD = TL.IDTimeD
GROUP BY CoachName, LessonLevel, 6_Months , Year , Nationality 


######################################################################################################################

# Materialized Views (5 points)

-- TENNIS-CLUB (IDClub, ClubName, City, Province, Region, LoungeArea, Showers, Bar, ChangingRooms)
-- COACH (IDCoach, CoachName, Nationality, AgeRange)
-- TIME-DATE (IDTimeD, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- TIME-HOUR (IDTimeH, TimeSlot)
-- JUNK-LESSON (IDJL, LessonType, LessonLevel, PaymentMethod)
-- TENNIS-LESSONS (IDClub, IDCoach, IDTimeD, IDTimeH, IDJL, NumHours, NumStudents, Revenue)

-- Given the above logical scheme, consider the following queries of interest:

-- a. For clubs with showers and changing rooms but no bar, display the cumulative value of lesson revenue
-- for each quarter (3-Month attribute), separately by year, payment method (PaymentMethod attribute)
-- and club region.

-- b. Separately for each two-month period, lesson type and lesson level, show the percentage of the revenue
-- compared to the total revenue per year and the average number of students per lesson hour,
-- considering only clubs in the city of Turin.

-- c. For “group” lessons (LessonType attribute), show the total revenue and average revenue per student
-- separately by year and club province.


-- Given the above logical schema, answer the following requests:

-- 1. Define a materialized view with the CREATE MATERIALIZED VIEW, that can be used to efficiently answer
-- all three of the above queries (i.e., a, b, c). Specifically, define the query in SQL associated with BLOCK A
-- in the following instruction
-- CREATE MATERIALIZED VIEW ViewLessons
-- BUILD IMMEDIATE
-- REFRESH FAST ON COMMIT
-- AS
-- Block A


-- 2. Define the minimal set of attributes that allows identifying the tuples belonging to the materialized
-- view ViewLessons.


-- 3. Assume that the management of the materialized view (derived table) is carried out by means of
-- triggers. Write the trigger to propagate to the ViewLessons materialized view the changes due to the
-- insertion of a new record into the TENNIS-LESSONS fact table


SELECT
    TC.Showers,
    TC.ChangingRooms,
    TC.Bar,
    TC.City,
    TC.Province,
    TC.Region,
    TD.Year,
    TD."2-Months",
    TD."3-Months",
    JL.PaymentMethod,
    JL.LessonType,
    JL.LessonLevel,

    SUM(TL.Revenue) AS TotRevenue,
    SUM(TL.NumStudents) AS TotStudents,
    SUM(TL.NumHours) AS TotHours,
    COUNT(*) AS NumLessons

FROM "TENNIS-LESSONS" TL,
     "TENNIS-CLUB" TC,
     "JUNK-LESSON" JL,
     "TIME-DATE" TD

WHERE TL.IDClub = TC.IDClub
  AND TL.IDL = JL.IDL
  AND TL.IDTimeD = TD.IDTimeD

GROUP BY
    TC.Showers,
    TC.ChangingRooms,
    TC.Bar,
    TC.City,
    TC.Province,
    TC.Region,
    TD.Year,
    TD."2-Months",
    TD."3-Months",
    JL.PaymentMethod,
    JL.LessonType,
    JL.LessonLevel;

2.minimal set of attributes:
Showers,
ChangingRooms,
Bar,
City,
Province,
Region,
Year,
2-Months,
3-Months,
PaymentMethod,
LessonType,
LessonLevel


3. CREATE OR REPLACE TRIGGER TriggerViewLessons
AFTER INSERT ON "TENNIS-LESSONS"
FOR EACH ROW
DECLARE
    varShowers VARCHAR(10);
    varChangingRooms VARCHAR(10);
    varBar VARCHAR(10);
    var3M VARCHAR(20);
    var2M VARCHAR(20);
    varYear INTEGER;
    varPaymentMethod VARCHAR(20);
    varRegion VARCHAR(50);
    varLessonType VARCHAR(20);
    varLessonLevel VARCHAR(20);
    varCity VARCHAR(50);
    varProvince VARCHAR(50);
    N INTEGER;
BEGIN

    SELECT Showers, ChangingRooms, Bar, City, Province, Region
    INTO varShowers, varChangingRooms, varBar, varCity, varProvince, varRegion
    FROM "TENNIS-CLUB"
    WHERE IDClub = :NEW.IDClub;

    SELECT "3-Months", "2-Months", Year
    INTO var3M, var2M, varYear
    FROM "TIME-DATE"
    WHERE IDTimeD = :NEW.IDTimeD;

    SELECT PaymentMethod, LessonType, LessonLevel
    INTO varPaymentMethod, varLessonType, varLessonLevel
    FROM "JUNK-LESSON"
    WHERE IDL = :NEW.IDL;

    SELECT COUNT(*)
    INTO N
    FROM ViewLessons
    WHERE Showers = varShowers
      AND ChangingRooms = varChangingRooms
      AND Bar = varBar
      AND City = varCity
      AND Province = varProvince
      AND Region = varRegion
      AND Year = varYear
      AND "3-Months" = var3M
      AND "2-Months" = var2M
      AND PaymentMethod = varPaymentMethod
      AND LessonType = varLessonType
      AND LessonLevel = varLessonLevel;

    IF N > 0 THEN

        UPDATE ViewLessons
        SET TotRevenue = TotRevenue + :NEW.Revenue,
            TotStudents = TotStudents + :NEW.NumStudents,
            TotHours = TotHours + :NEW.NumHours,
            NumLessons = NumLessons + 1
        WHERE Showers = varShowers
          AND ChangingRooms = varChangingRooms
          AND Bar = varBar
          AND City = varCity
          AND Province = varProvince
          AND Region = varRegion
          AND Year = varYear
          AND "3-Months" = var3M
          AND "2-Months" = var2M
          AND PaymentMethod = varPaymentMethod
          AND LessonType = varLessonType
          AND LessonLevel = varLessonLevel;

    ELSE

        INSERT INTO ViewLessons (
            Showers,
            ChangingRooms,
            Bar,
            City,
            Province,
            Region,
            Year,
            "3-Months",
            "2-Months",
            PaymentMethod,
            LessonType,
            LessonLevel,
            TotRevenue,
            TotStudents,
            TotHours,
            NumLessons
        )
        VALUES (
            varShowers,
            varChangingRooms,
            varBar,
            varCity,
            varProvince,
            varRegion,
            varYear,
            var3M,
            var2M,
            varPaymentMethod,
            varLessonType,
            varLessonLevel,
            :NEW.Revenue,
            :NEW.NumStudents,
            :NEW.NumHours,
            1
        );

    END IF;

END;
/
