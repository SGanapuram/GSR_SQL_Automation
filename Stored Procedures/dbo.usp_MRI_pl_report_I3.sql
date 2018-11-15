SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[usp_MRI_pl_report_I3]
(    
    @oid int,    
	@parcel_execution_ind char(1) = 'P',
    @rounding_decimals int = 2    
)    
AS    
set nocount on

declare @plAsofDate as varchar(17)  

if isnull(@parcel_execution_ind, 'P') = 'P' 
  begin
    select @plAsofDate = convert(varchar(17), isnull(max(pl_asof_date), getdate()), 106) from pl_history   
    where real_port_num in (select real_port_num from strategy_execution where oid=@oid)
  end
else
  begin
    select @plAsofDate = convert(varchar(17), isnull(max(pl_asof_date), getdate()), 106) from pl_history   
    where real_port_num in (select real_port_num from contract_execution where oid=@oid)
  end


create table #finalOutput
( contract_num int,
  parcel_num int,
  exec_num int,
  p_s_ind char(1),
  psSignFactor int,
  cost_num int,
  element_mineral varchar(20),
  moisture_pcnt float,
  franchise_pcnt float,
  wmt_qty float,
  dmt_qty float,
  ndmt_qty float,
  assay_value float,
  pay_penalty_ind varchar(3),
  payable_content float,
  pay_content_unit varchar(20),
  pay_qty float,
  pay_qty_unit varchar(5),
  price float,
  price_unit varchar(20),
  price_date varchar(20),
  payable_amt float,
  payable_price_basis varchar(20),
  fixed_price_esc float,
  tc_flat float,
  tc_benchmark float,
  tc_escalator float,
  tc_total float,
    tc_basis varchar(20),
  tc_value float,
  rc_flat float,
  rc_benchmark float,
  rc_escalator float,
  rc_total float,
  rc_basis varchar(20),
    rc_value float,
    penalty_charge float,
    penalty_basis varchar(20),
  penalty_value float,
  deductions_value float,
  net_payable_value float,
  curr_code varchar(10),
  pass_date varchar(17)
  )


--- get the specs based on pricing rules
if isnull(@parcel_execution_ind, 'P') = 'P' 
  begin
		insert into #finalOutput (contract_num, parcel_num, exec_num, p_s_ind, psSignFactor, cost_num,element_mineral, wmt_qty, 
				   pay_penalty_ind,payable_content, pay_qty, curr_code, pass_date)	
		select distinct ce.conc_contract_oid,
			se.strategy_id,
			se.exec_id,
			ce.exec_purch_sale_ind,
			case ce.exec_purch_sale_ind
				when 'P'
					then - 1
				else 1
				end,
			co.cost_num,
			prule.spec_code,
			co.cost_qty,
			case isnull(cspec.prim_paydeduct_ind, 'O')
				when 'P'
					then 'PAY'
				else 'PEN'
				end,
			0.0, -- initialize payable_content to 0.0
			0.0, -- initialize pay_qty to 0.0
			'USD',
			convert(varchar(20), cast(@plAsofDate as datetime), 106)
		from strategy_execution_detail se
		inner join contract_execution ce
			on ce.oid = se.exec_id
		inner join exec_phys_inv inv
			on inv.contract_execution_oid = se.exec_id
		inner join cost co
			on co.cost_owner_key1 = inv.exec_inv_num
		inner join cost_price_detail cpd
			on cpd.cost_num = co.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
		inner join commodity_specification cspec
			on cspec.spec_code = prule.spec_code
				and cspec.cmdty_code = co.cost_code
		where co.cost_type_code = 'PIP'
			and cost_owner_code = 'EI'
			and se.strategy_id = @oid


--- add fixed price row
		insert into #finalOutput (contract_num, parcel_num, exec_num, p_s_ind, psSignFactor, cost_num,element_mineral, wmt_qty, 
				   pay_penalty_ind,payable_content, pay_qty, price,price_unit, payable_price_basis, curr_code, pass_date)	
		SELECT     
		  ce.conc_contract_oid, 
		  se.strategy_id ,    
		  se.exec_id ,  
		  ce.exec_purch_sale_ind ,
		   case ce.exec_purch_sale_ind when 'P' then -1 else 1 end,
		  co.cost_num ,    
		  'Fixed Price' as element_mineral ,
		  co.cost_qty,
		  '' as pay_pen , -- pay/pen,
		  0.0, -- initialize payable_content to 0.0
		  0.0, -- initialize pay_qty to 0.0
			cc.contract_fixed_price AS 'Price',    
		  LTRIM(RTRIM(isnull(cc.contract_fixed_curr_code,'USD'))) +
		   (case isnull(cc.contract_fixed_price_uom,'NULL') when 'NULL' then 'MT'
				else '/' + LTRIM(RTRIM(cc.contract_fixed_price_uom)) end) AS 'Price Unit', 
			(case isnull(cc.contract_fixed_price_uom,'NULL') when 'NULL' then 'MT'
				else LTRIM(RTRIM(cc.contract_fixed_price_uom)) end), 
		  
		  'USD' ,
		   convert(varchar(20), cast(@plAsofDate as datetime), 106)
		  FROM strategy_execution_detail se
		  INNER JOIN contract_execution ce ON ce.oid=se.exec_id
		  INNER JOIN conc_contract cc ON ce.conc_contract_oid = cc.oid
		  INNER JOIN exec_phys_inv inv ON inv.contract_execution_oid=se.exec_id
		  INNER JOIN cost co ON co.cost_owner_key1=inv.exec_inv_num
		WHERE co.cost_type_code = 'PIP'    
		AND cost_owner_code = 'EI'    
		AND se.strategy_id = @oid    
		AND cc.fixed_price_ind = 'Y'    
		AND contract_fixed_price IS NOT NULL  
	end
else
	begin
		insert into #finalOutput (contract_num, parcel_num, exec_num, p_s_ind, psSignFactor, cost_num,element_mineral, wmt_qty, 
				   pay_penalty_ind,payable_content, pay_qty, curr_code, pass_date)	
				select distinct ce.conc_contract_oid,
			0,
			ce.oid,
			ce.exec_purch_sale_ind,
			case ce.exec_purch_sale_ind
				when 'P'
					then - 1
				else 1
				end,
			co.cost_num,
			prule.spec_code,
			co.cost_qty,
			case isnull(cspec.prim_paydeduct_ind, 'O')
				when 'P'
					then 'PAY'
				else 'PEN'
				end,
			0.0, -- initialize payable_content to 0.0
			0.0, -- initialize pay_qty to 0.0
			'USD',
			convert(varchar(20), cast(@plAsofDate as datetime), 106)
		from contract_execution ce
		inner join exec_phys_inv inv
			on inv.contract_execution_oid = ce.oid
		inner join cost co
			on co.cost_owner_key1 = inv.exec_inv_num
		inner join cost_price_detail cpd
			on cpd.cost_num = co.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
		inner join commodity_specification cspec
			on cspec.spec_code = prule.spec_code
				and cspec.cmdty_code = co.cost_code
		where co.cost_type_code = 'PIP'
			and cost_owner_code = 'EI'
			and ce.oid = @oid


		--- add fixed price row
		insert into #finalOutput (contract_num, parcel_num, exec_num, p_s_ind, psSignFactor, cost_num,element_mineral, wmt_qty, 
				   pay_penalty_ind,payable_content, pay_qty, price,price_unit, payable_price_basis, curr_code, pass_date)	
		SELECT     
		  ce.conc_contract_oid,
		  0 ,    
		  ce.oid ,  
		  ce.exec_purch_sale_ind ,
		   case ce.exec_purch_sale_ind when 'P' then -1 else 1 end,
		  co.cost_num ,    
		  'Fixed Price' as element_mineral ,
		  co.cost_qty,
		  '' as pay_pen , -- pay/pen,
		  0.0, -- initialize payable_content to 0.0
		  0.0, -- initialize pay_qty to 0.0
			cc.contract_fixed_price AS 'Price',    
		  LTRIM(RTRIM(isnull(cc.contract_fixed_curr_code,'USD'))) +
		   (case isnull(cc.contract_fixed_price_uom,'NULL') when 'NULL' then 'MT'
				else '/' + LTRIM(RTRIM(cc.contract_fixed_price_uom)) end) , 
		   (case isnull(cc.contract_fixed_price_uom,'NULL') when 'NULL' then 'MT'
				else  LTRIM(RTRIM(cc.contract_fixed_price_uom)) end) , 		  
		  'USD' ,
		   convert(varchar(20), cast(@plAsofDate as datetime), 106)
		  FROM contract_execution ce 
		  INNER JOIN conc_contract cc ON ce.conc_contract_oid = cc.oid
		  INNER JOIN exec_phys_inv inv ON inv.contract_execution_oid=ce.oid
		  INNER JOIN cost co ON co.cost_owner_key1=inv.exec_inv_num
		WHERE co.cost_type_code = 'PIP'    
		AND cost_owner_code = 'EI'    
		AND ce.oid = @oid    
		AND cc.fixed_price_ind = 'Y'    
		AND contract_fixed_price IS NOT NULL  
	end
	
-- set the fixedprice basis
	update #finalOutput
	set payable_price_basis = (
			case isnull(cc.contract_fixed_price_uom, 'NULL')
				when 'NULL'
					then 'MT'
				else LTRIM(RTRIM(cc.contract_fixed_price_uom))
				end
			)
	from #finalOutput fo
	inner join conc_contract cc
		on cc.oid = fo.contract_num

--- update assay value
	update #finalOutput
	set assay_value = isnull(cs.spec_val, 0.0)
	from #finalOutput fo
	inner join cost_specification cs
		on cs.spec_code = fo.element_mineral
			and cs.cost_num = fo.cost_num

--- update moisture and dmt
	update #finalOutput
	set moisture_pcnt = cs.spec_val,
		dmt_qty = isnull(wmt_qty, 0) * (100. - isnull(cs.spec_val, 0)) / 100.
	from cost_specification cs
	inner join #finalOutput fo
		on cs.cost_num = fo.cost_num
	where cs.spec_code = 'MOISTURE'

--- update franchise and ndmt
	update #finalOutput
	set franchise_pcnt = cs.spec_val,
		ndmt_qty = isnull(dmt_qty, 0) * (100. - isnull(cs.spec_val, 0)) / 100.
	from cost_specification cs
	inner join #finalOutput fo
		on cs.cost_num = fo.cost_num
	where cs.spec_code = 'FRANCHIS'


 -- update payable content
	update #finalOutput
	set payable_content = isnull(fbi.price_pcnt_value, 0) / isnull(spec.spec_uom_ratio_factor * 100., 1),
		pay_content_unit = isnull(rtrim(prule.spec_uom_code), '') + case isnull(prule.per_spec_uom_code, 'NULL')
			when 'NULL'
				then ''
			else '/' + prule.per_spec_uom_code
			end
	from #finalOutput fo
	inner join cost_price_detail cpd
		on cpd.cost_num = fo.cost_num
	inner join fb_modular_info fbi
		on cpd.formula_num = fbi.formula_num
			and cpd.formula_body_num = fbi.formula_body_num
	inner join pricing_rule prule
		on prule.oid = fbi.price_rule_oid
			and fo.element_mineral = prule.spec_code
	inner join specification spec
		on spec.spec_code = prule.spec_code
	where prule.rule_type_ind = 'P'
		and fbi.price_quote_string like '%Quote(%'

  
 -- update pay_content_unit
	update #finalOutput
	set pay_content_unit = isnull(rtrim(spec.spec_val_uom_code), '%') + case isnull(spec.per_spec_val_uom_code, 'NULL')
			when 'NULL'
				then ''
			else '/' + spec.per_spec_val_uom_code
			end
	from #finalOutput fo
	inner join specification spec
		on spec.spec_code = fo.element_mineral


 --- update pay qty and unit
	update #finalOutput
	set pay_qty = payable_content * ndmt_qty / 100.,
		pay_qty_unit = 'MT'
	from #finalOutput fo
	inner join specification spec
		on spec.spec_code = fo.element_mineral
	where spec.spec_val_uom_code is null
		and payable_content != 0

	update #finalOutput
	set pay_qty = payable_content * ndmt_qty / 31.1035,
		pay_qty_unit = 'TROZ'
	where pay_content_unit like 'GM%'
		and payable_content != 0

   
-- update pay price and unit
	update #finalOutput
	set price = unit_price * 100 / isnull(price_pcnt_val + 0.000000001, 1),
		price_unit = isnull(rtrim(cpd.price_curr_code), 'USD') + case isnull(cpd.price_uom_code, 'NULL')
			when 'NULL'
				then 'MT'
			else '/' + RTRIM(cpd.price_uom_code)
			end
	from #finalOutput fo
	inner join cost_price_detail cpd
		on cpd.cost_num = fo.cost_num
	inner join fb_modular_info fbi
		on fbi.formula_num = cpd.formula_num
			and fbi.formula_body_num = cpd.formula_body_num
	inner join pricing_rule prule
		on prule.oid = fbi.price_rule_oid
			and prule.spec_code = fo.element_mineral
	where prule.rule_type_ind = 'P'
		and fbi.price_quote_string like '%Quote(%'


--- set price datetime
	update #finalOutput set price_date =
	case substring(qpp.real_trading_prd,5,2) when '01' then 'Jan' when '02' then 'Feb' when '03' then 'Mar' when '04' then 'Apr' 
	when '05' then 'May' when '06' then 'Jun' when '07' then 'Jul' when '08' then 'Aug' when '09' then 'Sep' when '10' then 'Oct'
	when '11' then 'Nov' when '12' then 'Dec' end + '-' + substring (qpp.real_trading_prd,3,2)
	from #finalOutput fo
	inner join cost_price_detail cpd
		on cpd.cost_num = fo.cost_num
	inner join fb_modular_info fbi
		on fbi.formula_num = cpd.formula_num
			and fbi.formula_body_num = cpd.formula_body_num
	inner join pricing_rule prule
		on prule.oid = fbi.price_rule_oid
			and prule.spec_code = fo.element_mineral
	inner join quote_pricing_period qpp
		on qpp.formula_num = cpd.formula_num
			and qpp.formula_body_num = cpd.formula_body_num
	where prule.rule_type_ind = 'P'
		and fbi.price_quote_string like '%Quote(%'


-- set payable amount

	update #finalOutput
	set payable_amt = sumpay.payAmt
	from #finalOutput fo
	inner join (
		select fo.cost_num,
			prule.spec_code,
			sum(cpd.fb_value * fo.ndmt_qty) as payAmt
		from #finalOutput fo
		inner join cost_price_detail cpd
			on fo.cost_num = cpd.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
				and prule.spec_code = fo.element_mineral
		where prule.rule_type_ind = 'P'
		group by fo.cost_num,
			prule.spec_code
		) sumpay
		on fo.element_mineral = sumpay.spec_code
			and fo.cost_num = sumpay.cost_num

    
  -- update fixed price payable amount
	update #finalOutput
	set payable_amt = isnull(price, 0) * (
			case isnull(payable_price_basis, 'MT')
				when 'MT'
					then isnull(ndmt_qty, 0)
				when 'WMT'
					then isnull(wmt_qty, 0)
				when 'DMT'
					then isnull(dmt_qty, 0)
				end
			)
	where element_mineral = 'Fixed Price'

   

 -- update fixed price escalators
	 update #finalOutput
	set fixed_price_esc = (
			fpesc.unitPrice - isnull(cc.contract_fixed_price, 0) * (
				case isnull(payable_price_basis, 'MT')
					when 'MT'
						then 1
					when 'DMT'
						then 1. / (1 - franchise_pcnt / 100.)
					when 'WMT'
						then 1. / ((1. - moisture_pcnt / 100.) * (1. - franchise_pcnt / 100.))
					end
				)
			) * ndmt_qty
	from #finalOutput fo
	inner join (
		select cpd.cost_num,
			prule.spec_code as recSpecCode,
			prule.price_basis,
			sum(isnull(cpd.unit_price, 0)) as unitPrice
		from #finalOutput fo
		inner join cost_price_detail cpd
			on fo.cost_num = cpd.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
				and prule.spec_code = fo.element_mineral
		where prule.rule_type_ind in ('F')
		group by cpd.cost_num,
			prule.spec_code,
			prule.price_basis
		) fpesc
		on fo.element_mineral = fpesc.recSpecCode
			and fo.cost_num = fpesc.cost_num
	inner join conc_contract cc
		on cc.oid = fo.contract_num
	where isnull(cc.fixed_price_ind, 'N') = 'Y'
		and cc.contract_fixed_price is not null

 
 -- set TC
 -- update tc_basis
	update #finalOutput
	set tc_basis = tcpay.price_basis
	from #finalOutput fo
	inner join (
		select cpd.cost_num,
			prule.oid,
			prule.spec_code,
			prule.price_basis,
			rule_type_ind
		from #finalOutput fo
		inner join cost_price_detail cpd
			on fo.cost_num = cpd.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
				and prule.spec_code = fo.element_mineral
		where prule.rule_type_ind in ( 'TC', 'TF' )
		) tcpay
		on fo.element_mineral = tcpay.spec_code and tcpay.cost_num = fo.cost_num

 
 --update #finalOutput set tc_flat=tcFlat*tcpay.price_basis_factor, tc_benchmark=tcBenchmark*tcpay.price_basis_factor,
	update #finalOutput
	set tc_flat = signFactor * tcFlat,
		tc_benchmark = signFactor * tcBenchmark
	--select tcpay.spec_code, tcpay.price_basis, tc_flat*price_basis_factor , tc_benchmark*price_basis_factor 
	from #finalOutput fo
	inner join (
		select cpd.cost_num, prule.oid, prule.spec_code, prule.price_basis, rule_type_ind, cpd.unit_price, cpd.fb_value, tcb.tc_value,
			case isnull(price_basis, 'MT')
				when 'MT' then (1.0 - moisture_pcnt / 100.0) * (1.0 - franchise_pcnt / 100.)
				when 'DMT' then (1.0 - franchise_pcnt / 100.0)
				when 'WMT' then 1.0
				end as price_basis_factor,
			((cpd.unit_price + .00000001) / abs(cpd.unit_price + .00000001)) as signFactor,
			isnull(tcb.flat_amt, 0) * isnull(tcb.flat_percentage, 0) / 100. as tcFlat,
			(case isnull(tcb.app_to_benchmark, 'D')
					when 'D' then - 1. else 1.
					end) * isnull(tcb.benchmark_value, 0) * isnull(tcb.benchmark_percentage, 0) / 100.0 as tcBenchmark
		from #finalOutput fo
		inner join cost_price_detail cpd on fo.cost_num = cpd.cost_num
		inner join fb_modular_info fbi on fbi.formula_num = cpd.formula_num and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule on prule.oid = fbi.price_rule_oid and prule.spec_code = fo.element_mineral
		inner join tc_flat_benchmark tcb on tcb.price_rule_oid = prule.oid --and abs(abs(isnull(cpd.fb_value,0))-abs(isnull(tcb.tc_value,0)))<0.00001
		where prule.rule_type_ind in ( 'TC', 'TF' )
		) tcpay on fo.element_mineral = tcpay.spec_code and fo.cost_num=tcpay.cost_num


 -- set TC- escalators
	update #finalOutput
	set tc_escalator = (tcesc.unitPrice) * (
			case isnull(tc_basis, 'MT')
				when 'WMT'
					then (1 - moisture_pcnt / 100.0) * (1 - franchise_pcnt / 100.)
				when 'DMT'
					then (1 - moisture_pcnt / 100.0)
				when 'MT'
					then 1.0
				end
			)
	from #finalOutput fo
	inner join (
		select cpd.cost_num,
			parentRule.spec_code as parentSpecCode,
			prule.spec_code as recSpecCode,
			prule.price_basis,
			sum(isnull(cpd.unit_price, 0)) as unitPrice
		from #finalOutput fo
		inner join cost_price_detail cpd
			on fo.cost_num = cpd.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
		inner join pricing_rule parentRule
			on parentRule.oid = prule.parent_pricing_rule_oid
				and parentRule.spec_code = fo.element_mineral
		where prule.rule_type_ind in ( 'TEP', 'TEC' )
		group by cpd.cost_num, parentRule.spec_code, prule.spec_code, prule.price_basis
		) tcesc
		on fo.element_mineral = tcesc.parentSpecCode and fo.cost_num = tcesc.cost_num

 
 -- set tc amount
	update #finalOutput
	set tc_total = isnull(tc_flat, 0) + isnull(tc_benchmark, 0) + isnull(tc_escalator, 0),
		tc_value = isnull(tcSum.tcAmt, 0) * (
			case tc_basis
				when 'WMT' then isnull(wmt_qty, 0.000000001) + 0.000000000001
				when 'DMT' then isnull(dmt_qty, 0.00000000001) + 0.0000000001
				when 'MT' then isnull(ndmt_qty, 0.000000001) + 0.000000000001
				when 'NDMT' then isnull(ndmt_qty, 0.000000001) + 0.000000000001
				end
			)
	from #finalOutput fo
	inner join cost co
		on fo.cost_num = co.cost_num
	inner join (
		select co.cost_num,
			prule.spec_code,
			sum(cpd.unit_price) as tcAmt
		from #finalOutput fo1
		inner join cost co
			on co.cost_num = fo1.cost_num
		inner join cost_price_detail cpd
			on co.cost_num = cpd.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
				and prule.spec_code = fo1.element_mineral
		where prule.rule_type_ind like 'T%'
		group by co.cost_num,
			prule.spec_code
		) tcSum
		on fo.element_mineral = tcSum.spec_code
			and fo.cost_num = tcSum.cost_num


-- set RC
	update #finalOutput
	set rc_flat = rcFlat,
		rc_benchmark = rcBenchmark,
		rc_basis = 'Payable ' + rcpay.price_basis
	--select tcpay.spec_code, tcpay.price_basis, tc_flat*price_basis_factor , tc_benchmark*price_basis_factor 
	from #finalOutput fo
	inner join (
		select cpd.cost_num, prule.oid, prule.spec_code, prule.price_basis, rule_type_ind, cpd.unit_price,
			cpd.fb_value, rcb.rc_value,
			isnull(rcb.flat_amt, 0) * isnull(rcb.flat_percentage, 0) / 100. * ((cpd.unit_price + .00000001) / abs(cpd.unit_price + .00000001)) as rcFlat,
			( case isnull(rcb.app_to_benchmark, 'D')
					when 'D' then - 1. else 1. end ) * isnull(rcb.benchmark_value, 0) * isnull(rcb.benchmark_percentage, 0) / 100.0 as rcBenchmark
		from #finalOutput fo
		inner join cost_price_detail cpd
			on fo.cost_num = cpd.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
				and prule.spec_code = fo.element_mineral
		inner join rc_flat_benchmark rcb
			on rcb.price_rule_oid = prule.oid --and abs(abs(cpd.fb_value)-abs(rcb.rc_value))<0.00001
		where prule.rule_type_ind in ( 'RC', 'RF' )
		) rcpay on fo.element_mineral = rcpay.spec_code and fo.cost_num=rcpay.cost_num



-- set RC- escalators
	update #finalOutput
	set rc_escalator = (
			case payable_content
				when 0 then 0
				else (rcesc.unitPrice) / (
						case isnull(price_basis, 'NULL') when 'LB' then 2204.62
							when 'TROZ' then 31103.5
							else 1 end ) -- conversion factor
					* (
						case isnull(pay_content_unit, '%')
							when '%' then 100. / isnull(payable_content, 1)
							when 'GM/MT' then 100. / (isnull(payable_content, 1) * 1000000.)
							else 1 end )
				end
			)
	from #finalOutput fo
	inner join (
		select cpd.cost_num, parentRule.spec_code as parentSpecCode, prule.spec_code as recSpecCode,
			prule.price_basis, sum(isnull(cpd.unit_price, 0)) as unitPrice
		from #finalOutput fo
		inner join cost_price_detail cpd
			on fo.cost_num = cpd.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
		inner join pricing_rule parentRule
			on parentRule.oid = prule.parent_pricing_rule_oid
				and parentRule.spec_code = fo.element_mineral
		where prule.rule_type_ind in ( 'REP', 'REC' )
		group by cpd.cost_num, parentRule.spec_code, prule.spec_code, prule.price_basis ) rcesc
		on fo.element_mineral = rcesc.parentSpecCode and fo.cost_num = rcesc.cost_num



 -- set rc amount
	update #finalOutput
	set rc_total = isnull(rc_flat, 0) + isnull(rc_benchmark, 0) + isnull(rc_escalator, 0),
		rc_value = isnull(rcSum.rcAmt, 0) * co.cost_qty * (1 - moisture_pcnt / 100.0) * (1 - franchise_pcnt / 100.)
	from #finalOutput fo
	inner join cost co
		on fo.cost_num = co.cost_num
	inner join (
		select co.cost_num,
			prule.spec_code,
			sum(cpd.unit_price) as rcAmt
		from #finalOutput fo1
		inner join cost co
			on co.cost_num = fo1.cost_num
		inner join cost_price_detail cpd
			on co.cost_num = cpd.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
				and prule.spec_code = fo1.element_mineral
		where prule.rule_type_ind like 'R%'
		group by co.cost_num,
			prule.spec_code
		) rcSum on fo.element_mineral = rcSum.spec_code and fo.cost_num = rcSum.cost_num


-- set penalty
	update #finalOutput
	set penalty_value = isnull(penaltySum.penaltyAmt, 0) * co.cost_qty * (1 - moisture_pcnt / 100.0) * (1 - franchise_pcnt / 100.),
		penalty_basis = (
			case isnull(penaltySum.price_basis, 'NULL')
				when 'MT' then 'NDMT'
				else penaltySum.price_basis
				end
			)
	from #finalOutput fo
	inner join cost co
		on fo.cost_num = co.cost_num
	inner join (
		select co.cost_num, prule.spec_code, prule.price_basis, cpd.unit_price as penaltyAmt
		from #finalOutput fo1
		inner join cost co
			on co.cost_num = fo1.cost_num
		inner join cost_price_detail cpd
			on co.cost_num = cpd.cost_num
		inner join fb_modular_info fbi
			on fbi.formula_num = cpd.formula_num
				and fbi.formula_body_num = cpd.formula_body_num
		inner join pricing_rule prule
			on prule.oid = fbi.price_rule_oid
		where prule.rule_type_ind like 'N'
		) penaltySum on fo.element_mineral = penaltySum.spec_code and fo.cost_num = penaltySum.cost_num


-- update penalty charge
	update #finalOutput
	set penalty_charge = penalty_value / (
			case penalty_basis
				when 'WMT'	then isnull(wmt_qty, 0.000000001) + 0.000000000001
				when 'DMT'	then isnull(dmt_qty, 0.00000000001) + 0.0000000001
				when 'MT'	then isnull(ndmt_qty, 0.000000001) + 0.000000000001
				when 'NDMT'	then isnull(ndmt_qty, 0.000000001) + 0.000000000001
				end
			)
	from #finalOutput


-- update deductions
 update #finalOutput
 set deductions_value = isnull(penalty_value, 0) + isnull(rc_value, 0) + isnull(tc_value, 0)

 
-- update net payable
  update #finalOutput 
  set net_payable_value = isnull(payable_amt,0) + isnull(deductions_value,0) + isnull(fixed_price_esc,0)


 if isnull(@parcel_execution_ind, 'P') = 'P' 
  begin
	select parcel_num as 'Parcel Num',
		exec_num as 'Execution Num',
		p_s_ind as 'Purch/Sale',
		cost_num as 'CostNum',
		element_mineral as 'Elements/Minerals',
		ROUND(isnull(wmt_qty, 0), @rounding_decimals) as 'Qty-WMT',
		ROUND(isnull(moisture_pcnt, 0), @rounding_decimals) as 'Moisture %',
		ROUND(isnull(dmt_qty, 0), @rounding_decimals) as 'Qty-DMT',
		ROUND(isnull(franchise_pcnt, 0), @rounding_decimals) as 'Franchise %',
		ROUND(isnull(ndmt_qty, 0), @rounding_decimals) as 'Qty-NDMT',
		ROUND(isnull(assay_value, 0), @rounding_decimals) as 'Assay Value',
		pay_penalty_ind as 'Assay Type',
		ROUND(isnull(payable_content, 0), @rounding_decimals) as 'Payable Content',
		pay_content_unit as 'Unit',
		ROUND(isnull(pay_qty, 0), @rounding_decimals) as 'Payable Qty',
		pay_qty_unit as 'Pay Qty Unit',
		ROUND(isnull(price, 0), @rounding_decimals) as 'Price',
		price_unit as 'Price Unit',
		price_date as 'Price Date',
		ROUND(isnull(psSignFactor * payable_amt, 0), @rounding_decimals) as 'Payable Amount',
		ROUND(isnull(psSignFactor * fixed_price_esc, 0), @rounding_decimals) as 'Fixed Price Escalators',
		ROUND(isnull(psSignFactor * tc_flat, 0), @rounding_decimals) as 'TC-Flat',
		ROUND(isnull(psSignFactor * tc_benchmark, 0), @rounding_decimals) as 'TC-Benchmark',
		ROUND(isnull(psSignFactor * tc_escalator, 0), @rounding_decimals) as 'TC-Escalator',
		ROUND(isnull(psSignFactor * tc_total, 0), @rounding_decimals) as 'TC-Total',
		tc_basis as 'TC-Basis',
		ROUND(isnull(psSignFactor * tc_value, 0), @rounding_decimals) as 'TC',
		ROUND(isnull(psSignFactor * rc_flat, 0), @rounding_decimals) as 'RC-Flat',
		ROUND(isnull(psSignFactor * rc_benchmark, 0), @rounding_decimals) as 'RC-Benchmark',
		ROUND(isnull(psSignFactor * rc_escalator, 0), 4) as 'RC-Escalator',
		ROUND(isnull(psSignFactor * rc_total, 0), 4) as 'RC-Total',
		rc_basis as 'RC-Basis',
		ROUND(isnull(psSignFactor * rc_value, 0), @rounding_decimals) as 'RC',
		ROUND(isnull(psSignFactor * penalty_charge, 0), @rounding_decimals) as 'Penalty Charge',
		penalty_basis as 'Penalty Basis',
		ROUND(isnull(psSignFactor * penalty_value, 0), @rounding_decimals) 'Penalty',
		ROUND(isnull(psSignFactor * deductions_value, 0), @rounding_decimals) as 'Deductions',
		ROUND(isnull(psSignFactor * net_payable_value, 0), @rounding_decimals) as 'Net Payable Value',
		curr_code as 'Currency',
		pass_date as 'PASS AsofDate'
	from #finalOutput
 end
  else
	begin
	  select exec_num as 'Execution Num',
		p_s_ind as 'Purch/Sale',
		cost_num as 'CostNum',
		element_mineral as 'Elements/Minerals',
		ROUND(isnull(wmt_qty, 0), @rounding_decimals) as 'Qty-WMT',
		ROUND(isnull(moisture_pcnt, 0), @rounding_decimals) as 'Moisture %',
		ROUND(isnull(dmt_qty, 0), @rounding_decimals) as 'Qty-DMT',
		ROUND(isnull(franchise_pcnt, 0), @rounding_decimals) as 'Franchise %',
		ROUND(isnull(ndmt_qty, 0), @rounding_decimals) as 'Qty-NDMT',
		ROUND(isnull(assay_value, 0), @rounding_decimals) as 'Assay Value',
		pay_penalty_ind as 'Assay Type',
		ROUND(isnull(payable_content, 0), @rounding_decimals) as 'Payable Content',
		pay_content_unit as 'Unit',
		ROUND(isnull(pay_qty, 0), @rounding_decimals) as 'Payable Qty',
		pay_qty_unit as 'Pay Qty Unit',
		ROUND(isnull(price, 0), @rounding_decimals) as 'Price',
		price_unit as 'Price Unit',
		price_date as 'Price Date',
		ROUND(isnull(psSignFactor * payable_amt, 0), @rounding_decimals) as 'Payable Amount',
		ROUND(isnull(psSignFactor * fixed_price_esc, 0), @rounding_decimals) as 'Fixed Price Escalators',
		ROUND(isnull(psSignFactor * tc_flat, 0), @rounding_decimals) as 'TC-Flat',
		ROUND(isnull(psSignFactor * tc_benchmark, 0), @rounding_decimals) as 'TC-Benchmark',
		ROUND(isnull(psSignFactor * tc_escalator, 0), @rounding_decimals) as 'TC-Escalator',
		ROUND(isnull(psSignFactor * tc_total, 0), @rounding_decimals) as 'TC-Total',
		tc_basis as 'TC-Basis',
		ROUND(isnull(psSignFactor * tc_value, 0), @rounding_decimals) as 'TC',
		ROUND(isnull(psSignFactor * rc_flat, 0), @rounding_decimals) as 'RC-Flat',
		ROUND(isnull(psSignFactor * rc_benchmark, 0), @rounding_decimals) as 'RC-Benchmark',
		ROUND(isnull(psSignFactor * rc_escalator, 0), 4) as 'RC-Escalator',
		ROUND(isnull(psSignFactor * rc_total, 0), 4) as 'RC-Total',
		rc_basis as 'RC-Basis',
		ROUND(isnull(psSignFactor * rc_value, 0), @rounding_decimals) as 'RC',
		ROUND(isnull(psSignFactor * penalty_charge, 0), @rounding_decimals) as 'Penalty Charge',
		penalty_basis as 'Penalty Basis',
		ROUND(isnull(psSignFactor * penalty_value, 0), @rounding_decimals) 'Penalty',
		ROUND(isnull(psSignFactor * deductions_value, 0), @rounding_decimals) as 'Deductions',
		ROUND(isnull(psSignFactor * net_payable_value, 0), @rounding_decimals) as 'Net Payable Value',
		curr_code as 'Currency',
		pass_date as 'PASS AsofDate'
	  from #finalOutput
end
GO
GRANT EXECUTE ON  [dbo].[usp_MRI_pl_report_I3] TO [next_usr]
GO
