# EXtended sql (4 points)

-- TIME_HOUR  (HourID, Hour, Time_Slot)
-- TIME_DATE (DateID, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- USER_TYPE (UserTypeID, User_Type, User-Category)
-- COMPANY (CompanyID, Company, Size, City, Province, Region, Geographical_Area)
-- SERVICE (ServiceID, Service, Service_Type, Cloud_Space_Size, Distribution_Channel, Provider)
-- REVIEW_IT_SERVICES (HourID, DateID, UserTypeID, CompanyID, ServiceID, Number_Evaluators, Total_Review_Score, Number_Users)


-- Considering companies in the Northwest (AreaGeographic='Northwest'), for each type of service, user category and bimonth (2-Month), show:

-- the average daily number of evaluators,
-- the average daily number of users,
-- the average rating per evaluator separately by provider,
-- the ratio of the number of evaluators versus the total number of evaluators per provider.
-- Perform the analysis separately by company size

SELECT 2M, Service_Type,

SUM(Number_Evaluators)/COUNT(DISTINCT Date),

SUM(Number_Users)/COUNT(DISTINCT Date),

SUM(SUM(Total_Review_Score))/SUM(SUM(Number_Evaluators)) OVER (PARTITION BY Provider, 2M, Size, User-Category) 

SUM(Number_Evaluators)/SUM(SUM(Number_Evaluators)) OVER (PARTITION BY Provider, 2M, Size, User-Category)

FROM REVIEW_IT_SERVICES R, TIME_DATE T, SERVICE S, USER_TYPE U, COMPANY C

WHERE R.DateID=T.DateID AND R.ServiceID=S.ServiceID AND U.UserTypeID=R.UserTypeID AND C.CompanyID=R.CompanyID

AND Geographical_Area='Northwest'

GROUP BY 2M, Service_Type, Provider, Size, User-Category





##########################################################################################################################################################

# Extended SQL (4 points)


-- TIME_HOUR  (HourID, Hour, Time_Slot)
-- TIME_DATE (DateID, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- USER_TYPE (UserTypeID, User_Type, User-Category)
-- COMPANY (CompanyID, Company, Size, City, Province, Region, Geographical_Area)
-- SERVICE (ServiceID, Service, Service_Type, Cloud_Space_Size, Distribution_Channel, Provider)
-- REVIEW_IT_SERVICES (HourID, DateID, UserTypeID, CompanyID, ServiceID, Number_Evaluators, Total_Review_Score, Number_Users)


-- Considering reviews of multichannel services (Distribution_Channel='multichannel'), for each type of users and quarter (3-Months) show:

-- the percentage of the number of evaluators with respect to the number of users,
-- the average score of reviews per evaluator,
-- the cumulative number of users as quarters (3-Months) pass separately by year,
-- the percentage of the number of evaluators with respect to the overall per year.
-- Perform the analysis separately for each company.

SELECT User_Type, 3M, Company, 
SUM(Number_Evaluators)/SUM(Number_Users),

SUM(Total_Review_Score)/SUM(Number_Evaluators),

SUM(SUM(Number_Users)) OVER (PARTITION BY User_Type, Year, Company ORDER BY 3M ROWS UNBOUNDED PRECEDING),

SUM(Number_Evaluators)/SUM(SUM(Number_Evaluators)) OVER (PARTITION BY User_Type, Year, Company)

FROM REVIEW_IT_SERVICES R, TIME_DATE T, SERVICE S, USER_TYPE U, COMPANY C

WHERE R.DateID=T.DateID AND R.ServiceID=S.ServiceID AND U.UserTypeID=R.UserTypeID AND C.CompanyID=R.CompanyID

AND Distribution_Channel='multichannel'

GROUP BY User_Type, 3M, Year, Company

#########################################################################################################################################################

Extended SQl (3 Points)

-- TIME_HOUR  (HourID, Hour, Time_Slot)
-- TIME_DATE (DateID, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- USER_TYPE (UserTypeID, User_Type, User-Category)
-- COMPANY (CompanyID, Company, Size, City, Province, Region, Geographical_Area)
-- SERVICE (ServiceID, Service, Service_Type, Cloud_Space_Size, Distribution_Channel, Provider)
-- REVIEW_IT_SERVICES (HourID, DateID, UserTypeID, CompanyID, ServiceID, Number_Evaluators, Total_Review_Score, Number_Users)


-- Considering the reviews collected from companies located in the Piedmont region, for each service and semester (attribute 6-Months) show

-- the number of users and the number of evaluators,
-- the percentage of evaluators compared with the overall by service type and year,
-- the percentage of users compared with the total by service type and year.
-- Assign to each record:

-- a rank based on the number of users (rank 1 for the highest number of users) separately by service type,
-- a rank based on the number of evaluators (position 1 for the highest number of evaluators)

SELECT Service, 6M, Service_Type, SUM(Number_Users), SUM(Number_Evaluators),

SUM(Number_Evaluators)/SUM(SUM(Number_Evaluators)) OVER (PARTITION BY  Service_Type, Year)

SUM(Number_Users)/SUM(SUM(Number_Users)) OVER (PARTITION BY  Service_Type, Year),

RANK() OVER (PARTITION BY Service_Type ORDER BY SUM(Number_Users) DESC),

RANK() OVER (ORDER BY SUM(Number_Evaluators) DESC)

FROM REVIEW_IT_SERVICES R, TIME_DATE T, SERVICE S, COMPANY C

WHERE R.DateID=T.DateID AND R.ServiceID=S.ServiceID AND C.CompanyID=R.CompanyID

AND Region='Piedmont'

GROUP BY Service, 6M, Service_Type, Year

########################################################################################################################################################

-- TIME_HOUR (HourID, Hour, Time_Slot) 
-- TIME_DATE (DateID, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- USER_TYPE (UserTypeID, User_Type, User-Category)
-- COMPANY (CompanyID, Company, Size, City, Province, Region, Geographical_Area)
-- SERVICE (ServiceID, Service, Service_Type, Cloud_Space_Size, Distribution_Channel, Provider)
-- REVIEW_IT_SERVICES (HourID, DateID, UserTypeID, CompanyID, ServiceID, Number_Evaluators, Total_Review_Score, Number_Users)

-- Given the above logical scheme, consider the following queries of interest:

-- a.For the years 2023 and 2024, separately by geographic area of the company and semester (attribute 6-Months),
--  display the percentage of the number of evaluators to the total number of evaluators by geographic area of the company.

-- b.Considering companies with size greater than 20 employees (attribute Size) and
--  provider 'AWS' (attribute Provider), display the cumulative value of review score as bimonths pass (attribute 2-Months), separately by year. 

-- c.For companies located in cities of the Piedmont region, separately
-- by distribution channel (attribute Distribution_Channel) and semester (attribute 6-Months),
--  display the total number of evaluators, total number of users, average score per evaluator.
-- Given the above logical schema, answer the following requests:

-- 1.
-- Define a materialized view with the CREATE MATERIALIZED VIEW, that can be used to 
-- efficiently answer all three of the above queries (i.e., a, b, c). Specifically, define the query
-- in SQL associated with BLOCK A in the following instruction
-- CREATE MATERIALIZED VIEW ViewReview
-- BUILD IMMEDIATE
-- REFRESH FAST ON COMMIT
-- AS
--  Block A

-- 2.
-- Define the minimal set of attributes that allows identifying the tuples belonging to the materialized view ViewReview.

-- 3.
-- Assume that the management of the materialized view (derived table) is carried out by means of triggers.
-- Write the trigger to propagate to the ViewReview materialized view 
-- the changes due to the insertion of a new record into the REVIEW_IT_SERVICES fact table

#######################################################################################################################################################

1. Block A:

SELECT

   2-Months, 6-Months, Year,

   Region, Geographical_Area, Size,

   Distribution_Channel, Provider,

   SUM(Number_Evaluators) AS TotEvaluators,

   SUM(Number_Users) AS TotUsers,

   SUM(Total_Review_Score) AS TotScore

FROM

   TIME_DATE  T,

   COMPANY A,

   SERVICE S,

   REVIEW_IT_SERVICES AS RSI

WHERE

   RSI.DateID = T. DateID AND RSI.CompanyID = A.CompanyID AND  RSI.ServiceID= S.ServiceID 

GROUP BY   2-Months, 6-Months, Year, Region, Geographical_Area, Size,                   Distribution_Channel, Provider

---------------------



2.
2-Months, Region, Size, Provider, Distribution_Channel



---------------------



3. Trigger:
CREATE OR REPLACE TRIGGER ViewReview

AFTER INSERT ON REVIEW_IT_SERVICES

FOR EACH ROW

DECLARE

    V2M DATE, V6M DATE, VYear INTEGER; 

    VRegion VARCHAR(30), VGeographical_Area (30);

    VProvider VARCHAR(63), VChannel VARCHAR(63), VSize INTEGER;

    N INTEGER;

BEGIN

   SELECT 2-Months, 6-Months, Year INTO V2M, V6M, VAnno

   FROM TIME_DATE

   WHERE DateID = :NEW.DateID;



   SELECT Region, Geographical_Area, Size INTO VRegion, VGeographical_Area, vSize

   FROM COMPANY

   WHERE CompanyID = :NEW.CompanyID;



   SELECT Provider, Distribution_Channel INTO VProvider, VChannel

   FROM SERVICE

   WHERE ServiceID = :NEW.ServiceID;





   SELECT COUNT(*) INTO N

   FROM ViewReview

   WHERE 

      2-Months = V2M AND

      Region = VRegion AND

      Provider = VProvider AND

      Distribution_Channel = VChannel AND

      Size = VSize;



   IF (N = 0) THEN

      INSERT INTO ViewReview (2-Months, 6-Months, Year, Region, Geographical_Area,  Distribution_Channel, Provider, Size, TotEvaluators, TotUsers, TotScore ) 

VALUES (V2M, V6M, VYear, VRegion, VGeographica_Area, VProvider, VChannel, VSize, 

         :NEW.Number_Evaluators, :NEW.Number_Users, :NEW.Total_Review_Score);



   ELSE

      UPDATE ViewReview

      SET TotEvaluators = TotEvaluators + :NEW.Number_Evaluators,

             TotUsers = TotUsers + :NEW.Number_Users,

             TotScore = TotScore + :NEW.Total_Review_Score

      WHERE

     	 2-Months = V2M AND

      	Region = VRegion AND

      	Provider = VProvider AND

      	Distribution_Channel = VChannel AND

     	 Size = VSize;

   END IF;

END; 

