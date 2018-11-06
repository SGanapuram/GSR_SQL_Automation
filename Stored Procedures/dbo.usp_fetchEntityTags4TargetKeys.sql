SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_fetchEntityTags4TargetKeys]  
(  
   @a_entity_tag_name     varchar(100),    
   @b_target_values       varchar(8000),    
   @c_target_key_values   varchar(8000),    
   @d_row_delimiter       varchar(10),    
   @e_column_delimiter    varchar(10),    
   @f_keyvalue_delimiter  varchar(10) 
)   
as    
begin   
set nocount on  
declare @next                        int    
declare @lenStringArray              int    
declare @lenDelimiter                int    
declare @ii                          int    
declare @targetRecordKey             varchar(500)    
declare @lenColumnArray              int    
declare @lenColumnDelimiter          int    
declare @nextColumn                  int    
declare @jj                          int    
declare @targetKeyValue              varchar(100)    
declare @lenKeyValue                 int    
declare @lenKeyValueDelimiter        int    
declare @targetKey                   varchar(100)    
declare @nextKeyValueDelimLocation   int    
declare @targetValue                 varchar(100)    
declare @kk                          int    
    
declare @TargetValuesTable TABLE    
(    
   SeqNo     int IDENTITY(1, 1),     
   Item      varchar(8000)    
) 
   
declare @TargetNamedValuesTable TABLE    
(    
   SeqNo      int IDENTITY(1, 1),     
   keyName    varchar(8000),    
   keyValue   varchar(8000)    
)    

declare @TargetEntityKeysTable TABLE    
(    
   SeqNo      int IDENTITY(1, 1),     
   key1       varchar(8000),    
   key2       varchar(8000),    
   key3       varchar(8000)    
)    

   --initialise everything    
   select @ii = 1, 
          @lenStringArray = LEN(@b_target_values),
          @lenDelimiter = LEN(@d_row_delimiter)    
 
   if @lenStringArray > 0    
   begin    
      while @ii <= @lenStringArray    
      begin --find the next occurrence of the delimiter in the target_values    
         select @next = CHARINDEX(@d_row_delimiter, @b_target_values + @d_row_delimiter, @ii)    
         insert into @TargetValuesTable (Item)    
         select SUBSTRING(@b_target_values, @ii, @next - @ii)    
         select @ii = @next + @lenDelimiter    
      end   
      select 
         entity_tag_id, 
         entity_tag_name,    
         s_record_key1 = sekn1.key_name + '=' +     
                            case sekn1.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end + et.key1 +    
                            case sekn1.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end,     
         s_record_key2 = sekn2.key_name + '=' +     
                            case sekn2.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end + et.key2 +    
                            case sekn2.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end,     
         s_record_key3 = sekn3.key_name + '=' +     
                            case sekn3.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end + et.key3 +    
                            case sekn3.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end,     
         t_record_key1 = tekn1.key_name + '=' +     
                            case tekn1.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end + et.target_key1 +    
                            case tekn1.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end,     
         t_record_key2 = tekn2.key_name + '=' +     
                            case tekn2.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end + et.target_key2 +    
                            case tekn2.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end,     
         t_record_key3 = tekn3.key_name + '=' +     
                            case tekn3.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end + et.target_key3 +    
                            case tekn3.key_data_type when 'char' then '''' 
                                                     when 'datetime' then '''' 
                                                     else '' 
                            end,     
         target_key1, 
         target_key2, 
         target_key3      
      from dbo.entity_tag et     
              join dbo.entity_tag_definition etd 
                 on et.entity_tag_id = etd.oid    
              join dbo.icts_entity_name sien 
                 on etd.entity_id = sien.oid    
              left join dbo.entity_key_name sekn1 
                 on sien.entity_name = sekn1.entity_name and 
                    sekn1.key_num = 1    
              left join dbo.entity_key_name sekn2 
                 on sien.entity_name = sekn2.entity_name and 
                    sekn2.key_num = 2    
              left join dbo.entity_key_name sekn3 
                 on sien.entity_name = sekn3.entity_name and 
                    sekn3.key_num = 3    
              left join dbo.icts_entity_name tien 
                 on etd.target_entity_id = tien.oid    
              left join dbo.entity_key_name tekn1 
                 on tien.entity_name = tekn1.entity_name and 
                    tekn1.key_num = 1    
              left join dbo.entity_key_name tekn2 
                 on tien.entity_name = tekn2.entity_name and 
                    tekn2.key_num = 2    
              left join dbo.entity_key_name tekn3 
                 on tien.entity_name = tekn3.entity_name and 
                    tekn3.key_num = 3    
      where entity_tag_name = @a_entity_tag_name and 
            et.target_key1 in (select Item from @TargetValuesTable)     
   end    
   else    
   begin    
      select @ii = 1, 
             @lenStringArray = LEN(@c_target_key_values),
             @lenDelimiter = LEN(@d_row_delimiter)    
      if @lenStringArray > 0    
      begin    
         while @ii <= @lenStringArray    
         begin    --find the next occurrence of the delimiter in the @c_target_key_values    
            select @next = CHARINDEX(@d_row_delimiter, @c_target_key_values + @d_row_delimiter, @ii)    
            select @targetRecordKey = SUBSTRING(@c_target_key_values, @ii, @next - @ii)    
            select @jj = 1, 
                   @lenColumnArray = LEN(@targetRecordKey), 
                   @lenColumnDelimiter = LEN(@e_column_delimiter)    
            while @jj <= @lenColumnArray    
            begin --find the next occurrence of the delimiter in the @targetRecordKey    
               select @nextColumn = CHARINDEX(@e_column_delimiter, @targetRecordKey + @e_column_delimiter, @jj)    
               select @targetKeyValue = SUBSTRING(@targetRecordKey, @jj, @nextColumn - @jj)    
               select @kk = 1, 
                      @lenKeyValue = LEN(@targetKeyValue),
                      @lenKeyValueDelimiter = LEN(@f_keyvalue_delimiter)    
               select @nextKeyValueDelimLocation = CHARINDEX(@f_keyvalue_delimiter, @targetKeyValue + @f_keyvalue_delimiter, @kk)    
               select @targetKey = SUBSTRING(@targetKeyValue, @kk, @nextKeyValueDelimLocation - @kk)    
    
               select @kk = @nextKeyValueDelimLocation + @lenKeyValueDelimiter    
               select @nextKeyValueDelimLocation = CHARINDEX(@f_keyvalue_delimiter, @targetKeyValue + @f_keyvalue_delimiter, @kk)    
               select @targetValue = SUBSTRING(@targetKeyValue, @kk, @nextKeyValueDelimLocation - @kk)    
    
               insert into @TargetNamedValuesTable (keyName,keyValue)    
               select @targetKey,@targetValue    
               select @jj = @nextColumn + @lenColumnDelimiter    
            end    
            insert into @TargetEntityKeysTable (key1, key2, key3)    
            select nv1.keyValue,
                   nv2.keyValue,
                   nv3.keyValue 
            from dbo.entity_tag_definition etd    
                    left join dbo.icts_entity_name tien 
                       on etd.target_entity_id = tien.oid    
                    left join dbo.entity_key_name tekn1 
                       on tien.entity_name = tekn1.entity_name and 
                          tekn1.key_num = 1    
                    left join dbo.entity_key_name tekn2 
                       on tien.entity_name = tekn2.entity_name and 
                          tekn2.key_num = 2    
                    left join dbo.entity_key_name tekn3 
                       on tien.entity_name = tekn3.entity_name and 
                          tekn3.key_num = 3    
                    left join @TargetNamedValuesTable nv1 
                       on tekn1.key_name = nv1.keyName    
                    left join @TargetNamedValuesTable nv2 
                       on tekn2.key_name = nv2.keyName    
                    left join @TargetNamedValuesTable nv3 
                       on tekn3.key_name = nv3.keyName    
            where entity_tag_name = @a_entity_tag_name    

            delete from @TargetNamedValuesTable    
            select @ii = @next + @lenDelimiter    
         end
         select entity_tag_id, 
                entity_tag_name,    
                s_record_key1 = sekn1.key_name + '=' +     
                                   case sekn1.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end + et.key1 +    
                                   case sekn1.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end,     
                s_record_key2 = sekn2.key_name + '=' +     
                                   case sekn2.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end + et.key2 +    
                                   case sekn2.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end,     
                s_record_key3 = sekn3.key_name + '=' +     
                                   case sekn3.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end + et.key3 +    
                                   case sekn3.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end,     
                t_record_key1 = tekn1.key_name + '=' +     
                                   case tekn1.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end + et.target_key1 +    
                                   case tekn1.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end,     
                t_record_key2 = tekn2.key_name + '=' +     
                                   case tekn2.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end + et.target_key2 +    
                                   case tekn2.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end,     
                t_record_key3 = tekn3.key_name + '=' +     
                                   case tekn3.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end + et.target_key3 +    
                                   case tekn3.key_data_type when 'char' then '''' 
                                                            when 'datetime' then '''' 
                                                            else '' 
                                   end,     
                target_key1, 
                target_key2, 
                target_key3      
         from dbo.entity_tag et     
                 join dbo.entity_tag_definition etd 
                    on et.entity_tag_id = etd.oid    
                 join @TargetEntityKeysTable tkv 
                    on et.target_key1 = tkv.key1 and 
                       isnull(et.target_key2, '') = isnull(tkv.key2, '') and 
                       isnull(et.target_key3, '') = isnull(tkv.key3, '')    
                 join dbo.icts_entity_name sien 
                    on etd.entity_id = sien.oid    
                 left join dbo.entity_key_name sekn1 
                    on sien.entity_name = sekn1.entity_name and 
                       sekn1.key_num = 1    
                 left join dbo.entity_key_name sekn2 
                    on sien.entity_name = sekn2.entity_name and 
                       sekn2.key_num = 2    
                 left join dbo.entity_key_name sekn3 
                    on sien.entity_name = sekn3.entity_name and 
                       sekn3.key_num = 3    
                 left join dbo.icts_entity_name tien 
                    on etd.target_entity_id = tien.oid    
                 left join dbo.entity_key_name tekn1 
                    on tien.entity_name = tekn1.entity_name and 
                       tekn1.key_num = 1    
                 left join dbo.entity_key_name tekn2 
                    on tien.entity_name = tekn2.entity_name and 
                       tekn2.key_num = 2    
                 left join dbo.entity_key_name tekn3 
                    on tien.entity_name = tekn3.entity_name and 
                       tekn3.key_num = 3    
         where entity_tag_name = @a_entity_tag_name    
      end    
   end    
end 
GO
GRANT EXECUTE ON  [dbo].[usp_fetchEntityTags4TargetKeys] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'usp_fetchEntityTags4TargetKeys', NULL, NULL
GO
