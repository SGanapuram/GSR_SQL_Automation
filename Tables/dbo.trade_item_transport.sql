CREATE TABLE [dbo].[trade_item_transport]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[transport_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_date_from] [datetime] NULL,
[load_date_to] [datetime] NULL,
[disch_date_from] [datetime] NULL,
[disch_date_to] [datetime] NULL,
[load_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_qty] [float] NULL,
[tol_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_sign] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_ship_qty] [float] NULL,
[min_ship_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[overrun_price] [float] NULL,
[overrun_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[overrun_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[shrinkage_qty] [float] NULL,
[shrinkage_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[loss_allowance_qty] [float] NULL,
[loss_allowance_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[demurrage_price] [float] NULL,
[demurrage_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[demurrage_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dispatch_price] [float] NULL,
[dispatch_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dispatch_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[free_time] [smallint] NULL,
[free_time_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pump_rate_qty] [float] NULL,
[pump_rate_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pump_rate_time_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [int] NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[container_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[number_of_trucks] [int] NULL,
[trans_id] [int] NOT NULL,
[pipeline_cycle_num] [int] NULL,
[timing_cycle_year] [smallint] NULL,
[target_min_qty] [decimal] (20, 8) NULL,
[target_max_qty] [decimal] (20, 8) NULL,
[capacity] [decimal] (20, 8) NULL,
[min_op_req_qty] [decimal] (20, 8) NULL,
[safe_fill] [decimal] (20, 8) NULL,
[heel] [decimal] (20, 8) NULL,
[tank_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_transport_deltrg]
on [dbo].[trade_item_transport]
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
   select @errmsg = '(trade_item_transport) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_trade_item_transport
   (trade_num,
    order_num,
    item_num,
    transport_cmdty_code,
    load_date_from,
    load_date_to,
    disch_date_from,
    disch_date_to,
    load_loc_code,
    del_loc_code,
    mot_code,
    transportation,
    tol_qty,
    tol_qty_uom_code,
    tol_sign,
    min_ship_qty,
    min_ship_qty_uom_code,
    overrun_price,
    overrun_curr_code,
    overrun_uom_code,
    shrinkage_qty,
    shrinkage_uom_code,
    loss_allowance_qty,
    loss_allowance_uom_code,
    demurrage_price,
    demurrage_curr_code,
    demurrage_periodicity,
    dispatch_price,
    dispatch_curr_code,
    dispatch_periodicity,
    free_time,
    free_time_uom_code,
    pump_rate_qty,
    pump_rate_qty_uom_code,
    pump_rate_time_uom_code,
    min_qty,
    min_qty_uom_code,
    max_qty,
    max_qty_uom_code,
    pay_days,
    pay_term_code,
    credit_term_code,
    container_ind,
    number_of_trucks,
    pipeline_cycle_num,
    timing_cycle_year,
    target_min_qty,	
    target_max_qty,
    capacity,
    min_op_req_qty,
    safe_fill,
    heel,
    tank_num,
    trans_id,
    resp_trans_id)
select
   d.trade_num,
   d.order_num,
   d.item_num,
   d.transport_cmdty_code,
   d.load_date_from,
   d.load_date_to,
   d.disch_date_from,
   d.disch_date_to,
   d.load_loc_code,
   d.del_loc_code,
   d.mot_code,
   d.transportation,
   d.tol_qty,
   d.tol_qty_uom_code,
   d.tol_sign,
   d.min_ship_qty,
   d.min_ship_qty_uom_code,
   d.overrun_price,
   d.overrun_curr_code,
   d.overrun_uom_code,
   d.shrinkage_qty,
   d.shrinkage_uom_code,
   d.loss_allowance_qty,
   d.loss_allowance_uom_code,
   d.demurrage_price,
   d.demurrage_curr_code,
   d.demurrage_periodicity,
   d.dispatch_price,
   d.dispatch_curr_code,
   d.dispatch_periodicity,
   d.free_time,
   d.free_time_uom_code,
   d.pump_rate_qty,
   d.pump_rate_qty_uom_code,
   d.pump_rate_time_uom_code,
   d.min_qty,
   d.min_qty_uom_code,
   d.max_qty,
   d.max_qty_uom_code,
   d.pay_days,
   d.pay_term_code,
   d.credit_term_code,
   d.container_ind,
   d.number_of_trucks,
   d.pipeline_cycle_num,
   d.timing_cycle_year,
   d.target_min_qty,	
   d.target_max_qty,
   d.capacity,
   d.min_op_req_qty,
   d.safe_fill,
   d.heel,
   d.tank_num,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemTransport'

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

create trigger [dbo].[trade_item_transport_instrg]
on [dbo].[trade_item_transport]
for insert
as
declare @num_rows        int,
        @count_num_rows  int,
        @errmsg          varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemTransport'

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

create trigger [dbo].[trade_item_transport_updtrg]
on [dbo].[trade_item_transport]
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
   raiserror ('(trade_item_transport) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(trade_item_transport) New trans_id must be larger than original trans_id.'
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
   raiserror ('(trade_item_transport) new trans_id must not be older than current trans_id.',10,1)
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
      raiserror ('(trade_item_transport) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_item_transport
      (trade_num,
       order_num,
       item_num,
       transport_cmdty_code,
       load_date_from,
       load_date_to,
       disch_date_from,
       disch_date_to,
       load_loc_code,
       del_loc_code,
       mot_code,
       transportation,
       tol_qty,
       tol_qty_uom_code,
       tol_sign,
       min_ship_qty,
       min_ship_qty_uom_code,
       overrun_price,
       overrun_curr_code,
       overrun_uom_code,
       shrinkage_qty,
       shrinkage_uom_code,
       loss_allowance_qty,
       loss_allowance_uom_code,
       demurrage_price,
       demurrage_curr_code,
       demurrage_periodicity,
       dispatch_price,
       dispatch_curr_code,
       dispatch_periodicity,
       free_time,
       free_time_uom_code,
       pump_rate_qty,
       pump_rate_qty_uom_code,
       pump_rate_time_uom_code,
       min_qty,
       min_qty_uom_code,
       max_qty,
       max_qty_uom_code,
       pay_days,
       pay_term_code,
       credit_term_code,
       container_ind,
       number_of_trucks,
       pipeline_cycle_num,
       timing_cycle_year,
       target_min_qty,	
       target_max_qty,
       capacity,
       min_op_req_qty,
       safe_fill,
       heel,
       tank_num,
       trans_id,
       resp_trans_id)
   select
      d.trade_num,
      d.order_num,
      d.item_num,
      d.transport_cmdty_code,
      d.load_date_from,
      d.load_date_to,
      d.disch_date_from,
      d.disch_date_to,
      d.load_loc_code,
      d.del_loc_code,
      d.mot_code,
      d.transportation,
      d.tol_qty,
      d.tol_qty_uom_code,
      d.tol_sign,
      d.min_ship_qty,
      d.min_ship_qty_uom_code,
      d.overrun_price,
      d.overrun_curr_code,
      d.overrun_uom_code,
      d.shrinkage_qty,
      d.shrinkage_uom_code,
      d.loss_allowance_qty,
      d.loss_allowance_uom_code,
      d.demurrage_price,
      d.demurrage_curr_code,
      d.demurrage_periodicity,
      d.dispatch_price,
      d.dispatch_curr_code,
      d.dispatch_periodicity,
      d.free_time,
      d.free_time_uom_code,
      d.pump_rate_qty,
      d.pump_rate_qty_uom_code,
      d.pump_rate_time_uom_code,
      d.min_qty,
      d.min_qty_uom_code,
      d.max_qty,
      d.max_qty_uom_code,
      d.pay_days,
      d.pay_term_code,
      d.credit_term_code,
      d.container_ind,
      d.number_of_trucks,
      d.pipeline_cycle_num,
      d.timing_cycle_year,
      d.target_min_qty,	
      d.target_max_qty,
      d.capacity,
      d.min_op_req_qty,
      d.safe_fill,
      d.heel,
      d.tank_num,
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

   select @the_entity_name = 'TradeItemTransport'

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
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk1] FOREIGN KEY ([transport_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk10] FOREIGN KEY ([overrun_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk11] FOREIGN KEY ([shrinkage_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk12] FOREIGN KEY ([loss_allowance_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk13] FOREIGN KEY ([pump_rate_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk14] FOREIGN KEY ([min_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk15] FOREIGN KEY ([max_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk16] FOREIGN KEY ([pipeline_cycle_num]) REFERENCES [dbo].[pipeline_cycle] ([pipeline_cycle_num])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk2] FOREIGN KEY ([overrun_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk3] FOREIGN KEY ([demurrage_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk4] FOREIGN KEY ([dispatch_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk5] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk6] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk8] FOREIGN KEY ([tol_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_transport] ADD CONSTRAINT [trade_item_transport_fk9] FOREIGN KEY ([min_ship_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_transport] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_transport] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_transport] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_transport] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_item_transport', NULL, NULL
GO
