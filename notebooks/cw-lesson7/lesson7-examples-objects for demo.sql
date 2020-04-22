/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2017 (14.0.2002)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [WideWorldImporters]
GO

/****** Object:  Table [Sales].[InvoiceLines_BulkDemo]    Script Date: 2/11/2019 5:18:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE IF EXISTS [Sales].[InvoiceLines_BulkDemo];

GO

CREATE TABLE [Sales].[InvoiceLines_BulkDemo](
	[InvoiceLineID] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Sales_InvoiceLines_BulkDemo] PRIMARY KEY CLUSTERED 
(
	[InvoiceLineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
) ON [USERDATA]
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Numeric ID used for reference to a line on an invoice within the database' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'InvoiceLineID'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Invoice that this line is associated with' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'InvoiceID'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Stock item for this invoice line' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'StockItemID'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Description of the item supplied (Usually the stock item name but can be overridden)' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Type of package supplied' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'PackageTypeID'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Quantity supplied' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'Quantity'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Unit price charged' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'UnitPrice'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Tax rate to be applied' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'TaxRate'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Tax amount calculated' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'TaxAmount'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Profit made on this line item at current cost price' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'LineProfit'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Extended line price charged' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo', @level2type=N'COLUMN',@level2name=N'ExtendedPrice'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Detail lines from customer invoices' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'InvoiceLines_BulkDemo'
GO


