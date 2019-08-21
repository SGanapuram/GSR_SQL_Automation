SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_PLCOMP_get_tag_columns]
(
   @tag_xml_string    xml,
   @debugon           bit = 0
)
as
set nocount on
declare @hDoc                int,
        @tag_id              int,
        @tag_name            varchar(40),
        @sql                 varchar(max),
        @entity_name         varchar(30),
        @entity_keys         varchar(16),
        @colname             sysname,
        @key_datatype        varchar(10),
        @smsg                varchar(800),
        @rows_affected       int

   create table #temp
   (
      entity_tag_key          int
   )        

   create table #tags
   (
      tag_id           int primary key,
      tag_name         varchar(40)
   )

   -- get a handle for XML string
   exec sp_xml_preparedocument @hDoc OUTPUT, @tag_xml_string

   -- Shredd XML string
   select * into #entities 
   from OPENXML(@hDoc,'/entity-tags/entity-tag')
   with (entity_name varchar(16) 'entity-name',
         entity_keys varchar(16) 'entity-keys',
         key_datatype varchar(10) 'entity-key-datatype')

   -- We got data in #entities table, we don't need XML handle, so just drop it
   exec sp_xml_removedocument @hDoc

   select @entity_name = min(entity_name)
   from #entities

   while @entity_name is not null
   begin
      /* entity_name
         -------------------
         Account
         AiEstActual
         AllocationItem
         Commodity
         Cost
         CostCode
         CostTemplateItem
         Country
         ForecastValue
         IctsUser
         Lc
         PaymentTerm
         Portfolio
         Position
         Shipment
         Specification
         Trade
         TradeItem
         Voucher
      */
      if @entity_name not in ('Portfolio', 'TradeItem')
      begin
         set @smsg = 'The entity ''' + @entity_name + ''' is not currently supported by this version of app'
         RAISERROR(@smsg, 0, 1) WITH NOWAIT
         goto next1
      end

      if @debugon = 1
      begin
         set @smsg = 'entity name = ''' + @entity_name + ''''
         RAISERROR(@smsg, 0, 1) WITH NOWAIT
      end
   
      select @entity_keys = entity_keys,
             @key_datatype = key_datatype
      from #entities
      where entity_name = @entity_name
   
      truncate table #tags
	 
      -- Getting tags owned by @entity_name
      insert into #tags (tag_id, tag_name)
        select oid, rtrim(entity_tag_name)
        from dbo.entity_tag_definition WITH (NOLOCK)
        where entity_id = (select oid
                           from dbo.icts_entity_name WITH (NOLOCK)
                           where entity_name = @entity_name) and
              tag_status = 'A'

      select @tag_name = min(tag_name)
      from #tags

      -- Going thru each tag and producing an UPDATE statement for tag
      while @tag_name is not null
      begin
         select @tag_id = tag_id
         from #tags
         where tag_name = @tag_name
   
         if @debugon = 1
         begin
            set @smsg = '=> tag name = ''' + @tag_name + ''''
            RAISERROR(@smsg, 0, 1) WITH NOWAIT
         end
      
         -- Check to see if the tag has any association with portfolioes existed in #children
         -- We only want to append tag column if the tag has any association with portfolioes 
         -- existed in #children
         if @entity_name = 'Portfolio'
         begin
            set @sql = 'select top 1 tag_id from #porttags tag where tag_id = ' + cast(@tag_id as varchar) + ' and '
            set @sql = @sql + 'exists (select 1 from #PlDelta c where cast(c.' +  @entity_keys + ' as varchar) = tag.port_num)'
         end
         else if @entity_name = 'TradeItem'
         begin
            set @sql = 'select top 1 tag_id from #titags tag where tag_id = ' + cast(@tag_id as varchar) + ' and '
            set @sql = @sql + 'exists (select 1 from #PlDelta c where c.' +  @entity_keys + ' = tag.trade_key)'
         end

         if @debugon = 1
            print 'DEBUG: @sql = ''' + @sql + ''''

         truncate table #temp
         insert into #temp
            exec(@sql)
         select @rows_affected = @@rowcount
         if @rows_affected > 0 
         begin  
            set @colname = 'X_' + @entity_name + '_' + @tag_name
            set @sql = 'update a set ' + @colname + ' = '
         
            -- If the tag is BOOKCOMP', we want to get the booking company name from the account table
            if @tag_name <> 'BOOKCOMP'
               set @sql = @sql + 'tag_value '
            else
            begin
               set @sql = @sql + '(select ac.acct_short_name from dbo.account ac WITH (NOLOCK) '
               set @sql = @sql + 'where et.tag_value = cast(ac.acct_num as varchar)) '
            end 
            if @entity_name = 'Portfolio'
            begin
               set @sql = @sql + 'from #PlDelta a LEFT OUTER JOIN #porttags et WITH (NOLOCK) '
               set @sql = @sql + 'ON et.port_num = a.' + @entity_keys + ' and '
            end
            else if @entity_name = 'TradeItem'
            begin
               set @sql = @sql + 'from #PlDelta a LEFT OUTER JOIN #titags et WITH (NOLOCK) '
               set @sql = @sql + 'ON et.trade_key = a.' + @entity_keys + ' and '
            end
            set @sql = @sql + 'et.tag_id = ' + cast(@tag_id as varchar)
         
            insert into #tag_sql
                (entity_name, tag_name, colname, sql_stmt)
              values(@entity_name, @tag_name, @colname, @sql)                 
         end
      
         select @tag_name = min(tag_name)
         from #tags
         where tag_name > @tag_name
      end
      
      if @debugon = 1
      begin
         RAISERROR(' ', 0, 1) WITH NOWAIT
      end

next1:      
      select @entity_name = min(entity_name)
      from #entities
      where entity_name > @entity_name
   end
   
endofsp:
if object_id('tempdb..#entities', 'U') is not null
   exec('drop table #entities')
if object_id('tempdb..#tags', 'U') is not null
   exec('drop table #tags')
if object_id('tempdb..#temp', 'U') is not null
   exec('drop table #temp')
GO
GRANT EXECUTE ON  [dbo].[usp_PLCOMP_get_tag_columns] TO [next_usr]
GO
