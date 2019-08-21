CREATE TABLE [dbo].[aud_vessel_dist]
(
[oid] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dist_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dist_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dist_qty] [numeric] (20, 8) NOT NULL,
[alloc_qty] [numeric] (20, 8) NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[avg_price] [numeric] (20, 8) NOT NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[real_port_num] [int] NOT NULL,
[pos_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_vessel_dist_idx1] ON [dbo].[aud_vessel_dist] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_vessel_dist_idx2] ON [dbo].[aud_vessel_dist] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_vessel_dist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_vessel_dist] TO [next_usr]
GO
