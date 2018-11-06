SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[usp_moh_sap_data_extraction]
as
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#temp') IS NOT NULL
    DROP TABLE #temp
/*
the below query may return duplicates bcoz of formula_comp_type = 'G'. if u use the same quote more than once in the formula body then 
multiple formula component records will be created.
we can avoid this by distinct formula_comp_name but we are skipping here (may be little complex inside the join) but later we can remove it from the 
final output using distinct.
*/
SELECT
    qp.trade_num,
    qp.order_num,
    qp.item_num,
    qp.accum_num,
    qp.qpp_num,
    ac.last_pricing_run_date,
    ac.last_pricing_as_of_date,
   ac.quote_start_date,
   ac.quote_end_date,
    fc.formula_num,
    fc.formula_body_num,
    fc.formula_comp_num,
    fc.formula_comp_name,
    qp.price_quote_date,
    fc.commkt_key,
    fc.price_source_code,
    fc.trading_prd,
    fc.formula_comp_val_type INTO #temp
    FROM
    accumulation ac
   LEFT OUTER JOIN
   trade_item ti 
   ON
   ac.trade_num = ti.trade_num
   AND
   ac.order_num = ti.order_num
   AND
   ac.item_num = ti.item_num
   JOIN
   quote_price qp
   ON
   ac.trade_num = qp.trade_num
   AND
   ac.order_num = qp.order_num
   AND
   ac.item_num = qp.item_num
   AND
   ac.accum_num = qp.accum_num
   JOIN 
   formula_component fc
   ON
   ac.formula_num = fc.formula_num
   AND
   fc.formula_comp_type = 'G'
   WHERE ac.accum_qty > 0
   --WHERE ac.accum_qty > 0 and (ac.trade_num = 18 or ac.trade_num = 33) --and ac.order_num = 1 and ac.item_num = 1
   AND
   ti.booking_comp_num = (SELECT acct_num FROM account WHERE acct_status = 'A' AND acct_type_code = 'PEICOMP' AND acct_short_name = 'MOH')


ALTER TABLE #temp ADD
oid int IDENTITY (1, 1),
is_simple_formula char(1),
market_quote_name varchar(40),
market_quote varchar(100),
market_quote_price float,
diff_name varchar(20),
diff_value float,

--added below 4 new cols for formula uom/curr and formula component uom/curr I#ADSO-6457
formula_curr_code varchar(10),
formula_uom_code varchar(10),
formula_comp_curr_code varchar(10),
formula_comp_uom_code varchar(10),

formula_body_string varchar(255),
formula_parse_string varchar(255),
spec_name1 varchar(40),
spec_value1 float,
spec_name2 varchar(40),
spec_value2 float,
spec_name3 varchar(40),
spec_value3 float,
spec_name4 varchar(40),
spec_value4 float,
cost_unit_price float,
premium_body_string varchar(255),
premium_parse_string varchar(255)

DECLARE
    @commktKey int,
    @priceSourceCode char(8),
    @tradingPrd char(8),
    @priceQuoteDate datetime,
    @formulaCompValType char(1),
    @formulaNum int,
    @marketQuotePrice float, 
    @isSimpleFormula char(1),
    @costUnitPrice float,
    @tradeNum int,
    @orderNum smallint,
    @itemNum smallint,
    @formulaBodyNum int,
    @formulaCompNum int,
    @loop_id int

SELECT @loop_id = MIN(oid) FROM #temp

WHILE @loop_id IS NOT NULL
    BEGIN

        SELECT
            @commktKey = commkt_key,
            @priceSourceCode = price_source_code,
            @tradingPrd = trading_prd,
            @priceQuoteDate = price_quote_date,
            @formulaCompValType = formula_comp_val_type,
            @formulaNum = formula_num,
            @tradeNum = trade_num,
            @orderNum = order_num,
            @itemNum = item_num,
            @formulaBodyNum = formula_body_num,
            @formulaCompNum = formula_comp_num

            FROM #temp WHERE oid = @loop_id

        SELECT TOP 1 @marketQuotePrice =
                              CASE @formulaCompValType
                                  WHEN 'C' THEN avg_closed_price
                                  WHEN 'H' THEN high_asked_price
                                  WHEN 'L' THEN low_bid_price
                              END
            FROM price WHERE 
        commkt_key = @commktKey
        AND
        price_source_code = @priceSourceCode
        AND
        trading_prd = @tradingPrd
        AND
        price_quote_date <= @priceQuoteDate
        ORDER BY price_quote_date DESC

-- ##########################################################################################################################

        --this is for is simple or complex indicator
        SELECT @isSimpleFormula =
                              CASE fb.complexity_ind
                                  WHEN 'S' THEN 'Y'
                                  ELSE 'N'
                              END
            FROM formula_body fb
        WHERE 
        fb.complexity_ind IS NOT NULL
        AND
        fb.formula_num = @formulaNum
        AND
        fb.formula_body_num = @formulaBodyNum
        AND
        formula_body_type IN ('P', 'M', 'Q');

-- ##########################################################################################################################

        -- this is only for differential name
        DECLARE @diffName varchar(20) = NULL;
        -- below 2 cols added for I#ADSO-6457
        DECLARE @formulaCompCurrCode varchar(10) = NULL;
        DECLARE @formulaCompUomCode varchar(10) = NULL;
        --SELECT DISTINCT @diffName = formula_comp_name
        SELECT DISTINCT @diffName = formula_comp_name, @formulaCompCurrCode = formula_comp_curr_code, @formulaCompUomCode = formula_comp_uom_code
        FROM
        formula_component fc
        WHERE 
        fc.formula_num = @formulaNum
        AND
        fc.formula_body_num = @formulaBodyNum
        AND
        fc.formula_comp_type = 'U';

-- ##########################################################################################################################

-- below block added for I#ADSO-6457. formula currency and uom
        DECLARE @formulaCurrCode varchar(10) = NULL;
        DECLARE @formulaUomCode varchar(10) = NULL;
        --SELECT DISTINCT @diffName = formula_comp_name
        SELECT DISTINCT @formulaCurrCode = formula_curr_code, @formulaUomCode = formula_uom_code
        FROM
        formula f
        WHERE 
        f.formula_num = @formulaNum
        
        /*
		The below code added for issue#ADSO-8157. For Surcharge Currency/UOM we need to pick it from the formula comp. But it is a simple formula trade
		then you won't have the 'U' type formula comp. So the above code block will try to set the values from the 'U' type formula comp else NULL. Here we check for NULL
		and if so set the formula level currency code and  uom code
         */
        
        IF @formulaCompCurrCode IS NULL OR @formulaCompUomCode IS NULL
        BEGIN
        SELECT @formulaCompCurrCode = @formulaCurrCode
        SELECT @formulaCompUomCode = @formulaUomCode
        END

-- ##########################################################################################################################

        -- the below is for quote and all the things
        DECLARE
            @tempCompName varchar(40) = NULL,
            @tempMarketQuote varchar(200) = NULL,
            @tempFormulaBodyString varchar(100) = NULL,
            @tempFormulaParseString varchar(100) = NULL,
            @tempDifferentialVal float = 0;
        SELECT
            @tempCompName = formula_comp_name,
            @tempMarketQuote = RTRIM(cm.cmdty_code) + '/' + RTRIM(cm.mkt_code) + '/' + RTRIM(fc.trading_prd) + '/' + RTRIM(fc.price_source_code) + '/' +
            (CASE fc.formula_comp_val_type
                WHEN 'H' THEN 'High'
                WHEN 'C' THEN 'Avg'
                WHEN 'L' THEN 'Low'
            END),
            @tempFormulaBodyString = fb.formula_body_string,
            @tempFormulaParseString = fb.formula_parse_string,
            @tempDifferentialVal = fb.differential_val
            FROM
            formula_component fc
            JOIN
            commodity_market cm
            ON
            fc.commkt_key = cm.commkt_key
            JOIN
            formula_body fb
            ON
            fc.formula_num = fb.formula_num
            AND 
            fc.formula_body_num = fb.formula_body_num
            WHERE 
            fc.formula_num = @formulaNum
            AND
            fb.formula_body_num = @formulaBodyNum    
            AND
            fc.formula_comp_num = @formulaCompNum
            AND
            fc.formula_comp_type = 'G'
            --where fc.formula_num = 837 and fc.formula_comp_type = 'G' and fb.formula_body_num = 3

-- ##########################################################################################################################

        -- the below is for API Spec or Premium/Discount only for formula_body_type 'M'
        DECLARE
            @tempPremiumBodyString varchar(255) = NULL,
            @tempPremiumParseString varchar(255) = NULL;
        SELECT
            @tempPremiumBodyString = fb.formula_body_string,
            @tempPremiumParseString = fb.formula_parse_string
            FROM
                formula_body fb
        WHERE fb.formula_num = @formulaNum
        AND
        fb.formula_body_type = 'M'
        --where fb.formula_num = 28 and fb.formula_body_type = 'M'

-- ##########################################################################################################################

        -- this is to display the wpp cost unit price
        SELECT @costUnitPrice = cost_unit_price FROM cost c
        WHERE
        c.cost_owner_key6 = @tradeNum
        AND
        c.cost_owner_key7 = @orderNum
        AND
        c.cost_owner_key8 = @itemNum
        AND
        cost_status = 'OPEN'
        AND
        cost_type_code = 'WPP';

-- ##########################################################################################################################

        -- this is to display the edensity and bdensity specs and values. we need to check for actual specs first if not then get trade item specs
        IF OBJECT_ID('tempdb..#tempspec') IS NOT NULL
            DROP TABLE #tempspec

        CREATE TABLE #tempspec (oid int IDENTITY (1, 1), spec_code varchar(20), spec_value float)
        
        INSERT INTO #tempspec
        SELECT actspec.spec_code, actspec.spec_actual_value
        FROM
        allocation_item ai
        JOIN
        ai_est_actual_spec actspec
        ON
        ai.alloc_num = actspec.alloc_num
        AND
        ai.alloc_item_num = actspec.alloc_item_num
        WHERE ai.trade_num = @tradeNum AND ai.order_num = @orderNum AND ai.item_num = @itemNum AND actspec.ai_est_actual_num = 1 and actspec.spec_actual_value is not null
        --WHERE ai.trade_num = 281 AND ai.order_num = 1 AND ai.item_num = 1 AND actspec.ai_est_actual_num = 1 and actspec.spec_actual_value is not null
        
        if not exists (select 1 from #tempspec)
        
        INSERT INTO #tempspec
            SELECT tis.spec_code, tis.spec_typical_val
            FROM
            trade_item_spec tis
            WHERE
            tis.trade_num = @tradeNum
            AND
            tis.order_num = @orderNum
            AND
            tis.item_num = @itemNum
        --where tis.trade_num = 80 and tis.order_num = 1 and tis.item_num = 1

        DECLARE @specCode varchar(20), @specValue float, @temp_spec_oid int
        
        SELECT @temp_spec_oid = MIN(oid) FROM #tempspec
        WHILE @temp_spec_oid IS NOT NULL
            BEGIN
                SELECT @specCode = spec_code, @specValue = spec_value FROM #tempspec WHERE oid = @temp_spec_oid
                
                IF @temp_spec_oid = 1
                    UPDATE #temp SET spec_name1 = @specCode, spec_value1 = @specValue WHERE oid = @loop_id
                IF @temp_spec_oid = 2
                    UPDATE #temp SET spec_name2 = @specCode, spec_value2 = @specValue WHERE oid = @loop_id
                IF @temp_spec_oid = 3
                    UPDATE #temp SET spec_name3 = @specCode, spec_value3 = @specValue WHERE oid = @loop_id
                IF @temp_spec_oid = 4
					UPDATE #temp SET spec_name4 = @specCode, spec_value4 = @specValue WHERE oid = @loop_id

                SELECT @temp_spec_oid = MIN(oid) FROM #tempspec WHERE oid > @temp_spec_oid
            END

-- ##########################################################################################################################

        --update #temp set quote_price_value1 = @result, is_simple_formula=@isSimpleFormula, cost_unit_price = @costUnitPrice where oid = @loop_id
        UPDATE #temp
        SET market_quote_price = @marketQuotePrice,
            is_simple_formula = @isSimpleFormula,
            cost_unit_price = @costUnitPrice,
            market_quote_name = @tempCompName,
            market_quote = @tempMarketQuote,
            diff_name = @diffName,
            diff_value = @tempDifferentialVal,
           
           -- populating value for the 4 new cols added for I#ADSO-6457
           formula_curr_code = @formulaCurrCode,
           formula_uom_code = @formulaUomCode,
           formula_comp_curr_code = @formulaCompCurrCode,
           formula_comp_uom_code = @formulaCompUomCode,
           
           formula_body_string = @tempFormulaBodyString,
           formula_parse_string = @tempFormulaParseString,
           premium_body_string = @tempPremiumBodyString,
           premium_parse_string = @tempPremiumParseString

            WHERE oid = @loop_id

        SELECT @loop_id = MIN(oid) FROM #temp WHERE oid > @loop_id

    END


IF OBJECT_ID('tempdb..#final_temp') IS NOT NULL
    DROP TABLE #final_temp


SELECT
   
    t.trade_num AS "Trade Num",
    t.order_num AS "Order Num",
    t.item_num AS "Item Num",
    is_simple_formula AS "Is Simple Formula",
    formula_num AS "Formula Num",
    price_quote_date AS "Price Quote Date",
    last_pricing_run_date AS "Last Pricing Run Date",
    market_quote_name AS "Market Quote Name",
    market_quote AS "Market Quote",
    market_quote_price AS "Quote Price Value",
    avg_market_quote_price as "Average Market Quote Price",
    diff_name AS "Differential Name",
    diff_value AS "Differential Value",
   
   --I#ADSO-6457
   rtrim(formula_curr_code) + '/' + rtrim(formula_uom_code) as "Formula Currency/UOM",
   rtrim(formula_comp_curr_code) + '/' + rtrim(formula_comp_uom_code) as "Surcharge Currency/UOM",
    
    spec_name1 AS "Spec1 Name",
    spec_value1 AS "Spec1 Value",
    spec_name2 AS "Spec2 Name",
    spec_value2 AS "Spec2 Value",
    spec_name3 AS "Spec3 Name",
    spec_value3 AS "Spec3 Value",
   spec_name4 AS "Spec4 Name",
   spec_value4 AS "Spec4 Value",
    cost_unit_price AS "WPP Cost Unit Price",
    round(((avg_market_quote_price + diff_value) / NULLIF(cost_unit_price,0)),6) as "Escalation Factor",
    formula_body_string AS "Formula Body String",
    formula_parse_string AS "Formula Parse String",
    premium_body_string AS "Premium Body String",
    premium_parse_string AS "Premium Parse String",
	quote_start_date AS "Pricing Period Start Date",
	quote_end_date AS "Pricing Period End Date"
   
   INTO #final_temp 
   FROM #temp t
   JOIN
   (select trade_num,order_num,item_num,avg(market_quote_price) avg_market_quote_price from #temp group by trade_num,order_num,item_num) g
   on t.trade_num = g.trade_num and t.order_num = g.order_num and t.item_num = g.item_num
    
--select * from #temp
SELECT *, GETDATE() as "Extracted On" FROM #final_temp
return
GO
GRANT EXECUTE ON  [dbo].[usp_moh_sap_data_extraction] TO [next_usr]
GO
