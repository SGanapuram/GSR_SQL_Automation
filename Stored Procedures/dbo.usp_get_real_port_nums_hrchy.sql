SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_get_real_port_nums_hrchy]
(
	 @top_port_num	 int = 0,
	 @debugon        bit = 0 
)
as
set nocount on

   create table #children 
   (
	    port_num  INT PRIMARY KEY,
	    port_type CHAR(2)
   )

declare @my_top_port_num   int 

   set @top_port_num = @top_port_num

   exec dbo.usp_get_child_port_nums @top_port_num, 1

   select port_short_name,
          port_num,
          port_type   
   from dbo.portfolio  
   where port_num in (select port_num from #children)

endofsp: 
drop table #children
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_get_real_port_nums_hrchy] TO [next_usr]
GO
