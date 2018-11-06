CREATE TABLE [dbo].[inventory]
(
[inv_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[sale_item_num] [smallint] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[pos_num] [int] NOT NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[storage_subloc_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[port_num] [int] NULL,
[inv_bal_from_date] [datetime] NOT NULL,
[inv_bal_to_date] [datetime] NOT NULL,
[inv_open_prd_proj_qty] [float] NULL,
[inv_open_prd_actual_qty] [float] NULL,
[inv_adj_qty] [float] NULL,
[inv_curr_proj_qty] [float] NULL,
[inv_curr_actual_qty] [float] NULL,
[inv_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[inv_avg_cost] [float] NULL,
[inv_cost_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_cost_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[inv_rcpt_proj_qty] [float] NULL,
[inv_rcpt_actual_qty] [float] NULL,
[inv_dlvry_proj_qty] [float] NULL,
[inv_dlvry_actual_qty] [float] NULL,
[open_close_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[long_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[long_risk_mkt] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_risk_mkt] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[balance_period] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[line_fill_qty] [float] NULL,
[needs_repricing] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_loop_num] [int] NULL,
[inv_cnfrmd_qty] [float] NOT NULL,
[prev_inv_num] [int] NULL,
[next_inv_num] [int] NULL,
[inv_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[r_inv_avg_cost_amt] [float] NULL,
[unr_inv_avg_cost_amt] [float] NULL,
[trans_id] [int] NOT NULL,
[inv_open_prd_proj_sec_qty] [float] NULL,
[inv_open_prd_actual_sec_qty] [float] NULL,
[inv_cnfrmd_sec_qty] [float] NULL,
[inv_adj_sec_qty] [float] NULL,
[inv_sec_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_curr_proj_sec_qty] [float] NULL,
[inv_curr_actual_sec_qty] [float] NULL,
[inv_rcpt_proj_sec_qty] [float] NULL,
[inv_rcpt_actual_sec_qty] [float] NULL,
[inv_dlvry_proj_sec_qty] [float] NULL,
[inv_dlvry_actual_sec_qty] [float] NULL,
[inv_credit_exposure_oid] [int] NULL,
[inv_wacog_cost] [float] NULL,
[inv_bal_qty] [numeric] (20, 8) NULL,
[inv_bal_sec_qty] [numeric] (20, 8) NULL,
[inv_mac_cost] [numeric] (20, 8) NULL,
[mac_inv_amt] [numeric] (20, 8) NULL,
[inv_mac_insert_cost] [numeric] (20, 8) NULL,
[inv_fifo_cost] [numeric] (20, 8) NULL,
[roll_at_mkt_price_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inv_target_min_qty] [decimal] (20, 8) NULL,
[inv_target_max_qty] [decimal] (20, 8) NULL,
[inv_capacity] [decimal] (20, 8) NULL,
[inv_min_op_req_qty] [decimal] (20, 8) NULL,
[inv_safe_fill] [decimal] (20, 8) NULL,
[inv_heel] [decimal] (20, 8) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[inventory_deltrg]
on [dbo].[inventory]
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
   select @errmsg = '(inventory) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_inventory
   (inv_num,
    trade_num,
    order_num,
    sale_item_num,
    cmdty_code,
    pos_num,
    del_loc_code,
    storage_subloc_name,
    port_num,
    inv_bal_from_date,
    inv_bal_to_date,
    inv_open_prd_proj_qty,
    inv_open_prd_actual_qty,
    inv_adj_qty,
    inv_curr_proj_qty,
    inv_curr_actual_qty,
    inv_qty_uom_code,
    inv_avg_cost,
    inv_cost_curr_code,
    inv_cost_uom_code,
    cmnt_num,
    inv_rcpt_proj_qty,
    inv_rcpt_actual_qty,
    inv_dlvry_proj_qty,
    inv_dlvry_actual_qty,
    open_close_ind,
    long_cmdty_code,
    short_cmdty_code,
    long_risk_mkt,
    short_risk_mkt,
    balance_period,
    line_fill_qty,
    needs_repricing,
    inv_loop_num,
    inv_cnfrmd_qty,
    prev_inv_num,
    next_inv_num,
    inv_type,
    r_inv_avg_cost_amt,
    unr_inv_avg_cost_amt,
    inv_open_prd_proj_sec_qty,
    inv_open_prd_actual_sec_qty,
    inv_cnfrmd_sec_qty,
    inv_adj_sec_qty,
    inv_sec_qty_uom_code,
    inv_curr_actual_sec_qty,
    inv_curr_proj_sec_qty,
    inv_dlvry_actual_sec_qty,
    inv_dlvry_proj_sec_qty,
    inv_rcpt_actual_sec_qty,
    inv_rcpt_proj_sec_qty,
    inv_wacog_cost,
    inv_bal_qty,
    inv_bal_sec_qty,
    inv_mac_cost,
    mac_inv_amt,
    inv_mac_insert_cost,
    inv_fifo_cost,
    roll_at_mkt_price_ind,
	  inv_target_min_qty,	
    inv_target_max_qty,
    inv_capacity,
    inv_min_op_req_qty,
    inv_safe_fill,
    inv_heel,
    trans_id,
    resp_trans_id)
select
   d.inv_num,
   d.trade_num,
   d.order_num,
   d.sale_item_num,
   d.cmdty_code,
   d.pos_num,
   d.del_loc_code,
   d.storage_subloc_name,
   d.port_num,
   d.inv_bal_from_date,
   d.inv_bal_to_date,
   d.inv_open_prd_proj_qty,
   d.inv_open_prd_actual_qty,
   d.inv_adj_qty,
   d.inv_curr_proj_qty,
   d.inv_curr_actual_qty,
   d.inv_qty_uom_code,
   d.inv_avg_cost,
   d.inv_cost_curr_code,
   d.inv_cost_uom_code,
   d.cmnt_num,
   d.inv_rcpt_proj_qty,
   d.inv_rcpt_actual_qty,
   d.inv_dlvry_proj_qty,
   d.inv_dlvry_actual_qty,
   d.open_close_ind,
   d.long_cmdty_code,
   d.short_cmdty_code,
   d.long_risk_mkt,
   d.short_risk_mkt,
   d.balance_period,
   d.line_fill_qty,
   d.needs_repricing,
   d.inv_loop_num,
   d.inv_cnfrmd_qty,
   d.prev_inv_num,
   d.next_inv_num,
   d.inv_type,
   d.r_inv_avg_cost_amt,
   d.unr_inv_avg_cost_amt,
   d.inv_open_prd_proj_sec_qty,
   d.inv_open_prd_actual_sec_qty,
   d.inv_cnfrmd_sec_qty,
   d.inv_adj_sec_qty,
   d.inv_sec_qty_uom_code,
   d.inv_curr_actual_sec_qty,
   d.inv_curr_proj_sec_qty,
   d.inv_dlvry_actual_sec_qty,
   d.inv_dlvry_proj_sec_qty,
   d.inv_rcpt_actual_sec_qty,
   d.inv_rcpt_proj_sec_qty,
   d.inv_wacog_cost,
   d.inv_bal_qty,
   d.inv_bal_sec_qty,
   d.inv_mac_cost,
   d.mac_inv_amt,
   d.inv_mac_insert_cost,
   d.inv_fifo_cost,
   d.roll_at_mkt_price_ind,
   d.inv_target_min_qty,	
   d.inv_target_max_qty,
   d.inv_capacity,
   d.inv_min_op_req_qty,
   d.inv_safe_fill,
   d.inv_heel,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Inventory'

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
             convert(varchar(40),d.inv_num),
             null,
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
             convert(varchar(40),d.inv_num),
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
             convert(varchar(40),d.inv_num),
             null,
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
             convert(varchar(40),d.inv_num),
             null,
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

create trigger [dbo].[inventory_instrg]
on [dbo].[inventory]
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

   select @the_entity_name = 'Inventory'

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
             convert(varchar(40),inv_num),
             null,
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
             convert(varchar(40),inv_num),
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
             convert(varchar(40),inv_num),
             null,
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
             convert(varchar(40),inv_num),
             null,
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

create trigger [dbo].[inventory_updtrg]
on [dbo].[inventory]
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
   raiserror ('(inventory) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(inventory) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.inv_num = d.inv_num )
begin
   raiserror ('(inventory) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(inv_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.inv_num = d.inv_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(inventory) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_inventory
      (inv_num,
       trade_num,
       order_num,
       sale_item_num,
       cmdty_code,
       pos_num,
       del_loc_code,
       storage_subloc_name,
       port_num,
       inv_bal_from_date,
       inv_bal_to_date,
       inv_open_prd_proj_qty,
       inv_open_prd_actual_qty,
       inv_adj_qty,
       inv_curr_proj_qty,
       inv_curr_actual_qty,
       inv_qty_uom_code,
       inv_avg_cost,
       inv_cost_curr_code,
       inv_cost_uom_code,
       cmnt_num,
       inv_rcpt_proj_qty,
       inv_rcpt_actual_qty,
       inv_dlvry_proj_qty,
       inv_dlvry_actual_qty,
       open_close_ind,
       long_cmdty_code,
       short_cmdty_code,
       long_risk_mkt,
       short_risk_mkt,
       balance_period,
       line_fill_qty,
       needs_repricing,
       inv_loop_num,
       inv_cnfrmd_qty,
       prev_inv_num,
       next_inv_num,
       inv_type,
       r_inv_avg_cost_amt,
       unr_inv_avg_cost_amt,
       inv_open_prd_proj_sec_qty,
       inv_open_prd_actual_sec_qty,
       inv_cnfrmd_sec_qty,
       inv_adj_sec_qty,
       inv_sec_qty_uom_code,
       inv_curr_actual_sec_qty,
       inv_curr_proj_sec_qty,
       inv_dlvry_actual_sec_qty,
       inv_dlvry_proj_sec_qty,
       inv_rcpt_actual_sec_qty,
       inv_rcpt_proj_sec_qty,
       inv_wacog_cost,
       inv_bal_qty,
       inv_bal_sec_qty,
       inv_mac_cost,
       mac_inv_amt,
       inv_mac_insert_cost,
       inv_fifo_cost,
       roll_at_mkt_price_ind,
			 inv_target_min_qty,	
       inv_target_max_qty,
       inv_capacity,
       inv_min_op_req_qty,
       inv_safe_fill,
       inv_heel,
       trans_id,
       resp_trans_id)
    select
       d.inv_num,
       d.trade_num,
       d.order_num,
       d.sale_item_num,
       d.cmdty_code,
       d.pos_num,
       d.del_loc_code,
       d.storage_subloc_name,
       d.port_num,
       d.inv_bal_from_date,
       d.inv_bal_to_date,
       d.inv_open_prd_proj_qty,
       d.inv_open_prd_actual_qty,
       d.inv_adj_qty,
       d.inv_curr_proj_qty,
       d.inv_curr_actual_qty,
       d.inv_qty_uom_code,
       d.inv_avg_cost,
       d.inv_cost_curr_code,
       d.inv_cost_uom_code,
       d.cmnt_num,
       d.inv_rcpt_proj_qty,
       d.inv_rcpt_actual_qty,
       d.inv_dlvry_proj_qty,
       d.inv_dlvry_actual_qty,
       d.open_close_ind,
       d.long_cmdty_code,
       d.short_cmdty_code,
       d.long_risk_mkt,
       d.short_risk_mkt,
       d.balance_period,
       d.line_fill_qty,
       d.needs_repricing,
       d.inv_loop_num,
       d.inv_cnfrmd_qty,
       d.prev_inv_num,
       d.next_inv_num,
       d.inv_type,
       d.r_inv_avg_cost_amt,
       d.unr_inv_avg_cost_amt,
       d.inv_open_prd_proj_sec_qty,
       d.inv_open_prd_actual_sec_qty,
       d.inv_cnfrmd_sec_qty,
       d.inv_adj_sec_qty,
       d.inv_sec_qty_uom_code,
       d.inv_curr_actual_sec_qty,
       d.inv_curr_proj_sec_qty,
       d.inv_dlvry_actual_sec_qty,
       d.inv_dlvry_proj_sec_qty,
       d.inv_rcpt_actual_sec_qty,
       d.inv_rcpt_proj_sec_qty,
       d.inv_wacog_cost,
       d.inv_bal_qty,
       d.inv_bal_sec_qty,
       d.inv_mac_cost,
       d.mac_inv_amt,
       d.inv_mac_insert_cost,
       d.inv_fifo_cost,
       d.roll_at_mkt_price_ind,
			 d.inv_target_min_qty,	
       d.inv_target_max_qty,
       d.inv_capacity,
       d.inv_min_op_req_qty,
       d.inv_safe_fill,
       d.inv_heel,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.inv_num = i.inv_num

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'Inventory'

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
             convert(varchar(40),inv_num),
             null,
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
             convert(varchar(40),inv_num),
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
             convert(varchar(40),inv_num),
             null,
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
             convert(varchar(40),inv_num),
             null,
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
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_pk] PRIMARY KEY CLUSTERED  ([inv_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_idx1] ON [dbo].[inventory] ([port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [inventory_idx] ON [dbo].[inventory] ([trade_num], [order_num], [sale_item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_fk12] FOREIGN KEY ([inv_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_fk13] FOREIGN KEY ([inv_cost_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_fk14] FOREIGN KEY ([inv_sec_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_fk3] FOREIGN KEY ([inv_cost_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_fk4] FOREIGN KEY ([long_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_fk5] FOREIGN KEY ([short_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_fk6] FOREIGN KEY ([del_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_fk7] FOREIGN KEY ([long_risk_mkt]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[inventory] ADD CONSTRAINT [inventory_fk8] FOREIGN KEY ([short_risk_mkt]) REFERENCES [dbo].[market] ([mkt_code])
GO
GRANT DELETE ON  [dbo].[inventory] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[inventory] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[inventory] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[inventory] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'inventory', NULL, NULL
GO
