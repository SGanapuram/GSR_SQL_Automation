SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[usp_get_parent_loc_codes]
as
set nocount on      
      
 select l.*,lg.parent_loc_code,convert(varchar(500),'') loc_path into #loc_codes       
 from location l join location_group lg       
 on l.loc_code = lg.loc_code       
 where lg.loc_type_code = 'DEL' and              
       l.loc_code != '/'  and       
       l.loc_code != '' and       
       l.loc_status ='A' and       
       l.loc_code != 'CHE'  -- this is a bad record.. no parent location code with loc_type DEL in location_group.
      
 create nonclustered index loc_codes_idx on #loc_codes(loc_code)          
        
 declare @loc_code   char(8)      
 declare @parent_loc_code char(8)      
 declare @loc_code_name  varchar(40)      
 declare @result    varchar(500)      
       
 select @loc_code = min(loc_code) from #loc_codes       
       
 while @loc_code is not null      
 begin       
     select @result = null      
  select @parent_loc_code = parent_loc_code from dbo.location_group where loc_code = @loc_code and loc_type_code = 'DEL'      
  select @loc_code_name = loc_name from dbo.location where loc_code = @parent_loc_code      
  select @result = rtrim(@loc_code_name)        
  while @parent_loc_code is not null and rtrim(@parent_loc_code) != '/'      
  begin         
   select @parent_loc_code = parent_loc_code from dbo.location_group where loc_code = @parent_loc_code and loc_type_code = 'DEL'      
            
   if @parent_loc_code is not null and @parent_loc_code != '/'      
   begin      
    select @loc_code_name = loc_name from dbo.location where loc_code = @parent_loc_code       
    select @result = rtrim(@loc_code_name)+'/'+@result      
   end       
  end      
        
  update #loc_codes      
  set loc_path = @result      
  where loc_code = @loc_code      
          
  select @loc_code = min(loc_code) from #loc_codes where loc_code > @loc_code      
 end          
       
update #loc_codes  
set loc_path = ''  
where loc_path = 'ROOT'  
  
select * from #loc_codes where loc_path != 'ROOT'      
       
if object_id('tempdb..#loc_codes') is not null      
 drop table #loc_codes      
GO
GRANT EXECUTE ON  [dbo].[usp_get_parent_loc_codes] TO [next_usr]
GO
