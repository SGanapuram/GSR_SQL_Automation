SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[portfolio_tag_option]
(
   tag_name, 
   tag_option, 
   tag_option_desc, 
   tag_option_status, 
   trans_id
)
WITH SCHEMABINDING
as
select def.entity_tag_name, 
       opt.tag_option,
       opt.tag_option_desc,
       opt.tag_option_status,
       opt.trans_id 
from dbo.entity_tag_option opt 
        join dbo.entity_tag_definition def
           on def.oid = opt.entity_tag_id
        join dbo.icts_entity_name en
           on def.entity_id = en.oid
where en.entity_name = 'Portfolio'
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_option_ideltrg]
on [dbo].[portfolio_tag_option]
INSTEAD OF DELETE
AS
begin
declare @num_rows       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return
       
   delete eto
   from dbo.entity_tag_option eto
           join dbo.entity_tag_definition etd
              on eto.entity_tag_id = etd.oid
           join deleted d
              on etd.entity_tag_name = d.tag_name and
                 eto.tag_option = d.tag_option
   where etd.entity_id = (select oid
                          from dbo.icts_entity_name with (nolock)
                          where entity_name = 'Portfolio')
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_option_iinstrg]
on [dbo].[portfolio_tag_option]
INSTEAD OF INSERT
AS
begin
declare @num_rows       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return                     
   
   insert into dbo.entity_tag_option
    	   (entity_tag_id,
	        tag_option,
	        tag_option_desc,
	        tag_option_status,
	        trans_id)
	    select etd.oid,
	           i.tag_option,
             i.tag_option_desc,
             i.tag_option_status,
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

create trigger [dbo].[portfolio_tag_option_iupdtrg]
on [dbo].[portfolio_tag_option]
INSTEAD OF UPDATE
AS
begin
declare @num_rows       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return
           
   if update(tag_name) or
      update(tag_option)
   begin
      RAISERROR('The tag_name and/or the tag_option is not allowed to change', 0, 1) with nowait
      rollback tran
      return
   end
     
   update eto
   set tag_option_desc = i.tag_option_desc,
       tag_option_status = i.tag_option_status,
       trans_id = i.trans_id
   from dbo.entity_tag_option eto
           join dbo.entity_tag_definition etd
              on etd.oid = eto.entity_tag_id
           join deleted d
              on etd.entity_tag_name = d.tag_name and
                 eto.tag_option = d.tag_option
           join inserted i
              on d.tag_name = i.tag_name and
                 d.tag_option = i.tag_option
   where etd.entity_id = (select oid
                          from dbo.icts_entity_name with (nolock)
                          where entity_name = 'Portfolio')
end
GO
CREATE UNIQUE CLUSTERED INDEX [portfolio_tag_option_idx] ON [dbo].[portfolio_tag_option] ([tag_name], [tag_option]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_tag_option_POSGRID_idx1] ON [dbo].[portfolio_tag_option] ([tag_name], [tag_option]) INCLUDE ([tag_option_desc]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[portfolio_tag_option] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_tag_option] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_tag_option] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_tag_option] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'portfolio_tag_option', NULL, NULL
GO
