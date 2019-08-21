CREATE TABLE [dbo].[pl_history]
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
[trans_id] [bigint] NOT NULL,
[currency_fx_rate] [float] NULL,
[pl_record_qty] [numeric] (20, 8) NULL,
[pl_record_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pos_num] [int] NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[pl_history] ADD CONSTRAINT [pl_history_pk] PRIMARY KEY CLUSTERED  ([pl_asof_date], [pl_record_key], [pl_owner_code], [pl_type]) WITH (ALLOW_PAGE_LOCKS=OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pl_history_idx2] ON [dbo].[pl_history] ([pl_asof_date], [real_port_num], [pl_primary_owner_key1], [pl_primary_owner_key2], [pl_primary_owner_key3], [pl_primary_owner_key4]) WITH (FILLFACTOR=90, ALLOW_PAGE_LOCKS=OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pl_history_idx8] ON [dbo].[pl_history] ([pl_record_key], [pl_asof_date], [pl_owner_code], [pl_type]) WITH (FILLFACTOR=90, ALLOW_PAGE_LOCKS=OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pl_history_idx6] ON [dbo].[pl_history] ([real_port_num], [pl_asof_date], [pos_num], [pl_type], [pl_owner_code], [pl_amt]) WITH (FILLFACTOR=90, ALLOW_PAGE_LOCKS=OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pl_history] ADD CONSTRAINT [pl_history_fk1] FOREIGN KEY ([pl_record_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[pl_history] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[pl_history] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[pl_history] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[pl_history] TO [next_usr]
GO
