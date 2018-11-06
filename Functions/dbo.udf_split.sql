SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create function [dbo].[udf_split]
(
	@row_data varchar(2000),
	@split_on varchar(5)
)  
returns @rtnvalue table 
(
	data varchar(100)
) 
as  
begin
	 while (charindex(@split_on, @row_data) > 0)
	 begin
		 insert into @rtnvalue (data)
		   select ltrim(rtrim(Substring(@row_data, 1, charindex(@split_on, @row_data) - 1)))

		 set @row_data = substring(@row_data, charindex(@split_on, @row_data) + 1, len(@row_data))
	 end
	
   insert into @rtnvalue (data)
	    select ltrim(rtrim(@row_data))

	 return
end
GO
GRANT SELECT ON  [dbo].[udf_split] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'FUNCTION', N'udf_split', NULL, NULL
GO
