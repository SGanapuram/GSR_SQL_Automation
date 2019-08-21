SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_find_entity_id]
(
   @entity_name          varchar(16) = null,
   @entity_id            int OUTPUT
)
as
set nocount on
declare @my_entity_id          int,
        @my_entity_name        varchar(16),
        @errcode               int

   select @entity_id = null,
          @my_entity_name = @entity_name,
          @my_entity_id = null,
          @errcode = 0

   if @my_entity_name is not null
   begin
      select @my_entity_id = oid
      from dbo.icts_entity_name
      where entity_name = @my_entity_name
      select @errcode = @@error
   end
   
   if @errcode > 0 
      select @my_entity_id = null

   select @entity_id = @my_entity_id
   return @errcode
GO
GRANT EXECUTE ON  [dbo].[usp_find_entity_id] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[usp_find_entity_id] TO [public]
GO
