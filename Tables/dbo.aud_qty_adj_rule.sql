CREATE TABLE [dbo].[aud_qty_adj_rule]
(
[qty_adj_rule_num] [int] NOT NULL,
[qty_adj_rule_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qty_adj_rule_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_code1] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_code2] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[rule_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[price_precision] [tinyint] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qty_adj_rule] ON [dbo].[aud_qty_adj_rule] ([qty_adj_rule_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_qty_adj_rule_idx1] ON [dbo].[aud_qty_adj_rule] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_qty_adj_rule] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_qty_adj_rule] TO [next_usr]
GO
