SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[trade_book_comp_view] 
(       
   acct_num,
   acct_short_name,
   acct_full_name,
   trans_id
)
as  
select
   a.acct_num,
   a.acct_short_name,
   a.acct_full_name,
   a.trans_id
from dbo.account a,
     dbo.trade_item ti
where a.acct_num = ti.booking_comp_num
GO
GRANT SELECT ON  [dbo].[trade_book_comp_view] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[trade_book_comp_view] TO [next_usr]
GO
