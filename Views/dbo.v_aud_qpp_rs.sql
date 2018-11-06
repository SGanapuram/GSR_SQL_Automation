SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_aud_qpp_rs]
as
select
   audtb.*,
   it.type as trans_type,
   it.user_init as trans_user_init,
   it.tran_date,
   it.app_name
from dbo.aud_quote_pricing_period audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_aud_qpp_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_aud_qpp_rs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[v_aud_qpp_rs] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_aud_qpp_rs', NULL, NULL
GO
