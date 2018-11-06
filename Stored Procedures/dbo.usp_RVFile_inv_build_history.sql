SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_inv_build_history]
(
   @asof_date            datetime = null,
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
        @my_port_num       int,
        @my_asof_date      datetime

   select @my_asof_date = @asof_date,
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

   create table #invhist
   (
      oid                        numeric(18, 0) IDENTITY,
      inv_num                    int null,
      asof_date                  datetime null,
      cost_trade_num             int null,
      cost_order_num             int null,
      cost_item_num              int null,
      invhist_real_port_num      int null,
      rcpt_alloc_num             int null,
      rcpt_alloc_item_num        int null,
      cost_num                   int null,
      cost_due_date              datetime null,
      invhist_trans_id           int null,
      pl_mkt_price_cost          float null,
      pl_amt                     float null,
      pl_record_qty              numeric(20,8) null,
      pl_mkt_price_tid           float null,
      inv_b_d_qty                float null,
      ti_trans_id                int null,
      dist_num                   int null,
      pos_num                    int null,
      commkt_key                 int null,
      p_s_ind                    char(1) null,
      counterparty               int null,
      contr_date                 datetime null,
      inhouse_ind                char(1) null,
      del_date_from              datetime null,
      del_date_to                datetime null,
      del_loc_code               char(8) null,
      trading_prd                char(8) null
   )

   select @stepid = 0
   /* -----------------------------------------------
       STEP: Copying rows into #invhist table
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Copying rows into #invhist table', getdate())

   insert into #invhist
   (
      inv_num,
      asof_date,
      cost_trade_num,
      cost_order_num,
      cost_item_num,
      invhist_real_port_num,
      rcpt_alloc_num,
      rcpt_alloc_item_num,
      cost_num,
      cost_due_date,
      invhist_trans_id
   )
   select
      inv_num,
      asof_date,
      cost_trade_num,
      cost_order_num,
      cost_item_num,
      real_port_num,
      rcpt_alloc_num,
      rcpt_alloc_item_num,
      cost_num,
      cost_due_date,
      trans_id
   from dbo.inventory_history ih WITH (NOLOCK)
   where ih.asof_date = @my_asof_date AND 
         exists (select 1
                 from @port_num_list port
                 where ih.real_port_num = port.real_port_num) AND
         not exists (select 1 
                     from dbo.inventory_history ih2 WITH (NOLOCK)
                     where ih2.asof_date < ih.asof_date AND
                           ih2.real_port_num = ih.real_port_num AND
                           ih2.inv_num = ih.inv_num AND
                           ih2.cost_num = ih.cost_num) AND
         ih.cost_type_code = 'WPP'
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
         print 'No inventory_history records found!'
      end
      goto endofsp
   end

   create clustered index xx_invhist_idx990
      on #invhist (oid)
   create nonclustered index xx_invhist_idx991
      on #invhist (cost_trade_num, cost_order_num, cost_item_num, invhist_real_port_num, invhist_trans_id)
   create nonclustered index xx_invhist_idx992
      on #invhist (inv_num, asof_date, invhist_real_port_num, cost_num)
   create nonclustered index xx_invhist_idx993
      on #invhist (rcpt_alloc_num, rcpt_alloc_item_num, cost_num)

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
      trans_id      int null
   )

   insert into #trades
   select t.trade_num,
          t.acct_num,
          t.contr_date,
          t.inhouse_ind,
          t.trans_id
   from dbo.trade t WITH (NOLOCK),
        #invhist invhist
   where t.trade_num = invhist.cost_trade_num and
         t.trans_id <= invhist.invhist_trans_id
   union
   select t.trade_num,
          t.acct_num,
          t.contr_date,
          t.inhouse_ind,
          t.trans_id
   from dbo.aud_trade t WITH (NOLOCK),
        #invhist invhist
   where t.trade_num = invhist.cost_trade_num and
         t.trans_id <= invhist.invhist_trans_id
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

   /* ---------------------------------------------------
       STEP: Getting acct_num and contr_date information
      --------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
          (oid, step, starttime)
        values(@stepid, 'Updating (trade) acct_num, contr_date in #invhist', getdate())

   update #invhist
   set counterparty = t.acct_num,
       contr_date = t.contr_date,
       inhouse_ind = t.inhouse_ind
   from #trades t,
        #invhist invhist
   where t.trade_num = invhist.cost_trade_num and
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

   /* -----------------------------------------------------------
       STEP: Getting inv_b_d_qty from dbo.inventory_build_draw table
      ----------------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
          (oid, step, starttime)
        values(@stepid, 'Getting inv_b_d_qty from dbo.inventory_build_draw', getdate())

   create table #invbds
   (
      inv_num              int,
      inv_b_d_num          int,
      alloc_num            int null,
      inv_b_d_qty          float null,
      trans_id             int null
   )

   insert into #invbds
   select invbd.inv_num,
          invbd.inv_b_d_num,
          invbd.alloc_num,
          invbd.inv_b_d_qty,
          invbd.trans_id
   from dbo.inventory_build_draw invbd WITH (NOLOCK),
        #invhist invhist
   where invbd.inv_num = invhist.inv_num AND
         invbd.inv_b_d_type = 'B' AND
         invbd.alloc_num = invhist.rcpt_alloc_num AND
         invbd.trans_id <= invhist.invhist_trans_id
   union
   select invbd.inv_num,
          invbd.inv_b_d_num,
          invbd.alloc_num,
          invbd.inv_b_d_qty,
          invbd.trans_id
   from dbo.aud_inventory_build_draw invbd WITH (NOLOCK),
        #invhist invhist
   where invbd.inv_num = invhist.inv_num AND
         invbd.inv_b_d_type = 'B' AND
         invbd.alloc_num = invhist.rcpt_alloc_num AND
         invbd.trans_id <= invhist.invhist_trans_id
   select @rows_affected = @@rowcount
   if @debugon = 1 
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
   end
   
   create nonclustered index xx_878_invbds_idx1
      on #invbds(inv_num, inv_b_d_num, trans_id)

   if @rows_affected > 0
   begin
      /* -----------------------------------------------
          STEP: Updating inv_b_d_qty in #invhist
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating inv_b_d_qty in #invhist', getdate())

      update #invhist
      set inv_b_d_qty = invbd.inv_b_d_qty
      from #invbds invbd
      where invbd.inv_num = #invhist.inv_num AND
            invbd.alloc_num = #invhist.rcpt_alloc_num AND
            trans_id = (select max(trans_id)
                        from #invbds invbd2 
                        where invbd2.inv_num = invbd.inv_num AND    
                              invbd2.inv_b_d_num = invbd.inv_b_d_num)    
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected 
         where oid = @stepid
      end
   end
   drop table #invbds

   /* --------------------------------------------------------
       STEP: Getting cost-related pl_history information
      -------------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
          (oid, step, starttime)
        values(@stepid, 'Getting cost-related pl_history information', getdate())

   update #invhist
   set pl_mkt_price_cost = plh.pl_mkt_price,
       pl_amt = plh.pl_amt,
       pl_record_qty = plh.pl_record_qty
   from dbo.pl_history plh WITH (NOLOCK), 
        #invhist invhist
   where invhist.invhist_real_port_num = plh.real_port_num AND
         invhist.cost_trade_num = plh.pl_secondary_owner_key1 AND
         invhist.cost_order_num = plh.pl_secondary_owner_key2 AND
         invhist.cost_item_num = plh.pl_secondary_owner_key3 AND
         plh.pl_owner_code = 'C' AND
         plh.pl_owner_sub_code = 'WPP' AND
         plh.pl_asof_date = (select max(pl_asof_date) 
                             from dbo.pl_history plh2 WITH (NOLOCK)
                             where plh2.pl_record_key = plh.pl_record_key AND
                                   plh2.pl_type = plh.pl_type AND
                                   plh2.pl_owner_code = plh.pl_owner_code AND
                                   plh2.pl_asof_date < invhist.asof_date) 
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
   end

   /* --------------------------------------------------------
       STEP: Getting TID-related pl_history information
      -------------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
          (oid, step, starttime)
        values(@stepid, 'Getting TID-related pl_history information', getdate())

   update #invhist
   set pl_mkt_price_tid = plh.pl_mkt_price
   from dbo.pl_history plh WITH (NOLOCK), 
        #invhist invhist
   where invhist.invhist_real_port_num = plh.real_port_num AND
         invhist.cost_trade_num = plh.pl_secondary_owner_key1 AND
         invhist.cost_order_num = plh.pl_secondary_owner_key2 AND
         invhist.cost_item_num = plh.pl_secondary_owner_key3 AND
         invhist.asof_date = plh.pl_asof_date AND
         plh.pl_owner_code = 'T' AND
         plh.pl_owner_sub_code = 'W'
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
   end

   /* -------------------------------------------------
       STEP: Getting trade_item level information, if
             there are trade_item record(s) found, then
             get PHYSICAL specific information.
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
      trans_id            int null,
      trading_prd         varchar(40) null,
      contr_qty_uom_code  char(4) null,
      price_uom_code      varchar(4) null,
      real_port_num       int null,
      avg_price           float null,
      cmdty_code          varchar(8) null,
      risk_mkt_code       varchar(8) null,
      booking_comp_num    int null,
      price_curr_code     char(8) null,
      brkr_num            int null, 
      brkr_comm_amt       float null,
      contr_qty           float null,
      formula_ind         char(1) null
   )

   create table #tiwps
   (
       trade_num               int,
       order_num               smallint,
       item_num                smallint,
       del_date_from           datetime null,
       del_date_to             datetime null,
       del_loc_code            char(8) null, 
       trans_id                int null
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
          ti.price_curr_code,
          ti.brkr_num, 
          ti.brkr_comm_amt,
          ti.contr_qty,
          ti.formula_ind
   from dbo.trade_item ti WITH (NOLOCK),
        #invhist invhist
   where ti.trade_num = invhist.cost_trade_num AND    
         ti.order_num = invhist.cost_order_num AND    
         ti.item_num = invhist.cost_item_num AND
         ti.trans_id <= invhist.invhist_trans_id
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
          ti.price_curr_code,
          ti.brkr_num, 
          ti.brkr_comm_amt,
          ti.contr_qty,
          ti.formula_ind
   from dbo.aud_trade_item ti WITH (NOLOCK),
        #invhist invhist
   where ti.trade_num = invhist.cost_trade_num AND    
         ti.order_num = invhist.cost_order_num AND    
         ti.item_num = invhist.cost_item_num AND
         ti.trans_id <= invhist.invhist_trans_id
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
          STEP: Updating ti_trans_id in #invhist
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating ti_trans_id in #invhist', getdate())
           
      update #invhist
      set ti_trans_id = (select max(trans_id)
                         from #items ti    
                         where ti.trade_num = #invhist.cost_trade_num AND    
                               ti.order_num = #invhist.cost_order_num AND    
                               ti.item_num = #invhist.cost_item_num)
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected 
         where oid = @stepid
      end

      /* --------------------------------------------------------
          STEP: Getting trade_item_wet_phy's related information
         -------------------------------------------------------- */     
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Getting trade_item_wet_phy information', getdate())

      insert into #tiwps
      select tiwp.trade_num,
             tiwp.order_num,
             tiwp.item_num,
             tiwp.del_date_from,
             tiwp.del_date_to,
             tiwp.del_loc_code, 
             tiwp.trans_id
      from dbo.trade_item_wet_phy tiwp WITH (NOLOCK),
           #invhist invhist
      where tiwp.trade_num = invhist.cost_trade_num AND    
            tiwp.order_num = invhist.cost_order_num AND    
            tiwp.item_num = invhist.cost_item_num AND
            tiwp.trans_id <= invhist.invhist_trans_id
      union
      select tiwp.trade_num,
             tiwp.order_num,
             tiwp.item_num,
             tiwp.del_date_from,
             tiwp.del_date_to,
             tiwp.del_loc_code, 
             tiwp.trans_id
      from dbo.aud_trade_item_wet_phy tiwp WITH (NOLOCK),
           #invhist invhist
      where tiwp.trade_num = invhist.cost_trade_num AND    
            tiwp.order_num = invhist.cost_order_num AND    
            tiwp.item_num = invhist.cost_item_num AND
            tiwp.trans_id <= invhist.invhist_trans_id
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected 
         where oid = @stepid
      end
      
      create nonclustered index xx_878_tiwp_idx1
         on #tiwps(trade_num, order_num, item_num, trans_id)

      if @rows_affected > 0
      begin
         /* --------------------------------------------------
             STEP: Updating PHYSICAL-specific data in #invhist
            -------------------------------------------------- */   
         select @stepid = @stepid + 1
         if @debugon = 1 
            insert into @times 
               (oid, step, starttime)
              values(@stepid, 'Updating PHYSICAL-specific data in #invhist', getdate())

         update #invhist
         set del_date_from = tiwp.del_date_from,
             del_date_to = tiwp.del_date_to,
             del_loc_code = tiwp.del_loc_code 
         from #tiwps tiwp,
              #invhist invhist
         where tiwp.trade_num = invhist.cost_trade_num AND    
               tiwp.order_num = invhist.cost_order_num AND    
               tiwp.item_num = invhist.cost_item_num AND
               tiwp.trans_id = (select max(trans_id) 
                                from #tiwps tiwp2 
                                where tiwp2.trade_num = tiwp.trade_num AND
                                      tiwp2.order_num = tiwp.order_num AND
                                      tiwp2.item_num = tiwp.item_num)
         select @rows_affected = @@rowcount
         if @debugon = 1
         begin
            update @times
            set endtime = getdate(),
                rows_affected = @rows_affected 
            where oid = @stepid
         end
      end
   end
   drop table #tiwps

   /* ----------------------------------------------------
       STEP: Getting trade_item_dist's related information
      ---------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Getting trade_item_dist information', getdate())

   create table #tids
   (
      dist_num         int,
      trade_num        int null,
      order_num        smallint null,
      item_num         smallint null,
      real_port_num    int null,
      pos_num          int null,
      commkt_key       int null,
      p_s_ind          char(1) null,
      trading_prd      char(8) null,
      trans_id         int null
   )

   insert into #tids
   select tid.dist_num,
          tid.trade_num,
          tid.order_num,
          tid.item_num,
          tid.real_port_num,
          tid.pos_num,
          tid.commkt_key,
          tid.p_s_ind,
          tid.trading_prd,
          tid.trans_id
   from dbo.trade_item_dist tid WITH (NOLOCK),
        #invhist invhist
   where tid.trade_num = invhist.cost_trade_num AND
         tid.order_num = invhist.cost_order_num AND
         tid.item_num = invhist.cost_item_num AND
         tid.trans_id <= invhist.invhist_trans_id
   union
   select tid.dist_num,
          tid.trade_num,
          tid.order_num,
          tid.item_num,
          tid.real_port_num,
          tid.pos_num,
          tid.commkt_key,
          tid.p_s_ind,
          tid.trading_prd,
          tid.trans_id
   from dbo.aud_trade_item_dist tid WITH (NOLOCK),
        #invhist invhist
   where tid.trade_num = invhist.cost_trade_num AND
         tid.order_num = invhist.cost_order_num AND
         tid.item_num = invhist.cost_item_num AND
         tid.trans_id <= invhist.invhist_trans_id
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
   end

   create nonclustered index xx_878_tids_idx1
       on #tids(trade_num, order_num, item_num, trans_id)
   create nonclustered index xx_878_tids_idx2
       on #tids(dist_num, trans_id)

   -- If the trade has associated distributions, then get dist_nums
   if @rows_affected > 0
   begin
      /* --------------------------------------------------
          STEP: Updating TID-related data items in #invhist
         -------------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating TID-related data items in #invhist', getdate())

      update #invhist
      set dist_num = tid.dist_num,
          pos_num = tid.pos_num,
          commkt_key = tid.commkt_key,
          p_s_ind = tid.p_s_ind,
          trading_prd = tid.trading_prd 
      from #tids tid,
           #invhist invhist
      where tid.trade_num = invhist.cost_trade_num AND
            tid.order_num = invhist.cost_order_num AND
            tid.item_num = invhist.cost_item_num AND
            tid.trans_id = (select max(trans_id)    
                            from #tids tid2 
                            where tid2.dist_num = tid.dist_num)    
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected
         where oid = @stepid
      end
   end
   drop table #tids

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
      ih.inv_num,
      ih.cost_trade_num,
      ih.cost_order_num,
      ih.cost_item_num,
      ih.invhist_real_port_num,
      ih.rcpt_alloc_num,
      ih.rcpt_alloc_item_num,
      convert(char(10), ih.cost_due_date, 101) as cost_due_date,
      ih.inv_b_d_qty,
      ih.pl_mkt_price_cost,
      ih.pl_amt,
      ih.pl_record_qty,
      ih.pl_mkt_price_tid,
      ih.ti_trans_id,
      ti.trading_prd as ti_trading_prd,
      ti.contr_qty_uom_code,
      ti.price_uom_code,
      ti.cmdty_code,
      ti.risk_mkt_code,
      ti.booking_comp_num,
      ti.real_port_num as ti_real_port_num,
      ti.avg_price,
      ti.price_curr_code,
      ih.p_s_ind,
      ti.brkr_num,
      ti.brkr_comm_amt,
      ti.contr_qty,
      ti.formula_ind,
      ih.dist_num,
      ih.pos_num,
      ih.commkt_key,
      ih.counterparty,
      convert(char(10), ih.contr_date, 101) as contr_date,
      ih.inhouse_ind,
      convert(char(10), ih.del_date_from, 101) as del_date_from,
      convert(char(10), ih.del_date_to, 101) as del_date_to,
      ih.del_loc_code,
      ih.trading_prd as tid_trading_prd
   from #invhist ih
           RIGHT OUTER JOIN #items ti
              ON ti.trade_num = ih.cost_trade_num AND 
                 ti.order_num = ih.cost_order_num AND 
                 ti.item_num = ih.cost_item_num AND 
                 ti.trans_id = ih.ti_trans_id
   order by cost_trade_num,
            cost_order_num,
            cost_item_num 
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
      select @smsg = 'usp_RVFile_inv_build_history: ' + convert(varchar, @rows_affected) + ' rows returned.'
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

endofsp:
drop table #invhist
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_inv_build_history] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_RVFile_inv_build_history', NULL, NULL
GO
