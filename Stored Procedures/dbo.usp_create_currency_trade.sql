SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_create_currency_trade]              
(              
 @trader_init char(8) = null,              
 @contr_date datetime = null,              
 @acct_num int = 0,              
 @fxtrade_num int = 0,              
 @ps_ind  char(1) = null,              
 @deal_amt float,              
 @deal_curr char(8),              
 @avg_price float,              
 @real_port_num int = 0,              
 @payment_date datetime = null,              
 @spot_rate float,              
 @contr_amt float,              
 @currpair_str varchar(255) = null,            
 @ndf_ind char(1) = null,            
 @short_comment varchar(254) = null,            
 @debugon         bit = 0               
)              
as              
set nocount on              
declare @my_trade_num int,              
  @my_trans_id bigint,               
  @my_trader_init char(8),              
  @my_contr_date datetime,              
  @my_acct_num int,              
  @my_cmnt_num int,              
  @my_fxtrade_num varchar(30),              
  @my_currpair_str varchar(255),              
  @my_ps_ind char(1),              
  @my_bookcomp_num int,              
  @my_cmdty_code char(8),              
  @my_mkt_code char(8),              
  @my_deal_amt float,              
  @my_deal_curr char(8),              
  @my_avg_price float,              
  @my_real_port_num int,              
  @my_payment_date datetime,              
  @my_spot_rate float,              
  @my_contr_amt float,              
  @my_paycurr_amt float,              
  @my_reccurr_amt float,              
  @my_temp_curr char(8),              
  @my_pay_curr    char(8),              
  @my_rec_curr   char(8),            
  @my_ndf_ind char(1),            
  @my_fx_contract_code varchar(20),            
  @my_ndf_trade_num int,             
  @my_short_comment varchar(254)            
              
--Add all parameter validations here              
              
 set @my_trader_init=@trader_init              
 set @my_contr_date=@contr_date              
 set @my_acct_num=@acct_num              
 set @my_fxtrade_num=@fxtrade_num              
 set @my_ps_ind=@ps_ind              
 set @my_deal_amt=@deal_amt              
 set @my_deal_curr=@deal_curr              
 set @my_avg_price=@avg_price              
 set @my_real_port_num=@real_port_num              
 set @my_payment_date=@payment_date              
 set @my_spot_rate=@spot_rate              
 set @my_contr_amt=@contr_amt              
 set @my_currpair_str=@currpair_str              
 set @my_short_comment=@short_comment              
 set @my_ndf_ind='N'            
 set @my_ndf_trade_num=-1            
         
 --Added logic by Subu on Jan 4th 2013 to convert CNY NDF currency deals to CNYNDF commodity          
 if exists (select 1 from Mercuria_RefData..fxall where user_field_11_value='NDF' and dealCurrency='CNY' and currencyPair='USD.CNY' and blockTicketId=@fxtrade_num and @contr_date=tradeDate and status<>'COMPLETED' )          
 SELECT @my_temp_curr='CNYNDF'         
 else          
  select @my_temp_curr=cmdty_code from commodity c where c.cmdty_code=@my_deal_curr and c.cmdty_type='C' and cmdty_status='A'              
      
      
              
 if @my_temp_curr is null              
 select @my_temp_curr=cmdty_code              
 from commodity_alias ca              
 where   alias_source_code='ISO' and              
  cmdty_alias_name=@my_deal_curr              
              
 if @my_temp_curr is null              
 begin              
  SELECT 'Unable to find commodity entry or commodity_alias entry for deal currency '+@my_deal_curr              
  goto endofsp              
 end              
          
--Added logic by Subu on Jan 4th 2013 to convert CNY NDF currency deals to CNYNDF commodity          
 if exists (select 1 from Mercuria_RefData..fxall where user_field_11_value='NDF' and dealCurrency='CNY' and currencyPair='USD.CNY' and blockTicketId=@fxtrade_num and @contr_date=tradeDate and status<>'COMPLETED' )          
 SELECT @my_cmdty_code='CNYNDF' ,@my_mkt_code='USD'          
 else          
  select @my_cmdty_code=cmdty_code,@my_mkt_code=mkt_code              
  from commodity_market cm              
  join commodity_market_alias cma on cma.commkt_key=cm.commkt_key              
  where alias_source_code='FXALL' and commkt_alias_name=@my_currpair_str              
              
    --If alias is not found then try flipping the currency code and check the alias.              
 if @my_cmdty_code is null or @my_mkt_code is null              
 begin              
  select @my_cmdty_code=cmdty_code,@my_mkt_code=mkt_code              
  from commodity_market cm              
  join commodity_market_alias cma on cma.commkt_key=cm.commkt_key              
  where alias_source_code='FXALL' and               
     commkt_alias_name in (substring(@my_currpair_str,charindex('.',@my_currpair_str)+1,len(@my_currpair_str)-charindex('.',@my_currpair_str))+'.'+substring(@my_currpair_str,1,charindex('.',@my_currpair_str)-1))              
 end              
              
 if @my_cmdty_code is null or @my_mkt_code is null              
 begin              
  SELECT 'Unable to find commodity market alias for currency pairs : '+@my_currpair_str+' or '+ (substring(@my_currpair_str,charindex('.',@my_currpair_str)+1,len(@my_currpair_str)-charindex('.',@my_currpair_str))+'.'+substring(@my_currpair_str,1,charindex('.',@my_currpair_str)-1))              
  goto endofsp              
 end              
              
 if not (@my_cmdty_code=@my_temp_curr or @my_mkt_code=@my_temp_curr)              
 begin              
  SELECT 'Unable to match for deal currency '+rtrim(@my_temp_curr)+' with symphony''s currency pair '+rtrim(@my_cmdty_code)+'.'+rtrim(@my_mkt_code)              
  goto endofsp              
 end              
              
 select @my_bookcomp_num=target_key1               
 from entity_tag               
 where entity_tag_id in (select oid from entity_tag_definition where entity_tag_name='BOOKCOMP')               
    and key1=convert(varchar,@my_real_port_num)              
              
 if @my_bookcomp_num is null              
 begin              
  SELECT 'Failed to get booking company number from portfolio tag for portfolio : '+convert(varchar,@my_real_port_num)              
  goto endofsp              
 end              
              
    if(@my_ps_ind = 'S')                  
  begin              
   SET @my_paycurr_amt=@my_deal_amt                 
   SET @my_pay_curr=@my_temp_curr              
   SET @my_reccurr_amt=@my_contr_amt                 
   SET @my_rec_curr=case when @my_cmdty_code=@my_temp_curr then @my_mkt_code when @my_mkt_code=@my_temp_curr then @my_cmdty_code              
        end              
  end              
 else              
  begin              
   SET @my_paycurr_amt=@my_contr_amt              
   SET @my_pay_curr=case when @my_cmdty_code=@my_temp_curr then @my_mkt_code              
          when @my_mkt_code=@my_temp_curr then @my_cmdty_code              
        end              
   SET @my_reccurr_amt=@my_deal_amt                    
   SET @my_rec_curr=@my_temp_curr              
  end              
              
  set @my_fx_contract_code = 'FXall '+@my_fxtrade_num            
--Validate Commodity, Market and BookingCompany Num here              
  if (@my_ndf_ind is not null and @my_ndf_ind='Y') --Handle NDF trades            
  begin            
 select @my_ndf_trade_num=trade_num from trade where acct_ref_num=@my_fx_contract_code            
            
 if(@my_ndf_trade_num <= 0)            
 begin              
  SELECT 'Unable to pairing trade this NDF deal, so unable to create the tradeet alias for currency pairs : '+@my_currpair_str+' or '+ (substring(@my_currpair_str,charindex('.',@my_currpair_str)+1,len(@my_currpair_str)-charindex('.',@my_currpair_str))+'.'+substring(@my_currpair_str,1,charindex('.',@my_currpair_str)-1))              
  goto endofsp              
 end              
             
 if(@my_cmdty_code='USD' or @my_mkt_code='USD')            
     set @my_fx_contract_code = @my_fx_contract_code + ' SWAP'            
 else             
            set @my_fx_contract_code = @my_fx_contract_code + ' SWAPERR'            
  end            
              
 begin tran              
              
  exec gen_new_transaction              
  select @my_trans_id=last_num from icts_trans_sequence              
              
  exec get_new_num 'trade_num',0              
  select @my_trade_num=last_num from new_num where num_col_name='trade_num' and owner_table='trade'              
              
  exec get_new_num 'cmnt_num',0              
  select @my_cmnt_num=last_num from new_num where num_col_name='cmnt_num' and owner_table='comment'              
        
       
 if( @my_pay_curr='USD'   and  round(@my_paycurr_amt/@my_reccurr_amt,3)<> round(@my_avg_price,3) and @my_mkt_code='USD')      
   select @my_avg_price=@my_paycurr_amt/@my_reccurr_amt      

  if( @my_rec_curr='USD' and  round(@my_reccurr_amt/@my_paycurr_amt,3)<> round(@my_avg_price,3) and @my_mkt_code='USD')  
   select @my_avg_price=@my_reccurr_amt/@my_paycurr_amt      
  
   
    
  insert into trade               
  (trade_num,trader_init,trade_status_code,conclusion_type,inhouse_ind,acct_num,acct_ref_num,concluded_date,contr_date,cp_gov_contr_ind,contr_tlx_hold_ind,creation_date,creator_init,invoice_cap_type,contr_status_code,max_order_num,is_long_term_ind,trans_id,copy_type)              
  values (@my_trade_num,@my_trader_init,'UNALLOC', 'C', 'N',@my_acct_num,@my_fx_contract_code,getDate(),@my_contr_date,'N','N',getDate(),@my_trader_init,'N','NEW',1,'N',@my_trans_id,'FULL')              
              
  insert into trade_order               
  (trade_num,order_num,order_type_code,strip_summary_ind,bal_ind,max_item_num,trans_id)              
  values (@my_trade_num,1,'CURRENCY','N','N',1,@my_trans_id)              
              
  insert into comment (cmnt_num,short_cmnt,trans_id) values (@my_cmnt_num,@my_short_comment,@my_trans_id)              
              
  insert into trade_item               
  (trade_num,order_num,item_num,item_status_code,p_s_ind,booking_comp_num,cmdty_code,risk_mkt_code,title_mkt_code,contr_qty,contr_qty_uom_code,contr_qty_periodicity,item_type,formula_ind,priced_qty_uom_code,avg_price,price_curr_code,cmnt_num,real_port_num,sch_qty_uom_code,open_qty_uom_code,estimate_ind,billing_type,sched_status,hedge_curr_code,hedge_multi_div_ind,hedge_pos_ind,trans_id,trade_modified_ind,item_confirm_ind,finance_bank_num,includes_excise_tax_ind,includes_fuel_tax_ind)              
  values (@my_trade_num,1,1,'A',@my_ps_ind,@my_bookcomp_num,@my_cmdty_code,@my_mkt_code,@my_mkt_code,@my_deal_amt,'UNIT','L','U','N','UNIT',@my_avg_price,@my_mkt_code,@my_cmnt_num,@my_real_port_num,'UNIT','UNIT','N','N',0,@my_mkt_code,'D','N',@my_trans_id,'N','N',NULL,0,0)              
              
  insert into trade_item_curr                    
  (trade_num,order_num,item_num,payment_date,credit_term_code,ref_spot_rate,pay_curr_amt,pay_curr_code,rec_curr_amt,rec_curr_code,trans_id)                    
  values (@my_trade_num,1,1,@my_payment_date,'OPEN',@my_spot_rate,@my_paycurr_amt,@my_pay_curr,@my_reccurr_amt,@my_rec_curr,@my_trans_id)                    
            
  insert into trade_sync                    
  (trade_num,trade_sync_inds,trans_id)                    
  values (@my_trade_num,'0000N---',@my_trans_id)                    
            
  if (@my_ndf_ind is not null and @my_ndf_ind='Y') --Handle NDF trades            
  begin            
 update trade_item_curr set payment_date=@my_payment_date,trans_id=@my_trans_id where trade_num=@my_ndf_trade_num            
 update trade set acct_ref_num=@my_fx_contract_code,trans_id=@my_trans_id where trade_num=@my_ndf_trade_num            
            
 if(@my_mkt_code = 'USD')            
 begin              
  update trade_item set hedge_rate=1/avg_price,hedge_curr_code=@my_cmdty_code,trans_id=@my_trans_id where trade_num=@my_ndf_trade_num             
 end              
 else if(@my_cmdty_code = 'USD')            
 begin              
  update trade_item set hedge_rate=avg_price,hedge_curr_code=@my_mkt_code,trans_id=@my_trans_id where trade_num=@my_ndf_trade_num             
 end              
  end            
            
 commit tran              
              
 select @my_trade_num                    
 return @my_trade_num                
endofsp:               
return 0              
GO
GRANT EXECUTE ON  [dbo].[usp_create_currency_trade] TO [next_usr]
GO
