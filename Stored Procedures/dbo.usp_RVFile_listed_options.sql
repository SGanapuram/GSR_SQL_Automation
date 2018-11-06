SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_listed_options]
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
        @session_started   varchar(30),
        @session_ended     varchar(30),
        @my_pl_asof_date   datetime,
        @my_port_num       int

   select @session_started = convert(varchar, getdate(), 109),
          @my_pl_asof_date = @pl_asof_date,
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
      real_port_num            int,  
      pl_asof_date             datetime, 
      pl_owner_code            char(8), 
      pl_type                  char(8),    
      pl_secondary_owner_key1  int null,    
      pl_secondary_owner_key2  int null,    
      pl_secondary_owner_key3  int null,
      pl_record_key            int null,
      pl_amt                   float null,
      pl_mkt_price             float null,
      pl_trans_id              int null,
      dist_num                 int null,
      acct_num                 int null,
      contr_date               datetime null,
      inhouse_ind              char(1) null,
      ti_trans_id              int null,
      tid_trans_id             int null,
      tiexchopt_trans_id       int null,
      tiexchopt_exp_date       datetime null,
      dtid_dist_num            int null,
      dtid_trans_id            int null
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
      real_port_num,  
      pl_asof_date,
      pl_owner_code, 
      pl_type,    
      pl_secondary_owner_key1,    
      pl_secondary_owner_key2,    
      pl_secondary_owner_key3,
      pl_record_key,
      pl_amt,
      pl_mkt_price,
      pl_trans_id
   )
   select real_port_num,
          pl_asof_date,
          pl_owner_code, 
          pl_type,    
          pl_secondary_owner_key1,
          pl_secondary_owner_key2,
          pl_secondary_owner_key3,
          pl_record_key,
          pl_amt,
          pl_mkt_price,
          trans_id
   from dbo.pl_history plh WITH (NOLOCK)
   where pl_asof_date = @my_pl_asof_date AND 
         exists (select 1
                 from @port_num_list port
                 where plh.real_port_num = port.real_port_num) AND
         pl_owner_code = 'T' AND 
         pl_type = 'U' AND    
         pl_owner_sub_code = 'E' AND
         pl_secondary_owner_key1 is not null AND    
         pl_secondary_owner_key2 is not null AND    
         pl_secondary_owner_key3 is not null    
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

   create nonclustered index xx_plh_xx_idx2
      on #plh(dist_num)

   /* -----------------------------------------------
       STEP: Getting trade's related information
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
        #plh plh
   where t.trade_num = plh.pl_secondary_owner_key1 and
         t.trans_id = (select max(trans_id)
                       from dbo.trade t1 WITH (NOLOCK)
                       where t1.trade_num = plh.pl_secondary_owner_key1 and
                             t1.trans_id <= plh.pl_trans_id)
   union
   select t.trade_num,
          t.acct_num,
          t.contr_date,
          t.inhouse_ind,
          t.trans_id
   from dbo.aud_trade t WITH (NOLOCK),
        #plh plh
   where t.trade_num = plh.pl_secondary_owner_key1 and
         t.trans_id = (select max(trans_id)
                       from dbo.aud_trade t1 WITH (NOLOCK)
                       where t1.trade_num = plh.pl_secondary_owner_key1 and
                             t1.trans_id <= plh.pl_trans_id)
   select @rows_affected = @@rowcount
   if @debugon = 1 
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
   end
   
   create nonclustered index xx_878_trades_idx1
      on #trades(trade_num, trans_id)

   if @rows_affected > 0
   begin 
      /* --------------------------------------------------
          STEP: Getting acct_num and contr_date information
         -------------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
          values(@stepid, 'Updating acct_num, contr_date in #plh', getdate())
          
      update #plh
      set acct_num = t1.acct_num,
          contr_date = t1.contr_date,
          inhouse_ind = t1.inhouse_ind
      from #trades t1,
           #plh plh
      where t1.trade_num = plh.pl_secondary_owner_key1 and
            t1.trans_id = (select max(t2.trans_id) 
                           from #trades t2 
                           where t2.trade_num = t1.trade_num)   
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected
         where oid = @stepid
      end
   end
   -- We don't need to use the temporary table #trades any more, so drop it
   drop table #trades

   /* ----------------------------------------------------
       STEP: Getting trade_item's related information, if
             there are trade_item record(s) found, then
             get trade_item_exch_opt's related information.
      ---------------------------------------------------- */   
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
      item_type           char(1) null,
      trans_id            int null,
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
      commkt_key          int null,
      brkr_acct_full_name varchar(255) null,
      mkt_acct_full_name  varchar(255) null    
   )

   create table #item_exchopts
   (
       trade_num               int,
       order_num               smallint,
       item_num                smallint,
       exp_date                datetime NULL,
       put_call_ind            char(1) NULL,
       strike_price            float NULL,
       premium                 float NULL,
       premium_uom_code        varchar(4) NULL,
       premium_curr_code       varchar(8) NULL,
       strike_price_uom_code   varchar(4) NULL,
       strike_price_curr_code  varchar(8) NULL,
       trans_id                int NULL
   )
   
   insert into #items
   select ti.trade_num,
          ti.order_num,
          ti.item_num,
          ti.item_type,
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
          (select cm.commkt_key
           from dbo.commodity_market cm WITH (NOLOCK)
           where ti.cmdty_code = cm.cmdty_code AND
                 ti.risk_mkt_code = cm.mkt_code),         
          (select acc.acct_full_name
           from dbo.account acc WITH (NOLOCK)
           where ti.brkr_num = acc.acct_num),
          (select acc.acct_full_name
           from dbo.account acc WITH (NOLOCK)
           where ti.risk_mkt_code = acc.acct_short_name)
   from dbo.trade_item ti WITH (NOLOCK),
        #plh plh
   where ti.trade_num = plh.pl_secondary_owner_key1 AND    
         ti.order_num = plh.pl_secondary_owner_key2 AND    
         ti.item_num = plh.pl_secondary_owner_key3 AND
         ti.trans_id = (select max(trans_id)
                        from dbo.trade_item ti1 WITH (NOLOCK)
                        where ti1.trade_num = plh.pl_secondary_owner_key1 AND    
                              ti1.order_num = plh.pl_secondary_owner_key2 AND    
                              ti1.item_num = plh.pl_secondary_owner_key3 AND
                              ti1.trans_id <= plh.pl_trans_id)
   union
   select ti.trade_num,
          ti.order_num,
          ti.item_num,
          ti.item_type,
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
          (select cm.commkt_key
           from dbo.commodity_market cm WITH (NOLOCK)
           where ti.cmdty_code = cm.cmdty_code AND
                 ti.risk_mkt_code = cm.mkt_code),         
          (select acc.acct_full_name
           from dbo.account acc WITH (NOLOCK)
           where ti.brkr_num = acc.acct_num),
          (select acc.acct_full_name
           from dbo.account acc WITH (NOLOCK)
           where ti.risk_mkt_code = acc.acct_short_name)
   from dbo.aud_trade_item ti WITH (NOLOCK),
        #plh plh
   where ti.trade_num = plh.pl_secondary_owner_key1 AND    
         ti.order_num = plh.pl_secondary_owner_key2 AND    
         ti.item_num = plh.pl_secondary_owner_key3 AND
         ti.trans_id = (select max(trans_id)
                        from dbo.aud_trade_item ti1 WITH (NOLOCK)
                        where ti1.trade_num = plh.pl_secondary_owner_key1 AND    
                              ti1.order_num = plh.pl_secondary_owner_key2 AND    
                              ti1.item_num = plh.pl_secondary_owner_key3 AND
                              ti1.trans_id <= plh.pl_trans_id)
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

      /* ---------------------------------------------------------
          STEP: Getting trade_item_exch_opt's related information
         --------------------------------------------------------- */     
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Getting trade_item_exch_opt information', getdate())
           
      insert into #item_exchopts
      select exchopt.trade_num,
             exchopt.order_num,
             exchopt.item_num,
             exchopt.exp_date,
             exchopt.put_call_ind,
             exchopt.strike_price,
             exchopt.premium,
             exchopt.premium_uom_code,
             exchopt.premium_curr_code,
             exchopt.strike_price_uom_code,
             exchopt.strike_price_curr_code,
             exchopt.trans_id
      from dbo.trade_item_exch_opt exchopt WITH (NOLOCK),
           #plh plh
      where exchopt.trade_num = plh.pl_secondary_owner_key1 AND    
            exchopt.order_num = plh.pl_secondary_owner_key2 AND    
            exchopt.item_num = plh.pl_secondary_owner_key3 AND
            exchopt.trans_id = (select max(trans_id)
                                from dbo.trade_item_exch_opt exchopt1 WITH (NOLOCK)
                                where exchopt1.trade_num = plh.pl_secondary_owner_key1 AND    
                                      exchopt1.order_num = plh.pl_secondary_owner_key2 AND    
                                      exchopt1.item_num = plh.pl_secondary_owner_key3 AND
                                      exchopt1.trans_id <= plh.pl_trans_id) 
      union
      select exchopt.trade_num,
             exchopt.order_num,
             exchopt.item_num,
             exchopt.exp_date,
             exchopt.put_call_ind,
             exchopt.strike_price,
             exchopt.premium,
             exchopt.premium_uom_code,
             exchopt.premium_curr_code,
             exchopt.strike_price_uom_code,
             exchopt.strike_price_curr_code,
             exchopt.trans_id
      from dbo.aud_trade_item_exch_opt exchopt WITH (NOLOCK),
           #plh plh
      where exchopt.trade_num = plh.pl_secondary_owner_key1 AND    
            exchopt.order_num = plh.pl_secondary_owner_key2 AND    
            exchopt.item_num = plh.pl_secondary_owner_key3 AND
            exchopt.trans_id = (select max(trans_id)
                                from dbo.aud_trade_item_exch_opt exchopt1 WITH (NOLOCK)
                                where exchopt1.trade_num = plh.pl_secondary_owner_key1 AND    
                                      exchopt1.order_num = plh.pl_secondary_owner_key2 AND    
                                      exchopt1.item_num = plh.pl_secondary_owner_key3 AND
                                      exchopt1.trans_id <= plh.pl_trans_id) 
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected 
         where oid = @stepid
      end
      
      create nonclustered index xx_878_exchopts_idx1
         on #item_exchopts(trade_num, order_num, item_num, trans_id)

      if @rows_affected > 0
      begin
         /* -----------------------------------------------
             STEP: Updating tiexchopt_trans_id in #plh
            ----------------------------------------------- */   
         select @stepid = @stepid + 1
         if @debugon = 1 
            insert into @times 
               (oid, step, starttime)
              values(@stepid, 'Updating tiexchopt_trans_id in #plh', getdate())
              
         update #plh
         set tiexchopt_trans_id = (select max(trans_id)
                                   from #item_exchopts exchopt    
                                   where exchopt.trade_num = #plh.pl_secondary_owner_key1 AND    
                                         exchopt.order_num = #plh.pl_secondary_owner_key2 AND    
                                         exchopt.item_num = #plh.pl_secondary_owner_key3)
         select @rows_affected = @@rowcount
         if @debugon = 1
         begin
            update @times
            set endtime = getdate(),
                rows_affected = @rows_affected 
            where oid = @stepid
         end

         /* -----------------------------------------------
             STEP: Updating tiexchopt_exp_date in #plh
            ----------------------------------------------- */   
         select @stepid = @stepid + 1
         if @debugon = 1 
            insert into @times 
               (oid, step, starttime)
              values(@stepid, 'Updating tiexchopt_exp_date in #plh', getdate())
              
         update #plh
         set tiexchopt_exp_date = (select exp_date
                                   from #item_exchopts exchopt
                                   where exchopt.trade_num = #plh.pl_secondary_owner_key1 AND    
                                         exchopt.order_num = #plh.pl_secondary_owner_key2 AND    
                                         exchopt.item_num = #plh.pl_secondary_owner_key3 AND
                                         exchopt.trans_id = #plh.tiexchopt_trans_id)
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
      dist_type        char(2) null,
      dist_qty         float null,
      is_equiv_ind     char(1) null,
      p_s_ind          char(1) null,
      real_port_num    int null,
      pos_num          int null,
      commkt_key       int null,
      trans_id         int null
   )

   insert into #tids
   select tid.dist_num,
          tid.trade_num,
          tid.order_num,
          tid.item_num,
          tid.dist_type,
          tid.dist_qty,
          tid.is_equiv_ind,
          tid.p_s_ind,
          tid.real_port_num,
          tid.pos_num,
          tid.commkt_key,
          tid.trans_id
   from dbo.trade_item_dist tid WITH (NOLOCK),
        #plh plh
   where tid.trade_num = plh.pl_secondary_owner_key1 AND
         tid.order_num = plh.pl_secondary_owner_key2 AND
         tid.item_num = plh.pl_secondary_owner_key3 AND
         tid.is_equiv_ind = 'Y' AND  
         tid.real_port_num = plh.real_port_num AND 
         tid.trans_id = (select max(trans_id)
                         from dbo.trade_item_dist tid1 WITH (NOLOCK)
                         where tid1.trade_num = plh.pl_secondary_owner_key1 AND
                               tid1.order_num = plh.pl_secondary_owner_key2 AND
                               tid1.item_num = plh.pl_secondary_owner_key3 AND
                               tid1.is_equiv_ind = 'Y' AND  
                               tid1.real_port_num = plh.real_port_num AND 
                               tid1.trans_id <= plh.pl_trans_id)
   union
   select tid.dist_num,
          tid.trade_num,
          tid.order_num,
          tid.item_num,
          tid.dist_type,
          tid.dist_qty,
          tid.is_equiv_ind,
          tid.p_s_ind,
          tid.real_port_num,
          tid.pos_num,
          tid.commkt_key,
          tid.trans_id
   from dbo.aud_trade_item_dist tid WITH (NOLOCK),
        #plh plh
   where tid.trade_num = plh.pl_secondary_owner_key1 AND
         tid.order_num = plh.pl_secondary_owner_key2 AND
         tid.item_num = plh.pl_secondary_owner_key3 AND
         tid.is_equiv_ind = 'Y' AND  
         tid.real_port_num = plh.real_port_num AND 
         tid.trans_id = (select max(trans_id)
                         from dbo.aud_trade_item_dist tid1 WITH (NOLOCK)
                         where tid1.trade_num = plh.pl_secondary_owner_key1 AND
                               tid1.order_num = plh.pl_secondary_owner_key2 AND
                               tid1.item_num = plh.pl_secondary_owner_key3 AND
                               tid1.is_equiv_ind = 'Y' AND  
                               tid1.real_port_num = plh.real_port_num AND 
                               tid1.trans_id <= plh.pl_trans_id)
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
          STEP: Updating dist_num and tid_trans_id in #plh
         -------------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating dist_num and tid_trans_id in #plh', getdate())
           
      update #plh
      set dist_num = tid1.dist_num,
          tid_trans_id = tid1.trans_id
      from #tids tid1,
           #plh plh
      where tid1.trade_num = plh.pl_secondary_owner_key1 AND
            tid1.order_num = plh.pl_secondary_owner_key2 AND
            tid1.item_num = plh.pl_secondary_owner_key3 AND
            tid1.is_equiv_ind = 'Y' AND  
            tid1.real_port_num = plh.real_port_num AND 
            tid1.trans_id = (select max(tid2.trans_id)    
                             from #tids tid2 
                             where tid2.trade_num = tid1.trade_num AND
                                   tid2.order_num = tid1.order_num AND
                                   tid2.item_num = tid1.item_num AND
                                   tid2.is_equiv_ind = tid1.is_equiv_ind AND  
                                   tid2.real_port_num = tid1.real_port_num)    
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected
         where oid = @stepid
      end
   end

   /* ------------------------------------------------------------
       STEP: Getting dtid - trade_item_dist's related information
      ------------------------------------------------------------ */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Getting trade_item_dist (D) information', getdate())
        
   create table #dtids
   (
      dist_num         int,
      trade_num        int null,
      order_num        smallint null,
      item_num         smallint null,
      dist_type        char(2) null,
      dist_qty         float null,
      is_equiv_ind     char(1) null,
      p_s_ind          char(1) null,
      real_port_num    int null,
      pos_num          int null,
      commkt_key       int null,
      trading_prd      char(8) null,
      trans_id         int null
   )

   insert into #dtids
   select tid.dist_num,
          tid.trade_num,
          tid.order_num,
          tid.item_num,
          tid.dist_type,
          tid.dist_qty,
          tid.is_equiv_ind,
          tid.p_s_ind,
          tid.real_port_num,
          tid.pos_num,
          tid.commkt_key,
          tid.trading_prd,
          tid.trans_id
   from dbo.trade_item_dist tid WITH (NOLOCK),
        #plh plh
   where tid.dist_num = plh.pl_record_key AND 
         tid.trans_id = (select max(trans_id)
                         from dbo.trade_item_dist tid1 WITH (NOLOCK)
                         where tid1.dist_num= plh.pl_record_key AND 
                               tid1.trans_id <= plh.pl_trans_id)
   union
   select tid.dist_num,
          tid.trade_num,
          tid.order_num,
          tid.item_num,
          tid.dist_type,
          tid.dist_qty,
          tid.is_equiv_ind,
          tid.p_s_ind,
          tid.real_port_num,
          tid.pos_num,
          tid.commkt_key,
          tid.trading_prd,
          tid.trans_id
   from dbo.aud_trade_item_dist tid WITH (NOLOCK),
        #plh plh
   where tid.dist_num = plh.pl_record_key AND 
         tid.trans_id = (select max(trans_id)
                         from dbo.aud_trade_item_dist tid1 WITH (NOLOCK)
                         where tid1.dist_num= plh.pl_record_key AND 
                               tid1.trans_id <= plh.pl_trans_id)
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
   end

   create nonclustered index xx_878_tids_idx1
       on #dtids(trade_num, order_num, item_num, trans_id)
   create nonclustered index xx_878_tids_idx2
       on #dtids(dist_num, trans_id)

   -- If the trade has associated distributions, then get dist_nums
   if @rows_affected > 0
   begin
      /* ---------------------------------------------------------
          STEP: Updating dtid - dist_num and tid_trans_id in #plh
         --------------------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating dist_num and tid_trans_id in #plh', getdate())
           
      update #plh
      set dtid_dist_num = tid1.dist_num,
          dtid_trans_id = tid1.trans_id
      from #dtids tid1,
           #plh plh
      where tid1.dist_num = plh.pl_record_key  AND 
            tid1.trans_id = (select max(tid2.trans_id)    
                             from #dtids tid2 
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

   create nonclustered index xx_plh_xx_idx3
      on #plh(pl_secondary_owner_key1,
              pl_secondary_owner_key2,
              pl_secondary_owner_key3,
              ti_trans_id)

   create nonclustered index xx_plh_xx_idx4
      on #plh(pl_secondary_owner_key1,
              pl_secondary_owner_key2,
              pl_secondary_owner_key3,
              tiexchopt_trans_id)

   create nonclustered index xx_plh_xx_idx5
      on #plh(dist_num,
              tid_trans_id)

   create nonclustered index xx_plh_xx_idx6
      on #plh(dtid_dist_num,
              dtid_trans_id)

   /* -----------------------------------------------
       STEP: Returns data back to caller
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Return result set', getdate())

   select distinct 
       plh.pl_record_key,
       plh.pl_owner_code,
       plh.pl_type, 
       plh.pl_amt,
       ti.item_type,
       plh.pl_secondary_owner_key1,
       plh.pl_secondary_owner_key2,
       plh.pl_secondary_owner_key3,
       plh.pl_mkt_price,
       plh.pl_trans_id,
       ti.trans_id as ti_trans_id,
       ti.trading_prd as ti_trading_prd,
       dtid.dist_num as dist_num_dtid,
       dtid.dist_type,
       dtid.dist_qty as dist_qty_tid,
       dtid.is_equiv_ind,
       dtid.p_s_ind,
       plh.acct_num as counterparty,
       convert(char(10), plh.contr_date, 101) as contr_date,
       plh.inhouse_ind,
       tid.real_port_num as tid_real_port_num,
       ti.real_port_num as ti_real_port_num,
       ti.avg_price,
       ti.cmdty_code,
       ti.contr_qty_uom_code,
       ti.risk_mkt_code,
       ti.price_uom_code,
       ti.booking_comp_num,
       datediff(dd, @my_pl_asof_date, plh.tiexchopt_exp_date) as offset,
       tiexchopt.put_call_ind,
       tiexchopt.strike_price,
       tiexchopt.premium,
       tiexchopt.premium_uom_code,
       tiexchopt.premium_curr_code,
       tiexchopt.strike_price_uom_code,
       tiexchopt.strike_price_curr_code,
       ti.price_curr_code,
       dtid.commkt_key,
       convert(char(10), plh.tiexchopt_exp_date, 101) as exp_date,
       convert(char(10), tidmtmold.mtm_pl_asof_date,101) as mtm_pl_asof_date_prev,
       convert(char(10), tidmtm.mtm_pl_asof_date, 101) as mtm_pl_asof_date,
       tidmtmold.discount_factor as discount_factor_prev,
       tidmtm.discount_factor,
       tidmtmold.trade_value as trade_value_prev,
       tidmtm.trade_value,
       tidmtmold.alloc_qty as alloc_qty_prev,
       tidmtm.alloc_qty,
       tidmtmold.dist_qty as dist_qty_prev,
       tidmtm.dist_qty,
       tidmtmold.market_value as market_value_prev,
       tidmtm.market_value,
       tidmtmold.curr_conv_rate as curr_conv_rate_prev,
       tidmtm.curr_conv_rate,
       tidmtmold.qty_uom_code as qty_uom_code_prev, 
       tidmtm.qty_uom_code, 
       tidmtmold.curr_code as curr_code_prev,
       tidmtm.open_pl,       
       ti.brkr_num,
       ti.brkr_comm_amt,
       tidmtm.addl_cost_sum,
       ti.contr_qty,
       tidmtm.trade_modified_ind,
       dtid.pos_num,
       ti.brkr_acct_full_name,
       ti.mkt_acct_full_name,
       plh.dist_num,
       dtid.trading_prd as tid_trading_prd      
   from #plh plh
           INNER JOIN #items ti
              ON ti.trade_num = plh.pl_secondary_owner_key1 AND 
                 ti.order_num = plh.pl_secondary_owner_key2 AND 
                 ti.item_num = plh.pl_secondary_owner_key3 AND 
                 ti.trans_id = plh_ti_trans_id
           LEFT OUTER JOIN #item_exchopts
              ON plh.pl_secondary_owner_key1 = tiexchopt.trade_num AND 
                 plh.pl_secondary_owner_key2 = tiexchopt.order_num AND 
                 plh.pl_secondary_owner_key3 = tiexchopt.item_num AND 
                 plh.tiexchopt_trans_id = tiexchopt.trans_id
           LEFT OUTER JOIN #tids tid
              ON plh.dist_num = tid.dist_num and 
                 plh.tid_trans_id = tid.trans_id
           LEFT OUTER JOIN #dtids dtid
              ON plh.dtid_dist_num = dtid.dist_num AND 
                 plh.dtid_trans_id = dtid.trans_id
           LEFT OUTER JOIN dbo.tid_mark_to_market tidmtmm WITH (NOLOCK)
              ON plh.pl_record_key = tidmtm.dist_num AND 
                 tidmtm.mtm_pl_asof_date = @my_pl_asof_date
           LEFT OUTER JOIN dbo.tid_mark_to_market tidmtmold WITH (NOLOCK)
              ON plh.pl_record_key = tidmtmold.dist_num AND 
                 tidmtmold.mtm_pl_asof_date = (select max(mtm_pl_asof_date)
                                               from dbo.tid_mark_to_market tidmtmold2 WITH (NOLOCK)
                                               where tidmtmold2.dist_num = plh.pl_record_key and 
                                                     tidmtmold2.mtm_pl_asof_date < @my_pl_asof_date)
   ORDER BY pl_record_key,
            pl_secondary_owner_key1,
            pl_secondary_owner_key2,
            pl_secondary_owner_key3,
            plh.dist_num DESC
   select @rows_affected = @@rowcount

   if @debugon = 1
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
      print ' '
      select @smsg = 'usp_RVFile_listed_options: ' + convert(varchar, @rows_affected) + ' rows returned.'
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
      end 

      select @session_ended = convert(varchar, getdate(), 109)
      print ' '
      select @smsg = 'SESSION STARTED  AT     : ' + @session_started
      print @smsg       
      select @smsg = '        FINISHED AT     : ' + @session_ended
      print @smsg
   end
   drop table #items
   drop table #item_exchopts
   drop table #tids

endofsp:
drop table #plh
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_listed_options] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_RVFile_listed_options', NULL, NULL
GO
