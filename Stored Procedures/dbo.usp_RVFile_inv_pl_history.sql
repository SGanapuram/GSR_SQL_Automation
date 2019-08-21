SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_inv_pl_history]
(
   @pl_asof_date         datetime = null,
   @top_port_num         int = 0,
   @debugon              bit = 0
)
as
set nocount on
declare @rows_affected     int,
        @smsg              varchar(255),
        @status            int,
        @oid               numeric(18, 0),
        @stepid            smallint,  
        @my_pl_asof_date   datetime,  
        @my_port_num       int  
  
   select @my_pl_asof_date = @pl_asof_date,  
          @my_port_num = @top_port_num  

   if @debugon = 1
   begin
      declare @times   table
      (
         oid                int,
         step               varchar(80),
         starttime          datetime null,
         endtime            datetime null,
         rows_affected      int default -1 null
      )
   end

   declare @port_num_list table 
   (
      real_port_num     int 
   )

   insert into @port_num_list
   select port_num 
   from dbo.udf_RVFile_child_port_nums(@my_port_num)
   where port_type = 'R'
   select @rows_affected = @@rowcount

   if @rows_affected > 0
   begin  
      if @debugon = 1
      begin
         print ' '
         print '***************************************'
         print ' real_port_nums'
         print '---------------------------------------'
         select real_port_num from @port_num_list order by real_port_num     
      end 
   end
   else
   begin
      print 'No real port_nums found!'
      goto endofsp
   end

   create table #plh
   (
      oid                     numeric(18, 0) IDENTITY,
      pl_record_key           int null,
      pl_asof_date            datetime null,
      pl_real_port_num        int null,
      pl_owner_code           char(8) null,
      pl_type                 char(8) null,
      pl_amt                  float null,
      pl_mkt_price            float null,
      pl_amt_realized         float null,
      pl_trans_id             bigint null,
      trade_num               int null,
      order_num               smallint null,
      sale_item_num           smallint null,
      del_loc_code            char(8) null,
      inv_bal_from_date       datetime null,
      inv_bal_to_date         datetime null,
      pos_num                 int null,
      commkt_key              int null,
      pos_cmdty_code          char(8) null,
      mkt_code                char(8) null,
      long_qty                float null,
      short_qty               float null,
      counterparty            int null,
      contr_date              datetime null,
      inhouse_ind             char(1) null,
      pos_trans_id            bigint null
   )

   select @stepid = 0
   /* -----------------------------------------------
       STEP: Copying rows into #plh table
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Copying rows into #plh table', getdate())

   insert into #plh
   (
      pl_record_key,
      pl_asof_date,
      pl_real_port_num,
      pl_owner_code,
      pl_type,
      pl_amt,
      pl_mkt_price,
      pl_trans_id
   )
   select plh.pl_record_key,
          plh.pl_asof_date,
          plh.real_port_num,
          plh.pl_owner_code,
          plh.pl_type,
          plh.pl_amt,
          plh.pl_mkt_price,
          plh.trans_id
   from dbo.pl_history plh WITH (NOLOCK)
   where plh.pl_asof_date = @my_pl_asof_date AND 
         exists (select 1
                 from @port_num_list port
                 where plh.real_port_num = port.real_port_num) AND
         plh.pl_owner_code = 'P' AND
         plh.pl_type = 'U'
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times 
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
   end

   create nonclustered index xx_plh_xx_idx1
      on #plh(pl_record_key,pl_real_port_num,pl_owner_code, pl_asof_date)

   if @rows_affected <= 0
   begin
      if @debugon = 1 
      begin
         print 'No pl_history records found!'
      end
      goto endofsp
   end

  /* -------------------------------------------------
     STEP: remove positions which were rolled on 
           asofDate before we ran this
     ---------------------------------------------------*/
   delete #plh 
   from #plh plh
   where not exists (select 1 
                     from (select pos_num,
                                  open_close_ind,
                                  trans_id
                           from dbo.inventory WITH (NOLOCK)
                           union
                           select pos_num,
                                  open_close_ind,
                                  trans_id
                           from dbo.aud_inventory WITH (NOLOCK)) inv  
                     where inv.pos_num = plh.pl_record_key and
                           inv.open_close_ind = 'O' and
                           inv.trans_id >= (select isnull(max(trans_id) , 0) 
							                              from dbo.pl_history WITH (NOLOCK)
                                            where pl_owner_code = 'P' and
                                                  pl_record_key = plh.pl_record_key and
                                                  pl_asof_date = (select max(pl_asof_date) 
								       		                                        from dbo.pl_history WITH (NOLOCK)
                                                                  where pl_owner_code='P' and 
                                                                        pl_type = 'U' and 
												                                                pl_record_key = plh.pl_record_key and 
												                                                pl_asof_date < (select max(pl_asof_date) 
                                                                                        from dbo.pl_history WITH (NOLOCK)
             													                                                  where pl_asof_date < @my_pl_asof_date and
								                                                                              pl_owner_code='P' and
								                                                                              pl_record_key = plh.pl_record_key and
								                                                                              pl_type = 'U'))))

    select @rows_affected = @@rowcount
    print 'deleted rolled positions '  + convert(varchar, @rows_affected)
    
   /* -----------------------------------------------
       STEP: Updating realized pl_amt in #plh
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Updating realized pl_amt in #plh', getdate())

   update #plh
   set pl_amt_realized = plhr.pl_amt
   from dbo.pl_history plhr WITH (NOLOCK)
   where plhr.real_port_num = #plh.pl_real_port_num AND
         plhr.pl_record_key = #plh.pl_record_key AND
         plhr.pl_owner_code = #plh.pl_owner_code AND
         plhr.pl_type = 'R' AND
         plhr.pl_asof_date = #plh.pl_asof_date
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times 
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
   end
   

   /* -------------------------------------------------
       STEP: Getting position information
      ------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Getting position information', getdate())

   create table #positions
   (
      pos_num          int not null,
      real_port_num    int null,
      commkt_key       int null,
      cmdty_code       char(8) null,
      mkt_code         char(8) null,
      long_qty         float null,
      short_qty        float null,
      trans_id         bigint not null,
      pl_trans_id      bigint null,
      inv_trans_id     bigint null
   )
 
   insert into #positions
   select p.pos_num,
          p.real_port_num,
          p.commkt_key,
          p.cmdty_code,
          p.mkt_code,
          p.long_qty,
          p.short_qty,
          p.trans_id,
          plh.pl_trans_id,
          null    /* inv_trans_id */
   from dbo.position p WITH (NOLOCK),
        #plh plh
   where p.pos_num = plh.pl_record_key AND    
         p.trans_id <= plh.pl_trans_id
   union
   select p.pos_num,
          p.real_port_num,
          p.commkt_key,
          p.cmdty_code,
          p.mkt_code,
          p.long_qty,
          p.short_qty,
          p.trans_id,
          plh.pl_trans_id,
          null    /* inv_trans_id */
   from dbo.aud_position p WITH (NOLOCK),
        #plh plh
   where p.pos_num = plh.pl_record_key AND    
         p.trans_id <= plh.pl_trans_id
   select @rows_affected = @@rowcount
   if @debugon = 1 
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
   end
   
   create nonclustered index xx_878_pos_idx1
      on #positions(pos_num, real_port_num, trans_id)

   if @rows_affected > 0
   begin
      /* -----------------------------------------------
          STEP: Updating pos_trans_id in #plh
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating pos_trans_id in #plh', getdate())

      update #plh
      set pos_trans_id = (select max(trans_id)
                          from #positions p    
                          where p.pos_num = #plh.pl_record_key)    
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected 
         where oid = @stepid
      end
   end

   /* -------------------------------------------------
       STEP: Getting inventory information
      ------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Getting inventory information', getdate())

   create table #invs
   (
      pos_num                 int not null,
      port_num                int null,
      trade_num               int null,
      order_num               smallint null,
      sale_item_num           smallint null,
      del_loc_code            char(8) null,
      inv_bal_from_date       datetime null,
      inv_bal_to_date         datetime null,
      trans_id                bigint not null,
      pl_trans_id             bigint null,
      ti_trans_id             bigint null
   )
 
   insert into #invs
   select inv.pos_num,
          inv.port_num,
          inv.trade_num,
          inv.order_num,
          inv.sale_item_num,
          inv.del_loc_code,
          inv.inv_bal_from_date,
          inv.inv_bal_to_date,
          inv.trans_id,
          p.pl_trans_id,
          null    /* ti_trans_id */
   from dbo.inventory inv WITH (NOLOCK),
        #positions p
   where inv.pos_num = p.pos_num AND
         inv.port_num = p.real_port_num AND    
         inv.trans_id <= p.pl_trans_id
   union
   select inv.pos_num,
          inv.port_num,
          inv.trade_num,
          inv.order_num,
          inv.sale_item_num,
          inv.del_loc_code,
          inv.inv_bal_from_date,
          inv.inv_bal_to_date,
          inv.trans_id,
          p.pl_trans_id,
          null    /* ti_trans_id */
   from dbo.aud_inventory inv WITH (NOLOCK),
        #positions p
   where inv.pos_num = p.pos_num AND
         inv.port_num = p.real_port_num AND    
         inv.trans_id <= p.pl_trans_id
   select @rows_affected = @@rowcount
   if @debugon = 1 
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
   end
   
   create nonclustered index xx_878_invs_idx1
      on #invs(pos_num, port_num, trans_id)

   if @rows_affected > 0
   begin
      /* -----------------------------------------------
          STEP: Updating inv_trans_id in #positions
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating inv_trans_id in #positions', getdate())

      update #positions
      set inv_trans_id = (select max(trans_id)
                          from #invs inv    
                          where inv.pos_num = #positions.pos_num AND
                                inv.port_num = #positions.real_port_num)
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected 
         where oid = @stepid
      end
   end

   /* -----------------------------------------------
       STEP: Getting trade ROOT level information
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Getting trade information', getdate())

   create table #trades
   (
      trade_num     int,
      acct_num      int null,
      contr_date    datetime null,
      inhouse_ind   char(1) null,
      trans_id      bigint null
   )

   insert into #trades
   select t.trade_num,
          t.acct_num,
          t.contr_date,
          t.inhouse_ind,
          t.trans_id
   from dbo.trade t WITH (NOLOCK),
        #invs inv
   where t.trade_num = inv.trade_num and
         t.trans_id <= inv.pl_trans_id
   union
   select t.trade_num,
          t.acct_num,
          t.contr_date,
          t.inhouse_ind,
          t.trans_id
   from dbo.aud_trade t WITH (NOLOCK),
        #invs inv
   where t.trade_num = inv.trade_num and
         t.trans_id <= inv.pl_trans_id
   select @rows_affected = @@rowcount
   if @debugon = 1 
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
   end
   
   if @rows_affected <= 0
   begin
      if @debugon = 1 
      begin
         print 'No trade records found!'
      end
      drop table #trades
      goto endofsp
   end

   create nonclustered index xx_878_trades_idx1
      on #trades(trade_num, trans_id)

   /* --------------------------------------------------
       STEP: Getting acct_num and contr_date information
      -------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
          (oid, step, starttime)
        values(@stepid, 'Updating (trade) acct_num, contr_date in #plh', getdate())
        
   update plh
   set counterparty = t.acct_num,
       contr_date = t.contr_date,
       inhouse_ind = t.inhouse_ind
   from #plh plh,
        #trades t,
        #invs inv
   where t.trade_num = inv.trade_num and
         plh.pl_record_key = inv.pos_num and
         t.trans_id = (select max(t2.trans_id) 
                       from #trades t2 
                       where t2.trade_num = t.trade_num)   
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
   end
   drop table #trades
  
   /* -------------------------------------------------
       STEP: Getting trade_item level information
      ------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Getting trade_item information', getdate())

   create table #items
   (
      trade_num           int,
      order_num           smallint,
      item_num            smallint,
      trans_id            bigint null,
      trading_prd         varchar(40) null,
      contr_qty_uom_code  char(4) null,
      price_uom_code      varchar(4) null,
      real_port_num       int null,
      avg_price           float null,
      cmdty_code          varchar(8) null,
      risk_mkt_code       varchar(8) null,
      booking_comp_num    int null,
      p_s_ind             char(1) null,
      price_curr_code     char(8) null,
      brkr_num            int null, 
      brkr_comm_amt       float null,
      contr_qty           float null,
      formula_ind         char(1) null,
      order_type_code     char(8) null
   )
 
   insert into #items
   select ti.trade_num,
          ti.order_num,
          ti.item_num,
          ti.trans_id,
          ti.trading_prd,
          ti.contr_qty_uom_code,
          ti.price_uom_code,
          ti.real_port_num,
          ti.avg_price,
          ti.cmdty_code,
          ti.risk_mkt_code,
          ti.booking_comp_num,
          ti.p_s_ind,
          ti.price_curr_code,
          ti.brkr_num, 
          ti.brkr_comm_amt,
          ti.contr_qty,
          ti.formula_ind,
          null
   from dbo.trade_item ti WITH (NOLOCK),
        #invs inv
   where ti.trade_num = inv.trade_num AND    
         ti.order_num = inv.order_num AND    
         ti.item_num = inv.sale_item_num AND
         ti.trans_id <= inv.pl_trans_id
   union
   select ti.trade_num,
          ti.order_num,
          ti.item_num,
          ti.trans_id,
          ti.trading_prd,
          ti.contr_qty_uom_code,
          ti.price_uom_code,
          ti.real_port_num,
          ti.avg_price,
          ti.cmdty_code,
          ti.risk_mkt_code,
          ti.booking_comp_num,
          ti.p_s_ind,
          ti.price_curr_code,
          ti.brkr_num, 
          ti.brkr_comm_amt,
          ti.contr_qty,
          ti.formula_ind,
          null
   from dbo.aud_trade_item ti WITH (NOLOCK),
        #invs inv
   where ti.trade_num = inv.trade_num AND    
         ti.order_num = inv.order_num AND    
         ti.item_num = inv.sale_item_num AND
         ti.trans_id <= inv.pl_trans_id
   select @rows_affected = @@rowcount
   if @debugon = 1 
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
   end
   
   create nonclustered index xx_878_items_idx1
      on #items(trade_num, order_num, item_num, trans_id)

   if @rows_affected > 0
   begin
      /* -----------------------------------------------
          STEP: Updating order_type_code in #items
         ----------------------------------------------- */   
      update #items
      set order_type_code = (select order_type_code
                             from dbo.trade_order trdord WITH (NOLOCK)
                             where #items.trade_num = trdord.trade_num and
                                   #items.order_num = trdord.order_num)

      update #items
      set order_type_code = (select order_type_code
                             from dbo.aud_trade_order trdord WITH (NOLOCK)
                             where #items.trade_num = trdord.trade_num and
                                   #items.order_num = trdord.order_num)
      where order_type_code is null
                                   
      /* -----------------------------------------------
          STEP: Updating ti_trans_id in #invs
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating ti_trans_id in #invs', getdate())

      update #invs
      set ti_trans_id = (select max(trans_id)
                         from #items ti    
                         where ti.trade_num = #invs.trade_num AND    
                               ti.order_num = #invs.order_num AND    
                               ti.item_num = #invs.sale_item_num)
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected 
         where oid = @stepid
      end
   end

   /* -----------------------------------------------
       STEP: Returns data back to caller
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Return result set', getdate())

   select distinct
      1,  /* oid */
      plh.pl_record_key,
      plh.pl_owner_code,
      plh.pl_type,
      plh.pl_amt,
      plh.pl_mkt_price,
      plh.pl_amt_realized,
      plh.pl_trans_id,
      inv.trade_num,
      inv.order_num,
      inv.sale_item_num,
      inv.del_loc_code,
      convert(char(10), inv.inv_bal_from_date, 101) as inv_bal_from_date,
      convert(char(10), inv.inv_bal_to_date, 101) as inv_bal_to_date,
      pos.pos_num,
      pos.commkt_key,
      pos.cmdty_code as pos_cmdty_code,
      pos.mkt_code,
      pos.long_qty,
      pos.short_qty,
      inv.ti_trans_id,
      ti.trading_prd,
      ti.contr_qty_uom_code,
      ti.price_uom_code,
      ti.cmdty_code,
      ti.risk_mkt_code,
      ti.booking_comp_num,
      ti.real_port_num,
      ti.avg_price,
      ti.price_curr_code,
      ti.p_s_ind,
      ti.brkr_num,
      ti.brkr_comm_amt,
      ti.contr_qty,
      ti.formula_ind,
      ti.order_type_code,
      plh.counterparty,
      convert(char(10), plh.contr_date, 101) as contr_date,
      plh.inhouse_ind
   from #plh plh, 
        #positions pos, 
        #invs inv,
        #items ti 
   where pos.pos_num = plh.pl_record_key AND
         pos.trans_id = plh.pos_trans_id AND
         inv.pos_num = pos.pos_num AND
         inv.port_num = pos.real_port_num AND
         inv.trans_id = pos.inv_trans_id AND
         inv.trade_num = (select max(trade_num) 
                          from #invs inv2
                          where inv2.pos_num = inv.pos_num AND
                                inv2.port_num = inv.port_num) AND
         inv.order_num = (select max(order_num) 
                          from #invs inv2
                          where inv2.pos_num = inv.pos_num AND
                                inv2.port_num = inv.port_num AND
                                inv2.trade_num = inv.trade_num) AND
         inv.sale_item_num = (select max(sale_item_num) 
                              from #invs inv2
                              where inv2.pos_num = inv.pos_num AND
                                    inv2.port_num = inv.port_num AND
                                    inv2.trade_num = inv.trade_num AND
                                    inv2.order_num = inv.order_num) AND
         ti.trade_num = inv.trade_num AND
         ti.order_num = inv.order_num AND
         ti.item_num = inv.sale_item_num AND
         ti.trans_id = inv.ti_trans_id 
   order by inv.trade_num,
            inv.order_num,
            inv.sale_item_num 
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
   end

   if @debugon = 1
   begin
      print ' '
      select @smsg = 'usp_RVFile_inv_pl_history: ' + convert(varchar, @rows_affected) + ' rows returned.'
      print @smsg
      print ' '

      declare @step       varchar(80),
              @starttime  varchar(30),
              @endtime    varchar(30)

      select @oid = min(oid)
      from @times

      while @oid is not null
      begin
         select @step = step,
                @starttime = convert(varchar, starttime, 109),
                @endtime = convert(varchar, endtime, 109),
                @rows_affected = rows_affected
         from @times
         where oid = @oid

         select @smsg = convert(varchar, @oid) + '. ' + @step
         print @smsg
         select @smsg = '    STARTED  AT  : ' + @starttime
         print @smsg       
         select @smsg = '    FINISHED AT  : ' + @endtime
         print @smsg
         select @smsg = '    ROWS AFFECTED: ' + convert(varchar, @rows_affected)
         print @smsg
         
         select @oid = min(oid)
         from @times
         where oid > @oid
      end /* while */
   end /* debug */
   drop table #items
   drop table #invs
   drop table #positions

endofsp:
drop table #plh
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_inv_pl_history] TO [next_usr]
GO
