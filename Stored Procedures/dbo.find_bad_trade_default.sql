SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_bad_trade_default]
as
begin
set nocount on
declare @dflt_num     int,
        @maskstring   varchar(40)

   create table #trade_default_temp 
   (
      dflt_num     int         NOT NULL,
      maskstring   varchar(40) NULL
   )

  select @dflt_num = min(dflt_num)
  from dbo.trade_default

  while (@dflt_num is not null)
  begin
     select @maskstring = ''

     /* 1 - acct_num */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      acct_num is not null and 
                      not acct_num in (select acct_num 
                                       from dbo.account with (nolock)
                                       where acct_type_code = 'CUSTOMER'))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'

     /* 2 - cmdty_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      cmdty_code is not null and 
                      not cmdty_code in (select cmdty_code 
	                                       from dbo.commodity with (nolock)
                                         where cmdty_type = 'P'))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'

     /* 3 - order_type_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      order_type_code is not null and 
	                    not order_type_code in (select order_type_code 
                                              from dbo.order_type with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 4 - risk_mkt_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      risk_mkt_code is not null and 
	                    not risk_mkt_code in (select mkt_code 
	                                          from dbo.market with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 5 - title_mkt_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      title_mkt_code is not null and 
	                    not title_mkt_code in (select mkt_code 
	                                           from dbo.market with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 6 - contr_qty_uom_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      contr_qty_uom_code is not null and 
                      not contr_qty_uom_code in (select uom_code 
                                                 from dbo.uom with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 7 - price_curr_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      price_curr_code is not null and 
	                    not price_curr_code in (select cmdty_code 
	                                            from dbo.commodity with (nolock)
                                              where cmdty_type = 'C'))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'

     /* 8 - price_uom_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      price_uom_code is not null and 
	                    not price_uom_code in (select uom_code 
	                                           from dbo.uom with (nolock))) 
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'

     /* 9 - booking_comp_num */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      booking_comp_num is not null and 
	                    not booking_comp_num in (select acct_num 
                                               from dbo.account with (nolock)
                                               where acct_type_code = 'PEICOMP'))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'

     /* 10 - gtc_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      gtc_code is not null and 
                      not gtc_code in (select gtc_code 
                                       from dbo.gtc with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'

     /* 11 - pay_term_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      pay_term_code is not null and 
	                    not pay_term_code in (select pay_term_code 
                                            from dbo.payment_term with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'

     /* 12 - del_term_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      del_term_code is not null and 
                      not del_term_code in (select del_term_code 
                                            from dbo.delivery_term with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 13 - mot_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      mot_code is not null and 
                      not mot_code in (select mot_code 
                                       from dbo.mot with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 14 - del_loc_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      del_loc_code is not null and 
	                    not del_loc_code in (select loc_code 
	                                         from dbo.location with (nolock)
                                           where del_loc_ind = 'Y'))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 15 - min_qty_uom_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      min_qty_uom_code is not null and 
                      not min_qty_uom_code in (select uom_code 
                                               from dbo.uom with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 16 - max_qty_uom_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      max_qty_uom_code is not null and 
                      not max_qty_uom_code in (select uom_code 
                                               from uom with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 17 - tol_qty_uom_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      tol_qty_uom_code is not null and 
                      not tol_qty_uom_code in (select uom_code 
                                               from uom with (nolock)))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 18 - brkr_num */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      brkr_num is not null and 
	                    not brkr_num in (select acct_num 
                                       from dbo.account with (nolock)
                                       where acct_type_code IN ('BROKER', 'EXCHBRKR', 'FLRBRKR')))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 19 - brkr_num, brkr_cont_num */
     if exists (select 1 
                from dbo.trade_default tf with (nolock)
                where dflt_num = @dflt_num and
                      brkr_num is not null and
                      brkr_cont_num is not null and
                      not exists (select * 
                                  from dbo.account_contact ac with (nolock)
                                  where tf.brkr_num = ac.acct_num and
                                        tf.brkr_cont_num = ac.acct_cont_num))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 20 - brkr_comm_curr_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      brkr_comm_curr_code is not null and 
	                    not brkr_comm_curr_code in (select cmdty_code 
	                                                from dbo.commodity with (nolock)
                                                  where cmdty_type = 'C'))
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'

     /* 21 - brkr_comm_uom_code */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      brkr_comm_uom_code is not null and 
	              not brkr_comm_uom_code in (select uom_code 
	                                         from dbo.uom with (nolock)) )
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'


     /* 22 - tol_sign */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      tol_sign is not null and 
	                    not tol_sign in ('+', '-', '+/-') )
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'

     /* 23 - tol_opt */
     if exists (select 1 
                from dbo.trade_default with (nolock)
                where dflt_num = @dflt_num and
                      tol_opt is not null and 
	                    not upper(tol_opt) in ('SELLER', 'BUYER') )
        set @maskstring = @maskstring + 'Y'
     else
        set @maskstring = @maskstring + 'N'

     if charindex('Y', @maskstring) > 0 
     begin
        insert into #trade_default_temp
          values(@dflt_num, @maskstring) 
     end

     select @dflt_num = min(dflt_num)
     from dbo.trade_default
     where dflt_num > @dflt_num
  end

  select
     tf.dflt_num,
     tf.acct_num,
     tf.cmdty_code,
     tf.del_loc_code_key,
     tf.order_type_code,
     tf.risk_mkt_code,
     tf.title_mkt_code,
     tf.contr_qty,
     tf.contr_qty_uom_code,
     tf.price_curr_code,
     tf.price_uom_code,
     tf.booking_comp_num,
     tf.gtc_code,
     tf.pay_term_code,
     tf.del_term_code,
     tf.mot_code,
     tf.del_loc_code,
     tf.min_qty,
     tf.min_qty_uom_code,
     tf.max_qty,
     tf.max_qty_uom_code,
     tf.tol_qty,
     tf.tol_qty_uom_code,
     tf.tol_sign,
     tf.tol_opt,
     tf.formula_precision,
     tf.brkr_num,
     tf.brkr_cont_num,
     tf.brkr_comm_amt,
     tf.brkr_comm_curr_code,
     tf.brkr_comm_uom_code,
     tf.brkr_ref_num,
     tf.trans_id,
     tftemp.maskstring
  from dbo.trade_default tf, 
       #trade_default_temp tftemp
  where tf.dflt_num = tftemp.dflt_num
  order by tf.dflt_num

  drop table #trade_default_temp
  return
end
GO
GRANT EXECUTE ON  [dbo].[find_bad_trade_default] TO [next_usr]
GO
