CREATE TABLE [dbo].[aud_special_condition]
(
[special_cond_num] [int] NOT NULL,
[special_cond_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[special_cond_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_special_condition] ON [dbo].[aud_special_condition] ([special_cond_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_special_condition_idx1] ON [dbo].[aud_special_condition] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_special_condition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_special_condition] TO [next_usr]
GO
