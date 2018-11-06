SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchAllocItemToAiVat]
(
   @alloc_item_num      int,
   @alloc_num           int,
   @asof_trans_id       int
)
as
set nocount on
 
   select aad,
          alloc_item_num,
          alloc_num,
          asof_trans_id = @asof_trans_id,
          booking_comp_fiscal_rep,
          booking_comp_vat_number_id,
          cmdty_nomenclature_id,
          counterparty_fiscal_rep,
          counterparty_vat_number_id,
          destination_country_code,
          excise_num,
          excise_number_id,
          origin_country_code,
          ready_for_accounting_ind,
          resp_trans_id = NULL,
          tank_num,
          title_transfer_country_code,
          trans_id,
          vat_applies_ind,
          vat_country_code,
          vat_declaration_id,
          vat_trans_nature_code,
          vat_type_code,
          warehouse_permit_holder,
          warehouse_permit_loc_code,
          wph_excise_num,
          wph_vat_number_id
   from dbo.allocation_item_vat
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         trans_id <= @asof_trans_id
   union
   select aad,
          alloc_item_num,
          alloc_num,
          asof_trans_id = @asof_trans_id,
          booking_comp_fiscal_rep,
          booking_comp_vat_number_id,
          cmdty_nomenclature_id,
          counterparty_fiscal_rep,
          counterparty_vat_number_id,
          destination_country_code,
          excise_num,
          excise_number_id,
          origin_country_code,
          ready_for_accounting_ind,
          resp_trans_id,
          tank_num,
          title_transfer_country_code,
          trans_id,
          vat_applies_ind,
          vat_country_code,
          vat_declaration_id,
          vat_trans_nature_code,
          vat_type_code,
          warehouse_permit_holder,
          warehouse_permit_loc_code,
          wph_excise_num,
          wph_vat_number_id
   from dbo.aud_allocation_item_vat
   where alloc_num = @alloc_num and
         alloc_item_num = @alloc_item_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchAllocItemToAiVat] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchAllocItemToAiVat', NULL, NULL
GO
