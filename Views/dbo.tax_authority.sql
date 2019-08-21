SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[tax_authority] 
(
	acct_num, 
	acct_short_name, 
	acct_full_name
)
as
select 
   acct_num, 
   acct_short_name, 
   acct_full_name 
from dbo.account
where acct_type_code = 'TAXAUTH'
GO
GRANT SELECT ON  [dbo].[tax_authority] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[tax_authority] TO [next_usr]
GO
