CREATE TABLE [dbo].[icts_transaction_backup]
(
[trans_id] [int] NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[tran_date] [datetime] NOT NULL,
[app_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[app_revision] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spid] [smallint] NULL,
[workstation_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sequence] [numeric] (32, 0) NOT NULL IDENTITY(1, 1),
[parent_trans_id] [int] NULL,
[executor_id] [tinyint] NOT NULL
) ON [PRIMARY]
GO
