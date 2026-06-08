# Extended SQL (4 points)

SELECT TC.ClubName, TD.2_Months, JL.LessonType , TD.Year, TC.Region, 
SUM(TL.NumHours)/SUM(TL.NumStudent) , SUM(TL.Revenue)/Count(*) , 
SUM(TL.NumHours)/SUM(SUM(TL.Numhours)) OVER (PARTITION BY TC.Region , TD.2_Months, JL.LessonType)
SUM(SUM(TL.NumHours))OVER(PARTION BY TC.ClubName, JL.LessonType, TD.Year ORDER BY TD.2_Months ROWS UNBOUNDED PRECEDING) 
FROM TENNIS-CLUB TC,  JUNk-LESSON JL , TENNIS-LESSONS TL ,TIME-DATE TD 
WHERE TC.Showers = "yes" AND TC.LoungeArea = "yes" AND TL.IDTimeD= TD.IDTimeD AND TL.IDLL= JL.IDJL AND TL.IDClub = TC.IDClub
GROUP BY TD.2_Months, JL.LessonType, TC.Region , TC.ClubName , TD.Year , TC.ClubName

#######################################################################################################################

# Extended SQL (3 points)
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
