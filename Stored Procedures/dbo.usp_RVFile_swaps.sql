SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_swaps] 
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
      pl_amt_prev              float null,    
      pl_amt                   float null,    
      pl_mkt_price_prev        float null,    
      pl_mkt_price             float null,    
      pl_trans_id              int null,    
      dist_num                 int null,    
      acct_num                 int null,    
      contr_date               datetime null,    
      inhouse_ind              char(1) null,    
      ti_trans_id              int null,    
      pl_category_type         char(8) null,    
      pl_category_type_prev    char(8) null,    
      order_type_code          char(8) null,    
      pl_record_owner_key     int null    
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
      pl_trans_id,    
      pl_category_type,    
      pl_record_owner_key    
   )    
   select plh.real_port_num,    
          plh.pl_asof_date,    
          plh.pl_owner_code,     
          plh.pl_type,        
          plh.pl_secondary_owner_key1,    
          plh.pl_secondary_owner_key2,    
          plh.pl_secondary_owner_key3,    
          plh.pl_record_key,    
          plh.pl_amt,    
          plh.pl_mkt_price,    
          plh.trans_id,    
          plh.pl_category_type,    
        plh.pl_record_owner_key    
   from dbo.pl_history plh WITH (NOLOCK)    
   where plh.pl_asof_date = @my_pl_asof_date AND     
         exists (select 1    
                 from @port_num_list port    
                 where plh.real_port_num = port.real_port_num) AND    
         ((plh.pl_owner_code = 'C' AND    
           plh.pl_owner_sub_code = 'SWAP') or    
          (plh.pl_owner_code = 'T' AND    
           plh.pl_owner_sub_code = 'C')) and    
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
              real_port_num,    
              pl_trans_id)    
    
   create nonclustered index xx_plh_xx_idx2    
      on #plh(pl_record_owner_key)    
    
   create nonclustered index xx_plh_xx_idx3    
      on #plh(dist_num)    
    
   /* -----------------------------------------------    
       STEP: Getting pl_amt, pl_category_type and     
             pl_mkt_price for the previous pl_history     
             record    
      ----------------------------------------------- */       
   select @stepid = @stepid + 1    
   if @debugon = 1     
      insert into @times     
         (oid, step, starttime)    
        values(@stepid, 'Getting prev. PLH pl_amt, pl_category_type and pl_mkt_price', getdate())    
    
   update #plh    
   set pl_amt_prev = plhold1.pl_amt,    
       pl_mkt_price_prev = plhold1.pl_mkt_price,    
       pl_category_type_prev = plhold1.pl_category_type    
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
   -- We don't need to use the temporary table #trades any more, so drop it    
   drop table #trades    
    
   /* -----------------------------------------------    
       STEP: Getting trade_order level information    
      ----------------------------------------------- */       
   select @stepid = @stepid + 1    
   if @debugon = 1     
      insert into @times     
         (oid, step, starttime)    
        values(@stepid, 'Getting trade_order information', getdate())    
            
   create table #orders    
   (    
      trade_num           int,    
      order_num           smallint,    
      order_type_code     char(8) null    
   )    
          
   insert into #orders    
   select trdord.trade_num,    
          trdord.order_num,    
          trdord.order_type_code    
   from dbo.trade_order trdord WITH (NOLOCK),    
        #plh plh    
   where trdord.trade_num = plh.pl_secondary_owner_key1 AND        
         trdord.order_num = plh.pl_secondary_owner_key2 AND        
         trdord.trans_id = (select max(trans_id)    
                            from dbo.trade_order trdord1 WITH (NOLOCK)    
                            where trdord1.trade_num = plh.pl_secondary_owner_key1 AND        
                                  trdord1.order_num = plh.pl_secondary_owner_key2 AND        
                                  trdord1.trans_id <= plh.pl_trans_id)    
   union    
   select trdord.trade_num,    
          trdord.order_num,    
          trdord.order_type_code    
   from dbo.aud_trade_order trdord WITH (NOLOCK),    
        #plh plh    
   where trdord.trade_num = plh.pl_secondary_owner_key1 AND        
         trdord.order_num = plh.pl_secondary_owner_key2 AND        
         trdord.trans_id = (select max(trans_id)    
                            from dbo.aud_trade_order trdord1 WITH (NOLOCK)    
                            where trdord1.trade_num = plh.pl_secondary_owner_key1 AND        
                                  trdord1.order_num = plh.pl_secondary_owner_key2 AND        
                                  trdord1.trans_id <= plh.pl_trans_id)    
   select @rows_affected = @@rowcount    
   if @debugon = 1     
   begin    
      update @times    
      set endtime = getdate(),    
          rows_affected = @rows_affected     
      where oid = @stepid    
   end    
    
   create nonclustered index xx_878_orders_idx1    
      on #orders(trade_num, order_num)    
       
   if @rows_affected > 0    
   begin    
      /* -----------------------------------------------    
          STEP: Updating order_type_code in #plh    
         ----------------------------------------------- */       
      select @stepid = @stepid + 1    
      if @debugon = 1     
         insert into @times     
            (oid, step, starttime)    
           values(@stepid, 'Updating order_type_code', getdate())    
               
      update #plh    
      set order_type_code = a.order_type_code    
      from #orders a    
      where a.trade_num = #plh.pl_secondary_owner_key1 and    
            a.order_num = #plh.pl_secondary_owner_key2    
      select @rows_affected = @@rowcount    
      if @debugon = 1     
      begin    
         update @times    
         set endtime = getdate(),    
             rows_affected = @rows_affected     
         where oid = @stepid    
      end    
   end    
   drop table #orders    
    
   /* -----------------------------------------------    
       STEP: Getting trade_item's related information    
      ----------------------------------------------- */       
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
      brkr_acct_full_name varchar(255) null,    
      mkt_acct_full_name  varchar(255) null        
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
   end    
    
   /* -----------------------------------------------------    
       STEP: Getting trade_item_dist's related information    
      ----------------------------------------------------- */       
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
      is_equiv_ind     char(1) null,    
      p_s_ind          char(1) null,    
      real_port_num    int null,    
      pos_num          int null,    
      trading_prd      char(8) null,    
      commkt_key       int null,    
      accum_num        smallint null,    
      qpp_num          smallint null,    
      dist_qty         float null,    
      trans_id         int null,    
      quote_end_date   datetime null    
   )    
    
   create table #dists    
   (    
      trade_num        int,    
      order_num        smallint,    
      item_num         smallint,    
      real_port_num    int null,    
      accum_num        smallint null,    
      qpp_num          smallint null,    
      pl_trans_id      int null,    
      trans_id         int null    
    )    
    
   insert into #tids    
   select tid.dist_num,    
          tid.trade_num,    
          tid.order_num,    
          tid.item_num,    
          tid.dist_type,    
          tid.is_equiv_ind,    
          tid.p_s_ind,    
          tid.real_port_num,    
          tid.pos_num,    
          tid.trading_prd,    
          tid.commkt_key,    
          tid.accum_num,    
          tid.qpp_num,    
          tid.dist_qty,    
          tid.trans_id,    
          null    /* quote_end_date */    
   from dbo.trade_item_dist tid WITH (NOLOCK),    
        #plh plh    
   where tid.trade_num = plh.pl_secondary_owner_key1 AND    
         tid.order_num = plh.pl_secondary_owner_key2 AND    
         tid.item_num = plh.pl_secondary_owner_key3 AND    
         tid.trans_id <= plh.pl_trans_id    
   union    
   select tid.dist_num,    
          tid.trade_num,    
          tid.order_num,    
          tid.item_num,    
          tid.dist_type,    
          tid.is_equiv_ind,    
          tid.p_s_ind,    
          tid.real_port_num,    
          tid.pos_num,    
          tid.trading_prd,    
          tid.commkt_key,    
          tid.accum_num,    
          tid.qpp_num,    
          tid.dist_qty,    
          tid.trans_id,    
          null    /* quote_end_date */    
   from dbo.aud_trade_item_dist tid WITH (NOLOCK),    
        #plh plh    
   where tid.trade_num = plh.pl_secondary_owner_key1 AND    
         tid.order_num = plh.pl_secondary_owner_key2 AND    
         tid.item_num = plh.pl_secondary_owner_key3 AND    
         tid.trans_id = (select max(trans_id)     
                         from dbo.aud_trade_item_dist tid1 WITH (NOLOCK)     
                         where tid1.dist_num = tid.dist_num and     
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
       on #tids(trade_num, order_num, item_num, real_port_num, accum_num, qpp_num, trans_id)    
   create nonclustered index xx_878_tids_idx2    
       on #tids(dist_num, trans_id)    
    
   -- If the trade has associated distributions, then get dist_nums    
   if @rows_affected > 0    
   begin    
      /* --------------------------------------------------    
          STEP: Getting trade_item_dist with dist_type = U    
         -------------------------------------------------- */       
      select @stepid = @stepid + 1    
      if @debugon = 1    
         insert into @times     
            (oid, step, starttime)    
           values(@stepid, 'Getting trade_item_dist with dist_type = U', getdate())    
    
      insert into #dists    
      select dist.trade_num,    
             dist.order_num,    
             dist.item_num,    
             dist.real_port_num,    
             dist.accum_num,    
             dist.qpp_num,    
             plh.pl_trans_id,    
             null    
      from #plh plh,    
           dbo.trade_item_dist dist WITH (NOLOCK)    
      where dist.trade_num = plh.pl_secondary_owner_key1 AND    
            dist.order_num = plh.pl_secondary_owner_key2 AND    
            dist.item_num = plh.pl_secondary_owner_key3 AND    
            dist.real_port_num = plh.real_port_num AND    
            dist.dist_type = 'U'    
      select @rows_affected = @@rowcount    
          
      create nonclustered index xx_878_dist_idx1    
         on #dists(trade_num, order_num, item_num, accum_num, qpp_num, real_port_num, trans_id)    
    
      if @rows_affected > 0    
      begin               
         update #dists    
         set trans_id = (select max(trans_id)     
                         from #tids tid    
                         where tid.trade_num = #dists.trade_num AND    
                               tid.order_num = #dists.order_num AND    
                               tid.item_num = #dists.item_num AND    
                               tid.accum_num = #dists.accum_num AND    
                               tid.qpp_num = #dists.qpp_num AND    
                               tid.real_port_num = #dists.real_port_num AND    
                               tid.dist_type = 'U' AND    
                               tid.trans_id <= #dists.pl_trans_id)    
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
          STEP: Updating quote_end_date in #tids    
         ----------------------------------------------- */       
   select @stepid = @stepid + 1    
      if @debugon = 1    
         insert into @times     
            (oid, step, starttime)    
           values(@stepid, 'Updating quote_end_date in #tids', getdate())    
               
      update #tids    
      set quote_end_date = accum.quote_end_date    
      from dbo.accumulation accum WITH (NOLOCK)    
      where #tids.trade_num = accum.trade_num and     
            #tids.order_num = accum.order_num and     
            #tids.item_num = accum.item_num and    
            #tids.accum_num = accum.accum_num    
      select @rows_affected = @@rowcount    
      if @debugon = 1    
      begin    
         update @times    
         set endtime = getdate(),    
             rows_affected = @rows_affected    
         where oid = @stepid    
      end    
   end    
    
   create nonclustered index xx_plh_xx_idx4    
      on #plh(pl_secondary_owner_key1,    
              pl_secondary_owner_key2,    
              pl_secondary_owner_key3,    
              ti_trans_id)    
    
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
       ti.item_type,    
       plh.pl_secondary_owner_key1,    
       plh.pl_secondary_owner_key2,    
       plh.pl_secondary_owner_key3,    
       plh.pl_mkt_price,    
       plh.pl_trans_id as pl_trans_id,    
       plh.pl_category_type,    
       plh.pl_category_type_prev as pl_category_type_prev,    
       ti.trans_id as ti_trans_id,    
       ti.p_s_ind as ti_p_s_ind,           
       ti.trading_prd as ti_trading_prd,    
       ti.contr_qty_uom_code,    
       ti.price_uom_code,    
       ti.cmdty_code,    
       ti.risk_mkt_code,    
       ti.booking_comp_num,    
       ti.real_port_num as ti_real_port_num,    
       ti.avg_price,    
       ti.price_curr_code,    
       ti.brkr_num,    
       ti.brkr_comm_amt,    
       ti.contr_qty,    
       tid.dist_num as dist_num_u,    
       tid.dist_type,    
       tid.dist_qty as dist_qty_u,    
       tid.is_equiv_ind,    
       tid.real_port_num as tid_real_port_num,    
       tid.pos_num as pos_num_u,    
       tid.commkt_key,    
       tid.accum_num,    
       tid.qpp_num,    
       tid.trading_prd as tid_trading_prd,    
       tid.p_s_ind,    
       tidmtm.alloc_qty,    
       tidmtm.qty_uom_code,    
       tidmtm.dist_qty as dist_qty_tidmtm,    
       tidmtm.market_value,    
       tidmtm.trade_value,    
       tidmtm.curr_conv_rate,    
       tidmtm.open_pl,    
       tidmtm.addl_cost_sum,    
       tidmtm.trade_modified_ind,    
       tidmtm.delta,    
       tidmtm.volatility,    
       tidmtm.interest_rate,    
       tidmtm.discount_factor,    
       tidmtm.gamma,    
       tidmtm.vega,    
       tidmtm.theta,    
       tidmtm.rho,    
       tidmtm.drift,    
       tidmtm.curr_code_conv_to,    
       tidmtm.qty_uom_code_conv_to,    
       tidmtmold.trade_value as trade_value_prev,    
       tidmtmold.alloc_qty as alloc_qty_prev,    
       tidmtmold.dist_qty as dist_qty_prev,    
       tidmtmold.market_value as market_value_prev,    
       tidmtmold.curr_conv_rate as curr_conv_rate_prev,    
       tidmtmold.qty_uom_code as qty_uom_code_prev,    
       tidmtmold.curr_code as curr_code_prev,    
       convert(char(10), tidmtmold.mtm_pl_asof_date, 101) as mtm_pl_asof_date_prev,    
       tidmtmold.delta as delta_prev,    
       tidmtmold.volatility as volatility_prev,    
       tidmtmold.interest_rate as interest_rate_prev,    
       tidmtmold.discount_factor as discount_factor_prev,    
       tidmtmold.gamma as gamma_prev,    
       tidmtmold.vega as vega_prev,    
       tidmtmold.theta as theta_prev,    
       tidmtmold.rho as rho_prev,    
       tidmtmold.drift as drift_prev,    
       plh.order_type_code,    
       plh.acct_num as counterparty,    
       convert(char(10), plh.contr_date, 101) as contr_date,    
       plh.inhouse_ind,    
       ti.brkr_acct_full_name,    
       ti.mkt_acct_full_name,    
       dtid.dist_num as dist_num_d,    
       dtid.pos_num as pos_num_d,    
       dtid.dist_qty as dist_qty_d,    
       convert(char(10), tid.quote_end_date, 101) as quote_end_date,    
       datediff(dd, @my_pl_asof_date, tid.quote_end_date) as days_to_quote_end           
    from #plh plh     
            INNER JOIN #items ti    
               ON ti.trade_num = plh.pl_secondary_owner_key1 AND     
                  ti.order_num = plh.pl_secondary_owner_key2 AND     
                  ti.item_num = plh.pl_secondary_owner_key3 AND     
                  ti.trans_id = plh.ti_trans_id    
            INNER JOIN #tids dtid    
               ON dtid.dist_num = plh.pl_record_owner_key AND     
                  dtid.trans_id = (SELECT max(trans_id)    
                                   FROM #tids tid2    
                                   WHERE tid2.dist_num = plh.pl_record_owner_key)    
            INNER JOIN #dists dist    
               ON dist.real_port_num = plh.real_port_num AND     
                  dist.trade_num = plh.pl_secondary_owner_key1 AND     
                  dist.order_num = plh.pl_secondary_owner_key2 AND     
                  dist.item_num = plh.pl_secondary_owner_key3    
            INNER JOIN #tids tid    
               ON tid.real_port_num = dist.real_port_num AND     
                  tid.trade_num = dist.trade_num AND     
                  tid.order_num = dist.order_num AND     
                  tid.item_num = dist.item_num AND     
                  tid.accum_num = dist.accum_num AND     
                  tid.qpp_num = dist.qpp_num AND     
                  tid.trans_id = dist.trans_id    
            LEFT OUTER JOIN dbo.tid_mark_to_market tidmtm WITH (NOLOCK)    
               ON tidmtm.dist_num = plh.pl_record_owner_key AND     
                  tidmtm.mtm_pl_asof_date = @my_pl_asof_date    
            LEFT OUTER JOIN dbo.tid_mark_to_market tidmtmold WITH (NOLOCK)    
               ON tidmtmold.dist_num = plh.pl_record_owner_key AND     
                  tidmtmold.mtm_pl_asof_date = (SELECT max(mtm_pl_asof_date)    
                                                FROM dbo.tid_mark_to_market tidmtmold2 WITH (NOLOCK)    
                                                WHERE tidmtmold2.dist_num = plh.pl_record_owner_key AND     
                     tidmtmold2.mtm_pl_asof_date < @my_pl_asof_date)    
   order by tid_real_port_num,    
            pl_secondary_owner_key1,    
            pl_secondary_owner_key2,    
            pl_secondary_owner_key3,    
            tid.accum_num,    
            tid.commkt_key,    
            tid.qpp_num    
   select @rows_affected = @@rowcount    
    
   if @debugon = 1    
   begin    
      update @times    
      set endtime = getdate(),    
          rows_affected = @rows_affected    
      where oid = @stepid    
      print ' '    
      select @smsg = 'usp_RVFile_swaps: ' + convert(varchar, @rows_affected) + ' rows returned.'    
      print @smsg    
    
      declare @step       varchar(80),    
              @starttime  varchar(30),    
              @endtime    varchar(30),    
              @duration   varchar(30)    
    
      select @oid = min(oid)    
      from @times    
    
      while @oid is not null    
      begin    
         select @step = step,    
                @starttime = convert(varchar, starttime, 109),    
                @endtime = convert(varchar, endtime, 109),    
                @duration = convert(varchar, datediff(ms, starttime, endtime)),    
                @rows_affected = rows_affected    
         from @times    
         where oid = @oid    
    
         select @smsg = convert(varchar, @oid) + '. ' + @step    
         print @smsg    
         select @smsg = '    STARTED  AT     : ' + @starttime    
         print @smsg           
         select @smsg = '    FINISHED AT     : ' + @endtime    
         print @smsg    
         select @smsg = '    DURATION (in ms): ' + @duration    
         print @smsg    
         select @smsg = '    ROWS AFFECTED   : ' + convert(varchar, @rows_affected)    
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
   drop table #tids    
   drop table #dists    
    
endofsp:    
drop table #plh    
return 0 
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_swaps] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_RVFile_swaps', NULL, NULL
GO
