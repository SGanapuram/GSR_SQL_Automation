CREATE TABLE [dbo].[aud_collateral_party]
(
[coll_party_num] [int] NOT NULL,
[mca_num] [int] NOT NULL,
[acct_num] [int] NOT NULL,
[is_payor] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[coll_party_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[payor_acct_num] [int] NULL,
[invoice_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_collateral_party] ON [dbo].[aud_collateral_party] ([coll_party_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_collateral_party_idx1] ON [dbo].[aud_collateral_party] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_collateral_party] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_collateral_party] TO [next_usr]
GO
