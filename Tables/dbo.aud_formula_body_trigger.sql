CREATE TABLE [dbo].[aud_formula_body_trigger]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[trigger_num] [tinyint] NOT NULL,
[trigger_qty] [float] NOT NULL,
[trigger_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[trigger_price] [float] NULL,
[trigger_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[input_qty] [float] NULL,
[input_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[input_lock_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parcel_num] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [aud_formula_body_trigger] ON [dbo].[aud_formula_body_trigger] ([formula_body_num], [formula_num], [trigger_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_body_trigger_idx] ON [dbo].[aud_formula_body_trigger] ([formula_num], [formula_body_num], [trigger_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_body_trigger_idx1] ON [dbo].[aud_formula_body_trigger] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_formula_body_trigger] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_formula_body_trigger] TO [next_usr]
GO
