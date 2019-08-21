SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_compare_portfolio_eod]      
  @resp_trans_id_NEW      int,      
  @resp_trans_id_OLD      int,      
  @portnum                int = null,      
  @digits_for_scale4      tinyint = 4,      
  @digits_for_scale7      tinyint = 7        
as      
set nocount on      
      
   print ' '      
   print '==================================================='      
   print ' DATA : portfolio_eod'      
   print '==================================================='      
   print ' '      
      
   select  resp_trans_id,    
port_num,  
port_type,  
desired_pl_curr_code,  
snapshot_asof_date,  
port_status,  
port_short_name,  
port_full_name,  
port_class,  
port_ref_key,  
owner_init,  
cmnt_num,  
num_history_days,  
trading_entity_num,  
trans_id  
      
  into #porteod     
  from dbo.aud_portfolio_eod     
           where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and       
        1 = case when @portnum is null then 1        
                 else 0      
            end      
                  
select       
min(resp_trans_id) as resp_trans_id,         
port_num,  
port_type,  
desired_pl_curr_code,  
snapshot_asof_date,  
port_status,  
port_short_name,  
port_full_name,  
port_class,  
port_ref_key,  
owner_init,  
cmnt_num,  
num_history_days,  
trading_entity_num,  
min(trans_id) as trans_id1  
  into #porteod1      
   from #porteod      
  group by port_num,port_type,desired_pl_curr_code,snapshot_asof_date,  
           port_status,port_short_name,port_full_name,port_class,port_ref_key,  
     owner_init,cmnt_num,num_history_days,trading_entity_num  
  having count(*) = 1      
  order by port_num   
      
  drop table #porteod      
  -- write changed columns  
select       
'DIFFCOLS' as PASS,      
b.resp_trans_id,      
b.port_num,  
case when isnull(a.port_type, '@@') <> isnull(b.port_type, '@@')  
   then ',port_type'
   else ' ' end +
case when isnull(a.desired_pl_curr_code, '@@@') <> isnull(b.desired_pl_curr_code, '@@@')  
   then ',desired_pl_curr_code'
   else ' ' end +
case when isnull(a.snapshot_asof_date, '01/01/2015') <> isnull(b.snapshot_asof_date, '01/01/2015')  
   then ',snapshot_asof_date'
   else ' ' end +
case when isnull(a.port_status, '@')  <>  isnull(b.port_status, '@')    
   then ',port_status'
   else  ' ' end +
case when isnull(a.port_short_name, '@@@')  <>  isnull(b.port_short_name, '@@@')    
           then ',port_short_name'
   else  ' ' end +
case when isnull(a.port_full_name, '@@@')  <>  isnull(b.port_full_name, '@@@')    
           then ',port_full_name'
   else  ' ' end +
case when isnull(a.port_class, '@')  <>  isnull(b.port_class, '@')    
           then ',port_class'
   else  ' ' end +
case when isnull(a.port_ref_key, '@@@')  <>  isnull(b.port_ref_key, '@@@')    
           then ',port_ref_key'
    else  ' ' end +
case when isnull(a.owner_init, '@@@')  <>  isnull(b.owner_init, '@@@')    
           then ',owner_init'
    else  ' ' end +
case when isnull(a.cmnt_num, -1)  <>  isnull(b.cmnt_num, -1)    
           then ',cmnt_num'
    else  ' ' end +
case when isnull(a.num_history_days, -1)  <>  isnull(b.num_history_days, -1)    
           then ',num_history_days'
    else  ' ' end +
case when isnull(a.trading_entity_num, -1)  <>  isnull(b.trading_entity_num, -1)    
           then ',trading_entity_num'
    else  ' ' end as diffColList  
  into #diffColList 	
  from (select *      
        from  #porteod1      
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *      
        from  #porteod1      
        where resp_trans_id = @resp_trans_id_OLD) b       
  where  a.port_num = b.port_num
-- finish write changed columns.   
 select       
'NEW' as PASS,      
po.resp_trans_id,  
diffColList,       
po.port_num,  
port_type,  
desired_pl_curr_code,  
convert(varchar, snapshot_asof_date, 101) as snapshot_asof_date,  
port_status,  
port_short_name,  
port_full_name,  
port_class,  
port_ref_key,  
owner_init,  
str(cmnt_num) as cmnt_num,  
str(num_history_days) as num_history_days,  
str(trading_entity_num) as trading_entity_num,  
trans_id1      
   from  #porteod1 po left outer join #diffColList difc    
 on po.port_num = difc.port_num     
   where po.resp_trans_id = @resp_trans_id_NEW      
   union            
select       
'OLD' as PASS,      
b.resp_trans_id,
diffColList,       
b.port_num,  
case when isnull(a.port_type, '@@') <> isnull(b.port_type, '@@')  
   then b.port_type  
   else ' '  
end as port_type,  
case when isnull(a.desired_pl_curr_code, '@@@') <> isnull(b.desired_pl_curr_code, '@@@')  
   then b.desired_pl_curr_code  
   else ' '  
end as desired_pl_curr_code,  
case when isnull(a.snapshot_asof_date, '01/01/2015') <> isnull(b.snapshot_asof_date, '01/01/2015')  
   then convert(varchar, b.snapshot_asof_date, 101)  
   else ' '  
end as snapshot_asof_date,  
case when isnull(a.port_status, '@')  <>  isnull(b.port_status, '@')    
           then b.port_status    
           else  ' '    
end as port_status,  
case when isnull(a.port_short_name, '@@@')  <>  isnull(b.port_short_name, '@@@')    
           then b.port_short_name    
           else  ' '    
end as port_short_name,  
case when isnull(a.port_full_name, '@@@')  <>  isnull(b.port_full_name, '@@@')    
           then b.port_full_name    
           else  ' '    
end as port_full_name,  
case when isnull(a.port_class, '@')  <>  isnull(b.port_class, '@')    
           then b.port_class    
           else  ' '    
end as port_class,  
case when isnull(a.port_ref_key, '@@@')  <>  isnull(b.port_ref_key, '@@@')    
           then b.port_ref_key    
           else  ' '    
end as port_ref_key,  
case when isnull(a.owner_init, '@@@')  <>  isnull(b.owner_init, '@@@')    
           then b.owner_init    
           else  ' '    
end as owner_init,  
case when isnull(a.cmnt_num, -1)  <>  isnull(b.cmnt_num, -1)    
           then str(b.cmnt_num)  
           else  ' '    
end as cmnt_num,  
case when isnull(a.num_history_days, -1)  <>  isnull(b.num_history_days, -1)    
           then str(b.num_history_days)    
           else  ' '    
end as num_history_days,  
case when isnull(a.trading_entity_num, -1)  <>  isnull(b.trading_entity_num, -1)    
           then str(b.trading_entity_num)  
           else  ' '    
end as trading_entity_num,  
b.trans_id1      
  from (select *      
        from  #porteod1      
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *      
        from  #porteod1      
        where resp_trans_id = @resp_trans_id_OLD) b left outer join #diffColList difc    
 on b.port_num = difc.port_num            
  where  a.port_num = b.port_num  
  order by  port_num   
      
drop table #porteod1      
GO
GRANT EXECUTE ON  [dbo].[usp_compare_portfolio_eod] TO [next_usr]
GO
