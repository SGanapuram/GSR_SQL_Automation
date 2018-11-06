SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[trade_headline_comment]
(
	 trade_num,
	 cmnt_num,
	 tiny_cmnt,
	 short_cmnt,
	 cmnt_text
)
as
select
   tc.trade_num,
   c.cmnt_num,
   c.tiny_cmnt,
   c.short_cmnt,
   c.cmnt_text
from dbo.trade_comment tc, 
     dbo.comment c
where tc.trade_cmnt_type = 'O' and
      c.cmnt_num = tc.cmnt_num 
GO
GRANT SELECT ON  [dbo].[trade_headline_comment] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[trade_headline_comment] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'trade_headline_comment', NULL, NULL
GO
