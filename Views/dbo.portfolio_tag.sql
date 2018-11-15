SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[portfolio_tag]
(
   tag_name, 
   port_num, 
   tag_value, 
   trans_id
)
WITH SCHEMABINDING
as
select b.entity_tag_name,
       case when key1 like '[0-9]%' then CONVERT(int, key1) else 0 end,
       case when b.entity_tag_name = 'JMSRPT' then 'JMS REPORT'
            else isnull(et.target_key1, '')
       end,
       et.trans_id
from dbo.entity_tag et
        join dbo.entity_tag_definition b
           on et.entity_tag_id = b.oid
        join dbo.icts_entity_name en
           on b.entity_id = en.oid
where en.entity_name = 'Portfolio'
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_ideltrg]
on [dbo].[portfolio_tag]
INSTEAD OF DELETE
AS
begin
declare @num_rows       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return
       
   delete et
   from dbo.entity_tag et
           join dbo.entity_tag_definition etd
              on et.entity_tag_id = etd.oid
           join deleted d
              on etd.entity_tag_name = d.tag_name and
                 et.key1 = cast(d.port_num as varchar) and
                 et.target_key1 = d.tag_value
   where etd.entity_id = (select oid
                          from dbo.icts_entity_name with (nolock)
                          where entity_name = 'Portfolio')
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_iinstrg]
on [dbo].[portfolio_tag]
INSTEAD OF INSERT
AS
begin
declare @num_rows       int,
        @last_oid       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return
                      
   create table #ettags
   (
      oid          int IDENTITY primary key,
      tag_name     varchar(16),
      port_num     int,
      tag_value    varchar(16),
      trans_id     int 
   )

   insert into #ettags
      (tag_name, port_num, tag_value, trans_id)
     select * from inserted
        
    select @last_oid = max(entity_tag_key) 
    from dbo.entity_tag
   
    insert into dbo.entity_tag
    	   (entity_tag_key,
	        entity_tag_id,
	        key1,
	        target_key1,
	        trans_id)
	      select @last_oid + et.oid,
	             etd.oid,
	             cast(et.port_num as varchar),
               et.tag_value,
               et.trans_id
        from #ettags et
                join dbo.entity_tag_definition etd with (nolock)
                   on etd.entity_tag_name = et.tag_name
        where etd.entity_id = (select oid
                               from dbo.icts_entity_name with (nolock)
                               where entity_name = 'Portfolio')

    update dbo.new_num
    set last_num = (select max(entity_tag_key) from dbo.entity_tag)
    where owner_table = 'entity_tag' and
          owner_column = 'entity_tag_key' and
          loc_num = 0
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[portfolio_tag_iupdtrg]
on [dbo].[portfolio_tag]
INSTEAD OF UPDATE
AS
begin
declare @num_rows       int

   set @num_rows = @@rowcount
   if @num_rows = 0  return
           
   if update(tag_name) or
      update(port_num)
   begin
    	RAISERROR('The tag_name and/or the port_num is not allowed to change', 0, 1) with nowait
    	rollback tran
    	return
   end
     
   update et
   set target_key1 = i.tag_value,
       trans_id = i.trans_id
   from dbo.entity_tag et
           join dbo.entity_tag_definition etd
              on etd.oid = et.entity_tag_id
           join deleted d
              on etd.entity_tag_name = d.tag_name and
                 et.key1 = cast(d.port_num as varchar) and
                 et.target_key1 = d.tag_value
           join inserted i
              on d.tag_name = i.tag_name and
                 d.port_num = i.port_num
    where etd.entity_id = (select oid
                           from dbo.icts_entity_name with (nolock)
                           where entity_name = 'Portfolio')
end
GO
CREATE UNIQUE CLUSTERED INDEX [portfolio_tag_idx] ON [dbo].[portfolio_tag] ([tag_name], [port_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_tag_idx1] ON [dbo].[portfolio_tag] ([port_num], [tag_name]) INCLUDE ([tag_value], [trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [portfolio_tag_POSGRID_idx1] ON [dbo].[portfolio_tag] ([tag_name], [port_num]) INCLUDE ([tag_value]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[portfolio_tag] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[portfolio_tag] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[portfolio_tag] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[portfolio_tag] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'VIEW', N'portfolio_tag', NULL, NULL
GO
