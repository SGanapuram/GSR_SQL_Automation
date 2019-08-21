SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_daily_inventory_report]
(
   @inv_type                 varchar(10)=  null,
   @inv_num                  nvarchar(4000) = null,
   @loc_code                 varchar(8000) = null,
   @trade_num                nvarchar(4000) = null,
   @balance_prd              nvarchar(4000) = null,
   @commodity                varchar(8000) = null,
   @portfolio                nvarchar(4000) = null,
   @book_comp                nvarchar(4000) = null,
   @debugon                  bit = 0 
)
as
set nocount on
declare @rows_affected          int, 
        @smsg                   varchar(255), 
        @status                 int, 
        @oid                    numeric(18, 0), 
        @stepid                 smallint, 
        @session_started        varchar(30), 
        @session_ended          varchar(30),
        @my_inv_type            nvarchar(10),
        @my_inv_num             nvarchar(4000),
        @my_loc_code            nvarchar(4000),
        @my_trade_num           nvarchar(4000),
        @my_balance_prd         nvarchar(4000),
        @my_commodity           nvarchar(4000),
        @my_portfolio           nvarchar(4000),
        @my_book_comp           nvarchar(4000),
        @sql                    varchar(MAX)
            

SET @sql = 'SELECT ti.item_type,
		   i.inv_num,
		   i.cmdty_code,
		   CONVERT(VARCHAR,i.trade_num) + ''/'' + CONVERT(VARCHAR, i.order_num) + ''/ '' + CONVERT(VARCHAR, i.sale_item_num),
                   ( Isnull(i.inv_open_prd_proj_qty, 0) + Isnull(i.inv_open_prd_actual_qty, 0) ) AS open_qty,
                   ( Isnull(i.inv_adj_qty, 0) + Isnull(i.inv_cnfrmd_qty, 0) ) AS inv_qty,
                   i.inv_qty_uom_code,
                   ( Isnull(i.inv_open_prd_proj_sec_qty, 0) + Isnull(i.inv_open_prd_actual_sec_qty, 0) ) AS open_sec_qty,
                   ( Isnull(i.inv_cnfrmd_sec_qty, 0) + Isnull(i.inv_adj_sec_qty, 0) ) AS inv_sec_qty,
                   i.inv_sec_qty_uom_code, i.open_close_ind,
                   p.open_close_ind,
                   case when p.open_close_ind in (''R'',''C'') then
                   case when i.open_close_ind in (''O'') then 
                   isnull(i.inv_open_prd_proj_qty,0)+isnull(i.inv_open_prd_actual_qty,0)+isnull(i.inv_adj_qty,0)+isnull(i.inv_cnfrmd_qty,0)end 
                   else 
                   (isnull(i.inv_adj_qty,0)+isnull(i.inv_cnfrmd_qty,0)) end ''Var1'',
                   case when p.open_close_ind in (''R'',''C'') then 
                   case when i.open_close_ind in (''O'') then 
                   (isnull(i.inv_open_prd_proj_sec_qty,0)+isnull(i.inv_open_prd_actual_sec_qty,0)) + (isnull(i.inv_cnfrmd_sec_qty,0)+isnull(i.inv_adj_sec_qty,0)) end 
                   else 
                   (isnull(i.inv_open_prd_proj_sec_qty,0)+isnull(i.inv_open_prd_actual_sec_qty,0)) end ''Var2'',
                   case (select rtrim(attribute_value) from constants where attribute_name=''InventoryPriceForPL'')when ''MAC'' then 
                   i.inv_mac_cost 
                   else 
                   i.inv_avg_cost end as ''avg_cost'',
                   case (select rtrim(attribute_value) from constants where attribute_name=''InventoryPriceForPL'') when ''MAC'' then 
                   i.mac_inv_amt 
                   else 
                   i.r_inv_avg_cost_amt+i.unr_inv_avg_cost_amt end as total_cost,
                   i.inv_avg_cost,
                   i.inv_mac_cost,
                   i.r_inv_avg_cost_amt + i.unr_inv_avg_cost_amt,
                   i.mac_inv_amt,
                   i.pos_num,
                   pmtm.mtm_mkt_price,
                   pmtm.mtm_mkt_price_curr_code,
                   pmtm.mtm_mkt_price_uom_code,
                   pmtm.mtm_asof_date
            FROM   dbo.inventory i
            LEFT OUTER JOIN dbo.inventory p
                   ON i.prev_inv_num = p.inv_num
            JOIN trade_item ti
                   ON ti.trade_num = i.trade_num
                   AND ti.order_num = i.order_num
                   AND ti.item_num = i.sale_item_num
            LEFT OUTER JOIN dbo.position_mark_to_market pmtm
                   ON pmtm.pos_num = i.pos_num
                   WHERE  pmtm.mtm_asof_date = (SELECT MAX(pmtm1.mtm_asof_date)
            FROM   dbo.position_mark_to_market pmtm1
            WHERE  pmtm.pos_num = pmtm1.pos_num)'

select  @my_inv_type    = @inv_type,
            @my_inv_num = @inv_num,
            @my_loc_code = @loc_code,
            @my_trade_num = @trade_num,
            @my_balance_prd = @balance_prd,
            @my_commodity = @commodity,
            @my_portfolio = @portfolio,
            @my_book_comp = @book_comp

          IF (@my_inv_type is not null)
            BEGIN
                  SET @sql=@sql + 'and ti.item_type in (select * from dbo.fnToSplit(''' + @my_inv_type + ''', '',''))'
            END
            IF (@my_inv_num is not null)
            BEGIN
                  SET @sql=@sql + 'and i.inv_num in (select * from dbo.fnToSplit(''' + @my_inv_num + ''', '',''))'
            END
            IF (@my_loc_code is not null)
            BEGIN
                  SET @sql=@sql + 'and i.del_loc_code in (select * from dbo.fnToSplit(''' + @my_loc_code + ''', '',''))'
            END
            IF (@my_trade_num is not null)
            BEGIN
                  SET @sql=@sql + 'and i.trade_num in (select * from dbo.fnToSplit(''' + @my_trade_num + ''', '',''))'
            END
            IF (@my_balance_prd is not null)
            BEGIN
                  SET @sql=@sql + 'and i.balance_period in (select * from dbo.fnToSplit(''' + @my_balance_prd + ''', '',''))'
            END
            IF (@my_commodity is not null)
            BEGIN
                  SET @sql=@sql + 'and i.cmdty_code in (select * from dbo.fnToSplit(''' + @my_commodity + ''', '',''))'
            END
            IF (@my_portfolio is not null)
            BEGIN
                  SET @sql=@sql + 'and i.port_num in (select * from dbo.fnToSplit(''' + @my_portfolio + ''', '',''))'
            END
            IF (@my_book_comp is not null)
            BEGIN
                  SET @sql=@sql + 'and ti.booking_comp_num in (select * from dbo.fnToSplit(''' + @my_book_comp + ''', '',''))'
            END

create table #dailyinventory
(
inv_type                      varchar(8000) null,
inv_num                       varchar(8000) null,
commodity                     varchar(8000) null,
inv_misc                      varchar(8000),
open_qty                      varchar(8000) null,
inv_qty                       varchar(8000) null,
open_sec_qty                  varchar(8000) null,
inv_sec_qty                   varchar(8000) null,
inv_qty_uom_code              varchar(8000),
inv_sec_qty_uom_code          varchar(8000),
cur_open_close_ind            varchar(8000),
prev_open_close_ind           varchar(8000),
qty1                          float null, 
qty2                          float null,
avg_cost                      varchar(8000) null,
total_cost                    float null,
inv_avg_cost                  varchar(8000) null,
inv_mac_cost                  varchar(8000) null,
r_inv_avg_cost                varchar(8000) null,
mac_inv_amt                   varchar(8000) null,
pos_num                       varchar(8000) null,
mtm_mkt_price                 varchar(8000) null,
mtm_mkt_price_curr_code       varchar(8000),
mtm_mkt_price_uom_code        varchar(8000),
mtm_asof_date                 datetime
)
insert into #dailyinventory
(
inv_type,
inv_num,
commodity,
inv_misc,
open_qty,
inv_qty,
open_sec_qty,
inv_sec_qty,
inv_qty_uom_code,
inv_sec_qty_uom_code,
cur_open_close_ind,
prev_open_close_ind,
qty1,
qty2,
avg_cost,
total_cost,
inv_avg_cost,
inv_mac_cost,
r_inv_avg_cost,
mac_inv_amt,
pos_num,
mtm_mkt_price,
mtm_mkt_price_curr_code,
mtm_mkt_price_uom_code,
mtm_asof_date
)
exec (@sql)

SELECT i.inv_type,
       i.commodity,
       case when 
            case when inv_qty_uom_code in ('BBL') then qty1 
                 when inv_sec_qty_uom_code in ('BBL') then qty2 end in ('0',NULL) then 
            case when (Select uom_type from uom where uom_code=i.inv_qty_uom_code)='V' then convert(varchar,(select dbo.udf_getUomConversion(i.inv_qty_uom_code,'MT',null,null,null))) 
                 when (select uom_type from uom where uom_code=i.inv_sec_qty_uom_code) ='V' then convert(varchar,(select dbo.udf_getUomConversion(i.inv_qty_uom_code,'MT',null,null,null))) end else 
            case when inv_qty_uom_code in ('BBL') then qty1 when inv_sec_qty_uom_code in ('BBL') then qty2 end end 'Quantity_BBL',
       case when 
            case when inv_qty_uom_code in ('MT') then qty1 
            when inv_sec_qty_uom_code in ('MT') then qty2 end in ('0',NULL) then 
            case when (Select uom_type from uom where uom_code=i.inv_qty_uom_code)='V' then convert(varchar,(select dbo.udf_getUomConversion(i.inv_qty_uom_code,'BBL',null,null,null))) 
                 when (select uom_type from uom where uom_code=i.inv_sec_qty_uom_code) ='V' then convert(varchar,(select dbo.udf_getUomConversion(i.inv_qty_uom_code,'BBL',null,null,null))) end else 
            case when inv_qty_uom_code in ('MT') then qty1 when inv_sec_qty_uom_code in ('MT') then qty2 end end 'Quantity_MT',
            isnull(i.total_cost,0) total_cost,
            isnull(mtm_mkt_price,0) mtm_mkt_price
       FROM #dailyinventory i

DROP TABLE #dailyinventory
endofsp:
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_daily_inventory_report] TO [next_usr]
GO
