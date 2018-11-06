SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_filters_for_app]
(
   @application    varchar(40),
   @table_name     varchar(40) = null
)
as
begin
set nocount on

   select
      f.table_name,
      f.column_name,
      sc.type,
      f.alias_name,
      f.filter_name
   from dbo.filters f with (nolock),
        sys.syscolumns sc
   where f.application = @application and 
         (sc.id = object_id(f.table_name) and 
          sc.name = f.column_name)
   order by f.alias_name
end
GO
GRANT EXECUTE ON  [dbo].[find_filters_for_app] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'find_filters_for_app', NULL, NULL
GO
