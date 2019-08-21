SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_add_DUMMY_commodity_data]
(
   @cmdty_code   char(8)  output
)
as
set nocount on
set xact_abort on
declare @trans_id            int,
        @rows_affected       int,
        @mkt_code            varchar(8),        
        @commkt_key          int,        
        @temp_cmdty_code     varchar(8),        
        @temp_mkt_code       varchar(8),        
        @temp_commkt_key     int,        
        @status              int

   set @status = 0
   set @cmdty_code = 'DUMMY'

   if exists (select 1
              from dbo.commodity
              where cmdty_code = @cmdty_code)
      goto endofsp
   
   begin try
     exec dbo.gen_new_transaction_NOI @app_name = 'adddummycmdty_1337466'
   end try
   begin catch
     print '=> Failed to execute the ''gen_new_transaction_NOI'' stored procedure to create an icts_transaction record due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit
   end catch
  
   select @trans_id = last_num 
   from dbo.icts_trans_sequence
   where oid = 1

   if @trans_id is null
   begin
      print '=> Unable to obtain a valid trans_id for insertion!'
      goto errexit
   end

   set @mkt_code = 'DUMMY'
   set @commkt_key = null
   
   set @temp_cmdty_code = null
   set @temp_mkt_code = null
   set @temp_commkt_key = null

   -- Let's see if we can find cmdty_code 'WTI' in database
   -- If the cmdty_code 'WTI' exists, then we will use the WTI as a template
   -- record for adding DUMMY commodity
   set @temp_cmdty_code = (select cmdty_code
                           from dbo.commodity
                           where cmdty_code = 'WTI')
   
   if @temp_cmdty_code is null
      set @temp_cmdty_code = (select top 1 cmdty_code
                              from dbo.commodity
                              where cmdty_tradeable_ind = 'Y' and
                                    cmdty_type = 'P' and
                                    cmdty_status = 'A')
   
   if @temp_cmdty_code is null
   begin
      print '=> Could not find a template commodity record!'
      goto errexit
   end
                                    
   set @temp_mkt_code = (select top 1 mkt_code
                         from dbo.commodity_market
                         where cmdty_code = @temp_cmdty_code)

   if @temp_mkt_code is null
   begin
      print '=> Could not find a template market record!'
      goto errexit
   end

   set @temp_commkt_key = (select commkt_key
                           from dbo.commodity_market
                           where cmdty_code = @temp_cmdty_code and
                                 mkt_code = @temp_mkt_code)

   if @temp_commkt_key is null
   begin
      print '=> Could not find a template commodity_market record!'
      goto errexit
   end
                        
   begin tran
   begin try               
     insert into dbo.commodity
          (cmdty_code,
           cmdty_tradeable_ind,
           cmdty_type,
           cmdty_status,
           cmdty_short_name,
           cmdty_full_name,
           country_code,
           cmdty_loc_desc,
           prim_curr_code,
           prim_curr_conv_rate,
           prim_uom_code,
           sec_uom_code,
           cmdty_category_code,
           trans_id)
        select 
           @cmdty_code,
           'N',
           'P',
           'A',
           'DUMMYCMDTY',
           'DUMMY COMMODITY',
           country_code,
           cmdty_loc_desc,
           prim_curr_code,
           prim_curr_conv_rate,
           prim_uom_code,
           sec_uom_code,
           cmdty_category_code,
           @trans_id
        from dbo.commodity
        where cmdty_code = @temp_cmdty_code   
     set @rows_affected = @@rowcount   
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add DUMMY commodity record due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit     
   end catch
   if @rows_affected > 0
      print '=> DUMMY commodity record was added successfuly!'
   else
      print '=> DUMMY commodity record was NOT added ????'

   begin try
     insert into dbo.commodity_specification 
          (cmdty_code,
           spec_code,
           spec_type,   
           trans_id,
           standard_ind)
       select 
          @cmdty_code,
          spec_code,
          spec_type,   
          @trans_id,
          standard_ind
       from dbo.commodity_specification 
       where cmdty_code = @temp_cmdty_code
     set @rows_affected = @@rowcount   
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add commodity_specification records for DUMMY commodity due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit     
   end catch
   if @rows_affected > 0
      print '=> New commodity_specification records for the DUMMY commodity were added successfuly!'
   else
      print '=> No commodity_specification records for the DUMMY commodity were added ????'

   begin try
     insert into dbo.commodity_uom 
          (cmdty_code,
           cmdty_uom_for,
           uom_code,
           trans_id)
       select 
          @cmdty_code,
          cmdty_uom_for,
          uom_code,
          @trans_id
       from dbo.commodity_uom 
       where cmdty_code = @temp_cmdty_code
     set @rows_affected = @@rowcount   
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add commodity_uom records for DUMMY commodity due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit     
   end catch
   if @rows_affected > 0
      print '=> New commodity_uom records for the DUMMY commodity were added successfuly!'
   else
      print '=> No commodity_uom records for the DUMMY commodity were added ????'
   commit tran
               
   begin tran
   begin try
     insert into dbo.market 
          (mkt_code,
           mkt_type,
           mkt_status,
           mkt_short_name,
           mkt_full_name,
           trans_id)
       select
           @mkt_code,
           mkt_type,
           'A', 
           'DUMMY MKT',
           'DUMMY MARKET',
           @trans_id
       from dbo.market
       where mkt_code = @temp_mkt_code
     set @rows_affected = @@rowcount   
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add a market record for DUMMY market due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit     
   end catch
   if @rows_affected > 0
      print '=> A new market record for the DUMMY markety was added successfuly!'
   else
      print '=> No new market record for the DUMMY market was added ????'
   commit tran

   /* ******************************************************************** */
   /* COMMODITY_MARKET DATA */
   
   begin tran
   select @commkt_key = max(commkt_key)
   from dbo.commodity_market
   
   if @commkt_key is null
      set @commkt_key = 0
      
   set @commkt_key = @commkt_key + 1
   begin try
     insert into dbo.commodity_market 
           (commkt_key,
            mkt_code,
            cmdty_code,
            mtm_price_source_code,
            dflt_opt_eval_method,
            trans_id,
            man_input_sec_qty_required)
       select 
          @commkt_key,
          @cmdty_code,
          @mkt_code,
          mtm_price_source_code,
          dflt_opt_eval_method,
          @trans_id,
          man_input_sec_qty_required
       from dbo.commodity_market 
       where commkt_key = @temp_commkt_key  
     select @rows_affected = @@rowcount                
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add a commodity_market record for DUMMY commodity due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit     
   end catch   
   if @rows_affected > 0
      print '=> A new commodity_market record for the DUMMY commodity was added successfuly!'
   else
      print '=> No commodity_market record for the DUMMY commodity was added ????'

   begin try
     insert into dbo.commkt_future_attr 
          (commkt_key,
           commkt_fut_attr_status,
           commkt_lot_size,
           commkt_lot_uom_code,
           commkt_price_uom_code,
           commkt_settlement_ind,
           commkt_curr_code,
           commkt_price_fmt,
           commkt_trading_mth_ind,
           commkt_nearby_mask,
           commkt_min_price_var,
           commkt_max_price_var,
           commkt_spot_prd,
           commkt_price_freq,
           commkt_price_freq_as_of,
           commkt_price_series,
           commkt_spot_mth_qty,
           commkt_fwd_mth_qty,
           commkt_total_open_qty,
           commkt_formula_type,
           commkt_interpol_type,
           commkt_num_mth_out,
           commkt_support_price_type,
           commkt_same_as_mkt_code,
           commkt_same_as_cmdty_code,
           commkt_forex_mkt_code,
           commkt_forex_cmdty_code,
           commkt_price_div_mul_ind,
           user_init,
           commkt_limit_move_ind,
           commkt_point_conv_num,
           sec_price_source_code,
           sec_alias_source_code,
           trans_id)
       select
           @commkt_key,
           commkt_fut_attr_status,
           commkt_lot_size,
           commkt_lot_uom_code,
           commkt_price_uom_code,
           commkt_settlement_ind,
           commkt_curr_code,
           commkt_price_fmt,
           commkt_trading_mth_ind,
           commkt_nearby_mask,
           commkt_min_price_var,
           commkt_max_price_var,
           commkt_spot_prd,
           commkt_price_freq,
           commkt_price_freq_as_of,
           commkt_price_series,
           commkt_spot_mth_qty,
           commkt_fwd_mth_qty,
           commkt_total_open_qty,
           commkt_formula_type,
           commkt_interpol_type,
           commkt_num_mth_out,
           commkt_support_price_type,
           commkt_same_as_mkt_code,
           commkt_same_as_cmdty_code,
           commkt_forex_mkt_code,
           commkt_forex_cmdty_code,
           commkt_price_div_mul_ind,
           user_init,
           commkt_limit_move_ind,
           commkt_point_conv_num,
           sec_price_source_code,
           sec_alias_source_code,
           @trans_id
        from dbo.commkt_future_attr
        where commkt_key = @temp_commkt_key
     select @rows_affected = @@rowcount                
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add a commkt_future_attr record for DUMMY commodity due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit     
   end catch   
   if @rows_affected > 0
      print '=> A new commkt_future_attr record for the DUMMY commodity was added successfuly!'
   else
      print '=> No commkt_future_attr record for the DUMMY commodity was added ????'

   begin try
     insert into dbo.commkt_option_attr 
          (commkt_key,
           commkt_opt_attr_status,
           commkt_lot_size,
           commkt_lot_uom_code,
           commkt_price_uom_code,
           commkt_settlement_ind,
           commkt_curr_code,
           commkt_price_fmt,
           commkt_trading_mth_ind,
           commkt_nearby_mask,
           commkt_min_price_var,
           commkt_max_price_var,
           commkt_spot_prd,
           commkt_price_freq,
           commkt_price_freq_as_of,
           commkt_price_series,
           commkt_spot_mth_qty,
           commkt_fwd_mth_qty,
           commkt_total_open_qty,
           commkt_opt_type,
           commkt_opt_exp_time,
           commkt_opt_exp_zone,
           commkt_formula_type,
           commkt_interpol_type,
           commkt_num_mth_out,
           commkt_support_price_type,
           commkt_same_as_mkt_code,
           commkt_same_as_cmdty_code,
           commkt_forex_mkt_code,
           commkt_forex_cmdty_code,
           commkt_price_div_mul_ind,
           user_init,
           commkt_point_conv_num,
           sec_price_source_code,
           sec_alias_source_code,
           trans_id,
           margin_type)
       select 
          @commkt_key,
          commkt_opt_attr_status,
          commkt_lot_size,
          commkt_lot_uom_code,
          commkt_price_uom_code,
          commkt_settlement_ind,
          commkt_curr_code,
          commkt_price_fmt,
          commkt_trading_mth_ind,
          commkt_nearby_mask,
          commkt_min_price_var,
          commkt_max_price_var,
          commkt_spot_prd,
          commkt_price_freq,
          commkt_price_freq_as_of,
          commkt_price_series,
          commkt_spot_mth_qty,
          commkt_fwd_mth_qty,
          commkt_total_open_qty,
          commkt_opt_type,
          commkt_opt_exp_time,
          commkt_opt_exp_zone,
          commkt_formula_type,
          commkt_interpol_type,
          commkt_num_mth_out,
          commkt_support_price_type,
          commkt_same_as_mkt_code,
          commkt_same_as_cmdty_code,
          commkt_forex_mkt_code,
          commkt_forex_cmdty_code,
          commkt_price_div_mul_ind,
          user_init,
          commkt_point_conv_num,
          sec_price_source_code,
          sec_alias_source_code,
          @trans_id,
          margin_type
       from dbo.commkt_option_attr
       where commkt_key = @temp_commkt_key
     select @rows_affected = @@rowcount                
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add a commkt_option_attr record for DUMMY commodity due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit     
   end catch   
   if @rows_affected > 0
      print '=> A new commkt_option_attr record for the DUMMY commodity was added successfuly!'
   else
      print '=> No commkt_option_attr record for the DUMMY commodity was added ????'
       
   begin try
     insert into dbo.commkt_physical_attr 
          (commkt_key,
           commkt_phy_attr_status,
           commkt_dflt_qty,
           commkt_qty_uom_code,
           commkt_price_uom_code,
           commkt_curr_code,
           commkt_price_fmt,
           commkt_min_price_var,
           commkt_max_price_var,
           commkt_spot_prd,
           commkt_price_freq,
           commkt_price_freq_as_of,
           commkt_price_series,
           commkt_formula_type,
           commkt_interpol_type,
           commkt_num_mth_out,
           commkt_support_price_type,
           commkt_same_as_mkt_code,
           commkt_same_as_cmdty_code,
           commkt_forex_mkt_code,
           commkt_forex_cmdty_code,
           commkt_price_div_mul_ind,
           user_init,
           commkt_point_conv_num,
           sec_price_source_code,
           sec_alias_source_code,
           trans_id)
       select
           @commkt_key,
           commkt_phy_attr_status,
           commkt_dflt_qty,
           commkt_qty_uom_code,
           commkt_price_uom_code,
           commkt_curr_code,
           commkt_price_fmt,
           commkt_min_price_var,
           commkt_max_price_var,
           commkt_spot_prd,
           commkt_price_freq,
           commkt_price_freq_as_of,
           commkt_price_series,
           commkt_formula_type,
           commkt_interpol_type,
           commkt_num_mth_out,
           commkt_support_price_type,
           commkt_same_as_mkt_code,
           commkt_same_as_cmdty_code,
           commkt_forex_mkt_code,
           commkt_forex_cmdty_code,
           commkt_price_div_mul_ind,
           user_init,
           commkt_point_conv_num,
           sec_price_source_code,
           sec_alias_source_code,
           @trans_id       
       from dbo.commkt_physical_attr
       where commkt_key = @temp_commkt_key
     select @rows_affected = @@rowcount                
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add a commkt_physical_attr record for DUMMY commodity due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit     
   end catch   
   if @rows_affected > 0
      print '=> A new commkt_physical_attr record for the DUMMY commodity was added successfuly!'
   else
      print '=> No commkt_physical_attr record for the DUMMY commodity was added ????'

   begin try
     insert into dbo.commodity_market_source 
          (commkt_key,
           price_source_code,
           dflt_alias_source_code,
           calendar_code,
           tvm_use_ind,
           option_eval_use_ind,
           financial_borrow_use_ind,
           financial_lend_use_ind,
           quote_price_precision,
           trans_id)
       select 
          @commkt_key,
          price_source_code,
          dflt_alias_source_code,
          calendar_code,
          tvm_use_ind,
          option_eval_use_ind,
          financial_borrow_use_ind,
          financial_lend_use_ind,
          quote_price_precision,
          @trans_id
       from dbo.commodity_market_source
       where commkt_key = @temp_commkt_key
     select @rows_affected = @@rowcount                
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add commodity_market_source records for DUMMY commodity due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit     
   end catch   
   if @rows_affected > 0
      print '=> New commodity_market_source records for the DUMMY commodity were added successfuly!'
   else
      print '=> No commodity_market_source records for the DUMMY commodity were added ????'

   begin try
     insert into dbo.trading_period 
          (commkt_key,
           trading_prd,
           last_trade_date,
           opt_exp_date,
           first_del_date,
           last_del_date,
           first_issue_date,
           last_issue_date,
           last_quote_date,
           trading_prd_desc,
           opt_eval_method,
           trans_id)
       select
           @commkt_key,
           trading_prd,
           last_trade_date,
           opt_exp_date,
           first_del_date,
           last_del_date,
           first_issue_date,
           last_issue_date,
           last_quote_date,
           trading_prd_desc,
           opt_eval_method,
           @trans_id
       from dbo.trading_period
       where commkt_key = @temp_commkt_key
     select @rows_affected = @@rowcount                
   end try
   begin catch
     if @@trancount > 0
        rollback tran
     print '=> Failed to add trading_period records for DUMMY commodity due to the error:'
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto errexit     
   end catch   
   if @rows_affected > 0
      print '=> New trading_period records for the DUMMY commodity were added successfuly!'
   else
      print '=> No trading_period records for the DUMMY commodity were added ????'               
   commit tran      
   goto endofsp
  
errexit:
   set @status = 1

endofsp:
exec dbo.refresh_a_last_num 'commodity_market', 'commkt_key'
return @status  
GO
GRANT EXECUTE ON  [dbo].[usp_add_DUMMY_commodity_data] TO [next_usr]
GO
