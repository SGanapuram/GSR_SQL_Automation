SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[user_permission]
(
   user_init,
   function_num,
   perm_level,
   trans_id
)
as
select 
   usp.user_init,
   fd.function_num,
   fdv.attr_value,
   usp.trans_id
from dbo.icts_user_permission usp,
     dbo.function_detail fd,
     dbo.function_detail_value fdv
where usp.fdv_id = fdv.fdv_id and
      fdv.fd_id = fd.fd_id and
      fd.entity_name = 'LEVEL'
GO
GRANT SELECT ON  [dbo].[user_permission] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[user_permission] TO [next_usr]
GO
