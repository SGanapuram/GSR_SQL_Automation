CREATE TABLE [dbo].[aud_cost_approval]
(
[cost_approval_num] [int] NOT NULL,
[user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[acct_num] [int] NULL,
[cost_item] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_approval] ON [dbo].[aud_cost_approval] ([cost_approval_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_approval_idx1] ON [dbo].[aud_cost_approval] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_cost_approval] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_approval] TO [next_usr]
GO
