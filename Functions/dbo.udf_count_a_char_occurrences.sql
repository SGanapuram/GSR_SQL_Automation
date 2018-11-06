SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_count_a_char_occurrences] 
( 
    @pInput         varchar(1000), 
    @pSearchChar    char(1) 
)
returns int
begin
   return (len(@pInput) - len(replace(@pInput, @pSearchChar, '')))
end
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'FUNCTION', N'udf_count_a_char_occurrences', NULL, NULL
GO
