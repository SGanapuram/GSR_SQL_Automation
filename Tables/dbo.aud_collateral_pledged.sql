CREATE TABLE [dbo].[aud_collateral_pledged]
(
[coll_pledged_num] [int] NOT NULL,
[mca_num] [int] NOT NULL,
[margin_call_num] [int] NULL,
[coll_pledged_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_num] [int] NULL,
[lc_num] [int] NULL,
[pg_num] [int] NULL,
[mkt_security_num] [int] NULL,
[cash_coll_num] [int] NULL,
[coll_party_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_collateral_pledged_idx1] ON [dbo].[aud_collateral_pledged] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_collateral_pledged] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_collateral_pledged] TO [next_usr]
GO
