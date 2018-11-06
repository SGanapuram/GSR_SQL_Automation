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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lc_allocation_deltrg]
on [dbo].[lc_allocation]
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
from icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(lc_allocation) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_lc_allocation
   (lc_num,
    lc_alloc_num,
    cmdty_code,
    lc_alloc_min_qty,
    lc_alloc_max_qty,
    lc_alloc_qty_uom_code,
    lc_alloc_qty_tol_pcnt,
    lc_alloc_qty_tol_oper,
    lc_alloc_min_amt,
    lc_alloc_max_amt,
    lc_alloc_amt_curr_code,
    lc_alloc_amt_tol_pcnt,
    lc_alloc_amt_tol_oper,
    lc_alloc_amt_cap,
    lc_alloc_base_price,
    lc_alloc_base_price_uom_code,
    lc_alloc_base_price_curr_code,
    lc_alloc_formula_num,
    lc_alloc_start_date,
    lc_alloc_end_date,
    lc_alloc_partial_ship_ind,
    lc_alloc_last_bl_date,
    lc_alloc_trans_ship_ind,
    lc_alloc_amt_left,
    trans_id,
    resp_trans_id)
select
   d.lc_num,
   d.lc_alloc_num,
   d.cmdty_code,
   d.lc_alloc_min_qty,
   d.lc_alloc_max_qty,
   d.lc_alloc_qty_uom_code,
   d.lc_alloc_qty_tol_pcnt,
   d.lc_alloc_qty_tol_oper,
   d.lc_alloc_min_amt,
   d.lc_alloc_max_amt,
   d.lc_alloc_amt_curr_code,
   d.lc_alloc_amt_tol_pcnt,
   d.lc_alloc_amt_tol_oper,
   d.lc_alloc_amt_cap,
   d.lc_alloc_base_price,
   d.lc_alloc_base_price_uom_code,
   d.lc_alloc_base_price_curr_code,
   d.lc_alloc_formula_num,
   d.lc_alloc_start_date,
   d.lc_alloc_end_date,
   d.lc_alloc_partial_ship_ind,
   d.lc_alloc_last_bl_date,
   d.lc_alloc_trans_ship_ind,
   d.lc_alloc_amt_left,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'LcAllocation'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it
      where it.trans_id = @atrans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'D',
             @the_entity_name,
             convert(varchar(40), d.lc_num),
             convert(varchar(40), d.lc_alloc_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             @the_sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
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
             convert(varchar(40), d.lc_num),
             convert(varchar(40), d.lc_alloc_num),
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
             convert(varchar(40), d.lc_num),
             convert(varchar(40), d.lc_alloc_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           deleted d,
           dbo.icts_transaction it
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
             convert(varchar(40), d.lc_num),
             convert(varchar(40), d.lc_alloc_num),
             null,
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.icts_transaction it,
           deleted d
      where it.trans_id = @atrans_id

      /* END_TRANSACTION_TOUCH */
   end
   
return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lc_allocation_instrg]
on [dbo].[lc_allocation]
for insert
as
declare @num_rows        int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'LcAllocation'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it,
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'I',
             @the_entity_name,
             convert(varchar(40), lc_num),
             convert(varchar(40), lc_alloc_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
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

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'INSERT',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40), lc_num),
                convert(varchar(40), lc_alloc_num),
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
             convert(varchar(40), lc_num),
             convert(varchar(40), lc_alloc_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           inserted i,
           dbo.icts_transaction it
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
             convert(varchar(40), lc_num),
             convert(varchar(40), lc_alloc_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it,
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lc_allocation_updtrg]
on [dbo].[lc_allocation]
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
   raiserror ('(lc_allocation) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(lc_allocation) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.lc_num = d.lc_num and 
                 i.lc_alloc_num = d.lc_alloc_num )
begin
   select @errmsg = '(lc_allocation) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.lc_num) + ',' + 
                                        convert(varchar, i.lc_alloc_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(lc_num) or  
   update(lc_alloc_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.lc_num = d.lc_num and 
                                   i.lc_alloc_num = d.lc_alloc_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(lc_allocation) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_lc_allocation
      (lc_num,
       lc_alloc_num,
       cmdty_code,
       lc_alloc_min_qty,
       lc_alloc_max_qty,
       lc_alloc_qty_uom_code,
       lc_alloc_qty_tol_pcnt,
       lc_alloc_qty_tol_oper,
       lc_alloc_min_amt,
       lc_alloc_max_amt,
       lc_alloc_amt_curr_code,
       lc_alloc_amt_tol_pcnt,
       lc_alloc_amt_tol_oper,
       lc_alloc_amt_cap,
       lc_alloc_base_price,
       lc_alloc_base_price_uom_code,
       lc_alloc_base_price_curr_code,
       lc_alloc_formula_num,
       lc_alloc_start_date,
       lc_alloc_end_date,
       lc_alloc_partial_ship_ind,
       lc_alloc_last_bl_date,
       lc_alloc_trans_ship_ind,
       lc_alloc_amt_left,
       trans_id,
       resp_trans_id)
   select
      d.lc_num,
      d.lc_alloc_num,
      d.cmdty_code,
      d.lc_alloc_min_qty,
      d.lc_alloc_max_qty,
      d.lc_alloc_qty_uom_code,
      d.lc_alloc_qty_tol_pcnt,
      d.lc_alloc_qty_tol_oper,
      d.lc_alloc_min_amt,
      d.lc_alloc_max_amt,
      d.lc_alloc_amt_curr_code,
      d.lc_alloc_amt_tol_pcnt,
      d.lc_alloc_amt_tol_oper,
      d.lc_alloc_amt_cap,
      d.lc_alloc_base_price,
      d.lc_alloc_base_price_uom_code,
      d.lc_alloc_base_price_curr_code,
      d.lc_alloc_formula_num,
      d.lc_alloc_start_date,
      d.lc_alloc_end_date,
      d.lc_alloc_partial_ship_ind,
      d.lc_alloc_last_bl_date,
      d.lc_alloc_trans_ship_ind,
      d.lc_alloc_amt_left,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.lc_num = i.lc_num and
         d.lc_alloc_num = i.lc_alloc_num 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'LcAllocation'

   if @num_rows = 1
   begin
      select @the_tran_type = it.type,
             @the_sequence = it.sequence
      from dbo.icts_transaction it,
           inserted i
      where it.trans_id = i.trans_id

      /* BEGIN_ALS_RUN_TOUCH */

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             @the_entity_name,
             convert(varchar(40), lc_num),
             convert(varchar(40), lc_alloc_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             @the_sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
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
             convert(varchar(40), lc_num),
             convert(varchar(40), lc_alloc_num),
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
             convert(varchar(40), lc_num),
             convert(varchar(40), lc_alloc_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.als_module_entity a,
           dbo.server_config sc,
           inserted i,
           dbo.icts_transaction it
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
             convert(varchar(40), lc_num),
             convert(varchar(40), lc_alloc_num),
             null,
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it,
           inserted i
      where i.trans_id = it.trans_id

      /* END_TRANSACTION_TOUCH */
   end
   
return
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
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'lc_allocation', NULL, NULL
GO
