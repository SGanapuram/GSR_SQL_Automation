CREATE TABLE [dbo].[aud_pl_history]
(
[pl_record_key] [int] NOT NULL,
[pl_owner_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pl_asof_date] [datetime] NOT NULL,
[real_port_num] [int] NOT NULL,
[pl_owner_sub_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pl_record_owner_key] [int] NOT NULL,
[pl_primary_owner_key1] [int] NOT NULL,
[pl_primary_owner_key2] [int] NULL,
[pl_primary_owner_key3] [int] NULL,
[pl_primary_owner_key4] [int] NULL,
[pl_secondary_owner_key1] [int] NULL,
[pl_secondary_owner_key2] [int] NULL,
[pl_secondary_owner_key3] [int] NULL,
[pl_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pl_category_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pl_realization_date] [datetime] NULL,
[pl_cost_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pl_cost_prin_addl_ind] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pl_mkt_price] [float] NULL,
[pl_amt] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[currency_fx_rate] [float] NULL,
[pl_record_qty] [numeric] (20, 8) NULL,
[pl_record_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_num] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pl_history] ON [dbo].[aud_pl_history] ([pl_asof_date], [pl_record_key], [pl_owner_code], [pl_type], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pl_history_idx1] ON [dbo].[aud_pl_history] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pl_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pl_history] TO [next_usr]
GO
