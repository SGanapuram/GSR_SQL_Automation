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
GRANT EXECUTE ON  [dbo].[udf_count_a_char_occurrences] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[udf_count_a_char_occurrences] TO [next_usr]
GO
