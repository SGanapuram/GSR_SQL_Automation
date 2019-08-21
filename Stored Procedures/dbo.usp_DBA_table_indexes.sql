SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_DBA_table_indexes]
(
   @schemaname          sysname = 'dbo',
   @tablename           sysname
)
as
set nocount on
declare @tableid                     int,
		@index_id                    int,
		@index_column_id             smallint,
		@last_index_column_id        smallint,
		@last_include_column_id      smallint,
        @column_name                 sysname,
        @index_name                  sysname,
		@index_collist               varchar(2000),
		@include_collist             varchar(2000),
	    @is_descending_key	         bit,
        @is_included_column          bit
	
   set @tableid = OBJECT_ID(@schemaname + '.' + @tablename)

   create table #indexes
   (
      index_name             sysname primary key,
      index_id               int,
      type_desc	             nvarchar(60),
	  is_primary_key         bit,                  /* 1 =  Index is part of a PRIMARY KEY constraint */
	  is_unique_constraint   bit,                  /* 1 = Index is part of a UNIQUE constraint */
      is_unique              bit,                  /* 1 = Index is unique */
      fill_factor	         tinyint,
      allow_row_locks        bit,
      allow_page_locks       bit,
      has_filter             bit,
      filter_definition      nvarchar(max),
      index_collist          varchar(2000) null,
      include_collist        varchar(2000) null	  
   )

   insert into #indexes
   (
      index_id,
      index_name,
      type_desc,
	  is_primary_key,
	  is_unique_constraint,
      is_unique,
      fill_factor,
      allow_row_locks,
      allow_page_locks,
      has_filter,
      filter_definition
   )
   select 
      index_id,
      name,
      type_desc,
	  is_primary_key,
	  is_unique_constraint,
      is_unique,
      fill_factor,
      allow_row_locks,
      allow_page_locks,
      has_filter,
      filter_definition
   from sys.indexes
   where object_id = @tableid and
	     name is not null and      /* skip HEAP */
         name not like '_dta_index_%' and
	     name not like '_WA_Sys_%'

   select @index_name = min(index_name)
   from #indexes

   while @index_name is not null
   begin
      select @index_id = index_id
      from #indexes
      where index_name = @index_name

      set @index_collist = null
      set @include_collist = null

      select @last_index_column_id = max(index_column_id)
      from sys.index_columns
      where object_id = @tableid and
            index_id = @index_id and
		    is_included_column = 0

      select @last_include_column_id = max(index_column_id)
      from sys.index_columns
      where object_id = @tableid and
            index_id = @index_id and
		    is_included_column = 1
		 
      select @index_column_id = min(index_column_id)
      from sys.index_columns
      where object_id = @tableid and
            index_id = @index_id
		 
      while @index_column_id is not null
      begin
         select @column_name = col_name(object_id, column_id),
                @is_descending_key	= is_descending_key,
                @is_included_column = is_included_column
         from sys.index_columns
         where object_id = @tableid and
               index_id = @index_id and
			   index_column_id = @index_column_id

         if @is_included_column = 0
         begin	  
            if @index_collist is null
               set @index_collist = '[' + @column_name + ']'
            else
               set @index_collist = @index_collist + '[' + @column_name + ']'	
            if @is_descending_key = 1
		       set @index_collist = @index_collist + ' desc'
            if @index_column_id < @last_index_column_id
               set @index_collist = @index_collist + ', '
         end
	     else
	     begin
            if @include_collist is null
               set @include_collist = '[' + @column_name + ']'
            else
               set @include_collist = @include_collist + '[' + @column_name + ']'	
            if @index_column_id < @last_include_column_id
               set @include_collist = @include_collist + ', '
	     end
	  
         select @index_column_id = min(index_column_id)
         from sys.index_columns
         where object_id = @tableid and
               index_id = @index_id and
               index_column_id > @index_column_id
      end /* while */
	 
	  update #indexes
	  set index_collist = @index_collist,
          include_collist = @include_collist
	  where index_name = @index_name

      select @index_name = min(index_name)
      from #indexes
      where index_name > @index_name
   end
   
   select *
   from #indexes
   order by index_id
   
   drop table #indexes
GO
