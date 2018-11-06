CREATE TABLE [dbo].[aud_order_instruction]
(
[order_instr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[order_instr_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_order_instruction] ON [dbo].[aud_order_instruction] ([order_instr_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_order_instruction_idx1] ON [dbo].[aud_order_instruction] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_order_instruction] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_order_instruction] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_order_instruction] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_order_instruction] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_order_instruction] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_order_instruction', NULL, NULL
GO
