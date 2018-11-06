CREATE TABLE [dbo].[aud_allocation_chain]
(
[alloc_num] [int] NOT NULL,
[alloc_chain_num] [smallint] NOT NULL,
[acct_num] [int] NOT NULL,
[alloc_chain_acct_seq_num] [smallint] NULL,
[alloc_confirmed_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[circled_qty] [decimal] (20, 8) NULL,
[circled_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_chain] ON [dbo].[aud_allocation_chain] ([alloc_num], [alloc_chain_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_chain_idx1] ON [dbo].[aud_allocation_chain] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_allocation_chain] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_allocation_chain] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_allocation_chain] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_allocation_chain] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_allocation_chain] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_allocation_chain', NULL, NULL
GO
