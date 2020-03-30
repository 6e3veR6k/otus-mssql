/* Начало проектной работы. */

/* Создание таблиц и представлений для своего проекта. Если вы не сделали этого раньше,
 * придумайте и сделайте краткое описание проекта, который будете делать в рамках всего курса.

 * Нужно используя операторы DDL создать:
 * 1. Создать базу данных.
 * 2. 3-4 основные таблицы для своего проекта.
 * 3. Первичные и внешние ключи для всех созданных таблиц.
 * 4. 1-2 индекса на таблицы.
 * 5. Наложите по одному ограничению в каждой таблице на ввод данных.

 * В качестве проекта вы можете взять любую идею, которая вам близка.
 * Это может быть какая-то часть вашего рабочего проекта, которую вы хотите переосмыслить.
 * Если есть идея, но не понятно как ее уложить в рамки учебного проекта, напишите преподавателю и мы поможем.
 * Проект мы будем делать весь курс и защищать его в самом конце, он будет заключаться в созданной БД со схемой,
 * описанием проекта, и необходимыми процедурами\функциями или SQL кодом для демонстрации основного функционала системы.
 * Создать в github папку с проектом, создать там описание проекта - о чем он, какие функции будут реализованы, 
 * основные сущности, которые затем будут созданы (просто описание текстом).
 */


 -- Описание:
 -- Проект хранилища данных(DWH) по договорам одного вида страхования


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

    CONSTRAINT [PK_DatesDateKey] PRIMARY KEY CLUSTERED ([DateKey] DESC)
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
	[Id] [int] NOT NULL,
	[BranchCode] [varchar](10) NOT NULL,
	[DirectionCode] [varchar](2) NULL,
	[ParentBranchCode] [varchar](4) NULL,
	[Name] [nvarchar](255) NOT NULL,
	[ParentId] [int] NOT NULL,

    CONSTRAINT [PK_BranchesBranchId] PRIMARY KEY CLUSTERED ([Id] ASC)
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
    [Id] INT NOT NULL,
	[gid] [uniqueidentifier] NOT NULL,
	[ProgramParameterGID] [uniqueidentifier] NOT NULL,
	[Class] [int] NULL,
	[Value] [decimal](18, 2) NULL,

    CONSTRAINT [PK_BonusMalusId] PRIMARY KEY CLUSTERED ([Id] ASC)
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
    [Id] INT NOT NULL,
	[gid] [uniqueidentifier] NOT NULL,
	[Value] [int] NOT NULL,
	[Comment] [nvarchar](50) NOT NULL,
	[DiscountCoefficient] [int] NOT NULL,

    CONSTRAINT [PK_DiscountsId] PRIMARY KEY CLUSTERED ( [Id] ASC )
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
    [Id] INT NOT NULL,
	[gid] [uniqueidentifier] NOT NULL,
	[Value] [nvarchar](50) NULL,
	[RegulatorId] [int] NULL,

    CONSTRAINT [PK_ExperienceTypesId] PRIMARY KEY CLUSTERED ([Id] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]
GO



/* ========================================================================== */
/*  						Create table dim.ObjectTypes					  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dim].[ObjectTypes]
GO

CREATE TABLE [dim].[ObjectTypes](
    [Id] INT NOT NULL,
	[gid] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](10) NOT NULL,
	[RegulatorCategoryId]  AS 
	(case [Category] 
		when 'B1' then (1) 
		when 'B2' then (2) 
		when 'B3' then (3) 
		when 'B4' then (4) 
		when 'A1' then (5) 
		when 'A2' then (6) 
		when 'C1' then (7) 
		when 'C2' then (8) 
		when 'D1' then (9) 
		when 'D2' then (10) 
		when 'F' then (11)
		when 'E' then (12)
		when 'B' then (13) 
		when 'A' then (14)
		when 'C' then (15)
		when 'D' then (16)
		when 'B5' then (17)  
	end),

    CONSTRAINT [PK_ObjectTypesId] PRIMARY KEY CLUSTERED ([Id] ASC)
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
    [Id] INT NOT NULL,
	[gid] [uniqueidentifier] NOT NULL,
	[Comment] [nvarchar](100) NOT NULL,
	[Value] [int] NOT NULL,

	CONSTRAINT [PK_PrivilegiesId] PRIMARY KEY CLUSTERED ([Id] ASC)
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
	[Id] INT NOT NULL,
	[gid] [uniqueidentifier] NOT NULL,
	[Value] [nvarchar](500) NOT NULL,
	[Zone] [nvarchar](1) NOT NULL,

	CONSTRAINT [PK_ZonesId] PRIMARY KEY CLUSTERED ([Id] ASC)
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
	[Id] [int] NOT NULL,
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

	CONSTRAINT [PK_ProductCancelsId] PRIMARY KEY CLUSTERED ([Id] ASC)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
	ON [PRIMARY]
) ON [PRIMARY]
GO

--todo foreing key on dbo.Products


/* ========================================================================== */
/*  						Create table dbo.Settlements					  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dbo].[Settlements]
GO

CREATE TABLE [dbo].[Settlements](
	[Id] INT NOT NULL,
	[SettlementName] [nvarchar](250) NULL,
	[SettlementClearName] [nvarchar](250) NULL,
	[SettlementTypeName] [nvarchar](20) NULL,
	[SettlementShortTypeName] [nvarchar](4) NULL,
	[RegulatorID] [int] NULL,
	[DistrictName] [nvarchar](250) NULL,
	[RegionName] [nvarchar](250) NULL,
	[RegulatorDCity]  AS (case when [RegulatorID] IS NULL then (3797) else [RegulatorID] end),
	[RegulatorDZone] [int] NULL,

	CONSTRAINT [PK_SettlementsId] PRIMARY KEY CLUSTERED ([Id] ASC)
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
	[Id] [int] NOT NULL,
	[LastName] [nvarchar](255) NULL,
	[Firstname] [nvarchar](50) NULL,
	[Secondname] [nvarchar](50) NULL,
	[PersonType] [NVARCHAR](1) NULL,
	[FaceID] [nvarchar](15) NULL,
	[BirthDate] [date] NULL,
	[PhoneNumber] [nvarchar](30) NULL,
	[PassportSeria] [nvarchar](4) NULL,
	[PassportNumber] [varchar](10) NULL,
	[Gender] [bit] NULL,
	[DriversLicenseSeria] [nvarchar](3) NULL,
	[DriversLicenseNumber] [nvarchar](10) NULL,
	[DriverFrom] [int] NULL,
	[IsResident] [bit] NULL,
    [Address] NVARCHAR(500) NULL,

    CONSTRAINT [PK_FacesId] PRIMARY KEY CLUSTERED ([Id] DESC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]
GO


/* ========================================================================== */
/*  						Create table [dbo].[ParameterActivities]		  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dbo].[ParameterActivities]
GO

CREATE TABLE [dbo].[ParameterActivities](
    [Id] INT NOT NULL,
	[ProductId] [uniqueidentifier] NOT NULL,
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

    CONSTRAINT [PK_ParameterActivitiesId] PRIMARY KEY CLUSTERED ([Id] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
    ON [PRIMARY]
) ON [PRIMARY]
GO

--todo foreing key on dbo.Products

/* ========================================================================== */
/*  						Create table [dbo].[Vehicles]					  */
/* ========================================================================== */
DROP TABLE IF EXISTS [dbo].[Vehicles]
GO

CREATE TABLE [dbo].[Vehicles](
    [Id] INT NOT NULL,
	[RegistrationNumber] [nvarchar](50) NULL,
	[BodyNumber] [nvarchar](50) NULL,
	[ProducedDate] [int] NULL,
	[TechDocModel] [nvarchar](250) NULL,
	[ModelId] [uniqueidentifier] NULL,
	[OwnerRegisteredSettlementId] [INT] NULL,
	[VehiclesRegisteredSettlementId] [INT] NULL,
	[ObjectTypeId] INT NOT NULL,
	[InsuredObjectName] [nvarchar](900) NULL,
	[InsuredObjectComment] [nvarchar](255) NULL,

    CONSTRAINT [PK_VehiclesId] PRIMARY KEY CLUSTERED ([Id] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
    ON [PRIMARY]
) ON [PRIMARY]
GO

--todo foreing key on dbo.Products



/* ========================================================================== */
/*  						Create table dbo.OsagoProducts					  */
/* ========================================================================== */


CREATE TABLE [dbo].[OsagoProducts](
	[Id] INT NOT NULL,
	[ProgramId] INT NOT NULL,
	[ProductId] INT NOT NULL,
	[ProgramTypeId] INT NOT NULL,
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
	[AgentReportDate] [date] NULL,
	[AgentReportNumber] [nvarchar](50) NULL,
	[InsurerFaceId] INT NOT NULL,
	[Comment] [nvarchar](255) NULL,
	[ContractId] INT NOT NULL,
	[BaseProductId] INT NOT NULL,
	[BasePolisNumber] [nvarchar](50) NULL,
	[BaseBlankSeria]  AS (case when isnumeric([BasePolisNumber])=(1) then NULL else left([BasePolisNumber],(2)) end),
	[BaseBlankNumber]  AS (case when isnumeric([BasePolisNumber])=(1) then [BasePolisNumber] else substring([BasePolisNumber],(4),(7)) end),
	[BasePolisRegisteredDate] [int] NULL,
	[SupplementaryAgreementTypeId] INT NOT NULL,
	[InsuranceRate] [decimal](18, 10) NULL,
	[InsuredObjectId] INT NOT NULL,
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

	[BonusMalusValueId] INT NULL,
	[ZoneValueId] INT NULL,
	[DiscountValueId] INT NULL,
	[PrivilegValueId] INT NULL,
	[CExpValueId] INT NULL,
	[SphereUse] [int] NOT NULL,
	[NeedToParameterValueId] [INT] NULL,
	[DateNextTo] [date] NULL,

	[ProductDeleted] [bit] NOT NULL,
	[ProgramDeleted] [bit] NOT NULL,
	[PlannedPaymentDeleted] [bit] NOT NULL,

	[CoefficientsDeleted] [bit] NOT NULL,
	[ParametersDeleted] [bit] NOT NULL,

	[InsuredObjectDeleted] [bit] NOT NULL,

	[CurrentFlag] BIT NOT NULL,
	[Loaded] [datetime] NULL,

) ON [PRIMARY]
GO


