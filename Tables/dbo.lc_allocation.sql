CREATE TABLE [dbo].[lc_allocation]
(
[lc_num] [int] NOT NULL,
[lc_alloc_num] [tinyint] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_alloc_min_qty] [float] NULL,
[lc_alloc_max_qty] [float] NULL,
[lc_alloc_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_alloc_qty_tol_pcnt] [tinyint] NULL,
[lc_alloc_qty_tol_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_alloc_min_amt] [float] NULL,
[lc_alloc_max_amt] [float] NULL,
[lc_alloc_amt_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_alloc_amt_tol_pcnt] [tinyint] NULL,
[lc_alloc_amt_tol_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_alloc_amt_cap] [float] NULL,
[lc_alloc_base_price] [float] NULL,
[lc_alloc_base_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_alloc_base_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_alloc_formula_num] [int] NULL,
[lc_alloc_start_date] [datetime] NULL,
[lc_alloc_end_date] [datetime] NULL,
[lc_alloc_partial_ship_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_alloc_last_bl_date] [datetime] NULL,
[lc_alloc_trans_ship_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_alloc_amt_left] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lc_allocation] ADD CONSTRAINT [lc_allocation_pk] PRIMARY KEY CLUSTERED  ([lc_num], [lc_alloc_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lc_allocation] ADD CONSTRAINT [lc_allocation_fk1] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[lc_allocation] ADD CONSTRAINT [lc_allocation_fk2] FOREIGN KEY ([lc_alloc_amt_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[lc_allocation] ADD CONSTRAINT [lc_allocation_fk3] FOREIGN KEY ([lc_alloc_base_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[lc_allocation] ADD CONSTRAINT [lc_allocation_fk5] FOREIGN KEY ([lc_alloc_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[lc_allocation] ADD CONSTRAINT [lc_allocation_fk6] FOREIGN KEY ([lc_alloc_base_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[lc_allocation] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[lc_allocation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[lc_allocation] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[lc_allocation] TO [next_usr]
GO
