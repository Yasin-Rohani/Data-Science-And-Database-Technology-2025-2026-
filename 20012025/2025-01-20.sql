# Extended SQL (4 Points)

-- CAR-MODEL (IDModel, Model, Type, Brand)
-- ACCESSORIES (IDModel, Accessory)
-- TIME (IDTime, StartDate, Month, 2M, 3M, 6M, Year)
-- JUNK-RENT (IDJR, ClientType, PaymentMethod)
-- CITY (IDCity, City, Province, Region, Country)
-- CAR-RENT (IDModel, IDTime, IDJR, IDDepartureCity, IDArrivalCity, Revenue, NumRents, KMTraveled)


-- Considering only rentals of BMW cars (Brand='BMW') carried out in the period 2021-2024 compute for each
-- bimonth (2-Month attribute) and departure city:
-- the average revenue per rental and the average number of kilometers traveled per rental,
-- the cumulative value of the revenue as bimonths pass separately by year,
-- the percentage of the number of kilometers traveled compared to the total number of kilometers
-- traveled by departure country.
-- Perform the analysis separately by client type.

SELECT ClientType , 2M , City
SUM(Reneue)/SUM(NumRents), SUM(KMTraveled)/SUM(NumRents)
SUM(SUM(Revenue))OVER(PARTITION BY Month Year ClientType ORDER BY 2M ROWS UNBOUNDED PROCEDING)
100*SUM(KMTraveled)/SUM(SUM(KMTraveled))OVER(PARTITION BY  ClientType ,Country ,2M)
FROM City c, CAR-MODEL cm, CAR_RENT cr, JUNK-RENT jr
WHERE cr.IDModel = cm.IDModel AND cr.IDTime = t.IDTime AND cr.IDJR=jr.IDJR AND c.IDCity = cr.IDCity AND cm.BRAND='BMW' AND (t.Year>= '2021' AND t.Year<=2024) 
GROUP BY  Year,2M, ClientType, Country, City


####################################################################################################################################
 
 #Extended SQL (3 points)

-- CAR-MODEL (IDModel, Model, Type, Brand)
-- ACCESSORIES (IDModel, Accessory)
-- TIME (IDTime, StartDate, Month, 2M, 3M, 6M, Year)
-- JUNK-RENT (IDJR, ClientType, PaymentMethod)
-- CITY (IDCity, City, Province, Region, Country)
-- CAR-RENT (IDModel, IDTime, IDJR, IDDepartureCity, IDArrivalCity, Revenue, NumRents, KMTraveled)

-- Considering rentals of cars with navigator accessory (Accessory='Navigator'), for each semester and car
-- model show
-- the average revenue per number of rentals,
-- the percentage of total revenue with respect to the total revenue by car brand and year.
-- Assign to each record:
-- a rank based on the number of rentals made (rank 1 for the highest number of rentals) separately by car
-- brand
-- a rank based on the number of kilometers traveled (position 1 for the lowest number of kilometers
-- traveled) separately by year.


SELECT 6M , Model 
SUM(Revenue)/SUM(NumRents)
100*SUM(Revenue)/SUM(SUM(Revenue))OVER(PARTITION BY Year Brand)
RANK()OVER(PARTITION BY Brand ORDER BY SUM(NumRents)DESC)
RANK()OVER(PARTITION BY Year ORDER BY SUM(KMTraveled)ASC)
FROM CAR-RENT cr , Time t , ACCESSORIES a , CAR-MODEL cm
WHERE cr.IDMOdel = cm.IDModel AND cr.IDTime=t.IDTime AND cr.IDModel = a.IDMOdel AND a.Accessory = 'Navigator'
GROUP BY 6M , Model , Brand ,YEAR 

########################################################################################################################

#EXtended SQL (4 points)

-- CAR-MODEL (IDModel, Model, Type, Brand)
-- ACCESSORIES (IDModel, Accessory)
-- TIME (IDTime, StartDate, Month, 2M, 3M, 6M, Year)
-- JUNK-RENT (IDJR, ClientType, PaymentMethod)
-- CITY (IDCity, City, Province, Region, Country)
-- CAR-RENT (IDModel, IDTime, IDJR, IDDepartureCity, IDArrivalCity, Revenue, NumRents, KMTraveled)

-- For each triplet (province of rental departure city, province of rental arrival city, quarter (3-Months)), show
-- the average revenue per traveled km,
-- the percentage of the total revenue to the total revenue by region of the departure city and region of
-- the arrival city
-- the average revenue per number of rentals separately by year
-- Perform the analysis separately by payment method

SELECT C1.Province AS DeprtureProvince , C2.Province As ArrivalProvince,  T.3M , JR.PaymentMethod
SUM(CR.Revenue)/SUM(CR.KMTraveled),
100*SUM(CR.Rvenue)/SUM(SUM(CR.Revenue))OVER(PARTITION BY C1.Region,C2.Region ,T.3M,JR.PaymentMethod),
SUM(SUM(CR.Revenue)) OVER (PARTITION BY T.Year, C1.Province, C2.Province, JR.PaymentMethod)
/
SUM(SUM(CR.NumRents)) OVER (PARTITION BY T.Year, C1.Province, C2.Province, JR.PaymentMethod);
FROM  TIME T , CITY C1 ,CITY C2, CAR_RENT CR , JUNK_RENT JR
WHERE  CR.IDTIme = T.IDTime AND CR.IDJR = JR.IDJR AND CR.IDDepartureCity = C1.IDCity
      AND CR.IDArrivalCity = C2.IDCity
GROUP By C1.Province,C2.Province, T.3M , JR.PaymentMethod , C1.Region , C2.Region , T.Year

#########################################################################################################################

# Materialized view (5 Points)

-- CAR-MODEL (IDModel, Model, Type, Brand)
-- ACCESSORIES (IDModel, Accessory)
-- TIME (IDTime, StartDate, Month, 2M, 3M, 6M, Year)
-- JUNK-RENT (IDJR, ClientType, PaymentMethod)
-- CITY (IDCity, City, Province, Region, Country)
-- CAR-RENT (IDModel, IDTime, IDJR, IDDepartureCity, IDArrivalCity, Revenue, NumRents, KMTraveled)



-- Given the above logical scheme, consider the following queries of interest:

-- Considering only 'Audi' brand car models and 'business' type clients, show the cumulative value of the
-- number of rentals as the quarters pass (3-Months attribute), separately by year.
-- For rentals departed from cities in the Piedmont region, separately by payment mode (attribute
-- PaymentMode) and year, display the total number of rentals, total revenue, average revenue per rental,
-- and average number of kilometers traveled per rental.
-- For models of type 'economy' (Type attribute) and brand 'Toyota', separately by year and rental
-- departure region, show the percentage of the number of rentals compared to the total number of rentals
-- for each rental departure state and year.
-- Given the above logical schema, answer the following requests:

-- 1. Define a materialized view with the CREATE MATERIALIZED VIEW, that can be used to efficiently answer
-- all three of the above queries (i.e., a, b, c). Specifically, define the query in SQL associated with BLOCK A
-- in the following instruction
-- CREATE MATERIALIZED VIEW ViewRent
-- BUILD IMMEDIATE
-- REFRESH FAST ON COMMIT
-- AS
-- Block A

-- 2. Assume that the management of the materialized view (derived table) is carried out by means of
-- triggers. Write the trigger to propagate to the ViewRent materialized view the changes due to the
-- insertion of a new record into the CAR-RENT fact table


CREATE OR REPLACE TRIGGER ViewRentManagement
AFTER INSERT ON CAR_RENT
FOR EACH ROW
DECLARE
    varType          VARCHAR(30);
    varBrand         VARCHAR(30);
    var3M            VARCHAR(10);
    varYear          INTEGER;
    varClientType    VARCHAR(30);
    varPaymentMethod VARCHAR(30);
    varRegion        VARCHAR(30);
    varCountry       VARCHAR(30);
    N                INTEGER;
BEGIN
    SELECT CM.Type, CM.Brand
    INTO varType, varBrand
    FROM CAR_MODEL CM
    WHERE CM.IDModel = :NEW.IDModel;

    SELECT T.3M, T.Year
    INTO var3M, varYear
    FROM TIME T
    WHERE T.IDTime = :NEW.IDTime;

    SELECT JR.ClientType, JR.PaymentMethod
    INTO varClientType, varPaymentMethod
    FROM JUNK_RENT JR
    WHERE JR.IDJR = :NEW.IDJR;

    SELECT C.Region, C.Country
    INTO varRegion, varCountry
    FROM CITY C
    WHERE C.IDCity = :NEW.IDDepartureCity;

    SELECT COUNT(*)
    INTO N
    FROM ViewRent VR
    WHERE VR.ClientType = varClientType
      AND VR.PaymentMethod = varPaymentMethod
      AND VR.Brand = varBrand
      AND VR.Type = varType
      AND VR.3M = var3M
      AND VR.Year = varYear
      AND VR.Region = varRegion
      AND VR.Country = varCountry;

    IF N > 0 THEN
        UPDATE ViewRent VR
        SET
            VR.TotNumRents = VR.TotNumRents + :NEW.NumRents,
            VR.TotRevenue = VR.TotRevenue + :NEW.Revenue,
            VR.TotKMTraveled = VR.TotKMTraveled + :NEW.KMTraveled
        WHERE VR.ClientType = varClientType
          AND VR.PaymentMethod = varPaymentMethod
          AND VR.Brand = varBrand
          AND VR.Type = varType
          AND VR.3M = var3M
          AND VR.Year = varYear
          AND VR.Region = varRegion
          AND VR.Country = varCountry;
    ELSE
        INSERT INTO ViewRent (
            ClientType,
            PaymentMethod,
            Brand,
            Type,
            3M,
            Year,
            Region,
            Country,
            TotNumRents,
            TotRevenue,
            TotKMTraveled
        )
        VALUES (
            varClientType,
            varPaymentMethod,
            varBrand,
            varType,
            var3M,
            varYear,
            varRegion,
            varCountry,
            :NEW.NumRents,
            :NEW.Revenue,
            :NEW.KMTraveled
        );
    END IF;
END;
/
