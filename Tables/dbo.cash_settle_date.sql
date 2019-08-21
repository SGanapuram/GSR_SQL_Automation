CREATE TABLE [dbo].[cash_settle_date]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[cash_settle_num] [smallint] NOT NULL,
[cash_settle_date] [datetime] NULL,
[cash_settle_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cash_settle_date] ADD CONSTRAINT [cash_settle_date_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [cash_settle_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cash_settle_date] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cash_settle_date] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cash_settle_date] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cash_settle_date] TO [next_usr]
GO
