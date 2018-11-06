SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_pm_verify_refdata_and_aggregate_sales]
(       
   @p_feed_data_id       int = NULL,        
   @process_failed_recs  tinyint = NULL,           
   @start_date           datetime = NULL,        
   @end_date             datetime = NULL,        
   @debug                tinyint = 0
)        
as        
set nocount on 
set xact_abort on     
DECLARE @max_transid   INT        
DECLARE @feed_data_id   INT        
DECLARE @tbl_comp_splc_codes  TABLE (company_code CHAR(3), splc_code CHAR(9))        
DECLARE @tbl_feed_details  TABLE (feed_data_id INT, feed_detail_data_id INT)         
DECLARE @tbl_feed_error   TABLE (feed_data_id INT, feed_detail_data_id INT, description VARCHAR(800))         
DECLARE @tbl_feed_error_gbl  TABLE (feed_data_id INT, feed_detail_data_id INT, description VARCHAR(800))         
DECLARE @tbl_feeds   TABLE (feed_data_id int)        
        
DECLARE @pm_aggregated_records_tmp AS TABLE (feed_data_id  INT,        
       company_code  NVARCHAR(128),        
       mapped_acct_num INT,        
       start_load_date VARCHAR(128),        
       end_load_date  VARCHAR(128),        
       splc_code  VARCHAR(128),        
       mapped_loc_code VARCHAR(128),        
       bol_number  VARCHAR(128),        
       comp_prod_code  VARCHAR(128),        
       mapped_cmdty_code VARCHAR(128),        
       terminal_ctrl_num VARCHAR(128),        
       grossQty   FLOAT NULL,      
       qty   FLOAT NULL,      
       uom   VARCHAR(128),        
       WASP   FLOAT        
      )        
DECLARE  @pm_aggregated_records_gbl_tmp AS TABLE (feed_data_id  INT,        
       company_code  NVARCHAR(128),        
       mapped_acct_num INT,        
       start_load_date VARCHAR(128),        
       end_load_date  VARCHAR(128),        
       splc_code  VARCHAR(128),        
       mapped_loc_code VARCHAR(128),        
       bol_number  VARCHAR(128),        
       comp_prod_code  VARCHAR(128),        
       mapped_cmdty_code VARCHAR(128),        
       terminal_ctrl_num VARCHAR(128),      
       grossQty   FLOAT NULL,      
       qty   FLOAT NULL,      
       uom   VARCHAR(128),        
       WASP   FLOAT        
      )        
DECLARE @does_grand_total_match  INT         
DECLARE @new_num   INT        
DECLARE @row_count   INT 
DECLARE @splc_company_code_pair   VARCHAR(640)        
              
IF (@process_failed_recs IS NULL)        
BEGIN        
 SET @process_failed_recs = 0        
END        
        
IF (@start_date IS NOT NULL AND @end_date IS NOT NULL)        
BEGIN        
 IF (@end_date < @start_date)        
 BEGIN        
  PRINT '@end_date should be greater than or equal to @start_date'        
  RETURN        
 END         
 IF (@end_date = @start_date)        
 BEGIN        
  SET @end_date = DATEADD(d, 1, @start_date);        
 END         
        
    IF (@debug = 1)        
    BEGIN        
   PRINT '@start_date = ' +  CASE WHEN @start_date IS NULL THEN 'null' ELSE CAST(@start_date as nvarchar(40)) END        
   PRINT '@end_date = ' + CASE WHEN @end_date IS NULL THEN 'null' ELSE CAST(@end_date  as nvarchar(40)) END        
    END        
END        
        
IF (@start_date IS NOT NULL AND @end_date IS NOT NULL)        
BEGIN        
 INSERT INTO @tbl_feeds (feed_data_id)        
 SELECT fd.oid        
   FROM         
   feed_data       fd             
   INNER JOIN feed_definition    fdn          ON fd.feed_id       = fdn.oid        
   INNER JOIN icts_transaction   it           ON it.trans_id      = fd.trans_id                
   WHERE fdn.feed_name = 'PETROMAN_INTERFACE'        
   AND (it.tran_date >= @start_date AND it.tran_date <= @end_date)         
   --AND fd.status IN ('PENDING', 'PROC_SCHLD', 'PROCESSING')  
END        
        
ELSE IF  (@p_feed_data_id IS NOT NULL) -- Process a particular feed        
BEGIN        
 INSERT INTO @tbl_feeds (feed_data_id) VALUES(@p_feed_data_id)          
END        
        
ELSE IF (@process_failed_recs = 1) -- Process all error records        
BEGIN        
 INSERT INTO @tbl_feeds (feed_data_id)        
 SELECT DISTINCT fd.oid        
   FROM         
   feed_data       fd             
   INNER JOIN feed_definition    fdn          ON fd.feed_id           = fdn.oid        
   INNER JOIN feed_error    fe           ON fe.feed_data_id      = fd.oid                
   WHERE fdn.feed_name = 'PETROMAN_INTERFACE'        
END         
        
ELSE --Process all the pending records        
BEGIN        
 INSERT INTO @tbl_feeds (feed_data_id)        
 SELECT fd.oid        
   FROM         
   feed_data       fd             
   INNER JOIN feed_definition    fdn          ON fd.feed_id       = fdn.oid           
   WHERE fdn.feed_name = 'PETROMAN_INTERFACE' AND fd.status IN ('PENDING', 'PROC_SCHLD', 'PROCESSING')        
END        
        
IF (@debug = 1)        
 BEGIN        
  SELECT '@tbl_feeds contents', * FROM @tbl_feeds;        
 END        
        
DECLARE c_feeds CURSOR READ_ONLY FORWARD_ONLY LOCAL FOR         
SELECT feed_data_id FROM @tbl_feeds ORDER BY 1;        
        
OPEN c_feeds FETCH NEXT FROM c_feeds INTO @feed_data_id        
        
WHILE @@FETCH_STATUS = 0        
BEGIN        
        
 DELETE @tbl_feed_error_gbl;        
 DELETE @tbl_feed_details;
 SET @does_grand_total_match = 1
        
 IF (@process_failed_recs = 1) -- Here we have to pick error records(like suspended/val_failed/failed) from feed_error table.         
 BEGIN        
  INSERT INTO @tbl_feed_details(feed_data_id, feed_detail_data_id)        
  SELECT fdd.feed_data_id, fdd.oid FROM feed_detail_data fdd         
  WHERE feed_data_id = @feed_data_id AND status IN ('FAILED', 'SUSPENDED', 'VAL_FAILED')        
          
    END        
    ELSE        
    BEGIN             
  INSERT INTO @tbl_feed_details(feed_data_id, feed_detail_data_id)        
  SELECT feed_data_id, oid from feed_detail_data WHERE feed_data_id = @feed_data_id AND status IN ('PENDING', 'PROC_SCHLD', 'PROCESSING')         
 END        
        
 IF (@debug = 1)        
 BEGIN        
  SELECT '@tbl_feed_details' AS before_verification_of_refdata, * FROM @tbl_feed_details;        
 END        
   
 --------------------------------------------------------------------------        
 ------------------- Verification of totalling of quantities: Begin--------  
 --------------------------------------------------------------------------   
 IF ((SELECT number_of_rows FROM feed_data WHERE oid = @feed_data_id) = (SELECT COUNT(*) FROM @tbl_feed_details))  
 BEGIN  
    -- Match the sum of subtotals with the grand total        
    SELECT @does_grand_total_match =         
    CASE WHEN SUM(CAST(type4.gross_qty_sub_total AS FLOAT)) = CAST(type5.grand_tot_gross_qty AS FLOAT) AND         
              SUM(CAST(type4.net_qty_sub_total AS FLOAT))   = CAST(type5.grand_tot_net_qty AS FLOAT)        
    THEN        
        1        
    ELSE        
        0        
    END         
    FROM pm_type_4_record type4, pm_type_5_record type5         
    WHERE type4.fdd_id IN (SELECT feed_detail_data_id FROM @tbl_feed_details) AND        
          type5.fdd_id IN (SELECT feed_detail_data_id FROM @tbl_feed_details)         
    GROUP BY type5.grand_tot_gross_qty, type5.grand_tot_net_qty    
        
    IF (@debug = 1)        
    BEGIN        
        PRINT '@does_grand_total_match = ' + cast(@does_grand_total_match AS NVARCHAR)        
    END        
             
    IF (@does_grand_total_match = 0)        
    BEGIN        
        --If the grand total does not match, all the records have to put in error.        
        DELETE  @tbl_feed_error        
        INSERT INTO @tbl_feed_error         
        SELECT t.feed_data_id, t.feed_detail_data_id, 'Inconsistent Data: Grand total does not match with the sum of subtotals'        
        FROM @tbl_feed_details t        
          
        -- Update @tbl_feed_error_gbl table if some other error has been registered with the given feed_data_id and feed_detail_data_id        
        UPDATE fe         
        SET fe.description = fe.description + ', ' + tfe.description        
        FROM @tbl_feed_error_gbl fe         
        INNER JOIN @tbl_feed_error tfe ON fe.feed_data_id = tfe.feed_data_id AND fe.feed_detail_data_id = tfe.feed_detail_data_id        
            
        -- Insert into @tbl_feed_error_gbl table new errors that have not been present before        
        INSERT INTO @tbl_feed_error_gbl(feed_data_id, feed_detail_data_id, description)        
        SELECT t.feed_data_id, t.feed_detail_data_id, t.description        
        FROM @tbl_feed_error t WHERE NOT EXISTS(SELECT NULL FROM @tbl_feed_error_gbl WHERE feed_data_id = t.feed_data_id AND feed_detail_data_id = t.feed_detail_data_id)        

             
        -- Set all the feed details to val_failed status   
/*          
        BEGIN TRAN        
            EXEC gen_new_transaction_NOI 'usp_pm_verify_refdata_and_...', 'U'        
            SELECT @max_transid = last_num  FROM dbo.icts_trans_sequence  WHERE oid = 1          
        COMMIT TRANSACTION        
            
        UPDATE feed_detail_data SET status = 'VAL_FAILED', trans_id = @max_transid WHERE feed_data_id = @feed_data_id        
        UPDATE feed_data  SET status = 'VAL_FAILED', trans_id = @max_transid WHERE oid          = @feed_data_id        
*/  
    END  
     
    --Check for subtotals.   
    BEGIN  
        SET @splc_company_code_pair = ''

        -- Collect the type-4 records whose subtotals do not match with the sum of quantites of type-b records        
        INSERT INTO @tbl_comp_splc_codes (company_code, splc_code)          
        SELECT t.company_code, t.splc_code FROM         
        (        
        SELECT DISTINCT 
            b.company_code,         
            b.splc_code,         
            SUM(CAST(b.gross_qty AS FLOAT) * (CASE WHEN b.billed_credit_sign = '-' THEN -1 ELSE 1 END)) AS type_b_gross_qty_subtotal,         
            CAST(type4.gross_qty_sub_total AS FLOAT)  AS type_4_gross_qty_subtotal        
        FROM pm_type_b_record b          
        INNER JOIN pm_type_4_record type4 on b.company_code = type4.company_code AND         
                  b.splc_code    = type4.splc_code            
        WHERE b.fdd_id  IN (SELECT feed_detail_data_id FROM @tbl_feed_details) AND        
           type4.fdd_id IN (SELECT feed_detail_data_id FROM @tbl_feed_details)         
        GROUP BY b.company_code, b.splc_code, type4.gross_qty_sub_total        
        ) t         
        WHERE t.type_b_gross_qty_subtotal != t.type_4_gross_qty_subtotal        

        SELECT @splc_company_code_pair = @splc_company_code_pair + '(' + company_code + ',' + splc_code + '),'
        FROM @tbl_comp_splc_codes 
        
        IF (@debug = 1)        
        BEGIN        
            SELECT '@tbl_comp_splc_codes ' AS unmatched_type_4_subtotals, * FROM @tbl_comp_splc_codes
            SELECT '@splc_company_code_pair=' + @splc_company_code_pair;
        END
        
        DELETE  @tbl_feed_error
        IF (LEN(@splc_company_code_pair) > 0)
        BEGIN
            SET @splc_company_code_pair = SUBSTRING(@splc_company_code_pair, 1, LEN(@splc_company_code_pair) - 1)    
            -- Insert into @tbl_feed_error any mismatch of subtotals with the sum of quantities                            
            INSERT INTO @tbl_feed_error         
            SELECT tfd.feed_data_id, tfd.feed_detail_data_id,  
                    'Inconsistent Data: For the following Company code & SPLC code combinations - '   
                    + @splc_company_code_pair 
                    + ' - subtotals of type-4 records do not match with the sums of quantities of type-B records'  
            FROM @tbl_feed_details tfd
            --FROM pm_type_b_record b         
            --INNER JOIN @tbl_feed_details tfd    ON tfd.feed_detail_data_id = b.fdd_id        
            --INNER JOIN @tbl_comp_splc_codes csc ON csc.company_code = b.company_code AND csc.splc_code = b.splc_code        
        END    
        -- Update @tbl_feed_error_gbl table if some other error has been registered with the given feed_data_id and feed_detail_data_id        
        UPDATE fe         
        SET fe.description = fe.description + ', ' + tfe.description        
        FROM @tbl_feed_error_gbl fe         
        INNER JOIN @tbl_feed_error tfe ON fe.feed_data_id = tfe.feed_data_id AND fe.feed_detail_data_id = tfe.feed_detail_data_id        
            
        -- Insert into @tbl_feed_error_gbl table new errors that have not been present before        
        INSERT INTO @tbl_feed_error_gbl(feed_data_id, feed_detail_data_id, description)        
        SELECT t.feed_data_id, t.feed_detail_data_id, t.description        
        FROM @tbl_feed_error t WHERE NOT EXISTS(SELECT NULL FROM @tbl_feed_error_gbl WHERE feed_data_id = t.feed_data_id AND feed_detail_data_id = t.feed_detail_data_id)        
              
        IF (@debug = 1)        
        BEGIN        
            SELECT '@tbl_feed_error_gbl' AS after_matching_subtotals, * FROM @tbl_feed_error_gbl        
        END     
    END      
END   
  --------------------------------------------------------------------------        
 ------------------- Verification of totalling of quantities: End-----------  
 ---------------------------------------------------------------------------  
   
 --------------------------------------------------------------------------        
 ------------------- Verification of Reference Data: Begin-----------------        
 --------------------------------------------------------------------------        
        
 ----------------------------------        
 -- Verify company_code:Begin        
 ----------------------------------        
 --First insert errors into a temporary error table         
 DELETE  @tbl_feed_error        
 INSERT INTO @tbl_feed_error         
 SELECT t.feed_data_id, t.feed_detail_data_id, '(As of ' + CAST(getdate() AS NVARCHAR) + ') Company Code: ''' + LTRIM(RTRIM(t.company_code)) + ''' has not been mapped to an account in symphony'        
 FROM         
 (        
  SELECT tfd.feed_data_id, tfd.feed_detail_data_id, a.company_code         
  FROM pm_type_a_record a         
  INNER JOIN @tbl_feed_details tfd ON tfd.feed_detail_data_id = a.fdd_id        
        
  UNION        
        
  SELECT tfd.feed_data_id, tfd.feed_detail_data_id, b.company_code         
  FROM pm_type_b_record b         
  INNER JOIN @tbl_feed_details tfd ON tfd.feed_detail_data_id = b.fdd_id        
 ) t         
 LEFT OUTER JOIN ext_refdata_mapping em ON t.company_code   = em.external_key1 AND em.alias_source_code = 'PETROMAN'        
 LEFT OUTER JOIN icts_entity_name ie ON ie.oid     = em.entity_id        
 LEFT OUTER JOIN ext_ref_keys er   ON em.entity_key1_value_id = er.oid        
 LEFT OUTER JOIN account ac    ON ac.acct_num    = er.int_key_value        
 WHERE ac.acct_num IS NULL         
  
-- Update @tbl_feed_error_gbl table if some other error has been registered with the given feed_data_id and feed_detail_data_id        
 UPDATE fe         
  SET fe.description = fe.description + ', ' + tfe.description        
 FROM @tbl_feed_error_gbl fe         
 INNER JOIN @tbl_feed_error tfe ON fe.feed_data_id = tfe.feed_data_id AND fe.feed_detail_data_id = tfe.feed_detail_data_id   
   
 -- Insert into @tbl_feed_error_gbl table new errors that have not been present before        
 INSERT INTO @tbl_feed_error_gbl(feed_data_id, feed_detail_data_id, description)        
 SELECT t.feed_data_id, t.feed_detail_data_id, t.description        
 FROM @tbl_feed_error t WHERE NOT EXISTS(SELECT NULL FROM @tbl_feed_error_gbl WHERE feed_data_id = t.feed_data_id AND feed_detail_data_id = t.feed_detail_data_id)        
        
 IF (@debug = 1)        
 BEGIN        
  SELECT '@tbl_feed_error_gbl' AS after_company_code_verification, * FROM @tbl_feed_error_gbl        
 END        
 ----------------------------------             
 -- Verify company_code:End        
 ----------------------------------        
        
 ----------------------------------        
 -- Verify splc_code:Begin        
 ----------------------------------        
         
 DELETE  @tbl_feed_error        
 INSERT INTO @tbl_feed_error         
 SELECT t.feed_data_id, t.feed_detail_data_id, '(As of ' + CAST(getdate() AS NVARCHAR) + ') SPLC Code: ''' + LTRIM(RTRIM(t.splc_code)) + ''' has not been mapped to a location in symphony'        
 FROM         
 (        
  SELECT tfd.feed_data_id, tfd.feed_detail_data_id, a.splc_code         
  FROM pm_type_a_record a         
  INNER JOIN @tbl_feed_details tfd ON tfd.feed_detail_data_id = a.fdd_id        
        
  UNION        
        
  SELECT tfd.feed_data_id, tfd.feed_detail_data_id, b.splc_code         
  FROM pm_type_b_record b         
  INNER JOIN @tbl_feed_details tfd ON tfd.feed_detail_data_id = b.fdd_id        
 ) t         
 LEFT OUTER JOIN ext_refdata_mapping em ON t.splc_code    = em.external_key1 AND em.alias_source_code = 'PETROMAN'        
 LEFT OUTER JOIN icts_entity_name ie ON ie.oid     = em.entity_id        
 LEFT OUTER JOIN ext_ref_keys er   ON em.entity_key1_value_id = er.oid        
 LEFT OUTER JOIN location lo    ON lo.loc_code    = er.str_key_value        
 WHERE lo.loc_num IS NULL         
        
 -- Update @tbl_feed_error_gbl table if some other error has been registered with the given feed_data_id and feed_detail_data_id        
 UPDATE fe         
  SET fe.description = fe.description + ', ' + tfe.description        
 FROM @tbl_feed_error_gbl fe         
 INNER JOIN @tbl_feed_error tfe ON fe.feed_data_id = tfe.feed_data_id AND fe.feed_detail_data_id = tfe.feed_detail_data_id        
        
 -- Insert into @tbl_feed_error_gbl table new errors that have not been present before        
 INSERT INTO @tbl_feed_error_gbl(feed_data_id, feed_detail_data_id, description)        
 SELECT t.feed_data_id, t.feed_detail_data_id, t.description        
 FROM @tbl_feed_error t WHERE NOT EXISTS(SELECT NULL FROM @tbl_feed_error_gbl WHERE feed_data_id = t.feed_data_id AND feed_detail_data_id = t.feed_detail_data_id)        
        
 IF (@debug = 1)        
 BEGIN        
  SELECT '@tbl_feed_error_gbl' AS after_splc_code_verification, * FROM @tbl_feed_error_gbl        
 END        
 ----------------------------------        
 -- Verify splc_code:End        
 ----------------------------------        
        
 ----------------------------------        
 --Verify comp_prod_code:Begin        
 ----------------------------------        
        
 DELETE  @tbl_feed_error        
 INSERT INTO @tbl_feed_error         
 SELECT t.feed_data_id, t.feed_detail_data_id, '(As of ' + CAST(getdate() AS NVARCHAR) + ') Component Product Code: ''' + LTRIM(RTRIM(t.comp_prod_code)) + ''' has not been mapped to a commodity in symphony'        
 FROM         
 (        
  SELECT tfd.feed_data_id, tfd.feed_detail_data_id, b.comp_prod_code         
  FROM pm_type_b_record b         
  INNER JOIN @tbl_feed_details tfd ON tfd.feed_detail_data_id = b.fdd_id        
 ) t         
 LEFT OUTER JOIN ext_refdata_mapping em ON t.comp_prod_code   = em.external_key1 AND em.alias_source_code = 'PETROMAN'        
 LEFT OUTER JOIN icts_entity_name ie ON ie.oid     = em.entity_id         
 LEFT OUTER JOIN ext_ref_keys er   ON em.entity_key1_value_id = er.oid        
 LEFT OUTER JOIN commodity co   ON co.cmdty_code   = er.str_key_value        
 WHERE co.cmdty_code IS NULL         
        
 -- Update @tbl_feed_error_gbl table if some other error has been registered with the given feed_data_id and feed_detail_data_id        
 UPDATE fe         
  SET fe.description = fe.description + ', ' + tfe.description        
 FROM @tbl_feed_error_gbl fe         
 INNER JOIN @tbl_feed_error tfe ON fe.feed_data_id = tfe.feed_data_id AND fe.feed_detail_data_id = tfe.feed_detail_data_id        
        
 -- Insert into @tbl_feed_error_gbl table new errors that have not been present before        
 INSERT INTO @tbl_feed_error_gbl(feed_data_id, feed_detail_data_id, description)        
 SELECT t.feed_data_id, t.feed_detail_data_id, t.description        
 FROM @tbl_feed_error t WHERE NOT EXISTS(SELECT NULL FROM @tbl_feed_error_gbl WHERE feed_data_id = t.feed_data_id AND feed_detail_data_id = t.feed_detail_data_id)        
        
 IF (@debug = 1)       
 BEGIN        
  SELECT '@tbl_feed_error_gbl' AS after_product_code_verification, * FROM @tbl_feed_error_gbl        
 END        
 ----------------------------------        
 --Verify comp_prod_code:End        
 ----------------------------------        
         
 --------------------------------------------------------------------------        
 ------------------- Verification of Reference Data: End-------------------        
 --------------------------------------------------------------------------        
 BEGIN --Steps after validation of input data  
  -- Update all errorneous feed detail data records with val_failed status.         
  -- The query below updates typeA, typeB and type4(whose values did not match with the subtotals of typeB) records which are in error.        
        
  BEGIN TRAN        
   EXEC gen_new_transaction_NOI 'usp_pm_verify_refdata_and_...', 'U'        
   SELECT @max_transid = last_num  FROM dbo.icts_trans_sequence  WHERE oid = 1          
  COMMIT TRANSACTION        
          
  PRINT '@max_transid=' + CASE WHEN @max_transid IS NULL THEN 'NULL' ELSE CAST(@max_transid as nvarchar) END        
  UPDATE fdd         
   SET fdd.status  = 'VAL_FAILED',        
    fdd.trans_id = @max_transid    
  FROM feed_detail_data fdd        
  INNER JOIN @tbl_feed_details tfd ON tfd.feed_detail_data_id = fdd.oid        
  INNER JOIN @tbl_feed_error_gbl fe   ON fe.feed_detail_data_id  = tfd.feed_detail_data_id        
          
       
        
  -- Now delete from @tbl_feed_details the feed_detail_ids that are in error        
  IF (@debug = 1)        
  BEGIN        
   SELECT '@tbl_feed_details' AS records_in_error, * FROM @tbl_feed_details t WHERE EXISTS (SELECT NULL FROM @tbl_feed_error_gbl f WHERE t.feed_data_id = f.feed_data_id AND t.feed_detail_data_id = f.feed_detail_data_id);        
  END        
          
  DELETE @tbl_feed_details         
  FROM @tbl_feed_details t         
  INNER JOIN @tbl_feed_error_gbl f ON t.feed_data_id = f.feed_data_id AND t.feed_detail_data_id = f.feed_detail_data_id;        
          
  IF (@debug = 1)        
  BEGIN        
   SELECT '@tbl_feed_details' AS after_removing_error_records, * FROM @tbl_feed_details t;        
  END        
        
  --It might be the case that during reprocessing, due to an error in component product code,         
  --all that we have are typeB records. For the next SQL statement that does aggregation to work, we need corresponding type A records as well.        
  --Hence add the type A records that corresponds to type B records.        
        
  IF (NOT EXISTS(SELECT NULL FROM @tbl_feed_details INNER JOIN pm_type_a_record ON fdd_id = feed_detail_data_id))        
  BEGIN        
   INSERT INTO @tbl_feed_details (feed_data_id, feed_detail_data_id)        
   SELECT DISTINCT @feed_data_id, typeA.fdd_id         
    FROM pm_type_a_record typeA         
    INNER JOIN pm_type_b_record typeB ON (typeA.bol_number   = typeB.bol_number)         
                AND (typeA.splc_code  = typeB.splc_code)         
                AND (typeA.company_code = typeB.company_code        
               )        
    INNER JOIN @tbl_feed_details tfd  ON tfd.feed_detail_data_id = typeB.fdd_id  
    INNER JOIN feed_detail_data fdd ON fdd.oid = typeA.fdd_id WHERE fdd.feed_data_id = @feed_data_id        
        
   IF (@debug = 1)        
   BEGIN        
    SELECT '@tbl_feed_details' AS after_adding_typeA_records, * FROM @tbl_feed_details t;        
   END        
  END        
        
  -- Aggregate type-b records excluding those records whose sum of quantities do not match         
  -- with the subtotals of type-4 records, collected into @tbl_comp_splc_codes in the previous step.         
  INSERT INTO @pm_aggregated_records_tmp        
  SELECT           
   tfd.feed_data_id,        
   RTRIM(CAST(typeA.company_code AS VARCHAR))  AS company_code -- Casting chars to varchar, because to a bug in hibernate, which returns only the first character of char(N) datatypes        
   ,ac.acct_num         AS mapped_acct_num        
   ,CAST(typeA.start_load_date AS VARCHAR)   AS start_load_date        
   ,CAST(typeA.end_load_date AS VARCHAR)   AS end_load_date        
   ,CAST(typeA.splc_code AS VARCHAR)    AS splc_code        
   ,RTRIM(CAST(lo.loc_code AS VARCHAR))   AS mapped_loc_code   
   ,CAST(typeA.bol_number AS VARCHAR)    AS bol_number        
   --,CAST(typeA.bol_version AS VARCHAR)    AS bol_version        
   ,RTRIM(CAST(typeB.comp_prod_code AS VARCHAR)) AS comp_prod_code        
   ,RTRIM(CAST(co.cmdty_code AS VARCHAR))   AS mapped_cmdty_code        
   ,CAST(typeB.terminal_ctrl_num AS VARCHAR)  AS terminal_ctrl_num        
 ,SUM(CAST(typeB.gross_qty as FLOAT) *       
    (CASE WHEN typeB.gross_credit_sign = '-'         
     THEN -1 ELSE 1 END))/100               AS grossQty        
   ,SUM(CAST(typeB.billed_qty as FLOAT) *       
    (CASE WHEN typeB.billed_credit_sign = '-'         
     THEN -1 ELSE 1 END))/100               AS qty        
   ,CAST(typeB.measurement_type AS VARCHAR)     AS uom         
   ,SUM((Cast(typeB.billed_qty as FLOAT)/100) * (Cast(typeB.unit_price as float)/100000))      
    /        
    SUM((Cast(typeB.billed_qty as FLOAT)/100)) AS WASP --Weighted avg is the same regardless of bill_credit_sign and hence bill_credit_sign is ignored in calculations      
   --,CAST(typeB.gross_credit_sign AS VARCHAR)  AS gross_credit_sign        
   --,CAST(typeB.billed_credit_sign AS VARCHAR)  AS billed_credit_sign        
   --,CAST(typeB.net_credit_sign AS VARCHAR)   AS net_credit_sign           
   FROM(        
    SELECT DISTINCT         
    company_code        
    ,splc_code        
    ,terminal_ctrl_num        
    ,bol_number        
   -- ,bol_version        
    ,start_load_date        
    ,start_load_time        
    ,end_load_date        
    ,end_load_time        
    ,consignee_num        
    ,dest_state_code        
    ,dest_county_code        
    ,dest_city_code        
    ,carrier_code        
    ,carrier_fein        
    ,vehicle_num        
    ,vehicle_type        
    ,third_party        
    ,po_order_num        
    ,release_num        
    ,split_load_flag        
    ,time_zone        
    ,shipper_info        
    FROM pm_type_a_record WHERE fdd_id IN (SELECT feed_detail_data_id FROM @tbl_feed_details)) typeA        
    INNER JOIN pm_type_b_record typeB      ON (typeA.bol_number  = typeB.bol_number)         
           AND (typeA.splc_code  = typeB.splc_code)         
           AND (typeA.company_code = typeB.company_code        
                 )        
    INNER JOIN ext_refdata_mapping em1   ON typeB.company_code = em1.external_key1 AND em1.alias_source_code = 'PETROMAN'        
    INNER JOIN icts_entity_name ie1   ON ie1.oid = em1.entity_id AND ie1.entity_name = 'Account'        
    INNER JOIN ext_ref_keys er1    ON em1.entity_key1_value_id = er1.oid        
    INNER JOIN account ac     ON ac.acct_num = er1.int_key_value        
        
        
    INNER JOIN ext_refdata_mapping em2   ON typeB.splc_code = em2.external_key1 AND em2.alias_source_code = 'PETROMAN'         
    INNER JOIN icts_entity_name ie2   ON ie2.oid = em2.entity_id AND ie2.entity_name = 'Location'        
    INNER JOIN ext_ref_keys er2    ON em2.entity_key1_value_id = er2.oid        
    INNER JOIN location lo     ON lo.loc_code = er2.str_key_value        
            
        
    INNER JOIN ext_refdata_mapping em3   ON typeB.comp_prod_code = em3.external_key1 AND em3.alias_source_code = 'PETROMAN'         
    INNER JOIN icts_entity_name ie3   ON ie3.oid = em3.entity_id AND ie3.entity_name = 'Commodity'         
    INNER JOIN ext_ref_keys er3    ON em3.entity_key1_value_id = er3.oid        
    INNER JOIN commodity co     ON co.cmdty_code = er3.str_key_value        
        
    INNER JOIN @tbl_feed_details tfd   ON tfd.feed_detail_data_id = typeB.fdd_id        
            
    WHERE @does_grand_total_match = 1 -- This is necessary. If grand total doesn't match, we still need to return a record set on the java side        
            
    GROUP BY         
    typeA.company_code        
    ,typeA.start_load_date        
    ,typeA.end_load_date        
    ,typeA.splc_code        
    ,typeA.bol_number        
    --,typeA.bol_version        
    ,typeB.comp_prod_code        
    ,ac.acct_num        
    ,lo.loc_code        
    ,co.cmdty_code        
    ,typeB.measurement_type           
    ,typeB.terminal_ctrl_num           
    --,typeB.billed_qty          
    --,typeB.unit_price        
    ,tfd.feed_data_id         
    --,typeB.gross_credit_sign        
    --,typeB.billed_credit_sign        
    --,typeB.net_credit_sign        
        
    ORDER BY        
    typeA.company_code        
    ,typeA.start_load_date ASC         
    ,typeA.splc_code        
    ,typeB.comp_prod_code;        
        
        
  INSERT INTO @pm_aggregated_records_gbl_tmp        
  SELECT * FROM @pm_aggregated_records_tmp;        
        
  DELETE FROM @pm_aggregated_records_tmp;        
        
  ------------------------------------------------------------------------------        
  --Update the status to processing of those records that have been aggregated--        
  ------------------------------------------------------------------------------        
  BEGIN        
        
   BEGIN TRAN        
    EXEC  gen_new_transaction_NOI 'usp_pm_verify_refdata_and_...', 'U'        
    SELECT @max_transid = last_num  FROM dbo.icts_trans_sequence  WHERE oid = 1          
   COMMIT TRANSACTION        
        
   --Change the status of feed_detail and feed_data        
   UPDATE fdd         
   SET         
   fdd.status  ='PROCESSING',        
   fdd.trans_id = @max_transid        
   FROM         
   feed_detail_data fdd         
   INNER JOIN @tbl_feed_details  tfd ON tfd.feed_data_id = fdd.feed_data_id AND tfd.feed_detail_data_id = fdd.oid        
        
   UPDATE feed_data SET status = 'PROCESSING',trans_id = @max_transid WHERE oid = @feed_data_id  
  END        
 END -- end of 'Steps after validation of input data'  
        
 -------------------------------------------------------------------------------------------------        
 --Update the feed_error table from @tbl_feed_error_gbl based on the errors seen in this context--        
 -------------------------------------------------------------------------------------------------        
         
 BEGIN        
  BEGIN TRAN        
   EXEC gen_new_transaction_NOI 'usp_pm_verify_refdata_and_...', 'U'        
   SELECT @max_transid = last_num  FROM dbo.icts_trans_sequence  WHERE oid = 1          
  COMMIT TRANSACTION        
        
  -- Update feed_error table if some other error has been registered with the given feed_data_id and feed_detail_data_id  
/*    
  UPDATE fe         
   SET fe.description = fe.description + ', ' + tfe.description,        
   trans_id        = @max_transid        
  FROM feed_error fe         
  INNER JOIN @tbl_feed_error_gbl tfe ON fe.feed_data_id = tfe.feed_data_id AND fe.feed_detail_data_id = tfe.feed_detail_data_id        
  */      
  -- Insert into feed_error table from the temporary error table        
  SELECT @new_num = last_num FROM new_num WHERE num_col_name = 'feed_error_oid';        
        
  INSERT INTO feed_error(oid, feed_data_id, feed_detail_data_id, description, trans_id)        
  SELECT @new_num + (ROW_NUMBER() OVER (ORDER BY t.feed_detail_data_id ASC)), t.feed_data_id, t.feed_detail_data_id, t.description, @max_transid        
  FROM @tbl_feed_error_gbl t --WHERE NOT EXISTS(SELECT NULL FROM feed_error WHERE feed_data_id = t.feed_data_id AND feed_detail_data_id = t.feed_detail_data_id)        
        
  -- Update the new_num table with the number of feed_error records inserted.        
  SET @row_count = @@ROWCOUNT        
  IF (@row_count > 0)        
  BEGIN        
   EXEC dbo.get_new_num_NOI 'feed_error_oid', 0, @row_count        
  END        
 END        
        
 FETCH NEXT FROM c_feeds INTO @feed_data_id        
END --END of WHILE @@FETCH_STATUS = 0 (of cursor)        
        
CLOSE c_feeds         
DEALLOCATE c_feeds        
        
SELECT * from @pm_aggregated_records_gbl_tmp; 
GO
GRANT EXECUTE ON  [dbo].[usp_pm_verify_refdata_and_aggregate_sales] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_pm_verify_refdata_and_aggregate_sales', NULL, NULL
GO
