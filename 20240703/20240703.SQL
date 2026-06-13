#EXTENDED SQL (4 Points)

-- COPYSHOP(CodC, CopyshopC, CityC, ProvinceC, RegionC, CountryC, Brochures, Leaflets, Calendars, Print_photos, Photocopies)
-- TIME(CodT, Date, DayWeek, Week, Month, 3-Months, 4-Months, 6-Months, Year)
-- JUNK- DIMENSION(CodJK, PaymentType, DeliveryType, RequestedServiceType, RealisationMode)
-- COMPANY-TYPE(CodCT, CompanyType, CompanySector)
-- COMPANY-LOCATION (CodL, CompanyCity, CompanyProvince, CompanyRegion, CompanyCountry)
-- ORDERS(CodC, CodT, CodJK, CodCT, CodL, #Orders, ProductionTime, Cost, CopiesQuantity)

-- Separately by month and company type display:

-- the average quantity of copies per order and the average production time per order,
-- the percentage of orders in relation to the annual total
-- the total number of orders separately by company sector 
-- Assign to each record

-- a rank separately per sector of the company. Rank 1 is assigned to the record with the lowest average production time per order.
-- one rank separately per year. Rank 1 is to be assigned to the record with the highest number of orders



SELECT SUM(CopiesQuantity)/SUM(#Orders), SUM(ProductionTime)/SUM(#Orders),

SUM(SUM(#Orders))/SUM(SUM(#Orders)) OVER (PARTITION BY Year, CompanyType),

SUM(SUM(#Orders)) OVER (PARTITION BY Month, CompanySector),

RANK() OVER (PARTITION BY CompanySector ORDER BY SUM(ProductionTime)/SUM(#Orders)),

RANK() OVER (PARTITION BY Year ORDER BY SUM(#Orders) DESC),

FROM ORDERS O, TIME T, COMPANY-TYPE CT, COMPANY-LOCATION CL

WHERE O.CodT=T.CodT AND O.CodCT=CT.CodCT AND O.CodL=CL.CodL

GROUP BY Month, CompanyType, CompanySector, Year


####################################################################################################################################################

#Extended SQL (4 Points)

-- COPYSHOP(CodC, CopyshopC, CityC, ProvinceC, RegionC, CountryC, Brochures, Leaflets, Calendars, Print_photos, Photocopies)
-- TIME(CodT, Date, DayWeek, Week, Month, 3-Months, 4-Months, 6-Months, Year)
-- JUNK- DIMENSION(CodJK, PaymentType, DeliveryType, RequestedServiceType, RealisationMode)
-- COMPANY-TYPE(CodCT, CompanyType, CompanySector)
-- COMPANY-LOCATION (CodL, CompanyCity, CompanyProvince, CompanyRegion, CompanyCountry)
-- ORDERS(CodC, CodT, CodJK, CodCT, CodL, #Orders, ProductionTime, Cost, CopiesQuantity)

-- Considering the orders processed per requested service type flyer printing (RequestedServiceType ='Flyer Printing') placed by companies located in Italy (CompanyCountry='Italy'), separately by company type, month and payment type, calculate

-- the average number of copies per order  
-- the total number of orders separately per 4-months periods
-- the total number of copies regardless of company type and month
-- the average production time per order regardless (Without) of payment type.
-- Perform the analysis separately for the mode of realisation.

SELECT SUM(CopiesQuantity)/SUM(#Orders),

SUM(SUM(#Orders)) OVER (PARTITION BY 4M, PaymentType, CompanyType, RealisationMode),

SUM(SUM(CopiesQuantity)) OVER (PARTITION BY PaymentType, RealisationMode),

SUM(SUM(ProductionTime)) OVER (
    PARTITION BY Month, RealisationMode
)
/
SUM(SUM(Orders)) OVER (
    PARTITION BY Month, RealisationMode
)

FROM ORDERS O, JUNK- DIMENSION J, TIME T, COMPANY-TYPE CT, COMPANY-LOCATION CL

WHERE O.CodJK=J.CodJK AND O.CodT=T.CodT AND O.CodCT=CT.CodCT AND O.CodL=CL.CodL

AND RequestedServiceType='Flyer Printing' AND CompanyCountry='Italy'

AND (RealisationMode= 'standard' OR RealisationMode= 'express')

GROUP BY Month, PaymentType, CompanyType, 4M, RealisationMode

######################################################################################################################################################
# Materialized view - 5 points 

-- COPYSHOP(CodC, CopyshopC, CityC, ProvinceC, RegionC, CountryC, Brochures, Leaflets, Calendars, Print_photos, Photocopies)
-- TIME(CodT, Date, DayWeek, Week, Month, 3-Months, 4-Months, 6-Months, Year)
-- JUNK- DIMENSION(CodJK, PaymentType, DeliveryType, RequestedServiceType, RealisationMode)
-- COMPANY-TYPE(CodCT, CompanyType, CompanySector)
-- COMPANY-LOCATION (CodL, CompanyCity, CompanyProvince, CompanyRegion, CompanyCountry)
-- ORDERS(CodC, CodT, CodJK, CodCT, CodL, #Orders, ProductionTime, Cost, CopiesQuantity)

-- Given the above logic scheme, consider the following queries of interest: 

-- a) Separately by year and type of service (attribute RequestedServiceType), show 
-- the percentage of the number of orders (attribute #Orders) with respect to 
-- the total number of orders per year and the percentage of the production time with respect to the total production time per year.

-- b) Separately by semester (attribute 6-Months), payment type (attribute PaymentType) and company 
-- region (attribute CompanyRegion), show the total number of orders, the total cost and the average cost per order.

-- c) For companies located in the province of Turin (attribute CompanyProvince), display the yearly 
-- cumulative cost as the four quarters pass (attribute 4-Months).
-- Given the above logical schema, answer the following requests:

-- 1. Define a materialized view with CREATE MATERIALIZED VIEW, in order to reduce the response 
-- time of the queries of interest from (a) to (c) above. Specifically, specify the SQL query associated with Block A in the following statement:

-- CREATE MATERIALIZED VIEW ViewOrders
-- BUILD IMMEDIATE
-- REFRESH FAST ON COMMIT
-- AS
-- 	Block A

-- 2. Define the minimal set of attributes that allow to identify the tuples that belong to the ViewOrders materialized view.

-- 3. Assume that the management of the materialized view (derived table) is carried out by means of triggers.
--  Write the trigger to propagate changes to the ViewOrders materialized view when a new record is inserted into the ORDERS fact table.

Queries of interest: 

(a) 

SELECT Year, RequestedServiceType, SUM(#Orders)/SUM(SUM((#Orders)) OVER (PARTITION BY Year),

	SUM(ProductionTime)/SUM(SUM(ProductionTime)) OVER (PARTITION BY Year)

FROM JUNK-DIMENSION J, TIME T, ORDERS O

WHERE J.CodJK = O.CodJK AND T.CodT = O.CodT

GROUP BY Year, RequestedServiceType



(b) 

SELECT 6-Months, PaymentType, CompanyRegion, SUM(#Orders), SUM(Cost), SUM(Cost)/SUM(#Orders) 

FROM JUNK-DIMENSION J, COMPANY-LOCATION L, TIME T, ORDERS O

WHERE J.CodJK = O.CodJK AND T.CodT = O.CodT AND O.CodL = L.CodL

GROUP BY 6-Months, PaymentType, CompanyRegion



(c) 

SELECT 4-Months, Year, SUM(SUM(Cost)) OVER (PARTITION BY Year 

			      		    ORDER BY 4-Months 

			                    ROWS UNBOUNDED PRECEDING)

FROM JUNK-DIMENSION J, COMPANY-LOCATION L, TIME T, ORDERS O

WHERE J.CodJK = O.CodJK AND T.CodT = O.CodT AND O.CodL = L.CodL AND CompanyProvince = 'Turin'

GROUP BY 4-Months, Year



------------------------------------

1. Block A - Query for materialized view


SELECT 4-Months, 6-Months, Year, CompanyProvince, CompanyRegion, RequestedServiceType, PaymentType, 

SUM(#Orders) AS TOTOrders, SUM(Cost) AS TOTCost, SUM(ProductionTime) AS TOTTime

FROM JUNK-DIMENSION J, COMPANY-LOCATION L, TIME T, ORDERS O

WHERE J.CodJK = O.CodJK AND T.CodT = O.CodT AND O.CodL = L.CodL 

GROUP BY 4-Months, 6-Months, Year, CompanyProvince, CompanyRegion, RequestedServiceType, PaymentType



2. Identifiers

4-Months, 6-Months, CompanyProvince, RequestedServiceType, PaymentType



3. Trigger

CREATE OR REPLACE TRIGGER ViewOrders

AFTER INSERT ON ORDERS

FOR EACH ROW

DECLARE

Var4M, Var6M, VarYear DATE;

VarProvince, VarRegion, VarPT, VarRST VARCHAR(10);

N INTEGER;

BEGIN

       SELECT 4-Months, 6-Months, Year INTO Var4M, Var6M, VarYear

       FROM TIME

       WHERE CodT = :NEW.CodT;



       SELECT CompanyProvince, CompanyRegion INTO VarProvince, VarRegion

       FROM COMPANY-LOCATION

       WHERE CodL = :NEW.CodL;



       SELECT PaymentType, RequestedServiceType INTO VarPT, VarRST

       FROM JUNK-DIMENSION

       WHERE CodJK = :NEW.CodJK;



       SELECT COUNT(*) INTO N

       FROM ViewOrders

       WHERE 4-Months=Var4M AND 6-Months=Var6M AND CompanyProvince=VarProvince AND PaymentType=VarPT AND RequestedServiceType=VarRST;

 

      IF N>0 THEN

             UPDATE ViewOrders

             SET TOTOrders = TOTOrders + :NEW.#Orders, TOTCost = TOTCost + :NEW.Cost, TOTTime= TOTTime +:NEW.ProductionTime

             WHERE 4-Months=Var4M AND 6-Months=Var6M AND CompanyProvince=VarProvince AND PaymentType=VarPT AND RequestedServiceType=VarRST;

      ELSE 

            INSERT INTO ViewOrders(…) VALUES (Var4M, Var6M, VarYear, VarProvince, VarRegion, VarPT, VarRPT, :NEW.#Orders, :NEW.Cost, :NEW.ProductionTime); 

     END IF;

END;

######################################################################################################################################################
#Extended SQL (3 points)

-- COPYSHOP(CodC, CopyshopC, CityC, ProvinceC, RegionC, CountryC, Brochures, Leaflets, Calendars, Print_photos, Photocopies)
-- TIME(CodT, Date, DayWeek, Week, Month, 3-Months, 4-Months, 6-Months, Year)
-- JUNK- DIMENSION(CodJK, PaymentType, DeliveryType, RequestedServiceType, RealisationMode)
-- COMPANY-TYPE(CodCT, CompanyType, CompanySector)
-- COMPANY-LOCATION (CodL, CompanyCity, CompanyProvince, CompanyRegion, CompanyCountry)
-- ORDERS(CodC, CodT, CodJK, CodCT, CodL, #Orders, ProductionTime, Cost, CopiesQuantity)
-- Considering copy shops that only offer brochure and calendar production services, separately by semester (6-months) and region of the company, compute

-- The average cost per order and the average production time per order
-- The percentage of the number of orders in relation to the total number per company country 
-- The total number of copies as the semesters (6-Months) pass.
-- Perform the analysis separately by sector of the company.

SELECT SUM(Cost)/SUM(#Orders), SUM(ProductionTime)/SUM(#Orders),

100*SUM(#Orders)/SUM(SUM(#Orders)) OVER (PARTITION BY 6M, CompanySector, CompanyRegion),

SUM(SUM(CopiesQuantity)) OVER (PARTITION BY CompanyRegion, CompanySector ORDER BY 6M ROWS UNBOUNDED PRECEDING)

FROM ORDERS O, COPYSHOP C, TIME T, COMPANY-TYPE CT, COMPANY-LOCATION CL

WHERE O.CodC=C.CodC AND O.CodT=T.CodT AND O.CodCT=CT.CodCT AND O.CodL=CL.CodL

AND Brochures=True AND Calendars=True AND Leaflets=False AND Print_photos=FALSE AND Photocopies=FALSE

GROUP BY 6M, CompanyRegion, CompanySector, CompanyCountry