#Extended SQL 4 Points

SELECT ProvunceH , "2-month", PurchaseChannel 

100*SUM(Num_Booked_Rooms)/(SUM(Num_Booked_Rooms)+SUm(Num_Avail_Rooms))
100*SUM(Revenue)/SUM(SUM(Revenue))Over(PARTITION BY RegionH, PurchaseChannel, "2-month")
SUM(SUM(Revenue))OVER(PARTITION BY  Year,Region,PurchaseChannel  ORDER BY "2-Month" ROWS UNBOUNDED PROCEDING)

FROM BOOKINGS B, HOTEL H , TIME T , JUNK-PURCHASE JP
WHERE B.TimeID = T.TimeID AND B.HotelID = H.HotelID AND JP.IDJP = B.IDJP
GROUP BY ProvunceH , "2-month", PurchaseChannel , Year , RegionH

-----------------------------------------------------------------------------------------------------------------------------------
#Materialzed view

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
WHERE varCityH = varCityH
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
-----------------------------------------------------------------------------------------------------------------------------------
#Extended SQL 3 Points

SELECT CityG , "6-months" , 

SUM(Num_Guest)/SUM(Num_Booked_Rooms),
100*SUM(Revenue)/SUM(SUM(Revenue))OVER(PARTITION BY CountryG, "6-Months"),
SUM(SUM(Revenue))OVER(PARTITION BY Year,CountryG),
RANK()OVER(PARTITION BY Year ORDER BY SUM(Revenue) DESC)

FROM BOOKINGS B, TIME T , Guest_GEO GG
WHERE B.TimeID = T.TimeID  AND GG.GeoID=B.GeoID
GROUP BY CityG , "6-months" , Year , ConntryG



-----------------------------------------------------------------------------------------------------------------------------------
#Extended SQL 4 Points


SELECT T."4-Months" , H.HotelName, JP.PaymentTerms , G.CountryG

SUM(B.Revenue) / COUNT(DISTINCT T.Month)                               # Average Monthly Revenue
SUM(Revenue)/SUM(SUM(Revenue))OVER(PARTITION BY H.StarRating, JP.PaymentTerms, G.CountryG)            
SUM(SUM(Revenue))OverVER(PARTITION BY T.Year, H.StarRating, JP.PaymentTerms, G.CountryG)

FROM BOOKINGS B, ROOM-TYPE RT, GUEST_GEO G , TIME T , JUNK-PURCHASE JP , HOTEL H
WHERE AirConditioning = "yes" AND Safe = "yes" , B.TimeID = T.TimeID  AND G.GeoID=B.GeoID AND B.HotelID = H.HotelID AND JP.IDJP = B.IDJP AND B.RTID = RT.RTID

GROUP BY T."4-Months" , H.HotelName, JP.PaymentTerms , G.CountryG , H.StraRAting , T.Year