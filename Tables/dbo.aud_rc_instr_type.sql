CREATE TABLE [dbo].[aud_rc_instr_type]
(
[instr_type_code] [char] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[instr_type_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rc_instr_type] ON [dbo].[aud_rc_instr_type] ([instr_type_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_rc_instr_type_idx1] ON [dbo].[aud_rc_instr_type] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_rc_instr_type] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_rc_instr_type] TO [next_usr]
GO
