CREATE TABLE [dbo].[aud_contract]
(
[contr_num] [int] NOT NULL,
[contr_rev_num] [int] NOT NULL,
[contr_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NOT NULL,
[contr_creation_date] [datetime] NOT NULL,
[contr_creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_reviewer_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_status_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_on_hold_inds] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_confirmed_date] [datetime] NULL,
[contr_confirmed_by] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract] ON [dbo].[aud_contract] ([contr_num], [contr_rev_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_idx1] ON [dbo].[aud_contract] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_contract] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_contract] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_contract] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_contract] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_contract] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_contract', NULL, NULL
GO
