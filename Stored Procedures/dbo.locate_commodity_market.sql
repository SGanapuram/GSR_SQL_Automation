SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[locate_commodity_market]
(
   @by_type0   varchar(40)  = null,
   @by_ref0    varchar(255) = null,
   @by_type1   varchar(40) = null,
   @by_ref1    varchar(40) = null
)
as
begin
set nocount on
declare @rowcount int
declare @ref_num0 int

   if @by_type0 in ('cmdty_mkt', 'CM', 'commkt_key', 'commodity_market')
   begin
      set @ref_num0 = convert(int, @by_ref0)
      select
         /* :LOCATE: CmdtyMkt  */
         cm.commkt_key,               /* :IS_KEY: 1 */
         cm.mkt_code,
         cm.cmdty_code,
         cm.mtm_price_source_code,
         cm.dflt_opt_eval_method,
         cm.trans_id,
         cm.man_input_sec_qty_required
      from dbo.commodity_market cm with (nolock)
      where cm.commkt_key = @ref_num0
      order by cm.commkt_key
   end
   else if ( ((@by_type0 = 'mkt') or 
              (@by_type0 = 'mkt_code') or 
              (@by_type0 = 'MK') or 
              (@by_type0 = 'market')) AND
             ((@by_type1 = 'cmdty') or 
              (@by_type1 = 'cmdty_code') or 
              (@by_type1 = 'CC') or 
              (@by_type1 = 'commodity')))
      select
         cm.commkt_key,
         cm.mkt_code,
         cm.cmdty_code,
         cm.mtm_price_source_code,
         cm.dflt_opt_eval_method,
         cm.trans_id,
         cm.man_input_sec_qty_required 
      from dbo.commodity_market cm with (nolock)
      where cm.mkt_code = @by_ref0 AND
            cm.cmdty_code = @by_ref1
      order by cm.commkt_key
   else
      return 4

   set @rowcount = @@rowcount
   if @rowcount = 1
      return 0
   else if @rowcount = 0
      return 1
	 else
      return 2
end
GO
GRANT EXECUTE ON  [dbo].[locate_commodity_market] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'locate_commodity_market', NULL, NULL
GO
