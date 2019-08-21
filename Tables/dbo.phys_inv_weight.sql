CREATE TABLE [dbo].[phys_inv_weight]
(
[exec_inv_num] [int] NOT NULL,
[measure_date] [datetime] NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prim_qty] [float] NULL,
[prim_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_qty] [float] NULL,
[sec_qty_uom_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[use_in_pl_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[weight_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[weight_detail_num] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[phys_inv_weight] ADD CONSTRAINT [phys_inv_weight_pk] PRIMARY KEY CLUSTERED  ([exec_inv_num], [measure_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[phys_inv_weight] ADD CONSTRAINT [phys_inv_weight_fk1] FOREIGN KEY ([exec_inv_num]) REFERENCES [dbo].[exec_phys_inv] ([exec_inv_num])
GO
GRANT DELETE ON  [dbo].[phys_inv_weight] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[phys_inv_weight] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[phys_inv_weight] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[phys_inv_weight] TO [next_usr]
GO
