CREATE TABLE [dbo].[aud_allocation_ext_info]
(
[alloc_num] [int] NOT NULL,
[custom_field1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[custom_field5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_ext_info] ON [dbo].[aud_allocation_ext_info] ([alloc_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_allocation_ext_info_idx1] ON [dbo].[aud_allocation_ext_info] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_allocation_ext_info] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_allocation_ext_info] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_allocation_ext_info] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_allocation_ext_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_allocation_ext_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_allocation_ext_info', NULL, NULL
GO
