SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_next_sequence_num] 
(
   @key_name       varchar(40) = null, 
   @next_seq_num   bigint output
) 
as 
set nocount on 
set xact_abort on
declare @errcode        int,
        @smsg           varchar(max)
 
   set @next_seq_num = 0
   set @errcode = 0
   set @smsg = null
   set @next_seq_num = null
   
   begin try
     begin tran
     if @key_name = 'trans_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.icts_transaction_SEQ
        goto exit1
     end
     if @key_name = 'trade_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.trade_SEQ
        goto exit1
     end
     if @key_name = 'alloc_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.allocation_SEQ
        goto exit1
     end
     if @key_name = 'cmf_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.commodity_market_formula_SEQ
        goto exit1
     end
     if @key_name = 'cmnt_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.comment_SEQ
        goto exit1
     end
     if @key_name = 'cost_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.cost_SEQ
        goto exit1
     end
     if @key_name = 'detail_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.ai_est_actual_detail_SEQ
        goto exit1
     end
     if @key_name = 'dist_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.trade_item_dist_SEQ
        goto exit1
     end
     if @key_name = 'formula_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.formula_SEQ
        goto exit1
     end
     if @key_name = 'external_comment_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.external_comment_SEQ
        goto exit1
     end
     if @key_name = 'external_trade_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.external_trade_SEQ
        goto exit1
     end
     if @key_name = 'feed_data_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.feed_data_SEQ
        goto exit1
     end
     if @key_name = 'feed_definition_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.feed_definition_SEQ
        goto exit1
     end
     if @key_name = 'feed_definition_xsd_xml_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.feed_definition_xsd_xml_SEQ
        goto exit1
     end
     if @key_name = 'feed_detail_data_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.feed_detail_data_SEQ
        goto exit1
     end
     if @key_name = 'feed_error_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.feed_error_SEQ
        goto exit1
     end
     if @key_name = 'inv_actual_fifo_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.inv_actual_fifo_SEQ
        goto exit1
     end
     if @key_name = 'inv_actual_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.inv_actual_SEQ
        goto exit1
     end
     if @key_name = 'inv_b_d_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.inventory_build_draw_SEQ
        goto exit1
     end
     if @key_name = 'inv_credit_exposure_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.inv_credit_exposure_SEQ
        goto exit1
     end
     if @key_name = 'inv_fifo_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.inventory_fifo_SEQ
        goto exit1
     end
     if @key_name = 'inv_loop_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.inventory_loop_SEQ
        goto exit1
     end
     if @key_name = 'inv_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.inventory_SEQ
        goto exit1
     end
     if @key_name = 'parcel_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.parcel_SEQ
        goto exit1
     end
     if @key_name = 'shipment_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.shipment_SEQ
        goto exit1
     end
     if @key_name = 'simple_formula_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.simple_formula_SEQ
        goto exit1
     end
     if @key_name = 'uic_report_mod_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.uic_report_modification_SEQ
        goto exit1
     end
     if @key_name = 'uic_rpt_values_config_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.uic_rpt_values_config_SEQ
        goto exit1
     end
     if @key_name = 'var_run_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.var_run_SEQ
        goto exit1
     end
     if @key_name = 'user_resources_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.user_resources_SEQ
        goto exit1
     end
     if @key_name = 'voucher_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.voucher_SEQ
        goto exit1
     end
     if @key_name = 'vessel_dist_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.vessel_dist_SEQ
        goto exit1
     end
     if @key_name = 'voucher_approval_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.voucher_approval_SEQ
        goto exit1
     end
     if @key_name = 'voucher_pay_approval_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.voucher_pay_approval_SEQ
        goto exit1
     end
     if @key_name = 'TI_feed_transaction_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_feed_transaction_SEQ
        goto exit1
     end

	 /* ************************************** */ 
	 /* ************************************** */
     if @key_name = 'acct_agreement_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.account_agreement_SEQ
        goto exit1
     end
     if @key_name = 'acct_bank_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.account_bank_info_SEQ
        goto exit1
     end	
     if @key_name = 'acct_bc_ot_crinfo_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.acct_bc_ot_crinfo_SEQ
        goto exit1
     end
     if @key_name = 'acct_bookcomp_key'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.acct_bookcomp_SEQ
        goto exit1
     end
     if @key_name = 'acct_collat_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.acct_bookcomp_collatera_SEQ
        goto exit1
     end
     if @key_name = 'acct_fiscal_rep_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.acct_fiscal_rep_SEQ
        goto exit1
     end
     if @key_name = 'acct_guarantee_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.acct_bookcomp_guarantee_SEQ
        goto exit1
     end
     if @key_name = 'acct_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.account_SEQ
        goto exit1
     end
     if @key_name = 'acct_restriction_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.acct_bookcomp_restrict_SEQ
        goto exit1
     end
     if @key_name = 'acct_vat_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.acct_vat_number_SEQ
        goto exit1
     end
     if @key_name = 'actual_lot_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.actual_lot_SEQ
        goto exit1
     end
     if @key_name = 'ag_consignee_tankage_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.ag_consignee_tankage_SEQ
        goto exit1
     end
     if @key_name = 'ag_external_codes_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.ag_external_codes_SEQ
        goto exit1
     end
     if @key_name = 'alarm_cmnt_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.credit_alarm_comment_SEQ
        goto exit1
     end
     if @key_name = 'alarm_log_cmnt_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.credit_alarm_log_comment_SEQ
        goto exit1
     end
     if @key_name = 'alloc_chain_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.allocation_chain_SEQ
        goto exit1
     end
     if @key_name = 'alloc_criteria_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.allocation_criteria_SEQ
        goto exit1
     end
     if @key_name = 'als_module_group_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.server_config_SEQ
        goto exit1
     end
     if @key_name = 'assign_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.assign_trade_SEQ
        goto exit1
     end
     if @key_name = 'autopool_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.autopool_criteria_SEQ
        goto exit1
     end
    -- if @key_name = 'bb_ref_num'
    -- begin
    --    set @next_seq_num = NEXT VALUE FOR dbo.trade_item_SEQ
    --   goto exit1
    -- end
     if @key_name = 'bc_fate_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.bus_cost_fate_SEQ
        goto exit1
     end
     if @key_name = 'bc_mail_list_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.bus_cost_mail_list_SEQ
        goto exit1
     end
     if @key_name = 'bc_type_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.bus_cost_type_SEQ
        goto exit1
     end
     if @key_name = 'book_pl_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.portfolio_book_pl_SEQ
        goto exit1
     end
     if @key_name = 'booked_inv_reconcil_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.booked_inv_reconcil_SEQ
        goto exit1
     end
     if @key_name = 'bppl_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.bunker_pur_price_lookup_SEQ
        goto exit1
     end
     if @key_name = 'bsi_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.trade_item_fill_SEQ
        goto exit1
     end
     if @key_name = 'bulk_seq_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.bulk_seq_num_SEQ
        goto exit1
     end
     if @key_name = 'bulk_voucher_queue_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.bulk_voucher_queue_SEQ
        goto exit1
     end
     if @key_name = 'cash_coll_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.cash_collateral_SEQ
        goto exit1
     end
     if @key_name = 'cff_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.cash_forecast_file_SEQ
        goto exit1
     end
     if @key_name = 'cmdty_nomenclature_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.cmdty_nomenclature_SEQ
        goto exit1
     end
     if @key_name = 'coll_party_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.collateral_party_SEQ
        goto exit1
     end
     if @key_name = 'coll_pledged_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.collateral_pledged_SEQ
        goto exit1
     end
     if @key_name = 'commkt_key'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.commodity_market_SEQ
        goto exit1
     end
     if @key_name = 'confirm_method_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.confirm_method_SEQ
        goto exit1
     end
     if @key_name = 'confirm_template_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.confirm_template_SEQ
        goto exit1
     end
     if @key_name = 'cost_approval_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.cost_approval_SEQ
        goto exit1
     end
     if @key_name = 'cost_autogen_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.broker_cost_autogen_SEQ
        goto exit1
     end
     if @key_name = 'cost_credit_exposure_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.cost_credit_exposure_SEQ
        goto exit1
     end
     if @key_name = 'cost_rate_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.cost_rate_SEQ
        goto exit1
     end
     if @key_name = 'cost_template_group_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.cost_template_group_SEQ
        goto exit1
     end
     if @key_name = 'cost_template_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.cost_template_SEQ
        goto exit1
     end
     if @key_name = 'credit_limit_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.credit_limit_SEQ
        goto exit1
     end
     if @key_name = 'credit_reserve_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.credit_reserve_SEQ
        goto exit1
     end
     if @key_name = 'credit_seq_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.credit_seq_num_SEQ
        goto exit1
     end
     if @key_name = 'custom_contract_range_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.custom_contract_range_SEQ
        goto exit1
     end
     if @key_name = 'custom_voucher_range_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.custom_voucher_range_SEQ
        goto exit1
     end
     if @key_name = 'data_file_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.data_file_SEQ
        goto exit1
     end
     if @key_name = 'dflt_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.trade_default_SEQ
        goto exit1
     end
     if @key_name = 'doc_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.document_SEQ
        goto exit1
     end
     if @key_name = 'driver_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.driver_SEQ
        goto exit1
     end
     if @key_name = 'edpl_event_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.edpl_event_SEQ
        goto exit1
     end
     if @key_name = 'eipp_task_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.eipp_task_SEQ
        goto exit1
     end
     if @key_name = 'entity_tag_definition_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.entity_tag_definition_SEQ
        goto exit1
     end
     if @key_name = 'entity_tag_key'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.entity_tag_SEQ
        goto exit1
     end
     if @key_name = 'eom_pb_process_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.eom_posting_batch_SEQ
        goto exit1
     end
     if @key_name = 'event_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.event_SEQ
        goto exit1
     end
     if @key_name = 'exch_fifo_alloc_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.exch_fifo_alloc_SEQ
        goto exit1
     end
     if @key_name = 'exposure_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.exposure_SEQ
        goto exit1
     end
     if @key_name = 'ext_pos_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.external_position_SEQ
        goto exit1
     end
     if @key_name = 'ext_ref_keys_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.ext_ref_keys_SEQ
        goto exit1
     end
     if @key_name = 'ext_refdata_mapping_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.ext_refdata_mapping_SEQ
        goto exit1
     end
     if @key_name = 'ext_trade_loading_sched_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.ext_trade_loading_sched_SEQ
        goto exit1
     end
     if @key_name = 'ext_trandata_mapping_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.ext_trandata_mapping_SEQ
        goto exit1
     end
     if @key_name = 'ext_trans_keys_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.ext_trans_keys_SEQ
        goto exit1
     end
     if @key_name = 'external_mapping_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.external_mapping_SEQ
        goto exit1
     end
     if @key_name = 'external_trade_type_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.external_trade_type_SEQ
        goto exit1
     end
     if @key_name = 'facility_link_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.facility_link_SEQ
        goto exit1
     end
     if @key_name = 'fd_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.function_detail_SEQ
        goto exit1
     end
     if @key_name = 'fdv_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.function_detail_value_SEQ
        goto exit1
     end
     if @key_name = 'feed_cash_inbound_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.feed_cash_inbound_SEQ
        goto exit1
     end
     if @key_name = 'feed_refdata_mapping_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.feed_refdata_mapping_SEQ
        goto exit1
     end
     if @key_name = 'feed_scheduler_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.feed_scheduler_SEQ
        goto exit1
     end
     if @key_name = 'feed_xsd_xml_text_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.feed_xsd_xml_text_SEQ
        goto exit1
     end
     if @key_name = 'fifo_group_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fifo_group_SEQ
        goto exit1
     end
     if @key_name = 'fifo_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.trade_item_fill_fifo_SEQ
        goto exit1
     end
     if @key_name = 'file_load_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.file_load_SEQ
        goto exit1
     end
     if @key_name = 'financial_reconcil_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.financial_reconcil_SEQ
        goto exit1
     end
     if @key_name = 'fips_city_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fips_city_SEQ
        goto exit1
     end
     if @key_name = 'fips_county_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fips_county_SEQ
        goto exit1
     end
     if @key_name = 'fips_state_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fips_state_SEQ
        goto exit1
     end
     if @key_name = 'forecast_value_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.forecast_value_SEQ
        goto exit1
     end
     if @key_name = 'function_action_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.function_action_SEQ
        goto exit1
     end
     if @key_name = 'fx_cost_draw_down_hist_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fx_cost_draw_down_hist_SEQ
        goto exit1
     end
     if @key_name = 'fx_exposure_currency_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fx_exposure_currency_SEQ
        goto exit1
     end
     if @key_name = 'fx_exposure_dist_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fx_exposure_dist_SEQ
        goto exit1
     end
     if @key_name = 'fx_exposure_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fx_exposure_SEQ
        goto exit1
     end
     if @key_name = 'fx_hedge_rate_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fx_hedge_rate_SEQ
        goto exit1
     end
     if @key_name = 'fx_linking_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fx_linking_SEQ
        goto exit1
     end
     if @key_name = 'gdd_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.generic_data_definition_SEQ
        goto exit1
     end
     if @key_name = 'gdn_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.generic_data_name_SEQ
        goto exit1
     end
     if @key_name = 'gdv_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.generic_data_values_SEQ
        goto exit1
     end
     if @key_name = 'group_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.credit_group_SEQ
        goto exit1
     end
     if @key_name = 'gtc_agreement_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.gtc_SEQ
        goto exit1
     end
     if @key_name = 'icts_entity_name_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.icts_entity_name_SEQ
        goto exit1
     end
     if @key_name = 'icts_message_detail_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.icts_message_detail_SEQ
        goto exit1
     end
     if @key_name = 'icts_message_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.icts_message_SEQ
        goto exit1
     end
     if @key_name = 'implied_pr_curve_hist_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.implied_pr_curve_hist_SEQ
        goto exit1
     end
     if @key_name = 'implied_pr_curve_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.implied_pr_curve_SEQ
        goto exit1
     end
     if @key_name = 'implied_pr_differential_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.implied_pr_differential_SEQ
        goto exit1
     end
     if @key_name = 'importer_reason_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.importer_record_reason_SEQ
        goto exit1
     end
     if @key_name = 'interface_exec_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.interface_exec_params_SEQ
        goto exit1
     end
     if @key_name = 'inv_seq_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.inv_seq_num_SEQ
        goto exit1
     end
     if @key_name = 'invoice_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.mca_invoice_terms_SEQ
        goto exit1
     end
     if @key_name = 'job_schedule_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.job_schedule_SEQ
        goto exit1
     end
     if @key_name = 'key_value'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.key_value_SEQ
        goto exit1
     end
     if @key_name = 'lc_bankfee_autogen_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.lc_bankfee_autogen_SEQ
        goto exit1
     end
     if @key_name = 'lc_bankfee_refdata_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.lc_bankfee_refdata_SEQ
        goto exit1
     end
     if @key_name = 'lc_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.lc_SEQ
        goto exit1
     end
     if @key_name = 'license_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.license_SEQ
        goto exit1
     end
     if @key_name = 'limit_cmnt_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.credit_limit_comment_SEQ
        goto exit1
     end
     if @key_name = 'live_option_pr_hist_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.live_option_pr_hist_SEQ
        goto exit1
     end
     if @key_name = 'live_option_pr_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.live_option_pr_SEQ
        goto exit1
     end
     if @key_name = 'live_scenario_item_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.live_scenario_item_SEQ
        goto exit1
     end
     if @key_name = 'live_scenario_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.live_scenario_SEQ
        goto exit1
     end
     if @key_name = 'lm_acctdata_mapping_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.lm_acctdata_mapping_SEQ
        goto exit1
     end
     if @key_name = 'lm_margin_history_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.lm_margin_history_SEQ
        goto exit1
     end
     if @key_name = 'lm_marketdata_mapping_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.lm_marketdata_mapping_SEQ
        goto exit1
     end
     if @key_name = 'lm_net_position_history_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.lm_net_position_history_SEQ
        goto exit1
     end
     if @key_name = 'lm_risk_file_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.lm_risk_file_SEQ
        goto exit1
     end
     if @key_name = 'long_cmnt_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pei_comment_cmnt_SEQ
        goto exit1
     end
     if @key_name = 'macc_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.material_adv_chg_clause_SEQ
        goto exit1
     end
     if @key_name = 'margin_call_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.margin_call_SEQ
        goto exit1
     end
     if @key_name = 'market_formula_default_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.market_formula_default_SEQ
        goto exit1
     end
     if @key_name = 'market_value_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.market_value_SEQ
        goto exit1
     end
     if @key_name = 'marketdata_file_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.marketdata_file_SEQ
        goto exit1
     end
     if @key_name = 'marketdata_supplier_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.marketdata_supplier_SEQ
        goto exit1
     end
     if @key_name = 'mca_cmnt_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.mca_comment_SEQ 
        goto exit1
     end
     if @key_name = 'mca_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.master_coll_agreement_SEQ
        goto exit1
     end
     if @key_name = 'mkt_info_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.market_info_SEQ
        goto exit1
     end
     if @key_name = 'mkt_security_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.marketable_security_SEQ
        goto exit1
     end
     if @key_name = 'mpt_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.market_pricing_term_SEQ
        goto exit1
     end
     if @key_name = 'msi_feed_data_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.msi_feed_data_SEQ
        goto exit1
     end
     if @key_name = 'paper_alloc_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.paper_allocation_SEQ
        goto exit1
     end
     if @key_name = 'parcel_quality_slate_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.parcel_quality_slate_SEQ
        goto exit1
     end
     if @key_name = 'parser_field_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.parser_field_SEQ
        goto exit1
     end
     if @key_name = 'parser_field_map_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.parser_field_map_SEQ
        goto exit1
     end
     if @key_name = 'parser_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.parser_SEQ
        goto exit1
     end
     if @key_name = 'pass_control_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pass_control_info_SEQ
        goto exit1
     end
     if @key_name = 'path_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.path_SEQ
        goto exit1
     end
     if @key_name = 'pg_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.parent_guarantee_SEQ
        goto exit1
     end
     if @key_name = 'pipeline_cycle_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pipeline_cycle_SEQ
        goto exit1
     end
     if @key_name = 'piv_def_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.riskmgr_win_pivot_def_SEQ
        goto exit1
     end
     if @key_name = 'pl_offset_transfer_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pl_offset_transfer_SEQ
        goto exit1
     end
     if @key_name = 'pl_reconciliation_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pl_reconciliation_SEQ
        goto exit1
     end
     if @key_name = 'pm_trade_match_criteria_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pm_trade_match_criteria_SEQ
        goto exit1
     end
     if @key_name = 'port_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.portfolio_SEQ
        goto exit1
     end
     if @key_name = 'portfolio_tag_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.icts_function_SEQ
        goto exit1
     end
     if @key_name = 'pos_limit_def_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pos_limit_definition_SEQ
        goto exit1
     end
     if @key_name = 'posting_account_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.posting_account_SEQ
        goto exit1
     end
     if @key_name = 'posting_search_prec_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.posting_search_prec_SEQ
        goto exit1
     end
     if @key_name = 'PostingVouchers'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.PostingVouchers_SEQ
        goto exit1
     end
     if @key_name = 'price_change_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.price_change_SEQ
        goto exit1
     end
     if @key_name = 'priced_quote_period_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.priced_quote_period_SEQ
        goto exit1
     end
     if @key_name = 'product_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.product_SEQ
        goto exit1
     end
     if @key_name = 'psg_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.purchase_sale_group_SEQ
        goto exit1
     end
     if @key_name = 'qty_adj_rule_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.qty_adj_rule_SEQ
        goto exit1
     end
     if @key_name = 'qual_slate_cmdty_spec_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.qual_slate_cmdty_spec_SEQ
        goto exit1
     end
     if @key_name = 'qual_slate_cmdty_sptest_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.qual_slate_cmdty_sptest_SEQ 
        goto exit1
     end
     if @key_name = 'quality_slate_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.quality_slate_SEQ
        goto exit1
     end
     if @key_name = 'qf_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.quickfill_SEQ
        goto exit1
     end
     if @key_name = 'quote_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.quote_SEQ
        goto exit1
     end
     if @key_name = 'quote_marketdata_source_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.quote_marketdata_source_SEQ
        goto exit1
     end
     if @key_name = 'quote_period_description_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.quote_period_description_SEQ
        goto exit1
     end
     if @key_name = 'quote_period_duration_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.quote_period_duration_SEQ
        goto exit1
     end
     if @key_name = 'rc_assign_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.rc_assign_trade_SEQ
        goto exit1
     end
     if @key_name = 'recap_item_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.recap_item_SEQ
        goto exit1
     end
     if @key_name = 'release_doc_driver_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.release_document_driver_SEQ
        goto exit1
     end
     if @key_name = 'release_doc_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.release_document_SEQ
        goto exit1
     end
     if @key_name = 'reprice_event_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.reprice_event_SEQ
        goto exit1
     end
     if @key_name = 'rg_staging_acct_addr_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.rg_staging_acct_address_SEQ
        goto exit1
     end
     if @key_name = 'rin_definition_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.rin_definition_SEQ
        goto exit1
     end
     if @key_name = 'rin_equivalence_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.rin_equivalence_SEQ
        goto exit1
     end
     if @key_name = 'rin_obligation_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.rin_obligation_SEQ
        goto exit1
     end
     if @key_name = 'risk_cover_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.risk_cover_SEQ
        goto exit1
     end
     if @key_name = 'rms_conf_seq_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.rms_confirmation_SEQ
        goto exit1
     end
     if @key_name = 'rms_seq_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.rms_message_SEQ
        goto exit1
     end
     if @key_name = 'roll_criteria_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.inventory_roll_criteria_SEQ
        goto exit1
     end
     if @key_name = 'route_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.route_SEQ
        goto exit1
     end
     if @key_name = 'route_point_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.route_point_SEQ
        goto exit1
     end
     if @key_name = 'row_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.cki_outbound_data_SEQ
        goto exit1
     end
     if @key_name = 'rptext_result_set_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.rptext_result_set_id_SEQ
        goto exit1
     end
     if @key_name = 'sap_file_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.SAP_file_SEQ
        goto exit1
     end
     if @key_name = 'sap_row_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.send_to_SAP_SEQ
        goto exit1
     end
     if @key_name = 'scenario_item_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.scenario_item_SEQ
        goto exit1
     end
     if @key_name = 'scenario_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.scenario_SEQ
        goto exit1
     end
     if @key_name = 'segment_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.segment_SEQ
        goto exit1
     end
     if @key_name = 'special_cond_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.special_condition_SEQ
        goto exit1
     end
     if @key_name = 'symphony_outbound_data_row_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.symphony_outbound_data_SEQ
        goto exit1
     end
     if @key_name = 'sys_resources_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.sys_resources_SEQ  
        goto exit1
     end
     --if @key_name = 'tablet_num'
     --begin
     --   set @next_seq_num = NEXT VALUE FOR dbo.trade_SEQ
     --   goto exit1
     --end
     if @key_name = 'tank_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.location_tank_info_SEQ
        goto exit1
     end
     if @key_name = 'tax_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.tax_SEQ
        goto exit1
     end
     if @key_name = 'tax_rate_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.tax_rate_SEQ
        goto exit1
     end
     if @key_name = 'tcs_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.transport_cost_schedule_SEQ
        goto exit1
     end
     if @key_name = 'TI_book_inv_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_book_inv_SEQ
        goto exit1
     end
     if @key_name = 'TI_demand_forecast_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_demand_forecast_SEQ
        goto exit1
     end
     if @key_name = 'TI_exch_bal_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_exch_bal_SEQ
        goto exit1
     end
     if @key_name = 'TI_feed_definition_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_feed_definition_SEQ
        goto exit1
     end
     if @key_name = 'TI_feed_error_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_feed_error_SEQ
        goto exit1
     end
     if @key_name = 'TI_feed_schedule_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_feed_schedule_SEQ
        goto exit1
     end
     if @key_name = 'TI_feed_transaction_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_feed_transaction_SEQ
        goto exit1
     end
     if @key_name = 'ti_field_mod_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.ti_field_modified_SEQ
        goto exit1
     end
     if @key_name = 'TI_financial_results_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_financial_results_SEQ
        goto exit1
     end
     if @key_name = 'TI_inbound_data_xml_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_inbound_data_xml_SEQ
        goto exit1
     end
     if @key_name = 'ti_plan_exch_obj_feed_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.ti_plan_exch_obj_feed_SEQ
        goto exit1
     end
     if @key_name = 'TI_PSMV_feed_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_PSMV_feed_SEQ
        goto exit1
     end
     if @key_name = 'TI_PSMVal_feed_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_PSMVal_feed_SEQ
        goto exit1
     end
     if @key_name = 'TI_PSMVol_spot_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_PSMVol_spot_SEQ 
        goto exit1
     end
     if @key_name = 'TI_rate_table_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_rate_table_SEQ
        goto exit1
     end
     if @key_name = 'TI_refinery_actual_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_refinery_actual_SEQ
        goto exit1
     end
     if @key_name = 'TI_req_res_xml_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_req_res_xml_SEQ
        goto exit1
     end
     if @key_name = 'TI_RS_refinery_plan_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_RS_refinery_plan_SEQ
        goto exit1
     end
     if @key_name = 'TI_SOP_refinery_plan_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_SOP_refinery_plan_SEQ
        goto exit1
     end
     if @key_name = 'TI_sop_trade_plan_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_sop_trade_plan_SEQ
        goto exit1
     end
     if @key_name = 'TI_TSW_schedule_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_TSW_schedule_SEQ
        goto exit1
     end
     if @key_name = 'TI_TSW_spot_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_TSW_spot_SEQ
        goto exit1
     end
     if @key_name = 'TI_ZDEF_exch_objective_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.TI_ZDEF_exch_objective_SEQ
        goto exit1
     end
     if @key_name = 'trade_group_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.trade_group_SEQ
        goto exit1
     end
     if @key_name = 'trigger_actual_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.formula_body_trigger_actual_SEQ
        goto exit1
     end
     if @key_name = 'truck_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.truck_SEQ
        goto exit1
     end
     if @key_name = 'uic_report_type_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.uic_report_type_SEQ
        goto exit1
     end
     if @key_name = 'uic_rpt_criteria_entity_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.uic_rpt_criteria_entity_SEQ
        goto exit1
     end
     if @key_name = 'uic_rpt_criteria_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.uic_rpt_criteria_SEQ
        goto exit1
     end
     if @key_name = 'uom_conv_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.uom_conversion_SEQ
        goto exit1
     end
     if @key_name = 'user_default_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.user_default_SEQ
        goto exit1
     end
     if @key_name = 'user_login_history_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.user_login_history_SEQ
        goto exit1
     end
     if @key_name = 'valid_quote_duration_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.valid_quote_duration_SEQ
        goto exit1
     end
     if @key_name = 'vat_declaration_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.vat_declaration_SEQ
        goto exit1
     end
     if @key_name = 'venue_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.venue_SEQ
        goto exit1
     end
     if @key_name = 'wakeup_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.wakeup_SEQ
        goto exit1
     end
     if @key_name = 'win_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.riskmgr_win_def_SEQ
        goto exit1
	 end
     if @key_name = 'conc_assay_activity_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_assay_activity_SEQ
        goto exit1
	 end
     if @key_name = 'conc_assay_lab_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_assay_lab_SEQ
        goto exit1
	 end
     if @key_name = 'conc_assay_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_assay_SEQ
        goto exit1
	 end
     if @key_name = 'conc_brand_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_brand_SEQ
        goto exit1
	 end
     if @key_name = 'conc_comment_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_comment_SEQ
        goto exit1
	 end
     if @key_name = 'conc_contract_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_contract_SEQ
        goto exit1
	 end
     if @key_name = 'conc_cost_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_cost_SEQ
        goto exit1
	 end
     if @key_name = 'conc_del_term_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_del_term_SEQ
        goto exit1
	 end
     if @key_name = 'conc_delivery_item_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_delivery_item_SEQ
        goto exit1
	 end
     if @key_name = 'conc_delivery_schedule_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_delivery_schedule_SEQ
        goto exit1
	 end
     if @key_name = 'conc_document_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_document_SEQ
        goto exit1
	 end
     if @key_name = 'conc_exec_assay_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_exec_assay_SEQ
        goto exit1
	 end
     if @key_name = 'conc_exec_weight_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_exec_weight_SEQ
        goto exit1
	 end
     if @key_name = 'conc_ref_cost_group_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_ref_cost_group_SEQ
        goto exit1
	 end
     if @key_name = 'conc_ref_cost_item_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_ref_cost_item_SEQ
        goto exit1
	 end
     if @key_name = 'conc_ref_document_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_ref_document_SEQ
        goto exit1
	 end
     if @key_name = 'conc_ref_result_type_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_ref_result_type_SEQ
        goto exit1
	 end
     if @key_name = 'conc_ref_trigger_event_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.conc_ref_trigger_event_SEQ
        goto exit1
	 end
     if @key_name = 'contract_amendable_field_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.contract_amendable_field_SEQ
        goto exit1
	 end
     if @key_name = 'contract_exec_detail_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.contract_exec_detail_SEQ
        goto exit1
	 end
     if @key_name = 'contract_execution_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.contract_execution_SEQ
        goto exit1
	 end
     if @key_name = 'contract_pricing_formula_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.contract_pricing_formula_SEQ
        goto exit1
	 end
     if @key_name = 'data_file_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.data_file_SEQ
        goto exit1
	 end
     if @key_name = 'exec_logistics_details_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.exec_logistics_details_SEQ
        goto exit1
	 end
     if @key_name = 'exec_inv_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.exec_phys_inv_SEQ
        goto exit1
	 end
     if @key_name = 'external_formula_mapping_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.external_formula_mapping_SEQ
        goto exit1
	 end
     if @key_name = 'file_load_detail_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.file_load_detail_SEQ
        goto exit1
	 end
     if @key_name = 'file_load_iteration_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.file_load_iteration_SEQ
        goto exit1
	 end
     if @key_name = 'file_load_id'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.file_load_SEQ
        goto exit1
	 end
     if @key_name = 'fixed_price_content_basis_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.fixed_price_content_basis_SEQ
        goto exit1
	 end
     if @key_name = 'trigger_actual_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.formula_body_trigger_actual_SEQ
        goto exit1
	 end
     if @key_name = 'glfile_bh_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.glfile_bh_SEQ
        goto exit1
	 end
     if @key_name = 'glfile_fh_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.glfile_fh_SEQ
        goto exit1
	 end
     if @key_name = 'glfile_td_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.glfile_td_SEQ
        goto exit1
	 end
     if @key_name = 'glfile_th_num'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.glfile_th_SEQ
        goto exit1
	 end
     if @key_name = 'parser_version_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.parser_version_SEQ
        goto exit1
	 end
     if @key_name = 'pay_cont_range_def_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pay_cont_range_def_SEQ
        goto exit1
	 end
     if @key_name = 'pay_cont_range_value_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pay_cont_range_value_SEQ
        goto exit1
	 end
     if @key_name = 'pay_rule_fixprice_info_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pay_rule_fixprice_info_SEQ
        goto exit1
	 end
     if @key_name = 'penalty_rule_content_basis_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.penalty_rule_content_basis_SEQ
        goto exit1
	 end
     if @key_name = 'phys_inv_time_sheet_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.phys_inv_time_sheet_SEQ
        goto exit1
	 end
     if @key_name = 'pricing_rule_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.pricing_rule_SEQ
        goto exit1
	 end
     if @key_name = 'qp_option_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.qp_option_SEQ
        goto exit1
	 end
     if @key_name = 'qp_period_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.qp_period_SEQ
        goto exit1
	 end
     if @key_name = 'qp_pricing_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.qp_pricing_SEQ
        goto exit1
	 end
     if @key_name = 'rc_flat_benchmark_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.rc_flat_benchmark_SEQ
        goto exit1
	 end
     if @key_name = 'rc_rule_escalator_price_base_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.rc_rule_escalator_price_base_SEQ
        goto exit1
	 end
     if @key_name = 'strategy_execution_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.strategy_execution_SEQ
        goto exit1
	 end
     if @key_name = 'tc_flat_benchmark_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.tc_flat_benchmark_SEQ
        goto exit1
	 end
     if @key_name = 'tc_rule_escalator_price_base_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.tc_rule_escalator_price_base_SEQ
        goto exit1
	 end
     if @key_name = 'var_output_oid'
     begin
        set @next_seq_num = NEXT VALUE FOR dbo.var_output_SEQ
        goto exit1
	 end
	 
exit1:
	 commit tran
   end try
   begin catch
     set @errcode = ERROR_NUMBER()
     set @smsg = ERROR_MESSAGE()
     if @@trancount > 0
        rollback tran
     RAISERROR('=> Failed to obtain the next sequence number for the key ''%s'' due to the error below:', 0, 1, @key_name) with nowait
     RAISERROR('==> ERROR %d: %s', 0, 1, @errcode, @smsg) with nowait
     goto endofsp
   end catch

endofsp:
if @errcode > 0
begin
   set @next_seq_num = null
   return 1 
end
return 0 
GO
GRANT EXECUTE ON  [dbo].[usp_get_next_sequence_num] TO [admin_group]
GO
GRANT EXECUTE ON  [dbo].[usp_get_next_sequence_num] TO [next_usr]
GO
