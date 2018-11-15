SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_BI_profit_loss]                  
(                  
real_port_num,                  
pl_asof_date,                  
pl_owner_code ,                   
pl_owner_sub_code,                  
pl_secondary_owner_key1,                  
pl_secondary_owner_key2,                  
pl_secondary_owner_key3,                   
pos_num,--pl_owner_code,pl_owner_sub_code,                  
pl_amt  ,                  
pl_mkt_price,                   
currency_fx_rate ,                   
book_entity_num,                  
open_qty,                   
total_sch_qty,                  
trading_prd ,                  
pl_type ,        
total_pl_no_sec_cost  ,      
tran_date   ,
trans_id            
)                  
AS                  
 select plh.port_num as real_port_num,plh.pl_asof_date,'','', 0,0,0,0,--pl_owner_code,pl_owner_sub_code,                  
       (isnull(open_phys_pl,0) +                  
  isnull(open_hedge_pl,0) +                  
  isnull(closed_phys_pl,0)+                  
  isnull(closed_hedge_pl,0)+                  
  isnull(other_pl ,0) +                  
  isnull(liq_open_phys_pl,0)+                   
  isnull(liq_open_hedge_pl,0)+                   
  isnull(liq_closed_phys_pl,0)+                   
  isnull(liq_closed_hedge_pl,0)) as pl_amt  ,0, 0, port.trading_entity_num,0,0,convert(char(4),getdate(),112)+'01','R',  isnull(total_pl_no_sec_cost,0)  ,      
  isnull(i.tran_date,dateadd(mm,-15,getdate()) )  ,plh.trans_id    
   from portfolio_profit_loss plh                    
   join portfolio port on port.port_num=plh.port_num and port_type='R' --and desired_pl_curr_code='USD'     
   LEFT OUTER join icts_transaction i ON plh.trans_id=i.trans_id      
   WHERE   plh.pl_curr_code='USD'  
union     
select plh.port_num as real_port_num,plh.pl_asof_date,'','', 0,0,0,0,--pl_owner_code,pl_owner_sub_code,                  
       (isnull(open_phys_pl,0) +                  
  isnull(open_hedge_pl,0) +                  
  isnull(closed_phys_pl,0)+                  
  isnull(closed_hedge_pl,0)+                  
  isnull(other_pl ,0) +                  
  isnull(liq_open_phys_pl,0)+                   
  isnull(liq_open_hedge_pl,0)+                   
  isnull(liq_closed_phys_pl,0)+                   
  isnull(liq_closed_hedge_pl,0)) *  isnull(avg_closed_price ,1) 'usd_equiv'   ,            
   0, 0, port.trading_entity_num,0,0,convert(char(4),getdate(),112)+'01','R',  isnull(total_pl_no_sec_cost,0)*   isnull(avg_closed_price ,1)  ,      
  isnull(i.tran_date,dateadd(mm,-15,getdate()) )  ,plh.trans_id    
   from portfolio_profit_loss plh                    
   join portfolio port on port.port_num=plh.port_num and port_type='R'    --and desired_pl_curr_code<>'USD'     
   join commodity_market cm on cm.cmdty_code=plh.pl_curr_code and cm.mkt_code='USD'  
   join price pr ON pr.commkt_key=cm.commkt_key and pr.price_quote_date=plh.pl_asof_date and trading_prd='SPOT'  and price_source_code='INTERNAL'   
   LEFT OUTER join icts_transaction i ON plh.trans_id=i.trans_id      
   WHERE plh.pl_curr_code<>'USD' 
union  
  
 select plh.port_num as real_port_num,plh.pl_asof_date,'','', 0,0,0,0,--pl_owner_code,pl_owner_sub_code,                  
       (isnull(open_phys_pl,0) +                  
  isnull(open_hedge_pl,0) +                  
  isnull(closed_phys_pl,0)+                  
  isnull(closed_hedge_pl,0)+                  
  isnull(other_pl ,0) +                  
  isnull(liq_open_phys_pl,0)+                   
  isnull(liq_open_hedge_pl,0)+                   
  isnull(liq_closed_phys_pl,0)+                   
  isnull(liq_closed_hedge_pl,0)) *    case when calc_oper='M' then conv_rate else 1/conv_rate end  'usd_equiv'   ,            
   0, 0, port.trading_entity_num,0,0,convert(char(4),getdate(),112)+'01','R',  isnull(total_pl_no_sec_cost,0)*    case when calc_oper='M' then conv_rate else 1/conv_rate end   ,      
  isnull(i.tran_date,dateadd(mm,-15,getdate()) )    ,plh.trans_id  
   from portfolio_profit_loss plh                    
   join portfolio port on port.port_num=plh.port_num and port_type='R'    --and desired_pl_curr_code<>'USD'     
 CROSS APPLY  dbo.udf_currency_exch_rate  (                          
                   convert(char,plh.pl_asof_date,101),       /* @asof_date */                          
                   plh.pl_curr_code  ,                /* @curr_code_from */                          
                   'USD',                /* @curr_code_to */                          
                   plh.pl_asof_date, /* @eff_date */                                             
                   'F' ,               /* @est_final_ind */                                     
                   convert(char(6),plh.pl_asof_date,112)                                            /* @trading_prd */                    
     )               
   LEFT OUTER join icts_transaction i ON plh.trans_id=i.trans_id      
   WHERE plh.pl_curr_code<>'USD'  
   and not exists (select 1   
      from  commodity_market cm  
      inner join price pr ON pr.commkt_key=cm.commkt_key and pr.price_quote_date=plh.pl_asof_date and trading_prd='SPOT' and  price_source_code='INTERNAL'   
      WHERE  cm.cmdty_code=plh.pl_curr_code and cm.mkt_code='USD'  
      )  
GO
GRANT SELECT ON  [dbo].[v_BI_profit_loss] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_BI_profit_loss', NULL, NULL
GO
