SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_exp_futures_locked_positions] 
(
   @inputPlAsofDate   datetime,
   @outputPlAsofDate  datetime
)
as
set nocount on
declare @inputRealPortNum	int,
	      @transId		      int,
	      @rows_affected		int

   if @inputPlAsofDate is null
   begin
      print 'Please provide value for @inputPlAsofDate parameter'
      goto endofsp
   end

   if @outputPlAsofDate is null
   begin
      print 'Please provide value for @outputPlAsofDate parameter'
      goto endofsp
   end

   create table #portInPlHistory
   (
	    portNum		    int,
	    isLocked	    int,
	    hasExpiredPos	int
   )

   create table #tempExpiredPos
   (
	    posNum		      int,
	    realPortNum     int,
	    lastTradeDate	  varchar(20),
	    longQty		      float,
	    shortQty	      float,
	    qtyUomCode	    varchar(4),
	    lastMtmPrice	  numeric(20,8),
	    commktLotUom    varchar(4),
	    commktPriceUom  varchar(4),
	    commktLotSize   float,
	    posFactor       float
   )

   create table #tempExpiredPLH 
   (
	    posNum		      int, 
	    plType		      char(1), 
    	plAmt		        float,
	    recordQty       float
   )

   set @inputPlAsofDate = @inputPlAsofDate
   set @outputPlAsofDate = @outputPlAsofDate
   set @rows_affected = 0

   begin try
	   insert into #portInPlHistory
	   select distinct real_port_num, port_locked, 0
	   from dbo.pl_history plh 
	           inner join dbo.portfolio p with (nolock)
	              on p.port_num = plh.real_port_num
	   where pl_asof_date = @inputPlAsofDate
	   set @rows_affected = @@rowcount
   end try
   begin catch
	   print '=> Failed to load portfolios into #portInPlHistory table'
	   print '==> ERROR: ' + ERROR_MESSAGE()
	   goto endofsp
   end catch

   set @rows_affected = 0

   begin try
	   update #portInPlHistory
	   set hasExpiredPos = 1
	   from #portInPlHistory 
	   where portNum in (select portNum 
	                     from #portInPlHistory pRun 
	                     where exists (select 1 
	                                   from dbo.position p 
	                                           inner join dbo.trading_period tprd with (nolock)
		                                            on p.commkt_key = tprd.commkt_key and 
		                                               p.trading_prd = tprd.trading_prd
			                               where pRun.portNum = p.real_port_num and 
			                                     pos_type = 'F' and 
			                                     DATEDIFF(DD, last_trade_date, @outputPlAsofDate) > 
			                                       (select CONVERT(int, attribute_value)
			                                        from dbo.constants with (nolock)
			                                        where attribute_name = 'PLasExpiredFutureAfterNumDays')) and 
			     pRun.isLocked = 1)
	   set @rows_affected = @@rowcount
   end try
   begin catch
     print '=> Failed to update #portInPlHistory.hasExpiredPos '
     print '==> ERROR: ' + ERROR_MESSAGE()
     goto endofsp
   end catch

   delete #portInPlHistory where isLocked = 0
   delete #portInPlHistory where hasExpiredPos = 0

   set @rows_affected = 0
   select @inputRealPortNum = min(portNum) 
   from #portInPlHistory

   while @inputRealPortNum is not null
   begin
      delete #tempExpiredPos
      delete #tempExpiredPLH

	    print ''
	    print '@inputRealPortNum = ' + convert(varchar, @inputRealPortNum)
	    print ''

      set @rows_affected = 0

      ---- find expired, locked positions for a realPort
      begin try
	      insert into #tempExpiredPos
	      select pos_num, 
	             p.real_port_num,
	             CONVERT(varchar(20),last_trade_date, 101), 
	             long_qty, 
	             short_qty, 
	             qty_uom_code, 
	             last_mtm_price,
	             cfAttr.commkt_lot_uom_code, 
	             cfAttr.commkt_price_uom_code, 
	             cfAttr.commkt_lot_size, 1.0
	      from dbo.position p 
	              inner join dbo.trading_period tprd with (nolock) 
	                 on p.commkt_key = tprd.commkt_key and 
	                    p.trading_prd = tprd.trading_prd
	              inner join dbo.portfolio port with (nolock) 
	                 on port.port_num = p.real_port_num
	              inner join dbo.commkt_future_attr cfAttr with (nolock)
	                 on cfAttr.commkt_key = p.commkt_key
	      where real_port_num = @inputRealPortNum and 
	            pos_type = 'F' and 
	            DATEDIFF(DD, last_trade_date, @outputPlAsofDate) > 
	               (select CONVERT(int, attribute_value)
	                from dbo.constants with (nolock)
	                where attribute_name = 'PLasExpiredFutureAfterNumDays') and 
	            port.port_locked = 1
	      set @rows_affected = @@rowcount
      end try
      begin catch
	      print '=> Failed to insert records into #tempExpiredPos table with port_locked = 1'
	      print '==> ERROR: ' + ERROR_MESSAGE()
	      goto endofsp
      end catch

      set @rows_affected = 0

      -- if the position is in lots, update posFactor to lotsize
      update #tempExpiredPos 
      set posFactor = commktLotSize 
      where qtyUomCode = 'LOTS'

      -- update mtm Price for positions where curr of the position and desiredPlCurr match
      begin try
	      update #tempExpiredPos 
	      set lastMtmPrice = pr.avg_closed_price
	      from #tempExpiredPos texpPos
	              inner join dbo.position p 
	                 on texpPos.posNum = p.pos_num
	              inner join dbo.commodity_market cmkt with (nolock)
	                 on p.commkt_key = cmkt.commkt_key
	              inner join dbo.commkt_future_attr cfAttr with (nolock) 
	                 on cfAttr.commkt_key = p.commkt_key
	              inner join dbo.portfolio port with (nolock) 
	                 on port.port_num = p.real_port_num
	              inner join dbo.trading_period tprd with (nolock) 
	                 on tprd.commkt_key = p.commkt_key and 
	                    tprd.trading_prd = p.trading_prd
              	inner join dbo.price pr 
              	   on pr.commkt_key = p.commkt_key and 
              	      pr.trading_prd = p.trading_prd and 
                      pr.price_source_code = cmkt.mtm_price_source_code and 
                      pr.price_quote_date = tprd.last_trade_date
	      where cfAttr.commkt_curr_code = port.desired_pl_curr_code
	      set @rows_affected = @@rowcount
      end try
      begin catch
	      print '=> Failed to update #tempExpiredPos.lastMtmPrice entries'
	      print '==> ERROR: ' + ERROR_MESSAGE()
	      goto endofsp
      end catch

      set @rows_affected = 0

      -- write the costs
      begin try
	      insert into #tempExpiredPLH
	      select pos_num, 'L', SUM(pl_amt), 0
	      from dbo.pl_history plh 
	              inner join #tempExpiredPos tpos 
	                 on plh.pos_num = tpos.posNum
	      where plh.pl_asof_date = @inputPlAsofDate and 
	            plh.real_port_num = @inputRealPortNum and 
	            plh.pl_owner_code = 'C' 
	      group by plh.pos_num
	      set @rows_affected = @@rowcount
      end try
      begin catch
	      print '=> Failed to insert records into #tempExpiredPLH for pl type L'
	      print '==> ERROR: ' + ERROR_MESSAGE()
	      goto endofsp
      end catch

      set @rows_affected = 0

      -- for new EF, R
      begin try
	      insert into #tempExpiredPLH
	      select plh.pos_num, 'R', SUM(pl_amt), 0
	      from dbo.pl_history plh 
	              inner join #tempExpiredPos tpos 
	                 on plh.pos_num = tpos.posNum
	      where plh.pl_asof_date = @inputPlAsofDate and 
	            plh.real_port_num = @inputRealPortNum and 
	            plh.pl_owner_code = 'T' and 
	            plh.pl_type in ('R') and 
	            pl_amt <= 0.0
	      group by plh.pos_num
	      set @rows_affected = @@rowcount
      end try
      begin catch
	      print '=> Failed to insert records into #tempExpiredPLH for pl type R'
	      print '==> ERROR: ' + ERROR_MESSAGE()
	      goto endofsp
      end catch

      set @rows_affected = 0

      -- for new EF, U
      begin try
	      insert into #tempExpiredPLH
	      select plh.pos_num, 'U', SUM(pl_amt), 0
	      from dbo.pl_history plh 
	              inner join #tempExpiredPos tpos 
	                 on plh.pos_num = tpos.posNum
	      where plh.pl_asof_date = @inputPlAsofDate and 
	            plh.real_port_num = @inputRealPortNum and 
	            plh.pl_owner_code = 'T' and 
	            plh.pl_type in ('R') and 
	            pl_amt > 0.0
	      group by plh.pos_num
	      set @rows_affected = @@rowcount
      end try
      begin catch
	      print '=> Failed to insert records into #tempExpiredPLH for pl type U'
	      print '==> ERROR: ' + ERROR_MESSAGE()
	      goto endofsp
      end catch

      set @rows_affected = 0

      -- for new EF, C; closed pl purchase trades
      begin try
	      insert into #tempExpiredPLH
	      select plh.pos_num, 'C', SUM(pl_amt), 0
      	from dbo.pl_history plh 
	              inner join #tempExpiredPos tpos 
	                 on plh.pos_num = tpos.posNum
	      where plh.pl_asof_date = @inputPlAsofDate and 
	            plh.real_port_num = @inputRealPortNum and 
	            plh.pl_owner_code = 'T' and 
	            plh.pl_type in ('C') and 
	            pl_amt <= 0.0
	      group by plh.pos_num
	      set @rows_affected = @@rowcount
      end try
      begin catch
	      print '=> Failed to insert records into #tempExpiredPLH for pl type C'
	      print '==> ERROR: ' + ERROR_MESSAGE()
	      goto endofsp
      end catch

      set @rows_affected = 0

      -- for new EF, S closed pl sale trades
      begin try
	      insert into #tempExpiredPLH
	      select plh.pos_num, 'S', SUM(pl_amt), 0
	      from dbo.pl_history plh 
              	inner join #tempExpiredPos tpos 
              	   on plh.pos_num = tpos.posNum
	      where plh.pl_asof_date = @inputPlAsofDate and 
	            plh.real_port_num = @inputRealPortNum and 
	            plh.pl_owner_code='T' and 
	            plh.pl_type in ('C') and 
	            pl_amt > 0.0
	      group by plh.pos_num
	      set @rows_affected = @@rowcount
      end try
      begin catch
	      print '=> Failed to insert records into #tempExpiredPLH for pl type S'
	      print '==> ERROR: ' + ERROR_MESSAGE()
	      goto endofsp
      end catch

      set @rows_affected = 0

      -- for new EF, M
      begin try
	      insert into #tempExpiredPLH
	      select plh.pos_num, 'M', SUM(pl_amt), 0
	      from dbo.pl_history plh 
	              inner join #tempExpiredPos tpos 
	                 on plh.pos_num = tpos.posNum
	      where plh.pl_asof_date = @inputPlAsofDate and 
	            plh.real_port_num = @inputRealPortNum and 
	            plh.pl_owner_code = 'T' and 
	            plh.pl_type in ('U')
	      group by plh.pos_num
	      set @rows_affected = @@rowcount
      end try
      begin catch
	      print '=> Failed to insert records into #tempExpiredPLH for pl type M'
	      print '==> ERROR: ' + ERROR_MESSAGE()
	      goto endofsp
      end catch

      -- update recordQty for closed pl by converting the qty from tid to commktPriceUomCode
      update #tempExpiredPLH 
      set recordQty = recordQty + isnull(aggreQty.sumQty, 0)
      from #tempExpiredPLH tPlh2
              inner join  (select tPlh.posNum, 
                                  tPlh.plType, 
                                  ISNULL(sum(isnull(alloc_qty, 0)), 0) as sumQty
                           from #tempExpiredPLH tPlh
                                   inner join dbo.trade_item_dist tid 
                                      on tPlh.posNum = tid.pos_num
                                   inner join dbo.position p 
                                      on p.pos_num = tPlh.posNum
                                   inner join dbo.commkt_future_attr cfAttr with (nolock)
                                      on cfAttr.commkt_key = p.commkt_key
                           where tPlh.plType = 'S' and 
                                 tid.p_s_ind = 'S' and 
                                 tid.qty_uom_code = cfAttr.commkt_price_uom_code
                           group by tPlh.posNum, tPlh.plType) as aggreQty 
                 on aggreQty.posNum = tPlh2.posNum and 
                    aggreQty.plType = tPlh2.plType

      update #tempExpiredPLH 
      set recordQty = recordQty + isnull(aggreQty.sumQty, 0)
      from #tempExpiredPLH tPlh2
             inner join (select tPlh.posNum as posNum, 
                                tPlh.plType as plType, 
                                ISNULL(sum(isnull(alloc_qty * cfAttr.commkt_lot_size, 0)), 0) as sumQty
                         from #tempExpiredPLH tPlh
                                 inner join dbo.trade_item_dist tid 
                                    on tPlh.posNum = tid.pos_num
                                 inner join dbo.position p 
                                    on p.pos_num = tPlh.posNum
                                 inner join dbo.commkt_future_attr cfAttr with (nolock)
                                    on cfAttr.commkt_key = p.commkt_key
                         where tPlh.plType = 'S' and 
                               tid.p_s_ind = 'S' and 
                               tid.qty_uom_code = 'LOTS' and 
                               tPlh.recordQty = 0.0
                         group by tPlh.posNum, tPlh.plType) aggreQty 
                on aggreQty.posNum = tPlh2.posNum and 
                   aggreQty.plType = tPlh2.plType

      update #tempExpiredPLH 
      set recordQty = recordQty + isnull(aggreQty.sumQty, 0)
      from #tempExpiredPLH tPlh2
             inner join (select tPlh.posNum, 
                                tPlh.plType, 
                                ISNULL(sum(isnull(alloc_qty, 0)), 0) as sumQty
                         from #tempExpiredPLH tPlh
                                  inner join dbo.trade_item_dist tid 
                                     on tPlh.posNum = tid.pos_num
                                  inner join dbo.position p 
                                     on p.pos_num = tPlh.posNum
                                  inner join dbo.commkt_future_attr cfAttr with (nolock)
                                     on cfAttr.commkt_key = p.commkt_key
                         where tPlh.plType = 'C' and 
                               tid.p_s_ind = 'P' and 
                               tid.qty_uom_code = cfAttr.commkt_price_uom_code
                         group by tPlh.posNum, tPlh.plType) as aggreQty 
                on aggreQty.posNum = tPlh2.posNum and 
                   aggreQty.plType = tPlh2.plType

      update #tempExpiredPLH 
      set recordQty = recordQty + isnull(aggreQty.sumQty, 0)
      from #tempExpiredPLH tPlh2
              inner join (select tPlh.posNum as posNum, 
                                 tPlh.plType as plType, 
                                 ISNULL(sum(isnull(alloc_qty * cfAttr.commkt_lot_size, 0)), 0) as sumQty
                          from #tempExpiredPLH tPlh
                                  inner join dbo.trade_item_dist tid 
                                     on tPlh.posNum = tid.pos_num
                                  inner join dbo.position p 
                                     on p.pos_num = tPlh.posNum
                                  inner join dbo.commkt_future_attr cfAttr with (nolock) 
                                     on cfAttr.commkt_key = p.commkt_key
                          where tPlh.plType = 'C' and 
                                tid.p_s_ind = 'P' and 
                                tid.qty_uom_code = 'LOTS' and 
                                tPlh.recordQty = 0.0
                          group by tPlh.posNum, tPlh.plType) aggreQty 
                 on aggreQty.posNum = tPlh2.posNum and 
                    aggreQty.plType = tPlh2.plType


      exec dbo.gen_new_transaction_NOI @app_name = 'DbIssue_xxx'
      select @transId = last_num 
      from dbo.icts_trans_sequence 
      where oid = 1

      set @rows_affected = 0
      begin tran
      begin try
	      insert into dbo.pl_history
	      select texpPLH.posNum, 
	             'EF', 
	             @outputPlAsofDate, 
	             @inputRealPortNum, 
	             'F',
	             texpPLH.posNum, 
	             texpPLH.posNum, 
	             null, 
	             null, 
	             null, 
	             texpPLH.posNum, 
	             null, 
	             null,
	             texpPLH.plType, 
	             null, 
	             texpPos.lastTradeDate, 
	             null, 
	             null, 
	             texpPos.lastMtmPrice,
	             texpPLH.plAmt, 
	             @transId, 
	             null,
	             case texpPLH.plType
		              when 'R' then isnull(texpPos.longQty, 0) * posFactor
		              when 'U' then isnull(texpPos.shortQty, 0) * posFactor
		              when 'M' then (isnull(texpPos.longQty, 0) - isnull(texpPos.shortQty, 0)) * posFactor
		              when 'L' then null
		              when 'C' then isnull(texpPLH.recordQty, 0)
		              when 'S' then isnull(texpPLH.recordQty, 0)
		              else null
	             end,
	             texpPos.commktPriceUom, 
	             texpPos.posNum
	          from #tempExpiredPos texpPos
	                  inner join #tempExpiredPLH texpPLH 
	                     on texpPos.posNum = texpPLH.posNum
	          where (texpPLH.plAmt <> 0.0 or 
	                (texpPLH.plAmt = 0.0 and 
	                 texpPLH.plType in ('R', 'U')))
	          set @rows_affected = @@rowcount
      end try
      begin catch
	      if @@trancount > 0
	         rollback tran
	      print '=> Failed to insert records into pl_history table'
	      print '==> ERROR: ' + ERROR_MESSAGE()
	      goto endofsp
      end catch
      --commit tran
      if @rows_affected > 0
         print '==> ' + convert(varchar, @rows_affected) + ' Records inserted into pl_history table'

      if @inputPlAsofDate = @outputPlAsofDate
      begin
	       begin try
		       delete dbo.pl_history 
		       where pl_asof_date = @inputPlAsofDate and 
		             real_port_num = @inputRealPortNum and 
		             pos_num in (select posNum 
		                         from #tempExpiredPos) and 
		             pl_owner_code != 'EF'
		       set @rows_affected = @@rowcount
	       end try
	       begin catch
		       if @@trancount > 0
		          rollback tran
		       print '=> Failed to delete pl_history table entries'
		       print '==> ERROR: ' + ERROR_MESSAGE()
		       goto endofsp
	       end catch
	       --commit tran
	       if @rows_affected > 0
	          print '==> ' + convert(varchar, @rows_affected) + ' Records deleted on pl_history table'
      end

      -- update position last_mtm_price
      begin try
	      update dbo.position
	      set last_mtm_price = lastMtmPrice, 
	          trans_id = @transId
	      from #tempExpiredPos epos 
	              inner join position p 
	                 on p.pos_num = epos.posNum
	      set @rows_affected = @@rowcount
	    end try
	    begin catch
		    if @@trancount > 0
		       rollback tran
		    print '=> Failed to update position table entries'
		    print '==> ERROR: ' + ERROR_MESSAGE()
		    goto endofsp
	    end catch
	    --commit tran
	    if @rows_affected > 0
         print '==> ' + convert(varchar, @rows_affected) + ' Records updated on position table'

      select @inputRealPortNum = min(portNum) 
      from #portInPlHistory 
      where portNum > @inputRealPortNum
      commit tran
   end

endofsp:
drop table #portInPlHistory
drop table #tempExpiredPos
drop table #tempExpiredPLH
GO
GRANT EXECUTE ON  [dbo].[usp_exp_futures_locked_positions] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_exp_futures_locked_positions', NULL, NULL
GO
