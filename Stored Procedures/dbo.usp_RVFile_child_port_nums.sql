SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_child_port_nums]
(
   @top_port_num     int = null
)
as
set nocount on
declare @my_port_num     int

   select @my_port_num = @top_port_num
   if @my_port_num is null
   begin
      print 'Please provide a port_num for the argument @top_port_num!'
      goto reportusage
   end

   if not exists (select 1
                  from portfolio
                  where port_num = @my_port_num)
   begin
      print 'Please provide a valid port_num for the argument @top_port_num!'
      goto reportusage
   end

   create table #children2 (port_num int)

   insert into #children 
   select port_num, port_type 
   from portfolio 
   where port_num = @my_port_num
   
   while exists (select 1 from #children where port_type <> 'R')
   begin
      insert into #children2 (port_num) 
      select distinct port_num 
      from #children
      where port_type <> 'R'

      insert into #children (port_num, port_type) 
      select distinct p.port_num,  
             p.port_type
      from portfolio_group pg, portfolio p
      where pg.port_num = p.port_num and 
            pg.parent_port_num in (select port_num from #children2)
      
      delete #children 
      where port_num in (select port_num from #children2)
      delete #children2
   end
   drop table #children2
   return 0

reportusage:
   print 'Usage: exec usp_RVFile_child_port_nums @top_port_num = ?'
   return 1
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_child_port_nums] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_RVFile_child_port_nums', NULL, NULL
GO
