CREATE TABLE [dbo].[aud_forecast_value]
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
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[forecast_pos_num] [int] NULL,
[phy_pos_num] [int] NULL,
[real_port_num] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_forecast_value] ON [dbo].[aud_forecast_value] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_forecast_value_idx1] ON [dbo].[aud_forecast_value] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_forecast_value] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_forecast_value] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_forecast_value] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_forecast_value] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_forecast_value] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_forecast_value', NULL, NULL
GO
