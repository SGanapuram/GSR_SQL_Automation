SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_PLCOMP_position_info]
(
   pos_num,
   long_qty,
   short_qty,
   qty_uom_code,
   avg_purch_price,
   cmdty_short_name,
   mkt_short_name,
   trading_prd,
   trading_prd_desc,
   first_del_date,
   last_issue_date,
   last_trade_date,
   trans_id
)
as
select p.pos_num,
       p.long_qty,
       p.short_qty,
       p.qty_uom_code,
       p.avg_purch_price,
       cmdty.cmdty_short_name,
       mkt.mkt_short_name,
       tp.trading_prd,
       tp.trading_prd_desc,
       tp.first_del_date,
       tp.last_issue_date,
       tp.last_trade_date,
       tp.trans_id
from dbo.position p WITH (NOLOCK) 
        left outer join dbo.commodity cmdty WITH (NOLOCK) 
           on p.cmdty_code = cmdty.cmdty_code                                                        
        left outer join dbo.market mkt WITH (NOLOCK) 
           on p.mkt_code = mkt.mkt_code                             
        left outer join dbo.trading_period tp WITH (NOLOCK) 
           on p.commkt_key = tp.commkt_key and 
              p.trading_prd = tp.trading_prd                                                   
GO
GRANT SELECT ON  [dbo].[v_PLCOMP_position_info] TO [next_usr]
GO
