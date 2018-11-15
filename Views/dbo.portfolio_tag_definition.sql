SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[portfolio_tag_definition]
(
   tag_name, 
   tag_desc, 
	 ref_insp_name,
	 ref_insp_formatter_key,
	 value_entity_name,
	 value_type_ind,
	 value_attribute,
	 tag_status,
	 tag_required_ind,
	 foreign_key_table,
	 foreign_key_field,
	 trans_id
)
WITH SCHEMABINDING
as
select etd.entity_tag_name,
       etd.entity_tag_desc, 
	     NULL,             /* ref_insp_name */
	     NULL,             /* ref_insp_formatter_key */
	     NULL,             /* value_entity_name */
	     'S',              /* value_type_ind */
	     NULL,             /* value_attribute */
	     etd.tag_status,
	     etd.tag_required_ind,
	     NULL,             /* foreign_key_table */
	     NULL,             /* foreign_key_field */
       etd.trans_id
from dbo.entity_tag_definition etd
        join dbo.icts_entity_name en
           on etd.entity_id = en.oid
where en.entity_name = 'Portfolio'
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_definition_ideltrg]
on [dbo].[portfolio_tag_definition]
INSTEAD OF DELETE
AS
begin
declare @num_rows       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return
       
   delete etd
   from dbo.entity_tag_definition etd
           join deleted d
              on etd.entity_tag_name = d.tag_name
   where etd.entity_id = (select oid 
                          from dbo.icts_entity_name with (nolock) 
                          where entity_name = 'Portfolio')             
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_definition_iinstrg]
on [dbo].[portfolio_tag_definition]
INSTEAD OF INSERT
AS
begin
declare @num_rows       int,
        @last_oid       int,
        @entity_id      int

   set @num_rows = @@rowcount
   if @num_rows = 0  return
 
   set @entity_id = (select oid
                     from dbo.icts_entity_name with (nolock)
                     where entity_name = 'Portfolio')
                                          
   create table #ettags
   (
      oid                     int IDENTITY primary key,
	    tag_name                varchar(16) NOT NULL,
	    tag_desc                varchar(64) NOT NULL,
	    ref_insp_name           varchar(30) NULL,
	    ref_insp_formatter_key  varchar(30) NULL,
	    value_entity_name       varchar(30) NULL,
	    value_type_ind          char(1) NOT NULL,
	    value_attribute         varchar(60) NULL,
	    tag_status              char(1) NOT NULL,
	    tag_required_ind        char(1) NOT NULL,
	    foreign_key_table       varchar(30) NULL,
	    foreign_key_field       varchar(30) NULL,
	    trans_id                int NOT NULL
   )

   insert into #ettags
      (tag_name, 
	     tag_desc,
	     ref_insp_name,
	     ref_insp_formatter_key,
	     value_entity_name,
	     value_type_ind,
	     value_attribute,
	     tag_status,
	     tag_required_ind,
	     foreign_key_table,
	     foreign_key_field,
	     trans_id
     )
     select * from inserted
        
   select @last_oid = max(oid) 
   from dbo.entity_tag_definition
   
   insert into dbo.entity_tag_definition
    	   (oid,
	        entity_tag_name,
	        entity_tag_desc,
	        target_entity_id,
	        tag_required_ind,
	        tag_status,
	        entity_id,
	        trans_id)
	    select @last_oid + et.oid,
	           et.tag_name,
             et.tag_desc,
             null,
	           et.tag_required_ind,
	           et.tag_status,  
	           @entity_id,             
             et.trans_id
      from #ettags et

    update dbo.new_num
    set last_num = (select max(oid) from dbo.entity_tag_definition)
    where owner_table = 'entity_tag_definition' and
          owner_column = 'oid' and
          loc_num = 0
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_definition_iupdtrg]
on [dbo].[portfolio_tag_definition]
INSTEAD OF UPDATE
AS
begin
declare @num_rows       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return
           
   if update(tag_name)
   begin
      RAISERROR('The ''tag_name'' is not allowed to change', 0, 1) with nowait
    	rollback tran
      return
   end
     
   update etd
   set entity_tag_name = i.tag_name,
	     entity_tag_desc = i.tag_desc,
	     tag_required_ind = i.tag_required_ind,
	     tag_status = i.tag_status,
       trans_id = i.trans_id
   from dbo.entity_tag_definition etd
           join deleted d
              on etd.entity_tag_name = d.tag_name
           join inserted i
              on d.tag_name = i.tag_name
   where etd.entity_id = (select oid     
                          from dbo.icts_entity_name with (nolock) 
                          where entity_name = 'Portfolio')
end
GO
GRANT DELETE ON  [dbo].[portfolio_tag_definition] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_tag_definition] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_tag_definition] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_tag_definition] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'portfolio_tag_definition', NULL, NULL
GO
