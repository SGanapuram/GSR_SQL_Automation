CREATE TABLE [dbo].[fx_exposure_dist]
(
[oid] [int] NOT NULL,
[fx_owner_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_exp_num] [int] NULL,
[fx_owner_key1] [int] NULL,
[fx_owner_key2] [int] NULL,
[fx_owner_key3] [int] NULL,
[fx_owner_key4] [int] NULL,
[fx_owner_key5] [int] NULL,
[fx_owner_key6] [int] NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[fx_qty] [decimal] (20, 8) NULL,
[fx_price] [decimal] (20, 8) NULL,
[fx_amt] [decimal] (20, 8) NULL,
[fx_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_drop_date] [datetime] NULL,
[fx_priced_amt] [decimal] (20, 8) NULL,
[fx_real_port_num] [int] NULL,
[fx_custom_column1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_custom_column2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_custom_column3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fx_custom_column4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_exposure_dist_deltrg]
on [dbo].[fx_exposure_dist]
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
   select @errmsg = '(fx_exposure_dist) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_fx_exposure_dist
   (oid,
   fx_owner_code,
   fx_exp_num,
   fx_owner_key1,
   fx_owner_key2,
   fx_owner_key3,
   fx_owner_key4,
   fx_owner_key5,
   fx_owner_key6,
   trade_num,
   order_num,
   item_num,
   fx_qty,
   fx_price,
   fx_amt,
   fx_qty_uom_code,
   fx_price_curr_code,
   fx_price_uom_code,
   fx_drop_date,
   fx_priced_amt,
   fx_real_port_num,
   fx_custom_column1,
   fx_custom_column2,
   fx_custom_column3,
   fx_custom_column4,
   trans_id,
   resp_trans_id)
select
    d.oid,
   d.fx_owner_code,
   d.fx_exp_num,
   d.fx_owner_key1,
   d.fx_owner_key2,
   d.fx_owner_key3,
   d.fx_owner_key4,
   d.fx_owner_key5,
   d.fx_owner_key6,
   d.trade_num,
   d.order_num,
   d.item_num,
   d.fx_qty,
   d.fx_price,
   d.fx_amt,
   d.fx_qty_uom_code,
   d.fx_price_curr_code,
   d.fx_price_uom_code,
   d.fx_drop_date,
   d.fx_priced_amt,
   d.fx_real_port_num,
   d.fx_custom_column1,
   d.fx_custom_column2,
   d.fx_custom_column3,
   d.fx_custom_column4,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'FxExposureDist'

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
             convert(varchar(40), d.oid),
             null,
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

      if @the_tran_type <> 'E'
         insert dbo.transaction_touch
         select 'DELETE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40), d.oid),
                null,
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
             convert(varchar(40), d.oid),
             null,
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
             convert(varchar(40), d.oid),
             null,
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
      where it.trans_id = @atrans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_exposure_dist_instrg]
on [dbo].[fx_exposure_dist]
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

   select @the_entity_name = 'FxExposureDist'

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
             convert(varchar(40), i.oid),
             null,
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

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'INSERT',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40), i.oid),
             null,
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
             convert(varchar(40), i.oid),
             null,
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
             convert(varchar(40), i.oid),
             null,
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
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_exposure_dist_updtrg]
on [dbo].[fx_exposure_dist]
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
   raiserror ('(fx_exposure_dist) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(fx_exposure_dist) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
   raiserror ('(fx_exposure_dist) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(fx_exposure_dist) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_fx_exposure_dist
      (oid,
       fx_owner_code,
       fx_exp_num,
       fx_owner_key1,
       fx_owner_key2,
       fx_owner_key3,
       fx_owner_key4,
       fx_owner_key5,
       fx_owner_key6,
       trade_num,
       order_num,
       item_num,
       fx_qty,
       fx_price,
       fx_amt,
       fx_qty_uom_code,
       fx_price_curr_code,
       fx_price_uom_code,
       fx_drop_date,
       fx_priced_amt,
       fx_real_port_num,
       fx_custom_column1,
       fx_custom_column2,
       fx_custom_column3,
       fx_custom_column4,
       trans_id,
       resp_trans_id)
   select
       d.oid,
       d.fx_owner_code,
       d.fx_exp_num,
       d.fx_owner_key1,
       d.fx_owner_key2,
       d.fx_owner_key3,
       d.fx_owner_key4,
       d.fx_owner_key5,
       d.fx_owner_key6,
       d.trade_num,
       d.order_num,
       d.item_num,
       d.fx_qty,
       d.fx_price,
       d.fx_amt,
       d.fx_qty_uom_code,
       d.fx_price_curr_code,
       d.fx_price_uom_code,
       d.fx_drop_date,
       d.fx_priced_amt,
       d.fx_real_port_num,
       d.fx_custom_column1,
       d.fx_custom_column2,
       d.fx_custom_column3,
       d.fx_custom_column4,
       d.trans_id,
       i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'FxExposureDist'

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
             convert(varchar(40), i.oid),
             null,
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
      if @the_tran_type <> 'E'
         insert dbo.transaction_touch
         select 'UPDATE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40), i.oid),
                null,
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
             convert(varchar(40), i.oid),
             null,
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
             convert(varchar(40), i.oid),
             null,
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
ALTER TABLE [dbo].[fx_exposure_dist] ADD CONSTRAINT [fx_exposure_dist_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fx_exposure_dist] ADD CONSTRAINT [fx_exposure_dist_fk2] FOREIGN KEY ([fx_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[fx_exposure_dist] ADD CONSTRAINT [fx_exposure_dist_fk3] FOREIGN KEY ([fx_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[fx_exposure_dist] ADD CONSTRAINT [fx_exposure_dist_fk4] FOREIGN KEY ([fx_price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[fx_exposure_dist] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fx_exposure_dist] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fx_exposure_dist] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fx_exposure_dist] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'fx_exposure_dist', NULL, NULL
GO
