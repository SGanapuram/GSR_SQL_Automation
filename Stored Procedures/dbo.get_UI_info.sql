SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[get_UI_info]
(
   @table_name varchar(30) 
)
as
begin
set nocount on

   create table #temp_table 
   (
      row_id              int          NULL,
      column_id           int          NULL,
      column_caption      varchar(80)  NULL,
      column_datatype     char(1)      NULL,
      column_width        int          NULL,
      UI_object           varchar(30)  NULL,
      valid_values        varchar(255) NULL
   )

   insert into #temp_table (row_id)
   select gdv.gdv_num
   from dbo.generic_data_definition gdd with (nolock), 
        dbo.generic_data_values gdv with (nolock)
   where gdd.gdn_num = (select gdn_num
                        from dbo.generic_data_name with (nolock)
                        where UPPER(data_name) = 'EXTENDED INFORMATION') and      
         UPPER(gdd.attr_name) = 'TABLE_NAME' and
         gdd.gdd_num = gdv.gdd_num and
         gdv.string_value = @table_name
      
   update #temp_table
   set column_id = (select gdv.int_value
                    from dbo.generic_data_values gdv with (nolock), 
                         dbo.generic_data_definition gdd with (nolock)
                    where gdv.gdv_num = #temp_table.row_id and
                          gdv.gdd_num = gdd.gdd_num and
                          UPPER(gdd.attr_name) = 'FIELD_ID'),
       column_caption = (select gdv.string_value
                         from dbo.generic_data_values gdv with (nolock), 
                              dbo.generic_data_definition gdd with (nolock)
                         where gdv.gdv_num = #temp_table.row_id and
                               gdv.gdd_num = gdd.gdd_num and
                               UPPER(gdd.attr_name) = 'FIELD_CAPTION'),                            
       column_datatype = (select string_value
                          from dbo.generic_data_values gdv with (nolock), 
                               dbo.generic_data_definition gdd with (nolock)
                          where gdv.gdv_num = #temp_table.row_id and
                                gdv.gdd_num = gdd.gdd_num and
                            UPPER(gdd.attr_name) = 'FIELD_DATATYPE_IND'),
       column_width = (select int_value
                       from dbo.generic_data_values gdv with (nolock), 
                            dbo.generic_data_definition gdd with (nolock)
                       where gdv.gdv_num = #temp_table.row_id and
                             gdv.gdd_num = gdd.gdd_num and
                             UPPER(gdd.attr_name) = 'FIELD_WIDTH'),
       UI_object = (select string_value
                    from dbo.generic_data_values gdv with (nolock), 
                         dbo.generic_data_definition gdd with (nolock)
                    where gdv.gdv_num = #temp_table.row_id and
                          gdv.gdd_num = gdd.gdd_num and
                          UPPER(gdd.attr_name) = 'FIELD_UI'),
       valid_values = (select string_value
                       from dbo.generic_data_values gdv with (nolock), 
                            dbo.generic_data_definition gdd with (nolock)
                       where gdv.gdv_num = #temp_table.row_id and
                             gdv.gdd_num = gdd.gdd_num and
                             UPPER(gdd.attr_name) = 'VALID_VALUES')

   select column_id,
          column_caption,
          column_datatype,
          column_width,
          UI_object,
          valid_values
   from #temp_table
   order by column_id

   drop table #temp_table
end
return
GO
GRANT EXECUTE ON  [dbo].[get_UI_info] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'PROCEDURE', N'get_UI_info', NULL, NULL
GO
