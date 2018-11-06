SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create view [dbo].[v_bcp_prices_aug2]
(
    commkt_key,
    price_source_code,
    trading_prd,
    price_quote_date,
    low_bid_price,
    high_asked_price,
    avg_closed_price,
    open_interest,
    vol_traded,
    creation_type,
    low_bid_creation_ind,
    high_asked_creation_ind,
    avg_closed_creation_ind,
    trans_id
)
as 
select 
    commkt_key,
    price_source_code,
    trading_prd,
    price_quote_date,
    low_bid_price,
    high_asked_price,
    avg_closed_price,
    open_interest,
    vol_traded,
    creation_type,
    low_bid_creation_ind,
    high_asked_creation_ind,
    avg_closed_creation_ind,
    trans_id
from dbo.price
where datepart(mm, price_quote_date) = 8 and
      datepart(yy, price_quote_date) = datepart(yy, getdate())
GO
GRANT SELECT ON  [dbo].[v_bcp_prices_aug2] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_bcp_prices_aug2', NULL, NULL
GO
