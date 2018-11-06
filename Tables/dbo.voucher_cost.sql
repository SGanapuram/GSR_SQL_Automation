CREATE TABLE [dbo].[voucher_cost]
(
[voucher_num] [int] NOT NULL,
[cost_num] [int] NOT NULL,
[prov_price] [float] NULL,
[prov_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prov_qty] [float] NULL,
[prov_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prov_amt] [float] NULL,
[trans_id] [int] NOT NULL,
[line_num] [int] NOT NULL,
[voucher_cost_status] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
create trigger [dbo].[voucher_cost_deltrg]  
on [dbo].[voucher_cost]  
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
   select @errmsg = '(voucher_cost) Failed to obtain a valid responsible trans_id.'  
   if exists (select 1  
              from master.dbo.sysprocesses (nolock)  
              where spid = @@spid and  
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR  
                     program_name like 'Microsoft SQL Server Management Studio%') )  
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'  
   raiserror (@errmsg  ,10,1)
   if @@trancount > 0 rollback tran  

   return  
end  
  
  
insert dbo.aud_voucher_cost  
   (voucher_num,  
    cost_num,  
    prov_price,  
    prov_price_curr_code,  
    prov_qty,  
    prov_qty_uom_code,  
    prov_amt,  
    line_num,  
    trans_id,  
    resp_trans_id,
    voucher_cost_status)  
select  
   d.voucher_num,  
   d.cost_num,  
   d.prov_price,  
   d.prov_price_curr_code,  
   d.prov_qty,  
   d.prov_qty_uom_code,  
   d.prov_amt,  
   d.line_num,  
   d.trans_id,  
   @atrans_id,
   d.voucher_cost_status
from deleted d  
  
/* AUDIT_CODE_END */  
  
declare @the_sequence       numeric(32, 0),  
        @the_tran_type      char(1),  
        @the_entity_name    varchar(30)  
  
   select @the_entity_name = 'VoucherCost'  
  
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
              convert(varchar(40), d.voucher_num),  
              convert(varchar(40), d.cost_num),  
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
       begin  
          insert dbo.transaction_touch  
          select 'DELETE',  
                 @the_entity_name,  
                 'DIRECT',  
                 convert(varchar(40), d.voucher_num),  
                 convert(varchar(40), d.cost_num),  
                 null,  
                 null,  
                 null,  
                 null,  
                 null,  
                 null,  
                 @atrans_id,  
                 @the_sequence  
          from deleted d  
       end  
  
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
             convert(varchar(40), d.voucher_num),  
             convert(varchar(40), d.cost_num),  
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
             convert(varchar(40), d.voucher_num),  
             convert(varchar(40), d.cost_num),  
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

create trigger [dbo].[voucher_cost_instrg]
on [dbo].[voucher_cost]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return

   declare @the_sequence       numeric(32,0),
           @the_tran_type      char(1),
           @the_entity_name    varchar(30),
           @errmsg             varchar(255)


   if exists (select * 
              from dbo.voucher_cost, inserted
              where voucher_cost.cost_num = inserted.cost_num and
                    voucher_cost.trans_id <> inserted.trans_id)
   begin
      select @errmsg = 'The cost_num #' + ltrim(str(cost_num)) + ' has already existed in the voucher_cost table. Duplicated cost_num is not allowed!'
      from inserted
      raiserror (@errmsg ,10,1)
      if @@trancount > 0 rollback tran

      return
   end

   select @the_entity_name = 'VoucherCost'

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
              convert(varchar(40), i.voucher_num),
              convert(varchar(40), i.cost_num),
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

       if @the_tran_type <> 'E'
       begin
          insert dbo.transaction_touch
          select 'INSERT',
                 @the_entity_name,
                 'DIRECT',
                 convert(varchar(40), i.voucher_num),
                 convert(varchar(40), i.cost_num),
                 null,
                 null,
                 null,
                 null,
                 null,
                 null,
                 i.trans_id,
                 @the_sequence
          from inserted i
       end

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
             convert(varchar(40), i.voucher_num),
             convert(varchar(40), i.cost_num),
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
          'VoucherCost',
          'DIRECT',
          convert(varchar(40), i.voucher_num),
          convert(varchar(40), i.cost_num),
          null,
          null,
          null,
          null,
          null,
          null,
          i.trans_id,
          it.sequence
   from inserted i, dbo.icts_transaction it
   where i.trans_id = it.trans_id

   /* END_TRANSACTION_TOUCH */
end
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[voucher_cost_updtrg]
on [dbo].[voucher_cost]
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
if update(cost_num)
begin
   if exists (select * from voucher_cost, inserted
              where voucher_cost.cost_num = inserted.cost_num and
                    voucher_cost.trans_id <> inserted.trans_id)
   begin
      select @errmsg = 'The cost_num #' + ltrim(str(cost_num)) + ' has already existed in the voucher_cost table. Duplicated cost_num is not allowed!'
      from inserted
      raiserror (@errmsg ,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(voucher_cost) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(voucher_cost) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.voucher_num = d.voucher_num and 
                 i.cost_num = d.cost_num )
begin
   raiserror ('(voucher_cost) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(voucher_num) or  
   update(cost_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.voucher_num = d.voucher_num and 
                                   i.cost_num = d.cost_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(voucher_cost) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_voucher_cost
      (voucher_num,
       cost_num,
       prov_price,
       prov_price_curr_code,
       prov_qty,
       prov_qty_uom_code,
       prov_amt,
       line_num,
       trans_id,
       resp_trans_id,
       voucher_cost_status)
   select
      d.voucher_num,
      d.cost_num,
      d.prov_price,
      d.prov_price_curr_code,
      d.prov_qty,
      d.prov_qty_uom_code,
      d.prov_amt,
      d.line_num,
      d.trans_id,
      i.trans_id,
      d.voucher_cost_status
   from deleted d, inserted i
   where d.voucher_num = i.voucher_num and
         d.cost_num = i.cost_num 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'VoucherCost'

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
              convert(varchar(40), i.voucher_num),
              convert(varchar(40), i.cost_num),
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
       begin
          insert dbo.transaction_touch
          select 'UPDATE',
                 @the_entity_name,
                 'DIRECT',
                 convert(varchar(40), i.voucher_num),
                 convert(varchar(40), i.cost_num),
                 null,
                 null,
                 null,
                 null,
                 null,
                 null,
                 i.trans_id,
                 @the_sequence
          from inserted i
       end

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
             convert(varchar(40), i.voucher_num),
             convert(varchar(40), i.cost_num),
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
             convert(varchar(40), i.voucher_num),
             convert(varchar(40), i.cost_num),
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
ALTER TABLE [dbo].[voucher_cost] ADD CONSTRAINT [voucher_cost_pk] PRIMARY KEY CLUSTERED  ([voucher_num], [cost_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [voucher_cost_idx1] ON [dbo].[voucher_cost] ([cost_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[voucher_cost] ADD CONSTRAINT [voucher_cost_fk1] FOREIGN KEY ([prov_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[voucher_cost] ADD CONSTRAINT [voucher_cost_fk3] FOREIGN KEY ([prov_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[voucher_cost] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[voucher_cost] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[voucher_cost] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[voucher_cost] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'voucher_cost', NULL, NULL
GO
