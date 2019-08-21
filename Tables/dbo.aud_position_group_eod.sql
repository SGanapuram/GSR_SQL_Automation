CREATE TABLE [dbo].[aud_position_group_eod]
(
[pos_group_num] [int] NOT NULL,
[is_spread_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_position_group_eod] ON [dbo].[aud_position_group_eod] ([pos_group_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_position_group_eod_idx1] ON [dbo].[aud_position_group_eod] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_position_group_eod] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_position_group_eod] TO [next_usr]
GO
