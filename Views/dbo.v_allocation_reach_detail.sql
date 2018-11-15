SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[v_allocation_reach_detail]              
(
alloc_num,
alloc_item_num,
ai_est_actual_num,
cas_num_desc1,        
date_of_msds,        
msds_reach_imp_flag,        
registration_num,         
msds_method_desc,
cas_num_desc2,        
cas_num_desc3,        
cas_num_desc4,        
cas_num_desc5,        
cas_num_desc6,        
cas_num_desc7,        
cas_num_desc8,        
cas_num_desc9,        
cas_num_desc10
)
AS
SELECT
alloc_num,
alloc_item_num,
ai_est_actual_num,
eto1.tag_option_desc  'cas_num',        
et2.target_key1  'date_of_msds',        
eto3.tag_option_desc 'msds_reach_imp_flag',        
et33.target_key1 'registration_num'  ,     
eto13.tag_option_desc msds_method_desc,
eto4.tag_option_desc cas_num_desc2,        
eto5.tag_option_desc cas_num_desc3,        
eto6.tag_option_desc cas_num_desc4,        
eto7.tag_option_desc cas_num_desc5,        
eto8.tag_option_desc cas_num_desc6,        
eto9.tag_option_desc cas_num_desc7,        
eto10.tag_option_desc cas_num_desc8,        
eto11.tag_option_desc cas_num_desc9,        
eto12.tag_option_desc cas_num_desc10
FROM ai_est_actual aia
LEFT OUTER JOIN entity_tag et1 ON et1.key1=convert(varchar,aia.alloc_num) and et1.key2=convert(varchar,aia.alloc_item_num) and et1.key3=convert(varchar,aia.ai_est_actual_num) and et1.entity_tag_id=117        
LEFT OUTER JOIN entity_tag_option eto1 ON et1.entity_tag_id= eto1.entity_tag_id and et1.target_key1=eto1.tag_option
LEFT OUTER JOIN entity_tag et2 ON et2.key1=convert(varchar,aia.alloc_num) and et2.key2=convert(varchar,aia.alloc_item_num) and et2.key3=convert(varchar,aia.ai_est_actual_num) and et2.entity_tag_id=118        
--LEFT OUTER JOIN entity_tag_option eto2 ON et2.entity_tag_id= eto2.entity_tag_id and et2.target_key1=eto2.tag_option
LEFT OUTER JOIN entity_tag et3 ON et3.key1=convert(varchar,aia.alloc_num) and et3.key2=convert(varchar,aia.alloc_item_num) and et3.key3=convert(varchar,aia.ai_est_actual_num) and et3.entity_tag_id=119        
LEFT OUTER JOIN entity_tag_option eto3 ON et3.entity_tag_id= eto3.entity_tag_id and et3.target_key1=eto3.tag_option
LEFT OUTER JOIN entity_tag et33 ON et33.key1=convert(varchar,aia.alloc_num) and et33.key2=convert(varchar,aia.alloc_item_num) and et33.key3=convert(varchar,aia.ai_est_actual_num) and et33.entity_tag_id=120        
--LEFT OUTER JOIN entity_tag_option eto33 ON et33.entity_tag_id= eto33.entity_tag_id and et33.target_key1=eto33.tag_option
LEFT OUTER JOIN entity_tag et4 ON et4.key1=convert(varchar,aia.alloc_num) and et4.key2=convert(varchar,aia.alloc_item_num) and et4.key3=convert(varchar,aia.ai_est_actual_num) and et4.entity_tag_id=140        
LEFT OUTER JOIN entity_tag_option eto4 ON et4.entity_tag_id= eto4.entity_tag_id and et4.target_key1=eto4.tag_option
LEFT OUTER JOIN entity_tag et5 ON et5.key1=convert(varchar,aia.alloc_num) and et5.key2=convert(varchar,aia.alloc_item_num) and et5.key3=convert(varchar,aia.ai_est_actual_num) and et5.entity_tag_id=141        
LEFT OUTER JOIN entity_tag_option eto5 ON et5.entity_tag_id= eto5.entity_tag_id and et5.target_key1=eto5.tag_option
LEFT OUTER JOIN entity_tag et6 ON et6.key1=convert(varchar,aia.alloc_num) and et6.key2=convert(varchar,aia.alloc_item_num) and et6.key3=convert(varchar,aia.ai_est_actual_num) and et6.entity_tag_id=142        
LEFT OUTER JOIN entity_tag_option eto6 ON et6.entity_tag_id= eto6.entity_tag_id and et6.target_key1=eto6.tag_option
LEFT OUTER JOIN entity_tag et7 ON et7.key1=convert(varchar,aia.alloc_num) and et7.key2=convert(varchar,aia.alloc_item_num) and et7.key3=convert(varchar,aia.ai_est_actual_num) and et7.entity_tag_id=143        
LEFT OUTER JOIN entity_tag_option eto7 ON et7.entity_tag_id= eto7.entity_tag_id and et7.target_key1=eto7.tag_option
LEFT OUTER JOIN entity_tag et8 ON et8.key1=convert(varchar,aia.alloc_num) and et8.key2=convert(varchar,aia.alloc_item_num) and et8.key3=convert(varchar,aia.ai_est_actual_num) and et8.entity_tag_id=144        
LEFT OUTER JOIN entity_tag_option eto8 ON et8.entity_tag_id= eto8.entity_tag_id and et8.target_key1=eto8.tag_option
LEFT OUTER JOIN entity_tag et9 ON et9.key1=convert(varchar,aia.alloc_num) and et9.key2=convert(varchar,aia.alloc_item_num) and et9.key3=convert(varchar,aia.ai_est_actual_num) and et9.entity_tag_id=146
LEFT OUTER JOIN entity_tag_option eto9 ON et9.entity_tag_id= eto9.entity_tag_id and et9.target_key1=eto9.tag_option
LEFT OUTER JOIN entity_tag et10 ON et10.key1=convert(varchar,aia.alloc_num) and et10.key2=convert(varchar,aia.alloc_item_num) and et10.key3=convert(varchar,aia.ai_est_actual_num) and et10.entity_tag_id=147        
LEFT OUTER JOIN entity_tag_option eto10 ON et10.entity_tag_id= eto10.entity_tag_id and et10.target_key1=eto10.tag_option
LEFT OUTER JOIN entity_tag et11 ON et11.key1=convert(varchar,aia.alloc_num) and et11.key2=convert(varchar,aia.alloc_item_num) and et11.key3=convert(varchar,aia.ai_est_actual_num) and et11.entity_tag_id=148        
LEFT OUTER JOIN entity_tag_option eto11 ON et11.entity_tag_id= eto11.entity_tag_id and et11.target_key1=eto11.tag_option
LEFT OUTER JOIN entity_tag et12 ON et12.key1=convert(varchar,aia.alloc_num) and et12.key2=convert(varchar,aia.alloc_item_num) and et12.key3=convert(varchar,aia.ai_est_actual_num) and et12.entity_tag_id=149        
LEFT OUTER JOIN entity_tag_option eto12 ON et12.entity_tag_id= eto12.entity_tag_id and et12.target_key1=eto12.tag_option
LEFT OUTER JOIN entity_tag et13 ON et13.key1=convert(varchar,aia.alloc_num) and et13.key2=convert(varchar,aia.alloc_item_num) and et13.key3=convert(varchar,aia.ai_est_actual_num) and et13.entity_tag_id=150        
LEFT OUTER JOIN entity_tag_option eto13 ON et13.entity_tag_id= eto13.entity_tag_id and et13.target_key1=eto13.tag_option
WHERE ai_est_actual_num<>0
GO
GRANT SELECT ON  [dbo].[v_allocation_reach_detail] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'v_allocation_reach_detail', NULL, NULL
GO
