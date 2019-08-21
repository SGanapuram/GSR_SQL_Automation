CREATE TABLE [dbo].[aud_fx_exposure_dist]
(
[oid] [int] NOT NULL,
[fx_owner_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_exp_num] [int] NULL,
[fx_owner_key1] [int] NULL,
[fx_owner_key2] [int] NULL,
[fx_owner_key3] [int] NULL,
[fx_owner_key4] [int] NULL,
[fx_owner_key5] [int] NULL,
[fx_owner_key6] [int] NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[fx_qty] [decimal] (20, 8) NULL,
[fx_price] [decimal] (20, 8) NULL,
[fx_amt] [decimal] (20, 8) NULL,
[fx_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_drop_date] [datetime] NULL,
[fx_priced_amt] [decimal] (20, 8) NULL,
[fx_real_port_num] [int] NULL,
[fx_custom_column1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_custom_column2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_custom_column3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_custom_column4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_exposure_dist] ON [dbo].[aud_fx_exposure_dist] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_fx_exposure_dist_idx1] ON [dbo].[aud_fx_exposure_dist] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_fx_exposure_dist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_fx_exposure_dist] TO [next_usr]
GO
