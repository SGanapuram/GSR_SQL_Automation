SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_add_allocation_4_storage_trade]
(              
   @buy_trade_num            int,                    
   @buy_order_num            smallint,                    
   @buy_item_num             smallint,               
   @trade_num                int,                   
   @trader_init              varchar(3),              
   @storage_qty              float,                    
   @extended_storage_qty     float,                
   @actual_qty     float = null,              
   @bl_date                     datetime,            
   @nor_date                    datetime,             
   @disch_cmnc_date             datetime,              
   @load_cmnc_date              datetime,           
   @disch_compl_date            datetime,           
   @load_compl_date             datetime,           
   @actual_date                 datetime,           
   --@event_type       varchar(8),              
   @trans_id                 int,              
   @debugon                  bit = 0              
)              
as              
set nocount on              
set xact_abort on              
declare @errmsg                     varchar(max)              
declare @rows_affected              int              
declare @alloc_num                  int              
declare @inv_num                    int              
declare @inv_b_d_num                int              
declare @errcode                    int              
declare @sec_uom_code               char(4)                    
declare @sec_uom_factor             float                    
declare @alloc_type_code            char(1)               
declare @status                     int             
              
declare @new_sequence_num           table (seq_num  int)              
              
-- trade_item (@buy_trade_num, @buy_order_num, @buy_item_num)              
declare @TI_trade_num               int              
declare @TI_order_num               smallint              
declare @TI_item_num                smallint       
declare @TI_item_type               char(1)    
declare @TI_acct_num                int              
declare @TI_contr_qty_periodicity   char(1)              
declare @TI_contr_qty_uom_code      varchar(4)                    
declare @TI_cmdty_code              varchar(8)              
declare @TI_trading_prd             varchar(40)              
declare @TI_desired_pl_curr_code    varchar(8)              
declare @TI_price_curr_code         varchar(8)                    
declare @TI_price_uom_code          varchar(4)              
              
-- trade_item (@trade_num, 1, P_S_ind = 'S')              
declare @TI_S_trade_num             int              
declare @TI_S_order_num             smallint              
declare @TI_S_item_num              smallint              
declare @TI_S_cmdty_code            varchar(8)              
declare @TI_S_trading_prd           varchar(40)              
declare @TI_S_real_port_num         int              
              
-- trade_item_wet_phy (@buy_trade_num, @buy_order_num, @buy_item_num)              
declare @TIWP_del_date_from         datetime              
declare @TIWP_del_date_to           datetime              
declare @TIWP_mot_code              varchar(8)              
declare @TIWP_del_loc_code          varchar(8)              
declare @TIWP_credit_term_code      varchar(8)                   
declare @TIWP_pay_term_code         varchar(8)                    
declare @TIWP_pay_days              int                    
declare @TIWP_del_term_code         varchar(8)              
declare @TIWP_mot_type_code         char(1)              
              
-- trade_item_dist (MAX(dist_num) <= @buy_trade_num, @buy_order_num, @buy_item_num)              
declare @TID_qty_uom_code           varchar(4)                    
declare @TID_qty_uom_code_conv_to   varchar(4)                    
declare @TID_sec_qty_uom_code       varchar(4)               
declare @TID_qty_uom_conv_rate      float               
declare @TID_sec_conversion_factor  float            
declare @TID_dist_uom_type          char(1)                    
declare @TID_qty_uom_code_conv_to_type  char(1)                     
declare @TID_sec_qty_uom_code_type      char(1)               
              
-- allocation_item_transport               
--declare @bl_date                     datetime = null              
--declare @nor_date             datetime = null              
--declare @disch_cmnc_date             datetime = null              
--declare @load_cmnc_date              datetime = null              
--declare @disch_compl_date            datetime = null              
--declare @load_compl_date             datetime = null              
declare @lay_days_start_date         datetime = null            
declare @lay_days_end_date           datetime = null              
declare @negotiated_date             datetime = null              
declare @title_transfer_date         datetime = null              
declare @ai_est_actual_date      datetime = null              
declare @converted_actual_date       datetime = null              
                  
   set @errcode = 0              
   set @status = 0              
                  
   -- Save data items from the trade_item table into local variables              
   select @TI_trade_num = ti.trade_num,              
          @TI_order_num = ti.order_num,              
          @TI_item_num = ti.item_num,    
          @TI_item_type = ti.item_type,              
          @TI_acct_num = t.acct_num,              
          @TI_contr_qty_periodicity = ti.contr_qty_periodicity,              
          @TI_contr_qty_uom_code = ti.contr_qty_uom_code,                    
          @TI_cmdty_code = ti.cmdty_code,              
          @TI_trading_prd = ti.trading_prd,              
          @TI_desired_pl_curr_code = p.desired_pl_curr_code,              
          @TI_price_curr_code = ti.price_curr_code,                    
          @TI_price_uom_code = ti.price_uom_code              
   from dbo.trade_item ti              
           join dbo.trade t              
              on ti.trade_num = t.trade_num              
           join dbo.portfolio p with (nolock)              
              on ti.real_port_num = p.port_num              
   where ti.trade_num = @buy_trade_num and               
         ti.order_num = @buy_order_num and               
         ti.item_num = @buy_item_num              
              
   -- Save data items from the trade_item table (p_s_ind = 'S') into local variables              
   select @TI_S_trade_num = trade_num,              
          @TI_S_order_num = order_num,              
          @TI_S_item_num = item_num,              
          @TI_S_cmdty_code = cmdty_code,              
          @TI_S_trading_prd = trading_prd,              
          @TI_S_real_port_num = real_port_num              
   from dbo.trade_item              
   where trade_num = @trade_num and               
         order_num = 1 and               
         p_s_ind = 'S'              
              
   -- Save data items from the trade_item_wet_phy table into local variables     
   if @TI_item_type = 'W'            
   select @TIWP_del_date_from = tiwp.del_date_from,              
          @TIWP_del_date_to = tiwp.del_date_to,              
          @TIWP_mot_code = tiwp.mot_code,              
          @TIWP_del_loc_code = tiwp.del_loc_code,              
          @TIWP_credit_term_code = tiwp.credit_term_code,                    
          @TIWP_pay_term_code = tiwp.pay_term_code,                    
          @TIWP_pay_days = tiwp.pay_days,                    
          @TIWP_del_term_code = tiwp.del_term_code,              
          @TIWP_mot_type_code = m.mot_type_code              
   from dbo.trade_item_wet_phy tiwp              
           join dbo.mot m with (nolock)              
              on tiwp.mot_code = m.mot_code              
   where trade_num = @buy_trade_num and               
         order_num = @buy_order_num and               
         item_num = @buy_item_num         
      
   -- Save data items from the trade_item_dry _phy table into local variables     
       
   else if @TI_item_type='D'             
   select @TIWP_del_date_from = tiwp.del_date_from,              
          @TIWP_del_date_to = tiwp.del_date_to,              
          @TIWP_mot_code = tiwp.mot_code,          
          @TIWP_del_loc_code = tiwp.del_loc_code,              
          @TIWP_credit_term_code = tiwp.credit_term_code,                    
          @TIWP_pay_term_code = tiwp.pay_term_code,                    
          @TIWP_pay_days = tiwp.pay_days,                    
          @TIWP_del_term_code = tiwp.del_term_code,              
          @TIWP_mot_type_code = m.mot_type_code              
   from dbo.trade_item_dry_phy tiwp              
           join dbo.mot m with (nolock)              
              on tiwp.mot_code = m.mot_code              
   where trade_num = @buy_trade_num and               
         order_num = @buy_order_num and               
         item_num = @buy_item_num          
                                
   -- Save data items from the trade_item_dist table into local variables              
   select @TID_qty_uom_code = qty_uom_code,                    
          @TID_qty_uom_code_conv_to = qty_uom_code_conv_to,                    
          @TID_sec_qty_uom_code = sec_qty_uom_code,               
          @TID_qty_uom_conv_rate = qty_uom_conv_rate,               
          @TID_sec_conversion_factor = sec_conversion_factor,              
          @TID_dist_uom_type = u1.uom_type,                    
          @TID_qty_uom_code_conv_to_type = u2.uom_type,                    
          @TID_sec_qty_uom_code_type = u3.uom_type                    
     from dbo.trade_item_dist d         
             JOIN dbo.uom u1 with(nolock)              
                ON d.qty_uom_code = u1.uom_code                   
             JOIN dbo.uom u2 with(nolock)                    
                ON d.qty_uom_code_conv_to = u2.uom_code                   
             JOIN dbo.uom u3 with(nolock)                 
                ON d.sec_qty_uom_code = u3.uom_code                        
     where dist_num = (select max(dist_num)                    
                       from dbo.trade_item_dist                      
                       where trade_num = @buy_trade_num and               
                             order_num = @buy_order_num and               
                             item_num = @buy_item_num)                             
              
                                        
   set @alloc_type_code = case when @TIWP_mot_type_code = 'R' then 'R' /* railcar/railcar */                    
                               when @TIWP_mot_type_code = 'T' then 'K' /* truck/truck */                    
                               else 'W'                                /* barge/waterborne */                    
                          end                    
                    
   set @sec_uom_code = case when @TID_dist_uom_type != @TID_qty_uom_code_conv_to_type               
                               then @TID_qty_uom_code_conv_to               
      else                    
                               case when @TID_dist_uom_type != @TID_sec_qty_uom_code_type               
                                       then @TID_sec_qty_uom_code               
                                    else                    
                                       case when @TID_qty_uom_code_conv_to != @TID_qty_uom_code               
                             then @TID_qty_uom_code_conv_to                    
                                            else @TID_sec_qty_uom_code                    
                                       end                    
                               end                    
                       end                    
                    
   set @sec_uom_factor = (case when @TID_dist_uom_type != @TID_qty_uom_code_conv_to_type               
                                  then @TID_qty_uom_conv_rate               
                               else                    
                                  case when @TID_dist_uom_type != @TID_sec_qty_uom_code_type               
                                          then @TID_qty_uom_conv_rate * @TID_sec_conversion_factor               
                                       else                    
                                          case when @TID_qty_uom_code_conv_to != @TID_qty_uom_code               
                                                  then @TID_qty_uom_conv_rate                    
                                               else @TID_qty_uom_conv_rate * @TID_sec_conversion_factor                    
                                          end                    
                                  end                    
                          end)                    
                     
   /* **************************************************************** */              
   /* Getting a new alloc_num */              
   begin try                    
     update dbo.new_num               
     set last_num = last_num + 1               
           output inserted.last_num into @new_sequence_num              
     where num_col_name = 'alloc_num'               
   end try              
   begin catch              
     RAISERROR('=> Failed to update the new_num table for a new alloc_num due to the error:', 0, 1) WITH NOWAIT              
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()              
     goto endofsp                  
   end catch                         
                    
   select @alloc_num = seq_num               
   from @new_sequence_num               
                 
   if @alloc_num is null              
   begin               
      RAISERROR('=> Failed to obtain an alloc_num for new allocation!', 0, 1) WITH NOWAIT              
      set @errcode = 1                 
      goto endofsp                             
   end                         
              
   if @debugon = 1              
   begin              
      RAISERROR('DEBUG: alloc_num for new allocation is %d', 0, 1, @alloc_num) WITH NOWAIT              
   end                                
              
   /* **************************************************************** */              
   /* The following code block adds              
         1 allocation record (@alloc_num)              
    1 allocation_pl record (@alloc_num)              
         2 allocation_item records (@alloc_num/1 - Receipt)              
                                   (@alloc_num/2 - Inventory @inv_num)              
         2 allocation_item_transport records (@alloc_num/1 and @alloc_num/2)              
         4 ai_est_actual records (@alloc_num/1/0, @alloc_num/1/1)              
                                 (@alloc_num/2/0, @alloc_num/2/1)              
         x ai_est_actual_spec records              
         1 inventory record (@inv_num)              
         1 inventory_build_draw (@inv_num/@inv_b_d_num)              
   */              
                 
   /*  allocation (@alloc_num) */              
   begin try                     
     insert into dbo.allocation                    
        (alloc_num,                    
         alloc_type_code,                    
         mot_code,                    
         sch_init,                    
         alloc_status,                    
         sch_prd,                    
         creation_type,                    
         alloc_cmdty_code,                    
         alloc_match_ind,                    
         alloc_loc_code,                    
         creation_date,                    
         multiple_cmdty_ind,                    
         pay_for_del,                    
         pay_for_weight,                    
         max_alloc_item_num,                    
         trans_id)                    
      values(@alloc_num,                     
             @alloc_type_code,                      
             'STORAGE',                    
             @trader_init,                    
             'C',                    
             @TI_trading_prd,                    
             'M',                    
             @TI_cmdty_code,                    
             'Y',                    
             @TIWP_del_loc_code,                    
             getdate(),                    
             'N',                    
             'S',                    
             'S',                    
     2,                    
             @trans_id)                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new allocation record due to the error:', 0, 1) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch              
              
   if @debugon = 1              
   begin              
      if @rows_affected > 0              
         RAISERROR('DEBUG: %d new allocation record with alloc_num #%d was added successfully!', 0, 1, @rows_affected, @alloc_num) WITH NOWAIT              
      else              
         RAISERROR('DEBUG: No new allocation record was added!', 0, 1, @alloc_num) WITH NOWAIT              
   end              
                 
   set @rows_affected = 0              
   begin try                     
     insert into dbo.allocation_pl                   
        (alloc_num,                    
         trans_id)                    
      values(@alloc_num, @trans_id)                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new allocation_pl record with alloc_num #%d due to the error:', 0, 1, @alloc_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch              
              
   if @debugon = 1         
   begin              
      if @rows_affected > 0              
         RAISERROR('DEBUG: %d new allocation_pl with alloc_num #%d was added successfully!', 0, 1, @rows_affected, @alloc_num) WITH NOWAIT              
      else              
         RAISERROR('DEBUG: No new allocation_pl was added!', 0, 1, @alloc_num) WITH NOWAIT              
   end              
                 
   /* **************************************************************** */              
   /*  physical receipt allocation_item (@alloc_num/1) */              
   if @actual_date is not null set @title_transfer_date = convert(char(10), @actual_date, 111)               
   else set @title_transfer_date = convert(char(10), getdate(), 111)              
   set @rows_affected = 0                                  
   begin try                   
     insert into dbo.allocation_item                    
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
         alloc_item_confirm,                    
         alloc_item_verify,                    
         sch_qty_periodicity,                    
         actual_gross_qty,                    
         actual_gross_uom_code,                    
         fully_actualized,                    
         confirmation_date,                    
         final_dest_loc_code,                    
         max_ai_est_actual_num,                    
         secondary_actual_qty,                    
         load_port_loc_code,                    
         sec_actual_uom_code,                    
         trans_id)                    
      values(@alloc_num,                    
             1,                    
             'R',                    
             'C',                    
             0,                    
             @buy_trade_num,                    
             @buy_order_num,                    
             @buy_item_num,                    
             @TI_acct_num,                    
             @TI_cmdty_code,                    
             @storage_qty,                    
             @TI_contr_qty_uom_code,                    
             @TIWP_del_date_from,                    
             @TIWP_del_date_to,                    
             @extended_storage_qty,                    
             @TI_contr_qty_uom_code,                    
             @extended_storage_qty,                    
             @TI_contr_qty_uom_code,                    
             @TIWP_del_loc_code,                    
             @title_transfer_date,                   
    @TIWP_del_loc_code,                    
             @TIWP_del_loc_code,                    
             @TIWP_credit_term_code,                    
             @TIWP_pay_term_code,                    
             @TIWP_pay_days,                    
             @TIWP_del_term_code,                    
             'B',                    
             'Y',                    
             'Y',                    
             @TI_contr_qty_periodicity,                    
             @actual_qty,                    
             @TI_contr_qty_uom_code,                    
             'Y',                    
             getdate(),                    
             @TIWP_del_loc_code,                    
             1,           
             @actual_qty * @sec_uom_factor,                    
             @TIWP_del_loc_code,                    
             @sec_uom_code,                    
             @trans_id)                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new allocation_item record (%d/1) for RECEIPT due to the error:', 0, 1, @alloc_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch              
               
   if @debugon = 1              
   begin              
      if @rows_affected > 1              
         RAISERROR('DEBUG: %d new allocation_item record (%d/1) was added successfully', 0, 1, @rows_affected, @alloc_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new allocation_item record (%d/1) was added!', 0, 1, @alloc_num) WITH NOWAIT              
   end              
   if @actual_date is not null set @converted_actual_date = convert(char(10), @actual_date, 111)            
   else set @converted_actual_date = convert(char(10), getdate(), 111)         
   /* **************************************************************** */              
   /*  allocation_item_transport (@alloc_num/1) */              
   /*set @converted_actual_date = convert(char(10), @actual_date, 111)              
   if @event_type='B/L' set @bl_date = @converted_actual_date              
   if @event_type='NOR' set @nor_date = @converted_actual_date              
   if @event_type='COD' set @disch_cmnc_date = @converted_actual_date              
   if @event_type='COL' set @load_cmnc_date = @converted_actual_date              
   if @event_type='CMPD' set @disch_compl_date = @converted_actual_date              
   if @event_type='CMPL' set @load_compl_date = @converted_actual_date              
   if @event_type='LAYDAYS' begin set @lay_days_start_date = @converted_actual_date set @lay_days_end_date = @converted_actual_date end          
   if @event_type='ND' set @negotiated_date = @converted_actual_date    */          
          
   if @bl_date is not null  set @bl_date = convert(char(10), @bl_date, 111)          
   if @nor_date is not null set @nor_date = convert(char(10), @nor_date, 111)          
   if @disch_cmnc_date is not null set @disch_cmnc_date = convert(char(10), @disch_cmnc_date, 111)          
   if @load_cmnc_date is not null set @load_cmnc_date = convert(char(10), @load_cmnc_date, 111)          
   if @disch_compl_date is not null set @disch_compl_date = convert(char(10), @disch_compl_date, 111)          
   if @load_compl_date is not null set @load_compl_date = convert(char(10), @load_compl_date, 111)          
             
          
             
              
              
   set @rows_affected = 0                                         
   begin try                   
     insert into dbo.allocation_item_transport                    
        (alloc_num,                    
         alloc_item_num,                    
         transportation,                    
         bl_qty_uom_code,                    
         load_qty_uom_code,                    
         disch_qty_uom_code,                    
         bl_sec_qty_uom_code,                    
         load_sec_qty_uom_code,                    
         disch_sec_qty_uom_code,                    
         manual_input_sec_ind,                
bl_date,              
nor_date,              
disch_cmnc_date,              
load_cmnc_date,              
disch_compl_date,              
load_compl_date,              
lay_days_start_date,              
lay_days_end_date,              
negotiated_date,              
              
              
         trans_id)                    
      values(@alloc_num,                    
             1,                    
             @TIWP_mot_code,                    
             @TI_contr_qty_uom_code,                    
             @TI_contr_qty_uom_code,              
             @TI_contr_qty_uom_code,                    
             @sec_uom_code,                    
             @sec_uom_code,                    
   @sec_uom_code,                    
             'N',              
@bl_date,              
@nor_date,              
@disch_cmnc_date,              
@load_cmnc_date,              
@disch_compl_date,              
@load_compl_date,              
@lay_days_start_date,              
@lay_days_end_date,              
@negotiated_date,              
             @trans_id)                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new allocation_item_transport record (%d/1) due to the error:', 0, 1, @alloc_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch              
              
   if @debugon = 1              
   begin              
      if @rows_affected > 0     
         RAISERROR('DEBUG: %d new allocation_item_transport record (%d/1) was added successfully', 0, 1, @rows_affected, @alloc_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new allocation_item_transport record (%d/1) was added!', 0, 1, @alloc_num) WITH NOWAIT              
   end              
                            
   /* **************************************************************** */              
   /*  ai_est_actual (@alloc_num/1/0) */              
    set @ai_est_actual_date =  @converted_actual_date              
   set @rows_affected = 0                                  
   begin try                   
     insert into dbo.ai_est_actual                    
        (alloc_num,                    
         alloc_item_num,                    
         ai_est_actual_num,                    
         ai_est_actual_date,                    
         ai_est_actual_gross_qty,                    
         ai_gross_qty_uom_code,                    
         ai_est_actual_net_qty,                    
         ai_net_qty_uom_code,                   
         ai_est_actual_ind,                    
         ticket_num,                    
         del_loc_code,                    
         owner_code,                    
         secondary_actual_gross_qty,                    
         secondary_actual_net_qty,                    
         secondary_qty_uom_code,               
         manual_input_sec_ind,                    
         trans_id,                    
         fixed_swing_qty_ind)                    
      values(@alloc_num,                    
             1,                    
             0,                    
             @ai_est_actual_date,                    
             0.0,                    
             @TI_contr_qty_uom_code,                    
             0.0,                    
             @TI_contr_qty_uom_code,                    
             'E',                    
             convert(varchar, @alloc_num) + '-00-00',                    
             @TIWP_del_loc_code,                    
             'AIA',                    
             0.0,                    
             0.0,                    
             @sec_uom_code,                    
             'N',                    
             @trans_id,                    
             'F')                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new ai_est_actual record (%d/1/0) due to the error:', 0, 1, @alloc_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch              
              
   if @debugon = 1              
   begin              
      if @rows_affected > 0              
         RAISERROR('DEBUG: %d new ai_est_actual record (%d/1/0) was added successfully', 0, 1, @rows_affected, @alloc_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new ai_est_actual record (%d/1/0) was added!', 0, 1, @alloc_num) WITH NOWAIT              
   end              
                       
   /* **************************************************************** */           
   /*  ai_est_actual (@alloc_num/1/1) */              
   set @rows_affected = 0                                  
   begin try                   
     insert into dbo.ai_est_actual                    
        (alloc_num,                    
         alloc_item_num,                    
         ai_est_actual_num,                    
         ai_est_actual_date,                    
         ai_est_actual_gross_qty,                    
         ai_gross_qty_uom_code,                    
         ai_est_actual_net_qty,                    
         ai_net_qty_uom_code,                    
         ai_est_actual_ind,     
         ticket_num,                    
         del_loc_code,                    
         owner_code,                    
         secondary_actual_gross_qty,                    
         secondary_actual_net_qty,                    
         secondary_qty_uom_code,                    
         manual_input_sec_ind,                    
         trans_id,                    
         fixed_swing_qty_ind)                    
      select alloc_num,                    
             alloc_item_num,                    
             1,                    
             @ai_est_actual_date,                    
             @actual_qty,                    
             ai_gross_qty_uom_code,                    
             @actual_qty,                    
             ai_net_qty_uom_code,                    
             'A',                    
             convert(varchar, @alloc_num) + '-01-01',                    
             del_loc_code,                    
             owner_code,                    
             @actual_qty * @sec_uom_factor,                    
             @actual_qty * @sec_uom_factor,                    
             secondary_qty_uom_code,                
             manual_input_sec_ind,                               trans_id,                    
             fixed_swing_qty_ind                    
      from dbo.ai_est_actual                    
      where alloc_num = @alloc_num and                   
            alloc_item_num = 1 and                   
            ai_est_actual_num = 0                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new ai_est_actual record (%d/1/1) due to the error:', 0, 1, @alloc_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch              
              
   if @debugon = 1              
   begin              
      if @rows_affected > 0              
         RAISERROR('DEBUG: %d new ai_est_actual record (%d/1/1) was added successfully', 0, 1, @rows_affected, @alloc_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new ai_est_actual record (%d/1/1) was added!', 0, 1, @alloc_num) WITH NOWAIT              
   end              
              
   /* ************************************************************************************************************************ */              
   /*   INVENTORY                                                                                                              */              
   /* ************************************************************************************************************************ */              
   /* Getting a new inv_num */              
   begin try                    
     update dbo.new_num               
     set last_num = last_num + 1               
           output inserted.last_num into @new_sequence_num              
     where num_col_name = 'inv_num'               
   end try              
   begin catch              
     RAISERROR('=> Failed to update the new_num table for a new inv_num due to the error:', 0, 1) WITH NOWAIT              
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()              
     goto endofsp                  
   end catch                         
                    
   select @inv_num = seq_num               
   from @new_sequence_num               
                 
   if @inv_num is null              
   begin               
      RAISERROR('=> Failed to obtain an inv_num for new inventory!', 0, 1) WITH NOWAIT              
      set @errcode = 1                 
      goto endofsp                             
   end             
              
   if @debugon = 1              
   begin              
      RAISERROR('DEBUG: inv_num for new inventory is %d', 0, 1, @inv_num) WITH NOWAIT              
   end                                
              
   /* ******************************************* */              
   set @rows_affected = 0                   
   begin try                   
     insert into dbo.inventory                    
        (inv_num,                    
         trade_num,                    
         order_num,                    
         sale_item_num,                    
         cmdty_code,                    
         pos_num,                    
         del_loc_code,                    
         port_num,                    
         inv_bal_from_date,                    
         inv_bal_to_date,                    
         inv_open_prd_proj_qty,                    
         inv_open_prd_actual_qty,                    
         inv_adj_qty,                    
         inv_curr_proj_qty,                    
         inv_curr_actual_qty,                    
         inv_qty_uom_code,                    
         inv_cost_curr_code,                    
         inv_cost_uom_code,                    
  inv_rcpt_proj_qty,                    
         inv_rcpt_actual_qty,                    
         inv_dlvry_proj_qty,                    
         inv_dlvry_actual_qty,                    
         open_close_ind,                    
         balance_period,                    
         line_fill_qty,                    
         needs_repricing,                    
         inv_cnfrmd_qty,                    
         inv_type,                    
         trans_id,                    
         inv_open_prd_proj_sec_qty,                    
         inv_open_prd_actual_sec_qty,                    
         inv_cnfrmd_sec_qty,                    
         inv_adj_sec_qty,                    
         inv_sec_qty_uom_code,                    
         inv_curr_proj_sec_qty,                    
         inv_curr_actual_sec_qty,                    
         inv_rcpt_proj_sec_qty,                    
         inv_rcpt_actual_sec_qty,                    
         inv_dlvry_proj_sec_qty,                    
         inv_dlvry_actual_sec_qty)                    
      values(@inv_num,                    
             @TI_S_trade_num,                    
             @TI_S_order_num,                    
             @TI_S_item_num,                    
    @TI_S_cmdty_code,                    
             0,                    
             @TIWP_del_loc_code,                    
             @TI_S_real_port_num,                    
             @TIWP_del_date_from,                    
             @TIWP_del_date_to,                    
             0.0,                    
             0.0,                    
             0.0,                    
             0.0,                    
             @extended_storage_qty,                    
             @TI_contr_qty_uom_code,                    
             @TI_desired_pl_curr_code,                    
             @TI_price_uom_code,                    
             0.0,                    
             0.0,                    
             0.0,                    
             @extended_storage_qty,                    
             'O',                    
             @TI_S_trading_prd,                    
             0,                    
             'Y',                    
             @extended_storage_qty,                    
             'S',                    
             @trans_id,                    
             0.0,                    
             0.0,                    
             @extended_storage_qty * @sec_uom_factor,                    
             0.0,                    
             @sec_uom_code,                    
             0.0,                    
             @extended_storage_qty * @sec_uom_factor,                    
             0.0,                    
             0.0,                    
             0.0,                   
             @extended_storage_qty * @sec_uom_factor)           
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new inventory record (%d) due to the error:', 0, 1, @inv_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch               
              
   if @debugon = 1              
   begin              
      if @rows_affected > 0              
         RAISERROR('DEBUG: %d new inventory record (%d) was added successfully', 0, 1, @rows_affected, @inv_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new inventory record (%d) was added!', 0, 1, @inv_num) WITH NOWAIT              
   end              
                    
   /* ***************************************************************************************** */              
   /*  inventory side allocation_item (@alloc_num/2) */     
   /* I#ADSO-3843 fix-- update the @TI_acct_num to storage trade account for the below insert */  
  
select @TI_acct_num = acct_num from trade where trade_num=@TI_S_trade_num     
   set @rows_affected = 0                   
   begin try                   
     insert into dbo.allocation_item                    
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
         alloc_item_confirm,                    
         alloc_item_verify,                    
         sch_qty_periodicity,                    
         actual_gross_qty,                    
         actual_gross_uom_code,                    
         fully_actualized,                    
         inv_num,                    
         confirmation_date,                    
         final_dest_loc_code,                    
         max_ai_est_actual_num,                    
         secondary_actual_qty,                    
         load_port_loc_code,                    
         sec_actual_uom_code,                    
         trans_id)                    
      values(@alloc_num,                    
             2,                    
             'C',                    
             'C',                    
             0,                    
             @TI_S_trade_num,                    
             @TI_S_order_num,                    
             @TI_S_item_num,                    
             @TI_acct_num,                    
             @TI_cmdty_code,                    
             0.0,                    
             @TI_contr_qty_uom_code,                    
             @TIWP_del_date_from,                    
             @TIWP_del_date_to,                    
             @extended_storage_qty,                    
             @TI_contr_qty_uom_code,                    
             @extended_storage_qty,                    
             @TI_contr_qty_uom_code,                    
             @TIWP_del_loc_code,                    
             @title_transfer_date,                   
             @TIWP_del_loc_code,                    
             @TIWP_del_loc_code,                    
             @TIWP_credit_term_code,                    
             @TIWP_pay_term_code,                    
             @TIWP_pay_days,                    
             null,                    
             'B',                    
             'Y',             
             'Y',                    
             'L',                    
             @actual_qty,                    
             @TI_contr_qty_uom_code,                    
             'Y',                    
             @inv_num,                    
             getdate(),                    
             @TIWP_del_loc_code,                    
             1,                    
             @actual_qty * @sec_uom_factor,                    
             @TIWP_del_loc_code,                    
             @sec_uom_code,                    
             @trans_id)                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new allocation_item record (%d/2) due to the error:', 0, 1, @alloc_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch                    
              
   if @debugon = 1              
   begin              
      if @rows_affected > 0              
         RAISERROR('DEBUG: %d new allocation_item record (%d/2 - inv_num #%d) was added successfully', 0, 1, @rows_affected, @alloc_num, @inv_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new allocation_item record (%d/2 - inv_num #%d) was added!', 0, 1, @alloc_num, @inv_num) WITH NOWAIT              
   end              
                       
   /* ********************************************************************** */              
   /*  allocation_item_transport (@alloc_num/2) */               
   set @rows_affected = 0                   
   begin try                   
     insert into dbo.allocation_item_transport                      (alloc_num,                    
         alloc_item_num,                    
         transportation,                    
         bl_qty_uom_code,                    
         load_qty_uom_code,                    
         disch_qty_uom_code,                    
         bl_sec_qty_uom_code,                    
         load_sec_qty_uom_code,                    
         disch_sec_qty_uom_code,                    
         manual_input_sec_ind,                
bl_date,              
nor_date,              
disch_cmnc_date,              
load_cmnc_date,              
disch_compl_date,              
load_compl_date,              
lay_days_start_date,              
lay_days_end_date,              
negotiated_date,              
         trans_id)                    
      values(@alloc_num,                    
             2,                    
             'STORAGE',                    
             @TI_contr_qty_uom_code,                    
             @TI_contr_qty_uom_code,                    
             @TI_contr_qty_uom_code,                    
             @sec_uom_code,                    
             @sec_uom_code,                    
             @sec_uom_code,                    
             'N',               
@bl_date,              
@nor_date,              
@disch_cmnc_date,              
@load_cmnc_date,              
@disch_compl_date,              
@load_compl_date,              
@lay_days_start_date,              
@lay_days_end_date,              
@negotiated_date,              
             @trans_id)                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new allocation_item_transport record (%d/2) due to the error:', 0, 1, @alloc_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch              
              
   if @debugon = 1              
   begin              
      if @rows_affected > 0              
         RAISERROR('DEBUG: %d new allocation_item_transport record (%d/2) was added successfully', 0, 1, @rows_affected, @alloc_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new allocation_item_transport record (%d/2) was added!', 0, 1, @alloc_num) WITH NOWAIT              
   end              
                       
   /* ********************************************************************** */              
   /*  ai_est_actual (@alloc_num/2/0) */                 
   set @rows_affected = 0                   
   begin try                   
     insert into dbo.ai_est_actual                    
        (alloc_num,               
         alloc_item_num,                    
         ai_est_actual_num,                    
         ai_est_actual_date,                    
         ai_est_actual_gross_qty,                    
         ai_gross_qty_uom_code,                    
         ai_est_actual_net_qty,                    
         ai_net_qty_uom_code,                    
         ai_est_actual_ind,                    
         ticket_num,                    
         del_loc_code,                    
         owner_code,                    
         secondary_actual_gross_qty,                    
         secondary_actual_net_qty,                    
         secondary_qty_uom_code,                    
         manual_input_sec_ind,                    
         trans_id,                    
         fixed_swing_qty_ind)                 
      values(@alloc_num,                    
             2,                    
             0,                    
             @ai_est_actual_date,                    
             0.0,                    
             @TI_contr_qty_uom_code,                    
             0.0,                    
             @TI_contr_qty_uom_code,                    
             'E',                    
             convert(varchar, @alloc_num) + '-00-00',                    
             @TIWP_del_loc_code,                    
             'AIA',                    
             0.0,                    
             0.0,                    
             @sec_uom_code,                    
             'N',                    
             @trans_id,                    
             'F')                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     if @@trancount > 0              
        rollback tran              
     RAISERROR('=> Failed to add a new ai_est_actual record (%d/2/0) due to the error:', 0, 1, @alloc_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch              
              
   if @debugon = 1              
   begin              
      if @rows_affected > 0              
         RAISERROR('DEBUG: %d new ai_est_actual record (%d/2/0) was added successfully', 0, 1, @rows_affected, @alloc_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new ai_est_actual record (%d/2/0) was added!', 0, 1, @alloc_num) WITH NOWAIT              
   end              
                 
   /* ********************************************************************** */       
   /*  ai_est_actual (@alloc_num/2/1) */                 
   set @rows_affected = 0            begin try                   
     insert into dbo.ai_est_actual                    
        (alloc_num,                    
         alloc_item_num,                    
         ai_est_actual_num,                    
         ai_est_actual_date,                    
         ai_est_actual_gross_qty,                    
         ai_gross_qty_uom_code,                    
         ai_est_actual_net_qty,                    
         ai_net_qty_uom_code,                    
         ai_est_actual_ind,                    
         ticket_num,                    
         del_loc_code,                    
         owner_code,                    
         secondary_actual_gross_qty,                    
         secondary_actual_net_qty,                    
         secondary_qty_uom_code,                    
         manual_input_sec_ind,                    
         trans_id,                    
         fixed_swing_qty_ind)                    
      select alloc_num,                    
             alloc_item_num,                    
             1,                    
             @ai_est_actual_date,                    
             @actual_qty,                    
             ai_gross_qty_uom_code,                    
      @actual_qty,                    
             ai_net_qty_uom_code,                    
             'A',                    
             convert(varchar, @alloc_num) + '-01-01',                    
          del_loc_code,                    
             owner_code,                    
             @actual_qty * @sec_uom_factor,                    
             @actual_qty * @sec_uom_factor,                    
             secondary_qty_uom_code,                    
             manual_input_sec_ind,                    
             trans_id,                 
             fixed_swing_qty_ind                    
      from dbo.ai_est_actual                    
      where alloc_num = @alloc_num and               
            alloc_item_num = 2 and               
            ai_est_actual_num = 0                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new ai_est_actual record (%d/2/1) due to the error:', 0, 1, @alloc_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch              
              
   if @debugon = 1              
   begin              
      if @rows_affected > 0              
         RAISERROR('DEBUG: %d new ai_est_actual record (%d/2/1) was added successfully', 0, 1, @rows_affected, @alloc_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new ai_est_actual record (%d/2/1) was added!', 0, 1, @alloc_num) WITH NOWAIT              
   end              
                                       
   /* ********************************************************************** */              
   /* ai_est_actual_spec */                    
   set @rows_affected = 0                   
   begin try                   
     insert into dbo.ai_est_actual_spec                    
       (alloc_num,                    
        alloc_item_num,                    
        ai_est_actual_num,                    
        spec_code,                    
        spec_actual_value,                    
        trans_id)                    
     select a.alloc_num,                    
             a.alloc_item_num,                    
             a.ai_est_actual_num,                    
             s.spec_code,                    
             s.spec_typical_val,                    
             @trans_id                    
      from dbo.ai_est_actual a,                    
           dbo.trade_item_spec s                
      where a.alloc_num = @alloc_num and                    
            s.trade_num = @buy_trade_num and                   
            s.order_num = @buy_order_num and                   
            s.item_num = @buy_item_num and                   
            s.spec_typical_val is not null                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new ai_est_actual_spec record due to the error:', 0, 1) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch              
              
   if @debugon = 1              
   begin              
      if @rows_affected > 1              
         RAISERROR('DEBUG: %d new ai_est_actual_spec records (%d/%d/%d - alloc_num #%d) were added successfully', 0, 1, @rows_affected, @buy_trade_num, @buy_order_num, @buy_item_num, @alloc_num) WITH NOWAIT                
      else if @rows_affected = 1              
         RAISERROR('DEBUG: 1 new ai_est_actual_spec record (%d/%d/%d - alloc_num #%d) was added successfully', 0, 1, @buy_trade_num, @buy_order_num, @buy_item_num, @alloc_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new ai_est_actual_spec record (%d/%d/%d - alloc_num #%d) was added!', 0, 1, @buy_trade_num, @buy_order_num, @buy_item_num, @alloc_num) WITH NOWAIT              
   end              
                  
   /* ****************************************************************************************************** */              
   /* Getting a new inv_b_d_num */              
   delete from @new_sequence_num              
   begin try                    
     update dbo.new_num               
     set last_num = last_num + 1               
            output inserted.last_num into @new_sequence_num              
     where num_col_name = 'inv_b_d_num'               
   end try              
   begin catch              
     RAISERROR('=> Failed to update the new_num table for a new inv_b_d_num due to the error:', 0, 1) WITH NOWAIT              
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                 
     goto endofsp                  
   end catch                         
                    
   select @inv_b_d_num = seq_num               
   from @new_sequence_num               
                 
   if @inv_b_d_num is null              
   begin               
     RAISERROR('=> Failed to obtain a new inv_b_d_num for new inventory_build_draw due to the error:', 0, 1) WITH NOWAIT              
     set @errcode = 1                 
     goto endofsp                             
   end                           
              
   if @debugon = 1              
   begin              
      RAISERROR('DEBUG: inv_b_d_num for new inventory_build_draw is %d', 0, 1, @inv_b_d_num) WITH NOWAIT              
   end                                
              
   /* ************************************ */                             
   set @rows_affected = 0                   
   begin try                   
     insert into dbo.inventory_build_draw                    
        (inv_num,                    
         inv_b_d_num,                    
         inv_b_d_type,                    
         inv_b_d_status,                    
         trade_num,                    
         order_num,                    
         item_num,                    
         alloc_num,                    
    alloc_item_num,                    
         inv_b_d_qty,                    
         inv_b_d_cost_curr_code,                    
         inv_b_d_cost_uom_code,     
  associated_trade,    
         trans_id)                    
      values(@inv_num,                    
         @inv_b_d_num,                    
             'B',                    
             'I',                    
             @TI_S_trade_num,                    
             @TI_S_order_num,                    
             @TI_S_item_num,                    
             @alloc_num,                    
             2,                    
             @extended_storage_qty,                    
             @TI_price_curr_code,                    
             @TI_price_uom_code,    
      convert(varchar, @buy_trade_num )+ '/'+  convert(varchar, @buy_order_num) + '/' + convert(varchar, @buy_item_num),    
             @trans_id)                    
     set @rows_affected = @@rowcount                   
   end try              
   begin catch              
     RAISERROR('=> Failed to add a new inventory_build_draw record (%d) due to the error:', 0, 1, @inv_b_d_num) WITH NOWAIT                
     set @errmsg = ERROR_MESSAGE()              
     RAISERROR('==> ERROR: %s', 0, 1, @errmsg) WITH NOWAIT                
     set @errcode = ERROR_NUMBER()                    
     goto endofsp                                 
   end catch                     
              
   if @debugon = 1              
   begin              
      if @rows_affected > 0              
         RAISERROR('DEBUG: %d new inventory_build_draw record (%d) was added successfully', 0, 1, @rows_affected, @inv_b_d_num) WITH NOWAIT                
      else              
         RAISERROR('DEBUG: No new inventory_build_draw record (%d) was added!', 0, 1, @inv_b_d_num) WITH NOWAIT              
   end              
  exec @status = dbo.usp_add_shipment_4_storage_trade @alloc_num,      
                                                       @trans_id,      
                                                       @debugon      
   return @status      
      
                   
endofsp:              
if @errcode > 0              
   return 1              
return 0     
GO
GRANT EXECUTE ON  [dbo].[usp_add_allocation_4_storage_trade] TO [next_usr]
GO
