SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_idms_board_mappings]
(
   @by_type0		varchar(40) = null,
   @by_ref0		  varchar(255) = null
)
as 
begin
set nocount on
declare @rowcount int

   if @by_type0 = 'all'
   begin
      select ibm.next_name,
             ibm.idms_name,
             ibm.trans_id
      from dbo.idms_board_mapping ibm
   end
   else
   if (@by_type0 = 'idms_name')
   begin
      select ibm.next_name,
             ibm.idms_name,
             ibm.trans_id
      from dbo.idms_board_mapping ibm
      where idms_name = @by_ref0
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
GRANT EXECUTE ON  [dbo].[find_idms_board_mappings] TO [next_usr]
GO
