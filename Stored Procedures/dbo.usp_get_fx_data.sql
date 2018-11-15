SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_fx_data]                                                            
(                                                                                
   @port_num    int = NULL,                                                              
   @profit_cntr varchar(100) = NULL,                                                                      
   @debugon     bit = 0                                                                                
)                                                                                
as                                                                                 
set nocount on                                                                                
declare @my_top_port_num   int                                                                                
declare @smsg            varchar(255)                                                                                
declare @status          int                                                                                
declare @errcode         int                                                                                
declare @asofdate datetime                                                                                
declare @pl_asof_date datetime                                                          
                                                    
                                                          
 set @my_top_port_num=@port_num                                                                                
                                                                                
 set @status = 0                                                                                
 set @errcode = 0                                                                                
 if @my_top_port_num is null                                                                                
 select @my_top_port_num = 0                                                                                
                                                                                
/* if not exists (select 1                                                                                
    from dbo.portfolio                                                                                
    where port_num = @port_num)                                                                                
 begin                                                                                
 print '=> You must provide a valid port # for the argument @root_port_num!'                                                                                
 print 'Usage: exec dbo.usp_dump_fx_data_for_portnum_test @root_port_num = ? [, @debugon = ?]'                                                                                
 return 2                                                                                
 end      */                                                                           
                                                                                
 create table #children                                                                                
 (                                                                                
   port_num int PRIMARY KEY,                                                                                
   port_type char(2),                                                                                
 )                                                                                
                                                                                
 create table #active_fx_ids                                                                                 
 (                                                                                
  fx_exp_num int                                                                                
 )                                                                                
                                                                     
 create table #fx_dump                                                                                
 (                                                       
 trader_init char(3) NULL,                                             
 contr_date datetime NULL,                               
   trade_number varchar(40) null,                    
   trade_num int NULL,                                                          
   order_num int NULL,                                                           
   item_num int NULL,                                            
 trade_key varchar(50) NULL,                                                            
 counterparty varchar(255) NULL,                                                            
 inhouse_ind char(1),                                             
   fx_exp_num int null,                                           
   real_port_num int null,                                                                   
   fx_type varchar(45) null,                                                                                 
   fx_sub_type varchar(45) null,                                                                                
   fx_currency char(8) null,                                                                                
 pl_currency char(8) null,                                                                                
   trading_prd varchar(15) null,                                                               
   exp_date varchar(15) null,                                                                                
   year char(4) null,                                                                                
   quarter char(4) null,                                                                                
   month char(4) null,                                                                                
   day  char(4) null,                                          
   total_exp_by_id decimal(20,8) null,                                                                                
   fx_amount decimal(20,8) null,                                                                
   fx_source varchar(15) null,                                                                                
   cost_num int null,                                                         
   cost_status char(8) null,                                                                            
   cost_type_code char(8) null,                                              
   cost_code char(8) null,                                                                            
   cost_prim_sec_ind char(1),                                                                            
   cost_est_final_ind char(1),                                                                            
   conv_rate1 float null,                                                                            
   calc_oper1 char(1) null ,                                                                
   pl_incl_ind char(1) NULL   ,           
   due_date datetime null                                                            
)

--To store final Query and the apply conv
create table #fx_dump_final                                                                                
 (                                                       
 Trader char(3) NULL,                                             
 ContractDate datetime NULL,                               
 TradeNum varchar(40) null,                    
                                             
 TradeKey varchar(50) NULL, 
           
 CostNum int null,
                                                   
 Counterparty varchar(255) NULL,
 TradeType   char(9) null,                                                         
 InhouseInd char(1),  
 FXRiskType varchar(45) null,                                                                                  
   
   TradingEntity  varchar(510) null, 
   Book    varchar(16) null,
   ProfitCntr    varchar(16) null,
   BookingCompany    varchar(30) null,         
   PortNum int null, 
   
   FXAmount decimal(20,8) null,                                                                       
   Currency char(8) null,                                                                                
   BookCurrencyEquiv decimal(30,8) null,
   BookCurrency char(8) null, 
   Month varchar(30) null, --15 len
   Qtr varchar(32) null, --15 len
   YEAR varchar(30) null, --15 len
   ExpDate varchar(30) null, --15 len  
                                                                                  
   TradingPrd varchar(15) null,                                                            
                                         
   ExpId decimal(20,8) null,                                                                                
                                                                   
   FxSource varchar(15) null,                                                                                
                                                            
   CostStatus char(8) null,                                                                            
   CostType char(8) null,                                              
   cost_code char(8) null,                                                                              
             
   OrignalDueDate datetime null,                                                                                   
                                                            
) 

                                                                              
If (isnull(@port_num,0)<>0)                                                    
BEGIN                                                    
                                                            
 begin try                                                                                    
  exec dbo.usp_get_child_port_nums @my_top_port_num, 1                                                                                
 end try                     
 begin catch                                                                                
  print '=> Failed to execute the ''usp_get_child_port_nums'' sp due to the following error:'                                                                                
  print '==> ERROR: ' + ERROR_MESSAGE()                                                   
  set @errcode = ERROR_NUMBER()                                                                                
  goto errexit                                                                        
 end catch                                                                                
END                                  
                                                    
If (isnull(@port_num,0)=0 and @profit_cntr is not null)                                  
BEGIN                                                    
                                                            
 begin try                                                           
                                                    
  insert into #children                                                    
  SELECT port_num,'R' from portfolio_tag where tag_name='PRFTCNTR' and tag_value=@profit_cntr                                                    
  and port_num in (select port_num from portfolio where port_type='R')                               
                                                                       
 end try                                                                                
 begin catch                        
  print '=> Failed to execute the ''profit center'' sp due to the following error:'                                                                                
  print '==> ERROR: ' + ERROR_MESSAGE()                                                                       
  set @errcode = ERROR_NUMBER()                                                                                
  goto errexit                           
 end catch                                                                                
END                                                
                                                    
                                                                                
 begin try                                                                  
  insert into #active_fx_ids                                    
  select fe.oid                                                                                
  from fx_exposure fe                                                                                
  join #children t1 on fe.real_port_num=t1.port_num                                                                                
  where status !='N'                                                                                
 end try                                                                  
 begin catch                                                                                
  print '=> Failed to get list of active fx oids due to the following error:'                                                                                
  print '==> ERROR: ' + ERROR_MESSAGE()                                                                               
  set @errcode = ERROR_NUMBER()                                                                                
  goto errexit                                                                                
 end catch                                                                     
    
 if (@debugon=1)    
 BEGIN    
 select * from #active_fx_ids where fx_exp_num in (139650,139649)    
 END     
                                                                                
 begin try                                                                                    
  insert into #fx_dump                                                                  
  select                             
 t.trader_init,                                                        
 contr_date,                                                            
 convert(varchar,fed.trade_num),                                                           
 fed.trade_num,                                                          
 fed.order_num,                                                          
 fed.item_num,                            
 convert(varchar,fed.trade_num)+'-'+convert(varchar,fed.order_num)+'-'+convert(varchar,fed.item_num) 'trade_key',                                                                  
 acc.acct_short_name,                                                            
 inhouse_ind,                                                            
    fe.oid,                                                      
    fe.real_port_num,                                      
    case fx_exposure_type                                                                               
     when 'P' then 'Primary'                                                                               
     when 'SW' then 'Swap Curr Hedge' --Swap should be in primary                                                                              
     when 'C' then 'Forex'                                                                              
     when 'F' then 'Future Curr Exp'                                                                              
     when 'PP' then 'PricingP'                                                              
     when 'PR' then 'Premium'                                                
     when 'FD' then 'Premium'                                                                              
     when 'S' then 'Other'                                                                           
     else 'GasPower'                  
    end as fx_type,                                                          
    case fx_exposure_type                                                                               
     when 'P' then 'Primary'                                                                               
 when 'SW' then 'Swap Curr Exp' --Swap should be in primary                                                                              
     when 'C' then 'Forex'                                                                              
     when 'F' then 'Future Curr Exp'                                                                    
     when 'PP' then 'PricingP'                                                                              
     when 'PR' then 'Premium'                                                                              
     when 'FD' then 'Premium'                                          
     when 'S' then 'Other'                                                                              
     else 'INVALID'                                                               
    end as fx_sub_type,                                                                              
    price_curr_code,                                                                                
     pl_curr_code,                                                                                
     fx_trading_prd,                                         
     case when fx_drop_date is not null then fx_drop_date                                                                 
   when fx_drop_date is null and fx_trading_prd='SPOT' then convert(char,getdate(),101)                                                                              
  else convert(varchar,convert(datetime,substring(fx_trading_prd,13,len(fx_trading_prd)-12)+' '+substring(fx_trading_prd,9,3)+' '+substring(fx_trading_prd,1,4),106),101)                                                                         
     end 'exp_date',                                                                          
     null,                                                                         
     null,                                                                                
     null,                                                                                
     null,                                                                                
     open_rate_amt,                                                                                
     isnull(fx_amt,0) - isnull(fx_priced_amt,0),                                                                                
     'FXEXPDIST',                                                                                
     fx_owner_key4,                                             
     null,                   
     null,                                                                            
     null,                                                                            
     null,                                                                            
     'E',                                      
     null,                                                                            
     null   ,                                                                
     'Y'    ,     NULL                                                                     
  from fx_exposure fe                              
  join #active_fx_ids t1 on fe.oid=t1.fx_exp_num                                                                                
  join fx_exposure_dist fed on fed.fx_exp_num=fe.oid                                                                                
  join fx_exposure_currency fec on fec.oid=fx_exp_curr_oid                                                               
  left outer join trade t ON t.trade_num=fed.trade_num                                                            
  LEFT OUTER JOIN account acc ON acc.acct_num=t.acct_num                                                            
    
    
if (@debugon=1)    
BEGIN    
 SELECT * from #fx_dump where trade_key in ('1966776-1-1','1635930-7-1')    
END    
     
  insert into #fx_dump                                                                                    
  select                                                              
 c.creator_init,                                                      
 c.creation_date,                                                            
 convert(varchar,isnull(cost_owner_key6,c.cost_num)),                              
 cost_owner_key6,                                                          
 cost_owner_key7,                                                          
 cost_owner_key8,                                                          
    convert(varchar,isnull(cost_owner_key6,c.cost_num))+'-'+convert(varchar,cost_owner_key7)+'-'+convert(varchar,cost_owner_key8),                                                                    
 acc.acct_short_name,                                                            
 'N',                                                            
    fe.oid,                                                                                
    fe.real_port_num,                                                            
    case fx_exposure_type                                                                  
     when 'P' then 'Primary'                                                                               
     when 'SW' then 'Swap Curr Hedge' --Swap should be in primary                                                                              
     when 'C' then 'Forex'                                                                              
     when 'F' then 'Future Curr Exp'                                                                              
     when 'PP' then 'PricingP'                                                                              
     when 'PR' then 'Premium'                          
 when 'FD' then 'Premium'                                                                              
     when 'S' then 'Other'                                                                           
     else 'GasPower'                                                                              
    end as fx_type,                                                                              
   case fx_exposure_type                             
     when 'P' then 'Primary'                                                                               
     when 'SW' then 'Swap Curr Exp' --Swap should be in primary                                                                              
     when 'C' then 'Forex'                                                                              
     when 'F' then 'Future Curr Exp'                                                                              
     when 'PP' then 'PricingP'       
     when 'PR' then 'Premium'                                                                              
     when 'FD' then 'Premium'                                                                              
     when 'S' then 'Other'                                                                              
     else 'INVALID'                                    
    end as fx_sub_type,                                                                              
    price_curr_code,                                                                                
     pl_curr_code,                                                   
     fx_trading_prd,                                                                                
   case when fx_trading_prd='SPOT'   then convert(char,getdate(),101)                                                                              
     else convert(varchar,convert(datetime,substring(fx_trading_prd,13,len(fx_trading_prd)-12)+' '+substring(fx_trading_prd,9,3)+' '+substring(fx_trading_prd,1,4),106),101)                                         
     end 'exp_date',                                            
     null,                                                                                
     null,                                                                                
     null,                                                                                
     null,                                                                                
     open_rate_amt,                                                                          
     (isnull(cost_amt,0)*(case cost_pay_rec_ind when 'P' then -1 else 1 end)),  
     /*(isnull(cost_amt,0) -                                                                               
   ---(case when datediff(dd,getDate(),isnull(cost_paid_date,cost_due_date)) < 0 then isnull(cost_vouchered_amt,0) else 0 end)) *                                                                               
   (case cost_pay_rec_ind when 'P' then -1 else 1 end),                                                   */  
     'COST',                                                                                
     c.cost_num,                                                                            
     c.cost_status,                                                                            
     c.cost_type_code,                                                                            
     c.cost_code,                                  
     c.cost_prim_sec_ind,                                                                            
     c.cost_est_final_ind,                                                                            
     null,                                                                            
     null        ,                                                                
     'Y'  , cost_due_date                                                                  
  from fx_exposure fe                                                                                
  join #active_fx_ids t1 on fe.oid=t1.fx_exp_num                                                                      
  join cost_ext_info cei on cei.fx_exp_num=fe.oid and isnull(cost_pl_contribution_ind,'Y')='Y'                                                                                  
  join cost c on cei.cost_num=c.cost_num                                                                                
  join fx_exposure_currency fec on fec.oid=fx_exp_curr_oid                               
  LEFT OUTER JOIN account acc ON acc.acct_num=c.acct_num                                                            
  where abs(c.cost_amt) >= 0.001 and c.cost_status not in ('PAID','HELD','CLOSED') and cost_type_code not in ('INVROLL')                                                                            
 and not exists (select 1 from dbo.pdfx_detail pdfx where pdfx.cost_num=c.cost_num)                                            
                                                             
if (@debugon=1)    
BEGIN    
 SELECT * from #fx_dump where trade_key in ('1966776-1-1','1635930-7-1')    
END    
    
    
  insert into #fx_dump                                                                   
   select creator_init,                                          
 creation_date,                                                            
 c.cost_num,                                                            
cost_owner_key6,                                                          
cost_owner_key7,                                                           
cost_owner_key8,                                                          
    convert(varchar,isnull(cost_owner_key6,c.cost_num))+'-'+convert(varchar,cost_owner_key7)+'-'+convert(varchar,cost_owner_key8),                                                              
 cpty.acct_short_name,                                                            
 'N',                                                            
 c.cost_num,                                                            
 c.port_num,                                                            
 'Forex',                                                            
 'Forex',                     
 cost_price_curr_code,                                                            
 isnull(cost_book_curr_code,'USD'),                                                            
case when isnull(cost_paid_date,cost_due_date)>=                                               
   convert(char,getdate(),101) then convert(varchar,datepart(yyyy,isnull(cost_paid_date,cost_due_date)))                                              
    +'|'+ 'Q'+convert(varchar,datepart(qq,isnull(cost_paid_date,cost_due_date)))               
    +'|'+  convert(varchar(3),datename(mm,isnull(cost_paid_date,cost_due_date)))                                              
    +'|'+ convert(varchar(2),datepart(dd,isnull(cost_paid_date,cost_due_date)))                                               
    else 'SPOT'                                               
    end 'trading_prd',                                                            
--'SPOT' 'trading_prd',                                                
 convert(char,isnull(cost_paid_date,cost_due_date),101) ,                                               
     'PAID',                                                                         
     'PAID',                                                                                
     'PAID',                                                                                
     'PAID',                                                                                
     NULL,                                                              
    case when cost_pay_rec_ind='P' then -1 else 1 end *cost_amt,                                                              
   'COST',                                          
     c.cost_num,                                                                            
     c.cost_status,                                                                            
     c.cost_type_code,                                                                            
     c.cost_code,                                                                            
     c.cost_prim_sec_ind,                                                       
     c.cost_est_final_ind,                                                          
     null,                                                                            
     null        ,                                                                
     'Y'    ,       cost_due_date                                                 
 from cost c with (NOLOCK)                                     
 INNER JOIN portfolio  port  ON port.port_num=c.port_num and c.cost_price_curr_code<>isnull(desired_pl_curr_code,'USD')                                    
 INNER JOIN cost_ext_info cei ON cei.cost_num=c.cost_num and isnull(cost_pl_contribution_ind,'Y')='Y'                                        
 LEFT OUTER JOIN commodity cmdty ON cmdty.cmdty_code=c.cost_price_curr_code                                                            
 LEFT OUTER JOIN account cpty ON cpty.acct_num=c.acct_num                                                            
 WHERE --c.cost_price_curr_code not in('USD','USC') and       
  cost_amt!=0                                                            
 and cost_type_code in ('CPR','CPP')                                                            
 and cost_status in ('VOUCHED','OPEN')                                                      
-- and cost_due_date<= convert(char,getdate(),101)                                                            
 and c.port_num in (select port_num from #children)                                                            
 and exists (select 1 from cost_ext_info cei where isnull(fx_exp_num,0) =0 and cei.cost_num=c.cost_num)                                                      
    
if (@debugon=1)    
BEGIN    
 SELECT * from #fx_dump where trade_key in ('1966776-1-1','1635930-7-1')    
END    
    
                  
--Logic to include PAID costs that are not part of PDFX                  
insert into #fx_dump                                                              
   select creator_init,                                                            
 creation_date,                                                            
 c.cost_num,                                           
cost_owner_key6,                                                          
cost_owner_key7,                                                           
cost_owner_key8,                                                          
    convert(varchar,isnull(cost_owner_key6,c.cost_num))+'-'+convert(varchar,cost_owner_key7)+'-'+convert(varchar,cost_owner_key8),                                                              
 cpty.acct_short_name,                                                            
 'N',                                                            
 c.cost_num,                                 
 c.port_num,                                                            
 case when cost_prim_sec_ind='S' then 'Secondary'                                                         
   when cost_type_code in ('CPR','CPP') then 'Forex'                                                        
 else 'Primary' end,                                                            
 case when cost_prim_sec_ind='S' then 'Secondary'                                                         
   when cost_type_code in ('CPR','CPP') then 'Forex'                                                        
 else 'Primary' end,                                                            
 cost_price_curr_code,                                                            
isnull(cost_book_curr_code,'USD'),     case when cost_paid_date>=                                               
   convert(char,getdate(),101) then convert(varchar,datepart(yyyy,cost_paid_date))                                              
    +'|'+ 'Q'+convert(varchar,datepart(qq,cost_paid_date))                                               
    +'|'+  convert(varchar(3),datename(mm,cost_paid_date))                                              
    +'|'+ convert(varchar(2),datepart(dd,cost_paid_date))                                               
    else 'SPOT'                                               
    end 'trading_prd',                                                            
--'SPOT' 'trading_prd',                                                
 convert(char,cost_paid_date,101) ,                                                              
     'PAID',                                                                           
     'PAID',                                                                                
     'PAID',                                                                             
     'PAID',                                                                                
     NULL,                                                              
    case when cost_pay_rec_ind='P' then -1 else 1 end *cost_amt,              
   'COST',                                                            
     c.cost_num,                                                                            
     c.cost_status,                                                                            
     c.cost_type_code,                                                                            
     c.cost_code,                      
     c.cost_prim_sec_ind,                                            
     c.cost_est_final_ind,                                                                            
     null,                                                                            
 null        ,                                                                
     'Y'  ,c.cost_due_date          
 from cost c with (NOLOCK)                                       
 INNER JOIN voucher_cost vc on vc.cost_num=c.cost_num                        
 INNER JOIN voucher v ON v.voucher_num=vc.voucher_num                        
 --INNER JOIN (select voucher_num,max(paid_date) paid_date, max(processed_date)  processed_date from voucher_payment group by voucher_num)               
--   v_p on v_p.voucher_num=v.voucher_num              
 INNER JOIN portfolio  port  ON port.port_num=c.port_num and c.cost_price_curr_code<>isnull(desired_pl_curr_code,'USD')                                    
 INNER JOIN cost_ext_info cei ON cei.cost_num=c.cost_num and isnull(cost_pl_contribution_ind,'Y')='Y'                                                            
 LEFT OUTER JOIN commodity cmdty ON cmdty.cmdty_code=c.cost_price_curr_code                           LEFT OUTER JOIN account cpty ON cpty.acct_num=c.acct_num                                                            
 WHERE cost_amt!=0                                                            
 --and cost_type_code not in ('PR','PO')                                                            
 and c.port_num in (select port_num from #children)                                                     
 and (cost_status ='PAID'  )            
 and not exists (select 1 from dbo.pdfx_detail pdfx where pdfx.cost_num=c.cost_num)                                            
 and not exists (select 1 from #fx_dump f where c.cost_num=f.cost_num)                              
 and exists (select 1 from voucher_payment vp WHERE vp.voucher_num=v.voucher_num and voucher_pay_amt<>0 and processed_date>='08/06/2013')        
            
if (@debugon=1)    
BEGIN    
 SELECT * from #fx_dump where trade_key in ('1966776-1-1','1635930-7-1')    
END    
            
            
                  
--Logic to include VOUCHED costs that are not part of PDFX             
insert into #fx_dump                                                              
   select creator_init,                                                            
 creation_date,                                                            
 c.cost_num,                                           
cost_owner_key6,                                                          
cost_owner_key7,                                                           
cost_owner_key8,                                                          
    convert(varchar,isnull(cost_owner_key6,c.cost_num))+'-'+convert(varchar,cost_owner_key7)+'-'+convert(varchar,cost_owner_key8),                                                              
 cpty.acct_short_name,                                                            
 'N',                                                            
 c.cost_num,                                 
 c.port_num,                                           
 case when cost_prim_sec_ind='S' then 'Secondary'                                                         
   when cost_type_code in ('CPR','CPP') then 'Forex'                                                        
 else 'Primary' end,                                                            
 case when cost_prim_sec_ind='S' then 'Secondary'                                                         
   when cost_type_code in ('CPR','CPP') then 'Forex'                                                        
 else 'Primary' end,                                                            
 cost_price_curr_code,                                                            
 isnull(cost_book_curr_code,'USD'),               
 case when isnull(cost_paid_date,cost_due_date)>=                                               
   convert(char,getdate(),101) then convert(varchar,datepart(yyyy,isnull(cost_paid_date,cost_due_date)))                                              
    +'|'+ 'Q'+convert(varchar,datepart(qq,isnull(cost_paid_date,cost_due_date)))                                               
    +'|'+  convert(varchar(3),datename(mm,isnull(cost_paid_date,cost_due_date)))                                              
    +'|'+ convert(varchar(2),datepart(dd,isnull(cost_paid_date,cost_due_date)))                                               
    else 'SPOT'                                               
    end 'trading_prd',                                                            
--'SPOT' 'trading_prd',                                                
 convert(char,isnull(cost_paid_date,cost_due_date),101) ,                                                              
     'PAID',                                                                                
     'PAID',                                                                                
     'PAID',                                                                             
     'PAID',                                                                                
     NULL,                                                              
    case when cost_pay_rec_ind='P' then -1 else 1 end *cost_amt,              
   'COST',                                                            
     c.cost_num,                                                                            
     c.cost_status,                                                                            
     c.cost_type_code,                                                                            
     c.cost_code,                                                                            
     c.cost_prim_sec_ind,                                            
     c.cost_est_final_ind,                                                                            
     null,                                                                            
 null        ,                                                                
     'Y'  ,       c.cost_due_date         
 from cost c with (NOLOCK)                                       
 INNER JOIN portfolio  port  ON port.port_num=c.port_num and c.cost_price_curr_code<>isnull(desired_pl_curr_code,'USD')                                    
 INNER JOIN cost_ext_info cei ON cei.cost_num=c.cost_num and isnull(cost_pl_contribution_ind,'Y')='Y'                                                            
 LEFT OUTER JOIN commodity cmdty ON cmdty.cmdty_code=c.cost_price_curr_code                           LEFT OUTER JOIN account cpty ON cpty.acct_num=c.acct_num                                 
 WHERE cost_amt!=0                                                            
 --and cost_type_code not in ('PR','PO')                                                            
 and c.port_num in (select port_num from #children)                                                     
 and (cost_status='VOUCHED' and isnull(c.cost_paid_date,cost_due_date) >= dateadd(mm,-12,getdate())    )            
 and not exists (select 1 from dbo.pdfx_detail pdfx where pdfx.cost_num=c.cost_num)                                            
 and not exists (select 1 from #fx_dump f where c.cost_num=f.cost_num)                              
            
if (@debugon=1)    
BEGIN    
 SELECT * from #fx_dump where trade_key in ('1966776-1-1','1635930-7-1')    
END    
                  
--Logic to include Partially Paid VOUCHED costs.                  
insert into #fx_dump                                                              
   select creator_init,                                                            
 creation_date,                                                            
 c.cost_num,                                           
cost_owner_key6,                                                          
cost_owner_key7,                                                           
cost_owner_key8,                                                          
    convert(varchar,isnull(cost_owner_key6,c.cost_num))+'-'+convert(varchar,cost_owner_key7)+'-'+convert(varchar,cost_owner_key8),                                                              
 cpty.acct_short_name,                                                            
 'N',                                                            
 c.cost_num,                     
 c.port_num,                                                            
 case when cost_prim_sec_ind='S' then 'Secondary'                                                         
   when cost_type_code in ('CPR','CPP') then 'Forex'                                                        
 else 'Primary' end,                                                            
 case when cost_prim_sec_ind='S' then 'Secondary'                                                         
   when cost_type_code in ('CPR','CPP') then 'Forex'                                                        
 else 'Primary' end,                                                            
 cost_price_curr_code,                                                            
 isnull(cost_book_curr_code,'USD'),                                                    
 case when isnull(cost_paid_date,cost_due_date)>=                                               
   convert(char,getdate(),101) then convert(varchar,datepart(yyyy,isnull(cost_paid_date,cost_due_date)))                                              
    +'|'+ 'Q'+convert(varchar,datepart(qq,isnull(cost_paid_date,cost_due_date)))                                               
    +'|'+  convert(varchar(3),datename(mm,isnull(cost_paid_date,cost_due_date)))                                              
    +'|'+ convert(varchar(2),datepart(dd,isnull(cost_paid_date,cost_due_date)))                                               
    else 'SPOT'                                               
    end 'trading_prd',                                                            
--'SPOT' 'trading_prd',                                                
 convert(char,isnull(cost_paid_date,cost_due_date),101) ,                                                              
     'PAID',                                                                               
     'PAID',                                                                                
     'PAID',                                                                             
     'PAID',                                                                                
     NULL,                                                              
    case when cost_pay_rec_ind='P' then -1 else 1 end *cost_amt-isnull(pdfx.paid_amt,0),                  
   'COST',                  
     c.cost_num,                                                                            
     c.cost_status,                                                                            
     c.cost_type_code,                                                                            
     c.cost_code,                                                                            
     c.cost_prim_sec_ind,                                            
c.cost_est_final_ind,                                                                            
     null,                
     null        ,                                                                
     'Y'  , c.cost_due_date          
 from cost c with (NOLOCK)                      
 INNER JOIN dbo.pdfx_detail pdfx ON  pdfx.cost_num=c.cost_num                   
         and abs(round(case when cost_pay_rec_ind='P' then -1 else 1 end *c.cost_amt-isnull(pdfx.paid_amt,0),0))>1                  
 --LEFT OUTER JOIN voucher_cost vc on vc.cost_num=c.cost_num                        
 --LEFT OUTER JOIN voucher v ON v.voucher_num=v.voucher_num                        
 INNER JOIN portfolio  port  ON port.port_num=c.port_num and c.cost_price_curr_code<>isnull(desired_pl_curr_code,'USD')                                    
 INNER JOIN cost_ext_info cei ON cei.cost_num=c.cost_num and isnull(cei.cost_pl_contribution_ind,'Y')='Y'                                                            
 LEFT OUTER JOIN commodity cmdty ON cmdty.cmdty_code=c.cost_price_curr_code                                       
 LEFT OUTER JOIN account cpty ON cpty.acct_num=c.acct_num                                                            
 WHERE isnull(c.cost_paid_date,cost_due_date) >= dateadd(mm,-12,getdate())         
 --and c.cost_price_curr_code not in('USD','USC')                                                            
 and cost_amt!=0                                                            
 --and cost_type_code not in ('PR','PO')                                                            
 and c.port_num in (select port_num from #children)                                                     
 and cost_status in ('VOUCHED','PAID')                                              
 and not exists (select 1 from #fx_dump f where c.cost_num=f.cost_num)                              
                   
if (@debugon=1)    
BEGIN    
 SELECT * from #fx_dump where trade_key in ('1966776-1-1','1635930-7-1')    
END    
                               
end try                                                                                
 begin catch                                                                                
  print '=> Failed to get fx dump data from fx_exposure_dist, costs for the active fx_oids due to the following error:'                            
  print '==> ERROR: ' + ERROR_MESSAGE()                                                                                
  set @errcode = ERROR_NUMBER()                                                                                
  goto errexit                                                                                
 end catch                                                                         
                                                          
                                                          
                                                                         
--Delete premiums offset records where Costs doesn't have forex exposure                                                                                
 begin try                                                                                    
  delete t1                   
  from #fx_dump t1                                                                                
  where fx_sub_type='PRIMARY' and fx_source='FXEXPDIST'                                                                                
  and exists (select 1 from cost_ext_info cei where t1.cost_num=cei.cost_num and fx_exp_num is null)                                                                      
 end try                                                                                
 begin catch                                                                                
  print '=> Failed to delete premium offset records where costs dont have forex exposure due to the following error:'                                                                                
  print '==> ERROR: ' + ERROR_MESSAGE()                                                                      
  set @errcode = ERROR_NUMBER()                                                                                
  goto errexit                                                                                
 end catch                                                                                
                                                 
-----START- Added per lionel/JM requirement to remove SPOT FX Risk shown on Premium for a USD Pricing deal.                                  
delete fx                                  
from #fx_dump fx                                  
where exists (                                  
  select 1 from trade_item ti , portfolio p                                  
  where ti.trade_num=fx.trade_num                                  
  and ti.order_num=fx.order_num                                  
  and ti.item_num=fx.item_num                                  
  and ti.real_port_num=p.port_num                                  
  and ti.price_curr_code=pl_currency                                  
  and fx.trading_prd='SPOT'                                  
  and fx.fx_sub_type='Premium'                                  
  )                               
                            
delete fx                                  
from #fx_dump fx                                  
where exists (                                  
  select 1 from trade_item ti , portfolio p , cost c                                 
  where ti.trade_num=fx.trade_num              
  and ti.order_num=fx.order_num                                  
  and ti.item_num=fx.item_num                                  
  and ti.real_port_num=p.port_num                                  
  and ti.price_curr_code=pl_currency                                  
  and fx.fx_sub_type='Premium'                                 
  and c.cost_num=fx.cost_num                             
  and c.cost_type_code in ('PO','PR')                            
  )                               
----- END- Added per lionel/JM requirement to remove SPOT FX Risk shown on Premium for a USD Pricing deal.                                  
                                            
                                                                              
 begin try                                           
  update #fx_dump set year='SPOT',exp_date='SPOT', quarter='SPOT',month='SPOT',day='SPOT' where trading_prd='SPOT'                                                                               
 end try                                                                             
 begin catch                                              
  print '=> Failed to set SPOT trading period due to the following error:'                       
  print '==> ERROR: ' + ERROR_MESSAGE()                                                                                
  set @errcode = ERROR_NUMBER()                                                      
  goto errexit                                               
 end catch                                                                                
                            
 begin try                                                                                
  update #fx_dump set exp_date=convert(varchar,convert(datetime,substring(trading_prd,13,len(trading_prd)-12)+' '+substring(trading_prd,9,3)+' '+substring(trading_prd,1,4),106),101),                                                                        
  
    
      
        
       year=substring(trading_prd,1,4),                 
       quarter=substring(trading_prd,7,1),                                                                                
       month=substring(trading_prd,9,3),                                                                                
       day=substring(trading_prd,13,len(trading_prd)-12) where trading_prd!='SPOT'                                                                                
 end try                                         
 begin catch                                                                                
  print '=> Failed to derive exposure date, year, quarter,month and day from fx_exposure.trading_prd due to the following error:'                                                                                
  print '==> ERROR: ' + ERROR_MESSAGE()                                                                                
  set @errcode = ERROR_NUMBER()                                                                                
  goto errexit                                                    
 end catch                                                                               
                                                                                                                            
  update #fx_dump set fx_type='Secondary' where (cost_prim_sec_ind='S' or cost_type_code in ('WAP','SPP')) and fx_type in ('OTHER','INVALID')                                                                            
  update #fx_dump set fx_type='CashBalance' where cost_code='CASHBLNC'                                                                            
  update #fx_dump set fx_type='GasPower' where cost_type_code like 'POM%'                                                                            
                                                                            
  select @asofdate=max(price_quote_date) from price where commkt_key IN (248 ,357)                                                                          
              
  --Added by Subu on Jul 30th 2012 to reflect the correct expected payment date incase Due Date is different from expected pay date. -- Applies only for Physicals/secondary                                                                    
  update #fx_dump set exp_date=convert(char,voucher_expected_pay_date,101)                                                                    
  from #fx_dump fx, voucher v, voucher_cost vc                                                                    
  where fx.cost_num=vc.cost_num                                                             
  and vc.voucher_num=v.voucher_num                                                                    
  and voucher_expected_pay_date<>voucher_due_date                                                                    
  and cost_type_code not in ('CPP','CPR')                                                                    
  and cost_type_code is not null                                                           
  and cost_status='VOUCHED'                                                 
  and isnull(exp_date,'SPOT') <>'SPOT'                                    
  --Added by Subu on Jul 30th 2012 to reflect the correct expected payment date incase Due Date is different from expected pay date. -- Applies only for Physicals/secondary                                                                    
                                                          
                                                                      
    select @pl_asof_date=(select max(pl_asof_date) from v_BI_cob_date)                                                                   
                                                              
----Added temporariliy to fix a bug.                                                                      
   update fx set fx_amount=fut.fx_amount, conv_rate1=currency_fx_rate, calc_oper1='M'                                                  
   from #fx_dump fx,                                                            
   (                                           
   select trade_number,pl.real_port_num,sum(isnull(pl_amt,0)/currency_fx_rate) fx_amount,currency_fx_rate                                                                      
   from #fx_dump fx , pl_history pl                                                                      
   where pl.real_port_num=fx.real_port_num                                                         
   and fx.fx_type='FUT'                                                                      
   and fx.trade_num=pl_secondary_owner_key1                                                          
   and fx.order_num=pl_secondary_owner_key2                                                          
   and fx.item_num=pl_secondary_owner_key3                                                          
   and currency_fx_rate is not null                                                                      
   and pl_type not in ('I', 'W')                                                                      
   and pl_asof_date =@pl_asof_date                                     
   group by trade_number,pl.real_port_num,currency_fx_rate                                                                      
   ) fut                   where fx.trade_number=fut.trade_number                                                                      
                     
----Added temporariliy to fix a bug.                                                                      
                                                                      
                                                                      
                                                                      
                                                                                                    
                update #fx_dump                                                                            
                                set conv_rate1= conv_rate,                                                                             
   calc_oper1 = calc_oper                                                                            
         from #fx_dump fx                                                                            
  CROSS APPLY  dbo.udf_currency_exch_rate  (                                                                            
                                   @asofdate,       /* @asof_date */                                                                            
                                   fx.fx_currency,                /* @curr_code_from */                                                                            
                                   fx.pl_currency,                /* @curr_code_to */                                                                            
       case when exp_date='SPOT' then getdate() else exp_date end,       /* @eff_date */                                                                  
                                   case when datediff(dd,@asofdate,(case when exp_date='SPOT' then @asofdate else exp_date end))>0 then 'E' else 'F' end ,               /* @est_final_ind */                                                                 
  
     
     
        
          
            
              
                
                                   case when exp_date='SPOT' then exp_date else convert(char(6),exp_date,112) end                             /* @trading_prd */                                                                            
                                )                                                                            
       WHERE fx.conv_rate1 is null                                                                            
                                                                
 update #fx_dump set pl_incl_ind=cost_pl_contribution_ind                                        
 from #fx_dump f, cost_ext_info cei                                                                
 where f.cost_num=cei.cost_num                                                                
 and f.fx_source='COST'                                                                
 and cost_pl_contribution_ind='N'                                                                
                                                          
 UPDATE #fx_dump set exp_date='.SPOT-PDFX' where cost_code='PDFX'        
  insert into #fx_dump_final                                                                          
 select                                                             
   fd.trader_init 'Trader' ,                                                            
   contr_date ContractDate,                                                            
   trade_number 'TradeNum',                                                            
   trade_key 'TradeKey',                                                          
   cost_num 'CostNum',                                                                            
   counterparty 'Counterparty',                                                            
   'CURRENCY' TradeType,                                                            
   inhouse_ind 'InhouseInd',                                                            
   fx_sub_type 'FXRiskType',                                                               
  acc.acct_full_name  as 'TradingEntity',                                                            
   group_code as Book,                                                            
   profit_center_code 'ProfitCntr',                                                         
   booking_company_desc 'BookingCompany',                                                     
   real_port_num 'PortNum',                                                             
   fx_amount 'FXAmount',                                                                                
   fx_currency 'Currency',                                                                                
   case when calc_oper1='M' then fd.conv_rate1*fx_amount else fx_amount/fd.conv_rate1 end 'BookCurrencyEquiv'  ,                                 
   pl_currency 'BookCurrency',                                                                                
                                                          
 CASE when exp_date='SPOT'                                     
   then '.SPOT'                                     
   when exp_date='.SPOT-PDFX'                                     
   then '.SPOT-PDFX'                                    
   else substring(datename(mm,exp_date),1,3) end 'Month' ,                                                                                  
 CASE when exp_date='SPOT'                                     
   then '.SPOT'                                     
   when exp_date='.SPOT-PDFX'                                     
   then '.SPOT-PDFX'                                    
   else 'Q'+convert(char,datename(q,exp_date)) end 'Qtr',                                
 CASE when exp_date='SPOT'                                     
   then '.SPOT'                                     
   when exp_date='.SPOT-PDFX'                                     
   then '.SPOT-PDFX'                                    
   else datename(yyyy,exp_date) end 'YEAR' ,                             
                                                           
 --CASE when exp_date='SPOT' then substring(datename(mm,getdate()),1,3) else substring(datename(mm,exp_date),1,3) end 'Month' ,                                                                                  
 --'Q'+CASE when exp_date='SPOT' then convert(char,datename(q,getdate())) else convert(char,datename(q,exp_date)) end 'Qtr',                                                                                  
 --CASE when exp_date='SPOT' then datename(yyyy,getdate()) else datename(yyyy,exp_date) end 'YEAR' ,                                                                                        
 CASE when exp_date='SPOT'                                     
   then '.SPOT'                                     
   when exp_date='.SPOT-PDFX'                                     
   then '.SPOT-PDFX'                                    
   else exp_date end 'ExpDate',                                                                                
   trading_prd 'TradingPrd',                 
   total_exp_by_id 'ExpId',                                                                                
   fx_source 'FxSource',                         
   cost_status 'CostStatus',                                                                           
cost_type_code 'CostType',                                                                            
   fd.cost_code,       due_date 'OrignalDueDate'                        
from #fx_dump fd                                                                       
 join v_BI_portfolio pt on fd.real_port_num=pt.port_num                                                        
 LEFT outer join account acc ON acc.acct_num=pt.trading_entity_num                                                                              
 --where (abs(fx_amount) > 0 OR abs(pl_currency)>0)                                      
order by real_port_num,trade_number,exp_date                                 

--Temp table to store priceCmdtyCode , primaryCuryCode and conv rate from priceCmdtyCode to primaryCuryCode
create table #cmdtyCurrToPrimaryCurrConvTable 
(
	ID1 int IDENTITY(1,1) PRIMARY KEY,
	cmdty_code char(8),
	prim_curr_code char(8),
	prim_curr_conv_rate float(8)
)                                                                                                  
   

insert into #cmdtyCurrToPrimaryCurrConvTable(cmdty_code,	prim_curr_code,prim_curr_conv_rate) 
(
	select distinct cmdty_code,  prim_curr_code, prim_curr_conv_rate from commodity where cmdty_code in (select distinct Currency from #fx_dump_final) and cmdty_code != prim_curr_code
)

-- print conv Rate Table
---select * from #cmdtyCurrToPrimaryCurrConvTable
--print before conv Values
---select * from #fx_dump_final

DECLARE @z int = (select MAX(ID1) from #cmdtyCurrToPrimaryCurrConvTable)

DECLARE @priceCmdtyCode char(8) = null
DECLARE @primCurrCode char(8) = null
DECLARE @rate float(8)
WHILE @z > 0
        BEGIN
            select @priceCmdtyCode =  cmdty_code,@primCurrCode = prim_curr_code , @rate =prim_curr_conv_rate  from #cmdtyCurrToPrimaryCurrConvTable t where t.ID1 = @z
            ---PRINT 'CmdtyCode = ' + @priceCmdtyCode
            --PRINT 'PrilimCurrCode = ' + @primCurrCode
            --PRINT   @rate
            IF ISNULL(@rate,0) > 0 
				BEGIN
				update #fx_dump_final set Currency = @primCurrCode , FXAmount = FXAmount * @rate where Currency = @priceCmdtyCode
				END
			SET @z = @z - 1
		END
--End of conversion
 
select * from #fx_dump_final                              
errexit:                                                                                
   if @errcode > 0                                                                                
      set @status = 2                                                                    
                                                                                   
endofsp:                                                                                
if object_id('tempdb.dbo.#children') is not null                                                                                
   exec('drop table #children')                           
if object_id('tempdb.dbo.#fx_dump') is not null                                                                                
   exec('drop table #fx_dump')          
if object_id('tempdb.dbo.#active_fx_ids') is not null                                                                                
   exec('drop table #active_fx_ids')                                                                                
if object_id('tempdb.dbo.#fx_dump_final') is not null                                                                                
   exec('drop table #fx_dump_final')   
if object_id('tempdb.dbo.#cmdtyCurrToPrimaryCurrConvTable') is not null                                                                                
   exec('drop table #cmdtyCurrToPrimaryCurrConvTable')                                                                                 
return @status   
GO
GRANT EXECUTE ON  [dbo].[usp_get_fx_data] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_fx_data', NULL, NULL
GO
