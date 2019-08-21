SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_fetch_tags_4_an_entity]
(      
   @entity_name          varchar(30),      
   @keys                 varchar(max),   /* (e.g. for portfolio, it may be "p1,p2,p3",   
                                                  for trade item it may be "t.o.I, t1.o1.I1, t2.o2.I2") */   
   @active_tag_only_flag bit = 1  
)      
as    
set nocount on   
set xact_abort on  

declare @keystr     varchar(100),  
        @keycount   int  
         
   IF OBJECT_ID('tempdb..#temps') IS NOT NULL                  
		  DROP TABLE #temps
   create table #temps  
   (      
      keystr    varchar(100)  primary key  
   )      
    
   IF OBJECT_ID('tempdb..#etIds') IS NOT NULL          
		  DROP TABLE #etIds
   create table #etIds    
   (    
      etId int   primary key  
   )    
         
   if not exists (select 1    
                  from dbo.icts_entity_name with (nolock)   
                  where entity_name = @entity_name)    
      
   begin      
      print '=> The entity ''' + @entity_name + ''' does not exist in the icts_entity_name table!'      
      goto endofsp      
   end      
       
   if @active_tag_only_flag = 1  
      insert into #etIds    
      select oid 
      from dbo.entity_tag_definition etd with (nolock)  
      where entity_id = (select oid      
                         from dbo.icts_entity_name en with (nolock)       
                         where en.entity_name = @entity_name) and  
            tag_status != 'I'  
   else  
      insert into #etIds    
      select oid   
      from dbo.entity_tag_definition with (nolock)  
      where entity_id = (select oid      
                         from dbo.icts_entity_name en with (nolock)       
                         where en.entity_name = @entity_name)   
  
    
   insert into #temps (keystr)      
     select * from dbo.fnToSplit(@keys, ',')     
    
    
   set @keystr = (select top 1 keystr from #temps)      
         
   set @keycount = [dbo].[udf_count_a_char_occurrences] (@keystr, '.') + 1      
   print str(@keycount)    
   if @keycount = 1    
   begin    
      select et.*    
      from dbo.entity_tag et with (nolock)   
              INNER JOIN #etIds etid     
                 ON et.entity_tag_id = etid.etId      
              INNER JOIN #temps k    
                 ON et.key1 = k.keystr    
   end    
   else if @keycount = 2    
   begin    
      select et.*    
      from dbo.entity_tag et with (nolock)    
              INNER JOIN #etIds etid     
                 ON et.entity_tag_id = etid.etId      
              INNER JOIN #temps k    
                 ON et.key1 = [dbo].[udf_split_value](k.keystr, '.', 1) and   
                    et.key2 = [dbo].[udf_split_value](k.keystr, '.', 2)    
   end    
   else if @keycount = 3    
   begin    
      select et.*    
      from dbo.entity_tag et with (nolock)    
              INNER JOIN #etIds etid     
                 ON et.entity_tag_id = etid.etId      
              INNER JOIN #temps k    
                 ON et.key1 = [dbo].[udf_split_value](k.keystr, '.', 1) and   
                    et.key2 = [dbo].[udf_split_value](k.keystr, '.', 2) and    
                    et.key3 = [dbo].[udf_split_value](k.keystr, '.', 3)     
   end    
   else if @keycount = 4    
   begin    
      select et.*    
      from dbo.entity_tag et with (nolock)   
              INNER JOIN #etIds etid     
                 ON et.entity_tag_id = etid.etId      
              INNER JOIN #temps k    
                 ON et.key1 = [dbo].[udf_split_value](k.keystr, '.', 1) and    
                    et.key2 = [dbo].[udf_split_value](k.keystr, '.', 2) and  
                    et.key3 = [dbo].[udf_split_value](k.keystr, '.', 3) and  
                    et.key4 = [dbo].[udf_split_value](k.keystr, '.', 4)   
   end    
   else if @keycount = 5    
   begin    
      select et.*    
      from dbo.entity_tag et with (nolock)    
              INNER JOIN #etIds etid     
                 ON et.entity_tag_id = etid.etId      
              INNER JOIN #temps k    
                 ON et.key1 = [dbo].[udf_split_value](k.keystr, '.', 1) and  
                    et.key2 = [dbo].[udf_split_value](k.keystr, '.', 2) and   
                    et.key3 = [dbo].[udf_split_value](k.keystr, '.', 3) and   
                    et.key4 = [dbo].[udf_split_value](k.keystr, '.', 4) and   
                    et.key5 = [dbo].[udf_split_value](k.keystr, '.', 5)    
   end    
   else if @keycount = 6    
   begin    
      select et.*    
      from dbo.entity_tag et with (nolock)    
              INNER JOIN #etIds etid     
                 ON et.entity_tag_id = etid.etId      
              INNER JOIN #temps k  
                 ON et.key1 = [dbo].[udf_split_value](k.keystr, '.', 1) and  
                    et.key2 = [dbo].[udf_split_value](k.keystr, '.', 2) and  
                    et.key3 = [dbo].[udf_split_value](k.keystr, '.', 3) and  
                    et.key4 = [dbo].[udf_split_value](k.keystr, '.', 4) and  
                    et.key5 = [dbo].[udf_split_value](k.keystr, '.', 5) and  
                    et.key6 = [dbo].[udf_split_value](k.keystr, '.', 6)   
   end  
   else if @keycount = 7  
   begin  
      select et.*
      from dbo.entity_tag et with (nolock)
              INNER JOIN #etIds etid  
                 ON et.entity_tag_id = etid.etId  
              INNER JOIN #temps k  
                 ON et.key1 = [dbo].[udf_split_value](k.keystr, '.', 1) and  
                    et.key2 = [dbo].[udf_split_value](k.keystr, '.', 2) and  
                    et.key3 = [dbo].[udf_split_value](k.keystr, '.', 3) and  
                    et.key4 = [dbo].[udf_split_value](k.keystr, '.', 4) and  
                    et.key5 = [dbo].[udf_split_value](k.keystr, '.', 5) and  
                    et.key6 = [dbo].[udf_split_value](k.keystr, '.', 6) and  
                    et.key7 = [dbo].[udf_split_value](k.keystr, '.', 7)  
   end  
   else if @keycount = 8  
   begin  
      select et.*
      from dbo.entity_tag et with (nolock)
              INNER JOIN #etIds etid  
                 ON et.entity_tag_id = etid.etId  
              INNER JOIN #temps k  
                 ON et.key1 = [dbo].[udf_split_value](k.keystr, '.', 1) and  
                    et.key2 = [dbo].[udf_split_value](k.keystr, '.', 2) and  
                    et.key3 = [dbo].[udf_split_value](k.keystr, '.', 3) and  
                    et.key4 = [dbo].[udf_split_value](k.keystr, '.', 4) and  
                    et.key5 = [dbo].[udf_split_value](k.keystr, '.', 5) and  
                    et.key6 = [dbo].[udf_split_value](k.keystr, '.', 6) and  
                    et.key7 = [dbo].[udf_split_value](k.keystr, '.', 7) and  
                    et.key8 = [dbo].[udf_split_value](k.keystr, '.', 8)   
   end  
     
endofsp:  
drop table #etIds  
drop table #temps  
return
GO
GRANT EXECUTE ON  [dbo].[usp_fetch_tags_4_an_entity] TO [next_usr]
GO
