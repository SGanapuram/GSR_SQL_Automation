SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_compare_position]      
  @resp_trans_id_NEW     int,      
  @resp_trans_id_OLD       int,      
  @portnum                int = null,      
  @digits_for_scale4      tinyint = 4,      
  @digits_for_scale7      tinyint = 7        
as      
set nocount on      
      
   print ' '      
   print '==================================================='      
   print ' DATA : position'      
   print '==================================================='      
   print ' '      
      
   select  resp_trans_id,    
pos_num               ,  
real_port_num         ,  
pos_type              ,  
is_equiv_ind          ,  
what_if_ind           ,  
commkt_key            ,  
trading_prd           ,  
cmdty_code            ,  
mkt_code              ,  
formula_num           ,  
formula_name          ,  
option_type           ,  
settlement_type       ,  
str(strike_price, 38, @digits_for_scale4) as strike_price,  
strike_price_curr_code,  
strike_price_uom_code,  
put_call_ind         ,  
opt_exp_date         ,  
opt_start_date       ,  
opt_periodicity      ,  
opt_price_source_code,  
acct_short_name      ,  
desired_opt_eval_method,  
desired_otc_opt_code   ,  
is_hedge_ind           ,  
str(long_qty, 38, @digits_for_scale4) as long_qty,  
str(short_qty, 38, @digits_for_scale4) as short_qty,  
str(discount_qty, 38, @digits_for_scale4) as discount_qty,  
str(priced_qty, 38, @digits_for_scale4) as priced_qty,  
qty_uom_code           ,  
str(avg_purch_price, 38, @digits_for_scale4) as avg_purch_price,  
str(avg_sale_price, 38, @digits_for_scale4) as avg_sale_price,  
price_curr_code        ,  
price_uom_code         ,  
str(sec_long_qty, 38, @digits_for_scale4) as sec_long_qty,  
str(sec_short_qty, 38, @digits_for_scale4) as sec_short_qty,  
str(sec_discount_qty, 38, @digits_for_scale4) as sec_discount_qty,  
str(sec_priced_qty, 38, @digits_for_scale4) as sec_priced_qty,  
sec_pos_uom_code       ,  
trans_id               ,  
pos_status             ,  
str(last_mtm_price, 38, @digits_for_scale7) as last_mtm_price,  
str(rolled_qty, 38, @digits_for_scale7) as rolled_qty,  
str(sec_rolled_qty, 38, @digits_for_scale7) as sec_rolled_qty,  
is_cleared_ind         ,  
formula_body_num       ,  
equiv_source_ind       ,  
str(mkt_long_qty, 38, @digits_for_scale4) as mkt_long_qty,  
str(mkt_short_qty, 38, @digits_for_scale4) as mkt_short_qty,  
str(sec_mkt_long_qty, 38, @digits_for_scale4) as sec_mkt_long_qty,  
str(sec_mkt_short_qty, 38, @digits_for_scale4) as sec_mkt_short_qty  
  into #position    
  from dbo.aud_position     
           where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and       
        1 = case when @portnum is null then 1        
                 else 0      
            end      
                  
select       
min(resp_trans_id) as resp_trans_id,         
pos_num,  
real_port_num,  
pos_type  ,  
is_equiv_ind ,  
what_if_ind  ,  
commkt_key  ,  
trading_prd  ,  
cmdty_code  ,  
mkt_code  ,  
formula_num  ,  
formula_name ,  
option_type  ,  
settlement_type,  
strike_price,  
strike_price_curr_code,  
strike_price_uom_code ,  
put_call_ind    ,  
opt_exp_date    ,  
opt_start_date    ,  
opt_periodicity    ,  
opt_price_source_code ,  
acct_short_name    ,  
desired_opt_eval_method,  
desired_otc_opt_code   ,  
is_hedge_ind     ,  
long_qty      ,  
short_qty      ,  
discount_qty     ,  
priced_qty      ,  
qty_uom_code     ,  
avg_purch_price     ,  
avg_sale_price     ,  
price_curr_code     ,  
price_uom_code     ,  
sec_long_qty     ,  
sec_short_qty     ,  
sec_discount_qty    ,  
sec_priced_qty     ,  
sec_pos_uom_code    ,  
min(trans_id) as trans_id1,  
pos_status      ,  
last_mtm_price     ,  
rolled_qty      ,  
sec_rolled_qty     ,  
is_cleared_ind     ,  
formula_body_num    ,  
equiv_source_ind    ,  
mkt_long_qty     ,  
mkt_short_qty     ,  
sec_mkt_long_qty    ,  
sec_mkt_short_qty  
  into #position1      
   from #position  
 group by pos_num,real_port_num,pos_type,is_equiv_ind ,what_if_ind ,  
  commkt_key,trading_prd,cmdty_code,mkt_code,formula_num,formula_name ,  
  option_type,settlement_type,strike_price,strike_price_curr_code,strike_price_uom_code,  
  put_call_ind,opt_exp_date,opt_start_date,opt_periodicity,opt_price_source_code,  
  acct_short_name,desired_opt_eval_method,desired_otc_opt_code,is_hedge_ind,  
  long_qty,short_qty,discount_qty,priced_qty,qty_uom_code,avg_purch_price,avg_sale_price,  
  price_curr_code,price_uom_code,sec_long_qty,sec_short_qty,sec_discount_qty,sec_priced_qty,  
  sec_pos_uom_code,pos_status,last_mtm_price,rolled_qty,sec_rolled_qty,is_cleared_ind,  
  formula_body_num,equiv_source_ind,mkt_long_qty,mkt_short_qty,sec_mkt_long_qty,sec_mkt_short_qty  
  having count(*) = 1 order by pos_num  
      
 drop table #position      
 -- write changed columns   

select       
'DIFFCOLS' as PASS,      
b.resp_trans_id,      
b.pos_num,  
b.real_port_num,  
case when isnull(a.pos_type,'@') <> isnull(b.pos_type,'@')  
   then 'pos_type'
   else ' ' end +
case when isnull(a.is_equiv_ind,'@') <> isnull(b.is_equiv_ind,'@')  
   then ',is_equiv_ind'
   else ' ' end +
case when isnull(a.what_if_ind,'@') <> isnull(b.what_if_ind,'@')  
   then ',what_if_ind'
   else ' ' end +
case when isnull(a.commkt_key, -1)  <>  isnull(b.commkt_key, -1)    
           then ',commkt_key'
    else  ' ' end +
case when isnull(a.trading_prd, '@@@')  <>  isnull(b.trading_prd, '@@@')    
           then ',trading_prd'
    else  ' ' end +
case when isnull(a.cmdty_code, '@@@')  <>  isnull(b.cmdty_code, '@@@')    
           then ',cmdty_code'
    else  ' ' end +
case when isnull(a.mkt_code, '@@@')  <>  isnull(b.mkt_code, '@@@')    
           then ',mkt_code'
    else  ' ' end +
case when isnull(a.formula_num, -1)  <>  isnull(b.formula_num, -1)    
           then ',formula_num'
    else  ' ' end +
case when isnull(a.formula_name, '@@@')  <>  isnull(b.formula_name, '@@@')    
           then ',formula_name'
    else  ' ' end +
case when isnull(a.option_type, '@')  <>  isnull(b.option_type, '@')    
           then ',option_type'
    else  ' ' end +
case when isnull(a.settlement_type, '@')  <>  isnull(b.settlement_type, '@')    
           then ',settlement_type'
    else  ' ' end +
case when isnull(a.strike_price, '@@@')  <>  isnull(b.strike_price, '@@@')    
           then ',strike_price'
    else  ' ' end +
case when isnull(a.strike_price_curr_code, '@@@')  <>  isnull(b.strike_price_curr_code, '@@@')    
           then ',strike_price_curr_code'
    else  ' ' end +
case when isnull(a.strike_price_uom_code, '@@@')  <>  isnull(b.strike_price_uom_code, '@@@')    
           then ',strike_price_uom_code'
    else  ' ' end +
case when isnull(a.put_call_ind, '@')  <>  isnull(b.put_call_ind, '@')    
           then ',put_call_ind'
    else  ' ' end +
case when isnull(a.opt_exp_date, '01/01/2015')  <>  isnull(b.opt_exp_date, '01/01/2015')    
           then ',opt_exp_date'
    else  ' ' end +
case when isnull(a.opt_start_date, '01/01/2015')  <>  isnull(b.opt_start_date, '01/01/2015')    
           then ',opt_start_date'
    else  ' ' end +
case when isnull(a.opt_periodicity, '@@@')  <>  isnull(b.opt_periodicity, '@@@')    
           then ',opt_periodicity'
    else  ' ' end +
case when isnull(a.opt_price_source_code, '@@@')  <>  isnull(b.opt_price_source_code, '@@@')    
           then ',opt_price_source_code'
    else  ' ' end +
case when isnull(a.acct_short_name, '@@@') <> isnull(b.acct_short_name,'@@@')  
   then ',acct_short_name'
    else  ' ' end +
case when isnull(a.desired_opt_eval_method,'@') <> isnull(b.desired_opt_eval_method,'@')  
   then ',desired_opt_eval_method'
   else ' ' end +
case when isnull(a.desired_otc_opt_code, '@') <> isnull(b.desired_otc_opt_code,'@')  
   then ',desired_otc_opt_code'
   else ' ' end +
case when isnull(a.is_hedge_ind, '@')  <>  isnull(b.is_hedge_ind, '@')    
           then ',is_hedge_ind'
    else  ' ' end +
  
case when isnull(a.long_qty, '@@@')  <>  isnull(b.long_qty, '@@@')    
           then ',long_qty'
    else  ' ' end +
case when isnull(a.short_qty, '@@@')  <>  isnull(b.short_qty, '@@@')    
           then ',short_qty'
        else  ' ' end +
case when isnull(a.discount_qty, '@@@')  <>  isnull(b.discount_qty, '@@@')    
           then ',discount_qty'
           else  ' ' end +
case when isnull(a.priced_qty, '@@@')  <>  isnull(b.priced_qty, '@@@')    
           then ',priced_qty'
           else  ' ' end +
case when isnull(a.qty_uom_code, '@@@')  <>  isnull(b.qty_uom_code, '@@@')    
           then ',qty_uom_code'
           else  ' ' end +
case when isnull(a.avg_purch_price, '@@@')  <>  isnull(b.avg_purch_price, '@@@')    
           then ',avg_purch_price'
           else  ' ' end +  
case when isnull(a.avg_sale_price, '@@@')  <>  isnull(b.avg_sale_price, '@@@')    
           then ',avg_sale_price'
           else  ' ' end +
case when isnull(a.price_curr_code, '@@@')  <>  isnull(b.price_curr_code, '@@@')    
           then ',price_curr_code'
           else  ' ' end +
case when isnull(a.price_uom_code, '@@@')  <>  isnull(b.price_uom_code, '@@@')    
           then ',price_uom_code'
           else  ' ' end +
case when isnull(a.sec_long_qty, '@@@')  <>  isnull(b.sec_long_qty, '@@@')    
           then ',sec_long_qty'
           else  ' ' end +
case when isnull(a.sec_short_qty, '@@@')  <>  isnull(b.sec_short_qty, '@@@')    
           then ',sec_short_qty'
           else  ' ' end +
case when isnull(a.sec_discount_qty, '@@@')  <>  isnull(b.sec_discount_qty, '@@@')    
           then ',sec_discount_qty'
           else  ' ' end +  
case when isnull(a.sec_priced_qty, '@@@')  <>  isnull(b.sec_priced_qty, '@@@')    
           then ',sec_priced_qty'
           else  ' ' end +  
case when isnull(a.sec_pos_uom_code, '@@@')  <>  isnull(b.sec_pos_uom_code, '@@@')    
           then ',sec_pos_uom_code'
           else  ' ' end +
case when isnull(a.pos_status, '@@@')  <>  isnull(b.pos_status, '@@@')    
           then ',pos_status'
           else  ' ' end +
case when isnull(a.last_mtm_price, '@@@')  <>  isnull(b.last_mtm_price, '@@@')    
           then ',last_mtm_price'
           else  ' ' end +
case when isnull(a.rolled_qty, '@@@')  <>  isnull(b.rolled_qty, '@@@')    
           then ',rolled_qty'
           else  ' ' end +
case when isnull(a.sec_rolled_qty, '@@@')  <>  isnull(b.sec_rolled_qty, '@@@')    
           then ',sec_rolled_qty'
           else  ' ' end +
case when isnull(a.is_cleared_ind, '@')  <>  isnull(b.is_cleared_ind, '@')    
           then ',is_cleared_ind'
           else  ' ' end  +  
case when isnull(a.formula_body_num, -1)  <>  isnull(b.formula_body_num, -1)    
           then ',formula_body_num'
           else  ' ' end +  
case when isnull(a.equiv_source_ind, '@') <> isnull(b.equiv_source_ind,'@')  
   then ',equiv_source_ind'
   else ' ' end +
case when isnull(a.mkt_long_qty, '@@@') <> isnull(b.mkt_long_qty, '@@@')  
   then ',mkt_long_qty'
   else ' ' end +
case when isnull(a.mkt_short_qty, '@@@') <> isnull(b.mkt_short_qty, '@@@')  
   then ',mkt_short_qty'
   else ' ' end +
case when isnull(a.sec_mkt_long_qty, '@@@') <> isnull(b.sec_mkt_long_qty, '@@@')  
   then ',sec_mkt_long_qty'
   else ' ' end +
case when isnull(a.sec_mkt_short_qty, '@@@') <> isnull(b.sec_mkt_short_qty, '@@@')  
   then ',sec_mkt_short_qty'
   else ' ' end as diffColList    
 into #diffColList    
  from (select *      
        from  #position1      
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *      
        from  #position1      
        where resp_trans_id = @resp_trans_id_OLD) b       
  where  a.pos_num = b.pos_num  

   -- finish write changed columns.  
  
 select       
'NEW' as PASS,      
pos.resp_trans_id,  
diffColList,   
pos.pos_num,  
pos.real_port_num,  
pos_type  ,  
is_equiv_ind ,  
what_if_ind  ,  
str(commkt_key) as  commkt_key,  
trading_prd  ,  
cmdty_code  ,  
mkt_code  ,  
formula_num  ,  
formula_name ,  
option_type  ,  
settlement_type,  
strike_price,  
strike_price_curr_code,  
strike_price_uom_code ,  
put_call_ind,  
convert(varchar, opt_exp_date, 101) as opt_exp_date,  
convert(varchar, opt_start_date, 101) as opt_start_date,  
opt_periodicity    ,  
opt_price_source_code ,  
acct_short_name    ,  
desired_opt_eval_method,  
desired_otc_opt_code   ,  
is_hedge_ind     ,  
long_qty      ,  
short_qty      ,  
discount_qty     ,  
priced_qty      ,  
qty_uom_code     ,  
avg_purch_price     ,  
avg_sale_price     ,  
price_curr_code     ,  
price_uom_code     ,  
sec_long_qty     ,  
sec_short_qty     ,  
sec_discount_qty    ,  
sec_priced_qty     ,  
sec_pos_uom_code    ,  
pos_status      ,  
last_mtm_price     ,  
rolled_qty      ,  
sec_rolled_qty     ,  
is_cleared_ind     ,  
formula_body_num    ,  
equiv_source_ind    ,  
mkt_long_qty     ,  
mkt_short_qty     ,  
sec_mkt_long_qty    ,  
sec_mkt_short_qty,  
trans_id1      
from  #position1 pos left outer join #diffColList difc    
on pos.pos_num = difc.pos_num
where pos.resp_trans_id = @resp_trans_id_NEW      
union            
select       
'OLD' as PASS,      
b.resp_trans_id,
diffColList,       
b.pos_num,  
b.real_port_num,  
case when isnull(a.pos_type,'@') <> isnull(b.pos_type,'@')  
   then b.pos_type  
   else ' '  
end as pos_type,  
case when isnull(a.is_equiv_ind,'@') <> isnull(b.is_equiv_ind,'@')  
   then b.is_equiv_ind  
   else ' '  
end as is_equiv_ind,  
case when isnull(a.what_if_ind,'@') <> isnull(b.what_if_ind,'@')  
   then b.what_if_ind  
   else ' '  
end as what_if_ind,  
case when isnull(a.commkt_key, -1)  <>  isnull(b.commkt_key, -1)    
           then str(b.commkt_key)    
           else  ' '    
end as commkt_key,   
case when isnull(a.trading_prd, '@@@')  <>  isnull(b.trading_prd, '@@@')    
           then b.trading_prd    
           else  ' '    
end as trading_prd,    
case when isnull(a.cmdty_code, '@@@')  <>  isnull(b.cmdty_code, '@@@')    
           then b.cmdty_code    
           else  ' '    
end as cmdty_code,    
case when isnull(a.mkt_code, '@@@')  <>  isnull(b.mkt_code, '@@@')    
           then b.mkt_code    
           else  ' '    
end as mkt_code,    
case when isnull(a.formula_num, -1)  <>  isnull(b.formula_num, -1)    
           then str(b.formula_num)  
           else  ' '    
end as formula_num,    
case when isnull(a.formula_name, '@@@')  <>  isnull(b.formula_name, '@@@')    
           then b.formula_name    
           else  ' '    
end as formula_name,    
case when isnull(a.option_type, '@')  <>  isnull(b.option_type, '@')    
           then b.option_type    
           else  ' '    
end as option_type,    
case when isnull(a.settlement_type, '@')  <>  isnull(b.settlement_type, '@')    
           then b.settlement_type    
           else  ' '    
end as settlement_type,    
case when isnull(a.strike_price, '@@@')  <>  isnull(b.strike_price, '@@@')    
           then b.strike_price    
           else  ' '    
end as strike_price,    
case when isnull(a.strike_price_curr_code, '@@@')  <>  isnull(b.strike_price_curr_code, '@@@')    
           then b.strike_price_curr_code    
           else  ' '    
end as strike_price_curr_code,    
case when isnull(a.strike_price_uom_code, '@@@')  <>  isnull(b.strike_price_uom_code, '@@@')    
           then b.strike_price_uom_code    
           else  ' '    
end as strike_price_uom_code,    
case when isnull(a.put_call_ind, '@')  <>  isnull(b.put_call_ind, '@')    
           then b.put_call_ind    
           else  ' '    
end as put_call_ind,    
case when isnull(a.opt_exp_date, '01/01/2015')  <>  isnull(b.opt_exp_date, '01/01/2015')    
           then convert(varchar, b.opt_exp_date, 101)   
           else  ' '    
end as opt_exp_date,    
case when isnull(a.opt_start_date, '01/01/2015')  <>  isnull(b.opt_start_date, '01/01/2015')    
           then convert(varchar, b.opt_start_date, 101)  
           else  ' '    
end as opt_start_date,  
case when isnull(a.opt_periodicity, '@@@')  <>  isnull(b.opt_periodicity, '@@@')    
           then b.opt_periodicity    
           else  ' '    
end as opt_periodicity,  
case when isnull(a.opt_price_source_code, '@@@')  <>  isnull(b.opt_price_source_code, '@@@')    
           then b.opt_price_source_code    
           else  ' '    
end as opt_price_source_code,  
case when isnull(a.acct_short_name, '@@@') <> isnull(b.acct_short_name,'@@@')  
   then b.acct_short_name    
           else  ' '    
end as acct_short_name,  
case when isnull(a.desired_opt_eval_method,'@') <> isnull(b.desired_opt_eval_method,'@')  
   then b.desired_opt_eval_method  
   else ' '  
end as desired_opt_eval_method,  
case when isnull(a.desired_otc_opt_code, '@') <> isnull(b.desired_otc_opt_code,'@')  
   then b.desired_otc_opt_code  
   else ' '  
end as desired_otc_opt_code,  
case when isnull(a.is_hedge_ind, '@')  <>  isnull(b.is_hedge_ind, '@')    
           then b.is_hedge_ind    
           else  ' '    
end as is_hedge_ind,  
  
case when isnull(a.long_qty, '@@@')  <>  isnull(b.long_qty, '@@@')    
           then b.long_qty    
           else  ' '    
end as long_qty,  
case when isnull(a.short_qty, '@@@')  <>  isnull(b.short_qty, '@@@')    
           then b.short_qty    
           else  ' '    
end as short_qty,  
case when isnull(a.discount_qty, '@@@')  <>  isnull(b.discount_qty, '@@@')    
           then b.discount_qty    
           else  ' '    
end as discount_qty,  
case when isnull(a.priced_qty, '@@@')  <>  isnull(b.priced_qty, '@@@')    
           then b.priced_qty    
           else  ' '    
end as priced_qty,  
case when isnull(a.qty_uom_code, '@@@')  <>  isnull(b.qty_uom_code, '@@@')    
           then b.qty_uom_code    
           else  ' '    
end as qty_uom_code,  
case when isnull(a.avg_purch_price, '@@@')  <>  isnull(b.avg_purch_price, '@@@')    
           then b.avg_purch_price    
           else  ' '    
end as avg_purch_price,  
case when isnull(a.avg_sale_price, '@@@')  <>  isnull(b.avg_sale_price, '@@@')    
           then b.avg_sale_price    
           else  ' '    
end as avg_sale_price,  
case when isnull(a.price_curr_code, '@@@')  <>  isnull(b.price_curr_code, '@@@')    
           then b.price_curr_code    
           else  ' '    
end as price_curr_code,  
case when isnull(a.price_uom_code, '@@@')  <>  isnull(b.price_uom_code, '@@@')    
           then b.price_uom_code    
           else  ' '    
end as price_uom_code,  
case when isnull(a.sec_long_qty, '@@@')  <>  isnull(b.sec_long_qty, '@@@')    
           then b.sec_long_qty    
           else  ' '    
end as sec_long_qty,  
case when isnull(a.sec_short_qty, '@@@')  <>  isnull(b.sec_short_qty, '@@@')    
           then b.sec_short_qty    
           else  ' '    
end as sec_short_qty,  
case when isnull(a.sec_discount_qty, '@@@')  <>  isnull(b.sec_discount_qty, '@@@')    
           then b.sec_discount_qty    
           else  ' '    
end as sec_discount_qty,  
case when isnull(a.sec_priced_qty, '@@@')  <>  isnull(b.sec_priced_qty, '@@@')    
           then b.sec_priced_qty    
           else  ' '    
end as sec_priced_qty,  
case when isnull(a.sec_pos_uom_code, '@@@')  <>  isnull(b.sec_pos_uom_code, '@@@')    
           then b.sec_pos_uom_code    
           else  ' '    
end as sec_pos_uom_code,  
case when isnull(a.pos_status, '@@@')  <>  isnull(b.pos_status, '@@@')    
           then b.pos_status    
           else  ' '    
end as pos_status,  
case when isnull(a.last_mtm_price, '@@@')  <>  isnull(b.last_mtm_price, '@@@')    
           then b.last_mtm_price    
           else  ' '    
end as last_mtm_price,  
case when isnull(a.rolled_qty, '@@@')  <>  isnull(b.rolled_qty, '@@@')    
           then b.rolled_qty    
           else  ' '    
end as rolled_qty,  
case when isnull(a.sec_rolled_qty, '@@@')  <>  isnull(b.sec_rolled_qty, '@@@')    
           then b.sec_rolled_qty    
           else  ' '    
end as sec_rolled_qty,  
case when isnull(a.is_cleared_ind, '@')  <>  isnull(b.is_cleared_ind, '@')    
           then b.is_cleared_ind    
           else  ' '    
end as is_cleared_ind,  
case when isnull(a.formula_body_num, -1)  <>  isnull(b.formula_body_num, -1)    
           then str(b.formula_body_num)  
           else  ' '    
end as formula_body_num,  
case when isnull(a.equiv_source_ind, '@') <> isnull(b.equiv_source_ind,'@')  
   then b.equiv_source_ind  
   else ' '  
end as equiv_source_ind,  
case when isnull(a.mkt_long_qty, '@@@') <> isnull(b.mkt_long_qty, '@@@')  
   then b.mkt_long_qty  
   else ' '  
end as mkt_long_qty,  
case when isnull(a.mkt_short_qty, '@@@') <> isnull(b.mkt_short_qty, '@@@')  
   then b.mkt_short_qty  
   else ' '  
end as mkt_short_qty,  
case when isnull(a.sec_mkt_long_qty, '@@@') <> isnull(b.sec_mkt_long_qty, '@@@')  
   then b.sec_mkt_long_qty  
   else ' '  
end as sec_mkt_long_qty,  
case when isnull(a.sec_mkt_short_qty, '@@@') <> isnull(b.sec_mkt_short_qty, '@@@')  
   then b.sec_mkt_short_qty  
   else ' '  
end as sec_mkt_short_qty,  
b.trans_id1      
  from (select *      
        from  #position1      
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *      
        from  #position1      
        where resp_trans_id = @resp_trans_id_OLD) b left outer join #diffColList difc    
on b.pos_num = difc.pos_num       
  where  a.pos_num = b.pos_num  
  order by  pos_num  
      
drop table #position1      
GO
GRANT EXECUTE ON  [dbo].[usp_compare_position] TO [next_usr]
GO
