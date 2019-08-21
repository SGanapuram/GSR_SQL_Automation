SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[tax_code_commodity] 
(
	 cmdty_code, 
	 cmdty_short_name, 
	 cmdty_full_name
)
as
select 
   cmdty_code, 
   cmdty_short_name, 
   cmdty_full_name 
from dbo.commodity
where cmdty_type = 'T'
GO
GRANT SELECT ON  [dbo].[tax_code_commodity] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[tax_code_commodity] TO [next_usr]
GO
