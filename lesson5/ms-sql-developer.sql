 -- Описание:
 -- Проект хранилища данных(DWH) по договорам страхования ОСАГО
 -- В бд в течении дня должны загружатся договора из основной OLTP системы
 -- В бд должна храниться история изменений договоров
 -- Из этой бд в течении дня должны выгружаться данные во внешний источник в определенном формате
 -- БД также будет источником для разного рода аналитических отчетов, отчетов ReportingServices
 -- возможно для OLAB кубов
 -- есть определенный набор отчетов для которых бд будет дополняться и расширяться
 -- планируется создать процедуру для внешнего источника
 -- вьюхи для разного типа отчетов


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
	FILEGROWTH = 1024KB 
) LOG ON 
( 
	NAME = N'DmartLog', 
	FILENAME = N'C:\SQL\Log\Dmart_log.ldf',
	SIZE = 500MB,
	MAXSIZE = 2048GB,
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


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/* ========================================================================== */
/*  						Create table dim.Dates			 				  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dim].[Dates]
GO

CREATE TABLE [dim].[Dates](
	[DateId] [int] NOT NULL,
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

    CONSTRAINT [PK_DatesDateId] PRIMARY KEY CLUSTERED ([DateId] DESC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
    ON [PRIMARY]
) ON [PRIMARY]
GO



/* ========================================================================== */
/*  						Create table dim.Branches		 				  */
/* ========================================================================== */
DROP TABLE IF EXISTS  [dim].[Branches]
GO

CREATE TABLE [dim].[Branches](
	[BranchId] [int] NOT NULL,
	[BranchCode] [varchar](10) NOT NULL,
	[DirectionCode] [varchar](2) NULL,
	[ParentBranchCode] [varchar](4) NULL,
	[Name] [nvarchar](255) NOT NULL,
	[ParentBranchId] [int] NOT NULL,

    CONSTRAINT [PK_BranchesBranchId] PRIMARY KEY CLUSTERED ([BranchId] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]
GO



/* ========================================================================== */
/*  						Create table dim.BonusMaluses	 				  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dim].[BonusMaluses]
GO

CREATE TABLE [dim].[BonusMaluses](
    [BonusMalusId] INT NOT NULL,
	[ProgramParameterGID] [uniqueidentifier] NOT NULL,
	[Class] [int] NULL,
	[Value] [decimal](18, 2) NULL,

    CONSTRAINT [PK_BonusMalusesBonusMalusId] PRIMARY KEY CLUSTERED ([BonusMalusId] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
    ON [PRIMARY]
) ON [PRIMARY]
GO



/* ========================================================================== */
/*  						Create table dim.Discounts	 					  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dim].[Discounts]
GO
CREATE TABLE [dim].[Discounts](
    [DiscountId] INT NOT NULL,
	[Value] [int] NOT NULL,
	[Comment] [nvarchar](50) NOT NULL,
	[DiscountCoefficient] [int] NOT NULL,

    CONSTRAINT [PK_DiscountsDiscountId] PRIMARY KEY CLUSTERED ( [DiscountId] ASC )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
    ON [PRIMARY]
) ON [PRIMARY]
GO



/* ========================================================================== */
/*  						Create table dim.ExperienceTypes				  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dim].[ExperienceTypes]
GO

CREATE TABLE [dim].[ExperienceTypes](
    [ExperienceTypeId] INT NOT NULL,
	[Value] [nvarchar](50) NULL,
	[RegulatorId] [int] NULL,

    CONSTRAINT [PK_ExperienceTypesExperienceTypeId] PRIMARY KEY CLUSTERED ([ExperienceTypeId] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]
GO



/* ========================================================================== */
/*  						Create table dim.Privilegies					  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dim].[Privilegies]
GO

CREATE TABLE [dim].[Privilegies](
    [PrivilegId] INT NOT NULL,
	[Comment] [nvarchar](100) NOT NULL,
	[Value] [int] NOT NULL,

	CONSTRAINT [PK_PrivilegiesPrivilegId] PRIMARY KEY CLUSTERED ([PrivilegId] ASC)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
) ON [PRIMARY]
GO



/* ========================================================================== */
/*  						Create table dim.Zones							  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dim].[Zones]
GO

CREATE TABLE [dim].[Zones](
	[ZoneId] INT NOT NULL,
	[gid] [uniqueidentifier] NOT NULL,
	[Value] [nvarchar](500) NOT NULL,
	[Zone] [nvarchar](1) NOT NULL,

	CONSTRAINT [PK_ZonesZoneId] PRIMARY KEY CLUSTERED ([ZoneId] ASC)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
) ON [PRIMARY]
GO



/* ========================================================================== */
/*  						Create table dbo.Settlements					  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dbo].[Settlements]
GO

CREATE TABLE [dbo].[Settlements](
	[SettlementId] INT NOT NULL,
	[SettlementName] [nvarchar](250) NULL,
	[SettlementClearName] [nvarchar](250) NULL,
	[SettlementTypeName] [nvarchar](20) NULL,
	[SettlementShortTypeName] [nvarchar](4) NULL,
	[RegulatorID] [int] NULL,
	[DistrictName] [nvarchar](250) NULL,
	[RegionName] [nvarchar](250) NULL,
	[RegulatorDCity]  AS (case when [RegulatorID] IS NULL then (3797) else [RegulatorID] end),
	[RegulatorDZone] [int] NULL,

	CONSTRAINT [PK_SettlementsSettlementId] PRIMARY KEY CLUSTERED ([SettlementId] ASC)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
) ON [PRIMARY]
GO



/* ========================================================================== */
/*  						Create table dbo.Faces					  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dbo].[Faces]
GO

CREATE TABLE [dbo].[Faces](
	[FaceId] [int] NOT NULL,
	[LastName] [nvarchar](255) NULL,
	[Firstname] [nvarchar](50) NULL,
	[Secondname] [nvarchar](50) NULL,
	[PersonType] [NVARCHAR](1) NULL,
	[PersonTypeId] int NULL,
	[FaceIDN] [nvarchar](15) NULL,
	[BirthDate] [date] NULL,
	[PhoneNumber] [nvarchar](30) NULL,
	[PassportSeria] [nvarchar](4) NULL,
	[PassportNumber] [varchar](10) NULL,
	[Gender] NVARCHAR(1) NULL,
	[DriversLicenseSeria] [nvarchar](3) NULL,
	[DriversLicenseNumber] [nvarchar](10) NULL,
	[DriverFrom] [int] NULL,
	[IsResident] [bit] NULL,
	[Resident] varchar(5) NULL,
    [Address] NVARCHAR(500) NULL,

    CONSTRAINT [PK_FacesId] PRIMARY KEY CLUSTERED ([FaceId] DESC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_FaceIDN] ON [dbo].[Faces] ([FaceIDN] ASC)

/* ========================================================================== */
/*  						Create table [dbo].[Vehicles]					  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dbo].[Vehicles]
GO

CREATE TABLE [dbo].[Vehicles](
    [VehicleId] INT NOT NULL,
	[RegistrationNumber] [nvarchar](50) NULL,
	[BodyNumber] [nvarchar](50) NULL,
	[ProducedDate] [int] NULL,
	[TechDocModel] [nvarchar](250) NULL,
	[OwnerFaceId] INT NULL,
	[OwnerRegisteredSettlementId] [INT] NULL,
	[VehiclesRegisteredSettlementId] [INT] NULL,
	[RegulatorObjectCategoryId] VARCHAR(5) NOT NULL,
	[ObjectTypeName] [nvarchar](100) NOT NULL,
	[ObjectTypeCategory] [nvarchar](10) NOT NULL,
	[InsuredObjectName] [nvarchar](900) NULL,
	[InsuredObjectComment] [nvarchar](255) NULL,
	[Model] NVARCHAR(150) NOT NULL,
	[ModelRegulatorID] INT NULL,
	[Manufacturer] NVARCHAR(100) NOT NULL,
	[ManufacturerRegulatorID] INT NULL,
	[FullModelName] AS [Manufacturer]+ ' ' + [Model],
    CONSTRAINT [PK_VehiclesId] PRIMARY KEY CLUSTERED ([VehicleId] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
    ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Vehicles] WITH CHECK ADD  CONSTRAINT [FK_OwnerRegisteredSettlementId] FOREIGN KEY([OwnerRegisteredSettlementId])
REFERENCES [dbo].[Settlements] ([SettlementId])
GO
ALTER TABLE [dbo].[Vehicles] CHECK CONSTRAINT [FK_OwnerRegisteredSettlementId]
GO

ALTER TABLE [dbo].[Vehicles] WITH CHECK ADD  CONSTRAINT [FK_VehiclesRegisteredSettlementId] FOREIGN KEY([VehiclesRegisteredSettlementId])
REFERENCES [dbo].[Settlements] ([SettlementId])
GO
ALTER TABLE [dbo].[Vehicles] CHECK CONSTRAINT [FK_VehiclesRegisteredSettlementId]
GO


CREATE NONCLUSTERED INDEX IX_RegistrationNumber ON [dbo].[Vehicles] ([RegistrationNumber] DESC) 
GO

CREATE NONCLUSTERED INDEX IX_BodyNumber ON [dbo].[Vehicles] ([BodyNumber] DESC) 
GO

/* ========================================================================== */
/*  						Create table dbo.OsagoProducts					  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dbo].[OsagoProducts]
GO

CREATE TABLE [dbo].[OsagoProducts](
	[Id] INT NOT NULL,
	[ProgramId] INT NOT NULL,
	[ProductId] INT NOT NULL,
	[ProgramTypeId] INT NOT NULL, -- todo create table dim.ProgramTypes
	[BlankSeria]  AS (case when isnumeric([PolisNumber])=(1) then NULL else left([PolisNumber],(2)) end),
	[BlankNumber]  AS (case when isnumeric([PolisNumber])=(1) then [PolisNumber] else substring([PolisNumber],(4),(7)) end),
	[PolisNumber] [nvarchar](50) NOT NULL,
	[BranchId] [int] NOT NULL,
	[BeginingDate] [int] NOT NULL,
	[EndingDate] [int] NOT NULL,
	[Validity] [int] NOT NULL,
	[RegisteredDate] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[AgentReportDate] INT NULL,
	[AgentReportNumber] [nvarchar](50) NULL,
	[Comment] [nvarchar](255) NULL,
	[ContractId] INT NOT NULL,
	[BaseProductId] INT NULL,
	[BasePolisNumber] [nvarchar](50) NULL,
	[BaseBlankSeria]  AS (case when isnumeric([BasePolisNumber])=(1) then NULL else left([BasePolisNumber],(2)) end),
	[BaseBlankNumber]  AS (case when isnumeric([BasePolisNumber])=(1) then [BasePolisNumber] else substring([BasePolisNumber],(4),(7)) end),
	[BasePolisRegisteredDate] [int] NULL,
	[SupplementaryAgreementTypeId] INT NOT NULL,
	[InsuranceRate] [decimal](18, 10) NULL,
	[InsurerFaceId] INT NOT NULL,
	[InsuredFaceId] INT NOT NULL,
	[VehicleId] INT NOT NULL,
	[CostValue] [decimal](18, 2) NULL,
	[EstateCover] [decimal](18, 2) NULL,
	[HealthCover] [decimal](18, 2) NULL,
	[Franchise] [int] NULL,
	
	[PlanedPaymentValue] [decimal](18, 2) NULL,
	[PlanedPaymentDate] [int] NULL,
	[RealPaymentValue] [decimal](18, 2) NULL,
	[RealPaymentDate] [int] NULL,
	
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

	[BonusMalusId] INT NULL,
	[ZoneId] INT NULL,
	[DiscountId] INT NULL,
	[PrivilegId] INT NULL,
	[ExperienceTypeId] INT NULL,
	[SphereUse] [int] NOT NULL,
	[NeedToParameterValueId] [INT] NULL,
	[DateNextTo] [date] NULL,

	[ProductDeleted] [bit] NOT NULL,
	[ProgramDeleted] [bit] NOT NULL,
	[PlannedPaymentDeleted] [bit] NOT NULL,

	[CoefficientsDeleted] [bit] NOT NULL,
	[ParametersDeleted] [bit] NOT NULL,

	[VehicleDeleted] [bit] NOT NULL,

	[CurrentFlag] BIT NOT NULL,
	[Loaded] [datetime] NULL,

) ON [PRIMARY]
GO


/* ========================================================================== */
/*  						FK Dates										  */
/* ========================================================================== */
ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_BeginingDate] FOREIGN KEY([BeginingDate])
REFERENCES [dim].[Dates] ([DateId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_BeginingDate]
GO


ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_EndingDate] FOREIGN KEY([EndingDate])
REFERENCES [dim].[Dates] ([DateId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_EndingDate]
GO


ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_RegisteredDate] FOREIGN KEY([RegisteredDate])
REFERENCES [dim].[Dates] ([DateId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_RegisteredDate]
GO


ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_AgentReportDate] FOREIGN KEY([AgentReportDate])
REFERENCES [dim].[Dates] ([DateId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_AgentReportDate]
GO


ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_PlanedPaymentDate] FOREIGN KEY([PlanedPaymentDate])
REFERENCES [dim].[Dates] ([DateId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_PlanedPaymentDate]
GO


ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_RealPaymentDate] FOREIGN KEY([RealPaymentDate])
REFERENCES [dim].[Dates] ([DateId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_RealPaymentDate]
GO

--Branches
ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_Branch] FOREIGN KEY([BranchId])
REFERENCES [dim].[Branches] ([BranchId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_Branch]
GO

/* ========================================================================== */
/*  						FK Parameters									  */
/* ========================================================================== */

ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_BonusMalusId] FOREIGN KEY([BonusMalusId])
REFERENCES [dim].[BonusMaluses]([BonusMalusId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_BonusMalusId]
GO


ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_ZoneId] FOREIGN KEY([ZoneId])
REFERENCES [dim].[Zones] ([ZoneId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_ZoneId]
GO


ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_DiscountId] FOREIGN KEY([DiscountId])
REFERENCES [dim].[Discounts] ([DiscountId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_DiscountId]
GO


ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_PrivilegId] FOREIGN KEY([PrivilegId])
REFERENCES [dim].[Privilegies] ([PrivilegId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_PrivilegId]
GO

ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_ExperienceTypeId] FOREIGN KEY([ExperienceTypeId])
REFERENCES [dim].[ExperienceTypes] ([ExperienceTypeId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_ExperienceTypeId]
GO

/* ========================================================================== */
/*  						FK Objects										  */
/* ========================================================================== */

ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_VehicleId] FOREIGN KEY([VehicleId])
REFERENCES [dbo].[Vehicles]([VehicleId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_VehicleId]
GO

ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_InsuredFaceId] FOREIGN KEY([InsuredFaceId])
REFERENCES [dbo].[Faces]([FaceId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_InsuredFaceId]
GO

ALTER TABLE [dbo].[OsagoProducts]  WITH CHECK ADD  CONSTRAINT [FK_InsurerFaceId] FOREIGN KEY([InsurerFaceId])
REFERENCES [dbo].[Faces] ([FaceId])
GO
ALTER TABLE [dbo].[OsagoProducts] CHECK CONSTRAINT [FK_InsurerFaceId]
GO


CREATE NONCLUSTERED INDEX [IX_PolisNumber] ON [dbo].[OsagoProducts] ([PolisNumber] DESC)
GO

CREATE NONCLUSTERED INDEX [IX_ProductId] ON [dbo].[OsagoProducts] ([ProductId] DESC)
GO

CREATE NONCLUSTERED INDEX [IX_ProgramId] ON [dbo].[OsagoProducts] ([ProgramId] DESC)
GO

CREATE NONCLUSTERED INDEX [IX_ProgramTypeId] ON [dbo].[OsagoProducts] ([ProgramTypeId] DESC)
GO


/* ========================================================================== */
/*  						Create table [dbo].[ParameterActivities]		  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dbo].[ParameterActivities]
GO

CREATE TABLE [dbo].[ParameterActivities](
    [ParameterActivityId] INT NOT NULL,
	[ProductId] [int] NOT NULL,
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
	[CurrentFlag] [bit] NOT NULL,

    CONSTRAINT [PK_ParameterActivitiesId] PRIMARY KEY CLUSTERED ([ParameterActivityId] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
    ON [PRIMARY]
) ON [PRIMARY]
GO


/* ========================================================================== */
/*  						Create table dbo.ProductCancels					  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dbo].[ProductCancels]
GO

CREATE TABLE [dbo].[ProductCancels](
	[ProductId] [INT] NOT NULL,
	[CancelDate] [date] NULL,
	[StatusGID] [uniqueidentifier] NULL,
	[ReturnSum] [decimal](18, 2) NULL,
	[ProductCancelActGID] [uniqueidentifier] NULL,
	[PlanedPaymentRest] [decimal](18, 2) NULL,
	[RetPaymentValue] [decimal](18, 2) NULL,
	[OnDealSum] [decimal](18, 2) NULL,
	[CreateDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[Deleted] [bit] NULL,
	[CurrentFlag] [bit] NOT NULL,

	CONSTRAINT [PK_ProductCancelsProductId] PRIMARY KEY CLUSTERED ([ProductId] ASC)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
) ON [PRIMARY]
GO