CREATE TABLE [dbo].[aud_ag_btt_ack_cnfrm_litem]
(
[fdd_oid] [int] NOT NULL,
[fd_oid] [int] NOT NULL,
[line_item_num] [int] NOT NULL,
[parcel_num] [int] NULL,
[event_type] [char] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fail_desc] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[ext_char_col1] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_char_col3] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ext_int_col1] [int] NULL,
[ext_int_col2] [int] NULL,
[ext_int_col3] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_btt_ack_cnfrm_litem] ON [dbo].[aud_ag_btt_ack_cnfrm_litem] ([fdd_oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_ag_btt_ack_cnfrm_litem_idx1] ON [dbo].[aud_ag_btt_ack_cnfrm_litem] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_ag_btt_ack_cnfrm_litem] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_ag_btt_ack_cnfrm_litem] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_ag_btt_ack_cnfrm_litem] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_ag_btt_ack_cnfrm_litem] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_ag_btt_ack_cnfrm_litem] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_ag_btt_ack_cnfrm_litem', NULL, NULL
GO
