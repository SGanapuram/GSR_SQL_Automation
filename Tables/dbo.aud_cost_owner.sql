CREATE TABLE [dbo].[aud_cost_owner]
(
[cost_owner_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_owner_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_owner_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bc_owner_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_table_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_owner_key1_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_owner_key2_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_key3_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_key4_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_key5_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_key6_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_key7_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_owner_key8_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_owner] ON [dbo].[aud_cost_owner] ([cost_owner_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_owner_idx1] ON [dbo].[aud_cost_owner] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cost_owner] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cost_owner] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cost_owner] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cost_owner] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_owner] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cost_owner', NULL, NULL
GO
