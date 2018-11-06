CREATE TABLE [dbo].[aud_custom_contract_range]
(
[range_num] [int] NOT NULL,
[prefix_string] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[postfix_string] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[last_num] [int] NOT NULL,
[max_num] [int] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[number_format_width] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_custom_contract_range] ON [dbo].[aud_custom_contract_range] ([range_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_custom_contract_range] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_custom_contract_range] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_custom_contract_range] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_custom_contract_range] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_custom_contract_range] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_custom_contract_range', NULL, NULL
GO
