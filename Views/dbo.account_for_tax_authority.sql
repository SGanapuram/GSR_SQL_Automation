SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[account_for_tax_authority]
(
   acct_num,
   acct_short_name,
   acct_full_name,
   acct_status,
   acct_type_code,    
   acct_parent_ind,
   acct_sub_ind,
   acct_vat_code,
   acct_fiscal_code,
   acct_sub_type_code,
   contract_cmnt_num,
   man_input_sec_qty_required,
   trans_id
)
as
select 
   a.acct_num,
   a.acct_short_name,
   a.acct_full_name,
   a.acct_status,
   a.acct_type_code,    
   a.acct_parent_ind,
   a.acct_sub_ind,
   a.acct_vat_code,
   a.acct_fiscal_code,
   a.acct_sub_type_code,
   a.contract_cmnt_num,
   a.man_input_sec_qty_required,
   a.trans_id
from account a
where a.acct_type_code = 'TAXAUTH' and
      exists (select 1
              from dbo.license lic
              where a.acct_num = lic.issuing_tax_authority_num)
GO
GRANT SELECT ON  [dbo].[account_for_tax_authority] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[account_for_tax_authority] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'account_for_tax_authority', NULL, NULL
GO
