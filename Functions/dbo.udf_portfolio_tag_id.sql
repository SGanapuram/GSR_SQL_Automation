SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_portfolio_tag_id]
(
   @tag_name       varchar(16)
)
returns int
as
begin
declare @tag_id   int

   set @tag_id = 0
   select @tag_id = isnull(oid, 0)
   from dbo.entity_tag_definition
   where entity_tag_name = @tag_name and
         entity_id = (select oid
                      from dbo.icts_entity_name
                      where entity_name = 'Portfolio')
   
   return @tag_id
end
GO
GRANT EXECUTE ON  [dbo].[udf_portfolio_tag_id] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[udf_portfolio_tag_id] TO [next_usr]
GO
