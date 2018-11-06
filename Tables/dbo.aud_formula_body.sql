CREATE TABLE [dbo].[aud_formula_body]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[formula_body_string] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_parse_string] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_body_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_qty_pcnt_val] [float] NULL,
[formula_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_body_text] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_parse_text] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_price_start_date] [datetime] NULL,
[avg_price_end_date] [datetime] NULL,
[range_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[complexity_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[differential_val] [float] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[holiday_pricing_rule] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[saturday_pricing_rule] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sunday_pricing_rule] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parent_fb_num] [int] NULL,
[fb_trigger_num] [tinyint] NULL,
[float_value] [float] NULL,
[char_value] [char] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [aud_formula_body] ON [dbo].[aud_formula_body] ([formula_body_num], [formula_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_body_idx1] ON [dbo].[aud_formula_body] ([formula_num], [formula_body_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_body_idx2] ON [dbo].[aud_formula_body] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_formula_body] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_formula_body] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_formula_body] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_formula_body] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_formula_body] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_formula_body', NULL, NULL
GO
