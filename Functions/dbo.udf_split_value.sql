SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE FUNCTION [dbo].[udf_split_value]
(  
 @row_data	varchar(2000),  
 @split_on	varchar(5),  
 @index		int  
)    
RETURNS varchar(100)    
as    
begin
    declare	@i        int,
		@return   varchar(100)

    set @return = ''  
    set @i = 0  
  
    if @index = 1  
        set @return =  ltrim(rtrim(Substring(@row_data, 1, charindex(@split_on, @row_data) - 1)))  
    else  
    begin  
        while @i < @index-1  
        begin           
            set @row_data = substring(@row_data, charindex(@split_on, @row_data) + 1, len(@row_data))
            if( charindex(@split_on, @row_data) >0)
                 SET @return = ltrim(rtrim(Substring(@row_data, 1, charindex(@split_on, @row_data) - 1)))
            set @i = @i+1
        end
        if( charindex(@split_on, @row_data) =0)
            set @return = @row_data
    end
   return @return
end
GO
GRANT EXECUTE ON  [dbo].[udf_split_value] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'FUNCTION', N'udf_split_value', NULL, NULL
GO
