SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_inv_draw_history]
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
        @my_port_num       int,
        @my_pl_asof_date   datetime

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
      oid                      numeric(18, 0) IDENTITY,
      pl_record_key            int null,
      pl_record_key_i          int null,
      pl_record_owner_key      int null,
      pl_secondary_owner_key1  int null,    
      pl_secondary_owner_key2  int null,    
      pl_secondary_owner_key3  int null,
      pl_real_port_num         int null,  
      pl_asof_date             datetime, 
      pl_primary_owner_key1    int null,
      pl_primary_owner_key2    int null,
      pl_realization_date      datetime null,
      pl_mkt_price             float null,
      pl_record_qty            numeric(20,8) null,
      pl_mkt_price_prev        float null,
      pl_amt_prev              float null,
      pl_record_qty_prev       numeric(20,8) null,
      pl_trans_id              bigint null,
      inv_num                  int null,
      inv_b_d_qty              float null,
      counterparty             int null,
      contr_date               datetime null,
      inhouse_ind              char(1) null,
      ti_trans_id              bigint null,
      dist_num                 int null,
      pos_num                  int null,
      commkt_key               int null,
      p_s_ind                  char(1) null,
      trading_prd              char(8) null,
      del_date_from            datetime null,
      del_date_to              datetime null,
      del_loc_code             char(8) null
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
      pl_record_key_i,
      pl_record_owner_key,
      pl_secondary_owner_key1,    
      pl_secondary_owner_key2,    
      pl_secondary_owner_key3,
      pl_real_port_num,  
      pl_asof_date, 
      pl_primary_owner_key1,
      pl_primary_owner_key2,
      pl_realization_date,
      pl_mkt_price,
      pl_record_qty,
      pl_trans_id
   )
   select plh.pl_record_key,
          plhi.pl_record_key,
          plh.pl_record_owner_key,
          plh.pl_secondary_owner_key1,    
          plh.pl_secondary_owner_key2,    
          plh.pl_secondary_owner_key3,
          plh.real_port_num,  
          plh.pl_asof_date, 
          plh.pl_primary_owner_key1,
          plh.pl_primary_owner_key2,
          plh.pl_realization_date,
          plh.pl_mkt_price,
          plh.pl_record_qty,
          plh.trans_id
   from dbo.pl_history plh  WITH (NOLOCK),
        dbo.pl_history plhi  WITH (NOLOCK)
   where plh.pl_asof_date = @my_pl_asof_date AND 
         exists (select 1
                 from @port_num_list port
                 where plh.real_port_num = port.real_port_num) AND
         plh.pl_owner_code = 'C' AND
         plh.pl_owner_sub_code = 'WPP' AND
         plhi.pl_owner_code = 'I' AND
         plhi.pl_owner_sub_code = 'D' AND
         plhi.pl_type = 'U' AND
         plhi.pl_asof_date = plh.pl_asof_date AND
         plhi.real_port_num = plh.real_port_num AND
         plhi.pl_primary_owner_key1 = plh.pl_primary_owner_key1 AND
         NOT EXISTS (select 1 
                     from dbo.pl_history plh1 WITH (NOLOCK)
                     where plh1.pl_owner_code = plh.pl_owner_code AND
                           plh1.pl_record_key = plh.pl_record_key AND
                           plh1.pl_type = plh.pl_type AND 
	                         plh1.pl_asof_date < plh.pl_asof_date)
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
         print 'No pl_history records found!'
      end
      goto endofsp
   end

   create nonclustered index xx_plh_xx_idx1
      on #plh(pl_secondary_owner_key1,
              pl_secondary_owner_key2,
              pl_secondary_owner_key3,
              pl_trans_id)

   /* -----------------------------------------------
       STEP: Updating previous pl_history information
             in the #plh table
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Updating previous pl_history information in #plh', getdate())

   update #plh
   set pl_mkt_price_prev = plhold.pl_mkt_price,
       pl_amt_prev = plhold.pl_amt,
       pl_record_qty_prev = plhold.pl_record_qty
   from dbo.pl_history plhold WITH (NOLOCK)
   where plhold.real_port_num = #plh.pl_real_port_num AND
         plhold.pl_secondary_owner_key1 = #plh.pl_secondary_owner_key1 AND
         plhold.pl_secondary_owner_key2 = #plh.pl_secondary_owner_key2 AND
         plhold.pl_secondary_owner_key3 = #plh.pl_secondary_owner_key3 AND
         plhold.pl_owner_code = 'C' AND
         plhold.pl_owner_sub_code = 'WPP' AND
         plhold.pl_asof_date = (select max(pl_asof_date) 
                                from dbo.pl_history plhold2 WITH (NOLOCK)
                                where plhold2.pl_record_key = plhold.pl_record_key AND
                                      plhold2.pl_type = plhold.pl_type AND
                                      plhold2.pl_owner_code = plhold.pl_owner_code AND
                                      plhold2.pl_asof_date < #plh.pl_asof_date)
   select @rows_affected = @@rowcount
   if @debugon = 1 
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
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
        #plh plh
   where t.trade_num = plh.pl_secondary_owner_key1 and
         t.trans_id <= plh.pl_trans_id
   union
   select t.trade_num,
          t.acct_num,
          t.contr_date,
          t.inhouse_ind,
          t.trans_id
   from dbo.aud_trade t WITH (NOLOCK),
        #plh plh
   where t.trade_num = plh.pl_secondary_owner_key1 and
         t.trans_id <= plh.pl_trans_id
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
        
   update #plh
   set counterparty = t.acct_num,
       contr_date = t.contr_date,
       inhouse_ind = t.inhouse_ind
   from #trades t,
        #plh plh
   where t.trade_num = plh.pl_secondary_owner_key1 and
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
       STEP: Getting inventory_build_draw information
      ------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Getting inventory_build_draw information', getdate())

   create table #invbds
   (
      inv_num                 int        NOT NULL,
      inv_b_d_num             int        NOT NULL,
      inv_b_d_qty             float      NULL,
      trans_id                bigint        NULL
   )

   insert into #invbds
   select invbd.inv_num,
          invbd.inv_b_d_num,
          invbd.inv_b_d_qty,
          invbd.trans_id
   from dbo.inventory_build_draw invbd WITH (NOLOCK),
        #plh plh
   where invbd.inv_b_d_num = plh.pl_record_key_i AND
         invbd.trans_id <= plh.pl_trans_id
   union
   select invbd.inv_num,
          invbd.inv_b_d_num,
          invbd.inv_b_d_qty,
          invbd.trans_id
   from dbo.aud_inventory_build_draw invbd WITH (NOLOCK),
        #plh plh
   where invbd.inv_b_d_num = plh.pl_record_key_i AND
         invbd.trans_id <= plh.pl_trans_id
   select @rows_affected = @@rowcount
   if @debugon = 1 
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
   end
   
   create nonclustered index xx_878_invbds_idx1
      on #invbds(inv_b_d_num, trans_id)

   if @rows_affected > 0
   begin
      /* ---------------------------------------------------
          STEP: Updating inv_num and inv_b_d_qty in #plh
         --------------------------------------------------- */ 
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating inv_num and inv_b_d_qty in #plh', getdate())

      update #plh
      set inv_num = invbd.inv_num,
          inv_b_d_qty = invbd.inv_b_d_qty
      from #invbds invbd
      where invbd.inv_b_d_num = #plh.pl_record_key_i AND
            invbd.trans_id  = (select max(trans_id) 
                               from #invbds invbd2
                               where invbd2.trans_id <= #plh.pl_trans_id AND
                                     invbd2.inv_num = invbd.inv_num AND
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
      trans_id            bigint null,
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
       trans_id                bigint null
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
        #plh plh
   where ti.trade_num = plh.pl_secondary_owner_key1 AND    
         ti.order_num = plh.pl_secondary_owner_key2 AND    
         ti.item_num = plh.pl_secondary_owner_key3 AND
         ti.trans_id <= plh.pl_trans_id
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
        #plh plh
   where ti.trade_num = plh.pl_secondary_owner_key1 AND    
         ti.order_num = plh.pl_secondary_owner_key2 AND    
         ti.item_num = plh.pl_secondary_owner_key3 AND
         ti.trans_id <= plh.pl_trans_id
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
          STEP: Updating ti_trans_id in #plh
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating ti_trans_id in #plh', getdate())
           
      update #plh
      set ti_trans_id = (select max(trans_id)
                         from #items ti    
                         where ti.trade_num = #plh.pl_secondary_owner_key1 AND    
                               ti.order_num = #plh.pl_secondary_owner_key2 AND    
                               ti.item_num = #plh.pl_secondary_owner_key3)
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
           #plh plh
      where tiwp.trade_num = plh.pl_secondary_owner_key1 AND    
            tiwp.order_num = plh.pl_secondary_owner_key2 AND    
            tiwp.item_num = plh.pl_secondary_owner_key3 AND
            tiwp.trans_id <= plh.pl_trans_id
      union
      select tiwp.trade_num,
             tiwp.order_num,
             tiwp.item_num,
             tiwp.del_date_from,
             tiwp.del_date_to,
             tiwp.del_loc_code, 
             tiwp.trans_id
      from dbo.aud_trade_item_wet_phy tiwp WITH (NOLOCK),
           #plh plh
      where tiwp.trade_num = plh.pl_secondary_owner_key1 AND    
            tiwp.order_num = plh.pl_secondary_owner_key2 AND    
            tiwp.item_num = plh.pl_secondary_owner_key3 AND
            tiwp.trans_id <= plh.pl_trans_id
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
         /* -----------------------------------------------
             STEP: Updating PHYSICAL-specific data in #plh
            ----------------------------------------------- */   
         select @stepid = @stepid + 1
         if @debugon = 1 
            insert into @times 
               (oid, step, starttime)
              values(@stepid, 'Updating PHYSICAL-specific data in #plh', getdate())
              
         update #plh
         set del_date_from = tiwp.del_date_from,
             del_date_to = tiwp.del_date_to,
             del_loc_code = tiwp.del_loc_code 
         from #tiwps tiwp,
              #plh plh
         where tiwp.trade_num = plh.pl_secondary_owner_key1 and
               tiwp.order_num = plh.pl_secondary_owner_key2 and
               tiwp.item_num = plh.pl_secondary_owner_key3 and
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
      pos_num          int null,
      commkt_key       int null,
      p_s_ind          char(1) null,
      trading_prd      char(8) null,
      trans_id         bigint null
   )

   insert into #tids
   select tid.dist_num,
          tid.trade_num,
          tid.order_num,
          tid.item_num,
          tid.pos_num,
          tid.commkt_key,
          tid.p_s_ind,
          tid.trading_prd,
          tid.trans_id
   from dbo.trade_item_dist tid WITH (NOLOCK),
        #plh plh
   where tid.dist_num = plh.pl_record_owner_key AND
         tid.trans_id <= plh.pl_trans_id
   union
   select tid.dist_num,
          tid.trade_num,
          tid.order_num,
          tid.item_num,
          tid.pos_num,
          tid.commkt_key,
          tid.p_s_ind,
          tid.trading_prd,
          tid.trans_id
   from dbo.aud_trade_item_dist tid WITH (NOLOCK),
        #plh plh
   where tid.dist_num = plh.pl_record_owner_key AND
         tid.trans_id <= plh.pl_trans_id
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
      /* ------------------------------------------------------------
          STEP: Updating dist_num, pos_num and commkt_key in #plh
         ------------------------------------------------------------ */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating dist_num, pos_num and commkt_key in #plh', getdate())
           
      update #plh
      set dist_num = tid1.dist_num,
          pos_num = tid1.pos_num,
          commkt_key = tid1.commkt_key,
          p_s_ind = tid1.p_s_ind,
          trading_prd = tid1.trading_prd
      from #tids tid1,
           #plh plh
      where tid1.dist_num = plh.pl_record_owner_key AND
            tid1.trans_id = (select max(trans_id)    
                             from #tids tid2 
                             where tid2.dist_num = tid1.dist_num)    
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
      plh.pl_secondary_owner_key1,
      plh.pl_secondary_owner_key2,
      plh.pl_secondary_owner_key3,
      plh.pl_real_port_num,
      plh.pl_primary_owner_key1,
      plh.pl_primary_owner_key2,
      convert(char(10), plh.pl_realization_date, 101) as pl_realization_date,
      plh.pl_mkt_price,
      plh.pl_record_qty,
      plh.pl_mkt_price_prev,
      plh.pl_amt_prev,
      plh.pl_record_qty_prev,
      plh.pl_trans_id,
      plh.inv_num,
      plh.inv_b_d_qty,
      plh.ti_trans_id,
      ti.trading_prd as ti_trading_prd,
      ti.contr_qty_uom_code,
      ti.price_uom_code,
      ti.cmdty_code,
      ti.risk_mkt_code,
      ti.booking_comp_num,
      ti.real_port_num as ti_real_port_num,
      ti.avg_price,
      ti.price_curr_code,
      plh.p_s_ind,
      ti.brkr_num,
      ti.brkr_comm_amt,
      ti.contr_qty,
      ti.formula_ind,
      plh.dist_num,
      plh.pos_num,
      plh.commkt_key,
      plh.counterparty,
      convert(char(10), plh.contr_date, 101) as contr_date,
      plh.inhouse_ind,
      convert(char(10), plh.del_date_from, 101) as del_date_from,
      convert(char(10), plh.del_date_to, 101) as del_date_to,
      plh.del_loc_code,
      plh.trading_prd as tid_trading_prd
   from #plh plh
           LEFT OUTER JOIN #items ti
              ON plh.pl_secondary_owner_key1 = ti.trade_num AND 
                 plh.pl_secondary_owner_key2 = ti.order_num AND 
                 plh.pl_secondary_owner_key3 = ti.item_num AND 
                 plh.ti_trans_id = ti.trans_id         
   order by pl_secondary_owner_key1,
            pl_secondary_owner_key2,
            pl_secondary_owner_key3
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
      select @smsg = 'usp_RVFile_inv_draw_history: ' + convert(varchar, @rows_affected) + ' rows returned.'
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
drop table #plh
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_inv_draw_history] TO [next_usr]
GO
