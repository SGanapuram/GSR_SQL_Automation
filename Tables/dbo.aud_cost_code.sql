CREATE TABLE [dbo].[aud_cost_code]
(
[cost_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_code_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_code_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_code_order_num] [smallint] NULL,
[pl_implication] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[cost_code_long_name] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_code_idx1] ON [dbo].[aud_cost_code] ([cost_code], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_cost_code_idx2] ON [dbo].[aud_cost_code] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_cost_code] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_cost_code] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_cost_code] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_cost_code] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_cost_code] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_cost_code', NULL, NULL
GO
