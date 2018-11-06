SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_CHGHISTORY_get_search_filters]
(
   @search_xml_string      xml,
   @debugon                bit = 0
)
as
set nocount on
SET QUOTED_IDENTIFIER ON
declare @oid                    int
declare @criteria_name          varchar(50)
declare @column_name            varchar(800)
declare @criteria_group         varchar(20)
declare @criteria_value         varchar(max)
declare @root_port_num          int
declare @mod_date_expr          varchar(512)
declare @rows_affected          int
declare @profit_center_count    int
declare @trading_entity_count   int
declare @errcode                int
declare @smsg                   varchar(512)

declare @mytemp                 table
(
   oid                  int IDENTITY primary key,
   criteria_name        varchar(50)
)

   set @errcode = 0
   set @profit_center_count = 0
   set @trading_entity_count = 0
   set @root_port_num = null
   set @mod_date_expr = null
   
   create table #search_filters
   (
      oid                         int IDENTITY primary key,
      criteria_name               varchar(50) not null,
      column_name                 varchar(800) not null,
      criteria_group              varchar(20) not null,
      criteria_value              varchar(max) null
   )
   
   insert into @mytemp (criteria_name)
   select 'PROFIT_CENTER'
   union all
   select 'TRADING_ENTITY'
   union all
   select 'PORT_NUM'
   union all
   select 'MOD_DATE'

   select @oid = min(oid)
   from @mytemp
   
   while @oid is not null
   begin
      select @criteria_name = criteria_name
      from @mytemp
      where oid = @oid
      
      if @debugon = 1
      begin
         set @smsg = 'Processing Criteria = ''' + @criteria_name + ''' ...'
         RAISERROR(@smsg, 0, 1) WITH NOWAIT
      end
      
      if (select @search_xml_string.exist('/SearchCriterias/SearchCriteria[@CriteriaName=sql:variable("@criteria_name")]')) = 1
      begin
         select @column_name = cast(@search_xml_string.query('/SearchCriterias/SearchCriteria[@CriteriaName=sql:variable("@criteria_name")]/ColumnName/text()') as varchar(800)),
                @criteria_group = cast(@search_xml_string.query('/SearchCriterias/SearchCriteria[@CriteriaName=sql:variable("@criteria_name")]/CriteriaGroup/text()') as varchar(50)),
                @criteria_value = cast(@search_xml_string.query('/SearchCriterias/SearchCriteria[@CriteriaName=sql:variable("@criteria_name")]/CriteriaValue') as varchar(max))

         if @debugon = 1
         begin
            set @smsg = '=> DEBUG: The criteria ''' + @criteria_name + ''' exists in XML string!'
            RAISERROR(@smsg, 0, 1) WITH NOWAIT           
            set @smsg = '            Column list        = ''' + @column_name + ''''
            RAISERROR(@smsg, 0, 1) WITH NOWAIT
            set @smsg = '            Criteria group     = ''' + @criteria_group + ''''
            RAISERROR(@smsg, 0, 1) WITH NOWAIT
            set @smsg = '            Criteria_value     = ''' + @criteria_value + ''''
            RAISERROR(@smsg, 0, 1) WITH NOWAIT
            RAISERROR(' ', 0, 1) WITH NOWAIT
         end
   
         begin try
           insert into #search_filters
                 (criteria_name, column_name, criteria_group, criteria_value)
              values(@criteria_name, @column_name, @criteria_group, @criteria_value) 
         end try
         begin catch
           RAISERROR('=> Failed to add a new record into the #search_filters table due to the error:', 0, 1) WITH NOWAIT
           set @smsg = '==> ERROR: ' + ERROR_MESSAGE()
           RAISERROR(@smsg, 0, 1) WITH NOWAIT
           set @errcode = ERROR_NUMBER()
           goto endofsp
         end catch
      end

      select @oid = min(oid)
      from @mytemp
      where oid > @oid
   end
   
   set @oid = null   
   select @oid = oid
   from #search_filters
   where criteria_group = 'MULTIITEMS' and
         criteria_name = 'PROFIT_CENTER' and
         criteria_value is not null

   if @oid is not null
   begin
      select @criteria_name = criteria_name,
             @criteria_value = criteria_value
      from #search_filters
      where oid = @oid
            
      begin try
         insert into #profitCntrs 
             select * from dbo.udf_XML_get_string_data(@criteria_value);
           set @profit_center_count = @@rowcount
      end try
      begin catch
        RAISERROR('=> Failed to call the ''udf_XML_get_string_data'' function to move required profit centers due to the error:', 0, 1) WITH NOWAIT 
        set @smsg = '==> ERROR: ' + ERROR_MESSAGE()
        RAISERROR(@smsg, 0, 1) WITH NOWAIT
        set @errcode = ERROR_NUMBER()
        goto endofsp;
      end catch
         
      if @debugon = 1 select 'DEBUG - PROFIT_CENTER', * from #profitCntrs;
   end

   set @oid = null
   select @oid = oid
   from #search_filters
   where criteria_group = 'MULTIITEMS' and
         criteria_name = 'TRADING_ENTITY' and
         criteria_value is not null

   if @oid is not null
   begin
      select @criteria_name = criteria_name,
             @criteria_value = criteria_value
      from #search_filters
      where oid = @oid

      begin try
        insert into #trading_entities 
             select * from dbo.udf_XML_get_string_data(@criteria_value);
        set @trading_entity_count = @@rowcount
      end try
      begin catch
        RAISERROR('=> Failed to call the ''udf_XML_get_string_data'' function to move required trading entities due to the error:', 0, 1) WITH NOWAIT 
        set @smsg = '==> ERROR: ' + ERROR_MESSAGE()
        RAISERROR(@smsg, 0, 1) WITH NOWAIT
        set @errcode = ERROR_NUMBER()
        goto endofsp;
      end catch
         
      if @debugon = 1 select 'DEBUG - TRADING_ENTITY', * from #trading_entities;
   end

   if @debugon = 1
      RAISERROR('Processing DATE EXPRESSIONS ...', 0, 1) WITH NOWAIT
   set @mod_date_expr = ''
   
   set @oid = null
   select @oid = oid
   from #search_filters
   where criteria_group = 'DATEEXPRESSION' and
         criteria_name = 'MOD_DATE' and
         criteria_value is not null

   if @oid is not null
   begin
      select @criteria_value = criteria_value
      from #search_filters
      where oid = @oid

      set @criteria_value = REPLACE(@criteria_value, '&gt;', '>')
      set @criteria_value = REPLACE(@criteria_value, '&lt;', '<')
      set @criteria_value = REPLACE(@criteria_value, '<CriteriaValue>', '')
      set @criteria_value = REPLACE(@criteria_value, '</CriteriaValue>', '')
      
      set @mod_date_expr = @criteria_value
   end

   if @debugon = 1
      RAISERROR('Processing VALUES ...', 0, 1) WITH NOWAIT
   set @root_port_num = null
   
   set @oid = null
   select @oid = oid
   from #search_filters
   where criteria_group = 'VALUE' and
         criteria_name = 'PORT_NUM' and
         criteria_value is not null

   if @oid is not null
   begin
      select @criteria_value = criteria_value
      from #search_filters
      where oid = @oid

      set @criteria_value = REPLACE(@criteria_value, '<CriteriaValue>', '')
      set @criteria_value = REPLACE(@criteria_value, '</CriteriaValue>', '')
      
      set @root_port_num = cast(@criteria_value as int)
   end 
   
   truncate table #tempholder
   insert into #tempholder
           (port_num, date_expr, profit_center_count, trading_entity_count)
       values(@root_port_num, @mod_date_expr, @profit_center_count, @trading_entity_count)
   
endofsp:
if object_id('tempdb..#search_filters', 'U') is not null
   exec('drop table #search_filters')
   
if @errcode > 0
   return 1
return 0
GO
GRANT EXECUTE ON  [dbo].[usp_CHGHISTORY_get_search_filters] TO [next_usr]
GO
