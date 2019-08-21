CREATE TABLE [dbo].[trade_item_bunker]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_agent_num] [int] NULL,
[storage_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_agent_num] [int] NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[delivery_mot] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[eta_date] [datetime] NULL,
[del_date] [datetime] NULL,
[pricing_exp_date] [datetime] NULL,
[exp_time_zone_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[curr_exch_date] [datetime] NULL,
[transp_price_amt] [float] NULL,
[transp_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transp_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[handling_type_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_qty] [numeric] (20, 8) NULL,
[tol_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_sign] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_opt] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_qty] [numeric] (30, 8) NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [numeric] (20, 8) NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk10] FOREIGN KEY ([exp_time_zone_code]) REFERENCES [dbo].[time_zone] ([time_zone_code])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk11] FOREIGN KEY ([transp_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk12] FOREIGN KEY ([transp_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk13] FOREIGN KEY ([handling_type_code]) REFERENCES [dbo].[handling_type] ([handling_type_code])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk2] FOREIGN KEY ([port_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk3] FOREIGN KEY ([port_agent_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk4] FOREIGN KEY ([storage_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk5] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk6] FOREIGN KEY ([del_term_code]) REFERENCES [dbo].[delivery_term] ([del_term_code])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk7] FOREIGN KEY ([del_agent_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk8] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade_item_bunker] ADD CONSTRAINT [trade_item_bunker_fk9] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
GRANT DELETE ON  [dbo].[trade_item_bunker] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_bunker] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_bunker] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_bunker] TO [next_usr]
GO
