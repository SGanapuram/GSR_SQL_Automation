CREATE TABLE [dbo].[trade_item]
(
[trade_num] [int] NOT NULL,
[order_num] [smallint] NOT NULL,
[item_num] [smallint] NOT NULL,
[item_status_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[p_s_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[booking_comp_num] [int] NULL,
[gtc_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[risk_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[title_mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trading_prd] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_qty] [float] NULL,
[contr_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[contr_qty_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[accum_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[uom_conv_rate] [float] NULL,
[item_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_priced_qty] [float] NULL,
[priced_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[avg_price] [float] NULL,
[price_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[idms_bb_ref_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[idms_contr_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[idms_profit_center] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[idms_acct_alloc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[brkr_num] [int] NULL,
[brkr_cont_num] [int] NULL,
[brkr_comm_amt] [float] NULL,
[brkr_comm_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_comm_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[brkr_ref_num] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fut_trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[parent_item_num] [smallint] NULL,
[real_port_num] [int] NULL,
[amend_num] [smallint] NULL,
[amend_creation_date] [datetime] NULL,
[amend_effect_start_date] [datetime] NULL,
[amend_effect_end_date] [datetime] NULL,
[summary_item_num] [smallint] NULL,
[pooling_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[pooling_port_num] [int] NULL,
[pooling_port_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[total_sch_qty] [float] NULL,
[sch_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[open_qty] [float] NULL,
[open_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mtm_pl] [float] NULL,
[mtm_pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mtm_pl_as_of_date] [datetime] NULL,
[strip_item_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[estimate_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[billing_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sched_status] [smallint] NULL,
[hedge_rate] [float] NULL,
[hedge_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[hedge_multi_div_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[recap_item_num] [int] NULL,
[hedge_pos_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[addl_cost_sum] [float] NULL,
[contr_mtm_pl] [float] NULL,
[max_accum_num] [smallint] NULL,
[formula_declar_date] [datetime] NULL,
[purchasing_group] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[origin_country_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[load_port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[disch_port_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[excp_addns_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[internal_parent_trade_num] [int] NULL,
[internal_parent_order_num] [smallint] NULL,
[internal_parent_item_num] [smallint] NULL,
[trade_modified_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__trade_ite__trade__40CF895A] DEFAULT ('N'),
[item_confirm_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__trade_ite__item___41C3AD93] DEFAULT ('N'),
[finance_bank_num] [int] NULL,
[agreement_num] [int] NULL,
[active_status_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__trade_ite__activ__42B7D1CC] DEFAULT ('Y'),
[market_value] [numeric] (20, 8) NULL,
[includes_excise_tax_ind] [bit] NOT NULL CONSTRAINT [DF__trade_ite__inclu__43ABF605] DEFAULT ((0)),
[includes_fuel_tax_ind] [bit] NOT NULL CONSTRAINT [DF__trade_ite__inclu__44A01A3E] DEFAULT ((0)),
[total_committed_qty] [numeric] (20, 8) NULL,
[committed_qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_cleared_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[clr_service_num] [int] NULL,
[exch_brkr_num] [int] NULL,
[rin_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[is_lc_assigned] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__trade_ite__is_lc__468862B0] DEFAULT ('N'),
[is_rc_assigned] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__trade_ite__is_rc__4870AB22] DEFAULT ('N'),
[b2b_trade_item] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sap_order_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_mkt_formula_for_pl] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__trade_ite__use_m__6E8CFDC0] DEFAULT ('Y')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_deltrg]  
on [dbo].[trade_item]  
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
                    from master.dbo.sysprocesses with (nolock)  
                    where spid = @@spid)  
  
if @atrans_id is null  
begin  
   select @errmsg = '(trade_item) Failed to obtain a valid responsible trans_id.'  
   if exists (select 1  
              from master.dbo.sysprocesses (nolock)  
              where spid = @@spid and  
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )  
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'  
   raiserror (@errmsg  ,10,1)
   rollback tran  
   return  
end  
  
  
insert dbo.aud_trade_item  
   (trade_num,  
    order_num,  
    item_num,  
    item_status_code,  
    p_s_ind,  
    booking_comp_num,  
    gtc_code,  
    cmdty_code,  
    risk_mkt_code,  
    title_mkt_code,  
    trading_prd,  
    contr_qty,  
    contr_qty_uom_code,  
    contr_qty_periodicity,  
    accum_periodicity,  
    uom_conv_rate,  
    item_type,  
    formula_ind,  
    total_priced_qty,  
    priced_qty_uom_code,  
    avg_price,  
    price_curr_code,  
    price_uom_code,  
    idms_bb_ref_num,  
    idms_contr_num,  
    idms_profit_center,  
    idms_acct_alloc,  
    cmnt_num,  
    brkr_num,  
    brkr_cont_num,  
    brkr_comm_amt,  
    brkr_comm_curr_code,  
    brkr_comm_uom_code,  
    brkr_ref_num,  
    fut_trader_init,  
    parent_item_num,  
    real_port_num,  
    amend_num,  
    amend_creation_date,  
    amend_effect_start_date,  
    amend_effect_end_date,  
    summary_item_num,  
    pooling_type,  
    pooling_port_num,  
    pooling_port_ind,  
    total_sch_qty,  
    sch_qty_uom_code,  
    open_qty,  
    open_qty_uom_code,  
    mtm_pl,  
    mtm_pl_curr_code,  
    mtm_pl_as_of_date,  
    strip_item_status,  
    estimate_ind,  
    billing_type,  
    sched_status,  
    hedge_rate,  
    hedge_curr_code,  
    hedge_multi_div_ind,  
    recap_item_num,  
    hedge_pos_ind,  
    addl_cost_sum,  
    contr_mtm_pl,  
    max_accum_num,  
    formula_declar_date,  
    purchasing_group,  
    origin_country_code,  
    load_port_loc_code,  
    disch_port_loc_code,  
    excp_addns_code,  
    internal_parent_trade_num,  
    internal_parent_order_num,  
    internal_parent_item_num,  
    trade_modified_ind,  
    item_confirm_ind,  
    finance_bank_num,  
    agreement_num,  
    active_status_ind,  
    market_value,  
    includes_excise_tax_ind,    
    includes_fuel_tax_ind,  
    total_committed_qty,  
    committed_qty_uom_code,  
    is_cleared_ind,  
    clr_service_num,  
    exch_brkr_num,  
    rin_ind,    
    is_lc_assigned,  
    is_rc_assigned,  
    b2b_trade_item, 
    use_mkt_formula_for_pl,
    sap_order_num,
    trans_id,  
    resp_trans_id)  
select  
   d.trade_num,  
   d.order_num,  
   d.item_num,  
   d.item_status_code,  
   d.p_s_ind,  
   d.booking_comp_num,  
   d.gtc_code,  
   d.cmdty_code,  
   d.risk_mkt_code,  
   d.title_mkt_code,  
   d.trading_prd,  
   d.contr_qty,  
   d.contr_qty_uom_code,  
   d.contr_qty_periodicity,  
   d.accum_periodicity,  
   d.uom_conv_rate,  
   d.item_type,  
   d.formula_ind,  
   d.total_priced_qty,  
   d.priced_qty_uom_code,  
   d.avg_price,  
   d.price_curr_code,  
   d.price_uom_code,  
   d.idms_bb_ref_num,  
   d.idms_contr_num,  
   d.idms_profit_center,  
   d.idms_acct_alloc,  
   d.cmnt_num,  
   d.brkr_num,  
   d.brkr_cont_num,  
   d.brkr_comm_amt,  
   d.brkr_comm_curr_code,  
   d.brkr_comm_uom_code,  
   d.brkr_ref_num,  
   d.fut_trader_init,  
   d.parent_item_num,  
   d.real_port_num,  
   d.amend_num,  
   d.amend_creation_date,  
   d.amend_effect_start_date,  
   d.amend_effect_end_date,  
   d.summary_item_num,  
   d.pooling_type,  
   d.pooling_port_num,  
   d.pooling_port_ind,  
   d.total_sch_qty,  
   d.sch_qty_uom_code,  
   d.open_qty,  
   d.open_qty_uom_code,  
   d.mtm_pl,  
   d.mtm_pl_curr_code,  
   d.mtm_pl_as_of_date,  
   d.strip_item_status,  
   d.estimate_ind,  
   d.billing_type,  
   d.sched_status,  
   d.hedge_rate,  
   d.hedge_curr_code,  
   d.hedge_multi_div_ind,  
   d.recap_item_num,  
   d.hedge_pos_ind,  
   d.addl_cost_sum,  
   d.contr_mtm_pl,  
   d.max_accum_num,  
   d.formula_declar_date,  
   d.purchasing_group,  
   d.origin_country_code,  
   d.load_port_loc_code,  
   d.disch_port_loc_code,  
   d.excp_addns_code,  
   d.internal_parent_trade_num,  
   d.internal_parent_order_num,  
   d.internal_parent_item_num,  
   d.trade_modified_ind,  
   d.item_confirm_ind,  
   d.finance_bank_num,  
   d.agreement_num,  
   d.active_status_ind,  
   d.market_value,  
   d.includes_excise_tax_ind,    
   d.includes_fuel_tax_ind,  
   d.total_committed_qty,  
   d.committed_qty_uom_code,  
   d.is_cleared_ind,  
   d.clr_service_num,  
   d.exch_brkr_num,  
   d.rin_ind,    
   d.is_lc_assigned,  
   d.is_rc_assigned,  
   d.b2b_trade_item, 
   d.use_mkt_formula_for_pl,
   d.sap_order_num,
   d.trans_id,  
   @atrans_id  
from deleted d  
  
  
/* AUDIT_CODE_END */  
  
declare @the_sequence       numeric(32, 0),  
        @the_tran_type      char(1),  
        @the_entity_name    varchar(30)  
  
   select @the_entity_name = 'TradeItem'  
  
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
             convert(varchar(40),d.trade_num),  
             convert(varchar(40),d.order_num),  
             convert(varchar(40),d.item_num),  
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
            ( ( ((sc.trans_type_mask & 1) =   1) and (@the_tran_type = 'E') ) OR  
              ( ((sc.trans_type_mask & 2) =   2) and (@the_tran_type = 'U') ) OR  
              ( ((sc.trans_type_mask & 4) =   4) and (@the_tran_type = 'S') ) OR  
              ( ((sc.trans_type_mask & 8) =   8) and (@the_tran_type = 'P') ) OR  
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'A') )  
            ) AND  
            (a.operation_type_mask & 4) = 4 AND  
            a.entity_name = @the_entity_name  
  
      /* END_ALS_RUN_TOUCH */  
  
      /* BEGIN_TRANSACTION_TOUCH */  
  
      insert dbo.transaction_touch  
      select 'DELETE',  
             @the_entity_name,  
             'DIRECT',  
             convert(varchar(40),d.trade_num),  
             convert(varchar(40),d.order_num),  
             convert(varchar(40),d.item_num),  
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
             convert(varchar(40),d.trade_num),  
             convert(varchar(40),d.order_num),  
             convert(varchar(40),d.item_num),  
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
            ( ( ((sc.trans_type_mask & 1) =   1) and (it.type = 'E') ) OR  
              ( ((sc.trans_type_mask & 2) =   2) and (it.type = 'U') ) OR  
              ( ((sc.trans_type_mask & 4) =   4) and (it.type = 'S') ) OR  
              ( ((sc.trans_type_mask & 8) =   8) and (it.type = 'P') ) OR  
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'A') )  
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
             convert(varchar(40),d.trade_num),  
             convert(varchar(40),d.order_num),  
             convert(varchar(40),d.item_num),  
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE trigger [dbo].[trade_item_instrg]
on [dbo].[trade_item]
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

   select @the_entity_name = 'TradeItem'

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
             convert(varchar(40), trade_num),
             convert(varchar(40), order_num),
             convert(varchar(40), item_num),
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trade_item_updtrg]  
on [dbo].[trade_item]  
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
   raiserror ('(trade_item) The change needs to be attached with a new trans_id',10,1)
   rollback tran  
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
      select @errmsg = '(trade_item) New trans_id must be larger than original trans_id.'  
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'  
      raiserror (@errmsg,10,1)
      rollback tran  
      return  
   end  
end  
  
if exists (select * from inserted i, deleted d  
           where i.trans_id < d.trans_id and  
                 i.trade_num = d.trade_num and   
                 i.order_num = d.order_num and   
                 i.item_num = d.item_num )  
begin  
   select @errmsg = '(trade_item) new trans_id must not be older than current trans_id.'     
   if @num_rows = 1   
   begin  
      select @errmsg = @errmsg + ' (' + convert(varchar, i.trade_num) + ',' +   
                                        convert(varchar, i.order_num) + ',' +  
                                        convert(varchar, i.item_num) + ')'  
      from inserted i  
   end  
   rollback tran  
   raiserror (@errmsg ,10,1)
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
      raiserror ('(trade_item) primary key can not be changed.' ,10,1)
      rollback tran  
      return  
   end  
end  
  
/* AUDIT_CODE_BEGIN */  
  
if @dummy_update = 0  
   insert dbo.aud_trade_item  
      (trade_num,  
       order_num,  
       item_num,  
       item_status_code,  
       p_s_ind,  
       booking_comp_num,  
       gtc_code,  
       cmdty_code,  
       risk_mkt_code,  
       title_mkt_code,  
       trading_prd,  
       contr_qty,  
       contr_qty_uom_code,  
       contr_qty_periodicity,  
       accum_periodicity,  
       uom_conv_rate,  
       item_type,  
       formula_ind,  
       total_priced_qty,  
       priced_qty_uom_code,  
       avg_price,  
       price_curr_code,  
       price_uom_code,  
       idms_bb_ref_num,  
       idms_contr_num,  
       idms_profit_center,  
       idms_acct_alloc,  
       cmnt_num,  
       brkr_num,  
       brkr_cont_num,  
       brkr_comm_amt,  
       brkr_comm_curr_code,  
       brkr_comm_uom_code,  
       brkr_ref_num,  
       fut_trader_init,  
       parent_item_num,  
       real_port_num,  
       amend_num,  
       amend_creation_date,  
       amend_effect_start_date,  
       amend_effect_end_date,  
       summary_item_num,  
       pooling_type,  
       pooling_port_num,  
       pooling_port_ind,  
       total_sch_qty,  
       sch_qty_uom_code,  
       open_qty,  
       open_qty_uom_code,  
       mtm_pl,  
       mtm_pl_curr_code,  
       mtm_pl_as_of_date,  
       strip_item_status,  
       estimate_ind,  
       billing_type,  
       sched_status,  
       hedge_rate,  
       hedge_curr_code,  
       hedge_multi_div_ind,  
       recap_item_num,  
       hedge_pos_ind,  
       addl_cost_sum,  
       contr_mtm_pl,  
       max_accum_num,  
       formula_declar_date,  
       purchasing_group,  
       origin_country_code,  
       load_port_loc_code,  
       disch_port_loc_code,  
       excp_addns_code,  
       internal_parent_trade_num,  
       internal_parent_order_num,  
       internal_parent_item_num,  
       trade_modified_ind,  
       item_confirm_ind,  
       finance_bank_num,  
       agreement_num,  
       active_status_ind,  
       market_value,  
       includes_excise_tax_ind,    
       includes_fuel_tax_ind,  
       total_committed_qty,  
       committed_qty_uom_code,  
       is_cleared_ind,  
       clr_service_num,  
       exch_brkr_num,  
       rin_ind,    
       is_lc_assigned,  
       is_rc_assigned,  
       b2b_trade_item,
       use_mkt_formula_for_pl,
       sap_order_num,
       trans_id,  
       resp_trans_id)  
   select  
      d.trade_num,  
      d.order_num,  
      d.item_num,  
      d.item_status_code,  
      d.p_s_ind,  
      d.booking_comp_num,  
      d.gtc_code,  
      d.cmdty_code,  
      d.risk_mkt_code,  
      d.title_mkt_code,  
      d.trading_prd,  
      d.contr_qty,  
      d.contr_qty_uom_code,  
      d.contr_qty_periodicity,  
      d.accum_periodicity,  
      d.uom_conv_rate,  
      d.item_type,  
      d.formula_ind,  
      d.total_priced_qty,  
      d.priced_qty_uom_code,  
      d.avg_price,  
      d.price_curr_code,  
      d.price_uom_code,  
      d.idms_bb_ref_num,  
      d.idms_contr_num,  
      d.idms_profit_center,  
      d.idms_acct_alloc,  
      d.cmnt_num,  
      d.brkr_num,  
      d.brkr_cont_num,  
      d.brkr_comm_amt,  
      d.brkr_comm_curr_code,  
      d.brkr_comm_uom_code,  
      d.brkr_ref_num,  
      d.fut_trader_init,  
      d.parent_item_num,  
      d.real_port_num,  
      d.amend_num,  
      d.amend_creation_date,  
      d.amend_effect_start_date,  
      d.amend_effect_end_date,  
      d.summary_item_num,  
      d.pooling_type,  
      d.pooling_port_num,  
      d.pooling_port_ind,  
      d.total_sch_qty,  
      d.sch_qty_uom_code,  
      d.open_qty,  
      d.open_qty_uom_code,  
      d.mtm_pl,  
      d.mtm_pl_curr_code,  
      d.mtm_pl_as_of_date,  
      d.strip_item_status,  
      d.estimate_ind,  
      d.billing_type,  
      d.sched_status,  
      d.hedge_rate,  
      d.hedge_curr_code,  
      d.hedge_multi_div_ind,  
      d.recap_item_num,  
      d.hedge_pos_ind,  
      d.addl_cost_sum,  
      d.contr_mtm_pl,  
      d.max_accum_num,  
      d.formula_declar_date,  
      d.purchasing_group,  
      d.origin_country_code,  
      d.load_port_loc_code,  
      d.disch_port_loc_code,  
      d.excp_addns_code,  
      d.internal_parent_trade_num,  
      d.internal_parent_order_num,  
      d.internal_parent_item_num,  
      d.trade_modified_ind,  
      d.item_confirm_ind,  
      d.finance_bank_num,  
      d.agreement_num,  
      d.active_status_ind,  
      d.market_value,  
      d.includes_excise_tax_ind,    
      d.includes_fuel_tax_ind,  
      d.total_committed_qty,  
      d.committed_qty_uom_code,  
      d.is_cleared_ind,  
      d.clr_service_num,  
      d.exch_brkr_num,  
      d.rin_ind,    
      d.is_lc_assigned,  
      d.is_rc_assigned,  
      d.b2b_trade_item,  
      d.use_mkt_formula_for_pl,
      d.sap_order_num,
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
  
   select @the_entity_name = 'TradeItem'  
  
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
            ( ( ((sc.trans_type_mask & 1) =   1) and (@the_tran_type = 'E') ) OR  
              ( ((sc.trans_type_mask & 2) =   2) and (@the_tran_type = 'U') ) OR  
              ( ((sc.trans_type_mask & 4) =   4) and (@the_tran_type = 'S') ) OR  
              ( ((sc.trans_type_mask & 8) =   8) and (@the_tran_type = 'P') ) OR  
              ( ((sc.trans_type_mask & 16) = 16) and (@the_tran_type = 'A') )  
            ) AND  
            (a.operation_type_mask & 2) = 2 AND  
            a.entity_name = @the_entity_name  
  
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
            ( ( ((sc.trans_type_mask & 1) =   1) and (it.type = 'E') ) OR  
              ( ((sc.trans_type_mask & 2) =   2) and (it.type = 'U') ) OR  
              ( ((sc.trans_type_mask & 4) =   4) and (it.type = 'S') ) OR  
              ( ((sc.trans_type_mask & 8) =   8) and (it.type = 'P') ) OR  
              ( ((sc.trans_type_mask & 16) = 16) and (it.type = 'A') )  
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
  
return  
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [CK__trade_ite__is_lc__477C86E9] CHECK (([is_lc_assigned]='N' OR [is_lc_assigned]='Y'))
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [CK__trade_ite__is_rc__4964CF5B] CHECK (([is_rc_assigned]='N' OR [is_rc_assigned]='Y'))
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [CK__trade_ite__rin_i__45943E77] CHECK (([rin_ind]='N' OR [rin_ind]='Y' OR [rin_ind]=NULL))
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_pk] PRIMARY KEY CLUSTERED  ([trade_num], [order_num], [item_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_TS_idx92] ON [dbo].[trade_item] ([booking_comp_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_TS_idx91] ON [dbo].[trade_item] ([brkr_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_TS_idx90] ON [dbo].[trade_item] ([cmdty_code], [risk_mkt_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_TS_idx94] ON [dbo].[trade_item] ([cmnt_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx6] ON [dbo].[trade_item] ([pooling_port_num], [real_port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx5] ON [dbo].[trade_item] ([real_port_num], [formula_ind]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_TS_idx93] ON [dbo].[trade_item] ([risk_mkt_code], [cmdty_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_POSGRID_idx1] ON [dbo].[trade_item] ([trade_num], [order_num], [cmnt_num]) INCLUDE ([contr_qty], [contr_qty_uom_code], [idms_acct_alloc], [item_num], [p_s_ind]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx4] ON [dbo].[trade_item] ([trade_num], [order_num], [item_num], [item_type], [real_port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx2] ON [dbo].[trade_item] ([trade_num], [order_num], [parent_item_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx1] ON [dbo].[trade_item] ([trade_num], [order_num], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [trade_item_idx3] ON [dbo].[trade_item] ([trade_num], [trans_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk1] FOREIGN KEY ([booking_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk10] FOREIGN KEY ([origin_country_code]) REFERENCES [dbo].[country] ([country_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk11] FOREIGN KEY ([excp_addns_code]) REFERENCES [dbo].[exceptions_additions] ([excp_addns_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk12] FOREIGN KEY ([gtc_code]) REFERENCES [dbo].[gtc] ([gtc_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk13] FOREIGN KEY ([fut_trader_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk14] FOREIGN KEY ([load_port_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk15] FOREIGN KEY ([disch_port_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk16] FOREIGN KEY ([risk_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk17] FOREIGN KEY ([title_mkt_code]) REFERENCES [dbo].[market] ([mkt_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk2] FOREIGN KEY ([brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk22] FOREIGN KEY ([contr_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk23] FOREIGN KEY ([priced_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk24] FOREIGN KEY ([price_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk25] FOREIGN KEY ([brkr_comm_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk26] FOREIGN KEY ([sch_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk3] FOREIGN KEY ([brkr_num], [brkr_cont_num]) REFERENCES [dbo].[account_contact] ([acct_num], [acct_cont_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk30] FOREIGN KEY ([finance_bank_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk31] FOREIGN KEY ([agreement_num]) REFERENCES [dbo].[account_agreement] ([agreement_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk32] FOREIGN KEY ([committed_qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk33] FOREIGN KEY ([clr_service_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk34] FOREIGN KEY ([exch_brkr_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk5] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk6] FOREIGN KEY ([price_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk7] FOREIGN KEY ([brkr_comm_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk8] FOREIGN KEY ([mtm_pl_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[trade_item] ADD CONSTRAINT [trade_item_fk9] FOREIGN KEY ([hedge_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[trade_item] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[trade_item] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[trade_item] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[trade_item] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'trade_item', NULL, NULL
GO
