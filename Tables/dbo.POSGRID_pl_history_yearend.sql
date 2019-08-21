CREATE TABLE [dbo].[POSGRID_pl_history_yearend]
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
[currency_fx_rate] [float] NULL,
[pl_record_qty] [numeric] (20, 8) NULL,
[pl_record_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POSGRID_pl_history_yearend] ADD CONSTRAINT [POSGRID_pl_history_yearend_pk] PRIMARY KEY CLUSTERED  ([pl_asof_date], [pl_record_key], [pl_owner_code], [pl_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [POSGRID_pl_history_yearend_idx1] ON [dbo].[POSGRID_pl_history_yearend] ([pl_asof_date]) ON [PRIMARY]
GO
