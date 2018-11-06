SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_gen_create_table_script]
(
   @tablename          varchar(128),
   @data_migrate_flag  bit = 0,
   @debugon            bit = 0
)
as
set nocount on
declare @colid                    int,
        @column_name              varchar(128),
        @data_type                varchar(128),
        @column_length            int,
        @numeric_precision        tinyint,
        @numeric_scale            int,
        @nullable                 bit,
        @textline                 varchar(255),
        @longest_column_length    int,
        @column_default           varchar(80),
        @column_name_str          varchar(80),
        @last_colid               int,
        @check_constraint         varchar(255),
        @dbname                   varchar(128),
        @ident_incr               numeric(3, 0), 
        @ident_seed               numeric(3, 0),
        @ident_str                varchar(20)
        
   select @dbname = db_name()

   create table #table_layout
   ( 
      colid                    int primary key,
      column_name              varchar(128) not null,
      data_type                varchar(128) not null,
      column_length            int default 0 null,
      numeric_precision        tinyint default 0 null,
      numeric_scale            int default 0 null,
      column_default           varchar(80) null,
      nullable                 bit
   )

   insert into #table_layout
      (colid, column_name, data_type, column_length, numeric_precision, 
       numeric_scale, column_default, nullable)
   select ORDINAL_POSITION,
          COLUMN_NAME,
          DATA_TYPE, 
          isnull(CHARACTER_MAXIMUM_LENGTH, 0),
          isnull(NUMERIC_PRECISION, 0),
          isnull(NUMERIC_SCALE, 0),
          case when COLUMN_DEFAULT is not null then ' DEFAULT ' + substring(COLUMN_DEFAULT, 1, 80)
             else '<NULL>'
          end,
          case when IS_NULLABLE = 'YES' then 1
             else 0
          end
   from INFORMATION_SCHEMA.COLUMNS
   where TABLE_CATALOG = @dbname and
         TABLE_SCHEMA = 'dbo' and
         TABLE_NAME = @tablename
   order by ORDINAL_POSITION

   if @data_migrate_flag = 0
   begin
      print 'IF OBJECT_ID(''dbo.' + @tablename + ''') IS NOT NULL'
      print '   exec(''DROP TABLE dbo.' + @tablename + ''')'
   end
   else
   begin
      print 'IF OBJECT_ID(''dbo.' + @tablename + ''') IS NOT NULL'
      print 'BEGIN'
      print '   exec dbo.usp_drop_FKEY_references ' + @tablename + '1'
      print '   exec(''DROP TABLE dbo.' + @tablename + ''')'
      print 'END'
   end
   print 'go'

   if @data_migrate_flag = 1
   begin
      print 'exec dbo.usp_drop_FKEY_references ' + @tablename
      print 'go'
      print ' '
      
      print 'exec dbo.usp_drop_table_FKEYs ' + @tablename
      print 'go'
      print ' '

      print 'alter table dbo.' + @tablename
      print '   drop constraint ' + @tablename + '_pk'
      print 'go'
      print ' '
      print 'exec dbo.sp_rename ' + @tablename + ', ' + @tablename + '1'
      print 'go'     
  end

   print ' '
   print 'CREATE TABLE dbo.' + @tablename
   print '('

   select @longest_column_length = max(datalength(column_name))
   from #table_layout

   select @last_colid = max(colid)
   from #table_layout

   select @colid = min(colid)
   from #table_layout

   while @colid is not null
   begin
      select @column_name = column_name,
             @data_type = data_type,
             @column_length = column_length,
             @numeric_precision = numeric_precision,
             @numeric_scale = numeric_scale,
             @column_default = column_default,
             @nullable = nullable
      from #table_layout
      where colid = @colid

      if @debugon = 1
      begin   
         print '****'
         print 'COLUMN #' + cast(@colid as varchar)
         print 'COLUMN NAME    = ' + @column_name
         print 'DATA TYPE      = ' + @data_type
         print 'COLUMN LENGTH  = ' + cast(@column_length as varchar)
         print 'PRECISION      = ' + cast(@numeric_precision as varchar)
         print 'SCALE          = ' + cast(@numeric_scale as varchar)
         print 'COLUMN DEFAULT = ' + cast(@column_default as varchar)
         print 'NULLABLE       = ' + case when @nullable = 1 then 'YES' else 'NO' end
      end   
      
      if COLUMNPROPERTY(object_id('dbo.' + @tablename), @column_name, 'IsIdentity') = 1
      begin
         select @ident_incr = isnull(IDENT_INCR(@tablename), 1) 
         select @ident_seed = isnull(IDENT_SEED(@tablename), 1)
         select @ident_str = ' IDENTITY(' + cast(@ident_seed as varchar) + ', ' + cast(@ident_incr as varchar) + ') '
      end
      else
         select @ident_str = ''
      
      -- find check constaint for the column if exists
      select @check_constraint = null
      select @check_constraint = chk.CHECK_CLAUSE
      from INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE u,
           INFORMATION_SCHEMA.CHECK_CONSTRAINTS chk
      where u.TABLE_CATALOG = @dbname and
            u.TABLE_SCHEMA = 'dbo' and
            u.TABLE_NAME = @tablename and
            u.COLUMN_NAME = @column_name and
            u.CONSTRAINT_CATALOG = chk.CONSTRAINT_CATALOG and
            u.CONSTRAINT_SCHEMA = chk.CONSTRAINT_SCHEMA and
            u.CONSTRAINT_NAME = chk.CONSTRAINT_NAME
    
      select @column_name_str = @column_name + space(@longest_column_length - datalength(@column_name))   
      select @textline = '   ' + @column_name_str + ' ' + 
                        case when @data_type = 'char' or @data_type = 'nchar' or
                                  @data_type = 'varchar' or @data_type = 'nvarchar'
                                then convert(char(20), @data_type + '(' + cast(@column_length as varchar) + ')') 
                             when @data_type = 'decimal' or @data_type = 'numeric'
                                then convert(char(20), @data_type + '(' + cast(@numeric_precision as varchar) + ', ' + cast(@numeric_scale as varchar) + ')')
                             else
                                convert(char(20), @data_type)
                        end + 
                        @ident_str +
                        case when @column_default <> '<NULL>'
                                then @column_default
                             else ''
                        end + ' ' +
                        case when @nullable = 1
                                then 'NULL'
                             else
                                'NOT NULL'
                        end

      if @check_constraint is not null
      begin
         print @textline
         if @last_colid > @colid
            print '      check ' + @check_constraint + ','
         else
            print '      check ' + @check_constraint         
      end
      else
      begin
         if @last_colid > @colid
            print @textline + ','
         else
            print @textline
      end
      

      select @colid = min(colid)
      from #table_layout
      where colid > @colid
   end
   print ')'
   print 'go'
   print ' '
   
   declare @pk_constraint_name     varchar(128),
           @pk_columns             varchar(255)
           
   select @pk_constraint_name = null
   select @pk_constraint_name = CONSTRAINT_NAME
   from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
   where TABLE_CATALOG = @dbname and
         TABLE_SCHEMA = 'dbo' and
         TABLE_NAME = @tablename and
         CONSTRAINT_CATALOG = @dbname and
         CONSTRAINT_SCHEMA = 'dbo' and
         CONSTRAINT_TYPE = 'PRIMARY KEY'
         
   if @pk_constraint_name is not null
   begin
      select @pk_columns = null
      select @colid = min(ORDINAL_POSITION)
      from INFORMATION_SCHEMA.KEY_COLUMN_USAGE
      where TABLE_CATALOG = @dbname and
            TABLE_SCHEMA = 'dbo' and
            TABLE_NAME = @tablename and
            CONSTRAINT_CATALOG = @dbname and
            CONSTRAINT_SCHEMA = 'dbo' and
            CONSTRAINT_NAME = @pk_constraint_name
            
      while @colid is not null
      begin
         select @column_name = COLUMN_NAME
         from INFORMATION_SCHEMA.KEY_COLUMN_USAGE
         where TABLE_CATALOG = @dbname and
               TABLE_SCHEMA = 'dbo' and
               TABLE_NAME = @tablename and
               CONSTRAINT_CATALOG = @dbname and
               CONSTRAINT_SCHEMA = 'dbo' and
               CONSTRAINT_NAME = @pk_constraint_name and
               ORDINAL_POSITION = @colid

         if @pk_columns is null
            select @pk_columns = @column_name
         else
            select @pk_columns = @pk_columns + ', ' + @column_name

         select @colid = min(ORDINAL_POSITION)
         from INFORMATION_SCHEMA.KEY_COLUMN_USAGE
         where TABLE_CATALOG = @dbname and
               TABLE_SCHEMA = 'dbo' and
               TABLE_NAME = @tablename and
               CONSTRAINT_CATALOG = @dbname and
               CONSTRAINT_SCHEMA = 'dbo' and
               CONSTRAINT_NAME = @pk_constraint_name and
               ORDINAL_POSITION > @colid
      end            
      print 'ALTER TABLE dbo.' + @tablename
      print '   ADD CONSTRAINT ' + @pk_constraint_name
      print '         PRIMARY KEY (' + @pk_columns + ')'
      print 'go'
      print ' '
   end
      
   print 'IF OBJECT_ID(''dbo.' + @tablename + ''') IS NOT NULL'
   print '   PRINT ''<<< CREATED TABLE ' + @tablename + ' >>>'''
   print 'ELSE'
   print '   PRINT ''<<< FAILED CREATING ' + @tablename + ' >>>'''
   print 'go'
GO
GRANT EXECUTE ON  [dbo].[usp_gen_create_table_script] TO [public]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_gen_create_table_script', NULL, NULL
GO
