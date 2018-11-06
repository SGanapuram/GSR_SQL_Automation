CREATE TABLE [dbo].[aud_inventory_roll_criteria]
(
[roll_criteria_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_num] [int] NULL,
[days_after] [smallint] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inventory_roll_criteria] ON [dbo].[aud_inventory_roll_criteria] ([roll_criteria_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_inv_roll_criteria_idx1] ON [dbo].[aud_inventory_roll_criteria] ([trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aud_inventory_roll_criteria] TO [ictspurge]
GO
GRANT SELECT ON  [dbo].[aud_inventory_roll_criteria] TO [ictspurge]
GO
GRANT UPDATE ON  [dbo].[aud_inventory_roll_criteria] TO [ictspurge]
GO
GRANT INSERT ON  [dbo].[aud_inventory_roll_criteria] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_inventory_roll_criteria] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'aud_inventory_roll_criteria', NULL, NULL
GO
