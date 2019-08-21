CREATE TABLE [dbo].[trade_order_bunker]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[bunker_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_trade_order_bunker_bunker_type] DEFAULT ('S'),
[duty_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_order_bunker_duty_ind] DEFAULT ('N'),
[vat_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_order_bunker_vat_ind] DEFAULT ('N'),
[auto_alloc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_order_bunker_auto_alloc_ind] DEFAULT ('N'),
[not_to_vouch_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_order_bunker_not_to_vouch_ind] DEFAULT ('N'),
[brkr_num] [int] NULL,
[brkr_cont_num] [int] NULL,
[brkr_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_tel_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comm_amt] [float] NULL,
[comm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[comm_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transp_price_comp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_order_bunker_transp_price_comp_ind] DEFAULT ('N'),
[transp_price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_trade_order_bunker_transp_price_type] DEFAULT ('U'),
[transp_price_amt] [float] NULL,
[transp_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[fiscal_class_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_order_bunker] ADD CONSTRAINT [trade_order_bunker_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_order_bunker] ADD CONSTRAINT [trade_order_bunker_fk2] FOREIGN KEY ([brkr_num], [brkr_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[trade_order_bunker] ADD CONSTRAINT [trade_order_bunker_fk3] FOREIGN KEY ([comm_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_order_bunker] ADD CONSTRAINT [trade_order_bunker_fk4] FOREIGN KEY ([comm_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_order_bunker] ADD CONSTRAINT [trade_order_bunker_fk5] FOREIGN KEY ([transp_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_order_bunker] ADD CONSTRAINT [trade_order_bunker_fk6] FOREIGN KEY ([fiscal_class_code]) REFERENCES [dbo].[fiscal_classification] ([fiscal_class_code])
GO
GRANT DELETE ON  [dbo].[trade_order_bunker] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_order_bunker] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_order_bunker] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_order_bunker] TO [next_usr]
GO
