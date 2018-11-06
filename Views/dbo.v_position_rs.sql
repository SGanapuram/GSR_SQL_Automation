SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_position_rs]
as
select
   maintb.*,
   it.type as trans_type,
   it.user_init as trans_user_init,
   it.tran_date,
   it.app_name
from dbo.position maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_position_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_position_rs] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_position_rs', NULL, NULL
GO
