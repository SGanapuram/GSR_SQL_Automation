CREATE TABLE [dbo].[trade_item_dry_phy]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[min_qty] [float] NULL,
[min_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[max_qty] [float] NULL,
[max_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_date_from] [datetime] NULL,
[del_date_to] [datetime] NULL,
[del_date_est_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_date_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pay_days] [int] NULL,
[pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_imp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trade_exp_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[transportation] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_qty] [float] NULL,
[tol_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_sign] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tol_opt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[min_ship_qty] [float] NULL,
[min_ship_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[partial_deadline_date] [datetime] NULL,
[partial_res_inc_amt] [float] NULL,
[sch_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_ship_num] [smallint] NULL,
[parcel_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[taken_to_sch_pos_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[proc_deal_lifting_days] [smallint] NULL,
[proc_deal_delivery_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[proc_deal_event_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[proc_deal_event_spec] [smallint] NULL,
[item_petroex_num] [char] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_transfer_doc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lease_num] [int] NULL,
[lease_ver_num] [int] NULL,
[dest_trade_num] [int] NULL,
[dest_order_num] [smallint] NULL,
[dest_item_num] [smallint] NULL,
[density_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[imp_rec_reason_oid] [int] NULL,
[prelim_price_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prelim_price] [numeric] (20, 8) NULL,
[prelim_qty_base] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prelim_percentage] [numeric] (20, 8) NULL,
[prelim_pay_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[prelim_due_date] [datetime] NULL,
[declar_date_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[declar_rel_days] [smallint] NULL,
[tax_qualification_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[tank_num] [int] NULL,
[estimate_qty] [numeric] (20, 8) NULL,
[b2b_sale_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[facility_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_approver_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[credit_approval_date] [datetime] NULL,
[wet_qty] [numeric] (20, 8) NULL,
[dry_qty] [numeric] (20, 8) NULL,
[franchise_charge] [numeric] (20, 8) NULL,
[heat_adj_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sublots_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[umpire_rule_num] [int] NULL,
[trans_id] [int] NOT NULL,
[int_val] [int] NULL,
[float_val] [float] NULL,
[str_val] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_dry_phy_deltrg]
on [dbo].[trade_item_dry_phy]
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
   select @errmsg = '(trade_item_dry_phy) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_trade_item_dry_phy
   (trade_num,
    order_num,
    item_num,
    min_qty,
    min_qty_uom_code,
    max_qty,
    max_qty_uom_code,
    del_date_from,
    del_date_to,
    del_date_est_ind,
    del_date_basis,
    credit_term_code,
    pay_days,
    pay_term_code,
    trade_imp_rec_ind,
    trade_exp_rec_ind,
    del_term_code,
    mot_code,
    del_loc_type,
    del_loc_code,
    transportation,
    tol_qty,
    tol_qty_uom_code,
    tol_sign,
    tol_opt,
    min_ship_qty,
    min_ship_qty_uom_code,
    partial_deadline_date,
    partial_res_inc_amt,
    sch_init,
    total_ship_num,
    parcel_num,
    taken_to_sch_pos_ind,
    proc_deal_lifting_days,
    proc_deal_delivery_type,
    proc_deal_event_name,
    proc_deal_event_spec,
    item_petroex_num,
    title_transfer_doc,
    lease_num,
    lease_ver_num,
    dest_trade_num,
    dest_order_num,
    dest_item_num,
    density_ind,
    imp_rec_reason_oid,
    prelim_price_type,
    prelim_price,
    prelim_qty_base,
    prelim_percentage,
    prelim_pay_term_code,
    prelim_due_date,
    declar_date_type,
    declar_rel_days,
    tax_qualification_code,
    tank_num,
    estimate_qty,
    b2b_sale_ind,
    facility_code,
    credit_approver_init,
    credit_approval_date,
    wet_qty,
    dry_qty,
    franchise_charge,
    heat_adj_ind,
    sublots_ind,
    umpire_rule_num,
    trans_id,
    resp_trans_id,
    int_val,
    float_val, 
    str_val)
select
trade_num,
    d.order_num,
    d.item_num,
    d.min_qty,
    d.min_qty_uom_code,
    d.max_qty,
    d.max_qty_uom_code,
    d.del_date_from,
    d.del_date_to,
    d.del_date_est_ind,
    d.del_date_basis,
    d.credit_term_code,
    d.pay_days,
    d.pay_term_code,
    d.trade_imp_rec_ind,
    d.trade_exp_rec_ind,
    d.del_term_code,
    d.mot_code,
    d.del_loc_type,
    d.del_loc_code,
    d.transportation,
    d.tol_qty,
    d.tol_qty_uom_code,
    d.tol_sign,
    d.tol_opt,
    d.min_ship_qty,
    d.min_ship_qty_uom_code,
    d.partial_deadline_date,
    d.partial_res_inc_amt,
    d.sch_init,
    d.total_ship_num,
    d.parcel_num,
    d.taken_to_sch_pos_ind,
    d.proc_deal_lifting_days,
    d.proc_deal_delivery_type,
    d.proc_deal_event_name,
    d.proc_deal_event_spec,
    d.item_petroex_num,
    d.title_transfer_doc,
    d.lease_num,
    d.lease_ver_num,
    d.dest_trade_num,
    d.dest_order_num,
    d.dest_item_num,
    d.density_ind,
    d.imp_rec_reason_oid,
    d.prelim_price_type,
    d.prelim_price,
    d.prelim_qty_base,
    d.prelim_percentage,
    d.prelim_pay_term_code,
    d.prelim_due_date,
    d.declar_date_type,
    d.declar_rel_days,
    d.tax_qualification_code,
    d.tank_num,
    d.estimate_qty,
    d.b2b_sale_ind,
    d.facility_code,
    d.credit_approver_init,
    d.credit_approval_date,
    d.wet_qty,
    d.dry_qty,
    d.franchise_charge,
    d.heat_adj_ind,
    d.sublots_ind,
    d.umpire_rule_num,
    d.trans_id,
    @atrans_id,
    d.int_val,
    d.float_val, 
    d.str_val
from deleted d

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemDryPhy'

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

create trigger [dbo].[trade_item_dry_phy_instrg]
on [dbo].[trade_item_dry_phy]
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

   select @the_entity_name = 'TradeItemDryPhy'

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

create trigger [dbo].[trade_item_dry_phy_updtrg]
on [dbo].[trade_item_dry_phy]
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
   raiserror ('(trade_item_dry_phy) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(trade_item_dry_phy) New trans_id must be larger than original trans_id.'
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
   raiserror ('(trade_item_dry_phy) new trans_id must not be older than current trans_id.',10,1)
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
      raiserror ('(trade_item_dry_phy) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_trade_item_dry_phy
   (trade_num,
    order_num,
    item_num,
    min_qty,
    min_qty_uom_code,
    max_qty,
    max_qty_uom_code,
    del_date_from,
    del_date_to,
    del_date_est_ind,
    del_date_basis,
    credit_term_code,
    pay_days,
    pay_term_code,
    trade_imp_rec_ind,
    trade_exp_rec_ind,
    del_term_code,
    mot_code,
    del_loc_type,
    del_loc_code,
    transportation,
    tol_qty,
    tol_qty_uom_code,
    tol_sign,
    tol_opt,
    min_ship_qty,
    min_ship_qty_uom_code,
    partial_deadline_date,
    partial_res_inc_amt,
    sch_init,
    total_ship_num,
    parcel_num,
    taken_to_sch_pos_ind,
    proc_deal_lifting_days,
    proc_deal_delivery_type,
    proc_deal_event_name,
    proc_deal_event_spec,
    item_petroex_num,
    title_transfer_doc,
    lease_num,
    lease_ver_num,
    dest_trade_num,
    dest_order_num,
    dest_item_num,
    density_ind,
    imp_rec_reason_oid,
    prelim_price_type,
    prelim_price,
    prelim_qty_base,
    prelim_percentage,
    prelim_pay_term_code,
    prelim_due_date,
    declar_date_type,
    declar_rel_days,
    tax_qualification_code,
    tank_num,
    estimate_qty,
    b2b_sale_ind,
    facility_code,
    credit_approver_init,
    credit_approval_date,
    wet_qty,
    dry_qty,
    franchise_charge,
    heat_adj_ind,
    sublots_ind,
    umpire_rule_num,
    trans_id,
    resp_trans_id,
    int_val,
    float_val, 
    str_val)
   select
    d.trade_num,
    d.order_num,
    d.item_num,
    d.min_qty,
    d.min_qty_uom_code,
    d.max_qty,
    d.max_qty_uom_code,
    d.del_date_from,
    d.del_date_to,
    d.del_date_est_ind,
    d.del_date_basis,
    d.credit_term_code,
    d.pay_days,
    d.pay_term_code,
    d.trade_imp_rec_ind,
    d.trade_exp_rec_ind,
    d.del_term_code,
    d.mot_code,
    d.del_loc_type,
    d.del_loc_code,
    d.transportation,
    d.tol_qty,
    d.tol_qty_uom_code,
    d.tol_sign,
    d.tol_opt,
    d.min_ship_qty,
    d.min_ship_qty_uom_code,
    d.partial_deadline_date,
    d.partial_res_inc_amt,
    d.sch_init,
    d.total_ship_num,
    d.parcel_num,
    d.taken_to_sch_pos_ind,
    d.proc_deal_lifting_days,
    d.proc_deal_delivery_type,
    d.proc_deal_event_name,
    d.proc_deal_event_spec,
    d.item_petroex_num,
    d.title_transfer_doc,
    d.lease_num,
    d.lease_ver_num,
    d.dest_trade_num,
    d.dest_order_num,
    d.dest_item_num,
    d.density_ind,
    d.imp_rec_reason_oid,
    d.prelim_price_type,
    d.prelim_price,
    d.prelim_qty_base,
    d.prelim_percentage,
    d.prelim_pay_term_code,
    d.prelim_due_date,
    d.declar_date_type,
    d.declar_rel_days,
    d.tax_qualification_code,
    d.tank_num,
    d.estimate_qty,
    d.b2b_sale_ind,
    d.facility_code,
    d.credit_approver_init,
    d.credit_approval_date,
    d.wet_qty,
    d.dry_qty,
    d.franchise_charge,
    d.heat_adj_ind,
    d.sublots_ind,
    d.umpire_rule_num,
    d.trans_id,
    i.trans_id,
    d.int_val,
    d.float_val, 
    d.str_val
   from deleted d, inserted i
   where d.trade_num = i.trade_num and
         d.order_num = i.order_num and
         d.item_num = i.item_num 

/* AUDIT_CODE_END */

declare @the_sequence       numeric(32, 0),
        @the_tran_type      char(1),
        @the_entity_name    varchar(30)

   select @the_entity_name = 'TradeItemDryPhy'

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
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk1] FOREIGN KEY ([credit_term_code]) REFERENCES [dbo].[credit_term] ([credit_term_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk10] FOREIGN KEY ([max_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk11] FOREIGN KEY ([tol_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk12] FOREIGN KEY ([min_ship_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk15] FOREIGN KEY ([prelim_pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk18] FOREIGN KEY ([tank_num]) REFERENCES [dbo].[location_tank_info] ([tank_num])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk19] FOREIGN KEY ([facility_code]) REFERENCES [dbo].[facility] ([facility_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk2] FOREIGN KEY ([del_term_code]) REFERENCES [dbo].[delivery_term] ([del_term_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk20] FOREIGN KEY ([credit_approver_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk21] FOREIGN KEY ([umpire_rule_num]) REFERENCES [dbo].[umpire_rule] ([rule_num])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk3] FOREIGN KEY ([sch_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk4] FOREIGN KEY ([del_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk5] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk6] FOREIGN KEY ([pay_term_code]) REFERENCES [dbo].[payment_term] ([pay_term_code])
GO
ALTER TABLE [dbo].[trade_item_dry_phy] ADD CONSTRAINT [trade_item_dry_phy_fk9] FOREIGN KEY ([min_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[trade_item_dry_phy] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item_dry_phy] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item_dry_phy] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item_dry_phy] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_item_dry_phy', NULL, NULL
GO
