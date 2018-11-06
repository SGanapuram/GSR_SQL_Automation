SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_move_items_from_list_to_table] 
(
   @list        varchar(MAX)
)
returns @tbl TABLE (vchar_value varchar(200) NOT NULL)
as
begin
   DECLARE @pos        int,
           @nextpos    int,
           @valuelen   int

   set @pos = 0
   set @nextpos = 1

   while @nextpos > 0
   begin
      set @nextpos = charindex(',', @list, @pos + 1)
      set @valuelen = case when @nextpos > 0 then @nextpos
                           else len(@list) + 1
                      end - @pos - 1
                      
      insert @tbl (vchar_value)
         values (substring(@list, @pos + 1, @valuelen))
      set @pos = @nextpos
   end
   return
end
GO
GRANT SELECT ON  [dbo].[udf_move_items_from_list_to_table] TO [next_usr]
GO
