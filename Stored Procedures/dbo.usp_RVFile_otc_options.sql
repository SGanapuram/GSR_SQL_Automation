SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_RVFile_otc_options] 
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
      pl_record_qty_prev       int null,    
      pl_amt                   float null,    
      pl_amt_prev              float null,    
      pl_mkt_price             float null,    
      pl_mkt_price_prev        float null,    
      pl_trans_id              int null,    
      pl_trans_id_prev         int null,    
      dist_num                 int null,    
      acct_num                 int null,    
      contr_date               datetime null,    
      inhouse_ind              char(1) null,    
      ti_trans_id              int null,    
      tid_trans_id             int null,    
      tiotcopt_trans_id        int null,    
      order_type_code          char(8) null    
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
          plh.trans_id    
   from dbo.pl_history plh WITH (NOLOCK)    
   where plh.pl_asof_date = @my_pl_asof_date AND     
         exists (select 1    
                 from @port_num_list port    
                 where plh.real_port_num = port.real_port_num) AND    
        ((plh.pl_owner_code = 'T' AND     
          plh.pl_owner_sub_code = 'O' AND     
          plh.pl_type = 'U')) AND    
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
      on #plh(pl_record_key,pl_trans_id)    
    
   create nonclustered index xx_plh_xx_idx3    
      on #plh(dist_num)    
    
   create nonclustered index xx_plh_xx_idx4    
      on #plh(pl_record_key, pl_owner_code, pl_type)    
    
   /* -----------------------------------------------    
       STEP: Getting pl_amt and pl_mkt_price for the    
             previous pl_history record    
      ----------------------------------------------- */       
   select @stepid = @stepid + 1    
   if @debugon = 1     
      insert into @times     
         (oid, step, starttime)    
        values(@stepid, 'Getting prev. PLH pl_amt and pl_mkt_price', getdate())    
    
   update #plh    
   set pl_record_qty_prev = plhold1.pl_record_qty,    
       pl_amt_prev = plhold1.pl_amt,    
       pl_mkt_price_prev = plhold1.pl_mkt_price,    
       pl_trans_id_prev = plhold1.trans_id    
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
    
   /* ----------------------------------------------------    
       STEP: Getting acct_num and contr_date information    
      ---------------------------------------------------- */       
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
       
   /* -------------------------------------------------    
       STEP: Getting trade_item level information, if    
             there are trade_item record(s) found, then    
             get OTC OPTION specific information.    
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
    
   create table #item_otcopts    
   (    
       trade_num               int,    
       order_num               smallint,    
       item_num                smallint,    
       exp_date                datetime NULL,    
       put_call_ind            char(1) NULL,    
       strike_price            float NULL,    
       premium                 float NULL,    
       premium_prev            float NULL,    
       premium_uom_code        varchar(4) NULL,    
       premium_curr_code       varchar(8) NULL,    
       strike_price_uom_code   varchar(4) NULL,    
       strike_price_curr_code  varchar(8) NULL,    
       trans_id                int NULL,    
       pl_trans_id_prev        int NULL,    
       price_date_to           datetime NULL     
   )    
    
   create table #item_otcopts2    
   (    
       trade_num               int,    
       order_num               smallint,    
       item_num                smallint,    
       premium                 float NULL,    
       trans_id                int NULL,    
       pl_trans_id_prev        int NULL    
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
    
      /* -------------------------------------------------------    
          STEP: Getting trade_item_otc_opt's related information    
         ------------------------------------------------------- */         
      select @stepid = @stepid + 1    
      if @debugon = 1     
         insert into @times     
            (oid, step, starttime)    
           values(@stepid, 'Getting trade_item_otc_opt information', getdate())    
               
      insert into #item_otcopts    
      select otcopt.trade_num,    
             otcopt.order_num,    
             otcopt.item_num,    
             otcopt.exp_date,    
             otcopt.put_call_ind,    
             otcopt.strike_price,    
             otcopt.premium,    
             null,    
             otcopt.premium_uom_code,    
             otcopt.premium_curr_code,    
             otcopt.strike_price_uom_code,    
             otcopt.strike_price_curr_code,               otcopt.trans_id,    
             plh.pl_trans_id_prev,    
             otcopt.price_date_to      
      from dbo.trade_item_otc_opt otcopt WITH (NOLOCK),    
           #plh plh    
      where otcopt.trade_num = plh.pl_secondary_owner_key1 AND        
            otcopt.order_num = plh.pl_secondary_owner_key2 AND        
            otcopt.item_num = plh.pl_secondary_owner_key3 AND    
            otcopt.trans_id = (select max(trans_id)    
                               from dbo.trade_item_otc_opt otcopt1 WITH (NOLOCK)    
                               where otcopt1.trade_num = plh.pl_secondary_owner_key1 AND        
                                     otcopt1.order_num = plh.pl_secondary_owner_key2 AND        
                                     otcopt1.item_num = plh.pl_secondary_owner_key3 AND    
                                     otcopt1.trans_id <= plh.pl_trans_id)    
      union    
      select otcopt.trade_num,    
             otcopt.order_num,    
             otcopt.item_num,    
             otcopt.exp_date,    
             otcopt.put_call_ind,    
             otcopt.strike_price,    
             otcopt.premium,    
             NULL,    
             otcopt.premium_uom_code,    
             otcopt.premium_curr_code,    
             otcopt.strike_price_uom_code,    
             otcopt.strike_price_curr_code,    
             otcopt.trans_id,    
             plh.pl_trans_id_prev,    
             otcopt.price_date_to      
      from dbo.aud_trade_item_otc_opt otcopt WITH (NOLOCK),    
           #plh plh    
      where otcopt.trade_num = plh.pl_secondary_owner_key1 AND        
            otcopt.order_num = plh.pl_secondary_owner_key2 AND        
            otcopt.item_num = plh.pl_secondary_owner_key3 AND    
            otcopt.trans_id = (select max(trans_id)    
                               from dbo.aud_trade_item_otc_opt otcopt1 WITH (NOLOCK)    
                               where otcopt1.trade_num = plh.pl_secondary_owner_key1 AND        
                                     otcopt1.order_num = plh.pl_secondary_owner_key2 AND        
                                     otcopt1.item_num = plh.pl_secondary_owner_key3 AND    
                                     otcopt1.trans_id <= plh.pl_trans_id)    
      select @rows_affected = @@rowcount    
      if @debugon = 1    
      begin    
         update @times    
         set endtime = getdate(),    
             rows_affected = @rows_affected     
         where oid = @stepid    
      end    
          
      create nonclustered index xx_878_otcopts_idx1    
      on #item_otcopts(trade_num, order_num, item_num, trans_id)    
    
      if @rows_affected > 0    
      begin    
         /* ------------------------------------------------------    
             STEP: Getting previous trade_item_otc_opt's related     
                   information    
          ------------------------------------------------------ */         
         select @stepid = @stepid + 1    
         if @debugon = 1     
            insert into @times     
               (oid, step, starttime)    
              values(@stepid, 'Getting prev. trade_item_otc_opt information', getdate())    
                  
         insert into #item_otcopts2    
         select otcopt.trade_num,    
                otcopt.order_num,    
                otcopt.item_num,    
                otcopt.premium,    
                otcopt.trans_id,    
                plh.pl_trans_id_prev    
         from dbo.trade_item_otc_opt otcopt WITH (NOLOCK),    
              #plh plh    
         where otcopt.trade_num = plh.pl_secondary_owner_key1 AND        
               otcopt.order_num = plh.pl_secondary_owner_key2 AND        
               otcopt.item_num = plh.pl_secondary_owner_key3 AND    
               otcopt.trans_id = (select max(trans_id)    
                                  from dbo.trade_item_otc_opt otcopt1 WITH (NOLOCK)    
                                  where otcopt1.trade_num = plh.pl_secondary_owner_key1 AND        
                                        otcopt1.order_num = plh.pl_secondary_owner_key2 AND        
                                        otcopt1.item_num = plh.pl_secondary_owner_key3 AND    
                                        otcopt1.trans_id <= plh.pl_trans_id_prev)    
         union    
         select otcopt.trade_num,    
                otcopt.order_num,    
                otcopt.item_num,    
                otcopt.premium,    
                otcopt.trans_id,    
                plh.pl_trans_id_prev    
         from dbo.aud_trade_item_otc_opt otcopt WITH (NOLOCK),    
              #plh plh    
         where otcopt.trade_num = plh.pl_secondary_owner_key1 AND        
               otcopt.order_num = plh.pl_secondary_owner_key2 AND        
               otcopt.item_num = plh.pl_secondary_owner_key3 AND    
               otcopt.trans_id = (select max(trans_id)    
                                  from dbo.aud_trade_item_otc_opt otcopt1 WITH (NOLOCK)    
                                  where otcopt1.trade_num = plh.pl_secondary_owner_key1 AND        
                                        otcopt1.order_num = plh.pl_secondary_owner_key2 AND        
                                        otcopt1.item_num = plh.pl_secondary_owner_key3 AND    
                                        otcopt1.trans_id <= plh.pl_trans_id_prev)    
         select @rows_affected = @@rowcount    
         if @debugon = 1    
         begin    
            update @times    
            set endtime = getdate(),    
                rows_affected = @rows_affected     
            where oid = @stepid    
         end    
    
         create nonclustered index xx_878_otcopts2_idx1    
             on #item_otcopts2(trade_num, order_num, item_num, trans_id)      
    
         if @rows_affected > 0    
         begin    
            /* ------------------------------------------------------    
                STEP: Getting previous premium     
               ------------------------------------------------------ */         
            select @stepid = @stepid + 1    
            if @debugon = 1     
               insert into @times     
                  (oid, step, starttime)    
                 values(@stepid, 'Getting previous premium', getdate())    
                     
            update #item_otcopts    
            set premium_prev = b.premium    
            from #item_otcopts a, #item_otcopts2 b    
            where a.trade_num = b.trade_num AND    
                  a.order_num = b.order_num AND    
                  a.item_num = b.item_num AND    
                  b.trans_id = (select max(trans_id)    
                                from #item_otcopts2 c    
                                where b.trade_num = c.trade_num and    
                                      b.order_num = c.order_num and     
                                      b.item_num = c.item_num) and                      
                  a.pl_trans_id_prev = b.pl_trans_id_prev    
            select @rows_affected = @@rowcount    
            if @debugon = 1    
            begin    
               update @times    
               set endtime = getdate(),    
                   rows_affected = @rows_affected     
               where oid = @stepid    
            end    
         end    
         -- we do not need #item_otcopts2 table any more, so, drop it    
         drop table #item_otcopts2    
    
         /* -----------------------------------------------    
             STEP: Updating tiotcopt_trans_id in #plh    
            ----------------------------------------------- */       
         select @stepid = @stepid + 1    
         if @debugon = 1     
            insert into @times     
               (oid, step, starttime)    
              values(@stepid, 'Updating tiotcopt_trans_id in #plh', getdate())    
                  
         update #plh    
         set tiotcopt_trans_id = (select max(trans_id)    
                                   from #item_otcopts otcopt        
                                   where otcopt.trade_num = #plh.pl_secondary_owner_key1 AND        
                                         otcopt.order_num = #plh.pl_secondary_owner_key2 AND        
                                         otcopt.item_num = #plh.pl_secondary_owner_key3)    
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
      accum_num        smallint null,    
      qpp_num          smallint null,    
      trading_prd      char(8) null,    
      qty_uom_code     char(4) null,    
      trans_id         int null    
   )    
/*    
   create nonclustered index xx_878_tids_idx1    
       on #tids(trade_num, order_num, item_num, trans_id)    
   create nonclustered index xx_878_tids_idx2    
       on #tids(dist_num, trans_id)    
*/    
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
          tid.accum_num,    
          tid.qpp_num,    
          tid.trading_prd,    
          tid.qty_uom_code,    
          tid.trans_id    
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
          tid.dist_qty,    
          tid.is_equiv_ind,    
          tid.p_s_ind,    
          tid.real_port_num,    
          tid.pos_num,    
          tid.commkt_key,    
          tid.accum_num,    
          tid.qpp_num,    
          tid.trading_prd,    
          tid.qty_uom_code,    
          tid.trans_id    
   from dbo.aud_trade_item_dist tid  WITH (NOLOCK),    
        #plh plh    
   where tid.trade_num = plh.pl_secondary_owner_key1 AND    
         tid.order_num = plh.pl_secondary_owner_key2 AND    
         tid.item_num = plh.pl_secondary_owner_key3 AND    
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
       on #tids(trade_num, order_num, item_num, accum_num, qpp_num, trans_id)    
   create nonclustered index xx_878_tids_idx2    
       on #tids(dist_num, trans_id, is_equiv_ind)    
   create nonclustered index xx_878_tids_idx3    
       on #tids(real_port_num, trade_num, order_num, item_num, is_equiv_ind, trans_id)    
    
   delete tid1    
   from #tids tid1    
   where tid1.accum_num < (select max(accum_num)    
                           from #tids tid2    
                           where tid1.trade_num = tid2.trade_num and    
                                 tid1.order_num = tid2.order_num and    
                                 tid1.item_num = tid2.item_num)    
    
   -- If the trade has associated distributions, then get dist_nums    
   if @rows_affected > 0    
   begin    
      /* -------------------------------------------------    
          STEP: Updating dist_num and tid_trans_id in #plh    
         ------------------------------------------------- */       
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
            tid1.trans_id = (select max(trans_id)        
                             from #tids tid2     
                             where tid2.trade_num = tid1.trade_num AND    
                                   tid2.order_num = tid1.order_num AND    
                                   tid2.item_num = tid1.item_num)        
      select @rows_affected = @@rowcount    
      if @debugon = 1    
      begin    
         update @times    
         set endtime = getdate(),    
             rows_affected = @rows_affected    
         where oid = @stepid    
      end    
   end    
       
   /* ----------------------------------------------------    
       STEP: Getting quote_pricing_period information    
      ---------------------------------------------------- */       
   select @stepid = @stepid + 1    
   if @debugon = 1    
      insert into @times     
         (oid, step, starttime)    
        values(@stepid, 'Getting quote_pricing_period information', getdate())    
            
   create table #qpps    
   (    
      trade_num        int null,    
      order_num        smallint null,    
      item_num         smallint null,    
      accum_num        smallint null,    
      qpp_num          smallint null,    
      quote_end_date   datetime null,    
      trans_id         int null    
   )    
          
   insert into #qpps    
   select qpp.trade_num,    
          qpp.order_num,    
          qpp.item_num,    
          qpp.accum_num,    
          qpp.qpp_num,    
          qpp.quote_end_date,    
          qpp.trans_id    
   from dbo.quote_pricing_period qpp WITH (NOLOCK),    
        #plh plh    
   where qpp.trade_num = plh.pl_secondary_owner_key1 AND   
         qpp.order_num = plh.pl_secondary_owner_key2 AND    
         qpp.item_num = plh.pl_secondary_owner_key3 AND    
         qpp.trans_id <= plh.pl_trans_id    
   union    
   select qpp.trade_num,    
          qpp.order_num,    
          qpp.item_num,    
          qpp.accum_num,    
          qpp.qpp_num,    
          qpp.quote_end_date,    
          qpp.trans_id    
   from dbo.aud_quote_pricing_period qpp WITH (NOLOCK),    
        #plh plh    
   where qpp.trade_num = plh.pl_secondary_owner_key1 AND    
         qpp.order_num = plh.pl_secondary_owner_key2 AND    
         qpp.item_num = plh.pl_secondary_owner_key3 AND    
         qpp.trans_id <= plh.pl_trans_id    
   select @rows_affected = @@rowcount    
   if @debugon = 1    
   begin    
      update @times    
      set endtime = getdate(),    
          rows_affected = @rows_affected    
      where oid = @stepid    
   end    
    
   create nonclustered index xx_878_qpps_idx1    
      on #qpps(trade_num, order_num, item_num, accum_num, qpp_num, trans_id)    
    
   update q1    
   set quote_end_date = (select max(q2.quote_end_date)    
                         from #qpps q2    
                         where q1.trade_num = q2.trade_num and    
                               q1.order_num = q2.order_num and    
                               q1.item_num = q2.item_num)    
   from #qpps q1    
    
   create nonclustered index xx_plh_xx_idx5    
      on #plh(pl_secondary_owner_key1,    
              pl_secondary_owner_key2,    
              pl_secondary_owner_key3,    
              ti_trans_id)    
    
   create nonclustered index xx_plh_xx_idx6    
      on #plh(pl_secondary_owner_key1,    
              pl_secondary_owner_key2,    
              pl_secondary_owner_key3,    
              tiotcopt_trans_id)    
       
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
       plh.pl_trans_id,    
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
       ti.avg_price,    
       ti.price_curr_code,    
       ntid.p_s_ind as ntid_p_s_ind,    
       ti.brkr_num,    
       ti.brkr_comm_amt,    
       ti.contr_qty,           
       ytid.dist_num as dist_num_ytid,    
       ytid.dist_type,    
       ytid.dist_qty as dist_qty_ytid,    
       ytid.is_equiv_ind,    
       ytid.real_port_num as tid_real_port_num,    
       ytid.pos_num as pos_num_ytid,    
       ytid.p_s_ind as ytid_p_s_ind,    
       ytid.commkt_key,    
       ytid.accum_num,    
       ytid.qpp_num,    
       ytid.trading_prd as tid_trading_prd,    
       plh.order_type_code,    
       plh.acct_num as counterparty,    
       convert(char(10), plh.contr_date, 101) as contr_date,    
       plh.inhouse_ind,    
       convert(char(10), tiotcopt.exp_date, 101) as exp_date,    
       datediff(dd, @my_pl_asof_date, tiotcopt.exp_date) as offset,    
       tiotcopt.put_call_ind,    
       tiotcopt.premium,    
       tiotcopt.premium_prev,    
       tiotcopt.strike_price,    
       tiotcopt.premium_uom_code,    
       tiotcopt.premium_curr_code,    
       tiotcopt.strike_price_uom_code,    
       tiotcopt.strike_price_curr_code,   
       ti.brkr_acct_full_name,    
       ti.mkt_acct_full_name,    
       ntid.dist_num as dist_num_ntid,    
       ntid.pos_num as pos_num_ntid,    
       ntid.dist_qty as dist_qty_ntid,    
       ntid.qty_uom_code as qty_uom_code_ntid,    
       convert(char(10), tiotcopt.price_date_to, 101) as price_date_to,    
       convert(char(10), qpp.quote_end_date, 101) as quote_end_date,    
       datediff(dd, @my_pl_asof_date, qpp.quote_end_date) as qpp_offset    
    from #plh plh    
            INNER JOIN #items ti    
               ON ti.trade_num = plh.pl_secondary_owner_key1 AND     
                  ti.order_num = plh.pl_secondary_owner_key2 AND     
                  ti.item_num = plh.pl_secondary_owner_key3 AND     
                  ti.trans_id = plh.ti_trans_id    
            LEFT OUTER JOIN #item_otcopts tiotcopt    
               ON plh.pl_secondary_owner_key1 = tiotcopt.trade_num AND     
                  plh.pl_secondary_owner_key2 = tiotcopt.order_num AND     
                  plh.pl_secondary_owner_key3 = tiotcopt.item_num AND     
                  plh.tiotcopt_trans_id = tiotcopt.trans_id    
            INNER JOIN #tids ytid    
               ON ytid.real_port_num = plh.real_port_num AND     
                  ytid.trade_num = plh.pl_secondary_owner_key1 AND     
                  ytid.order_num = plh.pl_secondary_owner_key2 AND     
                  ytid.item_num = plh.pl_secondary_owner_key3 AND     
                  ytid.is_equiv_ind = 'Y' AND     
                  ytid.trans_id = (select max(trans_id)    
                                  from #tids ytid2    
                                  where ytid2.dist_num = ytid.dist_num)    
            INNER JOIN #qpps qpp    
               ON qpp.trade_num = ytid.trade_num AND     
                  qpp.order_num = ytid.order_num AND     
                  qpp.item_num = ytid.item_num AND     
                  qpp.qpp_num = ytid.qpp_num AND     
                  qpp.accum_num = ytid.accum_num AND     
                  qpp.trans_id in (select max(trans_id)    
                                   from #qpps qpp2    
  where qpp.trade_num = qpp2.trade_num and     
                                         qpp.order_num = qpp2.order_num and     
                                         qpp.item_num = qpp2.item_num and     
                                         qpp.accum_num = qpp2.accum_num and     
                                         qpp.qpp_num = qpp2.qpp_num)    
            INNER JOIN #tids ntid    
               ON ntid.dist_num = plh.pl_record_key AND     
                  ntid.is_equiv_ind = 'N' AND     
                  ntid.trans_id = (select max(trans_id)    
                                   from #tids ntid2    
                                   where ntid2.dist_num = ntid.dist_num and     
                                         ntid2.is_equiv_ind = 'N')                                  
   order by pl_record_key,    
            pl_secondary_owner_key1,    
            pl_secondary_owner_key2,    
            pl_secondary_owner_key3,    
            dist_num_ntid DESC    
   select @rows_affected = @@rowcount    
    
   if @debugon = 1    
   begin    
      update @times    
      set endtime = getdate(),    
          rows_affected = @rows_affected    
      where oid = @stepid    
      print ' '    
      select @smsg = 'usp_RVFile_otc_options: ' + convert(varchar, @rows_affected) + ' rows returned.'    
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
   drop table #item_otcopts    
   drop table #tids    
   drop table #qpps    
    
endofsp:    
drop table #plh    
return 0 
GO
GRANT EXECUTE ON  [dbo].[usp_RVFile_otc_options] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_RVFile_otc_options', NULL, NULL
GO
