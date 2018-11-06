CREATE TABLE [dbo].[POSGRID_snapshot_pos_summary]
(
[pos_num] [int] NOT NULL,
[asof_date] [datetime] NOT NULL,
[long_qty] [float] NOT NULL,
[short_qty] [float] NOT NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [POSGRID_snapshot_pos_summary_idx1] ON [dbo].[POSGRID_snapshot_pos_summary] ([pos_num], [asof_date]) INCLUDE ([long_qty], [qty_uom_code], [short_qty], [trans_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[POSGRID_snapshot_pos_summary] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[POSGRID_snapshot_pos_summary] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[POSGRID_snapshot_pos_summary] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[POSGRID_snapshot_pos_summary] TO [next_usr]
GO
