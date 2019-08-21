CREATE TABLE [dbo].[accumulation]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[accum_num] [smallint] NOT NULL,
[accum_start_date] [datetime] NOT NULL,
[accum_end_date] [datetime] NOT NULL,
[nominal_start_date] [datetime] NULL,
[nominal_end_date] [datetime] NULL,
[quote_start_date] [datetime] NULL,
[quote_end_date] [datetime] NULL,
[accum_qty] [float] NOT NULL,
[accum_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[total_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_pricing_run_date] [datetime] NULL,
[last_pricing_as_of_date] [datetime] NULL,
[accum_creation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_override_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_precision] [tinyint] NULL,
[cmnt_num] [int] NULL,
[formula_num] [int] NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[cost_num] [int] NULL,
[idms_trig_bb_ref_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exercised_by_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qpp_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[ai_est_actual_num] [int] NULL,
[flat_amt] [float] NULL,
[exec_inv_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[accumulation] ADD CONSTRAINT [accumulation_pk] PRIMARY KEY NONCLUSTERED  ([trade_num], [order_num], [item_num], [accum_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [accumulation_idx3] ON [dbo].[accumulation] ([price_status], [accum_creation_type], [formula_num]) INCLUDE ([item_num], [order_num], [trade_num]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [accumulation] ON [dbo].[accumulation] ([trade_num], [order_num], [item_num], [accum_num], [formula_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [accumulation_idx2] ON [dbo].[accumulation] ([trade_num], [order_num], [item_num], [accum_num], [price_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [accumulation_idx1] ON [dbo].[accumulation] ([trade_num], [order_num], [item_num], [trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[accumulation] ADD CONSTRAINT [accumulation_fk10] FOREIGN KEY ([exec_inv_num]) REFERENCES [dbo].[exec_phys_inv] ([exec_inv_num])
GO
ALTER TABLE [dbo].[accumulation] ADD CONSTRAINT [accumulation_fk3] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[accumulation] ADD CONSTRAINT [accumulation_fk6] FOREIGN KEY ([exercised_by_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[accumulation] ADD CONSTRAINT [accumulation_fk8] FOREIGN KEY ([accum_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[accumulation] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[accumulation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[accumulation] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[accumulation] TO [next_usr]
GO
