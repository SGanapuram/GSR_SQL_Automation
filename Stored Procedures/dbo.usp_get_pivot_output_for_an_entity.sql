SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_pivot_output_for_an_entity]
(
   @entity_name        varchar(40),
   @group_by_columns   varchar(200),
   @order_by_columns   varchar(200),
   @debugon            bit = 0
)
as
set nocount on
declare @column_list   varchar(2000),
        @sql           varchar(max),
        @entity_id     int,
        @smsg          varchar(800),
        @tempstr       varchar(120),
        @dberrmsg      varchar(max)

   create table #tags
   (
      tag_name       varchar(40) primary key
   )

   set @entity_id = (select oid 
                     from dbo.icts_entity_name 
                     where entity_name = @entity_name)
   if @entity_id is null
   begin
      set @smsg = '=> The ''' + @entity_name + ''' is an invalid entity!'
      raiserror(@smsg, 0, 1) with nowait
      exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                        @occurred_at = 'SP: usp_get_pivot_output_for_an_entity', 
                                        @problem_desc = @smsg,                                            
                                        @dberror_msg = 'N/A',
                                        @sql_stmt = 'N/A',
                                        @debugon = @debugon                                                                                                    
      goto endofsp
   end
   
   -- Get all the tags owned by the entity
   begin try
     insert into #tags
     select entity_tag_name
     from dbo.entity_tag_definition with (nolock)
     where entity_id = @entity_id and
           tag_status = 'A'
   end try
   begin catch
     set @smsg = 'Failed to fetch tag names and save them into the #tags table'  
     set @tempstr = '=> ' + @smsg + ' due to the error:'
     RAISERROR(@tempstr, 0, 1) WITH NOWAIT
     set @dberrmsg = ERROR_MESSAGE()                                                
     set @tempstr = '==> ERROR: ' + @dberrmsg                                                  
     RAISERROR(@tempstr, 0, 1) WITH NOWAIT
     exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                       @occurred_at = 'SP: usp_get_pivot_output_for_an_entity', 
                                       @problem_desc = @smsg,                                           
                                       @dberror_msg = @dberrmsg,
                                       @sql_stmt = 'insert into #tags select entity_tag_name from dbo.entity_tag_definition ..',
                                       @debugon = @debugon                                                                                                    
     goto endofsp
   end catch
               
   set @column_list = (select distinct stuff((select distinct top 100 percent '],[' + tag_name 
                       from #tags as t 
                         for xml path('')), 1, 2, '') + ']'
                    from #tags as t)

  -- ----------------------------------------------------------------------------------------------
   -- Build a query which will produce a PIVOT data whose columns consist of
   --   @group_by_columns, <column for tag #1>, <column for the tag #2>, .., <column for tag #n>
   --
   --   Here, @group_by_columns can be something like 'port_num' if the entity is 'Portfolio'; 
   --    'trade_num, order_num, item_num' if the entity is 'TradeItem'
   -- ----------------------------------------------------------------------------------------------
   set @sql = 'select * from (select ' + @group_by_columns + ',
         etd.entity_tag_name, 
         et.target_key1
      from dbo.entity_tag et with (nolock)
              INNER JOIN dbo.entity_tag_definition etd with (nolock)
                 ON et.entity_tag_id = etd.oid
      where entity_id = ' + cast(@entity_id as varchar) + ') as s
       PIVOT
       (
          max(target_key1)
          for entity_tag_name in (' + @column_list + ')
       ) as p
       order by ' + @order_by_columns + ';'

   begin try
     exec(@sql)
   end try
   begin catch
     set @smsg = 'Failed to execute query to produce a PIVOT output'  
     set @tempstr = '=> ' + @smsg + ' due to the error:'
     RAISERROR(@tempstr, 0, 1) WITH NOWAIT
     set @dberrmsg = ERROR_MESSAGE()                                                
     set @tempstr = '==> ERROR: ' + @dberrmsg                                                  
     RAISERROR(@tempstr, 0, 1) WITH NOWAIT
     set @tempstr = substring(@sql, 1, 60) + ' ..'                                                
     exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                       @occurred_at = 'SP: usp_get_pivot_output_for_an_entity', 
                                       @problem_desc = @smsg,                                           
                                       @dberror_msg = @dberrmsg,
                                       @sql_stmt = @tempstr,
                                       @debugon = @debugon                                                                                                    
     goto endofsp
   end catch    
   
endofsp:
drop table #tags
GO
GRANT EXECUTE ON  [dbo].[usp_get_pivot_output_for_an_entity] TO [next_usr]
GO
