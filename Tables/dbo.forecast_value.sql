CREATE TABLE [dbo].[forecast_value]
(
[oid] [int] NOT NULL,
[acct_num] [int] NULL,
[booking_comp_num] [int] NULL,
[commkt_key] [int] NOT NULL,
[del_date_from] [datetime] NULL,
[del_date_to] [datetime] NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[forecast_qty] [numeric] (20, 8) NOT NULL,
[forecast_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_forecast_value_p_s_ind] DEFAULT ('P'),
[forecast_pos_num] [int] NULL,
[phy_pos_num] [int] NULL,
[real_port_num] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [chk_forecast_value_p_s_ind] CHECK (([p_s_ind]='S' OR [p_s_ind]='P'))
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [forecast_value_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [forecast_value_idx1] ON [dbo].[forecast_value] ([acct_num], [booking_comp_num], [commkt_key], [del_loc_code], [mot_type_code], [p_s_ind], [real_port_num], [trading_prd]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [forecast_value_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [forecast_value_fk2] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [forecast_value_fk3] FOREIGN KEY ([commkt_key], [trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [forecast_value_fk4] FOREIGN KEY ([del_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [forecast_value_fk5] FOREIGN KEY ([forecast_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [forecast_value_fk6] FOREIGN KEY ([mot_type_code]) REFERENCES [dbo].[mot_type] ([mot_type_code])
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [forecast_value_fk7] FOREIGN KEY ([forecast_pos_num]) REFERENCES [dbo].[position] ([pos_num])
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [forecast_value_fk8] FOREIGN KEY ([phy_pos_num]) REFERENCES [dbo].[position] ([pos_num])
GO
ALTER TABLE [dbo].[forecast_value] ADD CONSTRAINT [forecast_value_fk9] FOREIGN KEY ([real_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
GRANT DELETE ON  [dbo].[forecast_value] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[forecast_value] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[forecast_value] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[forecast_value] TO [next_usr]
GO
