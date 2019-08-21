CREATE TABLE [dbo].[aud_mot]
(
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_type_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mot_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ppl_basis_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_loss_allowance] [float] NULL,
[ppl_cycle_freq] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_num_of_cycles] [tinyint] NULL,
[ppl_split_cycle_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_num] [int] NULL,
[ppl_tariff_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ppl_enforce_loc_seq_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transport_trade_num] [int] NULL,
[transport_order_num] [smallint] NULL,
[transport_item_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[mot_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ship_reg] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[imo_num] [char] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mot] ON [dbo].[aud_mot] ([mot_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_mot_idx1] ON [dbo].[aud_mot] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_mot] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_mot] TO [next_usr]
GO
