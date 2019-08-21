SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[find_table_and_keys]
(
   @tablename      varchar(40),
   @colname        varchar(40) = null
)
as
begin
set nocount on

   if (@colname is not null)
   begin
      select distinct
         FROM_COLUMN = @colname,
         TO_TABLE = object_name(k.depid),
         TO_COLUMN = isnull(col_name(k.depid, k.depkey1), '*'),
         TO_COLUMN_DATATYPE = sc.type,
         TO_COLUMN_ALIAS = a.alias_name,
         TO_COLUMN_DISPLAY_NAME = a.column_name,
         TO_COLUMN_COMPLEX_NAME = a.complex_name
      from sys.syskeys k,
           master.dbo.spt_values v,
           sys.syscolumns sc,
           dbo.alias a
      where k.type = v.number and 
            v.type = 'K' and   
            substring(v.name, 1, 7) = 'foreign' and   
            k.id = object_id(@tablename) and   
            isnull(col_name(k.id, key1), 'X') = @colname and   
            key2 is null and 
            key3 is null and 
            key4 is null and 
            key5 is null and 
            key6 is null and 
            key7 is null and 
            key8 is null and 
            sc.id = k.depid and 
            sc.colid = k.depkey1 and 
            a.table_name = object_name(k.depid) and 
            ((a.key_name = isnull(col_name(k.depid, k.depkey1), '*') and		
              k.depid != k.id) or    
             (a.key_name = isnull(col_name(k.id, k.key1), '*') and		
              k.depid = k.id))
   end
   else
   if (@colname is null)
   begin
      select distinct
         FROM_COLUMN = col_name(k.id, k.key1),
         TO_TABLE = object_name(k.depid),
         TO_COLUMN = isnull(col_name(k.depid, k.depkey1), '*'),
         TO_COLUMN_DATATYPE = sc.type,
         TO_COLUMN_ALIAS = a.alias_name,
         TO_COLUMN_DISPLAY_NAME = a.column_name
      from sys.syskeys k,
           master.dbo.spt_values v,
           sys.syscolumns sc,
           dbo.alias a
      where k.type = v.number and 
            v.type = 'K' and
            substring(v.name, 1, 7) = 'foreign' and
            k.id = object_id(@tablename) and
            key2 is null and
            key3 is null and
            key4 is null and
            key5 is null and
            key6 is null and
            key7 is null and
            key8 is null and
            sc.id = k.depid and
            sc.colid = k.depkey1 and
            a.table_name = object_name(k.depid) and
            ((a.key_name = isnull(col_name(k.depid, k.depkey1), '*') and
		          k.depid != k.id) or    
		         (a.key_name = isnull(col_name(k.id, k.key1), '*') and
		          k.depid = k.id))
   end
end
GO
GRANT EXECUTE ON  [dbo].[find_table_and_keys] TO [next_usr]
GO
