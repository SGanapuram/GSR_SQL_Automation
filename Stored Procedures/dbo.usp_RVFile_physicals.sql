SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_physicals]
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
      pl_record_key            int null,
      real_port_num            int,  
      pl_asof_date             datetime, 
      pl_owner_code            char(8), 
      pl_type                  char(8),    
      pl_amt                   float null,
      pl_record_qty            numeric(20,8) null,
      pl_secondary_owner_key1  int null,    
      pl_secondary_owner_key2  int null,    
      pl_secondary_owner_key3  int null,
      pl_mkt_price             float null,
      pl_trans_id              bigint null,
      pl_record_owner_key      int null,
      pl_amt_prev              float null,
      pl_record_qty_prev       numeric(20,8) null,
      pl_mkt_price_prev        float null,
      acct_num                 int null,
      contr_date               datetime null,
      inhouse_ind              char(1) null,
      ti_trans_id              bigint null,
      tid_trans_id             bigint null,
      cost_trans_id            bigint null,
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
      real_port_num,  
      pl_asof_date,
      pl_owner_code, 
      pl_type,    
      pl_amt,
      pl_record_qty,
      pl_secondary_owner_key1,    
      pl_secondary_owner_key2,    
      pl_secondary_owner_key3,
      pl_mkt_price,
      pl_trans_id,
      pl_record_owner_key
   )
   select plh.pl_record_key,
          plh.real_port_num,
          plh.pl_asof_date,
          plh.pl_owner_code, 
          plh.pl_type,    
          plh.pl_amt,
          plh.pl_record_qty,
          plh.pl_secondary_owner_key1,
          plh.pl_secondary_owner_key2,
          plh.pl_secondary_owner_key3,
          plh.pl_mkt_price,
          plh.trans_id,
          plh.pl_record_owner_key          
   from dbo.pl_history plh WITH (NOLOCK)
   where plh.pl_asof_date = @my_pl_asof_date AND 
         exists (select 1
                 from @port_num_list port
                 where plh.real_port_num = port.real_port_num) AND
         (plh.pl_owner_code = 'C' AND 
          plh.pl_owner_sub_code in ('WPP', 'BOAI', 'NO')) AND 
         plh.pl_secondary_owner_key1 is not null AND    
         plh.pl_secondary_owner_key2 is not null AND    
         plh.pl_secondary_owner_key3 is not null
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
      on #plh(pl_record_key, pl_owner_code, pl_type)

   /* -----------------------------------------------
       STEP: Getting pl_amt, pl_record_qty and 
             pl_mkt_price for the previous pl_history 
             record
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Getting prev. PLH pl_amt, pl_record_qty and pl_mkt_price', getdate())

   update #plh
   set pl_amt_prev = plhold1.pl_amt,
       pl_record_qty_prev = plhold1.pl_record_qty,
       pl_mkt_price_prev = plhold1.pl_mkt_price
   from dbo.pl_history plhold1 WITH (NOLOCK)
   where #plh.pl_record_key = plhold1.pl_record_key AND
         #plh.pl_owner_code = plhold1.pl_owner_code AND
         #plh.pl_type = plhold1.pl_type AND
         plhold1.pl_asof_date = (select max(pl_asof_date) 
                                 from dbo.pl_history plhold2 WITH (NOLOCK)
                                 where plhold2.pl_record_key = plhold1.pl_record_key AND 
                                       plhold2.pl_owner_code = plhold1.pl_owner_code AND 
                                       plhold2.pl_type = plhold1.pl_type and 
                                       plhold2.pl_asof_date  < @my_pl_asof_date)
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
   create nonclustered index xx_878_trades_idx1
      on #trades(trade_num, trans_id)

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
   if @rows_affected <= 0
   begin
      if @debugon = 1 
      begin
         print 'No trade records found!'
      end
      drop table #trades
      goto endofsp
   end

   /* --------------------------------------------------
       STEP: Getting acct_num and contr_date information
      -------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
          (oid, step, starttime)
        values(@stepid, 'Updating (trade) acct_num, contr_date in #plh', getdate())
        
   update #plh
   set acct_num = t.acct_num,
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
      pooling_port_num    int null,
      pooling_type        char(1) null,
      avg_price           float null,
      cmdty_code          varchar(8) null,
      risk_mkt_code       varchar(8) null,
      booking_comp_num    int null,
      p_s_ind             char(1) null,
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
	        ti.pooling_port_num,
          ti.pooling_type,
          ti.avg_price,
          ti.cmdty_code,
          ti.risk_mkt_code,
          ti.booking_comp_num,
          ti.p_s_ind,
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
          ti.trans_id,
          ti.trading_prd,
          ti.contr_qty_uom_code,
          ti.price_uom_code,
          ti.real_port_num,
	        ti.pooling_port_num,
          ti.pooling_type,
          ti.avg_price,
          ti.cmdty_code,
          ti.risk_mkt_code,
          ti.booking_comp_num,
          ti.p_s_ind,
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
            tiwp.trans_id = (select max(trans_id)
                             from dbo.trade_item_wet_phy tiwp1 WITH (NOLOCK)
                             where tiwp1.trade_num = plh.pl_secondary_owner_key1 AND    
                                   tiwp1.order_num = plh.pl_secondary_owner_key2 AND    
                                   tiwp1.item_num = plh.pl_secondary_owner_key3 AND
                                   tiwp1.trans_id <= plh.pl_trans_id)
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
            tiwp.trans_id = (select max(trans_id)
                             from dbo.aud_trade_item_wet_phy tiwp1 WITH (NOLOCK)
                             where tiwp1.trade_num = plh.pl_secondary_owner_key1 AND    
                                   tiwp1.order_num = plh.pl_secondary_owner_key2 AND    
                                   tiwp1.item_num = plh.pl_secondary_owner_key3 AND
                                   tiwp1.trans_id <= plh.pl_trans_id)
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
      dist_type        char(2) null,
      dist_qty         numeric(20, 8) null,
      alloc_qty        numeric(20, 8) null,
      priced_qty       float null,
      is_equiv_ind     char(1) null,
      p_s_ind          char(1) null,
      real_port_num    int null,
      pos_num          int null,
      commkt_key       int null,
      trading_prd      char(8) null,
      trans_id         bigint null
   )

   insert into #tids
   select tid.dist_num,
          tid.trade_num,
          tid.order_num,
          tid.item_num,
          tid.dist_type,
          tid.dist_qty,
          tid.alloc_qty,
          tid.priced_qty,
          tid.is_equiv_ind,
          tid.p_s_ind,
          tid.real_port_num,
          tid.pos_num,
          tid.commkt_key,
          tid.trading_prd,
          tid.trans_id
   from dbo.trade_item_dist tid WITH (NOLOCK),
        #plh plh
   where tid.dist_num = plh.pl_record_owner_key AND
         tid.trans_id = (select max(trans_id)
                         from dbo.trade_item_dist tid1 WITH (NOLOCK)
                         where tid1.dist_num = plh.pl_record_owner_key AND
                               tid1.trans_id <= plh.pl_trans_id)
   union
   select tid.dist_num,
          tid.trade_num,
          tid.order_num,
          tid.item_num,
          tid.dist_type,
          tid.dist_qty,
          tid.alloc_qty,
          tid.priced_qty,
          tid.is_equiv_ind,
          tid.p_s_ind,
          tid.real_port_num,
          tid.pos_num,
          tid.commkt_key,
          tid.trading_prd,
          tid.trans_id
   from dbo.aud_trade_item_dist tid WITH (NOLOCK),
        #plh plh
   where tid.dist_num = plh.pl_record_owner_key AND
         tid.trans_id = (select max(trans_id)
                         from dbo.aud_trade_item_dist tid1 WITH (NOLOCK)
                         where tid1.dist_num = plh.pl_record_owner_key AND
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
      /* -----------------------------------------------
          STEP: Updating tid_trans_id in #plh
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating tid_trans_id in #plh', getdate())
           
      update #plh
      set tid_trans_id = tid1.trans_id
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

   /* -------------------------------------------------
       STEP: Getting cost information
      ------------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1 
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Getting cost information', getdate())

   create table #costs
   (
      cost_num                   int,
      cost_owner_code            char(2) null,
      cost_status                varchar(8) null,
      cost_type_code             char(8) null,
      cost_pay_rec_ind           char(1) null,
      cost_price_uom_code        char(4) null,
      cost_qty                   float null,
      cost_unit_price            float null,
      cost_amt                   float null,
      cost_owner_key1            int null,
      cost_owner_key2            int null,
      cost_owner_key3            int null,
      cost_due_date              datetime null,
      cost_eff_date              datetime null,
      cost_pl_code               char(1) null,
      cost_est_final_ind         char(1) null,
      cost_qty_est_actual_ind    char(1) null,
      cost_price_est_actual_ind  char(1) null,
      ai_est_actual_date         datetime null,
      deemed_bl_date             datetime null,
      title_tran_date            datetime null,
      nomin_date_from  		       datetime null,  
      nomin_date_to      	       datetime null,  
      trans_id                   bigint null,
      pl_trans_id                bigint null
   )

   insert into #costs
   select c.cost_num,
          c.cost_owner_code,
          c.cost_status,
	        c.cost_type_code,
	        c.cost_pay_rec_ind,
          c.cost_price_uom_code,
          c.cost_qty,
          c.cost_unit_price,
          c.cost_amt,
          c.cost_owner_key1,
          c.cost_owner_key2,
          c.cost_owner_key3,
          c.cost_due_date,
          c.cost_eff_date,
	        c.cost_pl_code,
	        c.cost_est_final_ind,
          c.cost_qty_est_actual_ind,
          c.cost_price_est_actual_ind,
          null,   /* ai_est_actual_date */
          null,   /* deemed_bl_date */
          null,   /* title_tran_date */
          null,   /* nomin_date_from */  
          null,   /* nomin_date_to */  
          c.trans_id,
          plh.pl_trans_id
   from dbo.cost c WITH (NOLOCK),
        #plh plh
   where c.cost_num = plh.pl_record_key AND    
         c.cost_status in ('OPEN','VOUCHED','HELD','PAID') AND
         c.cost_type_code in ('WPP', 'BOAI', 'NO') AND
         c.trans_id = (select max(trans_id)
                       from dbo.cost c1 WITH (NOLOCK)
                       where c1.cost_num = plh.pl_record_key AND    
                             c1.cost_status in ('OPEN','VOUCHED','HELD','PAID') AND
                             c1.cost_type_code in ('WPP', 'BOAI', 'NO') AND
                             c1.trans_id <= plh.pl_trans_id)
   union
   select c.cost_num,
          c.cost_owner_code,
          c.cost_status,
	  c.cost_type_code,
	  c.cost_pay_rec_ind,
          c.cost_price_uom_code,
          c.cost_qty,
          c.cost_unit_price,
          c.cost_amt,
          c.cost_owner_key1,
          c.cost_owner_key2,
          c.cost_owner_key3,
          c.cost_due_date,
          c.cost_eff_date,
	        c.cost_pl_code,
	        c.cost_est_final_ind,
          c.cost_qty_est_actual_ind,
          c.cost_price_est_actual_ind,
          null,   /* ai_est_actual_date */
          null,   /* deemed_bl_date */
          null,   /* title_tran_date */
          null,   /* nomin_date_from */  
          null,   /* nomin_date_to */  
          c.trans_id,
          plh.pl_trans_id
   from aud_cost c WITH (NOLOCK),
        #plh plh
   where c.cost_num = plh.pl_record_key AND    
         c.cost_status in ('OPEN','VOUCHED','HELD','PAID') AND
         c.cost_type_code in ('WPP', 'BOAI', 'NO') AND
         c.trans_id = (select max(trans_id)
                       from aud_cost c1 WITH (NOLOCK)
                       where c1.cost_num = plh.pl_record_key AND    
                             c1.cost_status in ('OPEN','VOUCHED','HELD','PAID') AND
                             c1.cost_type_code in ('WPP', 'BOAI', 'NO') AND
                             c1.trans_id <= plh.pl_trans_id)
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected 
      where oid = @stepid
   end
   
   create nonclustered index xx_878_costs_idx1
      on #costs(cost_num, trans_id)
   create nonclustered index xx_878_costs_idx2
      on #costs(cost_owner_key1, cost_owner_key2, cost_owner_key3)

   if @rows_affected > 0
   begin
      /* -----------------------------------------------
          STEP: Updating cost_trans_id in #plh
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Updating cost_trans_id in #plh', getdate())
           
      update #plh
      set cost_trans_id = c1.trans_id
      from #costs c1,
           #plh plh
      where c1.cost_num = plh.pl_record_key AND
            c1.trans_id = (select max(trans_id)    
                           from #costs c2 
                           where c2.cost_num = c1.cost_num)    
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected
         where oid = @stepid
      end

      /* -----------------------------------------------
          STEP: Getting ai_est_actual_date for cost
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Getting ai_est_actual_date for cost', getdate())

      create table #aiests
      (
         alloc_num               int null,
         alloc_item_num          smallint null,
         ai_est_actual_num       smallint null,
         ai_est_actual_date      datetime null,
         trans_id                bigint null
      )

      insert into #aiests
      select aiest.alloc_num,
             aiest.alloc_item_num,
             aiest.ai_est_actual_num,
             aiest.ai_est_actual_date,
             aiest.trans_id
      from dbo.ai_est_actual aiest WITH (NOLOCK),
           #costs c
      where aiest.alloc_num = c.cost_owner_key1 AND    
            aiest.alloc_item_num = c.cost_owner_key2 AND 
            aiest.ai_est_actual_num = c.cost_owner_key3 AND 
            aiest.trans_id = (select max(trans_id)
                              from dbo.ai_est_actual aiest1 WITH (NOLOCK)
                              where aiest1.alloc_num = c.cost_owner_key1 AND    
                                    aiest1.alloc_item_num = c.cost_owner_key2 AND 
                                    aiest1.ai_est_actual_num = c.cost_owner_key3 AND 
                                    aiest1.trans_id <= c.pl_trans_id)
      union
      select aiest.alloc_num,
             aiest.alloc_item_num,
             aiest.ai_est_actual_num,
             aiest.ai_est_actual_date,
             aiest.trans_id
      from dbo.aud_ai_est_actual aiest WITH (NOLOCK),
           #costs c
      where aiest.alloc_num = c.cost_owner_key1 AND    
            aiest.alloc_item_num = c.cost_owner_key2 AND 
            aiest.ai_est_actual_num = c.cost_owner_key3 AND 
            aiest.trans_id = (select max(trans_id)
                              from dbo.aud_ai_est_actual aiest1 WITH (NOLOCK)
                              where aiest1.alloc_num = c.cost_owner_key1 AND    
                                    aiest1.alloc_item_num = c.cost_owner_key2 AND 
                                    aiest1.ai_est_actual_num = c.cost_owner_key3 AND 
                                    aiest1.trans_id <= c.pl_trans_id)
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected 
         where oid = @stepid
      end

      create nonclustered index xx_878_aiests_idx1
         on #aiests(alloc_num, alloc_item_num, ai_est_actual_num, trans_id)

      if @rows_affected > 0
      begin
         /* -----------------------------------------------
             STEP: Updating ai_est_actual_date in #costs
            ----------------------------------------------- */   
         select @stepid = @stepid + 1
         if @debugon = 1 
            insert into @times 
               (oid, step, starttime)
              values(@stepid, 'Updating ai_est_actual_date in #costs', getdate())
              
         update #costs
         set ai_est_actual_date = aiest1.ai_est_actual_date
         from #costs c,
              #aiests aiest1
         where aiest1.alloc_num = c.cost_owner_key1  AND    
               aiest1.alloc_item_num = c.cost_owner_key2 AND 
               aiest1.ai_est_actual_num = c.cost_owner_key3 AND 
               aiest1.trans_id = (select max(trans_id)    
                                  from #aiests aiest2 
                                  where aiest2.alloc_num = aiest1.alloc_num AND
                                        aiest2.alloc_item_num = aiest1.alloc_item_num AND
                                        aiest2.ai_est_actual_num = aiest1.ai_est_actual_num)    
         select @rows_affected = @@rowcount
         if @debugon = 1
         begin
            update @times
            set endtime = getdate(),
                rows_affected = @rows_affected
            where oid = @stepid
         end
      end
      drop table #aiests

      /* -----------------------------------------------
          STEP: Getting deemed_bl_date for cost
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Getting deemed_bl_date for cost', getdate())

      create table #allocation
      (
         alloc_num               int null,
         deemed_bl_date          datetime null,
         trans_id                bigint null
      )

      insert into #allocation
      select alloc.alloc_num,
             alloc.deemed_bl_date,
             alloc.trans_id
      from dbo.allocation alloc WITH (NOLOCK),
           #costs c
      where alloc.alloc_num = c.cost_owner_key1 AND    
            alloc.trans_id = (select max(trans_id)
                              from dbo.allocation alloc1 WITH (NOLOCK)
                              where alloc1.alloc_num = c.cost_owner_key1 AND    
                                    alloc1.trans_id <= c.pl_trans_id)
      union
      select alloc.alloc_num,
             alloc.deemed_bl_date,
             alloc.trans_id
      from dbo.aud_allocation alloc WITH (NOLOCK),
           #costs c
      where alloc.alloc_num = c.cost_owner_key1 AND    
            alloc.trans_id = (select max(trans_id)
                              from dbo.aud_allocation alloc1 WITH (NOLOCK)
                              where alloc1.alloc_num = c.cost_owner_key1 AND    
                                    alloc1.trans_id <= c.pl_trans_id)
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected 
         where oid = @stepid
      end

      create nonclustered index xx_878_allocation_idx1
         on #allocation(alloc_num, trans_id)

      if @rows_affected > 0
      begin
         /* -----------------------------------------------
             STEP: Updating deemed_bl_date in #costs
            ----------------------------------------------- */   
         select @stepid = @stepid + 1
         if @debugon = 1 
            insert into @times 
               (oid, step, starttime)
              values(@stepid, 'Updating deemed_bl_date in #costs', getdate())
              
         update #costs
         set deemed_bl_date = alloc1.deemed_bl_date
         from #costs c,
              #allocation alloc1
         where alloc1.alloc_num = c.cost_owner_key1  AND    
               alloc1.trans_id = (select max(trans_id)    
                                  from #allocation alloc2 
                                  where alloc2.alloc_num = alloc1.alloc_num)    
         select @rows_affected = @@rowcount
         if @debugon = 1
         begin
            update @times
            set endtime = getdate(),
                rows_affected = @rows_affected
            where oid = @stepid
         end
      end
      drop table #allocation

      /* -----------------------------------------------
          STEP: Getting title_tran_date for cost
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1 
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Getting title_tran_date for cost', getdate())

      create table #allocationItems
      (
         alloc_num               int null,
         alloc_item_num          smallint null,
         title_tran_date   	   datetime null,
         nomin_date_from         datetime null,  
         nomin_date_to    	   datetime null,  
         trans_id                bigint null
      )

      insert into #allocationItems
      select ai.alloc_num,
             ai.alloc_item_num,
             ai.title_tran_date,
		         ai.nomin_date_from,
		         ai.nomin_date_to,
             ai.trans_id
      from dbo.allocation_item ai WITH (NOLOCK),
           #costs c
      where ai.alloc_num = c.cost_owner_key1 AND    
            ai.alloc_item_num = c.cost_owner_key2 AND 
            ai.trans_id = (select max(trans_id)
                              from dbo.allocation_item ai1 WITH (NOLOCK)
                              where ai1.alloc_num = c.cost_owner_key1 AND    
                                    ai1.alloc_item_num = c.cost_owner_key2 AND 
                                    ai1.trans_id <= c.pl_trans_id)
      union
      select ai.alloc_num,
             ai.alloc_item_num,
             ai.title_tran_date,
		         ai.nomin_date_from,
		         ai.nomin_date_to,
             ai.trans_id
      from dbo.aud_allocation_item ai WITH (NOLOCK),
           #costs c
      where ai.alloc_num = c.cost_owner_key1 AND    
            ai.alloc_item_num = c.cost_owner_key2 AND 
            ai.trans_id = (select max(trans_id)
                              from dbo.aud_allocation_item ai1 WITH (NOLOCK)
                              where ai1.alloc_num = c.cost_owner_key1 AND    
                                    ai1.alloc_item_num = c.cost_owner_key2 AND 
                                    ai1.trans_id <= c.pl_trans_id)
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected 
         where oid = @stepid
      end

      create nonclustered index xx_878_allocationItems_idx1
         on #allocationItems(alloc_num, alloc_item_num, trans_id)

      if @rows_affected > 0
      begin
         /* -----------------------------------------------
             STEP: Updating title_tran_date in #costs
            ----------------------------------------------- */   
         select @stepid = @stepid + 1
         if @debugon = 1 
            insert into @times 
               (oid, step, starttime)
              values(@stepid, 'Updating title_tran_date in #costs', getdate())
              
         update #costs
         set title_tran_date = ai1.title_tran_date,
	           nomin_date_from = ai1.nomin_date_from, 
      	     nomin_date_to = ai1.nomin_date_to    
         from #costs c,
              #allocationItems ai1
         where ai1.alloc_num = c.cost_owner_key1  AND    
               ai1.alloc_item_num = c.cost_owner_key2 AND 
               ai1.trans_id = (select max(trans_id)    
                               from #allocationItems ai2 
                               where ai2.alloc_num = ai1.alloc_num AND
                                     ai2.alloc_item_num = ai1.alloc_item_num)    
         select @rows_affected = @@rowcount
         if @debugon = 1
         begin
            update @times
            set endtime = getdate(),
                rows_affected = @rows_affected
            where oid = @stepid
         end
      end
      drop table #allocationItems
   end

   create nonclustered index xx_plh_xx_idx3
      on #plh(pl_secondary_owner_key1,
              pl_secondary_owner_key2,
              pl_secondary_owner_key3,
              ti_trans_id)

   create nonclustered index xx_plh_xx_idx4
      on #plh(pl_record_owner_key,
              tid_trans_id)

   create nonclustered index xx_plh_xx_idx5
      on #plh(pl_record_key,
              cost_trans_id)

   /* -----------------------------------------------
       STEP: Returns data back to caller
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Return result set', getdate())

   select distinct
      1, /* oid */
      plh.pl_record_key,
      plh.pl_owner_code,
      plh.pl_type,
      plh.pl_amt,
      plh.pl_record_qty,
      plh.pl_secondary_owner_key1,
      plh.pl_secondary_owner_key2,
      plh.pl_secondary_owner_key3,
      plh.pl_mkt_price,
      plh.pl_trans_id,
      plh.pl_record_owner_key,
      plh.pl_amt_prev,
      plh.pl_record_qty_prev,
      plh.pl_mkt_price_prev,
      ti.trans_id as ti_trans_id,
      ti.trading_prd as ti_trading_prd,
      ti.contr_qty_uom_code,
      ti.price_uom_code,
      ti.cmdty_code,
      ti.risk_mkt_code,
      ti.booking_comp_num,
      ti.real_port_num as ti_real_port_num,
      ti.pooling_port_num as ti_pooling_port_num,
      ti.pooling_type,
      ti.avg_price,
      ti.price_curr_code,
      tid.p_s_ind,
      ti.brkr_num,
      ti.brkr_comm_amt,
      ti.contr_qty,
      ti.formula_ind,
      c.cost_owner_code,
      c.cost_status,
      c.cost_type_code,
      c.cost_pay_rec_ind,
      c.cost_price_uom_code,
      c.cost_qty,
      c.cost_unit_price,
      c.cost_amt,
      c.cost_owner_key1,
      c.cost_owner_key2,
      c.cost_owner_key3,
      convert(char(10), c.cost_due_date, 101) as cost_due_date,
      convert(char(10), c.cost_eff_date, 101) as cost_eff_date,
      c.cost_pl_code,
	    c.cost_est_final_ind,
      c.cost_qty_est_actual_ind,
      c.cost_price_est_actual_ind,
      tid.dist_num,
      tid.dist_type,
      tid.dist_qty,
      tid.alloc_qty,
      tid.priced_qty,
      tid.is_equiv_ind,
      tid.real_port_num as tid_real_port_num,
      tid.pos_num,
      tid.commkt_key,
      plh.acct_num as counterparty,
      convert(char(10), plh.contr_date, 101) as contr_date,
      plh.inhouse_ind,
      convert(char(10), plh.del_date_from, 101) as del_date_from,
      convert(char(10), plh.del_date_to, 101) as del_date_to,
      plh.del_loc_code,
      convert(char(10), c.ai_est_actual_date, 101) as ai_est_actual_date,
      tid.trading_prd as tid_trading_prd,
      convert(char(10), c.deemed_bl_date, 101) as deemed_bl_date,
      convert(char(10), c.title_tran_date, 101) as title_tran_date, 
      convert(char(10), c.nomin_date_from, 101) as nomin_date_from,  
      convert(char(10), c.nomin_date_to, 101) as nomin_date_to

   from #plh plh
           LEFT OUTER JOIN #items ti
              ON plh.pl_secondary_owner_key1 = ti.trade_num AND 
                 plh.pl_secondary_owner_key2 = ti.order_num AND 
                 plh.pl_secondary_owner_key3 = ti.item_num AND 
                 plh.ti_trans_id = ti.trans_id
           LEFT OUTER JOIN #tids tid
              ON plh.pl_record_owner_key = tid.dist_num AND 
                 plh.tid_trans_id = tid.trans_id
           LEFT OUTER JOIN #costs c
             ON plh.pl_record_key = c.cost_num AND 
                plh.cost_trans_id = c.trans_id
   ORDER BY pl_secondary_owner_key1,
            pl_secondary_owner_key2,
            pl_secondary_owner_key3,
            cost_owner_key1,
            cost_owner_key2,
            cost_owner_key3
   select @rows_affected = @@rowcount

   if @debugon = 1
   begin
      update @times
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
      print ' '
      select @smsg = convert(varchar, @rows_affected) + ' rows returned.'
      print @smsg

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

      select @session_ended = convert(varchar, getdate(), 109)
      print ' '
      select @smsg = 'SESSION STARTED  AT     : ' + @session_started
      print @smsg       
      select @smsg = '        FINISHED AT     : ' + @session_ended
      print @smsg
   end /* debug */
   drop table #items
   drop table #tids
   drop table #costs

endofsp:
drop table #plh
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_physicals] TO [next_usr]
GO
