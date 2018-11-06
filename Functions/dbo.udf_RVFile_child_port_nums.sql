SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_RVFile_child_port_nums]
(
    @top_port_num     int = null
)
returns @result table
	(
	   port_num  int,
	   port_type char(2) 
	)
as
begin
-- set nocount on
declare @my_port_num     int
declare @children2       table(port_num  int)

   select @my_port_num = @top_port_num
   if @my_port_num is null
      set @my_port_num = -1
   else
   begin
      if not exists (select 1
                     from dbo.portfolio
                     where port_num = @my_port_num)
         set @my_port_num = -1
   end
   
   insert into @result 
   select port_num, port_type 
   from dbo.portfolio 
   where port_num = @my_port_num
   
   while exists (select 1 from @result where port_type <> 'R')
   begin
      insert into @children2 (port_num) 
      select distinct port_num 
      from @result
      where port_type <> 'R'

      insert into @result (port_num, port_type) 
      select distinct p.port_num,  
             p.port_type
      from dbo.portfolio_group pg, 
           dbo.portfolio p
      where pg.port_num = p.port_num and 
            pg.parent_port_num in (select port_num from @children2)
      
      delete @result 
      where port_num in (select port_num from @children2)
      delete @children2
   end
   return
end
GO
GRANT SELECT ON  [dbo].[udf_RVFile_child_port_nums] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'FUNCTION', N'udf_RVFile_child_port_nums', NULL, NULL
GO
