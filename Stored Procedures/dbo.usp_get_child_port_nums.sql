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

   ;WITH ChildPortfolioListCTE(port_num, port_type)
   AS
   ( 
      -- Anchor Member 
      select pg.port_num, p.port_type
      from dbo.portfolio_group pg with (nolock)
	          INNER JOIN dbo.portfolio p with (nolock)
			     ON pg.port_num = p.port_num
      where pg.parent_port_num = @my_port_num
      union all  
      -- Recursive Member 
      select pg.port_num, p.port_type
      from dbo.portfolio_group pg with (nolock)
              INNER JOIN ChildPortfolioListCTE cte 
                 ON pg.parent_port_num = cte.port_num
	          INNER JOIN dbo.portfolio p with (nolock)
			     ON pg.port_num = p.port_num
	  where p.port_type not in ('G', 'P')
   )
   insert into #children
   select *
   from (select port_num, port_type
         from ChildPortfolioListCTE cte
         union all
         select @my_port_num, p.port_type
         from dbo.portfolio p with (nolock)
         where port_num = @my_port_num) t
   where 1 = case when @real_only_ind = 1 then
                     case when t.port_type = 'R' then 1
					      else 0
					 end
			      else 1
			 end

   return 0

reportusage:
   print 'Usage: exec dbo.usp_get_child_port_nums @top_port_num = ? [, @real_only_ind = ?]'
   return 1
GO
GRANT EXECUTE ON  [dbo].[usp_get_child_port_nums] TO [next_usr]
GO
