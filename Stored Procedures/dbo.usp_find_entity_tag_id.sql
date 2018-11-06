SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_find_entity_tag_id]
(
   @target_entity_id   int = null,
   @entity_id          int = null,
   @tag_name           varchar(16) = null,
   @tag_id             int OUTPUT
)
as
set nocount on
declare @entity_tag_id         int,
        @my_target_entity_id   int,
        @my_entity_id          int,
        @my_tag_name           varchar(16),
        @errcode               int

   select @entity_tag_id = null,
          @my_target_entity_id = @target_entity_id,
          @my_entity_id = @entity_id,
          @my_tag_name = @tag_name,
          @errcode = 0

   if @my_target_entity_id is not null
   begin
      select @entity_tag_id = oid
      from dbo.entity_tag_definition
      where entity_tag_name = @my_tag_name and
            target_entity_id = @my_target_entity_id and
            entity_id = @my_entity_id
      select @errcode = @@error
   end
   else
   begin
      select @entity_tag_id = oid
      from dbo.entity_tag_definition
      where entity_tag_name = @my_tag_name and
            entity_id = @my_entity_id
      select @errcode = @@error
   end
   
   if @errcode > 0
      select @entity_tag_id = null

   select @tag_id = @entity_tag_id
   return @errcode
GO
GRANT EXECUTE ON  [dbo].[usp_find_entity_tag_id] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[usp_find_entity_tag_id] TO [next_usr]
GO
GRANT EXECUTE ON  [dbo].[usp_find_entity_tag_id] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_find_entity_tag_id', NULL, NULL
GO
