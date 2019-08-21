SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[validate_trade_default_data]
as
begin
set nocount on
   /* ----------------------------------------------------------- */
   print 'Finding acct_num NOT IN account table ...'
   if exists (select * from trade_default
              where acct_num is not null and 
                    not acct_num in (select acct_num from account))
   begin
      select distinct acct_num 'Invalid acct_num'
      from trade_default
      where acct_num is not null and 
            not acct_num in (select acct_num from account)
      order by acct_num
   end

   /* ----------------------------------------------------------- */
   print 'Finding booking_comp_num NOT IN account (PEICOMP) table ...'
   if exists (select * from trade_default
              where booking_comp_num is not null and 
	            not booking_comp_num in (select acct_num 
                                             from account
                                             where acct_type_code = 'PEICOMP'))
   begin
      select distinct booking_comp_num 'Invalid booking_comp_num'
      from trade_default
      where booking_comp_num is not null and 
	    not booking_comp_num in (select acct_num 
                                     from account
                                     where acct_type_code = 'PEICOMP')
      order by booking_comp_num
   end

   /* ----------------------------------------------------------- */
   print 'Finding brkr_num NOT IN account (BROKER, EXCHBRKR, FLRBRKR) table ...'
   if exists (select * from trade_default
              where brkr_num is not null and 
	            not brkr_num in (select acct_num 
                                     from account
                                     where acct_type_code IN 
                                          ('BROKER', 'EXCHBRKR', 'FLRBRKR')))
   begin
      select distinct brkr_num 'Invalid brkr_num'
      from trade_default
      where brkr_num is not null and 
	    not brkr_num in (select acct_num 
                             from account
                             where acct_type_code IN 
                                 ('BROKER', 'EXCHBRKR', 'FLRBRKR'))
      order by brkr_num
   end

   /* ----------------------------------------------------------- */
   print 'Finding brkr_num, brkr_cont_num NOT IN account_contact table ...'
   if exists (select * from trade_default
              where brkr_num is not null and
                    brkr_cont_num is not null and
                    not exists (select * 
                                from account_contact
                                where trade_default.brkr_num = account_contact.acct_num and
                                      trade_default.brkr_cont_num = account_contact.acct_cont_num))
   begin
      select distinct brkr_num, brkr_cont_num 'Invalid brkr_cont_num'
      from trade_default
      where brkr_num is not null and
            brkr_cont_num is not null and
            not exists (select * 
                        from account_contact
                        where trade_default.brkr_num = account_contact.acct_num and
                              trade_default.brkr_cont_num = account_contact.acct_cont_num)
      order by brkr_num, brkr_cont_num
   end

   /* ----------------------------------------------------------- */
   print 'Finding cmdty_code NOT IN commodity table ...'
   if exists (select * from trade_default
              where cmdty_code is not null and 
	            not cmdty_code in (select cmdty_code from commodity 
                                       where cmdty_type = 'P'))
   begin
      select distinct cmdty_code 'Invalid cmdty_code'
      from trade_default
      where cmdty_code is not null and 
	    not cmdty_code in (select cmdty_code from commodity 
                               where cmdty_type = 'P')
      order by cmdty_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding price_curr_code NOT IN commodity (cmdty_type = C) table ...'
   if exists (select * from trade_default
              where price_curr_code is not null and 
	            not price_curr_code in (select cmdty_code from commodity 
                                            where cmdty_type = 'C'))
   begin
      select distinct price_curr_code 'Invalid price_curr_code'
      from trade_default
      where price_curr_code is not null and 
	    not price_curr_code in (select cmdty_code from commodity 
                                    where cmdty_type = 'C')
      order by price_curr_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding brkr_comm_curr_code NOT IN commodity (cmdty_type = C) table ...'
   if exists (select * from trade_default
              where brkr_comm_curr_code is not null and 
	            not brkr_comm_curr_code in (select cmdty_code from commodity 
                                                where cmdty_type = 'C'))
   begin
      select distinct brkr_comm_curr_code 'Invalid brkr_comm_curr_code'
      from trade_default
      where brkr_comm_curr_code is not null and 
	    not brkr_comm_curr_code in (select cmdty_code from commodity 
                                        where cmdty_type = 'C')
      order by brkr_comm_curr_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding del_loc_code_key NOT IN location (del_loc_ind = Y) table ...'
   if exists (select * from trade_default
              where del_loc_code_key is not null and 
	            not del_loc_code_key in (select loc_code from location 
                                             where del_loc_ind = 'Y'))
   begin
      select distinct del_loc_code_key 'Invalid del_loc_code_key'
      from trade_default
      where del_loc_code_key is not null and 
	    not del_loc_code_key in (select loc_code from location 
                                     where del_loc_ind = 'Y')
      order by del_loc_code_key
   end

   /* ----------------------------------------------------------- */
   print 'Finding del_loc_code NOT IN location (del_loc_ind = Y) table ...'
   if exists (select * from trade_default
              where del_loc_code is not null and 
	            not del_loc_code in (select loc_code from location 
                                         where del_loc_ind = 'Y'))
   begin
      select distinct del_loc_code 'Invalid del_loc_code'
      from trade_default
      where del_loc_code is not null and 
	    not del_loc_code in (select loc_code from location 
                                 where del_loc_ind = 'Y')
      order by del_loc_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding order_type_code NOT IN order_type table ...'
   if exists (select * from trade_default
              where order_type_code is not null and 
	            not order_type_code in (select order_type_code from order_type))
   begin
      select distinct order_type_code 'Invalid order_type_code'
      from trade_default
      where order_type_code is not null and 
	    not order_type_code in (select order_type_code from order_type)
      order by order_type_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding risk_mkt_code NOT IN market table ...'
   if exists (select * from trade_default
              where risk_mkt_code is not null and 
	            not risk_mkt_code in (select mkt_code from market))
   begin
      select distinct risk_mkt_code 'Invalid risk_mkt_code'
      from trade_default
      where risk_mkt_code is not null and 
	    not risk_mkt_code in (select mkt_code from market)
      order by risk_mkt_code
  end

   /* ----------------------------------------------------------- */
   print 'Finding title_mkt_code NOT IN market table ...'
   if exists (select * from trade_default
              where title_mkt_code is not null and 
	            not title_mkt_code in (select mkt_code from market))
   begin
      select distinct title_mkt_code 'Invalid title_mkt_code'
      from trade_default
      where title_mkt_code is not null and 
	    not title_mkt_code in (select mkt_code from market)
      order by title_mkt_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding gtc_code NOT IN gtc table ...'
   if exists (select * from trade_default
              where gtc_code is not null and 
                    not gtc_code in (select gtc_code from gtc))
   begin
      select distinct gtc_code 'Invalid gtc_code'
      from trade_default
      where gtc_code is not null and 
            not gtc_code in (select gtc_code from gtc)
      order by gtc_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding del_term_code NOT IN delivery_term table ...'
   if exists (select * from trade_default
              where del_term_code is not null and 
                    not del_term_code in (select del_term_code from delivery_term))
   begin
      select distinct del_term_code 'Invalid del_term_code'
      from trade_default
      where del_term_code is not null and 
            not del_term_code in (select del_term_code from delivery_term)
      order by del_term_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding pay_term_code NOT IN payment_term table ...'
   if exists (select * from trade_default
              where pay_term_code is not null and
	            not pay_term_code in (select pay_term_code from payment_term))
   begin
      select distinct pay_term_code 'Invalid pay_term_code'
      from trade_default
      where pay_term_code is not null and
	    not pay_term_code in (select pay_term_code from payment_term)
      order by pay_term_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding mot_code NOT IN mot table ...'
   if exists (select * from trade_default
              where mot_code is not null and 
                    not mot_code in (select mot_code from mot))
   begin
      select distinct mot_code 'Invalid mot_code'
      from trade_default
      where mot_code is not null and 
            not mot_code in (select mot_code from mot)
      order by mot_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding contr_qty_uom_code NOT IN uom table ...'
   if exists (select * from trade_default
              where contr_qty_uom_code is not null and 
                    not contr_qty_uom_code in (select uom_code from uom))
   begin
      select distinct contr_qty_uom_code 'Invalid contr_qty_uom_code'
      from trade_default
      where contr_qty_uom_code is not null and 
            not contr_qty_uom_code in (select uom_code from uom)
      order by contr_qty_uom_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding price_uom_code NOT IN uom table ...'
   if exists (select * from trade_default
              where price_uom_code is not null and 
                    not price_uom_code in (select uom_code from uom))
   begin
      select distinct price_uom_code 'Invalid price_uom_code'
      from trade_default
      where price_uom_code is not null and 
            not price_uom_code in (select uom_code from uom)
      order by price_uom_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding min_qty_uom_code NOT IN uom table ...'
   if exists (select * from trade_default
              where min_qty_uom_code is not null and 
                    not min_qty_uom_code in (select uom_code from uom))
   begin
      select distinct min_qty_uom_code 'Invalid min_qty_uom_code'
      from trade_default
      where min_qty_uom_code is not null and 
            not min_qty_uom_code in (select uom_code from uom)
      order by min_qty_uom_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding max_qty_uom_code NOT IN uom table ...'
   if exists (select * from trade_default
              where max_qty_uom_code is not null and 
                    not max_qty_uom_code in (select uom_code from uom))
   begin
      select distinct max_qty_uom_code 'Invalid max_qty_uom_code'
      from trade_default
      where max_qty_uom_code is not null and 
            not max_qty_uom_code in (select uom_code from uom)
      order by max_qty_uom_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding tol_qty_uom_code NOT IN uom table ...'
   if exists (select * from trade_default
              where tol_qty_uom_code is not null and 
                    not tol_qty_uom_code in (select uom_code from uom))
   begin
      select distinct tol_qty_uom_code 'Invalid tol_qty_uom_code'
      from trade_default
      where tol_qty_uom_code is not null and 
            not tol_qty_uom_code in (select uom_code from uom)
      order by tol_qty_uom_code
   end

   /* ----------------------------------------------------------- */
   print 'Finding brkr_comm_uom_code NOT IN uom table ...'
   if exists (select * from trade_default
              where brkr_comm_uom_code is not null and 
                    not brkr_comm_uom_code in (select uom_code from uom))
   begin
      select distinct brkr_comm_uom_code 'Invalid brkr_comm_uom_code'
      from trade_default
      where brkr_comm_uom_code is not null and 
	    not brkr_comm_uom_code in (select uom_code from uom)
      order by brkr_comm_uom_code
   end
   return
end
GO
GRANT EXECUTE ON  [dbo].[validate_trade_default_data] TO [next_usr]
GO
