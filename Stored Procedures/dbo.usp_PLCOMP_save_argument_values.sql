SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
CREATE procedure [dbo].[usp_PLCOMP_save_argument_values]
(
   @root_port_num    int,                                                  
   @cob_date1        datetime = NULL,                              
   @cob_date2        datetime = NULL,
   @tag_xml_string   xml = NULL,
   @debugon          bit = 0
)                             
as                             
set nocount on 
declare @tempstr           varchar(max)

   set @tempstr = cast(@root_port_num as varchar)
   exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                     @occurred_at = 'SP: usp_PLCOMP_save_argument_values', 
                                     @problem_desc = 'Value of the argument @root_port_num passed to stored procedure',                                            
                                     @dberror_msg = 'N/A',
                                     @sql_stmt = @tempstr,
                                     @debugon = @debugon                                                                                                    

   set @tempstr = case when @cob_date1 is null then 'NULL, ' 
                       else '''' + convert(varchar, @cob_date1, 101) + '''' 
                  end                                               
   exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                     @occurred_at = 'SP: usp_PLCOMP_save_argument_values', 
                                     @problem_desc = 'Value of the argument @cob_date1 passed to stored procedure',                                            
                                     @dberror_msg = 'N/A',
                                     @sql_stmt = @tempstr,
                                     @debugon = @debugon  
                                                                                                                                       
   set @tempstr = case when @cob_date2 is null then 'NULL, ' 
                       else '''' + convert(varchar, @cob_date2, 101) + '''' 
                  end                                               
   exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                     @occurred_at = 'SP: usp_PLCOMP_save_argument_values', 
                                     @problem_desc = 'Value of the argument @cob_date2 passed to stored procedure',                                            
                                     @dberror_msg = 'N/A',
                                     @sql_stmt = @tempstr,
                                     @debugon = @debugon    
   set @tempstr = convert(varchar(max), @tag_xml_string)                                                                                                                            
   exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                     @occurred_at = 'SP: usp_PLCOMP_save_argument_values', 
                                     @problem_desc = 'Value of the argument @tag_xml_string passed to stored procedure',                                            
                                     @dberror_msg = 'N/A',
                                     @sql_stmt = @tempstr,
                                     @debugon = @debugon                                                                                                    
GO
GRANT EXECUTE ON  [dbo].[usp_PLCOMP_save_argument_values] TO [next_usr]
GO
