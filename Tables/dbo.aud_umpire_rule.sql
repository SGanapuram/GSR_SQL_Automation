CREATE TABLE [dbo].[aud_umpire_rule]
(
[rule_num] [int] NOT NULL,
[short_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[long_desc] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_umpire_rule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_umpire_rule] TO [next_usr]
GO
