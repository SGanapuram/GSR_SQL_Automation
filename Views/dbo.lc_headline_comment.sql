SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[lc_headline_comment]
(
	 lc_num, 
	 cmnt_num,
	 tiny_cmnt, 
	 short_cmnt, 
	 cmnt_text
)
as
select 
	 lcc.lc_num, 
	 c.cmnt_num,
	 c.tiny_cmnt, 
	 c.short_cmnt, 
	 c.cmnt_text 
from dbo.lc_comment lcc, 
     dbo.comment c
where lcc.cmnt_num = c.cmnt_num and 
      lcc.lc_cmnt_type = 'HEADLINE'

GO
GRANT SELECT ON  [dbo].[lc_headline_comment] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[lc_headline_comment] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'lc_headline_comment', NULL, NULL
GO
