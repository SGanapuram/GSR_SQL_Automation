SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_port_list_children] 
(
   @port_type           char(2),
   @show_port_num_ind   bit = 1
)
as
set nocount on

   -- Functionally, this stored proc is similar to port_children, except for one performance improvement.
   -- This stored proc accepts a list of all first level portfolios as a temp table #selectedportfolios
   -- instead of getting them one at a time (requires a while loop in the calling procedure)

   if @show_port_num_ind is null
      select @show_port_num_ind = 1

   create table #children2 (port_num int)

   insert into #children 
   select port_num, port_type 
   from dbo.portfolio 
   where port_num in (select port_num from #selectedportfolios)

   while exists (select 1 from #children where port_type <> @port_type)
   begin
      insert into #children2 (port_num) 
      select distinct port_num 
      from #children
      where port_type <> @port_type

      insert into #children (port_num, port_type) 
      select distinct 
         p.port_num,  p.port_type
      from dbo.portfolio_group pg, 
           dbo.portfolio p
      where pg.port_num = p.port_num and 
            pg.parent_port_num in (select port_num from #children2)
      
      delete #children 
      where port_num in (select port_num from #children2)
      truncate table #children2
   end
   if @show_port_num_ind = 1
      select port_num from #children

   drop table #children2
   return
GO
GRANT EXECUTE ON  [dbo].[usp_port_list_children] TO [next_usr]
GO
