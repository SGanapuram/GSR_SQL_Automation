SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_update_cost_exch_rate]                                          
AS                                          
BEGIN                                                                             
--VOUCHED /PAID Cost in with Future Cost Due Date                                           
declare @oid              int                                          
declare @trans_id2        bigint                                          
declare @my_asof_date     varchar(10)                                          
declare @my_price_curr    char(8)                                          
declare @my_book_curr     char(8)                                          
declare @my_due_date      varchar(10)                                          
declare @my_est_final_ind char(1)                                          
                                           
create table #cost                                          
(                                               
      cost_num    int,                                          
      asof_date   varchar(10),                                          
      price_curr  char(8),                                          
      book_curr   char(8),                                          
      due_date    varchar(10),                                          
      est_final_ind     char(1)                                          
)                                          
                                           
create table #exch_rate                                          
(                                                              
      oid   int identity,                                          
      asof_date   varchar(10),                                          
      price_curr  char(8),                                          
      book_curr   char(8),                                          
      due_date    varchar(10),                                          
      est_final_ind     char(1),                                       
      rate  decimal(20,8) null,                                          
      dvd_mlt_ind char(1) null                                          
)                                          
                                           
insert into #cost                                                            
select      c.cost_num,                                                               
            convert(varchar,getDate(),101),                                                              
            c.cost_price_curr_code,                                                               
            isnull(p.desired_pl_curr_code,'USD'),                                                              
            convert(varchar,isnull(v.voucher_expected_pay_date,v.voucher_due_date),101),                                                               
            case when datediff(dd,convert(varchar,isnull(v.voucher_expected_pay_date,v.voucher_due_date),101), convert(varchar,getDate(),101)) > 0 then 'F' else 'E' end                                                              
from cost c, voucher_cost vc ,voucher v   , portfolio p                                                           
where c.cost_status in ( 'VOUCHED' )                                    
and v.voucher_num=vc.voucher_num                                                              
and vc.cost_num=c.cost_num                              
and c.port_num=p.port_num                                                          
and isnull(cost_price_curr_code,'USD')!=isnull(p.desired_pl_curr_code,'USD')                          
and isnull(v.voucher_expected_pay_date,v.voucher_due_date) >= convert(char,getdate () ,101)                                                          
and cost_amt<>0                                                            
and cost_type_code not like 'POMAX%'                                            
--and c.cost_num=3022429                        
--and cost_owner_key6=1584578                                                        
and not exists (select 1                                   
    from trade_item ti , trade_order to1             
    where ti.trade_num=c.cost_owner_key6                                                         
    and ti.order_num=c.cost_owner_key7                                                         
    and ti.item_num=c.cost_owner_key8                                         
    and ti.trade_num=to1.trade_num                                                         
    and ti.order_num=to1.order_num                                                         
    and order_type_code='CURRENCY'                                
    and isnull(ti.hedge_rate,0)=1)                                                        
                                           
          
          
--select * from #cost                                          
                                           
insert into #exch_rate (asof_date,price_curr,book_curr,due_date,est_final_ind)                                          
select distinct asof_date,price_curr,book_curr,due_date,est_final_ind                                           
from #cost                                          
                                           
                          
--select * from #exch_rate                                          
                                           
SELECT  @oid = min(oid) from #exch_rate                                          
                                           
            create table #convRateTbl                                          
            (                                         
                  rate  decimal(20,8),                                    
                  dvd_mlt_ind char(1)                                          
            )                                          
                                                                   
WHILE @oid is not null                                          
begin                                          
            select      @my_asof_date=asof_date,                                          
                        @my_price_curr=price_curr,                                          
                        @my_book_curr=book_curr,                                 
                        @my_due_date=due_date,                                          
                        @my_est_final_ind=est_final_ind                                          
            from #exch_rate where oid=@oid                                          
                                                 
            print @my_due_date                                          
            insert into #convRateTbl                                          
            exec usp_currency_exch_rate @asof_date=@my_asof_date,                                          
                             @curr_code_from = @my_price_curr,                                          
        @curr_code_to = @my_book_curr,                                          
                             @eff_date = @my_due_date,                                          
                             @est_final_ind = @my_est_final_ind                                          
                                           
            update er                                          
            set rate=t.rate , dvd_mlt_ind=t.dvd_mlt_ind                                          
            from #exch_rate er                                          
            cross join #convRateTbl t                                          
            where oid=@oid                                          
                                                      
            delete #convRateTbl                                          
            SELECT  @oid = min(oid) from #exch_rate where oid>@oid                                          
end                                          
                                           
begin tran                                          
      exec gen_new_transaction                                       
      select @trans_id2=last_num from icts_trans_sequence                                          
                                                
      update c                           
      set cost_book_exch_rate=rate,cost_xrate_conv_ind=dvd_mlt_ind,cost_book_curr_code=er.book_curr,trans_id=@trans_id2                                          
      from cost c                                          
      join #cost c1 on c1.cost_num=c.cost_num                                          
      join #exch_rate er on   c1.asof_date=er.asof_date and c1.price_curr=er.price_curr and               
        c1.book_curr=er.book_curr and c1.due_date=er.due_date and c1.est_final_ind=er.est_final_ind                                          
                                           
commit  tran                                          
                          
                                    
--PAID costs update                                          
begin tran                                          
                                           
declare @trans_id bigint                                          
exec gen_new_transaction                                
select @trans_id=last_num from icts_trans_sequence                                          
                                           
update c                                          
set c.cost_book_exch_rate=ecb.avg_closed_price,cost_xrate_conv_ind='M', trans_id=@trans_id   ,cost_book_curr_code=isnull(p.desired_pl_curr_code,'USD')                                       
from cost c                          
JOIN portfolio p ON p.port_num=c.port_num                                                 
, voucher_cost vc, --,portfolio_tag pt,                                          
voucher v                                          
JOIN price ecb on  ecb.trading_prd='SPOT' and ecb.commkt_key=248 and ecb.price_quote_date=convert(char,voucher_paid_date,101) and ecb.price_source_code='ECB'                                          
where voucher_paid_date>=dateadd(mm,-2,getdate()) and cost_status<>'CLOSED'       and voucher_paid_date>='08/06/2013'    
and v.voucher_num=vc.voucher_num                                          
and vc.cost_num=c.cost_num                                          
--and cost_type_code in('WPP','PO', 'PR')                                          
--and cost_type_code not in('CPP','CPR')                                            
and cost_type_code  not like 'POM%'                                          
and cost_price_curr_code='EURO'                                   
and isnull(p.desired_pl_curr_code,'USD')  ='USD'                        
--and pt.port_num=c.port_num                                          
--and tag_name='PRFTCNTR'                                          
and c.cost_status = 'PAID'                                          
and (ecb.avg_closed_price <> isnull(cost_book_exch_rate,0) or cost_xrate_conv_ind is null)                                          
and c.cost_num not in (1102459,1102463,1225030,1225033,1225348,1225354,1943793 ,2027943)                                          
and cost_amt <> 0                                          
and ecb.avg_closed_price is not null                                      
                                                                  
                                                                
                                                                
                                                                
update c                                          
set c.cost_book_exch_rate=ecb.avg_closed_price,cost_xrate_conv_ind='M', trans_id=@trans_id    ,cost_book_curr_code=isnull(p.desired_pl_curr_code,'USD')                         
from  cost c                             --,portfolio_tag pt                   
JOIN portfolio p ON p.port_num=c.port_num                                                 
--JOIN cost_ext_info cei ON cei.cost_num=c.cost_num and cost_pl_contribution_ind='Y'                   
JOIN voucher_cost vc ON vc.cost_num=c.cost_num                                                                
JOIN voucher v ON v.voucher_num=vc.voucher_num                                                                
JOIN commodity_market cm ON cm.cmdty_code=v.voucher_curr_code and cm.mkt_code=isnull(p.desired_pl_curr_code,'USD')                                                               
JOIN price ecb on  ecb.trading_prd='SPOT' and ecb.commkt_key=cm.commkt_key and ecb.price_quote_date=convert(char,voucher_paid_date,101) and ecb.price_source_code='INTERNAL'                                   
where voucher_paid_date<= getdate() and voucher_paid_date>=dateadd(mm,-2,getdate())  and voucher_paid_date>='08/06/2013'                                                              
and cost_status<>'CLOSED'                                        
--and cost_type_code  not in('CPP','CPR')           
and cost_type_code  not like 'POM%'                                                                
and isnull(c.cost_price_curr_code,'USD')<>isnull(p.desired_pl_curr_code,'USD')                          
--and pt.port_num=c.port_num                                        
--and tag_name='PRFTCNTR'                                        
and c.cost_status in ( 'PAID' )                                                                
and (ecb.avg_closed_price <> isnull(cost_book_exch_rate,0) or cost_xrate_conv_ind is null)   
and cost_amt <> 0                                        
and ecb.avg_closed_price is not null   
--and c.cost_num in (    3162033 ,  3132040)                               
and c.trans_id<@trans_id                                                                 
                                             
update c                                          
set c.cost_book_exch_rate=ecb.avg_closed_price,cost_xrate_conv_ind='M', trans_id=@trans_id    ,cost_book_curr_code=isnull(p.desired_pl_curr_code,'USD')                                                   
from  cost c                 --portfolio_tag pt       ,            
JOIN portfolio p ON p.port_num=c.port_num                                                 
--JOIN cost_ext_info cei ON cei.cost_num=c.cost_num and cost_pl_contribution_ind='Y'                                                                
JOIN voucher_cost vc ON vc.cost_num=c.cost_num                                                                
JOIN voucher v ON v.voucher_num=vc.voucher_num                                                    
JOIN commodity_market cm ON cm.cmdty_code=v.voucher_curr_code and cm.mkt_code='USD'                                                                
JOIN price ecb on  ecb.trading_prd='SPOT' and ecb.commkt_key=cm.commkt_key and ecb.price_quote_date=convert(char,voucher_paid_date,101) and ecb.price_source_code='INTERNAL'                                                
where voucher_paid_date is not null and voucher_paid_date>=dateadd(dd,-5,getdate())     and voucher_paid_date>='08/06/2013'                                                      
and cost_status<>'CLOSED'                                        
--and cost_type_code  not in('CPP','CPR')                                        
and cost_type_code  not like 'POM%'                                                                
and isnull(c.cost_price_curr_code,'USD')<>isnull(p.desired_pl_curr_code,'USD')                              
--and pt.port_num=c.port_num                                        
--and tag_name='PRFTCNTR'                                        
and c.cost_status in ( 'PAID' )                                                                
and cost_amt <> 0                                        
and ecb.avg_closed_price is not null                           
and (ecb.avg_closed_price <> isnull(cost_book_exch_rate,0) or cost_xrate_conv_ind is null)                                          
and c.trans_id<@trans_id                                                                 
                                        
  /*                                                                
update c                                          
set c.cost_book_exch_rate=ecb.avg_closed_price,cost_xrate_conv_ind='M', trans_id=@trans_id       ,cost_book_curr_code=isnull(p.desired_pl_curr_code,'USD')                                                
select tag_value 'PRFTCNTR', c.port_num, cost_num, cost_code, cost_status, case when cost_pay_rec_ind='P' then -1 else 1 end *cost_amt 'CostAmt',                       
cost_book_exch_rate 'ExchRate',cost_xrate_conv_ind 'M/DInd', avg_closed_price 'ExchRate', cost_due_date, cost_paid_date                                          
from  cost c                                                   ,   portfolio_tag pt               ,    
JOIN portfolio p ON p.port_num=c.port_num                                                 
JOIN price ecb on  ecb.trading_prd='SPOT' and ecb.commkt_key=248 and ecb.price_quote_date=convert(char,cost_due_date,101)  and ecb.price_source_code='ECB'                                          
where cost_due_date>=dateadd(mm,-2,getdate()) and cost_status<>'CLOSED'                                          
and cost_type_code  in('CPP','CPR')                                          
and cost_price_curr_code='EURO'                       and isnull(p.desired_pl_curr_code,'USD')='USD'                        
and pt.port_num=c.port_num                                          
and tag_name='PRFTCNTR'                                          
and c.cost_status in ( 'PAID' ,'VOUCHED')                                                                  
--and isnull(cost_book_exch_rate,0)<>avg_closed_price                                                            
and cost_amt <> 0                                   
and (ecb.avg_closed_price <> isnull(cost_book_exch_rate,0) or cost_xrate_conv_ind is null)                                          
and c.trans_id<@trans_id                                                                  
                                                                  
                                                                  
update c                                                                    
set c.cost_book_exch_rate=ecb.avg_closed_price,cost_xrate_conv_ind='M', trans_id=@trans_id     ,cost_book_curr_code=isnull(p.desired_pl_curr_code,'USD')                                                  
--select tag_value 'PRFTCNTR', c.port_num, cost_num, cost_code, cost_status, case when cost_pay_rec_ind='P' then -1 else 1 end *cost_amt 'CostAmt',                       
--cost_book_exch_rate 'ExchRate',cost_xrate_conv_ind 'M/DInd', avg_closed_price 'ExchRate' , cost_due_date, cost_paid_date                                         
from  cost c                                                      --portfolio_tag pt       ,            
JOIN portfolio p ON p.port_num=c.port_num                                                 
JOIN commodity_market cm ON cm.cmdty_code=c.cost_price_curr_code and cm.mkt_code=isnull(p.desired_pl_curr_code,'USD')                                                                 
JOIN price ecb on  ecb.trading_prd='SPOT' and ecb.commkt_key=cm.commkt_key and ecb.price_quote_date=convert(char,cost_due_date,101)  and ecb.price_source_code='INTERNAL'                                                  
where cost_due_date>=dateadd(mm,-2,getdate()) and cost_status<>'CLOSED'                                         
and cost_type_code  in('CPP','CPR')                                          
and cost_price_curr_code not in ('EURO')                             
and isnull(c.cost_price_curr_code,'USD')<>isnull(p.desired_pl_curr_code,'USD')                                          
--and pt.port_num=c.port_num                                                         
--and tag_name='PRFTCNTR'                                          
and c.cost_status in ( 'PAID' ,'VOUCHED')                                            
and (ecb.avg_closed_price <> isnull(cost_book_exch_rate,0) or cost_xrate_conv_ind is null)                                          
and c.trans_id<@trans_id                                    
                                              
                        
                        
update c                                                    
set c.cost_book_exch_rate=1/ecb.avg_closed_price,cost_xrate_conv_ind='M', trans_id=@trans_id     ,cost_book_curr_code=isnull(p.desired_pl_curr_code,'USD')                                                  
--select tag_value 'PRFTCNTR', c.port_num, cost_num, cost_code, cost_status,cost_type_code, cost_price_curr_code, isnull(p.desired_pl_curr_code,'USD'),                      
--case when cost_pay_rec_ind='P' then -1 else 1 end *cost_amt 'CostAmt', cost_book_exch_rate 'ExchRate',cost_xrate_conv_ind 'M/DInd', 1/avg_closed_price 'ExchRate'                                          
from  cost c                                                      --portfolio_tag pt       ,            
JOIN portfolio p ON p.port_num=c.port_num                                                 
JOIN commodity_market cm ON cm.cmdty_code=isnull(p.desired_pl_curr_code,'USD')  and cm.mkt_code=    c.cost_price_curr_code                                                             
JOIN price ecb on  ecb.trading_prd='SPOT' and ecb.commkt_key=cm.commkt_key and ecb.price_quote_date=convert(char,cost_due_date,101) and ecb.price_source_code='INTERNAL'                                                  
where cost_due_date>=dateadd(mm,-2,getdate()) and cost_status<>'CLOSED'                                         
and cost_type_code  in('CPP','CPR')                                          
--and cost_price_curr_code not in ('EURO')                             
and isnull(c.cost_price_curr_code,'USD')<>isnull(p.desired_pl_curr_code,'USD')                                                              
--and pt.port_num=c.port_num                                                         
--and tag_name='PRFTCNTR'                                          
and c.cost_status in ( 'PAID' ,'VOUCHED')                                            
and (ecb.avg_closed_price <> isnull(cost_book_exch_rate,0) or cost_xrate_conv_ind is null)                                          
and c.trans_id<@trans_id                                    
           */                   
                                                     
                                         
commit tran                                          
                                      
                                      
--VOUCHED costs with past due date                                          
                                           
begin tran                                          
                                           
declare @trans_id7 bigint                                          
exec gen_new_transaction                                      
select @trans_id7=last_num from icts_trans_sequence                                          
                                           
                          
                                      
                                
update c                                          
set c.cost_book_exch_rate=ecb.avg_closed_price,cost_xrate_conv_ind='M', trans_id=@trans_id7   ,cost_book_curr_code=isnull(p.desired_pl_curr_code,'USD')                                                    
from  cost c                                              --portfolio_tag pt       ,            
JOIN portfolio p ON p.port_num=c.port_num                                                 
JOIN commodity_market cm ON cm.cmdty_code=c.cost_price_curr_code and cm.mkt_code=isnull(p.desired_pl_curr_code,'USD')                     
JOIN price ecb on  ecb.trading_prd='SPOT' and ecb.commkt_key=cm.commkt_key and ecb.price_quote_date=convert(char,getdate(),101) and ecb.price_source_code='INTERNAL'                                                  
where cost_due_date>=dateadd(mm,-24,getdate()) and cost_status<>'CLOSED'                                         
--and cost_type_code  not in('CPP','CPR','INVROLL')                                          
and cost_type_code  not in('INVROLL')                   
and cost_type_code not like 'POM%'                                
and isnull(c.cost_price_curr_code,'USD')<>isnull(p.desired_pl_curr_code,'USD')                                                              
--and pt.port_num=c.port_num                                                         
--and tag_name='PRFTCNTR'                                          
and c.cost_status in ( 'VOUCHED')                                            
and cost_amt <> 0                                          
and c.cost_due_date < getdate ()                                      
and (ecb.avg_closed_price <> isnull(cost_book_exch_rate,0) or cost_xrate_conv_ind is null)                                          
and c.cost_num not in (1102459,1102463,1225030,1225033,1225348,1225354,1943793 ,2027943)                                          
and ecb.avg_closed_price is not null                                          
and c.trans_id<@trans_id7                                              
                                
--- Added for Cmdty=USD and Mkt is FX (for portfolios with desired P/L Non-USD                       
update c                                          
set c.cost_book_exch_rate=1/ecb.avg_closed_price,cost_xrate_conv_ind='M', trans_id=@trans_id7   ,cost_book_curr_code=isnull(p.desired_pl_curr_code,'USD')                                                    
from  cost c                                                      --portfolio_tag pt       ,            
JOIN portfolio p ON p.port_num=c.port_num                                                 
JOIN commodity_market cm ON cm.cmdty_code=isnull(p.desired_pl_curr_code,'USD') and cm.mkt_code=c.cost_price_curr_code                                                                  
JOIN price ecb on  ecb.trading_prd='SPOT' and ecb.commkt_key=cm.commkt_key and ecb.price_quote_date=convert(char,getdate(),101) and ecb.price_source_code='INTERNAL'                                                  
where cost_due_date>=dateadd(mm,-24,getdate()) and cost_status<>'CLOSED'                                         
--and cost_type_code  not in('CPP','CPR','INVROLL')                                          
and cost_type_code  not in('INVROLL')                                          
and cost_type_code not like 'POM%'                                
and isnull(c.cost_price_curr_code,'USD')<>isnull(p.desired_pl_curr_code,'USD')                       
and isnull(p.desired_pl_curr_code,'USD') <>'USD'                                                             
--and pt.port_num=c.port_num                                                       
--and tag_name='PRFTCNTR'                                          
and c.cost_status in ( 'VOUCHED')                                            
and cost_amt <> 0                                          
and c.cost_due_date < getdate ()                                      
and (ecb.avg_closed_price <> isnull(cost_book_exch_rate,0) or cost_xrate_conv_ind is null)                                          
and c.cost_num not in (1102459,1102463,1225030,1225033,1225348,1225354,1943793 ,2027943)                                          
and ecb.avg_closed_price is not null                                          
and c.trans_id<@trans_id7                                              
                           
                                           
commit tran                                          
                                           
              
-- Update all costs PAID/Partially Paid cost with a rate if the cost did not get a rate from above scripts (Paid on a holiday)--              
              
  update c              
  SET cost_book_exch_rate=conv_rate,              
   cost_xrate_conv_ind=calc_oper,              
   cost_book_curr_code=desired_pl_curr_code,              
   trans_id=@trans_id7              
  From cost c              
  INNER JOIN portfolio p ON p.port_num=c.port_num and c.cost_price_curr_code<>desired_pl_curr_code              
  INNER JOIN cost_ext_info cei ON cei.cost_num=c.cost_num and cost_pl_contribution_ind='Y'              
  INNER JOIN voucher_cost vc on vc.cost_num=c.cost_num               
  INNER JOIN voucher v on  v.voucher_num=vc.voucher_num                
  INNER JOIN               
  (select voucher_num, max(convert(datetime,convert(char,paid_date,101)))  paid_date  ,max(convert(datetime,convert(char,processed_date,101)))  processed_date                      
   from voucher_payment vp                      
   where paid_date<=getdate() and (paid_date>='08/01/2013' OR processed_date>='08/01/2013')                       
   group by voucher_num                      
   ) v_p ON v.voucher_num=v_p.voucher_num                 
  CROSS APPLY  udf_currency_exch_rate  (                                                                
   v_p.paid_date,  /* @asof_date */                                                                
   c.cost_price_curr_code,/* @curr_code_from */                                          
   desired_pl_curr_code,/* @curr_code_to */                                                              
   cost_paid_date ,  /* @eff_date */                                                               
   'F' ,/* @est_final_ind */                                                                  
   convert(char(6),isnull(paid_date,getdate()),112)   )                                                
  where (cost_status='PAID' OR isnull(cost_vouchered_amt,0)!=0  )              
  and v_p.paid_date<=getdate()              
  and isnull(cost_book_exch_rate,0) =0              
  and cost_amt<>0                                                            
  and cost_type_code not like 'POMAX%'                                                            
/*  and not exists (select 1 from v_price_detail pr where pr.trading_prd='SPOT' and pr.cmdty_code=c.cost_price_curr_code              
     and pr.price_quote_date=convert(char,cost_paid_date,101)  and pr.price_source_code='INTERNAL'                 
     )              
  and not exists (select 1 from v_price_detail pr where pr.trading_prd='SPOT' and pr.mkt_code=c.cost_price_curr_code              
     and pr.price_quote_date=convert(char,cost_paid_date,101)  and pr.price_source_code='INTERNAL'                 
     )   */           
  and processed_date>=dateadd(dd,-10,getdate())              
  and c.trans_id<@trans_id7              
            
              
---Set Calendar Month Avg Rate on FX CAD Swap  by updating the cost amount -- Subu = 05/08/2012                                      
                                      
begin tran                                      
                                       
                                                                 
 declare @trans_id4 bigint,@price_quote_date datetime, @avg_price float                                      
 exec gen_new_transaction                                      
 select @trans_id4=last_num from icts_trans_sequence                                      
 select @price_quote_date=max(price_quote_date) from price where commkt_key=3216 and price_source_code='CMA' and trading_prd='SPOT'                                      
                
 update cost set trans_id=@trans_id4, cost_amt=contr_qty*isnull(avg_closed_price,1)                                 
 -- select cost_amt,contr_qty,contr_qty *isnull(avg_closed_price,1), cost_amt*isnull(avg_closed_price,1)                                    
 from trade_item ti, trade_order to1, price p, cost c              
 where brkr_ref_num like '%FXSWAP'                                      
 and to1.trade_num=ti.trade_num                                      
 and to1.order_num=ti.order_num                                      
 and order_type_code='CURRENCY'                                
 and cmdty_code='CAD'                                      
 and risk_mkt_code='USD'                                      
 and price_quote_date =@price_quote_date                                          
 and p.commkt_key=3216 and price_source_code='CMA' and p.trading_prd='SPOT'                                      
 and substring(brkr_ref_num,1,6)=convert(char(6), price_quote_date,112)                              
 and cost_code='CAD'                                      
 and cost_price_curr_code='CAD'                                      
 and c.cost_owner_key6=ti.trade_num                                      
 and c.cost_owner_key7=ti.order_num                                      
 and c.cost_owner_key8=ti.item_num                                              
 and cost_status='OPEN'                                      
                                       
commit                                      
---Set Calendar Month Avg Rate on FX CAD Swap  by updating the cost amount -- Subu = 05/08/2012                                      
                                      
                                        
                                      
                                                    
                       
declare @oid1 int                                                    
                                                    
declare @my_asof_date1   varchar(10)                                                    
declare @my_price_curr1  char(8)                                                    
declare @my_book_curr1   char(8)                                                    
declare @my_due_date1    varchar(10)                                              
declare @my_est_final_ind1     char(1)                                                    
                                                    
create table #exch_rate1                                                    
(                                                         
      oid   int identity,                                                    
      asof_date   varchar(10),                                                    
      price_curr  char(8),              
      book_curr   char(8),                                                    
      due_date    varchar(10),                                                    
      est_final_ind     char(1),                                                    
      rate  decimal(20,8) null,                                                    
      dvd_mlt_ind char(1) null                                                    
)                                                    
                                          
insert into #exch_rate1 (asof_date,price_curr,book_curr,due_date,est_final_ind)                               
select distinct convert(varchar,last_trade_date,101),price_curr_code,isnull(desired_pl_curr_code,'USD'),convert(varchar,last_trade_date,101),'F'                                                    
from trade_item ti                                 
JOIN portfolio p ON p.port_num=ti.real_port_num                                                 
join trade_item_dist tid on ti.trade_num=tid.trade_num and ti.order_num=tid.order_num and ti.item_num=tid.item_num                                                    
join trading_period tp on tp.commkt_key=tid.commkt_key and tp.trading_prd=tid.trading_prd                                                    
where item_type in ('F','E','O') and isnull(price_curr_code,'USD')<>isnull(desired_pl_curr_code,'USD')                          
and last_trade_date<= convert(char,getdate(),101)              
and last_trade_date>='12/1/2012'                                           
and ti.real_port_num<>343668                  
--and ti.trade_num= 1868428                                          
                                       
                          
                                                    
                                        
SELECT  @oid1 = min(oid) from #exch_rate1                                                    
                                                    
            create table #convRateTbl1                                                    
            (                                                    
                  rate  decimal(20,8),                                                    
                  dvd_mlt_ind char(1)                                                    
            )                   
                                                    
WHILE @oid1 is not null                                                    
begin                                                    
            select      @my_asof_date1=asof_date,                                                    
      @my_price_curr1=price_curr,                                                    
  @my_book_curr1=book_curr,                                                    
                        @my_due_date1=due_date,                                                    
                        @my_est_final_ind1=est_final_ind                                                    
            from #exch_rate1 where oid=@oid1                                                    
                                          
            print @my_due_date1                                                    
            insert into #convRateTbl1                                                    
            exec usp_currency_exch_rate @asof_date=@my_due_date1,                                                    
                             @curr_code_from = @my_price_curr1,                                                    
                             @curr_code_to = @my_book_curr1,                                                    
        @eff_date = @my_due_date1,                                                    
                             @est_final_ind = @my_est_final_ind1                                                    
            update er                                                    
            set rate=t.rate , dvd_mlt_ind=t.dvd_mlt_ind                                                    
            from #exch_rate1 er                                                    
            cross join #convRateTbl1 t                                                    
            where oid=@oid1                                                    
                                                   
            delete #convRateTbl1                                                    
            SELECT  @oid1 = min(oid) from #exch_rate1 where oid>@oid1                                                    
end                                                    
                                                    
select *  from #exch_rate1                                                    
                                                    
                                                    
begin tran                                                    
declare @trans_id1 bigint                                                    
      exec gen_new_transaction                                                    
      select @trans_id1=last_num from icts_trans_sequence                                                   
                                                    
      update ti                               
      set hedge_rate= (case er.dvd_mlt_ind when 'M' then 1/rate else rate end),hedge_curr_code=book_curr,hedge_multi_div_ind='D', trans_id=@trans_id1                                                    
      from trade_item ti                                                    
      join trade_item_dist tid on ti.trade_num=tid.trade_num and ti.order_num=tid.order_num and ti.item_num=tid.item_num                                                    
      join trading_period tp on tp.commkt_key=tid.commkt_key and tp.trading_prd=tid.trading_prd                                                    
      join #exch_rate1 er on tp.last_trade_date=er.asof_date and er.price_curr=ti.price_curr_code                                                   
      where item_type in ('F','E','O') and price_curr_code not in ('USC','USD')                                                     
      and last_trade_date< getDate()                                                   
      and last_trade_date>='12/1/2012'                                                
      and (hedge_rate is null or hedge_rate<>  (case er.dvd_mlt_ind when 'M' then 1/rate else rate end))                    
                                                
commit tran                                                    
                                                    
--Cost PAID/Partially paid in the past processed in last 1 month          
             
SELECT @oid =0,@trans_id2 =0,@my_asof_date   ='',@my_price_curr  ='',@my_book_curr='',@my_due_date='',@my_est_final_ind=''          
                                           
delete #cost                                          
delete #exch_rate            
delete #convRateTbl                                        
                                           
insert into #cost                                                            
select      c.cost_num,                                                               
            convert(varchar,isnull(vp.paid_date,v.voucher_expected_pay_date),101),                                                              
            c.cost_price_curr_code,                                                               
         isnull(p.desired_pl_curr_code,'USD'),                                                              
            convert(varchar,isnull(vp.paid_date,v.voucher_expected_pay_date),101),                                                               
            case when datediff(dd,convert(varchar,isnull(v.voucher_expected_pay_date,v.voucher_due_date),101), convert(varchar,getDate(),101)) > 0 then 'F' else 'E' end                                                              
from cost c, voucher_cost vc ,          
voucher v             
INNER JOIN (select voucher_num, max(processed_date) processed_date,max(paid_date) paid_date          
   from voucher_payment           
   where isnull(voucher_pay_amt,0)<>0 group by voucher_num)           
vp ON vp.voucher_num=v.voucher_num           
, portfolio p                                                           
where c.cost_status in ( 'VOUCHED','PAID' )                                    
and v.voucher_num=vc.voucher_num                                                              
and vc.cost_num=c.cost_num                              
and c.port_num=p.port_num                                       
and isnull(cost_price_curr_code,'USD')!=isnull(p.desired_pl_curr_code,'USD')                          
and isnull(vp.processed_date,vp.paid_date) >= dateadd(mm,-1,getdate())                                             
and cost_amt<>0                                                            
and cost_type_code not like 'POMAX%'                                                            
and isnull(cost_book_exch_rate,1)=1          
          
          
--select * from #cost                                          
                                           
insert into #exch_rate (asof_date,price_curr,book_curr,due_date,est_final_ind)                                          
select distinct asof_date,price_curr,book_curr,due_date,est_final_ind                                           
from #cost                                          
                                           
                          
--select * from #exch_rate             
                                           
SELECT  @oid = min(oid) from #exch_rate                                          
                                           
                                       
WHILE @oid is not null                                          
begin                                          
            select      @my_asof_date=asof_date,                                          
                        @my_price_curr=price_curr,                                          
                        @my_book_curr=book_curr,                                 
                        @my_due_date=due_date,                                          
                        @my_est_final_ind=est_final_ind                                          
            from #exch_rate where oid=@oid                                          
                                                 
            print @my_due_date                             
            insert into #convRateTbl                                          
            exec usp_currency_exch_rate @asof_date=@my_asof_date,                                          
                             @curr_code_from = @my_price_curr,                                          
        @curr_code_to = @my_book_curr,                                          
                             @eff_date = @my_due_date,                                          
                             @est_final_ind = @my_est_final_ind                                          
                                           
            update er                                          
            set rate=t.rate , dvd_mlt_ind=t.dvd_mlt_ind                                          
            from #exch_rate er                                          
            cross join #convRateTbl t                                          
            where oid=@oid                                          
                                                      
            delete #convRateTbl                                                  SELECT  @oid = min(oid) from #exch_rate where oid>@oid                                          
end                                          
                                           
begin tran                                          
      exec gen_new_transaction                                          
      select @trans_id2=last_num from icts_trans_sequence                                          
                                                
      update c                                          
      set cost_book_exch_rate=rate,cost_xrate_conv_ind=dvd_mlt_ind,cost_book_curr_code=er.book_curr,trans_id=@trans_id2                                          
      from cost c                                          
      join #cost c1 on c1.cost_num=c.cost_num                                          
      join #exch_rate er on   c1.asof_date=er.asof_date and c1.price_curr=er.price_curr and                                           
        c1.book_curr=er.book_curr and c1.due_date=er.due_date and c1.est_final_ind=er.est_final_ind                                          
                                           
commit  tran                                          
                          
                
                                           
drop table #convRateTbl                                          
drop table #cost                                          
drop table #exch_rate                                          
drop table #exch_rate1                                                    
drop table #convRateTbl1                                                    
          
          
          
                                           
END                                          
GO
GRANT EXECUTE ON  [dbo].[usp_update_cost_exch_rate] TO [next_usr]
GO
