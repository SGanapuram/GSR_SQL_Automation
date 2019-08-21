SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CheckALSrun]  
as      
set nocount on      
set ANSI_WARNINGS OFF       
declare @rc int      
   create table #mytable      
   (      
      als_module_group_id      int primary key,      
      first_sequence           numeric(32, 0) null,      
      last_sequence            numeric(32, 0) null,      
      behind                   numeric(32, 0) default 0 null      
   )      
   select als_module_group_id,       
          sequence      
       into #alsrun1      
   from dbo.als_run with (nolock)    
   where als_run_status_id in (select als_run_status_id      
                               from dbo.als_run_status WITH (NOLOCK)      
                               where als_run_status_desc in ('WORKING', 'PENDING'))     
   select als_module_group_id,       
          sequence      
       into #alsrun2      
   from dbo.als_run with (nolock)    
   where als_run_status_id in (select als_run_status_id      
                               from dbo.als_run_status WITH (NOLOCK)      
                               where als_run_status_desc not in ('WORKING', 'PENDING'))     
   insert into #mytable      
     select als_module_group_id,      
            min(sequence),       
            max(sequence),       
            isnull(count(*), 0)      
     from #alsrun1      
     group by als_module_group_id      
     set @rc = @@rowcount      
   insert into #mytable    
     select als_module_group_id,    
         null,    
   null,    
   0    
     from dbo.server_config a WITH (NOLOCK)    
  where trans_type_mask <> 0  
  and not exists (select 1    
                    from #mytable b    
        where a.als_module_group_id = b.als_module_group_id)    
   set @rc = @rc + @@rowcount    
   if @rc = 0      
   begin      
      drop table #alsrun1      
   drop table #alsrun2    
      return 1      
   end      
   update t      
   set first_sequence = (select min(sequence)      
                         from #alsrun2 b      
                         where b.als_module_group_id = t.als_module_group_id),      
       last_sequence = (select max(sequence)      
                        from #alsrun2 b      
                        where b.als_module_group_id = t.als_module_group_id),      
       behind = 0      
   from #mytable t      
   where first_sequence is null      
   drop table #alsrun1    
   drop table #alsrun2       
   declare @maxTransID numeric(32, 0)      
   set @maxTransID = (select top 1 trans_id      
                      from dbo.icts_transaction WITH (NOLOCK)  
                      order by trans_id desc)      
   select a.als_module_group_desc 'ALS Module',      
          convert(char(15), first_sequence) 'First seq #',      
          convert(char(15), last_sequence) 'Last seq #',      
          convert(char(15), isnull(behind, 0)) 'Behind',      
          getdate() 'Snapshot Time',      
          @maxTransID 'Max Trans ID'      
   from dbo.server_config a WITH (NOLOCK)       
           left outer join #mytable b      
              on a.als_module_group_id = b.als_module_group_id  
   where a.trans_type_mask <> 0                  
   order by a.als_module_group_desc      
   drop table #mytable      
   return 0     
reportusage:      
print ' '      
print 'Usage: exec dbo.CheckALSrun'      
return 2 
GO
GRANT EXECUTE ON  [dbo].[CheckALSrun] TO [next_usr]
GO
