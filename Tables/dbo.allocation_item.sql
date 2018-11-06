CREATE TABLE [dbo].[allocation_item]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[alloc_item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alloc_item_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__allocatio__alloc__25518C17] DEFAULT ('I'),
[sub_alloc_num] [smallint] NULL,
[trade_num] [int] NULL,
[order_num] [smallint] NULL,
[item_num] [smallint] NULL,
[acct_num] [int] NOT NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[sch_qty] [float] NULL,
[sch_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_date_from] [datetime] NOT NULL,
[nomin_date_to] [datetime] NOT NULL,
[nomin_qty_min] [float] NULL,
[nomin_qty_min_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[nomin_qty_max] [float] NULL,
[nomin_qty_max_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_tran_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_tran_date] [datetime] NULL,
[origin_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[dest_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [smallint] NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cr_clear_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cr_anly_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_item_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[alloc_item_confirm] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_item_verify] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sch_qty_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[auto_receipt_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[actual_gross_qty] [float] NULL,
[actual_gross_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fully_actualized] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ar_alloc_num] [int] NULL,
[ar_alloc_item_num] [smallint] NULL,
[inv_num] [int] NULL,
[insp_acct_num] [int] NULL,
[confirmation_date] [datetime] NULL,
[net_nom_num] [smallint] NULL,
[recap_item_num] [int] NULL,
[auto_receipt_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[acct_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[final_dest_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_num] [int] NULL,
[reporting_date] [datetime] NULL,
[max_ai_est_actual_num] [smallint] NULL,
[inspection_date] [datetime] NULL,
[inspector_percent] [smallint] NULL,
[auto_sampling_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[auto_sampling_comp_num] [int] NULL,
[ship_agent_comp_num] [int] NULL,
[ship_broker_comp_num] [int] NULL,
[secondary_actual_qty] [float] NULL,
[load_port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sec_actual_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[purchasing_group] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[vat_ind] [bit] NULL CONSTRAINT [DF__allocatio__vat_i__2645B050] DEFAULT ((0)),
[imp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[imp_rec_reason_oid] [int] NULL,
[estimate_event_date] [datetime] NULL,
[finance_bank_num] [int] NULL,
[sap_delivery_num] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_delivery_line_item_num] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price] [numeric] (20, 8) NULL,
[transfer_price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_curr_code_to] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transfer_price_currency_rate] [float] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_item_deltrg]
on [dbo].[allocation_item]
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
   select @errmsg = '(allocation_item) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror  (@errmsg,10,1)
   if @@trancount > 0 rollback tran
   return
end


   insert dbo.aud_allocation_item
      (alloc_num,
       alloc_item_num,
       alloc_item_type,
       alloc_item_status,
       sub_alloc_num,
       trade_num,
       order_num,
       item_num,
       acct_num,
       cmdty_code,
       sch_qty,
       sch_qty_uom_code,
       nomin_date_from,
       nomin_date_to,
       nomin_qty_min,
       nomin_qty_min_uom_code,
       nomin_qty_max,
       nomin_qty_max_uom_code,
       title_tran_loc_code,
       title_tran_date,
       origin_loc_code,
       dest_loc_code,
       credit_term_code,
       pay_term_code,
       pay_days,
       del_term_code,
       cr_clear_ind,
       cr_anly_init,
       alloc_item_short_cmnt,
       cmnt_num,
       alloc_item_confirm,
       alloc_item_verify,
       sch_qty_periodicity,
       auto_receipt_ind,
       actual_gross_qty,
       actual_gross_uom_code,
       fully_actualized,
       ar_alloc_num,
       ar_alloc_item_num,
       inv_num,
       insp_acct_num,
       confirmation_date,
       net_nom_num,
       recap_item_num,
       auto_receipt_actual_ind,
       acct_ref_num,
       final_dest_loc_code,
       lc_num,
       reporting_date,
       max_ai_est_actual_num,
       inspection_date,
       inspector_percent,
       auto_sampling_ind,
       auto_sampling_comp_num,
       ship_agent_comp_num,
       ship_broker_comp_num,
       secondary_actual_qty,
       load_port_loc_code,
       sec_actual_uom_code,
       purchasing_group,
       vat_ind,
       imp_rec_ind,
       imp_rec_reason_oid,   
       estimate_event_date,  
       finance_bank_num,               
       sap_delivery_num,
       sap_delivery_line_item_num,
       transfer_price,
       transfer_price_uom_code,
       transfer_price_curr_code,
       transfer_price_curr_code_to,
	     transfer_price_currency_rate,
       trans_id,
       resp_trans_id)
   select
      d.alloc_num,
      d.alloc_item_num,
      d.alloc_item_type,
      d.alloc_item_status,
      d.sub_alloc_num,
      d.trade_num,
      d.order_num,
      d.item_num,
      d.acct_num,
      d.cmdty_code,
      d.sch_qty,
      d.sch_qty_uom_code,
      d.nomin_date_from,
      d.nomin_date_to,
      d.nomin_qty_min,
      d.nomin_qty_min_uom_code,
      d.nomin_qty_max,
      d.nomin_qty_max_uom_code,
      d.title_tran_loc_code,
      d.title_tran_date,
      d.origin_loc_code,
      d.dest_loc_code,
      d.credit_term_code,
      d.pay_term_code,
      d.pay_days,
      d.del_term_code,
      d.cr_clear_ind,
      d.cr_anly_init,
      d.alloc_item_short_cmnt,
      d.cmnt_num,
      d.alloc_item_confirm,
      d.alloc_item_verify,
      d.sch_qty_periodicity,
      d.auto_receipt_ind,
      d.actual_gross_qty,
      d.actual_gross_uom_code,
      d.fully_actualized,
      d.ar_alloc_num,
      d.ar_alloc_item_num,
      d.inv_num,
      d.insp_acct_num,
      d.confirmation_date,
      d.net_nom_num,
      d.recap_item_num,
      d.auto_receipt_actual_ind,
      d.acct_ref_num,
      d.final_dest_loc_code,
      d.lc_num,
      d.reporting_date,
      d.max_ai_est_actual_num,
      d.inspection_date,
      d.inspector_percent,
      d.auto_sampling_ind,
      d.auto_sampling_comp_num,
      d.ship_agent_comp_num,
      d.ship_broker_comp_num,
      d.secondary_actual_qty,
      d.load_port_loc_code,
      d.sec_actual_uom_code,
      d.purchasing_group,
      d.vat_ind,
      d.imp_rec_ind,
      d.imp_rec_reason_oid,                    
      d.estimate_event_date,   
      d.finance_bank_num,              
      d.sap_delivery_num,
      d.sap_delivery_line_item_num,
      d.transfer_price,
      d.transfer_price_uom_code,
      d.transfer_price_curr_code,
      d.transfer_price_curr_code_to,
	    d.transfer_price_currency_rate,
      d.trans_id,
      @atrans_id
   from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'AllocationItem'

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
             convert(varchar(40),d.alloc_num),
             convert(varchar(40),d.alloc_item_num),
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

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'DELETE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),d.alloc_num),
                convert(varchar(40),d.alloc_item_num),
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
             convert(varchar(40),d.alloc_num),
             convert(varchar(40),d.alloc_item_num),
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
             convert(varchar(40),d.alloc_num),
             convert(varchar(40),d.alloc_item_num),
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

create trigger [dbo].[allocation_item_instrg]
on [dbo].[allocation_item]
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

   select @the_entity_name = 'AllocationItem'

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
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
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
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
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
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
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
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
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

create trigger [dbo].[allocation_item_updtrg]
on [dbo].[allocation_item]
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
   raiserror  ('(allocation_item) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(allocation_item) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num and 
                 i.alloc_item_num = d.alloc_item_num )
begin
   raiserror ( '(allocation_item) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran
   return
end

/* RECORD_STAMP_END */

if update(alloc_num) or  
   update(alloc_item_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num and 
                                   i.alloc_item_num = d.alloc_item_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror  ('(allocation_item) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran
      return
   end
end


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_allocation_item
      (alloc_num,
       alloc_item_num,
       alloc_item_type,
       alloc_item_status,
       sub_alloc_num,
       trade_num,
       order_num,
       item_num,
       acct_num,
       cmdty_code,
       sch_qty,
       sch_qty_uom_code,
       nomin_date_from,
       nomin_date_to,
       nomin_qty_min,
       nomin_qty_min_uom_code,
       nomin_qty_max,
       nomin_qty_max_uom_code,
       title_tran_loc_code,
       title_tran_date,
       origin_loc_code,
       dest_loc_code,
       credit_term_code,
       pay_term_code,
       pay_days,
       del_term_code,
       cr_clear_ind,
       cr_anly_init,
       alloc_item_short_cmnt,
       cmnt_num,
       alloc_item_confirm,
       alloc_item_verify,
       sch_qty_periodicity,
       auto_receipt_ind,
       actual_gross_qty,
       actual_gross_uom_code,
       fully_actualized,
       ar_alloc_num,
       ar_alloc_item_num,
       inv_num,
       insp_acct_num,
       confirmation_date,
       net_nom_num,
       recap_item_num,
       auto_receipt_actual_ind,
       acct_ref_num,
       final_dest_loc_code,
       lc_num,
       reporting_date,
       max_ai_est_actual_num,
       inspection_date,
       inspector_percent,
       auto_sampling_ind,
       auto_sampling_comp_num,
       ship_agent_comp_num,
       ship_broker_comp_num,
       secondary_actual_qty,
       load_port_loc_code,
       sec_actual_uom_code,
       purchasing_group,
       vat_ind,
       imp_rec_ind,
       imp_rec_reason_oid,                    
       estimate_event_date,  
       finance_bank_num,               
       sap_delivery_num,
       sap_delivery_line_item_num,
       transfer_price,
       transfer_price_uom_code,
       transfer_price_curr_code,
       transfer_price_curr_code_to,
	     transfer_price_currency_rate,
       trans_id,
       resp_trans_id)
    select
       d.alloc_num,
       d.alloc_item_num,
       d.alloc_item_type,
       d.alloc_item_status,
       d.sub_alloc_num,
       d.trade_num,
       d.order_num,
       d.item_num,
       d.acct_num,
       d.cmdty_code,
       d.sch_qty,
       d.sch_qty_uom_code,
       d.nomin_date_from,
       d.nomin_date_to,
       d.nomin_qty_min,
       d.nomin_qty_min_uom_code,
       d.nomin_qty_max,
       d.nomin_qty_max_uom_code,
       d.title_tran_loc_code,
       d.title_tran_date,
       d.origin_loc_code,
       d.dest_loc_code,
       d.credit_term_code,
       d.pay_term_code,
       d.pay_days,
       d.del_term_code,
       d.cr_clear_ind,
       d.cr_anly_init,
       d.alloc_item_short_cmnt,
       d.cmnt_num,
       d.alloc_item_confirm,
       d.alloc_item_verify,
       d.sch_qty_periodicity,
       d.auto_receipt_ind,
       d.actual_gross_qty,
       d.actual_gross_uom_code,
       d.fully_actualized,
       d.ar_alloc_num,
       d.ar_alloc_item_num,
       d.inv_num,
       d.insp_acct_num,
       d.confirmation_date,
       d.net_nom_num,
       d.recap_item_num,
       d.auto_receipt_actual_ind,
       d.acct_ref_num,
       d.final_dest_loc_code,
       d.lc_num,
       d.reporting_date,
       d.max_ai_est_actual_num,
       d.inspection_date,
       d.inspector_percent,
       d.auto_sampling_ind,
       d.auto_sampling_comp_num,
       d.ship_agent_comp_num,
       d.ship_broker_comp_num,
       d.secondary_actual_qty,
       d.load_port_loc_code,
       d.sec_actual_uom_code,
       d.purchasing_group,
       d.vat_ind,
       d.imp_rec_ind,
       d.imp_rec_reason_oid,                    
       d.estimate_event_date,  
       d.finance_bank_num,               
       d.sap_delivery_num,
       d.sap_delivery_line_item_num,
       d.transfer_price,
       d.transfer_price_uom_code,
       d.transfer_price_curr_code,
       d.transfer_price_curr_code_to,
	     d.transfer_price_currency_rate,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.alloc_num = i.alloc_num and
          d.alloc_item_num = i.alloc_item_num 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'AllocationItem'

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
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
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

      if @the_tran_type != 'E'
      begin
         /* BEGIN_TRANSACTION_TOUCH */

         insert dbo.transaction_touch
         select 'UPDATE',
                @the_entity_name,
                'DIRECT',
                convert(varchar(40),alloc_num),
                convert(varchar(40),alloc_item_num),
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
             'U',
             @the_entity_name,
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
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
             convert(varchar(40),alloc_num),
             convert(varchar(40),alloc_item_num),
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
      where i.trans_id = it.trans_id and
            it.type != 'E'

      /* END_TRANSACTION_TOUCH */
   end

return
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [allocation_item_idx2] ON [dbo].[allocation_item] ([alloc_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [allocation_item_idx3] ON [dbo].[allocation_item] ([inv_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [allocation_item_idx1] ON [dbo].[allocation_item] ([trade_num], [order_num], [item_num], [trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk1] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk11] FOREIGN KEY ([dest_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk12] FOREIGN KEY ([final_dest_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk13] FOREIGN KEY ([origin_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk14] FOREIGN KEY ([title_tran_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk15] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk18] FOREIGN KEY ([sch_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk19] FOREIGN KEY ([nomin_qty_min_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk2] FOREIGN KEY ([insp_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk20] FOREIGN KEY ([nomin_qty_max_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk21] FOREIGN KEY ([actual_gross_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk22] FOREIGN KEY ([sec_actual_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk25] FOREIGN KEY ([finance_bank_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk26] FOREIGN KEY ([transfer_price_curr_code_to]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk5] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk6] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk7] FOREIGN KEY ([del_term_code]) REFERENCES [dbo].[delivery_term] ([del_term_code])
GO
ALTER TABLE [dbo].[allocation_item] ADD CONSTRAINT [allocation_item_fk8] FOREIGN KEY ([cr_anly_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[allocation_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'allocation_item', NULL, NULL
GO
