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



DROP DATABASE IF EXISTS Dmart
GO

CREATE DATABASE Dmart ON PRIMARY 
( NAME = N'DmartData', FILENAME = N'C:\SQL\Data\Dmart.mdf' , SIZE = 500MB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DmartLog', FILENAME = N'C:\SQL\Log\Dmart_log.ldf' , SIZE = 500MB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
COLLATE Cyrillic_General_CI_AS
GO
ALTER DATABASE [dmart] SET RECOVERY SIMPLE
GO



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
    CONSTRAINT [PK_DateKey] PRIMARY KEY CLUSTERED ([DateKey] DESC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
    ON [PRIMARY]
) ON [PRIMARY]
GO



DROP TABLE IF EXISTS  [dim].[Branches]
GO

CREATE TABLE [dim].[Branches](
	[Id] [int] NOT NULL,
	[BranchCode] [varchar](10) NOT NULL,
	[DirectionCode] [varchar](2) NULL,
	[ParentBranchCode] [varchar](4) NULL,
	[Name] [nvarchar](255) NOT NULL,
	[ParentId] [int] NOT NULL,
    CONSTRAINT [PK_BranchId] PRIMARY KEY CLUSTERED ([Id] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]
GO



DROP TABLE IF EXISTS [dim].[Faces]
GO

CREATE TABLE [dim].[Faces](
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
    [Address] NVARCHAR(500) NULL
    CONSTRAINT [PK_FaceId] PRIMARY KEY CLUSTERED ([Id] DESC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]
GO



DROP TABLE IF EXISTS [dim].[BonusMalus]
GO

CREATE TABLE [dim].[BonusMalus](
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



DROP TABLE IF EXISTS [dim].[Discount]
GO
CREATE TABLE [dim].[Discount](
    [Id] INT NOT NULL,
	[gid] [uniqueidentifier] NOT NULL,
	[Value] [int] NOT NULL,
	[Comment] [nvarchar](50) NOT NULL,
	[DiscountCoefficient] [int] NOT NULL,
    CONSTRAINT [PK_DiscountId] PRIMARY KEY CLUSTERED ( [Id] ASC )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
    ON [PRIMARY]
) ON [PRIMARY]
GO



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



DROP TABLE IF EXISTS [dim].[ObjectTypes]
GO

CREATE TABLE [dim].[ObjectTypes](
    [Id] INT NOT NULL,
	[gid] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](10) NOT NULL,
	[RegulatorCategoryId]  AS (case [Category] when 'B1' then (1) when 'B2' then (2) when 'B3' then (3) when 'B4' then (4) when 'A1' then (5) when 'A2' then (6) when 'C1' then (7) when 'C2' then (8) when 'D1' then (9) when 'D2' then (10) when 'F' then (11) when 'E' then (12) when 'B' then (13) when 'A' then (14) when 'C' then (15) when 'D' then (16) when 'B5' then (17)  end),
    CONSTRAINT [PK_ObjectTypesId] PRIMARY KEY CLUSTERED ([Id] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
    ON [PRIMARY]
) ON [PRIMARY]
GO



DROP TABLE IF EXISTS [dim].[ParameterActivities]
GO

CREATE TABLE [dim].[ParameterActivities](
    [Id] INT NOT NULL,
	[ProgramGID] [uniqueidentifier] NOT NULL,
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