SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_child_port_nums]
(
   @top_port_num     int = null,
   @real_only_ind    bit = 1
)
as
set nocount on
declare @my_port_num     int

   set @my_port_num = @top_port_num
   if @my_port_num is null
   begin
      print 'Please provide a port_num for the argument @top_port_num!'
      goto reportusage
   end

   if not exists (select 1
                  from dbo.portfolio with (nolock)
                  where port_num = @my_port_num)
   begin
      print 'Please provide a valid port_num for the argument @top_port_num!'
      goto reportusage
   end

   create table #children2 (port_num int)
   if @real_only_ind = 0
      create table #children3 (port_num int, port_type char(2))

   insert into #children 
   select port_num, port_type 
   from dbo.portfolio 
   where port_num = @my_port_num and
         port_type not in ('G', 'P')
   
   while exists (select 1 from #children where port_type <> 'R')
   begin
      if @real_only_ind = 0
      begin
         insert into #children3 (port_num, port_type)
         select port_num, port_type
         from #children a
         where port_type <> 'R' and
               not exists (select 1
                           from #children3 b
                           where a.port_num = b.port_num)
      end
      
      insert into #children2 (port_num) 
      select distinct port_num 
      from #children
      where port_type <> 'R'

      insert into #children (port_num, port_type) 
      select distinct 
         p.port_num,  
         p.port_type
      from dbo.portfolio_group pg, 
           dbo.portfolio p
      where pg.port_num = p.port_num and 
            pg.parent_port_num in (select port_num from #children2) and
            p.port_type not in ('G', 'P')
      
      delete #children 
      where port_num in (select port_num from #children2)
      delete #children2
   end
   drop table #children2
   
   if @real_only_ind = 0
   begin
      insert into #children
      select port_num, port_type
      from #children3 a
      where not exists (select 1
                        from #children b
                        where a.port_num = b.port_num)
      drop table #children3
   end
   return 0

reportusage:
   print 'Usage: exec dbo.usp_get_child_port_nums @top_port_num = ? [, @real_only_ind = ?]'
   return 1
GO
GRANT EXECUTE ON  [dbo].[usp_get_child_port_nums] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_get_child_port_nums', NULL, NULL
GO
