CREATE TABLE [dbo].[allocation]
(
[alloc_num] [int] NOT NULL,
[alloc_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sch_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cmnt_num] [int] NULL,
[ppl_comp_num] [int] NULL,
[ppl_comp_cont_num] [int] NULL,
[sch_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_batch_num] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_pump_date] [datetime] NULL,
[compr_trade_num] [int] NULL,
[initiator_acct_num] [int] NULL,
[deemed_bl_date] [datetime] NULL,
[alloc_pay_date] [datetime] NULL,
[alloc_base_price] [float] NULL,
[alloc_disc_rate] [float] NULL,
[transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[netout_gross_qty] [float] NULL,
[netout_net_qty] [float] NULL,
[netout_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_batch_given_date] [datetime] NULL,
[ppl_batch_received_date] [datetime] NULL,
[ppl_origin_given_date] [datetime] NULL,
[ppl_origin_received_date] [datetime] NULL,
[ppl_timing_cycle_num] [int] NULL,
[ppl_split_cycle_opt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[netout_parcel_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bookout_pay_date] [datetime] NULL,
[bookout_rec_date] [datetime] NULL,
[alloc_match_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_begin_date] [datetime] NULL,
[alloc_end_date] [datetime] NULL,
[alloc_load_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[book_net_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creation_date] [datetime] NULL,
[multiple_cmdty_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_precision] [smallint] NULL,
[pay_for_del] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pay_for_weight] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[max_alloc_item_num] [smallint] NULL,
[voyage_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[release_doc_num] [int] NULL,
[bookout_brkr_num] [int] NULL,
[base_port_num] [int] NULL,
[transfer_price] [numeric] (20, 8) NULL,
[transfer_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_curr_code_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_currency_rate] [float] NULL,
[shipment_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_pk] PRIMARY KEY CLUSTERED  ([alloc_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [allocation_idx2] ON [dbo].[allocation] ([alloc_type_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [allocation_idx1] ON [dbo].[allocation] ([compr_trade_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk1] FOREIGN KEY ([initiator_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk11] FOREIGN KEY ([netout_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk12] FOREIGN KEY ([voyage_code]) REFERENCES [dbo].[voyage] ([voyage_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk13] FOREIGN KEY ([release_doc_num]) REFERENCES [dbo].[release_document] ([release_doc_num])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk14] FOREIGN KEY ([bookout_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk15] FOREIGN KEY ([base_port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk16] FOREIGN KEY ([transfer_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk17] FOREIGN KEY ([transfer_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk18] FOREIGN KEY ([transfer_price_curr_code_to]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk2] FOREIGN KEY ([ppl_comp_num], [ppl_comp_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk3] FOREIGN KEY ([alloc_type_code]) REFERENCES [dbo].[allocation_type] ([alloc_type_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk5] FOREIGN KEY ([alloc_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk6] FOREIGN KEY ([sch_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk7] FOREIGN KEY ([alloc_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk8] FOREIGN KEY ([alloc_load_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation] ADD CONSTRAINT [allocation_fk9] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
GRANT DELETE ON  [dbo].[allocation] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation] TO [next_usr]
GO
