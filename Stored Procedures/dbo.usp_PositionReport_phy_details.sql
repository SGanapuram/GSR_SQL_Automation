SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_PositionReport_phy_details] 
( 
   @pl_asof_date         datetime = null,  
   @top_port_num         int = 0,  
   @uom_code             char(8) = 'MB',
   @hedge_ind            char(1) = 'N',
   @debugon              bit = 0 
) 
as  
set nocount on
declare @rows_affected         int,  
        @smsg                  varchar(255),  
        @status                int,  
        @oid                   numeric(18, 0),  
        @stepid                smallint,  
        @session_started       varchar(30),  
        @session_ended         varchar(30),  
        @my_port_num           int,  
        @my_pl_asof_date       datetime,
        @my_uom_code           char(8),  
        @my_hedge_ind          char(1),
        @counter               int,
        @uom_code_conv_from    char(8), 
        @uom_code_conv_to      char(8),
        @sec_conversion_factor numeric(20, 8), 
        @sec_qty_uom_code      char(8),
        @cmdty_code            char(8),
        @conv_rate             numeric(20, 8)

   select @my_hedge_ind = @hedge_ind, 
          @my_pl_asof_date = @pl_asof_date,  
          @my_port_num = @top_port_num,
          @my_uom_code = @uom_code

   create table #currPlTrades
   (  
      trade_num			  int,  
      order_num			  int,  
      item_num			  int,
      real_port_num       int,
      dist_num			  int,
      asof_date           datetime
   )  

   create table #Physicals
   (  
      oid                         numeric(32,0) IDENTITY PRIMARY KEY,
      trade_num	                  int,  
      order_num                   int,  
      item_num                    int,  
      cmdty_code                  char(8),
      mkt_code                    char(8),
      commkt_key                  int null,
      trading_prd                 char(8),   
      dist_qty                    float null,      
      priced_qty                  float null,      
      unpriced_qty                float null,      
      qty_uom_code                char(8),    
      qty_uom_code_conv_to        char(4),  
      sec_conversion_factor       float null,
      sec_qty_uom_code            char(8) null,
      del_term_code               char(8) null,
      del_date_from               datetime null,
      del_date_to                 datetime null,
      del_loc_name		            varchar(40) null,
      formula_desc		            varchar(255) null,
      formula_type_desc		        varchar(255) null,
      price_uom_code              char(8) null,
      price_curr_code             char(8) null,
      trader_init                 char(8) null,  
      contract_date               datetime null, 
      acct_short_name             varchar(40) null,
      book_comp_short_name        varchar(40) null,
      trade_price                 float null,
      bbl_qty                     float null,
      report_qty                  float null,      
      curr_code                   char(8),  
      pos_num                     int null,
      mtm_mkt_price               float null,  
      mtm_mkt_price_curr_code     char(8) null,  
      mtm_mkt_price_uom_code      char(8) null,
      c_precision                 int,
      mot                         char(8),
      p_s_ind                     char(1)
   )  

   create table #tempOutput
	 (  
	    oid	                                   numeric(32,0) IDENTITY PRIMARY KEY,
      imbalance_ind                          char(1),
	    p_trade_num                            int,  
	    p_order_num                            int,  
	    p_item_num                             int,  
	    p_cmdty_code                           char(8),
	    p_mkt_code                             char(8),
	    p_trading_prd                          char(8),
	    p_priced_qty                           float null,      
	    p_unpriced_qty                         float null,      
	    p_contr_qty                            float null,      
	    p_dist_qty                             float null,      
	    p_qty_uom_code                         char(8),      
	    p_del_term_code                        char(8) null,
	    p_del_date_from                        datetime null,
	    p_del_date_to                          datetime null,
	    p_del_loc_name                         varchar(40) null,
	    p_formula_desc                         varchar(255) null,
	    p_formula_type_desc                    varchar(255) null,
	    p_trader_init                          char(8) null,  
	    p_contract_date                        datetime null, 
	    p_acct_short_name                      varchar(40) null,
	    p_book_comp_short_name                 varchar(40) null,
	    p_trade_price                          float null,
	    p_bbl_qty                              float null,
	    p_mtm_mkt_price                        float null,  
	    p_mtm_mkt_price_curr_code              char(8) null,  
	    p_mtm_mkt_price_uom_code               char(8) null,  
      p_precision	                           int,
	    p_mot                                  char(8) null,
	    s_trade_num                            int,  
	    s_order_num                            int,  
	    s_item_num                             int,  
	    s_cmdty_code                           char(8),
	    s_mkt_code                             char(8),
      s_trading_prd                          char(8),
	    s_priced_qty                           float null,      
	    s_unpriced_qty                         float null,      
	    s_contr_qty                            float null,      
	    s_dist_qty                             float null,      
	    s_qty_uom_code                         char(8),      
	    s_del_term_code                        char(8) null,
	    s_del_date_from                        datetime null,
	    s_del_date_to                          datetime null,
	    s_del_loc_name                         varchar(40) null,
	    s_formula_desc                         varchar(255) null,
	    s_formula_type_desc                    varchar(255) null,
	    s_trader_init                          char(8) null,  
	    s_contract_date                        datetime null, 
	    s_acct_short_name                      varchar(40) null,
	    s_book_comp_short_name                 varchar(40) null,
	    s_trade_price                          float null,
	    s_bbl_qty                              float null,
	    s_mtm_mkt_price                        float null,  
	    s_mtm_mkt_price_curr_code              char(8) null,  
	    s_mtm_mkt_price_uom_code               char(8) null,
      s_precision                            int,
	    s_mot                                  char(8) null,
	    curr_pl	                               float null,
	    prev_pl                                float null,
      imbalance_qty                          float null
	 )  

   create table #commodityMarkets
   (  
      oid                   numeric(32,0) IDENTITY PRIMARY KEY,
      cmdty_code            char(8),
      mkt_code              char(8),
      commkt_key            int,
      trading_prd           char(8),
      quantity              float null,
      mtm_price             float null
   )  

   create table #convrates
   (
      oid                       numeric(18, 0) IDENTITY PRIMARY KEY,
      uom_code_conv_from        char(4) not null, 
      uom_code_conv_to          char(4) not null, 
      sec_conversion_factor     numeric(20, 8) null, 
      sec_qty_uom_code          char(4) null, 
      cmdty_code                char(8) null, 
      conv_rate                 numeric(20, 8) null          
   )
   
   insert into #currPlTrades
      (trade_num,
       order_num,
       item_num,
       real_port_num,
       dist_num,
       asof_date)
   select distinct
	    pl_secondary_owner_key1,
	    pl_secondary_owner_key2,
	    pl_secondary_owner_key3,
	    real_port_num,
	    pl_record_owner_key,
	    pl_asof_date
   from dbo.pl_history
   where real_port_num = @my_port_num and 
		 pl_asof_date = @my_pl_asof_date and 
		 pl_owner_code = 'T' and 
		 pl_owner_sub_code = 'W' 

	     	            		     
   insert into #Physicals
      (trade_num,  
       order_num,  
       item_num,  
       cmdty_code,
       mkt_code,
	     commkt_key,
       trading_prd,
	     bbl_qty,
	     report_qty,   
       dist_qty,      
       priced_qty,      
       unpriced_qty,
       qty_uom_code,      
       qty_uom_code_conv_to,   
       sec_conversion_factor,
       sec_qty_uom_code,
       del_term_code,
       del_date_from,
       del_date_to,
       del_loc_name,
       trader_init,  
       contract_date, 
       acct_short_name,
       book_comp_short_name,
       trade_price,
       pos_num,
       mtm_mkt_price,
       mtm_mkt_price_curr_code,
       mtm_mkt_price_uom_code,
       price_uom_code,
       price_curr_code,
       c_precision,
       mot,
       p_s_ind)
   select 
      ti.trade_num,  
      ti.order_num,  
      ti.item_num,  
      cm.cmdty_code,
      cm.mkt_code,
      tidmtm.commkt_key,
      tidmtm.trading_prd,
      tidmtm.dist_qty * qty_uom_conv_rate,      
      tidmtm.dist_qty * qty_uom_conv_rate,      
      ABS(ti.contr_qty),
      tidmtm.priced_qty * qty_uom_conv_rate,      
      (tidmtm.dist_qty - tidmtm.priced_qty) * qty_uom_conv_rate,      
      tidmtm.qty_uom_code,      
      tidmtm.qty_uom_code_conv_to,
      tidmtm.sec_conversion_factor,
      tidmtm.sec_qty_uom_code,
      tiwp.del_term_code,
      tiwp.del_date_from,
      tiwp.del_date_to,
      l.loc_name,
      t.trader_init,  
      t.contr_date, 
      a1.acct_short_name, 
      a2.acct_short_name,
      tidmtm.avg_price,
      tidmtm.pos_num,
      pmtm.mtm_mkt_price,
      pmtm.mtm_mkt_price_curr_code,
      pmtm.mtm_mkt_price_uom_code,
      ti.price_uom_code,
      ti.price_curr_code,
      4,
      tiwp.mot_code,
      tidmtm.p_s_ind
   from	dbo.tid_mark_to_market tidmtm,
        #currPlTrades tmp, 
        dbo.trade_item ti
        	 LEFT OUTER JOIN dbo.account a2 
              ON a2.acct_num = ti.booking_comp_num,
        dbo.commodity_market cm,
        dbo.trade t
        	 LEFT OUTER JOIN dbo.account a1 
	            ON a1.acct_num = t.acct_num,  
        dbo.trade_item_wet_phy tiwp
           LEFT OUTER JOIN dbo.location l 
              ON l.loc_code = tiwp.del_loc_code,
        dbo.position_mark_to_market pmtm
   where tidmtm.dist_num = tmp.dist_num and 
         tidmtm.mtm_pl_asof_date = tmp.asof_date and 
         tmp.trade_num = ti.trade_num and 
         tmp.order_num = ti.order_num and 
         tmp.item_num = ti.item_num and
         ti.trade_num = t.trade_num and 
         ti.trade_num = tiwp.trade_num and 
         ti.order_num = tiwp.order_num and 
         ti.item_num = tiwp.item_num and
         ti.hedge_pos_ind = @my_hedge_ind and
         tidmtm.commkt_key = cm.commkt_key and 
         pmtm.pos_num = tidmtm.pos_num and 
         pmtm.mtm_asof_date = tmp.asof_date 
   order by contr_date, ti.trade_num, ti.order_num, ti.item_num

   /* Here, we copy the needed data items involved with calculation of conversion rate from
      #Physicals to #convrates
   */
   insert into #convrates	     
      (uom_code_conv_from, 
       uom_code_conv_to, 
       sec_conversion_factor, 
       sec_qty_uom_code, 
       cmdty_code, 
       conv_rate)          
   select distinct
      qty_uom_code_conv_to, 
      'BBL', 
      sec_conversion_factor, 
      qty_uom_code, 
      cmdty_code,
      0     
   from #Physicals

    
   insert into #convrates	     
      (uom_code_conv_from, 
       uom_code_conv_to, 
       sec_conversion_factor, 
       sec_qty_uom_code, 
       cmdty_code, 
       conv_rate)          
   select 
      uom_code_conv_from, 
      @my_uom_code, 
      sec_conversion_factor, 
      sec_qty_uom_code, 
      cmdty_code, 
      0    
   from #convrates
   where uom_code_conv_to = 'BBL'

   insert into #convrates	     
      (uom_code_conv_from, 
       uom_code_conv_to, 
       sec_conversion_factor, 
       sec_qty_uom_code, 
       cmdty_code, 
       conv_rate)          
   select distinct	
      mtm_mkt_price_uom_code, 
      'BBL', 
      null, 
      null, 
      cmdty_code,
      0    
   from #Physicals

   /* Here, we retrieve each record in the #convrates table and call the 'udf_getUomConversion' 
      function to get a conversion rate
   */
   select @oid = min(oid)
   from #convrates
   
   while @oid is not null
   begin
      select @uom_code_conv_from = uom_code_conv_from, 
             @uom_code_conv_to = uom_code_conv_to, 
             @sec_conversion_factor = sec_conversion_factor, 
             @sec_qty_uom_code = sec_qty_uom_code, 
             @cmdty_code = cmdty_code, 
             @conv_rate = conv_rate
      from #convrates
      where oid = @oid
      
/*      exec @status = dbo.usp_getUomConversion @uom_code_conv_from, 
                                              @uom_code_conv_to, 
                                              @sec_conversion_factor, 
                                              @sec_qty_uom_code, 
                                              @cmdty_code, 
                                              @conv_rate output
*/
      update #convrates
      set conv_rate = dbo.udf_getUomConversion(@uom_code_conv_from, 
                                               @uom_code_conv_to, 
                                               @sec_conversion_factor, 
                                               @sec_qty_uom_code, 
                                               @cmdty_code)
      where oid = @oid
                                              
      select @oid = min(oid)
      from #convrates
      where oid > @oid
   end

   update p
   set bbl_qty = ABS(bbl_qty * cv.conv_rate) 
   from #Physicals p,
        #convrates cv
   where p.qty_uom_code_conv_to = cv.uom_code_conv_from and
         cv.uom_code_conv_to = 'BBL' and
         p.sec_conversion_factor = cv.sec_conversion_factor and
         p.sec_qty_uom_code = cv.sec_qty_uom_code and
         p.cmdty_code = cv.cmdty_code

   update p
   set report_qty = ABS(report_qty * cv.conv_rate),  
       priced_qty = ABS(priced_qty * cv.conv_rate),      
       unpriced_qty = ABS(unpriced_qty * cv.conv_rate)
   from #Physicals p,
        #convrates cv
   where p.qty_uom_code_conv_to = cv.uom_code_conv_from and
         cv.uom_code_conv_to = @my_uom_code and
         p.sec_conversion_factor = cv.sec_conversion_factor and
         p.sec_qty_uom_code = cv.sec_qty_uom_code and
         p.cmdty_code = cv.cmdty_code
         
   update p
   set trade_price = trade_price / cv.conv_rate,
       mtm_mkt_price = mtm_mkt_price  / cv.conv_rate
   from #Physicals p,
        #convrates cv
   where p.qty_uom_code_conv_to = cv.uom_code_conv_from and
         cv.uom_code_conv_to = 'BBL' and
         p.sec_conversion_factor IS NULL and
         p.sec_qty_uom_code IS NULL and
         p.cmdty_code = cv.cmdty_code
                
   update t1
   set formula_desc = formula_body_string + ' ' + rtrim(price_curr_code) + '/' + rtrim(price_uom_code), 
	   c_precision = formula_precision,
	   formula_type_desc = 'f(' + f.formula_type + (CASE WHEN event_name is not NULL THEN '-' + event_name ELSE '' 
	                                                END)  + ') '
   from #Physicals t1
            RIGHT OUTER JOIN dbo.trade_formula tf
               ON t1.trade_num = tf.trade_num and 
                  t1.order_num = tf.order_num and 
                  t1.item_num = tf.item_num,
        dbo.formula f 
            LEFT OUTER JOIN dbo.event_price_term ept
               ON f.formula_num = ept.formula_num, 
        dbo.formula_body fb
   where tf.fall_back_ind = 'N' and 
         tf.formula_num = f.formula_num and 
         f.formula_num = fb.formula_num and 
         fb.formula_body_type = 'P'
                  
   insert into #commodityMarkets
      (cmdty_code,
       mkt_code,
       commkt_key,
       trading_prd)
   select distinct
      cmdty_code, 
      mkt_code,commkt_key,
      trading_prd 
   from #Physicals
   
   update t1
   set trading_prd = t2.trading_prd_desc
   from #Physicals t1, 
        dbo.trading_period t2
   where t1.commkt_key = t2.commkt_key and 
         t1.trading_prd = t2.trading_prd

 
   declare @purchaseCount                     int,
           @saleCount                         int,
           @lcl2_trade_num                    int,  
           @lcl2_order_num                    int,  
           @lcl2_item_num                     int,  
           @lcl2_cmdty_code                   char(8),
           @lcl2_mkt_code                     char(8),
           @lcl2_trading_prd                  char(8),
           @lcl2_priced_qty                   float,      
           @lcl2_unpriced_qty                 float,      
           @lcl2_qty_uom_code                 char(8),      
           @lcl2_del_term_code                char(8),
           @lcl2_del_date_from                datetime,
           @lcl2_del_date_to                  datetime,
           @lcl2_del_loc_name                 varchar(40),
           @lcl2_formula_desc                 varchar(255),
           @lcl2_formula_type_desc            varchar(255),
           @lcl2_trader_init                  char(8),  
           @lcl2_contract_date                datetime, 
           @lcl2_acct_short_name              varchar(40),
           @lcl2_book_comp_short_name         varchar(40),
           @lcl2_trade_price                  float,
           @lcl2_bbl_qty                      float,
           @lcl2_contr_qty                    float,      
           @lcl2_dist_qty                     float,
           @lcl2_mtm_mkt_price                float,  
           @lcl2_mtm_mkt_price_curr_code      char(8),  
           @lcl2_mtm_mkt_price_uom_code       char(8),
           @lcl2_mot                          char(8),
           @lcl2_precision                    int,
           @lcl1_cmdty_code                   char(8),
           @lcl1_mkt_code                     char(8),
           @lcl1_trading_prd                  char(8),
           @lcl1_trade_price                  float,
           @lcl1_mtm_mkt_price                float,
           @lcl1_contr_qty                    float
			

   select @purchaseCount = count(*) from #Physicals where p_s_ind = 'P'
   select @saleCount = count(*) from #Physicals where p_s_ind = 'S'

   if @purchaseCount >= @saleCount
   begin
      insert into #tempOutput 
      (
         imbalance_ind,
         p_trade_num,  
         p_order_num,  
         p_item_num,  
         p_cmdty_code,
         p_mkt_code,
         p_trading_prd,
         p_priced_qty,
         p_unpriced_qty,      
         p_qty_uom_code,      
         p_del_term_code,
         p_del_date_from,
         p_del_date_to,
         p_del_loc_name,
         p_formula_desc,
         p_formula_type_desc,
         p_trader_init,  
         p_contract_date, 
         p_acct_short_name,
         p_book_comp_short_name,
         p_trade_price,
         p_bbl_qty,
         p_contr_qty, 
         p_dist_qty,
         p_mtm_mkt_price,  
         p_mtm_mkt_price_curr_code,  
         p_mtm_mkt_price_uom_code,
         p_precision,
         p_mot
      )
      select 			
         'N',	
         trade_num,  
         order_num,  
         item_num,  
         cmdty_code,
         mkt_code,
         trading_prd,
         priced_qty,      
         unpriced_qty,      
         qty_uom_code,      
         del_term_code,
         del_date_from,
         del_date_to,
         del_loc_name,
         formula_desc,
         formula_type_desc,
         trader_init,  
         contract_date, 
         acct_short_name,
         book_comp_short_name,
         ROUND(trade_price, c_precision),
         bbl_qty,
         report_qty,
         dist_qty,
         ROUND(mtm_mkt_price, c_precision),
         mtm_mkt_price_curr_code,
         mtm_mkt_price_uom_code,
         c_precision,
         mot
      from #Physicals
      where p_s_ind = 'P'
      order by oid
	
      declare sale_trade_cursor cursor for 
         select trade_num,  
                order_num,  
                item_num,  
                cmdty_code,
                mkt_code,
                trading_prd,
                priced_qty,      
                unpriced_qty,      
                qty_uom_code,      
                del_term_code,
                del_date_from,
                del_date_to,
                del_loc_name,
                formula_desc,
                formula_type_desc,
                trader_init,  
                contract_date, 
                acct_short_name,
                book_comp_short_name,
                ROUND(trade_price, c_precision),
                bbl_qty,
                report_qty,
                dist_qty,
                ROUND(mtm_mkt_price, c_precision),
                mtm_mkt_price_curr_code,
                mtm_mkt_price_uom_code,
                c_precision,
                mot
         from #Physicals
         where p_s_ind = 'S'
         order by oid
	
      select @counter = 1
	
      open sale_trade_cursor	
      fetch next from sale_trade_cursor into 
             @lcl2_trade_num,  
             @lcl2_order_num,  
				     @lcl2_item_num,  
				     @lcl2_cmdty_code,
				     @lcl2_mkt_code,
             @lcl2_trading_prd,
				     @lcl2_priced_qty ,      
				     @lcl2_unpriced_qty,      
				     @lcl2_qty_uom_code,      
				     @lcl2_del_term_code,
				     @lcl2_del_date_from,
				     @lcl2_del_date_to,
				     @lcl2_del_loc_name,
				     @lcl2_formula_desc,
				     @lcl2_formula_type_desc,
				     @lcl2_trader_init	,  
				     @lcl2_contract_date, 
				     @lcl2_acct_short_name,
				     @lcl2_book_comp_short_name,
				     @lcl2_trade_price,
				     @lcl2_bbl_qty,
				     @lcl2_contr_qty,
				     @lcl2_dist_qty,
				     @lcl2_mtm_mkt_price,  
				     @lcl2_mtm_mkt_price_curr_code,  
				     @lcl2_mtm_mkt_price_uom_code,
				     @lcl2_precision,
				     @lcl2_mot
	
      while @@FETCH_STATUS = 0
      begin
         update #tempOutput
         set s_trade_num = @lcl2_trade_num,  
             s_order_num = @lcl2_order_num,  
             s_item_num = @lcl2_item_num,  
             s_cmdty_code = @lcl2_cmdty_code,
             s_mkt_code = @lcl2_mkt_code,
             s_trading_prd = @lcl2_trading_prd,
             s_priced_qty = @lcl2_priced_qty,      
             s_unpriced_qty = @lcl2_unpriced_qty,      
             s_qty_uom_code = @lcl2_qty_uom_code,      
             s_del_term_code = @lcl2_del_term_code,
             s_del_date_from = @lcl2_del_date_from,
             s_del_date_to = @lcl2_del_date_to,
             s_del_loc_name = @lcl2_del_loc_name,
             s_formula_desc = @lcl2_formula_desc,
             s_formula_type_desc = @lcl2_formula_type_desc,
             s_trader_init = @lcl2_trader_init,  
             s_contract_date = @lcl2_contract_date, 
             s_acct_short_name = @lcl2_acct_short_name,
             s_book_comp_short_name = @lcl2_book_comp_short_name,
             s_trade_price = @lcl2_trade_price,
             s_bbl_qty = @lcl2_bbl_qty,
             s_contr_qty = @lcl2_contr_qty,      
             s_dist_qty = @lcl2_dist_qty,
             s_mtm_mkt_price = @lcl2_mtm_mkt_price,  
             s_mtm_mkt_price_curr_code = @lcl2_mtm_mkt_price_curr_code,  
             s_mtm_mkt_price_uom_code = @lcl2_mtm_mkt_price_uom_code,
             s_precision = @lcl2_precision,
             s_mot = @lcl2_mot
         where oid = @counter
	
         fetch next from sale_trade_cursor into 
                @lcl2_trade_num,  
					      @lcl2_order_num,  
					      @lcl2_item_num,  
					      @lcl2_cmdty_code,
					      @lcl2_mkt_code,
                @lcl2_trading_prd,
					      @lcl2_priced_qty ,      
					      @lcl2_unpriced_qty,      
					      @lcl2_qty_uom_code,      
					      @lcl2_del_term_code,
					      @lcl2_del_date_from,
					      @lcl2_del_date_to,
					      @lcl2_del_loc_name,
					      @lcl2_formula_desc,
					      @lcl2_formula_type_desc,
					      @lcl2_trader_init	,  
					      @lcl2_contract_date, 
					      @lcl2_acct_short_name,
					      @lcl2_book_comp_short_name,
					      @lcl2_trade_price,
					      @lcl2_bbl_qty,
					      @lcl2_contr_qty,     
					      @lcl2_dist_qty,
					      @lcl2_mtm_mkt_price,  
					      @lcl2_mtm_mkt_price_curr_code,  
					      @lcl2_mtm_mkt_price_uom_code,
					      @lcl2_precision,
					      @lcl2_mot
	
         select @counter = @counter + 1
      end /* while */
      close sale_trade_cursor
      deallocate sale_trade_cursor
   end
   else 
   begin
      insert into #tempOutput 
      (
         imbalance_ind,
         s_trade_num,  
         s_order_num,  
         s_item_num,  
         s_cmdty_code,
         s_mkt_code,
         s_trading_prd,
         s_priced_qty,      
         s_unpriced_qty,      
         s_qty_uom_code,      
         s_del_term_code,
         s_del_date_from,
         s_del_date_to,
         s_del_loc_name,
         s_formula_desc,
         s_formula_type_desc,
         s_trader_init,  
         s_contract_date, 
         s_acct_short_name,
         s_book_comp_short_name,
         s_trade_price,
         s_bbl_qty,
         s_contr_qty,      
         s_dist_qty,
         s_mtm_mkt_price,  
         s_mtm_mkt_price_curr_code,  
         s_mtm_mkt_price_uom_code,
         s_precision,
         s_mot
      )
      select 			
         'N',	
         trade_num,  
         order_num,  
         item_num,  
         cmdty_code,
         mkt_code,
         trading_prd,
         priced_qty,      
         unpriced_qty,      
         qty_uom_code,      
         del_term_code,
         del_date_from,
         del_date_to,
         del_loc_name,
         formula_desc,
         formula_type_desc,
         trader_init,  
         contract_date, 
         acct_short_name,
         book_comp_short_name,
         ROUND(trade_price, c_precision),
         bbl_qty,
         report_qty,
         dist_qty,
         ROUND(mtm_mkt_price, c_precision),
         mtm_mkt_price_curr_code,
         mtm_mkt_price_uom_code,
         c_precision,
         mot
      from #Physicals
      where p_s_ind = 'S'
      order by oid

      declare purch_trade_cursor cursor for 
         select trade_num,  
				        order_num,  
				        item_num,  
				        cmdty_code,
				        mkt_code,
				        trading_prd,
				        priced_qty,      
				        unpriced_qty,      
				        qty_uom_code,      
				        del_term_code,
				        del_date_from,
				        del_date_to,
				        del_loc_name,
				        formula_desc,
				        formula_type_desc,
				        trader_init,  
				        contract_date, 
				        acct_short_name,
				        book_comp_short_name,
				        ROUND(trade_price, c_precision),
				        bbl_qty,
				        report_qty,
				        dist_qty,
				        ROUND(mtm_mkt_price, c_precision),
				        mtm_mkt_price_curr_code,
				        mtm_mkt_price_uom_code,
				        c_precision,
				        mot
         from #Physicals
         where p_s_ind = 'P'
         order by oid
	
      select @counter = 1
	
      open purch_trade_cursor	
      fetch next from purch_trade_cursor into 
             @lcl2_trade_num,  
				     @lcl2_order_num,  
				     @lcl2_item_num,  
				     @lcl2_cmdty_code,
				     @lcl2_mkt_code,
             @lcl2_trading_prd,
				     @lcl2_priced_qty ,      
				     @lcl2_unpriced_qty,      
				     @lcl2_qty_uom_code,      
				     @lcl2_del_term_code,
				     @lcl2_del_date_from,
				     @lcl2_del_date_to,
				     @lcl2_del_loc_name,
				     @lcl2_formula_desc,
				     @lcl2_formula_type_desc,
				     @lcl2_trader_init	,  
				     @lcl2_contract_date, 
				     @lcl2_acct_short_name,
				     @lcl2_book_comp_short_name,
				     @lcl2_trade_price,
				     @lcl2_bbl_qty,
				     @lcl2_contr_qty,
				     @lcl2_dist_qty,
				     @lcl2_mtm_mkt_price,  
				     @lcl2_mtm_mkt_price_curr_code,  
				     @lcl2_mtm_mkt_price_uom_code,
				     @lcl2_precision,
				     @lcl2_mot
	
      while @@FETCH_STATUS = 0
      begin
         update #tempOutput
         set p_trade_num = @lcl2_trade_num,  
             p_order_num = @lcl2_order_num,  
             p_item_num = @lcl2_item_num,  
             p_cmdty_code = @lcl2_cmdty_code,
             p_mkt_code = @lcl2_mkt_code,
             p_trading_prd = @lcl2_trading_prd,
             p_priced_qty = @lcl2_priced_qty,      
             p_unpriced_qty = @lcl2_unpriced_qty,      
             p_qty_uom_code = @lcl2_qty_uom_code,      
             p_del_term_code = @lcl2_del_term_code,
             p_del_date_from = @lcl2_del_date_from,
             p_del_date_to = @lcl2_del_date_to,
             p_del_loc_name = @lcl2_del_loc_name,
             p_formula_desc = @lcl2_formula_desc,
             p_formula_type_desc = @lcl2_formula_type_desc,
             p_trader_init = @lcl2_trader_init,  
             p_contract_date = @lcl2_contract_date, 
             p_acct_short_name = @lcl2_acct_short_name,
             p_book_comp_short_name = @lcl2_book_comp_short_name,
             p_trade_price = @lcl2_trade_price,
             p_bbl_qty = @lcl2_bbl_qty,
             p_contr_qty = @lcl2_contr_qty,      
             p_dist_qty = @lcl2_dist_qty,
             p_mtm_mkt_price = @lcl2_mtm_mkt_price,  
             p_mtm_mkt_price_curr_code = @lcl2_mtm_mkt_price_curr_code,  
             p_mtm_mkt_price_uom_code = @lcl2_mtm_mkt_price_uom_code,
             p_precision = @lcl2_precision,
             p_mot = @lcl2_mot
         where oid = @counter
	
         fetch next from purch_trade_cursor into 
                @lcl2_trade_num,  
					      @lcl2_order_num,  
					      @lcl2_item_num,  
					      @lcl2_cmdty_code,
					      @lcl2_mkt_code,
                @lcl2_trading_prd,
					      @lcl2_priced_qty ,      
					      @lcl2_unpriced_qty,      
					      @lcl2_qty_uom_code,      
					      @lcl2_del_term_code,
					      @lcl2_del_date_from,
					      @lcl2_del_date_to,
					      @lcl2_del_loc_name,
					      @lcl2_formula_desc,
					      @lcl2_formula_type_desc,
					      @lcl2_trader_init	,  
					      @lcl2_contract_date, 
					      @lcl2_acct_short_name,
					      @lcl2_book_comp_short_name,
					      @lcl2_trade_price,
					      @lcl2_bbl_qty,
					      @lcl2_contr_qty,     
					      @lcl2_dist_qty,
					      @lcl2_mtm_mkt_price,  
					      @lcl2_mtm_mkt_price_curr_code,  
					      @lcl2_mtm_mkt_price_uom_code,
					      @lcl2_precision,
					      @lcl2_mot
	
         select @counter = @counter +1
      end	
	    close purch_trade_cursor
      deallocate purch_trade_cursor
   end	

   -- CALCULATE PL
   declare @purchaseQty       float,
           @saleQty           float,
           @purchaseBblQty    float,
           @saleBblQty        float,
           @avgPurchPrice     numeric(20,8)

   select @purchaseQty = sum(isnull(report_qty, 0.0)),
          @purchaseBblQty = sum(isnull(bbl_qty, 0.0))
   from #Physicals 
   where p_s_ind = 'P'
    
   select @saleQty = sum(isnull(report_qty, 0.0)),
	      @saleBblQty = sum(isnull(bbl_qty, 0.0))
   from #Physicals 
   where p_s_ind = 'S'

   select @avgPurchPrice = sum(isnull(p_bbl_qty, 0) * isnull(p_trade_price, 0)) / sum(isnull(p_bbl_qty, 1))  
   from #tempOutput 

   if @purchaseCount = 0 
   begin
      select @purchaseQty = 0.0
      select @purchaseBblQty = 0.0
      select @avgPurchPrice = NULL
   end
	
   if @saleCount = 0
   begin
      select @saleQty = 0.0
      select @saleBblQty = 0.0
   end

   select @smsg = 'Purchase count ' + cast(@purchaseCount as varchar)
   print @smsg
   select @smsg = 'sale count ' + cast(@saleCount as varchar)
   print @smsg
   select @smsg = 'Purchase qty ' + cast(@purchaseQty as varchar)
   print @smsg
   select @smsg = 'sale qty ' + cast(@saleQty as varchar)
   print @smsg
   select @smsg = 'purcg price ' + cast(@avgPurchPrice as varchar) 
   print @smsg	
   select @smsg = 'purcg @saleBblQty ' + cast(@saleBblQty as varchar)
   print @smsg 	
   select @smsg = 'purcg @purchaseBblQty ' + cast(@purchaseBblQty as varchar) 
   print @smsg

   -- CREATE IMBALANCE
   if @purchaseQty >= @saleQty 
   begin
      update #tempOutput
      set imbalance_qty = p_contr_qty

      declare outer_cursor1 cursor for 
         select s_contr_qty
         from #tempOutput
         where s_trade_num is not NULL
         order by oid

      open outer_cursor1
      fetch next from outer_cursor1 into @lcl1_contr_qty

      while @@FETCH_STATUS = 0
      begin
         declare inner_cursor cursor for 
             select oid,
                    imbalance_qty
             from #tempOutput
             where imbalance_qty is not NULL
             order by oid
				
         open inner_cursor	
         fetch next from inner_cursor into @oid, @lcl2_contr_qty

         while @@FETCH_STATUS = 0
         begin
            if @lcl1_contr_qty >= @lcl2_contr_qty
            begin
               select @lcl1_contr_qty = (@lcl1_contr_qty - @lcl2_contr_qty)
							  
               update #tempOutput 
               set imbalance_qty = NULL 
               where oid = @oid
            end	 					
            else
            begin
               update #tempOutput 
               set imbalance_qty = (@lcl2_contr_qty - @lcl1_contr_qty) 							  
               where oid = @oid
                
               select @lcl1_contr_qty = 0 
               break
            end	 					

            fetch next from inner_cursor into @oid, @lcl2_contr_qty
         end
         close inner_cursor
         deallocate inner_cursor

         fetch next from outer_cursor1 into @lcl1_contr_qty
      end
      close outer_cursor1
      deallocate outer_cursor1

      -- PL Calculation
      if @saleCount > 0 
      begin
         update #tempOutput
         set curr_pl = (s_trade_price - CASE when @avgPurchPrice is NOT NULL THEN @avgPurchPrice ELSE s_mtm_mkt_price 
					                     END) * s_bbl_qty 
         where s_trade_num is not NULL
      end

      insert into #tempOutput 
      (
         s_cmdty_code,
         s_mkt_code,
         s_trading_prd,
         imbalance_ind,
         s_dist_qty,
         s_mtm_mkt_price,
         curr_pl
      )
      select p_cmdty_code,
             p_mkt_code,
             p_trading_prd,
             'Y',
             SUM(ABS(isnull(imbalance_qty, 0))), 
             AVG(p_mtm_mkt_price),
             SUM(ABS(isnull(imbalance_qty, 0)) * p_bbl_qty / p_contr_qty) * (AVG(p_mtm_mkt_price) - @avgPurchPrice)			
      from #tempOutput 
      where imbalance_qty is not NULL
      group by p_cmdty_code, p_mkt_code, p_trading_prd
   end
   else
   begin
      update #tempOutput
      set imbalance_qty = s_contr_qty

      declare outer_cursor1 cursor for 
         select p_contr_qty
         from #tempOutput
         where p_trade_num is not NULL
         order by oid

      open outer_cursor1
      fetch next from outer_cursor1 into @lcl1_contr_qty

      while @@FETCH_STATUS = 0
      begin
         declare inner_cursor cursor for 
            select oid,
                   imbalance_qty
            from #tempOutput
            where imbalance_qty is not NULL
            order by oid
				
         open inner_cursor	
         fetch next from inner_cursor into @oid, @lcl2_contr_qty

         while @@FETCH_STATUS = 0
         begin
            if @lcl1_contr_qty >= @lcl2_contr_qty
            begin
               select @lcl1_contr_qty = (@lcl1_contr_qty - @lcl2_contr_qty)
						 	 
               update #tempOutput 
               set imbalance_qty = NULL 
               where oid = @oid
            end	 					
            else
            begin
               update #tempOutput 
               set imbalance_qty = (@lcl2_contr_qty - @lcl1_contr_qty) 
               where oid = @oid
							
               select @lcl1_contr_qty = 0 
               break
            end	 					

            fetch next from inner_cursor into @oid, @lcl2_contr_qty
         end
         close inner_cursor
         deallocate inner_cursor

         fetch next from outer_cursor1 into @lcl1_contr_qty
      end
      close outer_cursor1
      deallocate outer_cursor1

      -- PL Calculation
      update #tempOutput
      set curr_pl = (s_trade_price - CASE when @avgPurchPrice is NOT NULL THEN @avgPurchPrice ELSE 0 
			                          END) * ((s_bbl_qty * s_contr_qty) / s_contr_qty)
      where s_trade_num is not NULL

      insert into #tempOutput 
      (
         p_cmdty_code,
         p_mkt_code,
         p_trading_prd,
         imbalance_ind,
         p_dist_qty,
         p_mtm_mkt_price,
         curr_pl
      )
      select s_cmdty_code,
             s_mkt_code,
             s_trading_prd,
             'Y',
             SUM(ABS(isnull(imbalance_qty,0))), 
             AVG(s_mtm_mkt_price),
             SUM(-1.0 * ABS(isnull(imbalance_qty,0))*s_bbl_qty / s_contr_qty) * 
             (AVG(s_mtm_mkt_price) - CASE when @avgPurchPrice is NOT NULL THEN @avgPurchPrice ELSE 0 
					                  END)			
      from #tempOutput 
      where imbalance_qty is not NULL
      group by s_cmdty_code, s_mkt_code, s_trading_prd
   end

   select 
      imbalance_ind,
      p_trade_num,  
      p_order_num,  
      p_item_num,  
      p_cmdty_code,
      p_mkt_code,
      p_trading_prd,
      p_priced_qty,      
      p_unpriced_qty,      
      p_qty_uom_code,      
      p_del_term_code,
      p_del_date_from,
      p_del_date_to,
      p_del_loc_name,
      p_formula_desc,
      p_formula_type_desc,
      p_trader_init,  
      p_contract_date, 
      p_acct_short_name,
      p_book_comp_short_name,
      p_trade_price,
      p_bbl_qty,
      p_dist_qty,      
      p_mtm_mkt_price,  
      p_mtm_mkt_price_curr_code,  
      p_mtm_mkt_price_uom_code,  
      p_precision,
      p_mot,
      s_trade_num,  
      s_order_num,  
      s_item_num,  
      s_cmdty_code,
      s_mkt_code,
      s_trading_prd,
      s_priced_qty,      
      s_unpriced_qty,      
      s_qty_uom_code,      
      s_del_term_code,
      s_del_date_from,
      s_del_date_to,
      s_del_loc_name,
      s_formula_desc,
      s_formula_type_desc,
      s_trader_init,  
      s_contract_date, 
      s_acct_short_name,
      s_book_comp_short_name,
      s_trade_price,
      s_bbl_qty,
      s_dist_qty,      
      s_mtm_mkt_price,  
      s_mtm_mkt_price_curr_code,  
      s_mtm_mkt_price_uom_code,
      s_precision,
      s_mot,
      curr_pl,
      imbalance_qty  
   from #tempOutput

   drop table #tempOutput
   drop table #Physicals
   drop table #commodityMarkets
   drop table #convrates
   drop table #currPlTrades

endofsp:  
   return 0  
GO
GRANT EXECUTE ON  [dbo].[usp_PositionReport_phy_details] TO [next_usr]
GO
