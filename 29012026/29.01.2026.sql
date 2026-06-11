
#Extended SQL 4 Points

-- HOTEL (HotelID, HotelName, StarRating, CityH, ProvinceH, RegionH, CountryH)
-- ROOM-TYPE (RTID, Number_Beds, Minibar, AirConditioning, Safe)
-- TIME (TimeID, Date, Month, 2-Months, 3-Months, 4-Months, 6-Months, Year)
-- JUNK-PURCHASE (IDJP, PurchaseChannel, PaymentTerms)
-- GUEST_GEO (GeoID, CityG, CountryG)
-- BOOKINGS (HotelID, RTID, TimeID, IDJP, GeoID, Num_Booked_Rooms, Num_Avail_Rooms, Num_Guests, Revenue)

-- For each hotel province and for each 2-month period, compute:
-- the percentage between the total number of booked rooms and the total number of rooms (considering
-- both booked and available rooms)
-- the percentage of revenue with respect to total revenue considering all hotels located in the same
-- region;
-- the cumulative revenue over successive 2-month periods, computed separately by year and by the
-- region in which the hotel is located.
-- The analysis must be performed separately for each purchase channel.

SELECT ProvunceH , "2-month", PurchaseChannel 

100*SUM(Num_Booked_Rooms)/(SUM(Num_Booked_Rooms)+SUm(Num_Avail_Rooms))
100*SUM(Revenue)/SUM(SUM(Revenue))Over(PARTITION BY RegionH, PurchaseChannel, "2-month")
SUM(SUM(Revenue))OVER(PARTITION BY  Year,Region,PurchaseChannel  ORDER BY "2-Month" ROWS UNBOUNDED PROCEDING)

FROM BOOKINGS B, HOTEL H , TIME T , JUNK-PURCHASE JP
WHERE B.TimeID = T.TimeID AND B.HotelID = H.HotelID AND JP.IDJP = B.IDJP
GROUP BY ProvunceH , "2-month", PurchaseChannel , Year , RegionH

###################################################################################################################################
#Materialzed view


-- HOTEL (HotelID, HotelName, StarRating, CityH, ProvinceH, RegionH, CountryH)
-- ROOM-TYPE (RTID, Number_Beds, Minibar, AirConditioning, Safe)
-- TIME (TimeID, Date, Month, 2-Months, 3-Months, 4-Months, 6-Months, Year)
-- JUNK-PURCHASE (IDJP, PurchaseChannel, PaymentTerms)
-- GUEST_GEO (GeoID, CityG, CountryG)
-- BOOKINGS (HotelID, RTID, TimeID, IDJP, GeoID, Num_Booked_Rooms, Num_Avail_Rooms, Num_Guests, Revenue)

-- Given the above logical scheme, consider the following queries of interest:
-- a. Considering the rooms that offer both minibar service (attribute MiniBar) and a safe (attribute Safe),
-- display the total revenue, separately by hotel region (attribute RegionH) and by 2-Month period.
-- Additionally, display the ranking based on total revenue, separately for each 2-Month period
-- b. For hotels in the city of Turin, show the cumulative value of revenue over two months (attribute 2-
-- Months), separately for each year.
-- c. Separately by 3-Month period and by hotel region, for rooms equipped with a safe, display the
-- percentage of revenue with respect to the total revenue by hotel state and year.

-- Given the above logical schema, answer the following requests:
-- 1. Define a materialized view with the CREATE MATERIALIZED VIEW, that can be used to efficiently answer
-- all three of the above queries (i.e., a, b, c). Specifically, define the query in SQL associated with BLOCK A
-- in the following instruction
-- CREATE MATERIALIZED VIEW ViewBookings
-- BUILD IMMEDIATE
-- REFRESH FAST ON COMMIT
-- AS
-- Block A

-- 2. Define the minimal set of attributes that allows identifying the tuples belonging to the materialized
-- view ViewBookings.

-- 3. Assume that the management of the materialized view (derived table) is carried out by means of
-- triggers. Write the trigger to propagate to the ViewBookings materialized view the changes due to the
-- insertion of a new record into the BOOKINGS fact table

1. BLOCK A 

SELECT Minibar, Safe,  CountryH, "2-Months", CityH , Year , "3-MOnths" , SUM(Revenue) as TotRev
FROM ROOM_TYPE RT , TIME T , BOOKINGS B , HOTELS H
WHERE RT.TimeID = T.TIMEID AND RT.RTID = B.RTID AND H.HotelID = B.HotelID
GROUP BY Minibar, Safe, RegionH, "2-Months", CityH , Year , "3-MOnths" , ProvinceH

2.Minimal set
Minibar, Safe, "2-Months", CityH , "3-MOnths" , CountryH

3. Trigger
######################################ُ
CREATE OR REPLACE TRIGGER TriggerBookingView
AFTER INSERT ON BOOKINGS
FOR EACH ROW
DECLARE 
varCityH VARCHAR(50)
varRegionH VARCHAR(50)
varCountryH VARCHAR(50)ُ
varMinbar VARCHAR(10)
varSafe VARCHAR(10)
var2M VARCHAR(20)
var3M VARCHAR(20)
varYear INTEGER;
N INTEGER;
BEGIN
######################################

SELECT CityH, CountryH , RegionH
INTO varCityH, varRegionH, varCountryH
FROM HOTEL
WHERE HotelID = :NEW.HotelID;

SELECT Minibar, Safe
INTO varMinbar, varSafe
FROM ROOM_TYPE
WHERE RTID = :NEW.RTID;


SELECT 2M , 3M , Year
INTO var2M , var3M
FROM TIME
WHERE TimeID = :NEw.TimeID;

SELECT Count(*)
INTO N
FROM ViewBooking
WHERE CityH = varCityH
AND Minibar = varMinibar
AND Safe = varSafe
AND "2-Months" = var2M
AND "3-Months" = var3M;

######################################
IF N > 0 THEN;

UPDATE TotRev = TotRev + :NEW.Revenue;

ELSE
INSERT INTO ViewBooking(
     CityH, RegionH, CountryH,
    Minibar, Safe,
    "2-Months", "3-Months", Year,
    TotRevenue
)

VALUES
(
    varCityH, varRegionH, varCountryH,
    varMinibar, varSafe,
    var2M, var3M, varYear,
    :NEW.Revenue
);

END IF;
END;
###################################################################################################################################

#Extended SQL 3 Points

-- HOTEL (HotelID, HotelName, StarRating, CityH, ProvinceH, RegionH, CountryH)
-- ROOM-TYPE (RTID, Number_Beds, Minibar, AirConditioning, Safe)
-- TIME (TimeID, Date, Month, 2-Months, 3-Months, 4-Months, 6-Months, Year)
-- JUNK-PURCHASE (IDJP, PurchaseChannel, PaymentTerms)
-- GUEST_GEO (GeoID, CityG, CountryG)
-- BOOKINGS (HotelID, RTID, TimeID, IDJP, GeoID, Num_Booked_Rooms, Num_Avail_Rooms, Num_Guests, Revenue)

-- For each city of origin of the guest and for each 6-Month period, compute:
-- the average number of guests per booked room;
-- the percentage of revenue relative to the total revenue considering the guest’s country of origin;
-- the total revenue, computed separately by year and by the guest’s country of origin.
-- Assign to each record a rank, computed separately for each year, based on total revenue

SELECT CityG , "6-months"

SUM(Num_Guest)/SUM(Num_Booked_Rooms),
100*SUM(Revenue)/SUM(SUM(Revenue))OVER(PARTITION BY CountryG, "6-Months"),
SUM(SUM(Revenue))OVER(PARTITION BY Year,CountryG),
RANK()OVER(PARTITION BY Year ORDER BY SUM(Revenue) DESC)

FROM BOOKINGS B, TIME T , Guest_GEO GG
WHERE B.TimeID = T.TimeID  AND GG.GeoID=B.GeoID
GROUP BY CityG , "6-months" , Year , ConntryG


###################################################################################################################################

#Extended SQL 4 Points

-- HOTEL (HotelID, HotelName, StarRating, CityH, ProvinceH, RegionH, CountryH)
-- ROOM-TYPE (RTID, Number_Beds, Minibar, AirConditioning, Safe)
-- TIME (TimeID, Date, Month, 2-Months, 3-Months, 4-Months, 6-Months, Year)
-- JUNK-PURCHASE (IDJP, PurchaseChannel, PaymentTerms)
-- GUEST_GEO (GeoID, CityG, CountryG)
-- BOOKINGS (HotelID, RTID, TimeID, IDJP, GeoID, Num_Booked_Rooms, Num_Avail_Rooms, Num_Guests, Revenue)

-- Considering room types equipped with air conditioning and a safe, for each 4-month period and for each hotel
-- name, compute:
-- the average monthly revenue;
-- the ratio between revenue generated from bookings and total revenue considering the hotel’s star
-- rating;
-- total revenue, computed separately by year and by the hotel’s star rating.
-- Perform the analysis separately by payment terms and by the guest’s country of origin.

SELECT T."4-Months" , H.HotelName, JP.PaymentTerms , G.CountryG

SUM(B.Revenue) / COUNT(DISTINCT T.Month)                               # Average Monthly Revenue
SUM(Revenue)/SUM(SUM(Revenue))OVER(PARTITION BY H.StarRating, JP.PaymentTerms, G.CountryG)            
SUM(SUM(Revenue))OverVER(PARTITION BY T.Year, H.StarRating, JP.PaymentTerms, G.CountryG)

FROM BOOKINGS B, ROOM-TYPE RT, GUEST_GEO G , TIME T , JUNK-PURCHASE JP , HOTEL H
WHERE AirConditioning = "yes" AND Safe = "yes" , B.TimeID = T.TimeID  AND G.GeoID=B.GeoID AND B.HotelID = H.HotelID AND JP.IDJP = B.IDJP AND B.RTID = RT.RTID

GROUP BY T."4-Months" , H.HotelName, JP.PaymentTerms , G.CountryG , H.StraRAting , T.Year

