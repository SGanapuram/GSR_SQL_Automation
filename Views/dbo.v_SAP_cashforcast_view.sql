SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_SAP_cashforcast_view]  
(  
cost_book_comp_num,   
cost_book_curr_code,  
cost_book_prd_date,  
cost_amt,  
cost_code,  
cost_num,  
acct_num,   
creation_date,  
credit_term_code,  
cost_price_curr_code,  
cost_due_date,  
cost_eff_date,  
cost_gl_acct_cr_code,  
cost_gl_acct_dr_code,  
cost_owner_key7,  
cost_owner_key8,  
cost_type_code,  
cost_pay_rec_ind,  
cost_pay_days,  
pay_term_code,  
pay_method_code,  
port_num,  
cost_unit_price,  
cost_price_est_actual_ind,  
cost_prim_sec_ind,  
cost_qty_uom_code,  
cost_qty,  
cost_status,  
cost_owner_key6,  
cost_book_exch_rate,  
cost_xrate_conv_ind,  
brkr_ref_num,  
contract_number,  
alloc_num,  
eta_date,  
port_full_name  
)  
as  
select   
cost_book_comp_num,  
cost_book_curr_code,  
cost_book_prd_date,  
cost_amt,  
cost_code,  
cost_num,  
acct_num,  
c.creation_date,  
credit_term_code,  
isnull(cmdty_alias_name, cost_price_curr_code) ,  
cost_due_date,  
cost_eff_date,  
cost_gl_acct_cr_code,  
cost_gl_acct_dr_code,  
cost_owner_key7,  
cost_owner_key8,  
cost_type_code,  
cost_pay_rec_ind,  
cost_pay_days,  
pay_term_code,  
pay_method_code,  
real_port_num,  
cost_unit_price,  
cost_price_est_actual_ind,  
cost_prim_sec_ind,  
cost_qty_uom_code,  
cost_qty,  
cost_status,  
cost_owner_key6,  
cost_book_exch_rate,  
cost_xrate_conv_ind,  
ti.brkr_ref_num,  
ti.trade_num 'Contract Number',  
cost_owner_key1,  
cost_due_date,  
j.port_full_name  
from cost c  with (NOLOCK) 
left outer join commodity_alias ca1  with (NOLOCK) ON ca1.alias_source_code='ISO' and ca1.cmdty_code=c.cost_price_curr_code  
left outer join trade_item ti  with (NOLOCK) on   
  c.cost_owner_key6=ti.trade_num   
  and c.cost_owner_key7=ti.order_num   
  and c.cost_owner_key8=ti.item_num  
, portfolio j   with (NOLOCK) 
where c.port_num=j.port_num  
and cost_status='OPEN'  
and cost_type_code not in ('CPP','CPR','SWAP')  
and (cost_amt>10000 OR cost_amt<-10000 )  
and credit_term_code <>'FULLPREP'  
and acct_num not in (select acct_num from account_alias where alias_source_code='INTERCOS')  
and c.cost_due_date >=getdate() and c.cost_due_date<dateadd(dd,15,getdate() )  
and cost_book_comp_num in (511,3507,1405)  
GO
GRANT SELECT ON  [dbo].[v_SAP_cashforcast_view] TO [next_usr]
GO
