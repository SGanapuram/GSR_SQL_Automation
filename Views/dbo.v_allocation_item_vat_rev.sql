SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_allocation_item_vat_rev]
(
   alloc_num, 
   alloc_item_num,
   origin_country_code, 
   title_transfer_country_code, 
   destination_country_code, 
   vat_country_code, 
   booking_comp_vat_number_id,     
   booking_comp_fiscal_rep,     
   counterparty_vat_number_id,     
   counterparty_fiscal_rep,     
   vat_trans_nature_code, 
   vat_declaration_id,     
   cmdty_nomenclature_id,     
   aad,
   warehouse_permit_holder,     
   wph_vat_number_id,    
   vat_type_code,
   excise_num,
   ready_for_accounting_ind,
   vat_applies_ind,
   warehouse_permit_loc_code,
   excise_number_id,
   tank_num,
   wph_excise_num,
   trans_id,
   asof_trans_id,
   resp_trans_id
)
as
select
   alloc_num, 
   alloc_item_num,
   origin_country_code, 
   title_transfer_country_code, 
   destination_country_code, 
   vat_country_code, 
   booking_comp_vat_number_id,     
   booking_comp_fiscal_rep,     
   counterparty_vat_number_id,     
   counterparty_fiscal_rep,     
   vat_trans_nature_code, 
   vat_declaration_id,     
   cmdty_nomenclature_id,     
   aad,
   warehouse_permit_holder,     
   wph_vat_number_id,    
   vat_type_code,
   excise_num,
   ready_for_accounting_ind,
   vat_applies_ind,
   warehouse_permit_loc_code,
   excise_number_id,
   tank_num,
   wph_excise_num,
   trans_id,
   trans_id,
   resp_trans_id
from dbo.aud_allocation_item_vat
GO
GRANT SELECT ON  [dbo].[v_allocation_item_vat_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_allocation_item_vat_rev] TO [next_usr]
GO
