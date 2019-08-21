SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_TS_risk_cover]
(
   trade_num,
   order_num,
   item_num,
   rc_num,
   rc_multi_ind,
   rc_guarantee_bank,
   rc_guarantee_bank_shortname,  
   rc_guarantee_broker,
   rc_guarantee_broker_shortname,
   rc_exp_date,
   rc_amt_rcvble_covered,  
   rc_up_to_max_amount,  
   rc_disc_date,  
   rc_disc_rcvble_amt
)
as
select        
   rat.trade_num, 
   rat.order_num,
   rat.item_num,
   rc.risk_cover_num,
   case when v_rst.rc_multi_ind is null
           then 0
	      else 1
   end,
   case when rc.instr_type_code = 'RC_BANK'
           then rc.guarantee_acct_num
	      else null
   end,
   case when rc.instr_type_code = 'RC_BANK'
           then ac.acct_short_name
        else null
   end,
   case when rc.instr_type_code = 'RC_BROKER'
           then rc.guarantee_acct_num
        else null
   end,
   case when rc.instr_type_code = 'RC_BROKER'
           then ac.acct_short_name
        else null
   end,
   rc.guarantee_end_date,
   (rc.covered_percent * rat.cargo_value) / 100,
   rc.max_covered_amt,
   rc.disc_date,
   rc.disc_rec_amt
from dbo.risk_cover rc
        INNER JOIN dbo.rc_assign_trade rat with (nolock)
           ON rc.risk_cover_num = rat.risk_cover_num
        LEFT OUTER JOIN dbo.v_TS_rc_assign_trade v_rst
           ON rat.trade_num = v_rst.trade_num and
              rat.order_num = v_rst.order_num and
	            rat.item_num = v_rst.item_num
        LEFT OUTER JOIN dbo.account ac with (nolock)
           ON ac.acct_num = rc.guarantee_acct_num
GO
GRANT SELECT ON  [dbo].[v_TS_risk_cover] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_TS_risk_cover] TO [next_usr]
GO
