CREATE TABLE [dbo].[ai_est_actual]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[ai_est_actual_date] [datetime] NOT NULL,
[ai_est_actual_gross_qty] [float] NULL,
[ai_gross_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ai_est_actual_net_qty] [float] NULL,
[ai_net_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ai_est_actual_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ai_est_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ticket_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lease_num] [int] NULL,
[dest_trade_num] [int] NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[scac_carrier_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transporter_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bol_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_code] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accum_num] [int] NULL,
[secondary_actual_gross_qty] [float] NULL,
[secondary_actual_net_qty] [float] NULL,
[secondary_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[manual_input_sec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [df_ai_est_actual_manual_input_sec_ind] DEFAULT ('N'),
[trans_id] [int] NOT NULL,
[fixed_swing_qty_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[insert_sequence] [int] NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tertiary_gross_qty] [numeric] (20, 8) NULL,
[tertiary_net_qty] [numeric] (20, 8) NULL,
[tertiary_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_tax_mt_qty] [numeric] (20, 8) NULL,
[actual_tax_m315_qty] [numeric] (20, 8) NULL,
[start_load_date] [datetime] NULL,
[stop_load_date] [datetime] NULL,
[sap_position_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[assay_final_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_timezone] [smallint] NULL,
[date_specs_recieved_from_al] [datetime] NULL,
[unique_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [chk_ai_est_actual_fixed_swing_qty_ind] CHECK (([fixed_swing_qty_ind] IS NULL OR [fixed_swing_qty_ind]='S' OR [fixed_swing_qty_ind]='F'))
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num], [ai_est_actual_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ai_est_actual_idx1] ON [dbo].[ai_est_actual] ([alloc_num], [alloc_item_num], [trans_id]) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET ARITHABORT ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ai_est_actual_idx2] ON [dbo].[ai_est_actual] ([unique_id]) WHERE ([unique_id] IS NOT NULL) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk2] FOREIGN KEY ([del_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk4] FOREIGN KEY ([ai_gross_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk5] FOREIGN KEY ([ai_net_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk6] FOREIGN KEY ([secondary_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk7] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[ai_est_actual] ADD CONSTRAINT [ai_est_actual_fk8] FOREIGN KEY ([tertiary_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[ai_est_actual] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ai_est_actual] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ai_est_actual] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ai_est_actual] TO [next_usr]
GO
