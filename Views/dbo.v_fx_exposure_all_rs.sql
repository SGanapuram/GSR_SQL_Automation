SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE view [dbo].[v_fx_exposure_all_rs]
(
   oid,
   fx_exp_curr_oid,
   fx_trading_prd,
   fx_exposure_type,
   real_port_num,
   open_rate_amt,
   fixed_rate_amt,
   linked_rate_amt,
   trans_id,
   resp_trans_id,
   fx_exp_sub_type,
   status,
   custom_column1,
   custom_column2,
   custom_column3,
   custom_column4,
   trans_type,
   trans_user_init,
   tran_date,
   app_name,
   workstation_id,
   sequence
)
as
select
   maintb.oid,
   maintb.fx_exp_curr_oid,
   maintb.fx_trading_prd,
   maintb.fx_exposure_type,
   maintb.real_port_num,
   maintb.open_rate_amt,
   maintb.fixed_rate_amt,
   maintb.linked_rate_amt,
   maintb.trans_id,
   null,
   maintb.fx_exp_sub_type,
   maintb.status,
   maintb.custom_column1,
   maintb.custom_column2,
   maintb.custom_column3,
   maintb.custom_column4,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.fx_exposure maintb
        left outer join dbo.icts_transaction it
           on maintb.trans_id = it.trans_id
union
select
   audtb.oid,
   audtb.fx_exp_curr_oid,
   audtb.fx_trading_prd,
   audtb.fx_exposure_type,
   audtb.real_port_num,
   audtb.open_rate_amt,
   audtb.fixed_rate_amt,
   audtb.linked_rate_amt,
   audtb.trans_id,
   audtb.resp_trans_id,
   audtb.fx_exp_sub_type,
   audtb.status,
   audtb.custom_column1,
   audtb.custom_column2,
   audtb.custom_column3,
   audtb.custom_column4,
   it.type,
   it.user_init,
   it.tran_date,
   it.app_name,
   it.workstation_id,
   it.sequence
from dbo.aud_fx_exposure audtb
        left outer join dbo.icts_transaction it
           on audtb.trans_id = it.trans_id
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_all_rs] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_fx_exposure_all_rs] TO [next_usr]
GO
