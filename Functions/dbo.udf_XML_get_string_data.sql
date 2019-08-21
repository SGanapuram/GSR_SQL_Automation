SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_XML_get_string_data]
(
   @xml_data_list     xml
)
returns table 
as
return
(
   select s.value('.', 'varchar(80)') as data
   from @xml_data_list.nodes('/CriteriaValue/item') AS t(s)
)
GO
GRANT SELECT ON  [dbo].[udf_XML_get_string_data] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[udf_XML_get_string_data] TO [next_usr]
GO
