SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_U_tids]
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
        @asof_trans_id     int,
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

   select @stepid = 0
   /* -----------------------------------------------
       STEP: Copying rows into #allitems table
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Obtaining maxium trans_id from dbo.pl_history table', getdate())
 
   select @asof_trans_id = max(trans_id) 
   from dbo.pl_history plh WITH (NOLOCK)
   WHERE pl_asof_date = @my_pl_asof_date AND
         exists (select 1
                 from @port_num_list port
                 where plh.real_port_num = port.real_port_num)
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      select @smsg = 'DEBUG: asof_trans_id = ' + convert(varchar, @asof_trans_id)
      print @smsg
      update @times 
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
   end

   if @rows_affected <= 0
   begin
      if @debugon = 1 
      begin
         print 'Unable to find maxium trans id!'
      end
      goto endofsp
   end

   /* -----------------------------------------------
       STEP: Copying rows into #allitems table
      ----------------------------------------------- */   
   select @stepid = @stepid + 1
   if @debugon = 1
      insert into @times 
         (oid, step, starttime)
        values(@stepid, 'Copying rows into #allitems table', getdate())

   create table #allitems
   (
      oid                  numeric(18, 0) IDENTITY,
      trade_num            int,
      order_num            smallint,
      item_num             smallint,
      real_port_num        int null,
      trading_prd          varchar(40) null,
      contr_qty_uom_code   char(4) null,
      price_uom_code       char(4) null,
      cmdty_code           char(8) null,
      risk_mkt_code        char(8) null,
      booking_comp_num     int null,
      avg_price            float null,
      price_curr_code      char(8) null,
      p_s_ind              char(1) null,
      brkr_num             int null,
      brkr_comm_amt        float null,
      contr_qty            float null,
      trans_id             int null
   )

   insert into #allitems
   (
      trade_num,
      order_num,
      item_num,
      real_port_num,
      trading_prd,
      contr_qty_uom_code,
      price_uom_code,
      cmdty_code,
      risk_mkt_code,
      booking_comp_num,
      avg_price,
      price_curr_code,
      p_s_ind,
      brkr_num,
      brkr_comm_amt,
      contr_qty,
      trans_id
   )
   select 
      trade_num,
      order_num,
      item_num,
      real_port_num,
      trading_prd,
      contr_qty_uom_code,
      price_uom_code,
      cmdty_code,
      risk_mkt_code,
      booking_comp_num,
      avg_price,
      price_curr_code,
      p_s_ind,
      brkr_num,
      brkr_comm_amt,
      contr_qty,
      trans_id
   from dbo.trade_item ti WITH (NOLOCK)
   WHERE item_type = 'W' AND 
         exists (select 1
                 from @port_num_list port
                 where ti.real_port_num = port.real_port_num) AND
         trans_id = (select max(trans_id)
                     from dbo.trade_item ti2 WITH (NOLOCK)
                     where ti.trade_num = ti2.trade_num AND
                           ti.order_num = ti2.order_num AND
                           ti.item_num = ti2.item_num AND
                           ti2.trans_id <= @asof_trans_id)
   union
   select 
      trade_num,
      order_num,
      item_num,
      real_port_num,
      trading_prd,
      contr_qty_uom_code,
      price_uom_code,
      cmdty_code,
      risk_mkt_code,
      booking_comp_num,
      avg_price,
      price_curr_code,
      p_s_ind,
      brkr_num,
      brkr_comm_amt,
      contr_qty,
      trans_id
   from dbo.aud_trade_item ti WITH (NOLOCK)
   WHERE item_type = 'W' AND 
         exists (select 1
                 from @port_num_list port
                 where ti.real_port_num = port.real_port_num) AND
         trans_id = (select max(trans_id)
                     from dbo.aud_trade_item ti2 WITH (NOLOCK)
                     where ti.trade_num = ti2.trade_num AND
                           ti.order_num = ti2.order_num AND
                           ti.item_num = ti2.item_num AND
                           ti2.trans_id <= @asof_trans_id)
   select @rows_affected = @@rowcount
   if @debugon = 1
   begin
      update @times 
      set endtime = getdate(),
          rows_affected = @rows_affected
      where oid = @stepid
   end

   create nonclustered index xx_allitems_xx_idx1
      on #allitems(trade_num, order_num, item_num, trans_id)

   create table #items
   (
      oid                  numeric(18, 0) IDENTITY,
      trade_num            int,
      order_num            smallint,
      item_num             smallint,
      real_port_num        int null,
      trading_prd          varchar(40) null,
      contr_qty_uom_code   char(4) null,
      price_uom_code       char(4) null,
      cmdty_code           char(8) null,
      risk_mkt_code        char(8) null,
      booking_comp_num     int null,
      avg_price            float null,
      price_curr_code      char(8) null,
      p_s_ind              char(1) null,
      brkr_num             int null,
      brkr_comm_amt        float null,
      contr_qty            float null,
      trans_id             int null
   )

   if @rows_affected > 0
   begin
      insert into #items
      (
         trade_num,
         order_num,
         item_num,
         real_port_num,
         trading_prd,
         contr_qty_uom_code,
         price_uom_code,
         cmdty_code,
         risk_mkt_code,
         booking_comp_num,
         avg_price,
         price_curr_code,
         p_s_ind,
         brkr_num,
         brkr_comm_amt,
         contr_qty,
         trans_id
      )
      select 
         trade_num,
         order_num,
         item_num,
         real_port_num,
         trading_prd,
         contr_qty_uom_code,
         price_uom_code,
         cmdty_code,
         risk_mkt_code,
         booking_comp_num,
         avg_price,
         price_curr_code,
         p_s_ind,
         brkr_num,
         brkr_comm_amt,
         contr_qty,
         trans_id
      from #allitems ti1
      WHERE trans_id = (select max(trans_id)
                        from #allitems ti2
                        where ti1.trade_num = ti2.trade_num AND
                              ti1.order_num = ti2.order_num AND
                              ti1.item_num = ti2.item_num AND
                              ti2.trans_id <= @asof_trans_id)
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times 
         set endtime = getdate(),
             rows_affected = @rows_affected
         where oid = @stepid
      end

      create nonclustered index xx_items_xx_idx1
         on #items(trade_num, order_num, item_num, trans_id)
   end
   drop table #allitems

   if @rows_affected <= 0
   begin
      if @debugon = 1 
      begin
         print 'No trade_item records found!'
      end
      goto endofsp
   end

   /* ---------------------------------------------------
       STEP: Getting trade_item_dist's related information
      --------------------------------------------------- */   
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
      real_port_num    int null,
      pos_num          int null,
      commkt_key       int null,
      accum_num        smallint null,
      qpp_num          smallint null,
      dist_qty         float null,
      alloc_qty        numeric(20, 8) null,
      priced_qty       numeric(20, 8) null,
      accum_qty        numeric(20, 8) null,
      p_s_ind          char(1) null,
      trading_prd      char(8) null,
      trans_id         int null
   )

   create table #tids1
   (
      dist_num         int,
      trade_num        int null,
      order_num        smallint null,
      item_num         smallint null,
      dist_type        char(2) null,
      is_equiv_ind     char(1) null,
      real_port_num    int null,
      pos_num          int null,
      commkt_key       int null,
      accum_num        smallint null,
      qpp_num          smallint null,
      dist_qty         float null,
      alloc_qty        numeric(20, 8) null,
      priced_qty       numeric(20, 8) null,
      accum_qty        numeric(20, 8) null,
      p_s_ind          char(1) null,
      trading_prd      char(8) null,
      trans_id         int null
   )

   create table #tids2
   (
      dist_num         int,
      trade_num        int null,
      order_num        smallint null,
      item_num         smallint null,
      dist_type        char(2) null,
      is_equiv_ind     char(1) null,
      real_port_num    int null,
      pos_num          int null,
      commkt_key       int null,
      accum_num        smallint null,
      qpp_num          smallint null,
      dist_qty         float null,
      alloc_qty        numeric(20, 8) null,
      priced_qty       numeric(20, 8) null,
      accum_qty        numeric(20, 8) null,
      p_s_ind          char(1) null,
      trading_prd      char(8) null,
      trans_id         int null
   )

   create table #dists
   (
      trade_num        int,
      order_num        smallint,
      item_num         smallint,
      accum_num        smallint,
      qpp_num          smallint,
      real_port_num    int null,
      ti_trans_id      int null,
      trans_id         int null
    )

    insert into #dists  
    select utid.trade_num,  
           utid.order_num,  
           utid.item_num,  
           utid.accum_num,  
           utid.qpp_num,  
           utid.real_port_num,  
           ti.trans_id,  
           utid.trans_id  
    from #items ti,  
         dbo.trade_item_dist utid WITH (NOLOCK)
    where utid.trade_num = ti.trade_num AND  
          utid.order_num = ti.order_num AND  
          utid.item_num = ti.item_num AND  
          utid.real_port_num = ti.real_port_num AND  
          utid.dist_type = 'U'  
    select @rows_affected = @@rowcount  
    if @debugon = 1  
    begin  
       update @times  
       set endtime = getdate(),  
           rows_affected = @rows_affected  
       where oid = @stepid  
    end  

    create nonclustered index xx_878_dist_idx1
       on #dists(trade_num, order_num, item_num, accum_num, qpp_num, real_port_num, trans_id)
  
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

       insert into #tids1  
       select tid.dist_num,  
              tid.trade_num,  
              tid.order_num,  
              tid.item_num,  
              tid.dist_type,  
              tid.is_equiv_ind,  
              tid.real_port_num,  
              tid.pos_num,  
              tid.commkt_key,  
              tid.accum_num,  
              tid.qpp_num,  
              tid.dist_qty,  
              tid.alloc_qty,  
              tid.priced_qty,  
              null,  /* accum_qty */  
              tid.p_s_ind,  
              tid.trading_prd,  
              tid.trans_id  
       from dbo.trade_item_dist tid WITH (NOLOCK),  
            #dists 
       where tid.trade_num = #dists.trade_num AND  
             tid.order_num = #dists.order_num AND  
             tid.item_num = #dists.item_num AND  
             tid.accum_num = #dists.accum_num AND  
             tid.qpp_num = #dists.qpp_num AND  
             tid.real_port_num = #dists.real_port_num  AND
             tid.trans_id = (select max(trans_id)  
                             from dbo.trade_item_dist tid1 WITH (NOLOCK) 
                             where tid1.trade_num = #dists.trade_num AND  
                                   tid1.order_num = #dists.order_num AND  
                                   tid1.item_num = #dists.item_num AND  
	                                 tid1.accum_num = #dists.accum_num AND  
		                               tid1.qpp_num = #dists.qpp_num AND  
	                                 tid1.real_port_num = #dists.real_port_num AND
                                   tid1.trans_id <= @asof_trans_id) 
       create nonclustered index xx_878_tids1_idx1
          on #tids1(trade_num, order_num, item_num, accum_num, qpp_num, real_port_num, trans_id)
       create nonclustered index xx_878_tids1_idx2
          on #tids1(dist_num, trans_id)
 
       insert into #tids2    
       select tid.dist_num,  
              tid.trade_num,  
              tid.order_num,  
              tid.item_num,  
              tid.dist_type,  
              tid.is_equiv_ind,  
              tid.real_port_num,  
              tid.pos_num,  
              tid.commkt_key,  
              tid.accum_num,  
              tid.qpp_num,  
              tid.dist_qty,  
              tid.alloc_qty,  
              tid.priced_qty,  
              null,  /* accum_qty */  
              tid.p_s_ind,  
              tid.trading_prd,  
              tid.trans_id  
       from dbo.aud_trade_item_dist tid WITH (NOLOCK),  
            #dists  
       where tid.trade_num = #dists.trade_num AND  
             tid.order_num = #dists.order_num AND  
             tid.item_num = #dists.item_num AND  
             tid.accum_num = #dists.accum_num AND  
             tid.qpp_num = #dists.qpp_num AND  
             tid.real_port_num = #dists.real_port_num AND
             tid.trans_id = (select max(trans_id)  
                             from dbo.aud_trade_item_dist tid1 WITH (NOLOCK)  
                             where tid1.trade_num = #dists.trade_num AND  
                                   tid1.order_num = #dists.order_num AND  
                                   tid1.item_num = #dists.item_num AND  
	                                 tid1.accum_num = #dists.accum_num AND  
		                               tid1.qpp_num = #dists.qpp_num AND  
	                                 tid1.real_port_num = #dists.real_port_num AND
                                   tid1.trans_id <= @asof_trans_id) 
       create nonclustered index xx_878_tids2_idx1
          on #tids2(trade_num, order_num, item_num, accum_num, qpp_num, real_port_num, trans_id)
       create nonclustered index xx_878_tids_idx2
          on #tids2(dist_num, trans_id)

       insert into #tids
       select * from #tids1
       union
       select * from #tids2
       select @rows_affected = @@rowcount  

       create nonclustered index xx_878_tids_idx1
          on #tids(trade_num, order_num, item_num, accum_num, qpp_num, real_port_num, trans_id)
       create nonclustered index xx_878_tids_idx2
          on #tids(dist_num, trans_id)
     
       drop table #tids1
       drop table #tids2
   
      if @debugon = 1  
      begin  
         update @times  
         set endtime = getdate(),  
             rows_affected = @rows_affected  
         where oid = @stepid  
      end  
  
      if @rows_affected > 0  
      begin             
         select @stepid = @stepid + 1  
         if @debugon = 1  
            insert into @times   
               (oid, step, starttime)  
              values(@stepid, 'Updating trans_id in #dists', getdate())  
              
         update #dists  
         set trans_id = (select isnull(max(trans_id), 0)   
                         from #tids tid  
                         where tid.trade_num = #dists.trade_num AND  
                               tid.order_num = #dists.order_num AND  
                               tid.item_num = #dists.item_num AND  
                               tid.accum_num = #dists.accum_num AND  
                               tid.qpp_num = #dists.qpp_num AND  
                               tid.real_port_num = #dists.real_port_num AND  
                               tid.trans_id <= @asof_trans_id)  
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
          STEP: Get accumulation records
         ----------------------------------------------- */   
      select @stepid = @stepid + 1
      if @debugon = 1
         insert into @times 
            (oid, step, starttime)
           values(@stepid, 'Getting accumulation records', getdate())

      create table #accums
      (
         trade_num        int,
         order_num        smallint,
         item_num         smallint,
         accum_num        smallint,
         accum_qty        float null,
         trans_id         int null
      )

      insert into #accums
      (
         trade_num,
         order_num,
         item_num,
         accum_num,
         accum_qty,
         trans_id
      )
      select
         accum.trade_num,
         accum.order_num,
         accum.item_num,
         accum.accum_num,
         accum.accum_qty,
         accum.trans_id
      from dbo.accumulation accum WITH (NOLOCK),
           #tids tid
      where accum.trade_num = tid.trade_num AND
            accum.order_num = tid.order_num AND
            accum.item_num = tid.item_num AND
            accum.trans_id = (select max(trans_id)
                              from dbo.accumulation accum1 WITH (NOLOCK)
                              where accum1.trade_num = accum.trade_num AND
                                    accum1.order_num = accum.order_num AND
                                    accum1.item_num = accum.item_num AND
                                    accum1.trans_id <= @asof_trans_id)
      union
      select
         accum.trade_num,
         accum.order_num,
         accum.item_num,
         accum.accum_num,
         accum.accum_qty,
         accum.trans_id
      from dbo.aud_accumulation accum WITH (NOLOCK),
           #tids tid
      where accum.trade_num = tid.trade_num AND
            accum.order_num = tid.order_num AND
            accum.item_num = tid.item_num AND
            accum.trans_id = (select max(trans_id)
                              from dbo.aud_accumulation accum1 WITH (NOLOCK)
                              where accum1.trade_num = accum.trade_num AND
                                    accum1.order_num = accum.order_num AND
                                    accum1.item_num = accum.item_num AND
                                    accum1.trans_id <= @asof_trans_id)
      select @rows_affected = @@rowcount
      if @debugon = 1
      begin
         update @times
         set endtime = getdate(),
             rows_affected = @rows_affected
         where oid = @stepid
      end

      create nonclustered index xx_878_accums_idx1
         on #accums(trade_num, order_num, item_num, accum_num, trans_id)

      if @rows_affected > 0
      begin           
         /* -----------------------------------------------
             STEP: Set accum_qty in #tids
            ----------------------------------------------- */   
         select @stepid = @stepid + 1
         if @debugon = 1
            insert into @times 
               (oid, step, starttime)
              values(@stepid, 'Setting accum_qty in #tids', getdate())

         update #tids
         set accum_qty = accum1.accum_qty
         from #accums accum1
         where accum1.trade_num = #tids.trade_num AND
               accum1.order_num = #tids.order_num AND
               accum1.item_num = #tids.item_num AND
               accum1.accum_num = #tids.accum_num AND
               accum1.trans_id = (select max(trans_id) 
                                  from #accums accum2
                                  where accum2.trade_num = accum1.trade_num AND
                                        accum2.order_num = accum1.order_num AND
                                        accum2.item_num = accum1.item_num AND
                                        accum2.accum_num = accum1.accum_num)
         select @rows_affected = @@rowcount
         if @debugon = 1
         begin
            update @times
            set endtime = getdate(),
                rows_affected = @rows_affected
            where oid = @stepid
         end
      end
      drop table #accums
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
       1, /* oid */
       ti.trade_num,
       ti.order_num,
       ti.item_num,
       ti.real_port_num as ti_real_port_num,
       ti.trading_prd as ti_trading_prd,
       ti.contr_qty_uom_code,
       ti.price_uom_code,
       ti.cmdty_code,
       ti.risk_mkt_code,
       ti.booking_comp_num,
       ti.avg_price,
       ti.price_curr_code,
       tid.p_s_ind,
       ti.brkr_num,
       ti.brkr_comm_amt,
       ti.contr_qty,
       tid.dist_num,
       tid.dist_type,
       tid.dist_qty,
       tid.alloc_qty,
       tid.priced_qty,
       tid.is_equiv_ind,
       tid.real_port_num as tid_real_port_num,
       tid.pos_num,
       tid.commkt_key,
       tid.accum_qty,
       tid.trading_prd as tid_trading_prd
    from #items ti, 
         #tids tid, 
         #dists utid
    where utid.trade_num = ti.trade_num AND  
          utid.order_num = ti.order_num AND  
          utid.item_num = ti.item_num AND  
          utid.real_port_num = ti.real_port_num AND  
          tid.trade_num = utid.trade_num AND  
          tid.order_num = utid.order_num AND  
          tid.item_num = utid.item_num AND  
          tid.real_port_num = utid.real_port_num AND  
          tid.accum_num = utid.accum_num AND  
          tid.qpp_num = utid.qpp_num AND  
          tid.trans_id = utid.trans_id  
   order by ti.trade_num,
            ti.order_num,
            ti.item_num,
            ti_real_port_num DESC  
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
   drop table #tids
   drop table #dists

endofsp:
drop table #items
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_U_tids] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_RVFile_U_tids', NULL, NULL
GO
