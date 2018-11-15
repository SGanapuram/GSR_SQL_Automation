SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
                                                         
CREATE view [dbo].[v_contract_amendable_field_rev]                              
(                                                        
	oid,
	entity_id,
	entity_field,
	entity_field_datatype,
	trans_id,
	asof_trans_id,
	resp_trans_id
)                                                        
as                                                       
select                                                   
	oid,
	entity_id,
	entity_field,
	entity_field_datatype,
	trans_id,
	trans_id,
	resp_trans_id
from dbo.aud_contract_amendable_field                                 
GO
GRANT SELECT ON  [dbo].[v_contract_amendable_field_rev] TO [admin_group]
GO
GRANT SELECT ON  [dbo].[v_contract_amendable_field_rev] TO [next_usr]
GO
