USE Dmart;

SELECT
    P.BlankSeria AS [sagr],
    P.BlankNumber AS [nagr],
    P.SupplementaryAgreementTypeId AS [compl],
    bD.Date AS [d_beg],
    eD.Date AS [d_end],
    P.Validity AS [c_term],
    rD.Date AS [d_distr],
    PA.IsActive1 AS [is_active1],
    PA.IsActive2 AS [is_active2],
    PA.IsActive3 AS [is_active3],
    PA.IsActive4 AS [is_active4],
    PA.IsActive5 AS [is_active5],
    PA.IsActive6 AS [is_active6],
    PA.IsActive7 AS [is_active7],
    PA.IsActive8 AS [is_active8],
    PA.IsActive9 AS [is_active9],
    PA.IsActive10 AS [is_active10],
    PA.IsActive11 AS [is_active11],
    PA.IsActive12 AS [is_active12],
	PPr.[Value] AS [c_privileg],
	Dis.[Value] AS [c_discount],
	Z.[Zone] AS  [zone],
	Bm.[Value] AS [b_m],
	P.C1Value AS K1,
	P.C2Value AS K2,
	P.C3Value AS K3,
	P.C4Value AS K4,
	P.C5Value AS K5,
	P.C6Value AS K6,
	P.C7Value AS K7,
	P.C8Value AS K8,
	P.HealthCover AS [limit_life],
	P.EstateCover AS [limit_prop],
	P.Franchise AS [franchise],
	P.PlanedPaymentValue AS [payment],
	P.RealPaymentValue AS [paym_bal],
	Br.BranchCode AS [note],
	PC.CancelDate AS [d_abort],
	PC.RetPaymentValue AS [retpayment],
	P.BaseBlankSeria AS [chng_sagr],
	P.BlankNumber AS [chng_nagr],
	F.Resident AS [resident],
	F.[PersonType] AS [status_prs],
	F.[FaceIDN] AS [numb_ins],
	F.LastName  AS [f_name],
	F.Firstname	AS [s_name],
	F.Secondname AS [p_name],
	F.Birthdate AS [birth_date],
	'' AS [doc_name],
	F.PassportSeria AS [doc_series],
	F.PassportNumber AS [doc_no],
	F.Gender AS [person_s],
	cast(IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, 
        IIF(Z.Zone = '7', '3345', RS.RegulatorId), 
        IIF(Z.Zone = '6', '3345', ISNULL(OS.RegulatorId, '3797'))) as nvarchar(50)) AS [c_city],
	IIF(P.RegisteredDate < 20190921 or P.BasePolisRegisteredDate < 20190921, RS.SettlementName, OS.SettlementName) AS [city_name],
	F.DriversLicenseSeria AS [ser_ins],
	F.DriversLicenseNumber AS [num_ins],
	F.DriverFrom AS [exprn_ins],

	V.FullModelName AS [auto], --todo: in Vehicle model

	V.RegistrationNumber AS [reg_no],
	V.BodyNumber AS [vin],
	V.RegulatorObjectCategoryId AS [c_type],

	cast(V.ManufacturerRegulatorID as nvarchar(50)) AS [c_mark],

	V.Manufacturer AS [mark_txt],

	cast(V.ModelRegulatorID as nvarchar(50)) AS [c_model],

	V.Model AS [model_txt],

	V.ProducedDate AS [prod_year],

	P.SphereUse AS [sphere_use],

	IIF(P.NeedToParameterValueId is not null, cast('TRUE' as nvarchar(5)), 'FALSE') AS [need_to],

	P.DateNextTo AS [date_next_to],
	ET.RegulatorId AS [c_exp],
	P.LastModifiedDate AS [LastModifiedDate]
FROM dbo.OsagoProducts AS P
INNER JOIN dim.Dates as bD on bD.DateId = P.BeginingDate
INNER JOIN dim.Dates as eD on eD.DateId = P.EndingDate
INNER JOIN dim.Dates as rD on rD.DateId = P.RegisteredDate
INNER JOIN dbo.Faces AS F ON F.FaceId = P.InsuredFaceId
INNER JOIN dbo.ParameterActivities AS PA ON PA.ProductId = P.ProductId
INNER JOIN dim.Privilegies AS PPr ON PPr.PrivilegId = P.PrivilegId
INNER JOIN dim.Discounts AS Dis ON Dis.DiscountId = P.DiscountId
INNER JOIN dim.Branches AS Br ON Br.BranchId = P.BranchId
INNER JOIN dim.Zones AS Z ON Z.ZoneId = P.ZoneId
INNER JOIN dim.BonusMaluses AS Bm ON Bm.BonusMalusId = P.BonusMalusId
LEFT JOIN dbo.ProductCancels AS PC ON PC.ProductId = P.ProductId
LEFT JOIN dim.ExperienceTypes as ET on ET.ExperienceTypeId = P.ExperienceTypeId
INNER JOIN dbo.Vehicles AS V ON V.VehicleId = P.VehicleId
INNER JOIN dbo.Settlements AS OS ON OS.SettlementId = V.OwnerRegisteredSettlementId
INNER JOIN dbo.Settlements AS RS ON RS.SettlementId = V.VehiclesRegisteredSettlementId


