CREATE TABLE [dbo].[aud_formula_body_trigger_actual]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[trigger_num] [tinyint] NOT NULL,
[parcel_num] [int] NOT NULL,
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[applied_trigger_pcnt] [float] NULL,
[applied_trigger_qty] [float] NULL,
[applied_trigger_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_triggered_pcnt] [float] NULL,
[actual_triggered_qty] [float] NULL,
[actual_triggered_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fully_triggered] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL,
[trigger_actual_num] [int] NOT NULL,
[trigger_rem_bal] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_body_trigger_actual] ON [dbo].[aud_formula_body_trigger_actual] ([formula_num], [formula_body_num], [trigger_num], [parcel_num], [alloc_num], [alloc_item_num], [ai_est_actual_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_formula_body_trigger_actual_idx1] ON [dbo].[aud_formula_body_trigger_actual] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_formula_body_trigger_actual] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_formula_body_trigger_actual] TO [next_usr]
GO
