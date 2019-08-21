SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[fetchEventPriceTermRevPK]
(
   @asof_trans_id       bigint,
   @formula_num         int,
   @price_term_num      smallint
)
as
set nocount on
declare @trans_id   bigint
 
select @trans_id = trans_id
from dbo.event_price_term
where formula_num = @formula_num and
      price_term_num = @price_term_num
 
if @trans_id <= @asof_trans_id
begin
   select
   	  adj_days,
      adj_pricing_date_ind,
      adj_pricing_prd_type,
      asof_trans_id = @asof_trans_id,
      date_deemed,
      deemed_event_date,
      event_date_holidays,
      event_date_saturdays,
      event_date_sundays,
      event_dflt_ind,
      event_include_ind,
      event_name,
      event_oper,
      event_pricing_days,
      event_start_end_days,
      event_trig_ind,
      formula_num,
      parent_price_term_num,
      price_term_num,
      quote_type,
      resp_trans_id = null,
      trans_id
   from dbo.event_price_term
   where formula_num = @formula_num and
         price_term_num = @price_term_num
end
else
begin
   select top 1
   	  adj_days,
      adj_pricing_date_ind,
      adj_pricing_prd_type,	
      asof_trans_id = @asof_trans_id,
      date_deemed,
      deemed_event_date,
      event_date_holidays,
      event_date_saturdays,
      event_date_sundays,
      event_dflt_ind,
      event_include_ind,
      event_name,
      event_oper,
      event_pricing_days,
      event_start_end_days,
      event_trig_ind,
      formula_num,
      parent_price_term_num,
      price_term_num,
      quote_type,
      resp_trans_id,
      trans_id
   from dbo.aud_event_price_term
   where formula_num = @formula_num and
         price_term_num = @price_term_num and
         trans_id <= @asof_trans_id and
         resp_trans_id > @asof_trans_id
   order by trans_id desc
end
return
GO
GRANT EXECUTE ON  [dbo].[fetchEventPriceTermRevPK] TO [next_usr]
GO
