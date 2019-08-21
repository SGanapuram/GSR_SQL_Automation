SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_compare_position_group_eod]      
  @resp_trans_id_NEW      int,      
  @resp_trans_id_OLD      int,      
  @portnum                int = null,      
  @digits_for_scale4      tinyint = 4,      
  @digits_for_scale7      tinyint = 7        
as      
set nocount on      
      
   print ' '      
   print '==================================================='      
   print ' DATA : position_group_eod'      
   print '==================================================='      
   print ' '      
      
   select  resp_trans_id,    
pos_group_num,  
is_spread_ind,  
trans_id  
  
  into #poseod     
  from dbo.aud_position_group_eod     
           where resp_trans_id in (@resp_trans_id_NEW, @resp_trans_id_OLD) and       
        1 = case when @portnum is null then 1        
                 else 0      
            end      
                  
select       
min(resp_trans_id) as resp_trans_id,         
pos_group_num,  
is_spread_ind,  
min(trans_id) as trans_id1  
  into #poseod1      
   from #poseod      
  group by pos_group_num,is_spread_ind  
  having count(*) = 1      
  order by pos_group_num   
      
  drop table #poseod      
 -- write changed columns 
select       
'DIFFCOLS' as PASS,      
b.resp_trans_id,      
b.pos_group_num,  
case when isnull(a.is_spread_ind, '@') <> isnull(b.is_spread_ind, '@')  
   then 'is_spread_ind'
   else ' ' end as diffColList    
 into #diffColList           
  from (select *      
        from  #poseod1      
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *      
        from  #poseod1      
        where resp_trans_id = @resp_trans_id_OLD) b       
  where  a.pos_group_num = b.pos_group_num  
 -- finish write changed columns. 	
 select       
'NEW' as PASS,      
pos.resp_trans_id, 
diffColList,         
pos.pos_group_num,  
is_spread_ind,  
trans_id1      
   from  #poseod1 pos left outer join #diffColList difc    
 on pos.pos_group_num = difc.pos_group_num  
   where pos.resp_trans_id = @resp_trans_id_NEW      
   union            
select       
'OLD' as PASS,      
b.resp_trans_id, 
diffColList,  
b.pos_group_num,  
case when isnull(a.is_spread_ind, '@') <> isnull(b.is_spread_ind, '@')  
   then b.is_spread_ind  
   else ' '  
end as is_spread_ind,  
b.trans_id1      
  from (select *      
        from  #poseod1      
        where resp_trans_id = @resp_trans_id_NEW) a,    
       (select  *      
        from  #poseod1      
        where resp_trans_id = @resp_trans_id_OLD) b left outer join #diffColList difc    
 on b.pos_group_num = difc.pos_group_num        
  where  a.pos_group_num = b.pos_group_num  
  order by  pos_group_num   
      
drop table #poseod1      
GO
GRANT EXECUTE ON  [dbo].[usp_compare_position_group_eod] TO [next_usr]
GO
