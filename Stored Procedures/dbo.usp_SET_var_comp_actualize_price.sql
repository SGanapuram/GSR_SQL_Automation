SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[usp_SET_var_comp_actualize_price]    
(  
    @run_date datetime,  
    @var_run_id int = NULL,  
    @port_num_list varchar (255) = NULL,  
    @debug_mode bit = 0  
)  
as
  
set nocount on  
  
declare   
        @smsg varchar (255),  
        @appo_oid int,  
          
    @appo_commkt_key int,  
    @appo_price_source_code char(8),  
    @appo_trading_prd char(8),  
    @appo_run_date datetime,  
    @appo_horizon int,  
    @appo_settl_price_curr_code char(4),  
    @appo_open_qty_uom_code char(4)  
          
     
-------------  
declare @vr1 varchar (100)  
declare @vr2 int  
declare @vr3 char(100)  
  
  
  
select @vr1 = CURRENT_USER  
  
  
if len(@vr1) > 10  
BEGIN  
        select @vr2 = CHARINDEX ( '\' ,@vr1 )   
           if @vr2 = 0  
               select @vr2 = 0             
                                
        select @vr3 =  SUBSTRING (@vr1,@vr2+1,10)                     
END  
     else select  @vr3 = @vr1     
  
  
       
declare  @TargetCurr char(4)  
select @TargetCurr = 'USD'           
  
declare @cont int  
select @cont = 0  
          
CREATE TABLE #oid  
(  
oid int  
)  
  
CREATE TABLE #temptable  
(  
oid int,  
commkt_key int null ,  
price_source_code char(8)null,  
trading_prd char(8)null ,  
time_hor_price float null,  
time_hor_exch_rate float null,  
time_hor_price_curr_code char(4) null,  
uom char(4) null,  
time_hor_comp_amt float null,  
price_quote_date datetime null,  
time_hor_calc_date datetime null,  
settl_price_curr_code char(4) null,  
open_qty_uom_code char(4) null,  
user_init char(10) null,  
horizon_date datetime null  
  
)  
  
  
If @run_date is null   
    begin  
        select @smsg = ' ERRORE: la run_date non deve essere null '  
        print @smsg  
        return -100  
    end  
  
if @var_run_id is NULL and @port_num_list is NULL  
    begin  
        insert into #oid  
        select oid from var_run  
        where run_date = @run_date  
    end  
      
if @var_run_id is not NULL and @port_num_list is NULL  
    begin  
        insert into #oid   
        select @var_run_id  
    end  
  
if @var_run_id is NULL and @port_num_list is not NULL  
    begin  
        insert into #oid  
        select oid from var_run  
        where port_num_list = @port_num_list  
    end  
  
  
if @var_run_id is not NULL and @port_num_list is not NULL  
    begin  
        insert into #oid  
        select oid from var_run  
        where port_num_list = @port_num_list and oid = @var_run_id  
    end  
  
  
 declare @fltExchangePrice float  
declare @dtRefDate datetime  
  
if @debug_mode = 1     
select * from #oid  
  
  
declare  curs1 cursor  
for select oid   
from #oid  
  
  
open curs1  
    
  
fetch curs1 into @appo_oid  
  
  
WHILE (@@FETCH_STATUS=0)  
BEGIN  
    
       
     declare  curs2 cursor  
        for   select   
            vc.commkt_key,  
            vc.price_source_code,  
            vc.trading_prd,  
            vr.run_date,  
            vr.horizon,  
            vc.settl_price_curr_code,  
            vc.open_qty_uom_code  
            from var_run vr   
            join var_component vc on vc.var_run_id = vr.oid  
           where var_run_id = @appo_oid  
          
          
            open curs2  
    
  
            fetch curs2 into   
                @appo_commkt_key,  
                @appo_price_source_code,  
                @appo_trading_prd ,  
                @appo_run_date  ,  
                @appo_horizon,  
                @appo_settl_price_curr_code,  
                @appo_open_qty_uom_code  
       
    
  WHILE (@@FETCH_STATUS=0)  
        BEGIN  
  
                insert into #temptable  
                SELECT TOP 1 @appo_oid,  
       @appo_commkt_key,  
       @appo_price_source_code,  
       @appo_trading_prd,  
                   
        (case vc.price_type when 'C' then p.avg_closed_price   
                      when 'L' then p.low_bid_price   
                                  when 'H' then p.high_asked_price   
                                  else p.avg_closed_price end) AS time_hor_price,   
       1       AS time_hor_exch_rate,   
       coalesce (cf.commkt_curr_code, cp.commkt_curr_code) AS time_hor_price_curr_code,   
       c.prim_uom_code                                   AS uom,             
       0                                                 AS time_hor_comp_amt,   
       p.price_quote_date                                AS price_quote_date,  
       getdate()                                         AS time_hor_calc_date,   
       @appo_settl_price_curr_code                       AS settl_price_curr_code,  
       @appo_open_qty_uom_code                           AS open_qty_uom_code,  
                              
                       @vr3                                              AS user_init,  
       dateadd(day, vr.horizon, @appo_run_date)          AS horizon_date  
                              
     FROM var_component vc INNER JOIN commodity c   
       ON vc.cmdty_code = c.cmdty_code  
    INNER JOIN var_run vr   
       ON vc.var_run_id = vr.oid  
    INNER JOIN price p   
       ON vc.commkt_key = p.commkt_key   
         AND vc.price_source_code = p.price_source_code   
         AND vc.trading_prd = p.trading_prd  
                LEFT JOIN commkt_future_attr cf ON cf.commkt_key = p.commkt_key  
                LEFT JOIN commkt_physical_attr cp ON cp.commkt_key = p.commkt_key  
                WHERE   
         p.commkt_key = @appo_commkt_key   
      AND p.price_source_code = @appo_price_source_code   
      AND p.trading_prd = @appo_trading_prd   
      AND p.price_quote_date >= dateadd(day, vr.horizon, @appo_run_date)  
     ORDER BY p.price_quote_date ASC  
    
    
     if @@rowcount = 0 and @debug_mode = 1  
     begin  
    print 'PRICE NOT FOUND:'  
    print @appo_oid  
    print @appo_commkt_key  
    print @appo_price_source_code  
    print @appo_trading_prd   
     end  
    
   fetch curs2 into   
    @appo_commkt_key,  
    @appo_price_source_code,  
    @appo_trading_prd ,  
    @appo_run_date  ,  
    @appo_horizon ,  
    @appo_settl_price_curr_code,  
    @appo_open_qty_uom_code  
       
    
     END  
  
  
        FETCH curs1 INTO @appo_oid  
        CLOSE curs2  
        DEALLOCATE curs2  
END  
  
  
    
   CLOSE curs1  
   deallocate curs1  
  
update #temptable  
   set time_hor_comp_amt= (tp.time_hor_price * var_component.open_qty)   
  from var_component inner join #temptable tp   
    on tp.commkt_key = var_component.commkt_key  
    and tp.price_source_code = var_component.price_source_code   
    and tp.trading_prd = var_component.trading_prd   
       and tp.oid = var_component.var_run_id  
  
  
update #temptable   
 set #temptable.user_init = us.user_init  
from icts_user us  
where us.user_logon_id = #temptable.user_init  
    
    
  
  
declare  
@t_time_hor_price float,  
@t_time_hor_exch_rate float,  
@t_time_hor_price_curr_code char(4),  
@t_settl_price_curr_code char(4),  
@t_time_hor_calc_date datetime,  
@t_fltExchangePrice   float,  
@t_horizon_date   datetime  
  
  
  
  
DECLARE curs3 cursor for  
select   
time_hor_price,  
time_hor_exch_rate,  
time_hor_price_curr_code,  
settl_price_curr_code,  
time_hor_calc_date,  
horizon_date  
FROM #temptable  
FOR update of time_hor_exch_rate, time_hor_price_curr_code  
  
  
open curs3  
  
  
  
fetch curs3 into  
@t_time_hor_price,  
@t_time_hor_exch_rate,  
@t_time_hor_price_curr_code,  
@t_settl_price_curr_code,  
@t_time_hor_calc_date,  
@t_horizon_date    
  
  
WHILE (@@FETCH_STATUS=0)  
  
            BEGIN  
                 select @fltExchangePrice = null  
                 if @t_time_hor_price_curr_code <> @TargetCurr  
                   
                        BEGIN  
                  
                                              
                   
                            exec usp_get_VAR_exchange_value  @t_horizon_date, @t_time_hor_price_curr_code, @TargetCurr, @fltExchangePrice OUTPUT  
                             
                    If @fltExchangePrice is null  
                            BEGIN  
                                    exec usp_get_VAR_exchange_value  @t_horizon_date,  @TargetCurr, @t_time_hor_price_curr_code, @fltExchangePrice OUTPUT  
                            END                              
                                 
                               update #temptable  
                                set time_hor_exch_rate = @fltExchangePrice,   
                                time_hor_price_curr_code = @t_settl_price_curr_code  
                                where current of curs3  
                                  
                                            
                                                       
                        END                          
                                   
                    fetch curs3 into  
                    @t_time_hor_price,  
                    @t_time_hor_exch_rate,  
                    @t_time_hor_price_curr_code,  
                    @t_settl_price_curr_code,  
                    @t_time_hor_calc_date,  
                    @t_horizon_date    
        END  
            
  
                CLOSE curs3  
                deallocate curs3  
  
  
  
  
update var_component   
set   
var_component.time_hor_price           = tp.time_hor_price,                             
var_component.time_hor_exch_rate       = tp.time_hor_exch_rate,                         
var_component.time_hor_price_curr_code = tp.time_hor_price_curr_code,                   
var_component.time_hor_component_amt   = tp.time_hor_comp_amt ,   
var_component.time_hor_price_date      = tp.price_quote_date,                           
var_component.time_hor_calc_date       = tp.time_hor_calc_date,                         
var_component.time_hor_calc_user_init  = SUBSTRING (tp.user_init ,1,3)  
  
  
from var_component join #temptable tp   
on tp.commkt_key = var_component.commkt_key  
and tp.price_source_code = var_component.price_source_code   
and tp.trading_prd = var_component.trading_prd   
and tp.oid = var_component.var_run_id  
  

select * from #temptable  
  
drop table #temptable  
  
drop table #oid  
GO
GRANT EXECUTE ON  [dbo].[usp_SET_var_comp_actualize_price] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_SET_var_comp_actualize_price', NULL, NULL
GO
