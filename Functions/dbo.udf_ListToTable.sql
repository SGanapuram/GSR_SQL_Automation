SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[udf_ListToTable] (@list nvarchar(MAX))
   RETURNS @tbl TABLE (vchar_value varchar(200) NOT NULL) AS
BEGIN
   DECLARE @pos        int,
           @nextpos    int,
           @valuelen   int

   SELECT @pos = 0, @nextpos = 1

   WHILE @nextpos > 0
   BEGIN
      SELECT @nextpos = charindex(',', @list, @pos + 1)
      SELECT @valuelen = CASE WHEN @nextpos > 0
                              THEN @nextpos
                              ELSE len(@list) + 1
                         END - @pos - 1
      INSERT @tbl (vchar_value)
         VALUES (substring(@list, @pos + 1, @valuelen))
      SELECT @pos = @nextpos
   END
   RETURN
END

GO
GRANT SELECT ON  [dbo].[udf_ListToTable] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[udf_ListToTable] TO [next_usr]
GO
