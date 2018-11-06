CREATE TABLE [dbo].[inventory_build_draw]
(
[inv_num] [int] NOT NULL,
[inv_b_d_num] [int] NOT NULL,
[inv_b_d_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[inv_b_d_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[adj_qty] [float] NULL,
[adj_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_b_d_date] [datetime] NULL,
[inv_b_d_qty] [float] NULL,
[inv_b_d_actual_qty] [float] NULL,
[inv_b_d_cost] [float] NULL,
[inv_b_d_cost_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_b_d_cost_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_draw_b_d_num] [smallint] NULL,
[inv_b_d_tax_status_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[pos_group_num] [int] NULL,
[r_inv_b_d_cost] [float] NULL,
[unr_inv_b_d_cost] [float] NULL,
[voyage_code] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[adj_type_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_b_d_cost_wacog] [float] NULL,
[r_inv_b_d_cost_wacog] [float] NULL,
[unr_inv_b_d_cost_wacog] [float] NULL,
[inv_curr_actual_qty] [decimal] (20, 8) NULL,
[inv_curr_proj_qty] [decimal] (20, 8) NULL,
[associated_trade] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inventory_build_draw_deltrg]
on [dbo].[inventory_build_draw]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(inventory_build_draw) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_inventory_build_draw
   (inv_num,
    inv_b_d_num,
    inv_b_d_type,
    inv_b_d_status,
    trade_num,
    order_num,
    item_num,
    alloc_num,
    alloc_item_num,
    adj_qty,
    adj_qty_uom_code,
    inv_b_d_date,
    inv_b_d_qty,
    inv_b_d_actual_qty,
    inv_b_d_cost,
    inv_b_d_cost_curr_code,
    inv_b_d_cost_uom_code,
    inv_draw_b_d_num,
    inv_b_d_tax_status_code,
    cmnt_num,
    pos_group_num,
    r_inv_b_d_cost,
    unr_inv_b_d_cost,
    voyage_code,
    adj_type_ind,
    inv_b_d_cost_wacog,
    r_inv_b_d_cost_wacog,
    unr_inv_b_d_cost_wacog,
    inv_curr_actual_qty,	
    inv_curr_proj_qty,
    associated_trade,	
    trans_id,
    resp_trans_id)
select
   d.inv_num,
   d.inv_b_d_num,
   d.inv_b_d_type,
   d.inv_b_d_status,
   d.trade_num,
   d.order_num,
   d.item_num,
   d.alloc_num,
   d.alloc_item_num,
   d.adj_qty,
   d.adj_qty_uom_code,
   d.inv_b_d_date,
   d.inv_b_d_qty,
   d.inv_b_d_actual_qty,
   d.inv_b_d_cost,
   d.inv_b_d_cost_curr_code,
   d.inv_b_d_cost_uom_code,
   d.inv_draw_b_d_num,
   d.inv_b_d_tax_status_code,
   d.cmnt_num,
   d.pos_group_num,
   d.r_inv_b_d_cost,
   d.unr_inv_b_d_cost,
   d.voyage_code,
   d.adj_type_ind,
   d.inv_b_d_cost_wacog,
   d.r_inv_b_d_cost_wacog,
   d.unr_inv_b_d_cost_wacog,
   d.inv_curr_actual_qty,	
   d.inv_curr_proj_qty,	
   d.associated_trade,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'InventoryBuildDraw'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK)
      where it.trans_id = @atrans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.inv_num),
             convert(varchar(40), d.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           deleted d
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 4) = 4 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'DELETE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), d.inv_num),
             convert(varchar(40), d.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             @the_sequence
      from deleted d

      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.inv_num),
             convert(varchar(40), d.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           deleted d,
           dbo.icts_transaction it WITH (NOLOCK)
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 4) = 4 AND
            a.entity_name = @the_entity_name AND
            it.trans_id = @atrans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'DELETE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), d.inv_num),
             convert(varchar(40), d.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           deleted d
      where it.trans_id = @atrans_id

      /* END_TRANSACTION_TOUCH */
   end


return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inventory_build_draw_instrg]
on [dbo].[inventory_build_draw]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'InventoryBuildDraw'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40), i.inv_num),
             convert(varchar(40), i.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 1) = 1 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), i.inv_num),
             convert(varchar(40), i.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from inserted i

      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40), i.inv_num),
             convert(varchar(40), i.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i,
           dbo.icts_transaction it WITH (NOLOCK)
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 1) = 1 AND
            a.entity_name = @the_entity_name AND
            i.trans_id = it.trans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), i.inv_num),
             convert(varchar(40), i.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inventory_build_draw_updtrg]
on [dbo].[inventory_build_draw]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(inventory_build_draw) The change needs to be attached with a new trans_id',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(inventory_build_draw) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.inv_num = d.inv_num and 
                 i.inv_b_d_num = d.inv_b_d_num )
begin
   raiserror ('(inventory_build_draw) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(inv_num) or  
   update(inv_b_d_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.inv_num = d.inv_num and 
                                   i.inv_b_d_num = d.inv_b_d_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(inventory_build_draw) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_inventory_build_draw
      (inv_num,
       inv_b_d_num,
       inv_b_d_type,
       inv_b_d_status,
       trade_num,
       order_num,
       item_num,
       alloc_num,
       alloc_item_num,
       adj_qty,
       adj_qty_uom_code,
       inv_b_d_date,
       inv_b_d_qty,
       inv_b_d_actual_qty,
       inv_b_d_cost,
       inv_b_d_cost_curr_code,
       inv_b_d_cost_uom_code,
       inv_draw_b_d_num,
       inv_b_d_tax_status_code,
       cmnt_num,
       pos_group_num,
       r_inv_b_d_cost,
       unr_inv_b_d_cost,
       voyage_code,
       adj_type_ind,
       inv_b_d_cost_wacog,
       r_inv_b_d_cost_wacog,
       unr_inv_b_d_cost_wacog,
       inv_curr_actual_qty,	
       inv_curr_proj_qty,	
       associated_trade,
       trans_id,
       resp_trans_id)
   select
      d.inv_num,
      d.inv_b_d_num,
      d.inv_b_d_type,
      d.inv_b_d_status,
      d.trade_num,
      d.order_num,
      d.item_num,
      d.alloc_num,
      d.alloc_item_num,
      d.adj_qty,
      d.adj_qty_uom_code,
      d.inv_b_d_date,
      d.inv_b_d_qty,
      d.inv_b_d_actual_qty,
      d.inv_b_d_cost,
      d.inv_b_d_cost_curr_code,
      d.inv_b_d_cost_uom_code,
      d.inv_draw_b_d_num,
      d.inv_b_d_tax_status_code,
      d.cmnt_num,
      d.pos_group_num,
      d.r_inv_b_d_cost,
      d.unr_inv_b_d_cost,
      d.voyage_code,
      d.adj_type_ind,
      d.inv_b_d_cost_wacog,
      d.r_inv_b_d_cost_wacog,
      d.unr_inv_b_d_cost_wacog,
      d.inv_curr_actual_qty,	
      d.inv_curr_proj_qty,	
      d.associated_trade,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.inv_num = i.inv_num and
         d.inv_b_d_num = i.inv_b_d_num 

/* AUDIT_CODE_END */


declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'InventoryBuildDraw'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40), i.inv_num),
             convert(varchar(40), i.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (@the_tran_type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (@the_tran_type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (@the_tran_type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (@the_tran_type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (@the_tran_type = 'A') )
            ) AND
            (a.operation_type_mask & 2) = 2 AND
            a.entity_name = @the_entity_name

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), i.inv_num),
             convert(varchar(40), i.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from inserted i

      /* END_TRANSACTION_TOUCH */
   end
   else
   begin  /* if @num_rows > 1 */
      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40), i.inv_num),
             convert(varchar(40), i.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a WITH (NOLOCK),
           dbo.server_config sc WITH (NOLOCK),
           inserted i,
           dbo.icts_transaction it WITH (NOLOCK)
      where a.als_module_group_id = sc.als_module_group_id AND
            ( ( ((sc.trans_type_mask &  1) =  1) and (it.type = 'E') ) OR
              ( ((sc.trans_type_mask &  2) =  2) and (it.type = 'U') ) OR
              ( ((sc.trans_type_mask &  4) =  4) and (it.type = 'S') ) OR
              ( ((sc.trans_type_mask &  8) =  8) and (it.type = 'P') ) OR
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'I') ) OR
              ( ((sc.trans_type_mask & 32) = 32) and (it.type = 'A') )
            ) AND
            (a.operation_type_mask & 2) = 2 AND
            a.entity_name = @the_entity_name AND
            i.trans_id = it.trans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), i.inv_num),
             convert(varchar(40), i.inv_b_d_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */
   end


return
GO
ALTER TABLE [dbo].[inventory_build_draw] ADD CONSTRAINT [inventory_build_draw_pk] PRIMARY KEY CLUSTERED  ([inv_num], [inv_b_d_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_build_draw_idx2] ON [dbo].[inventory_build_draw] ([alloc_num], [alloc_item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_build_draw_idx4] ON [dbo].[inventory_build_draw] ([inv_num], [alloc_num], [inv_b_d_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_build_draw_idx3] ON [dbo].[inventory_build_draw] ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inventory_build_draw] ADD CONSTRAINT [inventory_build_draw_fk3] FOREIGN KEY ([inv_b_d_cost_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[inventory_build_draw] ADD CONSTRAINT [inventory_build_draw_fk6] FOREIGN KEY ([adj_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[inventory_build_draw] ADD CONSTRAINT [inventory_build_draw_fk7] FOREIGN KEY ([inv_b_d_cost_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[inventory_build_draw] ADD CONSTRAINT [inventory_build_draw_fk8] FOREIGN KEY ([voyage_code]) REFERENCES [dbo].[voyage] ([voyage_code])
GO
GRANT DELETE ON  [dbo].[inventory_build_draw] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inventory_build_draw] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inventory_build_draw] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inventory_build_draw] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'inventory_build_draw', NULL, NULL
GO
