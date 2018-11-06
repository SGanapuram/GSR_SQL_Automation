SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_get_TRADE_ITEM_tags]
(
   @debugon          bit = 0
)                             
as
set nocount on
declare @status                  int,
        @smsg                    varchar(800),
        @rows_affected           int,
        @time_started            varchar(20),
        @time_finished           varchar(20),
        @sql                     varchar(max),
        @oid                     int,
        @last_oid                int,
        @colname                 sysname,
        @tag_name                varchar(40),
        @entity_name             varchar(40),
        @tempstr                 varchar(255),
        @ref_insp_name           varchar(255),
        @tag_column_list         varchar(MAX),
        @dberrmsg                varchar(max)

   set @status = 0   
   create table #tagnames
   (
      oid             int IDENTITY primary key,
      tag_name        varchar(40) not null,
      ref_insp_name   varchar(255) null
   )
   
   begin try
     insert into #tagnames
          (tag_name, ref_insp_name)
       select rtrim(def.entity_tag_name), insp.entity_tag_attr_value
       from dbo.entity_tag_definition def WITH (NOLOCK)
               LEFT OUTER JOIN dbo.entity_tag_insp_attr insp WITH (NOLOCK)
                  ON def.oid = insp.entity_tag_id and
                     insp.entity_tag_attr_name = 'RefInspName'
       where def.entity_id = (select oid
                              from dbo.icts_entity_name WITH (NOLOCK)
                              where entity_name = 'TradeItem') and
             def.tag_status = 'A'          
       order by def.entity_tag_name
   end try
   begin catch
     set @smsg = 'Failed to fetch tag data and save them into the #tagnames table'  
     set @tempstr = '=> ' + @smsg + ' due to the error:'
     RAISERROR(@tempstr, 0, 1) WITH NOWAIT
     set @dberrmsg = ERROR_MESSAGE()                                                
     set @tempstr = '==> ERROR: ' + @dberrmsg                                                  
     RAISERROR(@tempstr, 0, 1) WITH NOWAIT
     exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                       @occurred_at = 'SP: usp_get_TRADE_ITEM_tags', 
                                       @problem_desc = @smsg,                                           
                                       @dberror_msg = @dberrmsg,
                                       @sql_stmt = 'insert into #tagnames (tag_name, ref_insp_name) select rtrim(def.entity_tag_name), ..',
                                       @debugon = @debugon                                                                                                    
      goto endofsp
   end catch
   
   set @sql = 'alter table #xx101_titags add '
   set @tag_column_list = ''
   select @last_oid = max(oid)
   from #tagnames

   select @oid = min(oid)
   from #tagnames
   
   while @oid is not null
   begin
      select @tag_name = tag_name + '(TradeItemTAG)'
      from #tagnames
      where oid = @oid
      
      set @sql = @sql + '[' + @tag_name + ']  varchar(40) NULL'
      if len(@tag_column_list) > 0
         set @tag_column_list = @tag_column_list + ', '
      set @tag_column_list = @tag_column_list + '[' + @tag_name + ']'
      if @oid < @last_oid
         set @sql = @sql + ','
      else
         break

      select @oid = min(oid)
      from #tagnames
      where oid > @oid
   end         
         
   -- alter temp table add columns for TradeItem tags
   -- DEBUG: print '@sql = ''' + @sql + ''''
   begin try
     exec(@sql)
   end try
   begin catch
     set @smsg = 'Failed to alter temp table ''#xx101_titags'''  
     set @tempstr = '=> ' + @smsg + ' due to the error:'
     RAISERROR(@tempstr, 0, 1) WITH NOWAIT
     set @dberrmsg = ERROR_MESSAGE()                                                
     set @tempstr = '==> ERROR: ' + @dberrmsg                                                  
     RAISERROR(@tempstr, 0, 1) WITH NOWAIT
     set @tempstr = substring(@sql, 1, 60) + ' ..'                                                
     exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                       @occurred_at = 'SP: usp_get_TRADE_ITEM_tags', 
                                       @problem_desc = @smsg,                                           
                                       @dberror_msg = @dberrmsg,
                                       @sql_stmt = @tempstr,
                                       @debugon = @debugon                                                                                                    
      goto endofsp
   end catch    

   insert into #tag_column_info
      values('TradeItem', @tag_column_list)
          
   set @tempstr = 'cast(key1 as int) as trade_num, cast(key2 as smallint) as order_num, cast(key3 as int) as item_num'
   begin try
     insert into #xx101_titags
        exec dbo.usp_get_pivot_output_for_an_entity 'TradeItem', 
                                                    @tempstr,
                                                    'trade_num, order_num, item_num'
   end try
   begin catch
     set @smsg = 'Failed to save data returned from the ''usp_get_pivot_output_for_an_entity'' procedure to the ''#xx101_titags'' table'  
     set @tempstr = '=> ' + @smsg + ' due to the error:'
     RAISERROR(@tempstr, 0, 1) WITH NOWAIT
     set @dberrmsg = ERROR_MESSAGE()                                                
     set @tempstr = '==> ERROR: ' + @dberrmsg                                                  
     RAISERROR(@tempstr, 0, 1) WITH NOWAIT
     exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                       @occurred_at = 'SP: usp_get_TRADE_ITEM_tags', 
                                       @problem_desc = @smsg,                                           
                                       @dberror_msg = @dberrmsg,
                                       @sql_stmt = 'insert into #xx101_titags exec dbo.usp_get_pivot_output_for_an_entity ..',
                                       @debugon = @debugon                                                                                                    
     goto endofsp
   end catch 

   if @debugon = 1
   begin
      select @ref_insp_name = min(ref_insp_name)
      from #tagnames
      where ref_insp_name is not null and
            ref_insp_name not in ('IctsUser', 'Account')
            
      while @ref_insp_name is not null
      begin
         set @smsg = 'This reference Inspector ''' + @ref_insp_name + ''' is not currently supported by this version of the ''usp_get_TRADE_ITEM_tags'' sp'
         set @tempstr = '=> Sorry! ' + @smsg
         RAISERROR(@tempstr, 0, 1) WITH NOWAIT
         exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                           @occurred_at = 'SP: usp_get_TRADE_ITEM_tags', 
                                           @problem_desc = @smsg,                                            
                                           @dberror_msg = 'N/A',
                                           @sql_stmt = 'N/A',
                                           @debugon = @debugon
         select @ref_insp_name = min(ref_insp_name)
         from #tagnames
         where ref_insp_name is not null and
               ref_insp_name not in ('IctsUser', 'Account') and
               ref_insp_name > @ref_insp_name
      end
   end

   select @oid = min(oid)
   from #tagnames
   where ref_insp_name is not null and
         ref_insp_name in ('IctsUser', 'Account')
      
   while @oid is not null
   begin
      select @ref_insp_name = ref_insp_name,
             @tag_name = tag_name + '(TradeItemTAG)'
      from #tagnames
      where oid = @oid
      
      if @ref_insp_name = 'IctsUser'
      begin
         -- update tag
         -- set <colname> = u.user_last_name + ', ' + u.user_first_name
         -- from #xx101_titags tag
         --         left outer join dbo.icts_user u
         --            on tag.<colname> = u.user_init
         set @sql = 'update tag set [' + @tag_name + '] = u.user_last_name + '', '' + u.user_first_name '
         set @sql = @sql + 'from #xx101_titags tag left outer join dbo.icts_user u '
         set @sql = @sql + 'on tag.[' + @tag_name + '] = u.user_init'
      end

      if @ref_insp_name = 'Account'
      begin
         -- update tag
         -- set <colname> = u.acct_short_name
         -- from #xx101_titags tag
         --         left outer join dbo.account u
         --            on tag.<colname> = cast(u.acct_num as varchar)
         set @sql = 'update tag set [' + @tag_name + '] = u.acct_short_name '
         set @sql = @sql + 'from #xx101_titags tag left outer join dbo.account u '
         set @sql = @sql + 'on tag.[' + @tag_name + '] = cast(u.acct_num as varchar)'
      end

      begin try
        exec(@sql)
      end try
      begin catch
        set @smsg = 'Failed to update the ''' + @tag_name + ''' column in the ''#xx101_titags'' table'  
        set @tempstr = '=> ' + @smsg + ' due to the error:' 
        RAISERROR(@tempstr, 0, 1) WITH NOWAIT
        set @dberrmsg = ERROR_MESSAGE()                                                
        set @tempstr = '==> ERROR: ' + @dberrmsg                                                  
        RAISERROR(@tempstr, 0, 1) WITH NOWAIT
        set @tempstr = substring(@sql, 1, 60) + ' ..'                                                
        exec dbo.usp_save_dashboard_error @report_name = 'PlCompReport',  
                                          @occurred_at = 'SP: usp_get_TRADE_ITEM_tags', 
                                          @problem_desc = @smsg,                                           
                                          @dberror_msg = @dberrmsg,
                                          @sql_stmt = @tempstr,
                                          @debugon = @debugon                                                                                                    
        goto endofsp
      end catch 
         
      select @oid = min(oid)
      from #tagnames
      where ref_insp_name is not null and
            ref_insp_name in ('IctsUser', 'Account') and
            oid > @oid
   end
 
endofsp:
if object_id('tempdb..#tagnames', 'U') is not null
   exec('drop table #tagnames')
   
return @status
GO
GRANT EXECUTE ON  [dbo].[usp_get_TRADE_ITEM_tags] TO [next_usr]
GO
