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
DECLARE @max_transid          bigint        
DECLARE @feed_data_id         int        
DECLARE @tbl_comp_splc_codes  table (company_code char(3), splc_code char(9))        
DECLARE @tbl_feed_details     table (feed_data_id int, feed_detail_data_id int)         
DECLARE @tbl_feed_error       table (feed_data_id int, feed_detail_data_id int, description VARCHAR(800))         
DECLARE @tbl_feed_error_gbl   table (feed_data_id int, feed_detail_data_id int, description VARCHAR(800))         
DECLARE @tbl_feeds            table (feed_data_id int)        
        
DECLARE @pm_aggregated_records_tmp AS TABLE 
(
   feed_data_id          int,        
   company_code          nvarchar(128),        
   mapped_acct_num       int,        
   start_load_date       varchar(128),        
   end_load_date         varchar(128),        
   splc_code             varchar(128),        
   mapped_loc_code       varchar(128),        
   bol_number            varchar(128),        
   comp_prod_code        varchar(128),        
   mapped_cmdty_code     varchar(128),        
   terminal_ctrl_num     varchar(128),        
   grossQty              float NULL,      
   qty                   float NULL,      
   uom                   varchar(128),        
   WASP                  float         
) 
       
DECLARE @pm_aggregated_records_gbl_tmp AS TABLE 
(
   feed_data_id          int,        
   company_code          nvarchar(128),        
   mapped_acct_num       int,        
   start_load_date       varchar(128),        
   end_load_date         varchar(128),        
   splc_code             varchar(128),        
   mapped_loc_code       varchar(128),        
   bol_number            varchar(128),        
   comp_prod_code        varchar(128),        
   mapped_cmdty_code     varchar(128),        
   terminal_ctrl_num     varchar(128),      
   grossQty              float NULL,      
   qty                   float NULL,      
   uom                   varchar(128),        
   WASP                  float        
)  
      
DECLARE @does_grand_total_match  int         
DECLARE @new_num                 int        
DECLARE @row_count               int 
DECLARE @splc_company_code_pair  varchar(640)        
              
   if (@process_failed_recs IS NULL)        
      set @process_failed_recs = 0        
       
   if (@start_date IS NOT NULL and 
       @end_date IS NOT NULL)        
   begin        
      if (@end_date < @start_date)        
      begin        
         print '@end_date should be greater than or equal to @start_date'        
         return        
      end         
      if (@end_date = @start_date)        
         set @end_date = DATEADD(d, 1, @start_date);        
        
      if (@debug = 1)        
      begin        
         print '@start_date = ' +  CASE WHEN @start_date IS NULL THEN 'null' 
		                                ELSE CAST(@start_date as nvarchar(40)) 
								   END        
         print '@end_date = ' + CASE WHEN @end_date IS NULL THEN 'null' 
		                             ELSE CAST(@end_date as nvarchar(40)) 
                                END        
      end        
   end        
        
   if (@start_date IS NOT NULL and 
       @end_date IS NOT NULL)        
   begin        
      insert into @tbl_feeds (feed_data_id)        
        select fd.oid        
        from dbo.feed_data fd             
               inner join dbo.feed_definition fdn          
			      on fd.feed_id = fdn.oid        
               inner join dbo.icts_transaction it           
			      on it.trans_id = fd.trans_id                
        where fdn.feed_name = 'PETROMAN_INTERFACE' and 
		      (it.tran_date >= @start_date and 
			   it.tran_date <= @end_date)         
   end               
   else if (@p_feed_data_id IS NOT NULL) -- Process a particular feed        
   begin        
      insert into @tbl_feeds (feed_data_id) 
	     values(@p_feed_data_id)          
   end                
   else if (@process_failed_recs = 1) -- Process all error records        
   begin        
      insert into @tbl_feeds (feed_data_id)        
        select distinct fd.oid        
        from dbo.feed_data fd             
                inner join dbo.feed_definition fdn          
			       on fd.feed_id = fdn.oid        
                inner join dbo.feed_error fe           
			       on fe.feed_data_id = fd.oid                
        where fdn.feed_name = 'PETROMAN_INTERFACE'        
   end                 
   else --Process all the pending records        
   begin        
      insert into @tbl_feeds (feed_data_id)        
        select fd.oid        
        from dbo.feed_data fd             
                inner join dbo.feed_definition fdn          
				   on fd.feed_id = fdn.oid           
        where fdn.feed_name = 'PETROMAN_INTERFACE' AND 
		      fd.status IN ('PENDING', 'PROC_SCHLD', 'PROCESSING')        
   end        
        
   if (@debug = 1)        
      select '@tbl_feeds contents', * 
	  from @tbl_feeds;        
        
   declare c_feeds CURSOR READ_ONLY FORWARD_ONLY LOCAL FOR         
      select feed_data_id 
	  from @tbl_feeds 
	  order by 1;        
        
   open c_feeds 
   fetch next from c_feeds into @feed_data_id              
   while @@FETCH_STATUS = 0        
   begin               
      delete @tbl_feed_error_gbl;        
      delete @tbl_feed_details;
      set @does_grand_total_match = 1
        
      if (@process_failed_recs = 1) -- Here we have to pick error records(like suspended/val_failed/failed) from feed_error table.         
      begin        
         insert into @tbl_feed_details
		      (feed_data_id, feed_detail_data_id)        
           select fdd.feed_data_id, fdd.oid 
		   from dbo.feed_detail_data fdd         
           where feed_data_id = @feed_data_id and 
		         status in ('FAILED', 'SUSPENDED', 'VAL_FAILED')                 
      end        
      else        
      begin             
         insert into @tbl_feed_details
		      (feed_data_id, feed_detail_data_id)        
           select feed_data_id, oid 
		   from dbo.feed_detail_data 
		   where feed_data_id = @feed_data_id and 
		         status in ('PENDING', 'PROC_SCHLD', 'PROCESSING')         
      end        
        
      if (@debug = 1)        
      begin        
         select '@tbl_feed_details' AS before_verification_of_refdata, * 
		 from @tbl_feed_details;        
      end        
   
      --------------------------------------------------------------------------        
      ------------------- Verification of totalling of quantities: Begin--------  
      --------------------------------------------------------------------------   
      if ((select number_of_rows 
	       from feed_data 
		   where oid = @feed_data_id) = (select COUNT(*) 
		                                 from @tbl_feed_details))  
      begin  
         -- Match the sum of subtotals with the grand total        
         select @does_grand_total_match = 
		       case when sum(cast(type4.gross_qty_sub_total AS float)) = CAST(type5.grand_tot_gross_qty AS float) and         
                         sum(cast(type4.net_qty_sub_total AS float))   = CAST(type5.grand_tot_net_qty AS float)        
                       then 1        
                    else 0        
               end         
         from dbo.pm_type_4_record type4, 
		      dbo.pm_type_5_record type5         
         where type4.fdd_id in (select feed_detail_data_id 
		                        from @tbl_feed_details) and        
               type5.fdd_id in (select feed_detail_data_id 
			                    from @tbl_feed_details)         
         group by type5.grand_tot_gross_qty, type5.grand_tot_net_qty    
        
         if (@debug = 1)        
            print '@does_grand_total_match = ' + cast(@does_grand_total_match as nvarchar)        
             
         if (@does_grand_total_match = 0)        
         begin        
            --If the grand total does not match, all the records have to put in error.        
            delete @tbl_feed_error        
            insert into @tbl_feed_error         
              select t.feed_data_id, 
			         t.feed_detail_data_id, 
			         'Inconsistent Data: Grand total does not match with the sum of subtotals'        
              from @tbl_feed_details t        
          
            -- Update @tbl_feed_error_gbl table if some other error has been registered 
			-- with the given feed_data_id and feed_detail_data_id        
            update fe         
            set fe.description = fe.description + ', ' + tfe.description        
            from @tbl_feed_error_gbl fe         
                    inner join @tbl_feed_error tfe 
					   on fe.feed_data_id = tfe.feed_data_id and 
					      fe.feed_detail_data_id = tfe.feed_detail_data_id        
            
            -- Insert into @tbl_feed_error_gbl table new errors that have not been present before        
            insert into @tbl_feed_error_gbl
			     (feed_data_id, feed_detail_data_id, description)        
              select t.feed_data_id, t.feed_detail_data_id, t.description        
              from @tbl_feed_error t 
			  where not exists (select 1 
			                    from @tbl_feed_error_gbl 
								where feed_data_id = t.feed_data_id and 
								      feed_detail_data_id = t.feed_detail_data_id)                    
         end  
     
         --Check for subtotals.   
         begin  
            set @splc_company_code_pair = ''

            -- Collect the type-4 records whose subtotals do not match with the sum of quantites of type-b records        
            insert into @tbl_comp_splc_codes 
			     (company_code, splc_code)          
              select t.company_code, t.splc_code 
			  from (select distinct 
                       b.company_code,         
                       b.splc_code,         
                       sum(cast(b.gross_qty as float) * (case when b.billed_credit_sign = '-' then -1 
					                                          else 1 
                                                         end)) as type_b_gross_qty_subtotal,         
                       cast(type4.gross_qty_sub_total as float) as type_4_gross_qty_subtotal        
                    from dbo.pm_type_b_record b          
                            inner join dbo.pm_type_4_record type4 
					           on b.company_code = type4.company_code and         
                                  b.splc_code = type4.splc_code            
                    where b.fdd_id in (select feed_detail_data_id 
			                           from @tbl_feed_details) and        
                          type4.fdd_id in (select feed_detail_data_id 
					                       from @tbl_feed_details)         
                    group by b.company_code, b.splc_code, type4.gross_qty_sub_total) t         
			  where t.type_b_gross_qty_subtotal != t.type_4_gross_qty_subtotal        

            select @splc_company_code_pair = @splc_company_code_pair + '(' + company_code + ',' + splc_code + '),'
            from @tbl_comp_splc_codes 
        
            if (@debug = 1)        
            begin        
               select '@tbl_comp_splc_codes ' AS unmatched_type_4_subtotals, * 
               from @tbl_comp_splc_codes
               select '@splc_company_code_pair = ' + @splc_company_code_pair;
            end
        
            delete @tbl_feed_error
            if (len(@splc_company_code_pair) > 0)
            begin
               set @splc_company_code_pair = substring(@splc_company_code_pair, 1, len(@splc_company_code_pair) - 1)    
               -- Insert into @tbl_feed_error any mismatch of subtotals with the sum of quantities                            
               insert into @tbl_feed_error         
                 select tfd.feed_data_id, 
				        tfd.feed_detail_data_id,  
                        'Inconsistent Data: For the following Company code & SPLC code combinations - '   
                             + @splc_company_code_pair 
                             + ' - subtotals of type-4 records do not match with the sums of quantities of type-B records'  
                 from @tbl_feed_details tfd
            end
			  
            -- Update @tbl_feed_error_gbl table if some other error has been registered 
			-- with the given feed_data_id and feed_detail_data_id        
            update fe         
            set fe.description = fe.description + ', ' + tfe.description        
            from @tbl_feed_error_gbl fe         
                     inner join @tbl_feed_error tfe 
					    on fe.feed_data_id = tfe.feed_data_id and 
						   fe.feed_detail_data_id = tfe.feed_detail_data_id        
            
            -- Insert into @tbl_feed_error_gbl table new errors that have not been present before        
            insert into @tbl_feed_error_gbl(feed_data_id, feed_detail_data_id, description)        
              select t.feed_data_id, t.feed_detail_data_id, t.description        
              from @tbl_feed_error t 
              where not exists (select 1 
				                from @tbl_feed_error_gbl 
								where feed_data_id = t.feed_data_id and 
								      feed_detail_data_id = t.feed_detail_data_id)        
              
            if (@debug = 1)        
               select '@tbl_feed_error_gbl' as after_matching_subtotals, * 
               from @tbl_feed_error_gbl        
         end /* Check for subtotals. */   
      end
	  
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
      delete @tbl_feed_error        
      insert into @tbl_feed_error         
        select t.feed_data_id, 
		       t.feed_detail_data_id, 
			   '(As of ' + CAST(getdate() as nvarchar) + ') Company Code: ''' + 
			        LTRIM(RTRIM(t.company_code)) + ''' has not been mapped to an account in symphony'        
        from (select tfd.feed_data_id, 
		             tfd.feed_detail_data_id, 
					 a.company_code         
              from dbo.pm_type_a_record a         
                      inner join @tbl_feed_details tfd 
					     on tfd.feed_detail_data_id = a.fdd_id                
              union                
              select tfd.feed_data_id, tfd.feed_detail_data_id, b.company_code         
              from dbo.pm_type_b_record b         
                      inner join @tbl_feed_details tfd 
				         ON tfd.feed_detail_data_id = b.fdd_id) t         
                left outer join dbo.ext_refdata_mapping em 
				   on t.company_code = em.external_key1 and 
				      em.alias_source_code = 'PETROMAN'        
                left outer join dbo.icts_entity_name ie 
				   on ie.oid = em.entity_id        
                left outer join dbo.ext_ref_keys er   
				   on em.entity_key1_value_id = er.oid        
                left outer join dbo.account ac    
				   on ac.acct_num = er.int_key_value        
        where ac.acct_num IS NULL         
  
      -- Update @tbl_feed_error_gbl table if some other error has been 
	  -- registered with the given feed_data_id and feed_detail_data_id        
      update fe         
      set fe.description = fe.description + ', ' + tfe.description        
      from @tbl_feed_error_gbl fe         
              inner join @tbl_feed_error tfe 
			     on fe.feed_data_id = tfe.feed_data_id and 
				    fe.feed_detail_data_id = tfe.feed_detail_data_id   
   
      -- Insert into @tbl_feed_error_gbl table new errors that have not been present before        
      insert into @tbl_feed_error_gbl
	       (feed_data_id, feed_detail_data_id, description)        
        select t.feed_data_id, 
		       t.feed_detail_data_id, 
			   t.description        
        from @tbl_feed_error t 
		where not exists (select 1 
		                  from @tbl_feed_error_gbl 
		                  where feed_data_id = t.feed_data_id and 
		                        feed_detail_data_id = t.feed_detail_data_id)        
        
      if (@debug = 1)        
          select '@tbl_feed_error_gbl' as after_company_code_verification, * 
		  from @tbl_feed_error_gbl        
 
      ----------------------------------             
      -- Verify company_code:End        
      ----------------------------------        
        
      ----------------------------------        
      -- Verify splc_code:Begin        
      ----------------------------------                 
      delete @tbl_feed_error        
      insert into @tbl_feed_error         
        select t.feed_data_id, 
		       t.feed_detail_data_id, 
			   '(As of ' + CAST(getdate() as nvarchar) + ') SPLC Code: ''' + 
			        LTRIM(RTRIM(t.splc_code)) + ''' has not been mapped to a location in symphony'        
        from (select tfd.feed_data_id, 
		             tfd.feed_detail_data_id, 
					 a.splc_code         
              from dbo.pm_type_a_record a         
                      inner join @tbl_feed_details tfd 
					     on tfd.feed_detail_data_id = a.fdd_id                
              union              
              select tfd.feed_data_id, 
			         tfd.feed_detail_data_id, 
					 b.splc_code         
              from dbo.pm_type_b_record b         
                      inner join @tbl_feed_details tfd 
					     on tfd.feed_detail_data_id = b.fdd_id) t         
               left outer join dbo.ext_refdata_mapping em 
                  on t.splc_code = em.external_key1 AND 
                     em.alias_source_code = 'PETROMAN'        
               left outer join dbo.icts_entity_name ie 
                  on ie.oid = em.entity_id        
               left outer join dbo.ext_ref_keys er   
			      on em.entity_key1_value_id = er.oid        
               left outer join dbo.location lo    
			      on lo.loc_code = er.str_key_value        
        where lo.loc_num IS NULL         
        
      -- Update @tbl_feed_error_gbl table if some other error has been 
      -- registered with the given feed_data_id and feed_detail_data_id        
      update fe         
      set fe.description = fe.description + ', ' + tfe.description        
      from @tbl_feed_error_gbl fe         
              inner join @tbl_feed_error tfe 
				 on fe.feed_data_id = tfe.feed_data_id and 
				    fe.feed_detail_data_id = tfe.feed_detail_data_id        
        
      -- Insert into @tbl_feed_error_gbl table new errors that have not been present before        
      insert into @tbl_feed_error_gbl
		   (feed_data_id, feed_detail_data_id, description)        
      select t.feed_data_id, 
		     t.feed_detail_data_id, 
             t.description        
      from @tbl_feed_error t 
      where not exists (select 1 
		                from @tbl_feed_error_gbl 
						where feed_data_id = t.feed_data_id and 
							  feed_detail_data_id = t.feed_detail_data_id)        
        
      if (@debug = 1)        
         select '@tbl_feed_error_gbl' AS after_splc_code_verification, * 
		 from @tbl_feed_error_gbl        
       
      ----------------------------------        
      -- Verify splc_code:End        
      ----------------------------------        
        
      ----------------------------------        
      --Verify comp_prod_code:Begin        
      ----------------------------------               
      delete @tbl_feed_error        
      insert into @tbl_feed_error         
        select t.feed_data_id, 
		       t.feed_detail_data_id, 
               '(As of ' + CAST(getdate() as nvarchar) + ') Component Product Code: ''' + 
				    LTRIM(RTRIM(t.comp_prod_code)) + ''' has not been mapped to a commodity in symphony'        
        from (select tfd.feed_data_id, 
		             tfd.feed_detail_data_id, 
					 b.comp_prod_code         
              from dbo.pm_type_b_record b         
                      inner join @tbl_feed_details tfd 
					     on tfd.feed_detail_data_id = b.fdd_id) t         
               left outer join dbo.ext_refdata_mapping em 
			      on t.comp_prod_code = em.external_key1 and 
				     em.alias_source_code = 'PETROMAN'        
               left outer join dbo.icts_entity_name ie 
			      on ie.oid = em.entity_id         
               left outer join dbo.ext_ref_keys er   
			      on em.entity_key1_value_id = er.oid        
               left outer join dbo.commodity co   
			      on co.cmdty_code = er.str_key_value        
        where co.cmdty_code IS NULL         
        
      -- Update @tbl_feed_error_gbl table if some other error has been 
      -- registered with the given feed_data_id and feed_detail_data_id        
      update fe         
      set fe.description = fe.description + ', ' + tfe.description        
      from @tbl_feed_error_gbl fe         
              inner join @tbl_feed_error tfe 
				 on fe.feed_data_id = tfe.feed_data_id and 
				    fe.feed_detail_data_id = tfe.feed_detail_data_id        
        
      -- Insert into @tbl_feed_error_gbl table new errors that have not been present before        
      insert into @tbl_feed_error_gbl(feed_data_id, feed_detail_data_id, description)        
        select t.feed_data_id, 
               t.feed_detail_data_id, 
               t.description        
        from @tbl_feed_error t 
        where not exists (select 1 
		                  from @tbl_feed_error_gbl 
                          where feed_data_id = t.feed_data_id and 
                                feed_detail_data_id = t.feed_detail_data_id)        
        
      if (@debug = 1)       
         select '@tbl_feed_error_gbl' as after_product_code_verification, * 
         from @tbl_feed_error_gbl        

      ----------------------------------        
      --Verify comp_prod_code:End        
      ----------------------------------        
         
      --------------------------------------------------------------------------        
      ------------------- Verification of Reference Data: End-------------------        
      --------------------------------------------------------------------------        
      begin --Steps after validation of input data  
         -- Update all errorneous feed detail data records with val_failed status.         
         -- The query below updates typeA, typeB and type4(whose values did not match 
		 -- with the subtotals of typeB) records which are in error.        
        
         BEGIN TRAN        
         exec dbo.gen_new_transaction_NOI 'usp_pm_verify_refdata_and_...', 'U' 
         set @max_transid = dbo.udf_current_sequence_value('trans_id')
         COMMIT TRAN       
          
         print '@max_transid = ' + case when @max_transid IS NULL then 'NULL' 
		                                else cast(@max_transid as nvarchar) 
                                   end        
         update fdd         
         set fdd.status = 'VAL_FAILED',        
             fdd.trans_id = @max_transid    
         from dbo.feed_detail_data fdd        
                 inner join @tbl_feed_details tfd 
				    on tfd.feed_detail_data_id = fdd.oid        
                 inner join @tbl_feed_error_gbl fe
				    on fe.feed_detail_data_id = tfd.feed_detail_data_id        
                 
         -- Now delete from @tbl_feed_details the feed_detail_ids that are in error        
         if (@debug = 1)        
            select '@tbl_feed_details' as records_in_error, * 
			from @tbl_feed_details t 
			where exists (select 1 
			              from @tbl_feed_error_gbl f 
                          where t.feed_data_id = f.feed_data_id and 
                                t.feed_detail_data_id = f.feed_detail_data_id);        
          
         delete @tbl_feed_details         
         from @tbl_feed_details t         
                 inner join @tbl_feed_error_gbl f 
				    on t.feed_data_id = f.feed_data_id and 
					   t.feed_detail_data_id = f.feed_detail_data_id;        
          
         if (@debug = 1)        
            select '@tbl_feed_details' as after_removing_error_records, * 
			from @tbl_feed_details t;        
        
         --It might be the case that during reprocessing, due to an error in component product code,         
         --all that we have are typeB records. For the next SQL statement that does 
		 -- aggregation to work, we need corresponding type A records as well.        
         --Hence add the type A records that corresponds to type B records.        
        
         if (not exists (select 1 
		                 from @tbl_feed_details 
						         inner join dbo.pm_type_a_record 
								    on fdd_id = feed_detail_data_id))        
         begin        
            insert into @tbl_feed_details 
			     (feed_data_id, feed_detail_data_id)        
              select distinct 
				 @feed_data_id, 
				 typeA.fdd_id         
              from dbo.pm_type_a_record typeA         
                      inner join dbo.pm_type_b_record typeB 
					     on typeA.bol_number = typeB.bol_number and 
						    typeA.splc_code = typeB.splc_code and 
                            typeA.company_code = typeB.company_code        
                      inner join @tbl_feed_details tfd  
                         on tfd.feed_detail_data_id = typeB.fdd_id  
                      inner join dbo.feed_detail_data fdd 
                         on fdd.oid = typeA.fdd_id 
              where fdd.feed_data_id = @feed_data_id        
        
            if (@debug = 1)               
               select '@tbl_feed_details' as after_adding_typeA_records, * 
			   from @tbl_feed_details t;               
         end        
        
         -- Aggregate type-b records excluding those records whose sum of quantities do not match         
         -- with the subtotals of type-4 records, collected into @tbl_comp_splc_codes in the previous step.         
         insert into @pm_aggregated_records_tmp        
           select           
              tfd.feed_data_id,        
              rtrim(cast(typeA.company_code as varchar)) as company_code, -- Casting chars to varchar, because to a bug in hibernate, 
				                                                          -- which returns only the first character of char(N) datatypes        
              ac.acct_num as mapped_acct_num,        
              cast(typeA.start_load_date as varchar) as start_load_date,        
              cast(typeA.end_load_date as varchar) as end_load_date,        
              cast(typeA.splc_code as varchar) as splc_code,        
              rtrim(cast(lo.loc_code as varchar)) as mapped_loc_code,   
              cast(typeA.bol_number as varchar) as bol_number,        
              rtrim(cast(typeB.comp_prod_code as varchar)) as comp_prod_code,        
              rtrim(cast(co.cmdty_code as varchar)) as mapped_cmdty_code,        
              cast(typeB.terminal_ctrl_num as varchar) as terminal_ctrl_num,        
              sum(cast(typeB.gross_qty as float) *       
                      (case when typeB.gross_credit_sign = '-'         
                               then -1 
							else 1 
                       end)) / 100 as grossQty,        
              sum(cast(typeB.billed_qty as float) *       
                      (case when typeB.billed_credit_sign = '-'         
                               then -1 
							else 1 
                       end)) / 100 as qty,       
                cast(typeB.measurement_type as varchar) AS uom,         
                sum((cast(typeB.billed_qty as float) / 100) * (Cast(typeB.unit_price as float)/100000)) /        
                     sum((cast(typeB.billed_qty as float) / 100)) as WASP -- Weighted avg is the same regardless of 
	                                                                      -- bill_credit_sign and hence bill_credit_sign 
													                      -- is ignored in calculations      
           from (select distinct         
                    company_code,        
                    splc_code,        
                    terminal_ctrl_num,        
                    bol_number,        
                    start_load_date,        
                    start_load_time,        
                    end_load_date,        
                    end_load_time,        
                    consignee_num,        
                    dest_state_code,        
                    dest_county_code,        
                    dest_city_code,        
                    carrier_code,        
                    carrier_fein,        
                    vehicle_num,        
                    vehicle_type,        
                    third_party,        
                    po_order_num,        
                    release_num,        
                    split_load_flag,        
                    time_zone,        
                    shipper_info        
                 from dbo.pm_type_a_record 
				 where fdd_id in (select feed_detail_data_id 
				                  from @tbl_feed_details)) typeA        
                inner join dbo.pm_type_b_record typeB      
				   on typeA.bol_number = typeB.bol_number and 
				      typeA.splc_code = typeB.splc_code and 
					  typeA.company_code = typeB.company_code        
                inner join dbo.ext_refdata_mapping em1   
				   on typeB.company_code = em1.external_key1 and 
				      em1.alias_source_code = 'PETROMAN'        
                inner join dbo.icts_entity_name ie1   
				   on ie1.oid = em1.entity_id and 
				      ie1.entity_name = 'Account'        
                inner join dbo.ext_ref_keys er1    
				   on em1.entity_key1_value_id = er1.oid        
                inner join dbo.account ac     
				   on ac.acct_num = er1.int_key_value                       
                inner join dbo.ext_refdata_mapping em2   
				   on typeB.splc_code = em2.external_key1 and 
				      em2.alias_source_code = 'PETROMAN'         
                inner join dbo.icts_entity_name ie2   
				   on ie2.oid = em2.entity_id and 
				      ie2.entity_name = 'Location'        
                inner join dbo.ext_ref_keys er2    
				   on em2.entity_key1_value_id = er2.oid        
                inner join dbo.location lo     
				   on lo.loc_code = er2.str_key_value                         
                inner join dbo.ext_refdata_mapping em3   
				   on typeB.comp_prod_code = em3.external_key1 and 
				      em3.alias_source_code = 'PETROMAN'         
                inner join dbo.icts_entity_name ie3   
				   on ie3.oid = em3.entity_id and 
				      ie3.entity_name = 'Commodity'         
                inner join dbo.ext_ref_keys er3    
				   on em3.entity_key1_value_id = er3.oid        
                inner join dbo.commodity co     
				   on co.cmdty_code = er3.str_key_value                
                inner join @tbl_feed_details tfd   
				   on tfd.feed_detail_data_id = typeB.fdd_id                   
           where @does_grand_total_match = 1 -- This is necessary. If grand total doesn't match, 
			                                 -- we still need to return a record set on the java side                    
           group by typeA.company_code,        
                    typeA.start_load_date,        
                    typeA.end_load_date,        
                    typeA.splc_code,        
                    typeA.bol_number,        
                    typeB.comp_prod_code,        
                    ac.acct_num,        
                    lo.loc_code,        
                    co.cmdty_code,        
                    typeB.measurement_type,           
                    typeB.terminal_ctrl_num,           
                    tfd.feed_data_id                 
           order by typeA.company_code,        
                    typeA.start_load_date ASC,         
                    typeA.splc_code,        
                    typeB.comp_prod_code;        
               
         insert into @pm_aggregated_records_gbl_tmp        
           select * 
           from @pm_aggregated_records_tmp;        
        
         delete from @pm_aggregated_records_tmp;        
        
         ------------------------------------------------------------------------------        
         --Update the status to processing of those records that have been aggregated--        
         ------------------------------------------------------------------------------        
         begin              
            begin tran        
            exec dbo.gen_new_transaction_NOI 'usp_pm_verify_refdata_and_...', 'U'        
            set @max_transid = dbo.udf_current_sequence_value('trans_id')
            commit tran       
        
            --Change the status of feed_detail and feed_data        
            update fdd         
            set fdd.status  ='PROCESSING',        
                fdd.trans_id = @max_transid        
            from dbo.feed_detail_data fdd         
                    inner join @tbl_feed_details tfd 
					   on tfd.feed_data_id = fdd.feed_data_id and 
						  tfd.feed_detail_data_id = fdd.oid        
        
            update dbo.feed_data 
			set status = 'PROCESSING',
			    trans_id = @max_transid 
            where oid = @feed_data_id  
         end        
      end -- end of 'Steps after validation of input data'  
        
      -------------------------------------------------------------------------------------------------        
      --Update the feed_error table from @tbl_feed_error_gbl based on the errors seen in this context--        
      -------------------------------------------------------------------------------------------------        
         
      begin        
         BEGIN TRAN        
         exec dbo.gen_new_transaction_NOI 'usp_pm_verify_refdata_and_...', 'U'        
         set @max_transid = dbo.udf_current_sequence_value('trans_id')
         COMMIT TRAN        
        
         -- Insert into feed_error table from the temporary error table
         set @new_num = dbo.udf_current_sequence_value('feed_error_oid')		   
        
         insert into dbo.feed_error
		      (oid, feed_data_id, feed_detail_data_id, description, trans_id)        
           select @new_num + (ROW_NUMBER() OVER (ORDER BY t.feed_detail_data_id ASC)), 
			      t.feed_data_id, 
                  t.feed_detail_data_id, 
                  t.description, 
                  @max_transid        
           from @tbl_feed_error_gbl t        
         set @row_count = @@rowcount        
         if (@row_count > 0)        
            exec dbo.get_new_num_NOI 'feed_error_oid', 0, @row_count        
      end 

      fetch next from c_feeds into @feed_data_id		        
   end --END of WHILE @@FETCH_STATUS = 0 (of cursor)              
   CLOSE c_feeds         
   DEALLOCATE c_feeds        
        
   select * 
   from @pm_aggregated_records_gbl_tmp; 
GO
GRANT EXECUTE ON  [dbo].[usp_pm_verify_refdata_and_aggregate_sales] TO [next_usr]
GO
