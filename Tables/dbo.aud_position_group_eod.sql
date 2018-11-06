CREATE TABLE [dbo].[aud_position_group_eod]
(
[pos_group_num] [int] NOT NULL,
[is_spread_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_position_group_eod] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[aud_position_group_eod] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_position_group_eod] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[aud_position_group_eod] TO [next_usr]
GO
