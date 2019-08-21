CREATE TABLE [dbo].[aud_credit_term_group]
(
[group_num] [int] NOT NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_term_group] ON [dbo].[aud_credit_term_group] ([group_num], [credit_term_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_credit_term_group_idx1] ON [dbo].[aud_credit_term_group] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_credit_term_group] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_credit_term_group] TO [next_usr]
GO
