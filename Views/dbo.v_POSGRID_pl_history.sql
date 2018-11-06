SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_POSGRID_pl_history]	
(
   pl_record_key,
   pl_owner_code,
   pl_asof_date,
   real_port_num,
   pl_owner_sub_code,
   pl_record_owner_key,
   pl_primary_owner_key1,
   pl_primary_owner_key2,
   pl_primary_owner_key3,
   pl_primary_owner_key4,
   pl_secondary_owner_key1,
   pl_secondary_owner_key2,
   pl_secondary_owner_key3,
   pl_type,
   pl_category_type,
   pl_realization_date,
   pl_cost_status_code,
   pl_cost_prin_addl_ind,
   pl_mkt_price,
   pl_amt,
   trans_id,
   currency_fx_rate,
   pl_record_qty,
   pl_record_qty_uom_code,
   pos_num	
)
as
select
   pl_record_key,
   pl_owner_code,
   pl_asof_date,
   real_port_num,
   pl_owner_sub_code,
   pl_record_owner_key,
   pl_primary_owner_key1,
   pl_primary_owner_key2,
   pl_primary_owner_key3,
   pl_primary_owner_key4,
   pl_secondary_owner_key1,
   pl_secondary_owner_key2,
   pl_secondary_owner_key3,
   pl_type,
   pl_category_type,
   pl_realization_date,
   pl_cost_status_code,
   pl_cost_prin_addl_ind,
   pl_mkt_price,
   pl_amt,
   trans_id,
   currency_fx_rate,
   pl_record_qty,
   pl_record_qty_uom_code,
   pos_num	
from dbo.pl_history plhist with (nolock)
where pl_asof_date >  (select isnull(max(pl_asof_date), '01/01/1900')
                       from dbo.POSGRID_pl_history_yearend with (nolock))
union
select
   pl_record_key,
   pl_owner_code,
   pl_asof_date,
   real_port_num,
   pl_owner_sub_code,
   pl_record_owner_key,
   pl_primary_owner_key1,
   pl_primary_owner_key2,
   pl_primary_owner_key3,
   pl_primary_owner_key4,
   pl_secondary_owner_key1,
   pl_secondary_owner_key2,
   pl_secondary_owner_key3,
   pl_type,
   pl_category_type,
   pl_realization_date,
   pl_cost_status_code,
   pl_cost_prin_addl_ind,
   pl_mkt_price,
   pl_amt,
   trans_id,
   currency_fx_rate,
   pl_record_qty,
   pl_record_qty_uom_code,
   pos_num	
from dbo.POSGRID_pl_history_yearend with (nolock)
-- where pl_asof_date in ('12/30/2011', '12/31/2012')
GO
GRANT SELECT ON  [dbo].[v_POSGRID_pl_history] TO [next_usr]
GO
