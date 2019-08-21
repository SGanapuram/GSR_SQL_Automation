SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_idms_department_mappings]
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
      select idm.idms_dept_code,
             idm.idms_dept_name,
             idm.newsgrazer_dept_name,
	           idm.trans_id
      from dbo.idms_department_mapping idm
   end
   else if @by_type0 = 'idms_dept_name'
   begin
      select idm.idms_dept_code,
             idm.idms_dept_name,
             idm.newsgrazer_dept_name,
	           idm.trans_id
      from dbo.idms_department_mapping idm
      where idm.idms_dept_name = @by_ref0
   end
   else if @by_type0 = 'idms_dept_code'
   begin
      select idm.idms_dept_code,
             idm.idms_dept_name,
             idm.newsgrazer_dept_name,
	           idm.trans_id
      from dbo.idms_department_mapping idm
      where idm.idms_dept_code = @by_ref0
   end
   else if @by_type0 = 'newsgrazer_dept_name'
   begin
      select idm.idms_dept_code,
             idm.idms_dept_name,
             idm.newsgrazer_dept_name,
	           idm.trans_id
      from dbo.idms_department_mapping idm
      where idm.newsgrazer_dept_name = @by_ref0
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
GRANT EXECUTE ON  [dbo].[find_idms_department_mappings] TO [next_usr]
GO
