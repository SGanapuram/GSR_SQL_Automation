SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_get_portfolio_path]
(
   @port_num       int,
   @path           varchar(max) output
)
as
set nocount on
declare @maxoid            int,
        @parent_port_num   int

   if @port_num is null
      set @port_num = 0
      
   if not exists (select 1
                  from dbo.portfolio
                  where port_num = @port_num)
      return 1
      
   create table #portnums 
   (
      oid      int IDENTITY primary key,
      port_num int not null
   )

   insert into #portnums values(@port_num)

   while (1 = 1)
   begin
      set @parent_port_num = null
      select @parent_port_num = parent_port_num
      from dbo.portfolio_group
      where port_num = @port_num
   
      if @parent_port_num is null
         break

      insert into #portnums values(@parent_port_num)
      set @port_num = @parent_port_num
   end

   select @maxoid = max(oid)
   from #portnums

   set @path = (select case when p1.oid < @maxoid then '/' else '' end + p.port_short_name AS [text()]
                from #portnums p1
                        inner join dbo.portfolio p
                           on p1.port_num = p.port_num 
                ORDER BY p1.oid desc
                FOR XML PATH(''))
             
   drop table #portnums
   return 0
GO
GRANT EXECUTE ON  [dbo].[usp_get_portfolio_path] TO [next_usr]
GO
