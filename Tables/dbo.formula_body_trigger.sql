CREATE TABLE [dbo].[formula_body_trigger]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[trigger_num] [tinyint] NOT NULL,
[trigger_qty] [float] NOT NULL,
[trigger_date] [datetime] NOT NULL,
[trans_id] [int] NOT NULL,
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
ALTER TABLE [dbo].[formula_body_trigger] ADD CONSTRAINT [formula_body_trigger_pk] PRIMARY KEY NONCLUSTERED  ([formula_num], [formula_body_num], [trigger_num]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [formula_body_trigger] ON [dbo].[formula_body_trigger] ([formula_body_num], [formula_num], [trigger_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[formula_body_trigger] ADD CONSTRAINT [formula_body_trigger_fk1] FOREIGN KEY ([trigger_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[formula_body_trigger] ADD CONSTRAINT [formula_body_trigger_fk2] FOREIGN KEY ([trigger_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[formula_body_trigger] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[formula_body_trigger] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[formula_body_trigger] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[formula_body_trigger] TO [next_usr]
GO
