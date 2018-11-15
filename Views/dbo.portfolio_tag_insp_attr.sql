SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[portfolio_tag_insp_attr]
(
   tag_name,
   ref_insp_attr_name,
   ref_insp_attr_type_ind,
   ref_insp_attr_value,
   trans_id
)
WITH SCHEMABINDING
as
select def.entity_tag_name, 
       attr.entity_tag_attr_name,
       'S',
       convert(varchar(4000), attr.entity_tag_attr_value),
       attr.trans_id 
from dbo.entity_tag_insp_attr attr 
        join dbo.entity_tag_definition def
           on def.oid = attr.entity_tag_id
        join dbo.icts_entity_name en
           on def.entity_id = en.oid
where en.entity_name = 'Portfolio'
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_insp_attr_ideltrg]
on [dbo].[portfolio_tag_insp_attr]
INSTEAD OF DELETE
AS
begin
declare @num_rows       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return
       
   delete etia
   from dbo.entity_tag_insp_attr etia
           join dbo.entity_tag_definition etd
              on etia.entity_tag_id = etd.oid
           join deleted d
              on etd.entity_tag_name = d.tag_name and
                 etia.entity_tag_attr_name = d.ref_insp_attr_name
   where etd.entity_id = (select oid
                          from dbo.icts_entity_name with (nolock)
                          where entity_name = 'Portfolio')
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_insp_attr_iinstrg]
on [dbo].[portfolio_tag_insp_attr]
INSTEAD OF INSERT
AS
begin
declare @num_rows       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return                     
   
   insert into dbo.entity_tag_insp_attr
    	   (entity_tag_id,
          entity_tag_attr_name,
          entity_tag_attr_value,
	        trans_id)
	    select etd.oid,
             i.ref_insp_attr_name,
             i.ref_insp_attr_value,
             i.trans_id
      from inserted i
              join dbo.entity_tag_definition etd with (nolock)
                 on etd.entity_tag_name = i.tag_name
      where etd.entity_id = (select oid
                             from dbo.icts_entity_name with (nolock)
                             where entity_name = 'Portfolio')
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_insp_attr_iupdtrg]
on [dbo].[portfolio_tag_insp_attr]
INSTEAD OF UPDATE
AS
begin
declare @num_rows       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return
           
   if update(tag_name) or
      update(ref_insp_attr_name)
   begin
      RAISERROR('The tag_name and/or the ref_insp_attr_name is not allowed to change', 0, 1) with nowait
      rollback tran
      return
   end
     
   update etia
   set entity_tag_attr_value = i.ref_insp_attr_value,
       trans_id = i.trans_id
   from dbo.entity_tag_insp_attr etia
           join dbo.entity_tag_definition etd
              on etd.oid = etia.entity_tag_id
           join deleted d
              on etd.entity_tag_name = d.tag_name and
                 etia.entity_tag_attr_name = d.ref_insp_attr_name
           join inserted i
              on d.tag_name = i.tag_name and
                 d.ref_insp_attr_name = i.ref_insp_attr_name
   where etd.entity_id = (select oid
                          from dbo.icts_entity_name with (nolock)
                          where entity_name = 'Portfolio')
end
GO
GRANT DELETE ON  [dbo].[portfolio_tag_insp_attr] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_tag_insp_attr] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_tag_insp_attr] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_tag_insp_attr] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'portfolio_tag_insp_attr', NULL, NULL
GO
