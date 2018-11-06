SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_idms_location_mappings]
(
   @by_type0    varchar(40) = null,
   @by_ref0	    varchar(255) = null
)
as 
begin
set nocount on
declare @rowcount int

   if @by_type0 = 'all'
   begin
      select ilm.idms_loc_code,
             ilm.idms_loc_initial,
             ilm.idms_board_name,
             ilm.newsgrazer_loc_name,
             ilm.trans_id
      from dbo.idms_location_mapping ilm
   end
   else if @by_type0 = 'idms_loc_initial'
   begin
      select ilm.idms_loc_code,
             ilm.idms_loc_initial,
             ilm.idms_board_name,
             ilm.newsgrazer_loc_name,
             ilm.trans_id
      from dbo.idms_location_mapping ilm
      where ilm.idms_loc_initial = @by_ref0
   end
   else if @by_type0 = 'idms_board_name'
   begin
      select ilm.idms_loc_code,
             ilm.idms_loc_initial,
             ilm.idms_board_name,
             ilm.newsgrazer_loc_name,
             ilm.trans_id
      from dbo.idms_location_mapping ilm
      where ilm.idms_board_name = @by_ref0
   end
   else if @by_type0 = 'newsgrazer_loc_name'
   begin
      select ilm.idms_loc_code,
             ilm.idms_loc_initial,
             ilm.idms_board_name,
             ilm.newsgrazer_loc_name,
             ilm.trans_id
      from dbo.idms_location_mapping ilm
      where ilm.newsgrazer_loc_name = @by_ref0
   end
   else 
      return 4

   set @rowcount = @@rowcount
   if (@rowcount = 1)
      return 0
   else if (@rowcount = 0)
      return 1
   else 
      return 2
end
GO
GRANT EXECUTE ON  [dbo].[find_idms_location_mappings] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'find_idms_location_mappings', NULL, NULL
GO
