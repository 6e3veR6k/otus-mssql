
SELECT IIF(ISNUMERIC(P.PolisNumber)=1, NULL, LEFT(P.PolisNumber, 2)) AS sagr
    ,IIF(ISNUMERIC(P.PolisNumber)=1, P.PolisNumber, SUBSTRING(P.PolisNumber, 4, 7)) AS nagr
    ,SAT.RegulatorIdCompl AS [compl]
    ,bD.Date AS [d_beg]
    ,eD.Date AS [d_end]
    ,P.Duration AS [c_term]
    ,rD.Date AS [d_distr]
    ,PA.IsActive1 AS [is_active1]
    ,PA.IsActive2 AS [is_active2]
    ,PA.IsActive3 AS [is_active3]
    ,PA.IsActive4 AS [is_active4]
    ,PA.IsActive5 AS [is_active5]
    ,PA.IsActive6 AS [is_active6]
    ,PA.IsActive7 AS [is_active7]
    ,PA.IsActive8 AS [is_active8]
    ,PA.IsActive9 AS [is_active9]
    ,PA.IsActive10 AS [is_active10]
    ,PA.IsActive11 AS [is_active11]
    ,PA.IsActive12 AS [is_active12]
	,COALESCE(Pv.[Value], 0) AS [c_privileg]
	,COALESCE(D.[Value], 0) AS [c_discount]
	,case
        when Z.Value = '1' then '1'
        when Z.Value = '2' then IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, '6', OS.RegulatorDZone)
        when Z.Value = '2' then IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, '6', OS.RegulatorDZone)
        when Z.Value = '3' then IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, '2', '3')
        when Z.Value = '4' then IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, '3', '4')
        when Z.Value = '5' then IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, '4', '5')
        when Z.Value = '6' then IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, '5', '7')
        when Z.Value = '7' then IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, '7', '')
    end as [zone]
	,IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, Bm.Class, NULL) AS [b_m]
	,P.C1Value AS K1
	,P.C2Value AS K2
	,P.C3Value AS K3
	,P.C4Value AS K4
	,P.C5Value AS K5
	,P.C6Value AS K6
	,P.C7Value AS K7
	,IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, NULL, P.C8Value) AS K8 --  null if reg date < 2109
	,P.HealthCover AS [limit_life]
	,P.EstateCover AS [limit_prop]
	,P.Franchise AS [franchise]
	,P.PValue AS [payment]
	,P.RValue AS [paym_bal]
	,B.BranchCode AS [note]
	,CAST(NULL AS DATE) AS [d_abort]
	,CAST(NULL AS DECIMAL(18,2)) AS [retpayment]
	,IIF(ISNUMERIC(P.BasePolisNumber)=1, NULL, LEFT(P.BasePolisNumber, 2)) AS [chng_sagr]
	,IIF(ISNUMERIC(P.BasePolisNumber)=1, P.BasePolisNumber, SUBSTRING(P.BasePolisNumber, 4, 7)) AS [chng_nagr]
	,F.IsResident AS [resident]
	,F.PersonTypeID AS [status_prs]
	,F.FaceIDN AS [numb_ins]
	,CAST(F.Firstname AS NVARCHAR(99)) AS [f_name]
	,CAST(F.Secondname AS NVARCHAR(99)) AS [s_name]
	,F.LastName AS [p_name]
	,F.Birthdate AS [birth_date]
	,'' AS [doc_name]
	,F.PassportSeria AS [doc_series]
	,F.PassportNumber AS [doc_no]
	,F.Gender AS [person_s]
	,cast(IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921,
		IIF(Z.Value = '7', '3345', RS.RegulatorDCity),
        IIF(Z.Value = '6', '3345', ISNULL(OS.RegulatorDCity, '3797'))) as nvarchar(50)) AS [c_city]
	,IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, RS.SettlementName, OS.SettlementName) AS [city_name]
	,F.ser_ins AS [ser_ins]
	,F.num_ins AS [num_ins]
	,F.DriverFrom AS [exprn_ins]
	,V.TechDocModel AS [auto] --todo: in Vehicle model
	,V.RegistrationNumber AS [reg_no]
	,V.BodyNumber AS [vin]
	,VT.RegulatorCTypeId AS [c_type]
	,CAST(V.ManufacturerRegulatorID AS NVARCHAR(50)) AS [c_mark]
	,V.Manufacturer AS [mark_txt]
	,CAST(V.ModelRegulatorID AS NVARCHAR(50)) AS [c_model]
	,V.Model AS [model_txt]
	,V.ProducedDate AS [prod_year]
	,P.SphereUse AS [sphere_use]
	,P.NeedTo AS [need_to]
	,P.DateNextTo AS [date_next_to]
	,ET.RegulatorId AS [c_exp]
	,COUNT(P.ProductId) OVER(PARTITION BY P.PolisNumber) AS [ErrorFlag]
	,P.LastModifiedDate AS [LastModifiedDate]

FROM Osago.Products AS P
LEFT JOIN Osago.SupplementaryAgreementTypes AS SAT ON SAT.SupplementaryAgreementTypeId = P.SupplementaryAgreementTypeId
LEFT JOIN dim.Dates AS bD ON bD.DateKey = P.BeginingDate
LEFT JOIN dim.Dates AS rD ON rD.DateKey = P.RegisteredDate
LEFT JOIN dim.Dates AS eD ON eD.DateKey = P.EndingDate
INNER JOIN dim.ProgramTypes AS PT ON PT.ProgramTypeId = P.ProgramTypeId
INNER JOIN Osago.Branches AS B ON P.WhBranchId = B.WhBranchId
INNER JOIN Osago.Faces AS F ON F.FaceId = P.InsuredFaceId
INNER JOIN Osago.Vehicles AS V ON V.VehicleId = P.VehicleId
LEFT JOIN Osago.ParameterActivities AS PA ON PA.ProductId = P.ProductId
LEFT JOIN Osago.Zones AS Z ON Z.ZoneId = P.ZoneId
LEFT JOIN Osago.BonusMaluses AS BM ON BM.BonusMalusId = P.BonusMalusId
LEFT JOIN Osago.Discounts AS D ON D.DiscountId = P.DiscountId
LEFT JOIN Osago.ExperienceTypes AS ET ON ET.ExperienceTypeId = P.ExperienceTypeId
LEFT JOIN Osago.Privilegies AS Pv ON Pv.PrivilegId = P.PrivilegId
LEFT JOIN Osago.VehicleTypes AS VT ON VT.VehicleTypeId = P.VehicleTypeId
LEFT JOIN Osago.Settlements AS OS ON OS.SettlementWhId = V.OwnerRegisteredSettlementWhId
LEFT JOIN Osago.Settlements AS RS ON RS.SettlementWhId = V.VehiclesRegisteredSettlementWhId
WHERE P.Deleted = 0