SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_compare_portfolio_group_eod]      
  @resp_trans_id_NEW      int,      
  @resp_trans_id_OLD      int,      
  @portnum                int = null,      
  @digits_for_scale4      tinyint = 4,      
  @digits_for_scale7      tinyint = 7        
as      
set nocount on      
      
   print ' '      
   print '==================================================='      
   print ' DATA : portfolio_group_eod'      
   print '==================================================='      
   print ' '      
      
   select  resp_trans_id,    
parent_port_num,  
port_num,  
is_link_ind,  
trans_id  
      
  into #porteod     
  from dbo.aud_portfolio_group_eod     
           where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and       
        1 = case when @portnum is null then 1        
                 else 0      
            end      
                  
select       
min(resp_trans_id) as resp_trans_id,         
parent_port_num,  
port_num,  
is_link_ind,  
min(trans_id) as trans_id1  
  into #porteod1      
   from #porteod      
  group by parent_port_num,port_num,is_link_ind  
  having count(*) = 1      
  order by parent_port_num, port_num   
      
  drop table #porteod      
 -- write changed columns 
select       
'DIFFCOLS' as PASS,      
b.resp_trans_id,      
b.parent_port_num,  
b.port_num,  
case when isnull(a.is_link_ind, '@') <> isnull(b.is_link_ind, '@')  
   then 'is_link_ind'
   else ' ' end as diffColList    
 into #diffColList         
  from (select *      
        from  #porteod1      
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *      
        from  #porteod1      
        where resp_trans_id = @resp_trans_id_OLD) b       
  where  a.parent_port_num = b.parent_port_num and  
   a.port_num = b.port_num
-- finish write changed columns.   
 select       
'NEW' as PASS,      
po.resp_trans_id, 
diffColList,       
po.parent_port_num,  
po.port_num,  
is_link_ind,  
trans_id1      
   from  #porteod1 po left outer join #diffColList difc    
 on po.parent_port_num = difc.parent_port_num and po.port_num = difc.port_num    
   where po.resp_trans_id = @resp_trans_id_NEW      
   union            
select       
'OLD' as PASS,      
b.resp_trans_id, 
diffColList,     
b.parent_port_num,  
b.port_num,  
case when isnull(a.is_link_ind, '@') <> isnull(b.is_link_ind, '@')  
   then b.is_link_ind  
   else ' '  
end as is_link_ind,  
b.trans_id1      
  from (select *      
        from  #porteod1      
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *      
        from  #porteod1      
        where resp_trans_id = @resp_trans_id_OLD) b left outer join #diffColList difc    
 on b.parent_port_num = difc.parent_port_num and b.port_num = difc.port_num      
  where  a.parent_port_num = b.parent_port_num and  
   a.port_num = b.port_num  
  order by  parent_port_num, port_num    
      
  drop table #porteod1      
GO
GRANT EXECUTE ON  [dbo].[usp_compare_portfolio_group_eod] TO [next_usr]
GO
