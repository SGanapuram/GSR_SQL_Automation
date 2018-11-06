SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE procedure [dbo].[usp_add_storage_trade]            
(            
   @acct_short_name nvarchar(30),                  
   @trader_init         char(3),                  
   @buy_trade_num       int,                  
   @buy_order_num       smallint,                  
   @buy_item_num        smallint,             
   @alloc_qty           float = null,            
   @nomin_qty  float = null,            
   @actual_qty  float = null,          
   @bl_date             datetime=null,          
   @nor_date            datetime=null,          
   @disch_cmnc_date     datetime=null,          
   @load_cmnc_date      datetime=null,          
   @disch_compl_date    datetime=null,          
   @load_compl_date     datetime=null,          
   @actual_date         datetime=null,          
   --@event_type varchar(8),            
   @debugon             bit = 0,      
   @executor_id  int = 0    --Added in ADSO-3418      
)            
as            
set nocount on            
set xact_abort on            
            
declare @errmsg                  varchar(max)            
declare @rows_affected           int            
declare @errcode                 int            
declare @trade_num               int                 
declare @acct_num                int            
declare @trans_id                int            
declare @storage_qty             float                  
declare @extended_storage_qty    float            
declare @status                  int                  
declare @open_qty                float            
declare @contr_qty_periodicity   char(1)            
declare @del_date_from           datetime            
declare @del_date_to             datetime         
declare @item_type   char(1)      
declare @loginame  varchar(20)      
declare @workstation_name varchar(20)      
declare @init   char(3)      
declare @new_sequence_num table (seq_num  int)                 
            
          
   set @errcode = 0              
   set @status = 0                                    
   set @acct_num =  (select top 1 acct_num         
                    from dbo.account with (nolock)        
                    where acct_short_name = @acct_short_name and         
                          acct_type_code in ( 'CUSTOMER','WAREHSRE','FCLYOWNR') and        
                          acct_status = 'A')                 
   if @acct_num is null            
   begin            
      RAISERROR('=> Invalid acct_short_name ''%s'' passed for the argument ''@acct_short_name''!', 0, 1, @acct_short_name) WITH NOWAIT            
      set @errcode = 1            
      goto endofsp                   
   end            
            
   if not exists (select 1             
                  from dbo.icts_user wth (nolock)                 
                  where user_init = @trader_init and             
                        user_status = 'A')                  
   begin                  
      RAISERROR('=> Invalid trader_init ''%s'' passed for the argument ''@trader_init''!', 0, 1, @trader_init) WITH NOWAIT            
      set @errcode = 1                 
      goto endofsp             
   end                  
                     
   --if exists (select 1              
   --           from dbo.trade_item                   
   --           where trade_num = @buy_trade_num and             
   --                 order_num = @buy_order_num and             
   --                 item_num = @buy_item_num and             
   --                 (sched_status & 4096 <> 4096))               
   --begin                  
   --   set @errcode = 1                 
   --   goto endofsp             
   --end                  
                  
   select @item_type = item_type,      
          @open_qty = open_qty,            
          @contr_qty_periodicity = contr_qty_periodicity            
   from dbo.trade_item                   
   where trade_num = @buy_trade_num and             
         order_num = @buy_order_num and             
         item_num = @buy_item_num              
        
   if @item_type='W'      
      
   select @del_date_from = del_date_from,            
          @del_date_to = del_date_to            
   from dbo.trade_item_wet_phy                 
   where trade_num = @buy_trade_num and             
         order_num = @buy_order_num and             
         item_num = @buy_item_num      
   else if @item_type='D'      
   select @del_date_from = del_date_from,            
          @del_date_to = del_date_to            
from dbo.trade_item_dry_phy                 
   where trade_num = @buy_trade_num and             
         order_num = @buy_order_num and             
         item_num = @buy_item_num      
                 
   if @alloc_qty is not null                  
      set @storage_qty = @alloc_qty                  
   else                  
      set @storage_qty = @open_qty            
                  
   if @contr_qty_periodicity = 'D'                  
      set @extended_storage_qty = @storage_qty * (datediff(dd, @del_date_from, @del_date_to) + 1)                  
   else                  
      set @extended_storage_qty = @storage_qty              
                              
  /* if @alloc_qty is not null  (DB Issue #ADSO-3832)         
   begin                  
      if @open_qty < @alloc_qty                  
      begin                  
         RAISERROR('Cannot allocate more than open quantity', 0, 1) WITH NOWAIT            
         set @errcode = 1                 
         goto endofsp             
      end            
   end   */               
            
   if @nomin_qty is not null            
   set @extended_storage_qty = @nomin_qty            
                  
   /* ****************************************************************** */            
-- new trans_id1 with executor_id 1      
      
exec get_new_num_NOI 'trans_id'      
select @trans_id = last_num from icts_trans_sequence      
      
select @loginame = SUBSTRING(loginame,CHARINDEX('\',loginame)+1,30),       
@workstation_name = RTRIM(hostname)       
from master..sysprocesses where spid = @@spid       
      
select @init = user_init       
from dbo.icts_user       
where user_logon_id = @loginame       
      
if @init is null select @init = @loginame       
      
insert into icts_transaction(trans_id,type,user_init,tran_date,app_name,app_revision,spid,workstation_id,parent_trans_id,executor_id)      
select @trans_id, 'U', @init, GETDATE(), 'MDS_CreateStorageAlloc', null, @@SPID, @workstation_name,null, @executor_id                                 
                  
   /* ****************************************************************** */            
   /* Getting a new trade_num */            
   begin try                  
     update dbo.new_num             
     set last_num = last_num + 1             
            output inserted.last_num into @new_sequence_num            
     where num_col_name = 'trade_num'             
   end try            
   begin catch            
     if @@trancount > 0            
        rollback tran            
     RAISERROR('=> Failed to update the new_num table for a new trade_num due to the error:', 0, 1) WITH NOWAIT            
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT              
     set @errcode = ERROR_NUMBER()            
     goto endofsp                
   end catch                       
                  
   select @trade_num = seq_num             
   from @new_sequence_num             
               
   if @trade_num is null            
   begin             
     if @@trancount > 0            
        rollback tran            
     RAISERROR('=> Failed to obtain a new trade_num for new trade!', 0, 1) WITH NOWAIT            
     set @errcode = 1               
     goto endofsp                           
   end                               
            
   if @debugon = 1            
   begin            
      RAISERROR('DEBUG: trade_num for new trade is %d', 0, 1, @trade_num) WITH NOWAIT            
   end                              
            
   /* ****************************************************************************** */            
   begin try            
     insert into dbo.trade             
        (trade_num,                  
         trader_init,                  
         trade_status_code,                  
         conclusion_type,                  
         inhouse_ind,                  
         acct_num,                  
         concluded_date,                  
         contr_date,            
         cp_gov_contr_ind,                  
         contr_tlx_hold_ind,                  
         creation_date,                  
         creator_init,                  
         invoice_cap_type,                  
         contr_status_code,                  
         max_order_num,                  
         is_long_term_ind,                  
         trans_id)                  
       select @trade_num,                 
              @trader_init,                  
              trade_status_code,                  
              conclusion_type,                  
              inhouse_ind,                  
              @acct_num,                  
              getdate(),                  
              contr_date,                  
              cp_gov_contr_ind,                  
              contr_tlx_hold_ind,                  
              getdate(),                  
              @trader_init,                  
              invoice_cap_type,                  
              contr_status_code,                  
              1,                  
              is_long_term_ind,                  
              @trans_id                  
       from dbo.trade                   
       where trade_num = @buy_trade_num             
     set @rows_affected = @@rowcount                
   end try            
   begin catch            
     RAISERROR('=> Failed to add a trade record due to the error:', 0, 1) WITH NOWAIT              
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT              
     set @errcode = ERROR_NUMBER()                  
     goto endofsp                               
   end catch            
               
   if @rows_affected = 0            
   begin            
      set @errcode = 1            
      goto endofsp            
   end            
               
   if @debugon = 1            
   begin            
      RAISERROR('DEBUG: A new trade with trade_num #%d was added successfully!', 0, 1, @trade_num) WITH NOWAIT            
   end            
               
   set @rows_affected = 0            
   begin try                  
     insert into dbo.trade_order                  
        (trade_num,                  
         order_num,                  
         order_type_code,                  
         order_status_code,                  
         strip_summary_ind,                  
         bal_ind,                  
         max_item_num,                  
         trans_id)                  
       select @trade_num,                  
              1,                  
              'STORAGE',                  
              order_status_code,                  
              'N',                  
              bal_ind,                  
              2,                  
              @trans_id                  
       from dbo.trade_order                  
       where trade_num = @buy_trade_num and             
             order_num = @buy_order_num                  
     set @rows_affected = @@rowcount                 
   end try            
   begin catch            
     RAISERROR('=> Failed to add a trade_order record due to the error:', 0, 1) WITH NOWAIT              
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT              
     set @errcode = ERROR_NUMBER()                  
     goto endofsp                               
   end catch            
            
   if @debugon = 1            
   begin            
      if @rows_affected > 0            
         RAISERROR('DEBUG: 1 new trade_order record was added successfully!', 0, 1) WITH NOWAIT            
      else            
         RAISERROR('DEBUG: No trade_order record was added', 0, 1) WITH NOWAIT            
   end            
                     
   set @rows_affected = 0            
   begin try                        
     insert into dbo.trade_item                  
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
         item_type,                  
         formula_ind,                  
         price_curr_code,                          
         real_port_num,                  
         total_sch_qty,                  
         sch_qty_uom_code,                  
         open_qty,             
         open_qty_uom_code,                  
        estimate_ind,                  
         billing_type,                  
         sched_status,                  
         hedge_multi_div_ind,                  
         hedge_pos_ind,                  
         trans_id,                  
         trade_modified_ind,                  
         item_confirm_ind,                  
         includes_excise_tax_ind,                  
         includes_fuel_tax_ind,                  
         committed_qty_uom_code,                  
         is_lc_assigned,                  
         is_rc_assigned)                  
      select @trade_num,                  
             1,                  
             1,                  
             p.item_status_code,                  
             'P',                  
             p.booking_comp_num,                  
             p.gtc_code,                  
             p.cmdty_code,                  
             p.risk_mkt_code,                  
             p.title_mkt_code,                  
             p.trading_prd,                  
             @extended_storage_qty,                 
             p.contr_qty_uom_code,                  
             'L',                  
             p.accum_periodicity,                  
             'S',                  
             'N',                  
             p.price_curr_code,                         
             p.real_port_num,                  
             0.0,                  
             p.sch_qty_uom_code,                  
             @extended_storage_qty,                  
             p.contr_qty_uom_code,                  
             p.estimate_ind,                  
             p.billing_type,                  
             0,                  
             p.hedge_multi_div_ind,                  
             p.hedge_pos_ind,                  
             @trans_id,                  
             'N',                  
             'N',                  
             p.includes_excise_tax_ind,                  
             p.includes_fuel_tax_ind,                  
             p.contr_qty_uom_code,                  
             'N',                  
             'N'                  
      from                          
           dbo.trade_item p                  
      where                   
            p.trade_num = @buy_trade_num and                 
            p.order_num = @buy_order_num and                 
            p.item_num = @buy_item_num              
               
     set @rows_affected = @@rowcount                 
   end try            
   begin catch            
     RAISERROR('=> Failed to add a trade_item record due to the error:', 0, 1) WITH NOWAIT              
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT              
     set @errcode = ERROR_NUMBER()            
     goto endofsp                               
   end catch                  
            
   if @debugon = 1            
   begin            
      if @rows_affected > 0            
      begin            
         if @rows_affected = 1            
            set @errmsg = 'DEBUG: 1 new trade_item record was added successfully!'            
         else            
            set @errmsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' new trade_item records were added successfully!'            
         RAISERROR(@errmsg, 0, 1) WITH NOWAIT            
      end            
      else            
         RAISERROR('DEBUG: No trade_item records were added', 0, 1) WITH NOWAIT            
   end            
               
  set @rows_affected = 0            
   begin try                        
     insert into dbo.trade_item                  
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
         item_type,                  
         formula_ind,                  
         price_curr_code,                  
  parent_item_num,                  
         real_port_num,                  
         total_sch_qty,                  
         sch_qty_uom_code,                  
         open_qty,                  
         open_qty_uom_code,                  
         estimate_ind,                  
         billing_type,                  
         sched_status,                  
         hedge_multi_div_ind,                  
         hedge_pos_ind,                  
         trans_id,                  
         trade_modified_ind,                  
         item_confirm_ind,                  
         includes_excise_tax_ind,                  
         includes_fuel_tax_ind,                  
         committed_qty_uom_code,                  
         is_lc_assigned,                  
         is_rc_assigned)                  
      select @trade_num,                  
             1,                  
             2,                  
             p.item_status_code,                  
             'S',                  
             p.booking_comp_num,                  
             p.gtc_code,                  
             p.cmdty_code,                  
             p.risk_mkt_code,                  
             p.title_mkt_code,                  
             p.trading_prd,                  
             @extended_storage_qty,                  
             p.contr_qty_uom_code,                  
             'L',                  
             p.accum_periodicity,                  
             'S',                  
             'N',                  
             p.price_curr_code,                  
             1,                  
             p.real_port_num,                  
             0.0,                  
             p.sch_qty_uom_code,                  
             @extended_storage_qty,                  
             p.contr_qty_uom_code,                  
             p.estimate_ind,                  
             p.billing_type,                  
             0,                  
             p.hedge_multi_div_ind,                  
             p.hedge_pos_ind,                  
             @trans_id,                  
             'N',                  
             'N',                  
             p.includes_excise_tax_ind,                  
             p.includes_fuel_tax_ind,                  
             p.contr_qty_uom_code,            
             'N',                  
             'N'                  
      from                          
           dbo.trade_item p                  
      where                   
            p.trade_num = @buy_trade_num and                 
            p.order_num = @buy_order_num and                 
            p.item_num = @buy_item_num              
     set @rows_affected = @@rowcount                 
   end try            
   begin catch            
     RAISERROR('=> Failed to add a trade_item record due to the error:', 0, 1) WITH NOWAIT              
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT              
     set @errcode = ERROR_NUMBER()            
     goto endofsp                               
   end catch                  
            
   if @debugon = 1            
   begin            
      if @rows_affected > 0            
      begin            
         if @rows_affected = 1            
            set @errmsg = 'DEBUG: 1 new trade_item record was added successfully!'            
         else            
            set @errmsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' new trade_item records were added successfully!'            
         RAISERROR(@errmsg, 0, 1) WITH NOWAIT            
      end            
      else            
         RAISERROR('DEBUG: No trade_item records were added', 0, 1) WITH NOWAIT            
   end                     
   set @rows_affected = 0            
   begin try       
     if @item_type = 'W'      
     insert into dbo.trade_item_storage                  
        (trade_num,                  
         order_num,                  
         item_num,                  
         storage_start_date,                  
         storage_end_date,                  
         storage_loc_code,                  
         mot_code,                  
         pay_days,                  
         pay_term_code,                  
         credit_term_code,                  
         trans_id)                  
         select @trade_num,                  
             1,                  
             1,                  
             w.del_date_from,                  
             w.del_date_to,                  
             w.del_loc_code,                  
             'STORAGE',                  
             w.pay_days,                  
             w.pay_term_code,                  
             w.credit_term_code,                  
             @trans_id                  
      from                        
           dbo.trade_item_wet_phy w                  
      where                     
            w.trade_num = @buy_trade_num and                 
            w.order_num = @buy_order_num and                 
            w.item_num = @buy_item_num         
                  
     else if @item_type = 'D'        
           
          insert into dbo.trade_item_storage                  
        (trade_num,                  
         order_num,                  
         item_num,                  
         storage_start_date,                  
         storage_end_date,                  
         storage_loc_code,                  
         mot_code,                  
         pay_days,                  
         pay_term_code,                  
         credit_term_code,                  
         trans_id)                  
         select @trade_num,                  
             1,                  
             1,                  
             w.del_date_from,                  
             w.del_date_to,                  
             w.del_loc_code,                  
             'STORAGE',                  
             w.pay_days,                  
             w.pay_term_code,                  
             w.credit_term_code,                  
             @trans_id                  
      from                        
           dbo.trade_item_dry_phy w                  
      where                     
            w.trade_num = @buy_trade_num and                 
            w.order_num = @buy_order_num and                 
            w.item_num = @buy_item_num       
            
     set @rows_affected = @@rowcount                 
   end try            
   begin catch            
     RAISERROR('=> Failed to add a trade_item_storage record due to the error:', 0, 1) WITH NOWAIT              
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT              
     set @errcode = ERROR_NUMBER()            
     goto endofsp                               
   end catch                    
            
   if @debugon = 1            
   begin            
      if @rows_affected > 0            
      begin            
         if @rows_affected = 1            
            set @errmsg = 'DEBUG: 1 new trade_item_storage record was added successfully!'            
         else            
            set @errmsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' new trade_item_storage records were added successfully!'            
         RAISERROR(@errmsg, 0, 1) WITH NOWAIT            
      end            
      else            
         RAISERROR('DEBUG: No trade_item_storage records were added', 0, 1) WITH NOWAIT            
   end            
          
          
      set @rows_affected = 0            
   begin try        
     if @item_type = 'W'                      
     insert into dbo.trade_item_storage                  
        (trade_num,                  
         order_num,                  
         item_num,                  
         storage_start_date,                  
         storage_end_date,                  
         storage_loc_code,                  
         mot_code,                  
         pay_days,                  
         pay_term_code,                  
         credit_term_code,                  
         trans_id)                  
      select @trade_num,                  
             1,                  
             2,                  
             w.del_date_from,                  
             w.del_date_to,                  
             w.del_loc_code,                  
             'STORAGE',                  
             w.pay_days,                  
             w.pay_term_code,                  
             w.credit_term_code,                  
             @trans_id                  
      from                        
           dbo.trade_item_wet_phy w                  
      where                     
            w.trade_num = @buy_trade_num and                 
            w.order_num = @buy_order_num and                 
            w.item_num = @buy_item_num        
                  
      else if @item_type = 'D'      
           insert into dbo.trade_item_storage                  
        (trade_num,                  
         order_num,                  
         item_num,                  
         storage_start_date,                  
         storage_end_date,                  
         storage_loc_code,                  
         mot_code,                  
         pay_days,                  
         pay_term_code,                  
         credit_term_code,                  
         trans_id)                  
      select @trade_num,                  
             1,                  
             2,                  
             w.del_date_from,                  
             w.del_date_to,                  
             w.del_loc_code,                  
             'STORAGE',                  
             w.pay_days,                  
             w.pay_term_code,                  
             w.credit_term_code,                  
             @trans_id                  
      from                        
           dbo.trade_item_dry_phy w                  
      where                     
            w.trade_num = @buy_trade_num and                 
            w.order_num = @buy_order_num and                 
            w.item_num = @buy_item_num         
                          
     set @rows_affected = @@rowcount                 
   end try          
   begin catch            
     RAISERROR('=> Failed to add a trade_item_storage record due to the error:', 0, 1) WITH NOWAIT              
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT              
     set @errcode = ERROR_NUMBER()            
     goto endofsp                               
   end catch                    
            
   if @debugon = 1            
   begin            
      if @rows_affected > 0            
      begin            
         if @rows_affected = 1            
            set @errmsg = 'DEBUG: 1 new trade_item_storage record was added successfully!'            
         else            
            set @errmsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' new trade_item_storage records were added successfully!'            
         RAISERROR(@errmsg, 0, 1) WITH NOWAIT            
      end            
      else            
         RAISERROR('DEBUG: No trade_item_storage records were added', 0, 1) WITH NOWAIT            
   end          
          
      
          
    /************ Begin adding trade sync table entry for storage trade item ***************/    
    
   set @rows_affected = 0            
   begin try        
     if @item_type = 'W'                      
     insert into dbo.trade_sync                  
        (trade_num,                  
         trade_sync_inds,                        
         trans_id)                  
      select @trade_num,                  
             '0000N---',                               
             @trans_id                  
      from                        
           dbo.trade_item_wet_phy w                  
      where                     
            w.trade_num = @buy_trade_num and                 
            w.order_num = @buy_order_num and                 
            w.item_num = @buy_item_num        
                  
      else if @item_type = 'D'      
     insert into dbo.trade_sync                  
        (trade_num,                  
         trade_sync_inds,                                
         trans_id)                  
      select @trade_num,                  
             '0000N---',                               
             @trans_id                   
      from                        
           dbo.trade_item_dry_phy w                  
      where                     
            w.trade_num = @buy_trade_num and                 
            w.order_num = @buy_order_num and                 
            w.item_num = @buy_item_num         
                          
     set @rows_affected = @@rowcount                 
   end try            
   begin catch            
     RAISERROR('=> Failed to add a trade_sync record due to the error:', 0, 1) WITH NOWAIT              
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT              
     set @errcode = ERROR_NUMBER()            
     goto endofsp                               
   end catch                    
            
   if @debugon = 1            
   begin            
      if @rows_affected > 0            
      begin            
         if @rows_affected = 1            
            set @errmsg = 'DEBUG: 1 new trade_sync record was added successfully!'            
         else            
            set @errmsg = 'DEBUG: ' + cast(@rows_affected as varchar) + ' new trade_sync record was added successfully!'            
         RAISERROR(@errmsg, 0, 1) WITH NOWAIT            
      end            
      else            
         RAISERROR('DEBUG: No trade_sync record was added', 0, 1) WITH NOWAIT            
   end    
    /************ End adding trade sync table entry for storage trade item *****************/    
    
    
    
    
    
            
   /* ****************************************************************************************************** */            
   /* ****************************************************************************************************** */            
   exec @status = dbo.usp_add_allocation_4_storage_trade @buy_trade_num,                  
                                                         @buy_order_num,                  
                                                         @buy_item_num,                  
                                                         @trade_num,                 
        @trader_init,            
                                                         @storage_qty,                  
                                                         @extended_storage_qty,                
        @actual_qty,          
        @bl_date ,          
         @nor_date ,           
         @disch_cmnc_date,            
         @load_cmnc_date,         
         @disch_compl_date,         
         @load_compl_date,        
       @actual_date,            
                                                         @trans_id,            
                                                         1    /* @debugon */            
   if @status > 0            
   begin            
      if @@trancount > 0            
         rollback tran            
      goto endofsp            
   end             
            
   /* ************************************************************************************* */            
   /* ************************************************************************************* */            
   /*  Since we need to set sched_status column of the newly added trade_item record, we need            
       a new trans_id for update to avoid the following error occurred inside the trigger of            
       the trade_item table:            
          (trade_item) New trans_id must be larger than original trans_id.            
   */            
                
   set @trans_id = null            
-- new trans_id1 with executor_id 1      
      
exec get_new_num_NOI 'trans_id'      
select @trans_id = last_num from icts_trans_sequence      
      
select @loginame = SUBSTRING(loginame,CHARINDEX('\',loginame)+1,30),       
@workstation_name = RTRIM(hostname)       
from master..sysprocesses where spid = @@spid       
      
select @init = user_init       
from dbo.icts_user       
where user_logon_id = @loginame       
      
if @init is null select @init = @loginame       
      
insert into icts_transaction(trans_id,type,user_init,tran_date,app_name,app_revision,spid,workstation_id,parent_trans_id,executor_id)      
select @trans_id, 'U', @init, GETDATE(), 'MDS_CreateStorageAlloc', null, @@SPID, @workstation_name,null, @executor_id                    
                        
   /* set scheduled status of the storage trade */              
   begin try               
     update dbo.trade_item                  
     set trans_id = @trans_id,                  
         sched_status = 23                  
     where trade_num = @trade_num and             
           order_num = 1 and             
           p_s_ind = 'S'                  
     set @rows_affected = @@rowcount                 
   end try            
   begin catch            
     if @@trancount > 0            
        rollback tran            
    RAISERROR('=> Failed to update the scheduled status of the storage trade due to the error:', 0, 1) WITH NOWAIT            
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT               
     set @errcode = ERROR_NUMBER()                  
     goto endofsp                                  
   end catch            
            
   if @debugon = 1            
   begin            
      if @rows_affected > 0            
         RAISERROR('DEBUG: The scheduled status of the trade_item (%d/1/S) was updated successfully', 0, 1, @trade_num) WITH NOWAIT            
   end                       
               
   /* update physical buy trade_item */                  
   begin try               
     update dbo.trade_item                   
  set trans_id = @trans_id,                  
         total_sch_qty = isnull(total_sch_qty, 0.0) + @storage_qty,            
         open_qty = open_qty - @storage_qty                  
     where trade_num = @buy_trade_num and                 
           order_num = @buy_order_num and                 
           item_num = @buy_item_num                  
     set @rows_affected = @@rowcount                 
   end try            
   begin catch            
     if @@trancount > 0            
        rollback tran            
    RAISERROR('=> Failed to update the total_sch_qty and open_qty for a trade_item record due to the error:', 0, 1) WITH NOWAIT            
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT               
     set @errcode = ERROR_NUMBER()                  
     goto endofsp                                  
   end catch                         
            
   if @debugon = 1            
   begin            
      if @rows_affected > 0            
         RAISERROR('DEBUG: The total_sch_qty/open_qty of the physical buy trade_item (%d/%d/%d) was updated successfully', 0, 1, @buy_trade_num, @buy_order_num, @buy_item_num) WITH NOWAIT            
   end                       
                  
   /* update trade_item_dist */                  
   begin try               
     update dbo.trade_item_dist                  
     set trans_id = @trans_id,                    
         alloc_qty = isnull(alloc_qty, 0.0) + @extended_storage_qty                  
     where trade_num = @buy_trade_num and                
           order_num = @buy_order_num and                 
           item_num = @buy_item_num and                 
           dist_type = 'D'                  
     set @rows_affected = @@rowcount                 
   end try            
   begin catch            
   if @@trancount > 0            
        rollback tran            
    RAISERROR('=> Failed to update alloc_qty for distribution records due to the error:', 0, 1) WITH NOWAIT            
     set @errmsg = ERROR_MESSAGE()            
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT               
     set @errcode = ERROR_NUMBER()                  
     goto endofsp                                  
   end catch              
               
   if @debugon = 1            
   begin            
      if @rows_affected > 0            
         RAISERROR('DEBUG: The alloc_qty of the trade_item_dist record related to the physical buy trade_item (%d/%d/%d) was updated successfully', 0, 1, @buy_trade_num, @buy_order_num, @buy_item_num) WITH NOWAIT            
   end                       
            
   if @@trancount > 0                                       
      commit tran                  
               
endofsp:            
if @errcode > 0            
   return 1            
return 0      
  
grant exec on dbo.usp_add_storage_trade to next_usr  
GO
GRANT EXECUTE ON  [dbo].[usp_add_storage_trade] TO [next_usr]
GO
