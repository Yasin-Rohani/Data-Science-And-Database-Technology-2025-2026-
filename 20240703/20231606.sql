#EXTENDED SQL 4 Points

-- FEATURES-COURSE-CERTIFICATION (IDFeatCourseCert, Topic, CertificationType, CertificationLevel, PresenceAdmissionRequirements,DeliveryMode) 
-- ENROLLED-CHARACTERISTICS (IDEnrolledChar, AgeRange, Profession, Gender)
-- CERTIFICATION-OFFICE (IDCertOffice, CityOffice, RegionOffice, CountryOffice, NumberClassrooms, NumberTeachers) 
-- TIME (IDTime, Month, 2-Months, 3-Months, 4-Months, 6-Months, Year) 
-- COURSES-DELIVERY (IDFeatCourseCert, IDEnrolledChar, IDCertOffice, IDTime, TotalRevenue, NumberHoursDelivered, NumberEnrolled, NumberPassed)
-- Separately by certification type and 2-months period, display:

-- the total revenue, 
-- the ratio of the total number of passed students over the total number of enrolled students,
-- the percentage of the number of passed students with respect to the total number of passed students separately by 6-months period and certification type
-- the cumulative total of revenue as 2-months pass, separately by 6-months period and certification type.
-- Conduct the analysis separately by student gender.

SELECT CertificationType, 2-Months, Gender
SUM(TotalRevenue), SUM(NumberPassed)/SUM(NumberEnrolled),
100* Sum(NumberPassed)/SUM(Sum(NumberPassed)) OVER (PARTITION BY 6-Months, CertificationType, Gender),
SUM(SUM(TotalRevenue)) OVER (PARTITION BY 6-Months, CertificationType, Gender ORDER BY 2-Months ROWS UNBOUNDED PRECEDING)
FROM COURSES-DELIVERY CD, TIME T, FEATURES-COURSE-CERTIFICATION FC, ENROLLED-CHARACTERISTIC EC
WHERE CD.IDTime=T.IDTime AND CD.IDFeatCourseCert =FC.IDFeatCourseCert AND EC.IDEnrolledChar =EC. DEnrolledChar
GROUP BY CertificationType, 2-Months, Gender, 6-Months

#####################################################################################################################################################
#Materialized view (5 points)
-- FEATURES-COURSE-CERTIFICATION (IDFeatCourseCert, Topic, CertificationType, CertificationLevel, PresenceAdmissionRequirements,DeliveryMode) 
-- ENROLLED-CHARACTERISTICS (IDEnrolledChar, AgeRange, Profession, Gender)
-- CERTIFICATION-OFFICE (IDCertOffice, CityOffice, RegionOffice, CountryOffice, NumberClassrooms, NumberTeachers) 
-- TIME (IDTime, Month, 2-Months, 3-Months, 4-Months, 6-Months, Year) 
-- COURSES-DELIVERY (IDFeatCourseCert, IDEnrolledChar, IDCertOffice, IDTime, TotalRevenue, NumberHoursDelivered, NumberEnrolled, NumberPassed)
-- Given the above logic schema, consider the following queries of interest: 

-- a) Considering only male enrolled students in the age group > 45, separately by certification office region and profession, display the total number of enrolled students, the total number of passed students, and total revenue.
-- b) Separately by country of certification office and month, display the total monthly revenue and the cumulative annual revenue as months pass.
-- c) Separately by profession, considering only certification office region Piedmont, display the average monthly number of hours delivered and the average monthly revenue.
-- Given the above logical scheme, answer the following requests:

-- Define a materialized view with CREATE MATERIALIZED VIEW, so as to reduce the response time of the queries of interest (a) to (c) above. Specifically, specify the SQL query associated with Block A in the following statement:
-- CREATE MATERIALIZED VIEW ViewCourses
-- BUILD IMMEDIATE
-- REFRESH FAST ON COMMIT
-- AS
-- 		Block A
-- Assume that the management of the materialized view (derived table) is carried out by means of triggers. Write the trigger to propagate to the ViewCourses materialized view the changes due to the insertion of a new record into the COURSES-DELIVERY table. 
-- Testo della risposta Domanda 13

1. Block A 
SELECT Gender, Profession, AgeRange, RegionOffice, CountryOffice, Month, Year,  
SUM(TotalRevenue) AS TotRevenue, SUM(NumberHoursDelivered) AS TotHours, SUM(NumberEnrolled) AS TotEnrolled, SUM(NumberPassed) AS TotPassed  
FROM CERTIFICATION-OFFICE CO, ENROLLED-CHARACTERISTICS CI, TIME T, COURSES-DELIVERY EA  
WHERE CO.IDCertOffice = EA.IDCertOffice  
AND CI.IDEnrolledChar = EA.IDEnrolledChar  
AND T.IDTime = EA.IDTime
GROUP BY Gender, Profession, AgeRange, RegionOffice, CountryOffice, Month, Year;
2. Identifier
Gender, Profession, AgeRange, RegionOffice, Month
CREATE OR REPLACE TRIGGER TriggerViewCourses 
AFTER INSERT ON COURSES-DELIVERY 
FOR EACH ROW 
DECLARE 
 
VarY DATE,  VarM DATE; 
VarRegion,  VarCountry varchar(10);  
INTO VarGender, VarProfession, VarAgeRange varchar(10); 
N INTEGER; 
BEGIN 
SELECT Month, Year INTO VarM, varY 
FROM TIME 
WHERE IDTime = :NEW. IDTime; 
 
SELECT Gender, Profession, AgeRange INTO VarGender, VarProfession, VarAgeRange 
FROM ENROLLED-CHARACTERISTICS 
WHERE IDEnrolledChar = :NEW.IDEnrolledChar; 
 
SELECT RegionOffice, CountryOffice INTO VarRegion,  VarCountry
FROM CERTIFICATION-OFFICE 
WHERE IDCertOffice = :NEW.IDCertOffice; 
 
SELECT COUNT(*) INTO N 
FROM ViewCourses 
WHERE Month = VarM AND Gender = VarGender  
AND Profession= VarProfession AND AgeRange = VarAgeRange  
AND RegionOffice = varRegion; 
 
IF N>0 THEN 
            UPDATE ViewCourses 
            SET TotRevenue = TotRevenue + :NEW.TotalRevenue,  
TotHours = TotHours + :NEW.NumberHoursDelivered, 
TotEnrolled = TotEnrolled + :NEW.NumberEnrolled,  
TotPassed = TotPassed + :NEW.NumberPassed 
            WHERE Month = VarM AND Gender= VarGender  
AND Profession= VarProfession AND AgeRange= VarAgeRange  
AND RegionOffice = varRegion; 
ELSE  
            INSERT INTO ViewCourses (…) VALUES (VarM, VarY, VarGender, VarProfession, VarAgeRange, VarRegion,  VarCountry,:NEW.TotalRevenue, :NEW.NumberHoursDelivered, :NEW.NumberEnrolled, :NEW.NumberPassed);  
END IF; 
END 

###################################################################################################################################################

#Extended SQL query (3 points)
-- FEATURES-COURSE-CERTIFICATION (IDFeatCourseCert, Topic, CertificationType, CertificationLevel, PresenceAdmissionRequirements,DeliveryMode) 
-- ENROLLED-CHARACTERISTICS (IDEnrolledChar, AgeRange, Profession, Gender)
-- CERTIFICATION-OFFICE (IDCertOffice, CityOffice, RegionOffice, CountryOffice, NumberClassrooms, NumberTeachers) 
-- TEMPO (IDTime, Month, 2-Months, 3-Months, 4-Months, 6-Months, Year) 
-- COURSES-DELIVERY (IDFeatCourseCert, IDEnrolledChar, IDCertOffice, IDTime, TotalRevenue, NumberHoursDelivered, NumberEnrolled, NumberPassed)
-- Considering certification offices located in Italy, separately by course delivery mode and 6-months period, display

-- The total number of hours delivered 
-- The average number of passed students per month
-- The ratio of the total number of enrolled students over the total number of enrolled students separately by year and delivery mode
-- The position in a ranking (rank) in descending order with respect to the total number of hours delivered.
-- Conduct the analysis separately by topic.


SELECT DeliveryMode, 6-Months, Topic, Year

SUM(NumberHoursDelivered), SUM(NumberPassed)/ COUNT (DISTINCT Month),

SUM(NumberEnrolled)/SUM(SUM(NumberEnrolled)) OVER (PARTITION BY year, DeliveryMode, Topic),

RANK() OVER (PARTITION BY Topic ORDER BY SUM(NumberHoursDelivered) DESC)

FROM COURSES-DELIVERY CD, TIME T,  ENROLLED-CHARACTERISTICS EC, FEATURES-COURSE-CERTIFICATION FC, CERTIFICATION-OFFICE CO

WHERE CD.IDTime=T.IDTime AND CD.IDEnrolledChar=EC.IDEnrolledChar AND CD.IDFeatCourseCert =FC.IDFeatCourseCert

AND CD.IDCertOffice =CO.IDCertOffice AND CountryOffice = “Italy”

GROUP BY DeliveryMode, 6-Months, Topic, Year

####################################################################################################################################################
#Extended SQL query (4 points)

-- FEATURES-COURSE-CERTIFICATION (IDFeatCourseCert, Topic, CertificationType, CertificationLevel, PresenceAdmissionRequirements,DeliveryMode) 
-- ENROLLED-CHARACTERISTICS (IDEnrolledChar, AgeRange, Profession, Gender)
-- CERTIFICATION-OFFICE (IDCertOffice, CityOffice, RegionOffice, CountryOffice, NumberClassrooms, NumberTeachers) 
-- TIME (IDTime, Month, 2-Months, 3-Months, 4-Months, 6-Months, Year) 
-- COURSES-DELIVERY (IDFeatCourseCert, IDEnrolledChar, IDCertOffice, IDTime, TotalRevenue, NumberHoursDelivered, NumberEnrolled, NumberPassed)
-- Considering courses with online delivery mode, separately by profession, 3-month periods, and certification office country, display

-- the total number of enrolled students and the total number of passed students
-- the average revenue by number of enrolled students 
-- the average monthly revenue
-- the total revenue separately by profession of enrolled students, certification office country, and year,
-- the position in a ranking (rank) in descending order of the total number of passed students, separately by year.


SELECT Profession, 3-Months, CountryOffice

SUM(NumberEnrolled), SUM(NumberPassed), SUM(TotalRevenue)/SUM(NumberEnrolled)

SUM(TotalRevenue)/ COUNT (DISTINCT Month)

SUM(SUM(TotalRevenue)) OVER (PARTITION BY A Profession, Year, CountryOffice),

RANK() OVER (PARTITION BY  Year ORDER BY SUM(NumberPassed) DESC)

FROM COURSES-DELIVERY CD, TIME T, CERTIFICATION-OFFICE CO, FEATURES-COURSE-CERTIFICATION FC, ENROLLED-CHARACTERISTICS EC

WHERE CD.IDTime=T.IDTime AND CD.IDCertOffice=CO.IDCertOffice AND CD.IDFeatCourseCert =FC.IDFeatCourseCert

AND  CD.IDEnrolledChar=ED.IDEnrolledChar AND DeliveryMode=''online''

GROUP BY Profession, 3-Months, OfficeCountry, Year