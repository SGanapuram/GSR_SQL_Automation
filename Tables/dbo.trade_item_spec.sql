CREATE TABLE [dbo].[trade_item_spec]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_min_val] [float] NULL,
[spec_max_val] [float] NULL,
[spec_typical_val] [float] NULL,
[spec_test_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[cmnt_num] [int] NULL,
[spec_provisional_val] [float] NULL,
[splitting_limit] [numeric] (20, 8) NULL,
[equiv_pay_deduct_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[equiv_del_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[equiv_del_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_in_formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_in_cost_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[equiv_del_period] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_spec] ADD CONSTRAINT [trade_item_spec_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num], [spec_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_spec] ADD CONSTRAINT [trade_item_spec_fk1] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
ALTER TABLE [dbo].[trade_item_spec] ADD CONSTRAINT [trade_item_spec_fk4] FOREIGN KEY ([equiv_del_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_spec] ADD CONSTRAINT [trade_item_spec_fk5] FOREIGN KEY ([equiv_del_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
GRANT DELETE ON  [dbo].[trade_item_spec] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_spec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_spec] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_spec] TO [next_usr]
GO
