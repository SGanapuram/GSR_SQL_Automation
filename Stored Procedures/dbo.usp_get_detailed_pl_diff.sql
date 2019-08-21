SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_detailed_pl_diff]  
(  
   @user_logon_id varchar(20),  
   @asofdate_day1 datetime,   
   @asofdate_day2 datetime,  
   @root_port_num    int = null,  
   @show_zero_diff   bit = 0,  
   @debugon          bit = 0  
)  
as   
set nocount on  
declare @my_user_logon_id   varchar(20)  
declare @my_asofdate_day1   datetime  
declare @my_asofdate_day2   datetime  
declare @my_top_port_num   int  
declare @my_is_superuser    char(1)  
declare @smsg            varchar(255)  
declare @status          int  
declare @errcode         int  
  
  
 set @my_user_logon_id=@user_logon_id  
 set @my_asofdate_day1=@asofdate_day1  
 set @my_asofdate_day2=@asofdate_day2  
 set @my_top_port_num=@root_port_num  
 set @my_is_superuser='N'  
  
 set @status = 0  
 set @errcode = 0  
 if @my_top_port_num is null  
 select @my_top_port_num = 0  
  
 if not exists (select 1  
    from dbo.icts_user  
    where user_logon_id = @user_logon_id)  
 begin  
 print '=> You must provide a valid user logon id @user_logon_id!'  
 print 'Usage: exec dbo.usp_get_detailed_pl_diff @root_port_num = ? [, @debugon = ?]'  
 return 2  
 end   
   
 create table #trading_entity  
 (  
   trading_account varchar(40) null  
 )  
   
 insert into #trading_entity  
 select fdv.attr_value   
 from icts_user_permission iup, function_detail_value fdv, function_detail fd, icts_function icf   
 where iup.fdv_id = fdv.fdv_id and fdv.fd_id = fd.fd_id and fd.function_num = icf.function_num   
 and icf.app_name = 'ICTSControl' and icf.function_name = 'TradingEntity' and   
 iup.user_init in (select user_init from icts_user where user_logon_id = @my_user_logon_id)  
  
 if exists (select 1 from #trading_entity where trading_account='ANY')  
 begin  
  set @my_is_superuser='Y'  
 end  
  
 create table #children  
 (  
   port_num int PRIMARY KEY,  
   port_type char(2),  
 )  
  
 if @root_port_num is not null  
 begin  
  if not exists (select 1  
     from dbo.portfolio  
     where port_num = @root_port_num)  
  begin  
  print '=> You must provide a valid port # for the argument @root_port_num!'  
  print 'Usage: exec dbo.usp_dump_fx_data_for_portnum @root_port_num = ? [, @debugon = ?]'  
  return 2  
  end   
  
  begin try      
   exec dbo.usp_get_child_port_nums @my_top_port_num, 1  
  end try  
  begin catch  
   print '=> Failed to execute the ''usp_get_child_port_nums'' sp due to the following error:'  
   print '==> ERROR: ' + ERROR_MESSAGE()  
   set @errcode = ERROR_NUMBER()  
   goto errexit  
  end catch  
 end  
 else  
 begin  
  insert into #children  
  select port_num,  
         port_type  
  from portfolio   
  where port_type='R'  
 end  
   
 if @my_is_superuser ='N'  
 begin  
  delete t1  
  from #children t1  
  where not exists (select 1 from portfolio p   
        where t1.port_num=p.port_num and  
        (trading_entity_num in (select cast (trading_account as int) from #trading_entity) or  
        trading_entity_num is null))    
 end  
  
 create table #day1_pl  
 (  
   port_num int,  
   order_type_code char(10),  
   pl_amt decimal(20,8)  
 )  
  
 create table #day2_pl  
 (  
   port_num int,  
   order_type_code char(10),  
   pl_amt decimal(20,8)  
 )  
  
 create table #diff_pl  
 (  
   port_num int,  
   order_type_code char(10),  
   pl_diff decimal(20,8)  
 )  
  
 if(convert(varchar,@my_asofdate_day1,101) <> convert(varchar,@my_asofdate_day2,101))  
 begin  
  insert into #day1_pl  
  select real_port_num,  
      order_type_code,  
      sum(pl_amt)  
  from (select plh.real_port_num as real_port_num,  
       isnull(isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,t.trade_status_code),'OTHER') as order_type_code,  
       sum(pl_amt) as pl_amt  
   from pl_history plh  
   join #children t1 on plh.real_port_num=t1.port_num  
   left outer join trade_item ti on    plh.pl_secondary_owner_key1=ti.trade_num and    
            plh.pl_secondary_owner_key2=ti.order_num and    
            plh.pl_secondary_owner_key3=ti.item_num  
   left outer join trade_order tor on  tor.trade_num = plh.pl_secondary_owner_key1 and    
            tor.order_num = plh.pl_secondary_owner_key2  
   left outer join trade t on t.trade_num=plh.pl_secondary_owner_key1  
   where pl_asof_date=@my_asofdate_day1  
      and pl_type not in ('I','W')   
      and pl_owner_code not in ('I', 'P')  
      and ((ti.item_num is null and t.trade_num is null) or (ti.item_num is not null and t.trade_num is not null))  
   group by plh.real_port_num,  
      isnull(isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,t.trade_status_code),'OTHER')  
   union  
   select plh.real_port_num as real_port_num,  
       isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,'DELETE') as order_type_code,  
       sum(pl_amt) as pl_amt  
   from pl_history plh  
   join #children t1 on plh.real_port_num=t1.port_num  
   left outer join trade_item ti on    plh.pl_secondary_owner_key1=ti.trade_num and    
            plh.pl_secondary_owner_key2=ti.order_num and    
            plh.pl_secondary_owner_key3=ti.item_num  
   left outer join aud_trade_order tor on  tor.trade_num = plh.pl_secondary_owner_key1 and    
            tor.order_num = plh.pl_secondary_owner_key2  
   left outer join trade t on t.trade_num=plh.pl_secondary_owner_key1  
   where pl_asof_date=@my_asofdate_day1  
      and pl_type not in ('I','W')   
      and pl_owner_code not in ('I', 'P')  
      and ti.item_num is null   
      and t.trade_num is not null  
   group by plh.real_port_num,  
      isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,'DELETE')  
   ) temp1  
  group by real_port_num, order_type_code  
  union  
  select plh.real_port_num,  
      'INVENTORY',  
      sum(pl_amt)  
  from pl_history plh  
  join #children t1 on plh.real_port_num=t1.port_num  
  where pl_asof_date=@my_asofdate_day1  
     and pl_type not in ('I','W')   
     and pl_owner_code in ('I', 'P')  
  group by plh.real_port_num  
  
 end  
      
 insert into #day2_pl  
 select real_port_num,  
     order_type_code,  
     sum(pl_amt)  
 from (select plh.real_port_num as real_port_num,  
      isnull(isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,t.trade_status_code),'OTHER') as order_type_code,  
      sum(pl_amt) as pl_amt  
  from pl_history plh  
  join #children t1 on plh.real_port_num=t1.port_num  
  left outer join trade_item ti on    plh.pl_secondary_owner_key1=ti.trade_num and    
           plh.pl_secondary_owner_key2=ti.order_num and    
           plh.pl_secondary_owner_key3=ti.item_num  
   left outer join trade_order tor on  tor.trade_num = plh.pl_secondary_owner_key1 and    
            tor.order_num = plh.pl_secondary_owner_key2  
   left outer join trade t on t.trade_num=plh.pl_secondary_owner_key1  
  where pl_asof_date=@my_asofdate_day2  
     and pl_type not in ('I','W')   
     and pl_owner_code not in ('I', 'P')  
     and ((ti.item_num is null and t.trade_num is null) or (ti.item_num is not null and t.trade_num is not null))  
  group by plh.real_port_num,  
     isnull(isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,t.trade_status_code),'OTHER')  
  union  
  select plh.real_port_num as real_port_num,  
      isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,'DELETE') as order_type_code,  
      sum(pl_amt) as pl_amt  
  from pl_history plh  
  join #children t1 on plh.real_port_num=t1.port_num  
  left outer join trade_item ti on    plh.pl_secondary_owner_key1=ti.trade_num and    
           plh.pl_secondary_owner_key2=ti.order_num and    
           plh.pl_secondary_owner_key3=ti.item_num  
  left outer join aud_trade_order tor on  tor.trade_num = plh.pl_secondary_owner_key1 and    
           tor.order_num = plh.pl_secondary_owner_key2  
  left outer join trade t on t.trade_num=plh.pl_secondary_owner_key1  
  where pl_asof_date=@my_asofdate_day2  
     and pl_type not in ('I','W')   
     and pl_owner_code not in ('I', 'P')  
     and ti.item_num is null   
     and t.trade_num is not null  
  group by plh.real_port_num,  
     isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,'DELETE')  
  ) temp1  
 group by real_port_num, order_type_code  
 union  
 select plh.real_port_num,  
     'INVENTORY',  
     sum(pl_amt)  
 from pl_history plh  
 join #children t1 on plh.real_port_num=t1.port_num  
 where pl_asof_date=@my_asofdate_day2  
    and pl_type not in ('I','W')   
    and pl_owner_code in ('I', 'P')  
 group by plh.real_port_num  
  
  
  ----Added on 07/16/2013 -- to get p/l for locked portfolios for LTD p/l only
 if(convert(varchar,@my_asofdate_day1,101) = convert(varchar,@my_asofdate_day2,101))  
 begin  

 insert into #day2_pl  
 select real_port_num,  
     order_type_code,  
     sum(pl_amt)  
 from (select plh.real_port_num as real_port_num,  
      isnull(isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,t.trade_status_code),'OTHER') as order_type_code,  
      sum(pl_amt) as pl_amt  
  from Mercuria_RefData..pl_history_locked plh  
  join #children t1 on plh.real_port_num=t1.port_num  
  left outer join trade_item ti on    plh.pl_secondary_owner_key1=ti.trade_num and    
           plh.pl_secondary_owner_key2=ti.order_num and    
           plh.pl_secondary_owner_key3=ti.item_num  
   left outer join trade_order tor on  tor.trade_num = plh.pl_secondary_owner_key1 and    
            tor.order_num = plh.pl_secondary_owner_key2  
   left outer join trade t on t.trade_num=plh.pl_secondary_owner_key1  
  where-- pl_asof_date=@my_asofdate_day2       and 
	pl_type not in ('I','W')   
     and pl_owner_code not in ('I', 'P')  
     and ((ti.item_num is null and t.trade_num is null) or (ti.item_num is not null and t.trade_num is not null))  
     and not exists (Select 1 from #day2_pl pl where pl.port_num=t1.port_num) -- Added by Subu to extract P/L for locked portfolios
     
  group by plh.real_port_num,  
     isnull(isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,t.trade_status_code),'OTHER')  
  union  
  select plh.real_port_num as real_port_num,  
      isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,'DELETE') as order_type_code,  
      sum(pl_amt) as pl_amt  
  from Mercuria_RefData..pl_history_locked plh  
  join #children t1 on plh.real_port_num=t1.port_num  
  left outer join trade_item ti on    plh.pl_secondary_owner_key1=ti.trade_num and    
           plh.pl_secondary_owner_key2=ti.order_num and    
           plh.pl_secondary_owner_key3=ti.item_num  
  left outer join aud_trade_order tor on  tor.trade_num = plh.pl_secondary_owner_key1 and    
           tor.order_num = plh.pl_secondary_owner_key2  
  left outer join trade t on t.trade_num=plh.pl_secondary_owner_key1  
  where --pl_asof_date=@my_asofdate_day2       and 
	 pl_type not in ('I','W')   
     and pl_owner_code not in ('I', 'P')  
     and ti.item_num is null   
     and t.trade_num is not null  
	 and not exists (Select 1 from #day2_pl pl where pl.port_num=t1.port_num) -- Added by Subu to extract P/L for locked portfolios     
  group by plh.real_port_num,  
     isnull(case tor.order_type_code when 'SWAP' then 'SWAP' when 'SWAPFLT' then 'SWAP' else tor.order_type_code end,'DELETE')  
  ) temp1  
 group by real_port_num, order_type_code  
 union  
 select plh.real_port_num,  
     'INVENTORY',  
     sum(pl_amt)  
 from Mercuria_RefData..pl_history_locked plh  
 join #children t1 on plh.real_port_num=t1.port_num  
 where --pl_asof_date=@my_asofdate_day2      and 
	pl_type not in ('I','W')   
    and pl_owner_code in ('I', 'P')  
	and not exists (Select 1 from #day2_pl pl where pl.port_num=t1.port_num) -- Added by Subu to extract P/L for locked portfolios     
 group by plh.real_port_num  
 end   
 insert into #diff_pl  
 select isnull(t1.port_num, t2.port_num),  
     isnull(t1.order_type_code,t2.order_type_code),  
     isnull(t1.pl_amt,0)-isnull(t2.pl_amt,0)  
 from #day2_pl t1  
 FULL JOIN #day1_pl t2 on t1.port_num=t2.port_num and t1.order_type_code=t2.order_type_code  
  
 if @show_zero_diff = 0  
 delete #diff_pl where abs(pl_diff)=0.0  
  
 select t1.port_num as PortfolioNum,  
     p.port_short_name as PortfolioName,  
     bc.acct_short_name as BookingCompany,  
     pt2.tag_value as Division,  
     pt3.tag_value as 'Group',  
     pt4.tag_value as ProfitCenter,  
     t1.order_type_code as OrderType,  
     t1.pl_diff as PlDifference  
 from #diff_pl  t1  
 join portfolio p on p.port_num = t1.port_num  
 left outer join portfolio_tag pt1 on pt1.port_num=t1.port_num and pt1.tag_name='BOOKCOMP'  
 left outer join account bc on bc.acct_num=cast (pt1.tag_value as int)  
 left outer join portfolio_tag pt2 on pt2.port_num=t1.port_num and pt2.tag_name='DIVISION'  
 left outer join portfolio_tag pt3 on pt3.port_num=t1.port_num and pt3.tag_name='GROUP'  
 left outer join portfolio_tag pt4 on pt4.port_num=t1.port_num and pt4.tag_name='PRFTCNTR'  
 order by t1.port_num,t1.order_type_code  
 
       
errexit:  
   if @errcode > 0  
      set @status = 2  
     
endofsp:  
if object_id('tempdb.dbo.#children') is not null  
   exec('drop table #children')  
if object_id('tempdb.dbo.#trading_entity') is not null  
   exec('drop table #trading_entity')  
if object_id('tempdb.dbo.#day1_pl') is not null  
   exec('drop table #day1_pl')  
if object_id('tempdb.dbo.#day2_pl') is not null  
   exec('drop table #day2_pl')  
if object_id('tempdb.dbo.#diff_pl') is not null  
   exec('drop table #diff_pl')  
  
return @status  
GO
GRANT EXECUTE ON  [dbo].[usp_get_detailed_pl_diff] TO [next_usr]
GO
