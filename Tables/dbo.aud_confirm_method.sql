CREATE TABLE [dbo].[aud_confirm_method]
(
[oid] [int] NOT NULL,
[confirm_method_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_confirm_method] ON [dbo].[aud_confirm_method] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_confirm_method_idx1] ON [dbo].[aud_confirm_method] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_confirm_method] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_confirm_method] TO [next_usr]
GO
