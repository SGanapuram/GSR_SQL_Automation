SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_dump_fx_data]
(
   @debugon          bit = 0
)
as 
set nocount on
declare @smsg            varchar(255)
declare @status          int
declare @errcode         int


	 set @status = 0
	 set @errcode = 0

	 create table #active_fx_ids 
	 (
		  fx_exp_num	int
   )
	
	 begin try    
		 insert into #active_fx_ids
		 select fe.oid
		 from dbo.fx_exposure fe
		         join #children t1 
		            on fe.real_port_num = t1.port_num
		 where status != 'N'
	 end try
	 begin catch
		 print '=> Failed to get list of active fx oids due to the following error:'
		 print '==> ERROR: ' + ERROR_MESSAGE()
		 set @errcode = ERROR_NUMBER()
		 goto errexit
	 end catch

	 begin try    
		 insert into #fx_dump
		 select 
		    cast(trade_num as varchar) + '-' + cast(order_num as varchar) + '-' + cast(item_num as varchar),
				fe.oid,
				fe.real_port_num,
				case fx_exposure_type 
				   when 'P' then 'PRIMARY' 
					 when 'SW' then 'PRIMARY' --Swap should be in primary
					 when 'C' then 'FOREX'
					 when 'F' then 'FUT'
					 when 'PP' then 'PricingP'
					 when 'PR' then 'Premium'
					 when 'FD' then 'Premium'
					 when 'S' then 'OTHER'
					 else 'INVALID'
				end as type,
				case fx_exposure_type 
					 when 'P' then 'PRIMARY' 
					 when 'SW' then 'SWAP' --Swap should be in primary
					 when 'C' then 'FOREX'
					 when 'F' then 'FUT'
					 when 'PP' then 'PricingP'
					 when 'PR' then 'Premium'
					 when 'FD' then 'Premium'
					 when 'S' then 'OTHER'
					 else 'INVALID'
				end as type,
			  price_curr_code,
			  pl_curr_code,
			  fx_trading_prd,
			  null,
			  null,
			  null,
			  null,
			  null,
			  open_rate_amt,
			  isnull(fx_amt, 0) - isnull(fx_priced_amt, 0),
			  'FXEXPDIST',
			  fx_owner_key4,
			  trade_num,
			  order_num,
			  item_num
		 from dbo.fx_exposure fe
	       	   join #active_fx_ids t1 
	       	      on fe.oid = t1.fx_exp_num
		         join dbo.fx_exposure_dist fed 
		            on fed.fx_exp_num = fe.oid
		         join dbo.fx_exposure_currency fec 
		            on fec.oid = fx_exp_curr_oid
		 union all
		 select  
		    cast(cost_owner_key6 as varchar) + '-' + cast(cost_owner_key7 as varchar) + '-' + cast(cost_owner_key8 as varchar),
				fe.oid,
				fe.real_port_num,
				case fx_exposure_type 
					 when 'P' then 'PRIMARY' 
					 when 'SW' then 'PRIMARY' --Swap should be in primary
					 when 'C' then 'FOREX'
					 when 'F' then 'FUT'
					 when 'PP' then 'PricingP'
					 when 'PR' then 'Premium'
					 when 'FD' then 'Premium'
					 when 'S' then 'OTHER'
					 else 'INVALID'
				end as type,
				case fx_exposure_type 
					 when 'P' then 'PRIMARY' 
					 when 'SW' then 'SWAP' --Swap should be in primary
					 when 'C' then 'FOREX'
					 when 'F' then 'FUT'
					 when 'PP' then 'PricingP'
					 when 'PR' then 'Premium'
					 when 'FD' then 'Premium'
					 when 'S' then 'OTHER'
					 else 'INVALID'
				end as type,
			  price_curr_code,
			  pl_curr_code,
			  fx_trading_prd,
			  null,
			  null,
			  null,
			  null,
			  null,
			  open_rate_amt,
			  case cost_pay_rec_ind 
			     when 'P' then (isnull(cost_amt, 0) - isnull(cost_vouchered_amt, 0)) * -1 
			     else (isnull(cost_amt, 0) - isnull(cost_vouchered_amt, 0)) 
			  end,
			  'COST',
			  c.cost_num,
			  c.cost_owner_key6,
			  c.cost_owner_key7,
			  c.cost_owner_key8
		 from dbo.fx_exposure fe
		         join #active_fx_ids t1 
		            on fe.oid = t1.fx_exp_num
	       	   join dbo.cost_ext_info cei 
	       	      on cei.fx_exp_num = fe.oid
		         join dbo.cost c 
		            on cei.cost_num = c.cost_num  and 
	                       abs(c.cost_amt) >= 0.001 and 
	                       c.cost_status not in ('PAID','HELD','CLOSED') and 
	                       cost_type_code not in ('INVROLL')     
		         join dbo.fx_exposure_currency fec 
		            on fec.oid = fx_exp_curr_oid
	 end try
	 begin catch
		 print '=> Failed to get fx dump data from fx_exposure_dist, costs for the active fx_oids due to the following error:'
		 print '==> ERROR: ' + ERROR_MESSAGE()
		 set @errcode = ERROR_NUMBER()
		 goto errexit
	 end catch

   -- Delete premiums offset records where Costs doesn't have forex exposure
	 begin try    
		 delete t1
		 from #fx_dump t1
		 where fx_sub_type = 'PRIMARY' and 
		       fx_source = 'FXEXPDIST' and 
		       exists (select 1 
		               from dbo.cost_ext_info cei 
		               where t1.cost_num = cei.cost_num and 
		                     fx_exp_num is null)
	 end try
	 begin catch
		 print '=> Failed to delete premium offset records where costs dont have forex exposure due to the following error:'
		 print '==> ERROR: ' + ERROR_MESSAGE()
		 set @errcode = ERROR_NUMBER()
		 goto errexit
	 end catch

	 begin try    
		 update #fx_dump 
		 set year = 'SPOT',
		     exp_date = 'SPOT', 
		     quarter = 'SPOT',
		     month = 'SPOT',
		     day = 'SPOT' 
		 where trading_prd = 'SPOT'
	 end try
	 begin catch
		 print '=> Failed to set SPOT trading period due to the following error:'
		 print '==> ERROR: ' + ERROR_MESSAGE()
		 set @errcode = ERROR_NUMBER()
		 goto errexit
	 end catch

	 begin try    
		 update #fx_dump 
		 set exp_date = convert(varchar, convert(datetime, substring(trading_prd, 13, len(trading_prd) - 12) + ' ' + substring(trading_prd, 9, 3) + ' ' + substring(trading_prd, 1, 4), 106), 101),
	       year = substring(trading_prd, 1, 4),
         quarter = substring(trading_prd, 7, 1),
	       month = substring(trading_prd, 9, 3),
	       day = substring(trading_prd, 13, len(trading_prd) - 12) 
	   where trading_prd != 'SPOT'
	 end try
	 begin catch
	   print '=> Failed to derive exposure date, year, quarter,month and day from fx_exposure.trading_prd due to the following error:'
		 print '==> ERROR: ' + ERROR_MESSAGE()
		 set @errcode = ERROR_NUMBER()
		 goto errexit
	 end catch
	 goto endofsp

errexit:
   if @errcode > 0
      set @status = 1
   
endofsp:
if object_id('tempdb.dbo.#active_fx_ids') is not null
   exec('drop table #active_fx_ids')
return @status
GO
GRANT EXECUTE ON  [dbo].[usp_dump_fx_data] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_dump_fx_data', NULL, NULL
GO
