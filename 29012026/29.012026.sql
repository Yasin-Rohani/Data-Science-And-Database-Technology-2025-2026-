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

SELECT Minibar, Safe, Revenue, RegionH, "2-Months", CityH , Year , "3-MOnths" , ProvinceH , SUM(Revenue) as TotRev
FROM ROOM-TYPE RT , TIME T , BOOKINGS B , HOTELS H
WHERE RT.TimeID = T.TIMEID AND RT.RTID = B.RTID AND H.HotelID = B.HotelID
GROUP BY Minibar, Safe, RegionH, "2-Months", CityH , Year , "3-MOnths" , ProvinceH

2.Minimal set
Minibar, Safe, "2-Months", CityH , "3-MOnths" 

3. Trigger
CREAT OR REPLACE TRIGGER TriggerViewBooking
AFTER INSER ON BOOKINGS
FOR EACH ROW 
BEGIN
UPDATE VEIWBOOKING V
set

V.TotRev = V.TotRev + :NEW.Revenue
WHERE V.CityH = (SELECT H.CityH FROM Hotel H WHERE H.HotelID = :NEW.HotelID)
AND V.Minibar = (SELECT RT.Minibar FROM "ROOM-Type" RT WHERE RT.RTID = :NEW.RTID)
AND V.Safe = (SELECT RT.Safe FROM "ROOM-Type" RT WHERE RT.RTID = :NEW.RTID)
AND V.RegionH = (SELECT H.RegionH FROM Hotel H WHERE H.HotelID = :NEW.HotelID)
AND V."2-Months" = (SELECT T."2-Months" FROM Time T WHERE TimeID = :NEW.TimeID)
AND V."3-Months" = (SELECT T."3-Months" FROM Time T WHERE TimeID = :NEW.TimeID)
AND V."Year" = (SELECT T."Year" FROM Time T WHERE TimeID = :NEW.TimeID)
AND V.ProvinceH = (SELECT H.ProvinceH FROM Hotel H WHERE H.HotelID = :NEW.HotelID)

IF SQL%ROWCOUNT = 0 THEN
INSERT INTO VeiwBookings
SELECT RT.Minibar, RT.Safe, H.RegionH, T."2-Months", H.CityH , T.Year , T."3-MOnths" , H.ProvinceH , :NEW.Revenue
FROM ROOM-TYPE RT , TIME T , HOTELS H
WHERE H.HotelID =:NEW.HotelID AND RT.RTID = :NEW.RTID AND TimeID = :NEW.TimeID
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