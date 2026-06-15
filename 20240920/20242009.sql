-- STORE(IDStore, Store, City, Region, GeoArea)
-- DEVICE-MODEL (IDDeviceModel, DeviceModel, Category)
-- JUNK-INSURANCE_COVERAGES (IDJIC, LegalWarranty, 3-YearExtension, AccidentalDamage, Theft)
-- JUNK-BUYER-FEATURES (IDJBF, Gender, Residence, AgeRange)
-- TIME(IDTime, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- REIMBURSEMENT-CLAIMS (IDStore, IDDeviceModel, IDJIC, IDJBF, IDTime, #ClaimsReceived, #ClaimsCompleted, AmountTotClaimed,
--  AmountTotApproved, DurationTotProcessInDays)

-- Considering insurance coverages that include the extended warranty 
-- -- for 3 years (3-YearExtension) or the extension for accidental damage (AccidentalDamage attribute),
--  -- --separately by bimonth (2-Months) and store, show:

-- The difference between the total number of completed and received claims
-- The average processing time per completed claim 
-- Associate each displayed record with a ranking according to the average duration of processing time per completed claim separately by shop region 
-- -- (1 for the record with the lowest average duration of processing time per claim).


SELECT Store, 2-Months 
SUM(#ClaimsCompleted)-SUM(#Claimreceived)
SUM(DurationTotProcessInDays)/SUM(#ClaimCompleted)
RANK()OVER(PARTITION BY Region ORDER BY SUM(DurationTotProcessInDays)/SUM(#ClaimCompleted) ASC)

FROM REIMBURSEMENT-CLAIMS RC , STORE S , TIME T ,JUNK-INSURANCE_COVERAGES JIC

WHERE RC.IDJIC = JIC.IDJIC AND T.IDTime = RC.IDTime AND S.IDStore=RC.IDStore AND (3-YearExtension='yes' OR AccidentalDamage ='yes')

GROUP BY Store , 2-Months , Region

#########################################################################################################################################################

# EXtended SQL 4 points 

-- STORE(IDStore, Store, City, Region, GeoArea)
-- DEVICE-MODEL (IDDeviceModel, DeviceModel, Category)
-- JUNK-INSURANCE_COVERAGES (IDJIC, LegalWarranty, 3-YearExtension, AccidentalDamage, Theft)
-- JUNK-BUYER-FEATURES (IDJBF, Gender, Residence, AgeRange)
-- TIME(IDTime, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- REIMBURSEMENT-CLAIMS (IDStore, IDDeviceModel, IDJIC, IDJBF, IDTime,
--  #ClaimsReceived, #ClaimsCompleted, AmountTotClaimed, AmountTotApproved, DurationTotProcessInDays)


-- Show separately by shop region and quarter (3-month attribute):
-- The total amount approved
-- The difference between the number of claims received and the number of claims completed, regardless of the shop region
-- The ratio of the total amount claimed and the total amount claimed considering all stores located in the same geographical area.
-- The analysis is carried out separately by gender of the buyer and presence or absence of accidental damage insurance cover.

SELECT Region , 3-Months, Gender , AccidentalDamage
SUM(AmountTotApproved),
SUM(SUM(#ClaimsRecieved))OVER(PARTITION BY 3-Month , Gender , AccidentalDamage)
-
SUM(SUM(#ClaimsCompleted))OVER(PARTITION BY  3-Month , Gender , AccidentalDamage)
SUM(AmountTotClaimed)/SUM(SUM(AmountTotClaimed))OVER(PARTITION BY GeoArea , 3-Month , AccidentalDamage , Gender)

FROM REIMBURSEMENT-CLAIMS RC , STORE S , TIME T ,JUNK-INSURANCE_COVERAGES JIC , JUNK-BUYER-FEATURES JBF
WHERE RC.IDJIC = JIC.IDJIC AND T.IDTime = RC.IDTime AND S.IDStore=RC.IDStore AND JBF.IDJBF = RC.IDJBF

GROUP BY Region , 3-Months, Gender , GeoArea , AccidentalDamage

#####################################################################################################################################################
# EXtended SQL 4 points 

-- STORE(IDStore, Store, City, Region, GeoArea)
-- DEVICE-MODEL (IDDeviceModel, DeviceModel, Category)
-- JUNK-INSURANCE_COVERAGES (IDJIC, LegalWarranty, 3-YearExtension, AccidentalDamage, Theft)
-- JUNK-BUYER-FEATURES (IDJBF, Gender, Residence, AgeRange)
-- TIME(IDTime, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- REIMBURSEMENT-CLAIMS (IDStore, IDDeviceModel, IDJIC, IDJBF, IDTime, #ClaimsReceived,
--  #ClaimsCompleted, AmountTotClaimed, AmountTotApproved, DurationTotProcessInDays)

-- Considering the shops located in Northern Italy (GeoArea=‘North Italy’), separately by electronic device model,
--  bimonthly (attribute 2-Months) and buyer age range, show: 
-- the average processing time duration per completed claim
-- the cumulative amount approved as bimonths pass, separately by year
-- the ratio of the total amount claimed and the total amount claimed considering all models of electronic devices belonging to the same category.

SELECT DeviceModel , 2-Months , AgeRange
SUM(DurationTotProcessInDays)/SUM(#ClaimsCompleted)
SUM(SUM(AmountTotApproved))OVER(PARTITION BY Year, DeviceModel , AgeRange ORDER BY 2_Months ROWS UNBOUNDED PROCEDING)
SUM(AmountTotClaimed)/SUM(SUM(AmountTotClaimed))OVER(PARTITION BY Category , 2-Months , AgeRange) 
FROM TIME T , REIMBURSEMENT-CLAIMS RC , JUNK-BUYER-FEATURES JBF , STORE S ,DEVICE-MODEL DM
WHERE GeoArea = 'North Italy' AND T.IDTime=RC.IDTime AND RC.IDStore=S.IDStore AND RC.IDDeviceModel=DM.IDDeviceModel AND JBF.IDJBF=RC.IDJBF
GROUP BY DeviceModel , 2-Months , AgeRange , Year, Category

#################################################################################################################################################
# Materialiezed View (5 points)
-- STORE(IDStore, Store, City, Region, GeoArea)
-- DEVICE-MODEL (IDDeviceModel, DeviceModel, Category)
-- JUNK-INSURANCE_COVERAGES (IDJIC, LegalWarranty, 3-YearExtension, AccidentalDamage, Theft)
-- JUNK-BUYER-FEATURES (IDJBF, Gender, Residence, AgeRange)
-- TIME(IDTime, Date, Month, 2-Months, 3-Months, 6-Months, Year)
-- REIMBURSEMENT-CLAIMS (IDStore, IDDeviceModel, IDJIC, IDJBF, IDTime, #ClaimsReceived,
--  #ClaimsCompleted, AmountTotClaimed, AmountTotApproved, DurationTotProcessInDays)
-- Given the above logical scheme, consider the following queries of interest: 

-- a. For stores located in the Northwest geographic area (attribute GeoArea),
--  separately by buyer gender and year, show the total number of claims received (attribute #ClaimsReceived),
--   the total number of claims completed (attribute #ClaimsCompleted), and the quarterly average number (attribute 3-Months) of claims received.

-- b. Separately by quarter (3-Months attribute) and store region, show the percentage of the number of completed claims
--  (#ClaimsCompleted attribute) compared to those received (#ClaimsReceived attribute) and the percentage of the number of completed
--   claims compared to the total number of completed claims by year and region.

-- c. Considering buyers in the age group '20-30' (attribute AgeRange),
--  show the cumulative number of claims received as bimonths pass (attribute 2-Months), separately by year.

-- Given the logical scheme above, the following activities should be performed

-- Define a materialized view with CREATE MATERIALIZED VIEW in order to reduce the response time of the queries of interest (a) to (c) above.
--  In particular, specify the SQL query associated with Block A in the following statement:
--             CREATE MATERIALIZED VIEW ViewRequestRefund
--             BUILD IMMEDIATE
--             REFRESH FAST ON COMMIT
--             AS
-- 		BlocK A
-- 2. Define the minimal set of attributes to identify the tuples belonging to the materialised view ViewRequestRefund.

-- 3. Assume that the management of the materialized view (derived table) is carried out using triggers.
--  Write the trigger to propagate changes to the materialized view ViewRequestRefund when a new record is inserted in
--   the REQUEST-REIMBURSEMENT fact table. 


1.
CREATE MATERIALIZED VIEW ViewRequestRefund
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
AS
BlocK A

SELECT GeoArea, Gender , SUM(#ClaimsReceived) AS TotClaimRec , SUM(#ClaimsCompleted) AS TotClaimCom ,3-Months , year , Region , AgeRange
FROM STORE S , JUNK-BUYER-FEATURES JBF , TIME T , REIMBURSEMENT-CLAIMS RC
WHERE RC.IDStore=S.IDStore AND JBF.IDJBF=RC.IDJBF AND T.IDTime=RC.IDTime 
GROUP BY GeoArea, Gender ,3-Months , year , Region , AgeRange

2. The minimal set of attributes : GeoArea, Gender ,3-Months , year , Region , AgeRange


3. 
CREATE OR REPLACE TRIGGER MATVIEW 
AFTER INSERT ON TO REQUEST-REIMBURSEMENT
FOR EACH ROW 
DECLARE;
 GeoAreaVar  VARCHAR(30), GenderVar VARCHAR(30) ,3-MonthsVar VARCHAR(30), yearVar INTEGER , RegionVar VARCHAR(50), AgeRangeVAr VARCHAR(50) , N INTEGER;
 BEGIN;

 SELECT Region, GeoArea INTO RegionVar GeoVar
 FROM STORE
 WHERE  IDStore = :NEW.IDStore

 SELECT Gender , AgeRange INTO GenderVar AgeRangeVar
 FROM JUNK-BUYER-FEATURES
 WHERE  IDJBF = :NEW.IDJBF

 SELECT Year 2-Month INTO YearVar 2-MonthVar
 FROM TIME
 WHERE  IDTime = :NEW.IDTime

 SELECT COUNT(*) INTO N 
 FROM MATVIEW
 WHERE  Region = RegionVAr AND AgeRAnge = AgeRangeVar

IF (N=0) THEN
INSERT INTO MATVIEW(
   GeoArea, Gender ,3-Months , year , Region , AgeRange , TotClaimCom , TotClaimRec
)
VALUES(GeoAreaVar, GenderVar , 3-MonthsVar , yearVar , RegionVar, AgeRangeVAr , :NEW.#ClaimsReceived , :NEW.#ClaimsCompleted)

ELSE ;
UPDATE MATVIEW
SET TotClaimCom = TotClaimCom + :NEW.#ClaimsCompleted , TotClaimRec = TotClaimRec + :NEW.#ClaimsReceived 
WHERE  GeoArea = GeoAreVAr AND Gender = GenderVAr AND 3-Months = 3-MonthsVAr  year AND  Region = RegionVAr AND  AgeRange = AgeRangeVar
END IF;
END;


