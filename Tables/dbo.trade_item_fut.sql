CREATE TABLE [dbo].[trade_item_fut]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[settlement_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fut_price] [float] NULL,
[fut_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_fill_qty] [float] NULL,
[fill_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_fill_price] [float] NULL,
[clr_brkr_num] [int] NULL,
[clr_brkr_cont_num] [int] NULL,
[clr_brkr_comm_amt] [float] NULL,
[clr_brkr_comm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_brkr_comm_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_brkr_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exercise_num] [smallint] NULL,
[trans_id] [int] NOT NULL,
[use_in_fifo_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[exec_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[efp_trigger_num] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_fut_deltrg]
on [dbo].[trade_item_fut]
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
   select @errmsg = '(trade_item_fut) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_item_fut
   (trade_num,
    order_num,
    item_num,
    settlement_type,
    fut_price,
    fut_price_curr_code,
    total_fill_qty,
    fill_qty_uom_code,
    avg_fill_price,
    clr_brkr_num,
    clr_brkr_cont_num,
    clr_brkr_comm_amt,
    clr_brkr_comm_curr_code,
    clr_brkr_comm_uom_code,
    clr_brkr_ref_num,
    exercise_num,
    use_in_fifo_ind,
    exec_type_code,
    price_source_code,
    efp_trigger_num,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.settlement_type,
   d.fut_price,
   d.fut_price_curr_code,
   d.total_fill_qty,
   d.fill_qty_uom_code,
   d.avg_fill_price,
   d.clr_brkr_num,
   d.clr_brkr_cont_num,
   d.clr_brkr_comm_amt,
   d.clr_brkr_comm_curr_code,
   d.clr_brkr_comm_uom_code,
   d.clr_brkr_ref_num,
   d.exercise_num,
   d.use_in_fifo_ind,
   d.exec_type_code,
   d.price_source_code,
   d.efp_trigger_num,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemFut'

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
             convert(varchar(40), d.trade_num),
             convert(varchar(40), d.order_num),
             convert(varchar(40), d.item_num),
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

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'DELETE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40), d.trade_num),
                convert(varchar(40), d.order_num),
                convert(varchar(40), d.item_num),
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
             convert(varchar(40), d.trade_num),
             convert(varchar(40), d.order_num),
             convert(varchar(40), d.item_num),
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
             convert(varchar(40), d.trade_num),
             convert(varchar(40), d.order_num),
             convert(varchar(40), d.item_num),
             null,
             null,
             null,
             null,
             null,
             @atrans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
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

create trigger [dbo].[trade_item_fut_instrg]
on [dbo].[trade_item_fut]
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

   select @the_entity_name = 'TradeItemFut'

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
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
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

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'INSERT',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),trade_num),
                convert(varchar(40),order_num),
                convert(varchar(40),item_num),
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
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
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
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_fut_updtrg]
on [dbo].[trade_item_fut]
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
   raiserror ('(trade_item_fut) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(trade_item_fut) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.trade_num = d.trade_num and 
                 i.order_num = d.order_num and 
                 i.item_num = d.item_num )
begin
   raiserror ('(trade_item_fut) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(trade_num) or 
   update(order_num) or  
   update(item_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.trade_num = d.trade_num and 
                                   i.order_num = d.order_num and 
                                   i.item_num = d.item_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(trade_item_fut) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_item_fut
      (trade_num,
       order_num,
       item_num,
       settlement_type,
       fut_price,
       fut_price_curr_code,
       total_fill_qty,
       fill_qty_uom_code,
       avg_fill_price,
       clr_brkr_num,
       clr_brkr_cont_num,
       clr_brkr_comm_amt,
       clr_brkr_comm_curr_code,
       clr_brkr_comm_uom_code,
       clr_brkr_ref_num,
       exercise_num,
       use_in_fifo_ind,
       exec_type_code,
       price_source_code,
       efp_trigger_num,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.item_num,
      d.settlement_type,
      d.fut_price,
      d.fut_price_curr_code,
      d.total_fill_qty,
      d.fill_qty_uom_code,
      d.avg_fill_price,
      d.clr_brkr_num,
      d.clr_brkr_cont_num,
      d.clr_brkr_comm_amt,
      d.clr_brkr_comm_curr_code,
      d.clr_brkr_comm_uom_code,
      d.clr_brkr_ref_num,
      d.exercise_num,
      d.use_in_fifo_ind,
      d.exec_type_code,
      d.price_source_code,
      d.efp_trigger_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and
         d.item_num = i.item_num 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemFut'

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
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
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

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             'TradeItem',
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
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
            a.entity_name = 'TradeItem'

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'UPDATE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),trade_num),
                convert(varchar(40),order_num),
                convert(varchar(40),item_num),
                null,
                null,
                null,
                null,
                null,
                i.trans_id,
                @the_sequence
         from inserted i

         insert dbo.transaction_touch
         select 'UPDATE',
                'TradeItem',
                'INDIRECT',
                convert(varchar(40),trade_num),
                convert(varchar(40),order_num),
                convert(varchar(40),item_num),
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
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
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

      insert into dbo.als_run_touch 
         (als_module_group_id, operation, entity_name,key1,key2,
          key3,key4,key5,key6,key7,key8,trans_id,sequence)
      select a.als_module_group_id,
             'U',
             'TradeItem',
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
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
            a.entity_name = 'TradeItem' AND
            i.trans_id = it.trans_id

      /* END_ALS_RUN_TOUCH */

      /* BEGIN_TRANSACTION_TOUCH */

      insert dbo.transaction_touch
      select 'UPDATE',
             @the_entity_name,
             'DIRECT',
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'

      insert dbo.transaction_touch
      select 'UPDATE',
             'TradeItem',
             'INDIRECT',
             convert(varchar(40),trade_num),
             convert(varchar(40),order_num),
             convert(varchar(40),item_num),
             null,
             null,
             null,
             null,
             null,
             i.trans_id,
             it.sequence
      from dbo.icts_transaction it WITH (NOLOCK),
           inserted i
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_fut_TS_idx90] ON [dbo].[trade_item_fut] ([clr_brkr_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk1] FOREIGN KEY ([clr_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk10] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk2] FOREIGN KEY ([clr_brkr_num], [clr_brkr_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk3] FOREIGN KEY ([fut_price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk4] FOREIGN KEY ([clr_brkr_comm_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk6] FOREIGN KEY ([fill_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk7] FOREIGN KEY ([clr_brkr_comm_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_fut] ADD CONSTRAINT [trade_item_fut_fk9] FOREIGN KEY ([exec_type_code]) REFERENCES [dbo].[execution_type] ([exec_type_code])
GO
GRANT DELETE ON  [dbo].[trade_item_fut] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_fut] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_fut] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_fut] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_item_fut', NULL, NULL
GO
