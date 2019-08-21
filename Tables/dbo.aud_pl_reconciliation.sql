CREATE TABLE [dbo].[aud_pl_reconciliation]
(
[pl_reconciliation_num] [int] NOT NULL,
[source_port_num] [int] NOT NULL,
[dest_port_num] [int] NOT NULL,
[offset_amount] [float] NOT NULL,
[booking_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pl_reconciliation] ON [dbo].[aud_pl_reconciliation] ([pl_reconciliation_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_pl_reconciliation_idx1] ON [dbo].[aud_pl_reconciliation] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_pl_reconciliation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_pl_reconciliation] TO [next_usr]
GO
