CREATE TABLE [dbo].[assign_trade]
(
[assign_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[ct_doc_num] [int] NOT NULL,
[ct_doc_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[covered_amt] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL,
[credit_exposure_oid] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[assign_trade] ADD CONSTRAINT [assign_trade_pk] PRIMARY KEY CLUSTERED  ([assign_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [assign_trade_idx2] ON [dbo].[assign_trade] ([alloc_num], [alloc_item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [assign_trade_TS_idx90] ON [dbo].[assign_trade] ([ct_doc_type], [alloc_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [assign_trade_idx1] ON [dbo].[assign_trade] ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[assign_trade] ADD CONSTRAINT [assign_trade_fk2] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[assign_trade] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[assign_trade] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[assign_trade] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[assign_trade] TO [next_usr]
GO
