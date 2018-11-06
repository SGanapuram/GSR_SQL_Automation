SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_import_agency_report]
(    
   @from_date   varchar(255),    
   @to_date     varchar(255),    
   @port_num    varchar(8000),    
   @user_name   varchar(8000),    
   @debugon     bit = 0     
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
        @my_from_date           varchar(255),    
        @my_to_date             varchar(255),    
        @my_port_num            varchar(8000),    
        @my_user_name           varchar(8000),  
        @my_oid                 int,  
        @my_bl_date             datetime,  
        @my_alloc_num           int,  
        @my_fx_rate             numeric(20,8),  
        @my_div_mul_ind         char(1),  
        @my_date                datetime  
  
select @my_date = convert(varchar,getdate(),101),  
       @my_from_date = @from_date,  
       @my_to_date = @to_date,  
       @my_port_num = @port_num,  
       @my_user_name = @user_name  
  
CREATE TABLE #importagency    
(    
 alloc_num  int    
)    
  
CREATE TABLE #tempalloc  
(  
 oid int IDENTITY,  
 alloc_num int,  
 bl_date datetime,  
 fx_rate numeric (20,8),  
 div_mul_ind char(1)  
)  
  
INSERT INTO #importagency    
(    
 alloc_num    
)  
  
SELECT DISTINCT a.alloc_num     
FROM  dbo.allocation a     
       JOIN dbo.allocation_item ai     
         ON a.alloc_num = ai.alloc_num     
       JOIN dbo.trade_item ti     
         ON ai.trade_num = ti.trade_num     
            AND ai.order_num = ti.order_num     
            AND ai.item_num = ti.item_num     
WHERE  sch_init IN (SELECT * FROM   dbo.udf_split(@my_user_name, ','))  
       AND convert(varchar,creation_date,101) >= @my_from_date    
       AND convert(varchar,creation_date,101) <= @my_to_date     
       AND ti.real_port_num IN (SELECT * FROM   dbo.udf_split(@my_port_num, ','))      
  
--Getting BL Dates along with alloc_num,   
  
insert into #tempalloc (alloc_num,bl_date)   
select distinct a.alloc_num,convert(varchar,ait.bl_date,101) bl_date from dbo.allocation a  
join dbo.allocation_item ai   
 on a.alloc_num = ai.alloc_num   
JOIN dbo.allocation_item_transport ait     
         ON a.alloc_num = ait.alloc_num     
            AND ait.alloc_item_num = ai.alloc_item_num    
where a.alloc_num in (SELECT alloc_num FROM  #importagency) and bl_date is not null  
  
-- While loop to update FX rates and div_mul_ind   
  
select @my_oid = min(oid) from #tempalloc   
while @my_oid is not null  
begin  
select @my_bl_date = bl_date , @my_alloc_num =alloc_num from #tempalloc where oid = @my_oid  
exec dbo.usp_currency_exch_rate @asof_date = @my_date, @curr_code_from ='USD', @curr_code_to = 'RMB',  
@eff_date = @my_bl_date, @est_final_ind = 'F', @use_out_args_flag = 1, @conv_rate = @my_fx_rate OUTPUT, @calc_oper = @my_div_mul_ind OUTPUT  
  
if ( @my_fx_rate is not null and @my_div_mul_ind is not null)  
if @my_div_mul_ind= 'M'  
update #tempalloc set fx_rate = @my_fx_rate ,div_mul_ind = @my_div_mul_ind   
where oid = @my_oid  
else  
update #tempalloc set fx_rate = round((1/ @my_fx_rate),3) ,div_mul_ind = @my_div_mul_ind   
where oid = @my_oid  
select @my_oid = min(oid) from #tempalloc where oid > @my_oid  
end --End while  
  
SELECT a.alloc_num                allocation_no,-- 1     
       c.cmdty_short_name         crude_oil,-- 2     
       m.mot_full_name            vessel_name,-- 3     
       ai.alloc_item_type Alloc_Item_type, --     
       convert(varchar,ait.load_cmnc_date,101)         loading_date_start,-- 4,6     
       convert(varchar,ait.load_compl_date,101)        loading_date_finish,-- 5,7    
       CASE     
         WHEN load_cmnc_date IS NOT NULL THEN MONTH(load_cmnc_date)     
         ELSE MONTH(load_compl_date)     
       END                        loading_month,-- 8     
       ai.trade_num               trade_num,-- 9,10    
       ti.p_s_ind                 purchase_sale,--      
       acc_book.acct_short_name   booking_co,-- 12     
       acc_supp.acct_short_name   supplier,-- 13     
       acc_client.acct_short_name client,-- 13     
       loc.loc_name           nation,-- 14     
       irr.description   trade_type,-- 15     
       ai.dest_loc_code           port_of_customs,-- 16     
       ai.credit_term_code        credit_terms,-- 18     
       convert(varchar,ait.bl_date,101) bl_date,-- 21     
      convert(varchar,cs.cost_due_date,101) receivable_payment_date,-- 22,23    
       ai.actual_gross_uom_code   primary_uom,-- 24     
       round(ai.actual_gross_qty,3)        bl_discharge_volume_gross,--      
       CASE     
         WHEN ai.actual_gross_uom_code IN ( 'BBL' ) THEN round(ai.actual_gross_qty,3)  
         WHEN ai.sec_actual_uom_code IN ( 'BBL' ) THEN round(ai.secondary_actual_qty,3)     
         WHEN (SELECT uom_type     
               FROM   uom     
               WHERE  uom_code = ai.actual_gross_uom_code) = 'V' THEN     
         round(ai.actual_gross_qty * (SELECT dbo.udf_getUomConversion(ai.actual_gross_uom_code, 'MT', NULL, NULL, NULL)),3)     
  WHEN (SELECT uom_type     
        FROM   uom     
        WHERE  uom_code = ai.sec_actual_uom_code) = 'V' THEN     
  round(ai.secondary_actual_qty * (SELECT dbo.udf_getUomConversion(ai.sec_actual_uom_code, 'MT', NULL, NULL, NULL)),3)     
END                        bl_vol_bbl,     
CASE     
  WHEN ai.actual_gross_uom_code IN ( 'MT' ) THEN round(ai.actual_gross_qty   ,3)  
  WHEN ai.sec_actual_uom_code IN ( 'MT' ) THEN round(ai.secondary_actual_qty,3)  
  WHEN (SELECT uom_type     
        FROM   uom     
        WHERE  uom_code = ai.actual_gross_uom_code) = 'V' THEN     
  round(ai.actual_gross_qty * (SELECT     
dbo.udf_getUomConversion(ai.actual_gross_uom_code, 'BBL', NULL, NULL, NULL)),3)  
  WHEN (SELECT uom_type     
        FROM   uom     
        WHERE  uom_code = ai.sec_actual_uom_code) = 'V' THEN     
  round(ai.secondary_actual_qty * (SELECT     
dbo.udf_getUomConversion(ai.sec_actual_uom_code, 'BBL', NULL, NULL, NULL)),3)  
END              bl_vol_mt,     
ai.sec_actual_uom_code     bl_discharge_uom,--      
round(ai.secondary_actual_qty,3)    bl_discharge_volume_sec,--      
com.cmnt_text              comments,--      
a.alloc_short_cmnt         short_comments,-- 29     
convert(varchar,accum.nominal_start_date,101) pricing_period_start,-- 30     
convert(varchar,accum.nominal_end_date,101) pricing_period_end,-- 31     
null 'pricing_period_start_sale',    
null 'pricing_period_end_sale',    
ti.formula_ind,     
tiwp.mot_code,     
round(ti.avg_price,3),     
tf.formula_num,     
round(cs.cost_unit_price,3)         fob_price_purchase_sale, --    
null 'sale_fob_price',     
cs.cost_price_curr_code,    
cs.cost_price_uom_code,
ai.order_num               order_num,
ai.item_num               item_num,
ai.del_term_code        
FROM   dbo.allocation a     
       JOIN dbo.commodity c     
         ON a.alloc_cmdty_code = c.cmdty_code     
       JOIN dbo.mot m     
         ON a.mot_code = m.mot_code     
       JOIN dbo.allocation_item ai     
         ON a.alloc_num = ai.alloc_num     
       JOIN dbo.allocation_item_transport ait     
         ON a.alloc_num = ait.alloc_num     
            AND ait.alloc_item_num = ai.alloc_item_num     
       JOIN dbo.trade_item ti     
         ON ti.trade_num = ai.trade_num     
            AND ai.order_num = ti.order_num     
            AND ai.item_num = ti.item_num     
       JOIN dbo.trade t_supp     
         ON t_supp.trade_num = ti.trade_num     
       JOIN dbo.trade t_cli     
         ON t_cli.trade_num = ti.trade_num     
       JOIN dbo.account acc_book     
         ON ti.booking_comp_num = acc_book.acct_num     
       JOIN dbo.account acc_supp     
         ON t_supp.acct_num = acc_supp.acct_num     
       JOIN dbo.account acc_client     
         ON t_cli.acct_num = acc_client.acct_num     
       LEFT OUTER JOIN dbo.location loc  
  ON loc.loc_code =ai.origin_loc_code    
       LEFT OUTER JOIN dbo.importer_record_reason imp     
         ON imp.oid = ai.imp_rec_reason_oid     
       JOIN dbo.cost cs     
         ON cs.cost_owner_key1 = a.alloc_num     
            AND cs.cost_owner_key2 = ai.alloc_item_num     
            AND cs.cost_owner_key6 = ti.trade_num                 AND cs.cost_owner_code IN ( 'A', 'AI', 'AA' )     
            AND cs.cost_type_code = 'WPP'     
            AND cost_status != 'CLOSED'     
       LEFT OUTER JOIN dbo.comment com     
         ON com.cmnt_num = a.cmnt_num     
       LEFT OUTER JOIN dbo.accumulation accum     
         ON accum.trade_num = ti.trade_num  
     AND accum.order_num = ti.order_num     
            AND accum.item_num = ti.item_num  
       LEFT OUTER JOIN dbo.trade_item_wet_phy tiwp     
         ON tiwp.trade_num = ti.trade_num     
            AND tiwp.order_num = ti.order_num     
            AND tiwp.item_num = ti.item_num     
       LEFT OUTER JOIN dbo.trade_formula tf     
         ON tf.trade_num = ti.trade_num     
            AND tf.order_num = ti.order_num     
            AND tf.item_num = ti.item_num   
 LEFT OUTER JOIN dbo.importer_record_reason irr      
         ON irr.oid = ai.imp_rec_reason_oid  
WHERE  a.alloc_num IN (SELECT alloc_num     
                       FROM   #importagency)     
ORDER  BY a.alloc_num       
    
SELECT A.alloc_num,C.cost_owner_key2 Alloc_Item, C.cost_owner_key6 Trade_Num, C.cost_amt,cost_pay_rec_ind, 'FREIGHT' ALIAS_FEE FROM dbo.cost C      
LEFT OUTER JOIN allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'FREIGHT')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'INSPECTION FEE'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'INSPECTION FEE')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'CERTIFICATION FEE'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'CERTIFICATION')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'WAR'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'WAR')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'FREIGHTTAX'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'FREIGHTTAX')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'PORTFEE'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'PORTFEE')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'CMDTYTAX'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'CMDTYTAX')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'DEVIATION'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'DEVIATION')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'DOCKING'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'DOCKING')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'HELICOPTER'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'HELICOPTER')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'OVERSEAS'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'OVERSEAS')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'INSURANCE'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'INSURANCE')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'OTHER COSTS'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND     
cmdty_alias_name NOT IN ('FREIGHT','INSPECTION FEE','CERTIFICATION','WAR','FREIGHTTAX','PORTFEE','CMDTYTAX','DEVIATION', 'DOCKING','HELICOPTER','OVERSEAS','INSURANCE','DEMURRAGE','AGENCYFEE'))    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION    
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'DEMURRAGE'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'DEMURRAGE')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION    
SELECT A.alloc_num,C.cost_owner_key2, C.cost_owner_key6, C.cost_amt,cost_pay_rec_ind, 'AGENCYFEE'  FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'AGENCYFEE')    
AND cost_owner_code IN ('A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
ORDER BY ALIAS_FEE    
    
SELECT DISTINCT Acc.acct_short_name,A.alloc_num,'INSPECTION FEE' 'ALIAS_FEE' FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
JOIN account Acc ON Acc.acct_num = C.acct_num     
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'INSPECTION FEE')    
AND cost_owner_code IN ( 'A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
UNION     
SELECT DISTINCT Acc.acct_short_name,A.alloc_num,'INSURANCE' 'ALIAS_FEE' FROM dbo.cost C      
LEFT OUTER JOIN dbo.allocation A ON  cost_owner_key1 =A.alloc_num    
JOIN account Acc ON Acc.acct_num = C.acct_num     
WHERE cost_code IN (SELECT cmdty_code FROM dbo.commodity_alias WHERE alias_source_code='COREPORT' AND cmdty_alias_name = 'INSURANCE')    
AND cost_owner_code IN ( 'A','AI','AA') AND cost_status !='CLOSED' AND A.alloc_num IN (select alloc_num from #importagency)    
    
SELECT ai.alloc_num,     
       alloc_item_type,     
       ai.trade_num,     
       fb.formula_num,     
       formula_body_num,     
       formula_body_string,  
       formula_body_type,  
       differential_val,  
       --accum_start_date,  
       upper(CONVERT(CHAR(3), accum_start_date, 100)) as 'accm_month'  
FROM   dbo.allocation_item ai     
       JOIN dbo.trade_formula tf     
         ON tf.trade_num = ai.trade_num     
            AND tf.order_num = ai.order_num     
            AND tf.item_num = ai.item_num     
     JOIN dbo.formula_body fb     
    ON fb.formula_num = tf.formula_num  
      LEFT OUTER JOIN (select min(accum_start_date) accum_start_date,trade_num,order_num,item_num,alloc_num   
from dbo.accumulation  where alloc_num in (SELECT alloc_num FROM   #importagency)  
group by trade_num,order_num,item_num,alloc_num) accm  
        ON accm.alloc_num = ai.alloc_num  
           AND accm.trade_num = ai.trade_num     
           AND accm.order_num = ai.order_num     
           AND accm.item_num = ai.item_num  
WHERE  ai.alloc_num IN (SELECT alloc_num FROM   #importagency) and formula_body_string is not null  
    
select * from #tempalloc  
  
drop table #importagency    
drop table #tempalloc    
  
endofsp:    
return 0    
GO
GRANT EXECUTE ON  [dbo].[usp_import_agency_report] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_import_agency_report', NULL, NULL
GO
