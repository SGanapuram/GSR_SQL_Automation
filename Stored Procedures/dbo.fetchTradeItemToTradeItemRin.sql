SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchTradeItemToTradeItemRin]
(
   @asof_trans_id      int,
   @item_num           smallint,
   @order_num          smallint,
   @trade_num          int
)
as
set nocount on
 
   select asof_trans_id = @asof_trans_id,
          committed_sqty,
          counterparty_qty,
          epa_exp_qty,
          epa_imp_prod_qty,
          impact_begin_year,
          impact_current_year,
          item_num,
          manual_commit_ind,
          manual_epa_ind,
          manual_rvo_ind,
          manual_settled_ind,
          mf_cmdty_code,
          order_num,
          py_rin_cmdty_code,
          resp_trans_id = NULL,
          rin_action_code,
          rin_cmdty_code,
          rin_impact_date,
          rin_impact_type,
          rin_p_s_ind,
          rin_pcent_year,
          rin_port_num,
          rin_qty_uom_code,
          rin_sep_status,
          rins_finalized,
          rvo_mf_qty,
          rvo_mf_qty_uom_code,
          settled_cur_y_sqty,
          settled_pre_y_sqty,
          trade_num,
          trans_id
   from dbo.trade_item_rin
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         trans_id <= @asof_trans_id
   union
   select asof_trans_id = @asof_trans_id,
          committed_sqty,
          counterparty_qty,
          epa_exp_qty,
          epa_imp_prod_qty,
          impact_begin_year,
          impact_current_year,
          item_num,
          manual_commit_ind,
          manual_epa_ind,
          manual_rvo_ind,
          manual_settled_ind,
          mf_cmdty_code,
          order_num,
          py_rin_cmdty_code,
          resp_trans_id,
          rin_action_code,
          rin_cmdty_code,
          rin_impact_date,
          rin_impact_type,
          rin_p_s_ind,
          rin_pcent_year,
          rin_port_num,
          rin_qty_uom_code,
          rin_sep_status,
          rins_finalized,
          rvo_mf_qty,
          rvo_mf_qty_uom_code,
          settled_cur_y_sqty,
          settled_pre_y_sqty,
          trade_num,
          trans_id
   from dbo.aud_trade_item_rin
   where trade_num = @trade_num and
         order_num = @order_num and
         item_num = @item_num and
         (trans_id <= @asof_trans_id and
          resp_trans_id > @asof_trans_id)
return
GO
GRANT EXECUTE ON  [dbo].[fetchTradeItemToTradeItemRin] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'fetchTradeItemToTradeItemRin', NULL, NULL
GO
