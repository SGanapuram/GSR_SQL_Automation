SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_PositionReport_physicals] 
( 
   @pl_asof_date         datetime = null,  
   @top_port_num         int = 0,  
   @uom_code             char(8) = 'MB',
   @hedge_ind            char(1) = 'N',
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
        @my_port_num       int,  
        @my_asof_date      datetime,
        @my_uom_code       char(8),
        @my_prev_asof_date datetime,  
        @my_hedge_ind      char(1)

   select @my_hedge_ind = @hedge_ind,
          @my_asof_date = @pl_asof_date,  
          @my_port_num = @top_port_num,
          @my_uom_code = @uom_code

   create table #curr_output
   (  
      oid			                      numeric(32,0),
	    imbalance_ind			            char,
      p_trade_num			              int,  
      p_order_num			              int,  
      p_item_num                    int,  
      p_cmdty_code	       	        char(8),
      p_mkt_code              	    char(8),
	    p_trading_prd			            char(8),
      p_priced_qty               	  float null,      
      p_unpriced_qty             	  float null,      
      p_contr_qty		                float null,      
      p_qty_uom_code	       	      char(8),      
      p_del_term_code		            char(8) null,
      p_del_date_from		            datetime null,
      p_del_date_to		              datetime null,
      p_del_loc_name		            varchar(40) null,
      p_formula_desc		            varchar(255) null,
      p_formula_type_desc	          varchar(255) null,
      p_trader_init	                char(8) null,  
      p_contract_date               datetime null, 
      p_acct_short_name		          varchar(40) null,
      p_book_comp_short_name	      varchar(40) null,
      p_trade_price		              float null,
      p_bbl_qty			                float null,
      p_mtm_mkt_price            	  float null,  
      p_mtm_mkt_price_curr_code   	char(8) null,  
      p_mtm_mkt_price_uom_code    	char(8) null,  
      p_precision			              float null,
      p_mot			    	              char(8) null,  
      s_trade_num					          int,  
      s_order_num					          int,  
      s_item_num                	  int,  
      s_cmdty_code	       			    char(8),
      s_mkt_code              		  char(8),
	    s_trading_prd			            char(8),
      s_priced_qty               	  float null,      
      s_unpriced_qty             	  float null,      
      s_contr_qty					          float null,      
      s_qty_uom_code	       		    char(8),      
      s_del_term_code				        char(8) null,
      s_del_date_from				        datetime null,
      s_del_date_to					        datetime null,
      s_del_loc_name				        varchar(40) null,
      s_formula_desc		            varchar(255) null,
      s_formula_type_desc	          varchar(255) null,
      s_trader_init	        		    char(8) null,  
      s_contract_date             	datetime null, 
      s_acct_short_name				      varchar(40) null,
      s_book_comp_short_name		    varchar(40) null,
      s_trade_price					        float null,
      s_bbl_qty						          float null,
      s_mtm_mkt_price            	  float null,  
      s_mtm_mkt_price_curr_code   	char(8) null,  
      s_mtm_mkt_price_uom_code    	char(8) null,
      s_precision			              float null,
      s_mot			    	              char(8) null,  
      curr_pl						            float null,
      prev_pl						            float null,
	    imbalance_qty					        float null
   )  

   create table #prev_output
   (  
      oid			                      numeric(32,0),
	    imbalance_ind			            char,
      p_trade_num			              int,  
      p_order_num			              int,  
      p_item_num                    int,  
      p_cmdty_code	       	        char(8),
      p_mkt_code              	    char(8),
	    p_trading_prd			            char(8),
      p_priced_qty               	  float null,      
      p_unpriced_qty             	  float null,      
      p_contr_qty		                float null,      
      p_qty_uom_code	       	      char(8),      
      p_del_term_code		            char(8) null,
      p_del_date_from		            datetime null,
      p_del_date_to		              datetime null,
      p_del_loc_name		            varchar(40) null,
      p_formula_desc		            varchar(255) null,
      p_formula_type_desc	          varchar(255) null,
      p_trader_init	                char(8) null,  
      p_contract_date               datetime null, 
      p_acct_short_name		          varchar(40) null,
      p_book_comp_short_name	      varchar(40) null,
      p_trade_price		              float null,
      p_bbl_qty			                float null,
      p_mtm_mkt_price            	  float null,  
      p_mtm_mkt_price_curr_code   	char(8) null,  
      p_mtm_mkt_price_uom_code    	char(8) null,  
      p_precision			              float null,
      p_mot			    	              char(8) null,  
      s_trade_num					          int,  
      s_order_num					          int,  
      s_item_num                	  int,  
      s_cmdty_code	       			    char(8),
      s_mkt_code              		  char(8),
	    s_trading_prd			            char(8),
      s_priced_qty               	  float null,      
      s_unpriced_qty             	  float null,      
      s_contr_qty					          float null,      
      s_qty_uom_code	       		    char(8),      
      s_del_term_code				        char(8) null,
      s_del_date_from				        datetime null,
      s_del_date_to					        datetime null,
      s_del_loc_name				        varchar(40) null,
      s_formula_desc		            varchar(255) null,
      s_formula_type_desc	          varchar(255) null,
      s_trader_init	        		    char(8) null,  
      s_contract_date             	datetime null, 
      s_acct_short_name				      varchar(40) null,
      s_book_comp_short_name		    varchar(40) null,
      s_trade_price					        float null,
      s_bbl_qty						          float null,
      s_mtm_mkt_price            	  float null,  
      s_mtm_mkt_price_curr_code   	char(8) null,  
      s_mtm_mkt_price_uom_code    	char(8) null,
      s_precision			              float null,
      s_mot			    	              char(8) null,  
      curr_pl						            float null,
      prev_pl						            float null,
	    imbalance_qty					        float null
   )  
 
   select @my_prev_asof_date = CONVERT(varchar, max(pl_asof_date), 101)
   from dbo.portfolio_profit_loss
   where port_num = @my_port_num and 
         pl_asof_date < @my_asof_date

   insert into #curr_output 
      exec dbo.usp_PositionReport_phy_details @my_asof_date, @my_port_num, @my_uom_code, @my_hedge_ind

   insert into #prev_output 
      exec dbo.usp_PositionReport_phy_details @my_prev_asof_date, @my_port_num, @my_uom_code, @my_hedge_ind

   delete #prev_output where curr_pl is NULL

   -- Updating Prev PL for matching Sale TradeItem
   update t1
   set prev_pl = t2.curr_pl
   from #curr_output t1, 
        #prev_output t2
   where t1.s_trade_num = t2.s_trade_num and
         t1.s_order_num = t2.s_order_num and
         t1.s_item_num = t2.s_item_num and
         t1.imbalance_ind = t2.imbalance_ind and
         t1.imbalance_ind = 'N'

   delete t2
   from #curr_output t1, 
        #prev_output t2
   where t1.s_trade_num = t2.s_trade_num and
         t1.s_order_num = t2.s_order_num and
         t1.s_item_num = t2.s_item_num and
         t1.imbalance_ind = t2.imbalance_ind and
         t1.imbalance_ind = 'N'

   -- Updating Prev PL for matching Imbalance rows
   update t1
   set prev_pl = t2.curr_pl
   from #curr_output t1, 
        #prev_output t2
   where ((t1.s_cmdty_code = t2.s_cmdty_code and
           t1.s_mkt_code = t2.s_mkt_code) or
          (t1.p_cmdty_code = t2.p_cmdty_code and
           t1.p_mkt_code = t2.p_mkt_code)) and
         t1.imbalance_ind = t2.imbalance_ind and
         t1.imbalance_ind = 'Y'
 
   delete t2
   from #curr_output t1, 
        #prev_output t2
   where ((t1.s_cmdty_code = t2.s_cmdty_code and
           t1.s_mkt_code = t2.s_mkt_code) OR
          (t1.p_cmdty_code = t2.p_cmdty_code and
           t1.p_mkt_code = t2.p_mkt_code)) and
         t1.imbalance_ind = t2.imbalance_ind and
         t1.imbalance_ind = 'Y'

   -- After this step if there are some #prev_output rows left, then we 
   -- have to find out from BA's how we should handle it
   select * from #curr_output

   drop table #curr_output
   drop table #prev_output

endofsp:  
   return 0  
GO
GRANT EXECUTE ON  [dbo].[usp_PositionReport_physicals] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_PositionReport_physicals', NULL, NULL
GO
