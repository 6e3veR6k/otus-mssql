 -- Описание:
 -- Проект хранилища данных(DWH) по договорам страхования ОСАГО
 -- В бд в течении дня должны загружатся договора из основной OLTP системы
 -- В бд должна храниться история изменений договоров (я решил попробовать воспользоваться для этого System-Versioned tables)
 -- Из этой бд в течении дня должны выгружаться данные во внешний источник в определенном формате
 -- БД также будет источником для разного рода аналитических отчетов, отчетов ReportingServices
 -- возможно для OLAB кубов
 -- есть определенный набор отчетов для которых бд будет дополняться и расширяться
 -- планируется создать процедуру для внешнего источника
 -- вьюхи для разного типа отчетов
 -- пример запроса в файле ./dmart-products.sql

USE master
GO


/* ========================================================================== */
/*  							Create database 							  */
/* ========================================================================== */


DROP DATABASE IF EXISTS [Dmart]
GO

CREATE DATABASE [Dmart] ON PRIMARY 
(	
	NAME = N'DmartData', 
	FILENAME = N'C:\SQL\Data\Dmart.mdf',
	SIZE = 500MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 2048KB 
) LOG ON 
( 
	NAME = N'DmartLog', 
	FILENAME = N'C:\SQL\Log\Dmart_log.ldf',
	SIZE = 100MB,
	MAXSIZE = 1024GB,
	FILEGROWTH = 10%
)
COLLATE Cyrillic_General_CI_AS
GO
ALTER DATABASE [Dmart] SET RECOVERY SIMPLE
GO


/* ========================================================================== */
/*  		Create schemas for dimensions and stages tables 				  */
/* ========================================================================== */


USE Dmart
GO
CREATE SCHEMA [dim] AUTHORIZATION [dbo]
GO
CREATE SCHEMA [stg] AUTHORIZATION [dbo]
GO
CREATE SCHEMA [Osago] AUTHORIZATION [dbo]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/* ========================================================================== */
/*  						Create table dim.Dates			 				  */
/* ========================================================================== */

CREATE TABLE [dim].[Dates]
(
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[DayOfYear] [smallint] NOT NULL,
	[WeekOfMonth] [tinyint] NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[MonthName] [varchar](10) NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[Year] [int] NOT NULL,
	[MMYYYY] [char](6) NOT NULL,
	[FirstDayOfMonth] [date] NOT NULL,
	[LastDayOfMonth] [date] NOT NULL,
	[FirstDayOfQuarter] [date] NOT NULL,
	[LastDayOfQuarter] [date] NOT NULL,
	[FirstDayOfYear] [date] NOT NULL,
	[LastDayOfYear] [date] NOT NULL,
	[FirstDayOfNextMonth] [date] NOT NULL,
	[FirstDayOfNextYear] [date] NOT NULL,
	[MonthNameUkr] [varchar](20) NULL,
	CONSTRAINT [PK_DateKey] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO




/* ========================================================================== */
/*  						Create table dim.Dates			 				  */
/* ========================================================================== */

CREATE TABLE [dim].[ProgramTypes]
(
	[ProgramTypeId] [bigint] NOT NULL,
	[Code] [nvarchar](10) NOT NULL,
	[Name] [nvarchar](180) NOT NULL,
	[IsOld] [bit] NOT NULL,
	[InitDate] [date] NOT NULL,
	[IssueDate] [date] NOT NULL,
	CONSTRAINT [PK_ProgramTypesProgramTypeId] PRIMARY KEY CLUSTERED 
(
	[ProgramTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/* ========================================================================== */
/*  						Create table Osago.Branches		 				  */
/* ========================================================================== */
CREATE TABLE [Osago].[Branches]
(
	[WhBranchId] [int] NOT NULL,
	[BranchCode] [varchar](10) NULL,
	[Name] [nvarchar](255) NOT NULL,
	[SourceGID] [uniqueidentifier] NOT NULL,
	[ParentBranchCode] [varchar](4) NULL,
	[WhParentBranchId] [int] NULL,
	[ParentBranchName] [nvarchar](255) NULL,
	[DirectionCode] [varchar](2) NULL,
	[DirectionWhId] [int] NULL,
	[DirectionName] [nvarchar](255) NULL,
	CONSTRAINT [PK_WhBranchId] PRIMARY KEY CLUSTERED 
(
	[WhBranchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [Osago].[Branches]  WITH CHECK ADD  CONSTRAINT [FK_DirectionWhId] FOREIGN KEY([DirectionWhId])
REFERENCES [Osago].[Branches] ([WhBranchId])
GO

ALTER TABLE [Osago].[Branches] CHECK CONSTRAINT [FK_DirectionWhId]
GO

ALTER TABLE [Osago].[Branches]  WITH CHECK ADD  CONSTRAINT [FK_WhParentBranchId] FOREIGN KEY([WhParentBranchId])
REFERENCES [Osago].[Branches] ([WhBranchId])
GO

ALTER TABLE [Osago].[Branches] CHECK CONSTRAINT [FK_WhParentBranchId]
GO



/* ========================================================================== */
/*  						Create table Osago.BonusMaluses	 				  */
/* ========================================================================== */
CREATE TABLE [Osago].[BonusMaluses]
(
	[BonusMalusId] [bigint] NOT NULL,
	[BonusMalusGid] [uniqueidentifier] NOT NULL,
	[ProgramParameterGID] [uniqueidentifier] NULL,
	[Class] [int] NULL,
	[CoefficientValue] [decimal](18, 2) NULL,
	CONSTRAINT [PK_BonusMalusId] PRIMARY KEY CLUSTERED 
(
	[BonusMalusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO




/* ========================================================================== */
/*  						Create table Osago.Discounts	 					  */
/* ========================================================================== */
CREATE TABLE [Osago].[Discounts]
(
	[DiscountId] [bigint] NOT NULL,
	[DiscountGid] [uniqueidentifier] NOT NULL,
	[Value] [int] NULL,
	[Comment] [nvarchar](50) NULL,
	[DiscountCoefficient] [int] NULL,
	CONSTRAINT [PK_DiscountId] PRIMARY KEY CLUSTERED 
(
	[DiscountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO




/* ========================================================================== */
/*  						Create table Osago.ExperienceTypes				  */
/* ========================================================================== */
CREATE TABLE [Osago].[ExperienceTypes]
(
	[ExperienceTypeId] [bigint] NOT NULL,
	[ExperienceTypeGid] [uniqueidentifier] NOT NULL,
	[Caption] [nvarchar](50) NULL,
	[RegulatorId] [int] NULL,
	CONSTRAINT [PK_ExperienceTypeId] PRIMARY KEY CLUSTERED 
(
	[ExperienceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO





/* ========================================================================== */
/*  						Create table Osago.Privilegies					  */
/* ========================================================================== */
CREATE TABLE [Osago].[Privilegies]
(
	[PrivilegId] [bigint] NOT NULL,
	[PrivilegGid] [uniqueidentifier] NOT NULL,
	[Comment] [nvarchar](100) NULL,
	[Value] [int] NOT NULL,
	CONSTRAINT [PK_PrivilegId] PRIMARY KEY CLUSTERED 
(
	[PrivilegId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]



/* ========================================================================== */
/*  						Create table Osago.Zones							  */
/* ========================================================================== */
CREATE TABLE [Osago].[Zones]
(
	[ZoneId] [bigint] NOT NULL,
	[ZoneGid] [uniqueidentifier] NOT NULL,
	[Caption] [nvarchar](500) NOT NULL,
	[Value] [nvarchar](1) NOT NULL,
	CONSTRAINT [PK_ZoneId] PRIMARY KEY CLUSTERED 
(
	[ZoneId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


/* ========================================================================== */
/*  						Create table Osago.SupplementaryAgreementTypes					  */
/* ========================================================================== */

CREATE TABLE [Osago].[SupplementaryAgreementTypes]
(
	[SupplementaryAgreementTypeId] [bigint] NOT NULL,
	[SupplementaryAgreementTypeGid] [uniqueidentifier] NULL,
	[Name] [nvarchar](255) NULL,
	[RegulatorIdCompl]  AS (case [SupplementaryAgreementTypeId] when (1) then (1) when (3) then (1) when (7) then (4) when (8) then (4) when (5) then (3) when (4) then (1)  end),
	CONSTRAINT [PK_SupplementaryAgreementTypeId] PRIMARY KEY CLUSTERED 
(
	[SupplementaryAgreementTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]



/* ========================================================================== */
/*  						Create table Osago.Settlements					  */
/* ========================================================================== */
CREATE TABLE [Osago].[Settlements]
(
	[SettlementWhId] [bigint] IDENTITY(1,1) NOT NULL,
	[SettlementId] [bigint] NOT NULL,
	[SettlementGid] [uniqueidentifier] NOT NULL,
	[SettlementName] [nvarchar](250) NOT NULL,
	[SettlementClearName] [nvarchar](250) NULL,
	[SettlementTypeName] [nvarchar](20) NULL,
	[SettlementShortTypeName] [nvarchar](4) NULL,
	[RegulatorDCity] [int] NULL,
	[RegulatorDZone] [int] NULL,
	[DistrictName] [nvarchar](250) NOT NULL,
	[RegionName] [nvarchar](250) NULL,
	[ValidFrom] [date] NULL,
	[ValidTo] [date] NULL,
	[Current] [bit] NULL,
	CONSTRAINT [PK_SettlementWhId] PRIMARY KEY NONCLUSTERED 
(
	[SettlementWhId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


/* ========================================================================== */
/*  						Create table Osago.Faces					  */
/* ========================================================================== */
CREATE TABLE [Osago].[Faces]
(
	[FaceId] [bigint] NOT NULL,
	[FaceGid] [uniqueidentifier] NOT NULL,
	[FirstName] [nvarchar](255) NULL,
	[SecondName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[PersonTypeID] [nvarchar](1) NOT NULL,
	[FaceIDN] [nvarchar](15) NULL,
	[Birthdate] [date] NULL,
	[PhoneNumber] [nvarchar](30) NULL,
	[Passport] [nvarchar](50) NULL,
	[PassportSeria] [nvarchar](2) NULL,
	[PassportNumber] [nvarchar](50) NULL,
	[Gender] [nvarchar](1) NOT NULL,
	[ser_ins] [nvarchar](3) NULL,
	[num_ins] [nvarchar](10) NULL,
	[DriverFrom] [int] NULL,
	[IsResident] [nvarchar](5) NOT NULL,
	[Address] [nvarchar](255) NULL,
	[ActualAddress] [nvarchar](255) NULL,
	[PostAddressGID] [uniqueidentifier] NULL,
	[PostActualAddressGID] [uniqueidentifier] NULL,
	[PostAddress] [nvarchar](2000) NULL,
	[PostActualAddress] [nvarchar](2000) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	CONSTRAINT [PK_FacesFaceId] PRIMARY KEY CLUSTERED 
(
	[FaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [Osago].[FacesHistory] )
)
GO


CREATE NONCLUSTERED INDEX [IX_FacesFaceIDN] ON [Osago].[Faces]([FaceIDN] ASC)

/* ========================================================================== */
/*  						Create table Osago.Vehicles					  */
/* ========================================================================== */
CREATE TABLE [Osago].[Vehicles]
(
	[VehicleId] [bigint] NOT NULL,
	[TechDocModel] [nvarchar](250) NULL,
	[RegistrationNumber] [nvarchar](50) NULL,
	[BodyNumber] [nvarchar](50) NULL,
	[ProducedDate] [int] NULL,
	[WhModelId] [bigint] NOT NULL,
	[Model] [nvarchar](150) NOT NULL,
	[ModelRegulatorID] [int] NULL,
	[Manufacturer] [nvarchar](100) NOT NULL,
	[ManufacturerRegulatorID] [int] NULL,
	[OwnerRegisteredSettlementWhId] [bigint] NULL,
	[VehiclesRegisteredSettlementWhId] [bigint] NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	CONSTRAINT [PK_OsagoVehiclesVehicleId] PRIMARY KEY CLUSTERED 
(
	[VehicleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [Osago].[VehiclesHistory] )
)
GO

ALTER TABLE [Osago].[Vehicles]  WITH CHECK ADD  CONSTRAINT [FK_VehiclesOwnerRegisteredSettlementWhId] FOREIGN KEY([OwnerRegisteredSettlementWhId])
REFERENCES [Osago].[Settlements] ([SettlementWhId])
GO

ALTER TABLE [Osago].[Vehicles] CHECK CONSTRAINT [FK_VehiclesOwnerRegisteredSettlementWhId]
GO

ALTER TABLE [Osago].[Vehicles]  WITH CHECK ADD  CONSTRAINT [FK_VehiclesVehiclesRegisteredSettlementWhId] FOREIGN KEY([VehiclesRegisteredSettlementWhId])
REFERENCES [Osago].[Settlements] ([SettlementWhId])
GO

ALTER TABLE [Osago].[Vehicles] CHECK CONSTRAINT [FK_VehiclesVehiclesRegisteredSettlementWhId]
GO

CREATE NONCLUSTERED INDEX [IX_VehiclesRegistrationNumber] ON [Osago].[Vehicles]([RegistrationNumber] ASC)



/* ========================================================================== */
/*  						Create table Osago.VehicleTypes				  */
/* ========================================================================== */

CREATE TABLE [Osago].[VehicleTypes]
(
	[VehicleTypeId] [bigint] NOT NULL,
	[VehicleTypeGid] [uniqueidentifier] NULL,
	[Category] [nvarchar](100) NULL,
	[Value] [nvarchar](3) NULL,
	[RegulatorCTypeId]  AS (case [Value] when 'B1' then (1) when 'B2' then (2) when 'B3' then (3) when 'B4' then (4) when 'A1' then (5) when 'A2' then (6) when 'C1' then (7) when 'C2' then (8) when 'D1' then (9) when 'D2' then (10) when 'F' then (11) when 'E' then (12) when 'B' then (13) when 'A' then (14) when 'C' then (15) when 'D' then (16) when 'B5' then (17)  end),
	CONSTRAINT [PK_ObjectTypeId] PRIMARY KEY CLUSTERED 
(
	[VehicleTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

/* ========================================================================== */
/*  						Create table Osago.Products					  */
/* ========================================================================== */

CREATE TABLE [Osago].[Products]
(
	[ProductId] [bigint] NOT NULL,
	[ProgramId] [bigint] NOT NULL,
	[ProgramTypeId] [bigint] NOT NULL,
	[PolisNumber] [nvarchar](50) NOT NULL,
	[WhBranchId] [int] NOT NULL,
	[BeginingDate] [int] NOT NULL,
	[EndingDate] [int] NOT NULL,
	[RegisteredDate] [int] NOT NULL,
	[Duration] [int] NOT NULL,
	[BasePolisNumber] [nvarchar](50) NULL,
	[BasePolisRegisteredDate] [int] NULL,
	[SupplementaryAgreementType] [int] NULL,
	[AgentReportDate] [int] NULL,
	[AgentReportNumber] [nvarchar](50) NULL,
	[InsuredFaceId] [bigint] NOT NULL,
	[Comment] [nvarchar](255) NULL,
	[ContractGID] [uniqueidentifier] NULL,
	[SupplementaryAgreementTypeId] [bigint] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CostValue] [decimal](18, 2) NOT NULL,
	[VehicleId] [bigint] NOT NULL,
	[VehicleTypeId] [bigint] NOT NULL,
	[InsuredObjectComment] [nvarchar](255) NULL,
	[InsuranceSum] [decimal](18, 2) NULL,
	[InsuranceRate] [decimal](18, 10) NULL,
	[InsuredObjectName] [nvarchar](900) NULL,
	[PValue] [decimal](18, 2) NULL,
	[RValue] [decimal](18, 2) NULL,
	[BValue] [decimal](18, 2) NULL,
	[RealPaymentDate] [date] NULL,
	[BonusMalusId] [bigint] NULL,
	[DiscountId] [bigint] NULL,
	[ZoneId] [bigint] NULL,
	[ExperienceTypeId] [bigint] NULL,
	[PrivilegId] [bigint] NULL,
	[SphereUse] [int] NOT NULL,
	[NeedTo] [varchar](5) NOT NULL,
	[DateNextTo] [date] NULL,
	[C1Value] [decimal](18, 2) NULL,
	[C2Value] [decimal](18, 2) NULL,
	[C3Value] [decimal](18, 2) NULL,
	[C4Value] [decimal](18, 2) NULL,
	[C5Value] [decimal](18, 2) NULL,
	[C6Value] [decimal](18, 2) NULL,
	[C7Value] [decimal](18, 2) NULL,
	[C8Value] [decimal](18, 2) NULL,
	[C9Value] [decimal](18, 2) NULL,
	[C10Value] [decimal](18, 2) NULL,
	[C1CalculatedValue] [decimal](18, 2) NULL,
	[C2CalculatedValue] [decimal](18, 2) NULL,
	[C3CalculatedValue] [decimal](18, 2) NULL,
	[C4CalculatedValue] [decimal](18, 2) NULL,
	[C5CalculatedValue] [decimal](18, 2) NULL,
	[C6CalculatedValue] [decimal](18, 2) NULL,
	[C7CalculatedValue] [decimal](18, 2) NULL,
	[C8CalculatedValue] [decimal](18, 2) NULL,
	[C9CalculatedValue] [decimal](18, 2) NULL,
	[C10CalculatedValue] [decimal](18, 2) NULL,
	[Franchise] [int] NULL,
	[EstateCover] [decimal](18, 2) NULL,
	[HealthCover] [decimal](18, 2) NULL,
	[Deleted] [int] NOT NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	CONSTRAINT [PK_OsagoProductsProductId] PRIMARY KEY NONCLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [Osago].[ProductsHistory] )
)
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsBasePolisRegisteredDate] FOREIGN KEY([BasePolisRegisteredDate])
REFERENCES [dim].[Dates] ([DateKey])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsBasePolisRegisteredDate]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsBeginingDate] FOREIGN KEY([BeginingDate])
REFERENCES [dim].[Dates] ([DateKey])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsBeginingDate]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsBonusMalusId] FOREIGN KEY([BonusMalusId])
REFERENCES [Osago].[BonusMaluses] ([BonusMalusId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsBonusMalusId]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsDiscountId] FOREIGN KEY([DiscountId])
REFERENCES [Osago].[Discounts] ([DiscountId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsDiscountId]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsEndingDate] FOREIGN KEY([EndingDate])
REFERENCES [dim].[Dates] ([DateKey])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsEndingDate]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsExperienceTypeId] FOREIGN KEY([ExperienceTypeId])
REFERENCES [Osago].[ExperienceTypes] ([ExperienceTypeId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsExperienceTypeId]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsInsuredFaceId] FOREIGN KEY([InsuredFaceId])
REFERENCES [Osago].[Faces] ([FaceId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsInsuredFaceId]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsPrivilegId] FOREIGN KEY([PrivilegId])
REFERENCES [Osago].[Privilegies] ([PrivilegId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsPrivilegId]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsProgramTypeId] FOREIGN KEY([ProgramTypeId])
REFERENCES [dim].[ProgramTypes] ([ProgramTypeId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsProgramTypeId]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsRegisteredDate] FOREIGN KEY([RegisteredDate])
REFERENCES [dim].[Dates] ([DateKey])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsRegisteredDate]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsSupplementaryAgreementTypeId] FOREIGN KEY([SupplementaryAgreementTypeId])
REFERENCES [Osago].[SupplementaryAgreementTypes] ([SupplementaryAgreementTypeId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsSupplementaryAgreementTypeId]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsVehicleId] FOREIGN KEY([VehicleId])
REFERENCES [Osago].[Vehicles] ([VehicleId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsVehicleId]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsVehicleTypeId] FOREIGN KEY([VehicleTypeId])
REFERENCES [Osago].[VehicleTypes] ([VehicleTypeId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsVehicleTypeId]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsWhBranchId] FOREIGN KEY([WhBranchId])
REFERENCES [Osago].[Branches] ([WhBranchId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsWhBranchId]
GO

ALTER TABLE [Osago].[Products]  WITH CHECK ADD  CONSTRAINT [FK_OsagoProductsZoneId] FOREIGN KEY([ZoneId])
REFERENCES [Osago].[Zones] ([ZoneId])
GO

ALTER TABLE [Osago].[Products] CHECK CONSTRAINT [FK_OsagoProductsZoneId]
GO


CREATE UNIQUE CLUSTERED INDEX [CIX_ProductsBeginingDateProductId] ON [Osago].[Products]( [BeginingDate] DESC, [ProductId] DESC )
GO

CREATE NONCLUSTERED INDEX [IX_ProductsLastModifiedDate] ON [Osago].[Products]( [LastModifiedDate] DESC )
GO

CREATE NONCLUSTERED INDEX [IX_ProductsPolisNumber] ON [Osago].[Products]( [PolisNumber] DESC, [Deleted] DESC )
GO

/* ========================================================================== */
/*  						Create table [Osago].[ParameterActivities]		  */
/* ========================================================================== */
CREATE TABLE [Osago].[ParameterActivities]
(
	[ProductId] [bigint] NOT NULL,
	[IsActive1] [nvarchar](5) NULL,
	[IsActive2] [nvarchar](5) NULL,
	[IsActive3] [nvarchar](5) NULL,
	[IsActive4] [nvarchar](5) NULL,
	[IsActive5] [nvarchar](5) NULL,
	[IsActive6] [nvarchar](5) NULL,
	[IsActive7] [nvarchar](5) NULL,
	[IsActive8] [nvarchar](5) NULL,
	[IsActive9] [nvarchar](5) NULL,
	[IsActive10] [nvarchar](5) NULL,
	[IsActive11] [nvarchar](5) NULL,
	[IsActive12] [nvarchar](5) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	CONSTRAINT [PK_ParameterActivitiesProductId] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [Osago].[ParameterActivitiesHistory] )
)
GO

/* ========================================================================== */
/*  						Create table Osago.ProductCancels					  */
/* ========================================================================== */
CREATE TABLE [Osago].[ProductCancels]
(
	[ProductId] [bigint] NOT NULL,
	[CancelDate] [int] NULL,
	[StatusGID] [uniqueidentifier] NULL,
	[ReturnSum] [decimal](18, 2) NULL,
	[ProductCancelActGID] [uniqueidentifier] NULL,
	[PlanedPaymentRest] [decimal](18, 2) NULL,
	[OnDealSum] [decimal](18, 2) NULL,
	[RetPaymentValue] [decimal](38, 2) NULL,
	[CreateDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [Osago].[ProductCancelsHistory] )
)
GO
