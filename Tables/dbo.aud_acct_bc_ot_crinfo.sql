CREATE TABLE [dbo].[aud_acct_bc_ot_crinfo]
(
[oid] [int] NOT NULL,
[acct_bookcomp_key] [int] NOT NULL,
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[order_direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bc_ot_crinfo] ON [dbo].[aud_acct_bc_ot_crinfo] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_acct_bc_ot_crinfo_idx1] ON [dbo].[aud_acct_bc_ot_crinfo] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_acct_bc_ot_crinfo] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_acct_bc_ot_crinfo] TO [next_usr]
GO
