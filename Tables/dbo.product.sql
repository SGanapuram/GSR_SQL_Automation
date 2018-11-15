CREATE TABLE [dbo].[product]
(
[id] [int] NOT NULL,
[base_product_id] [int] NULL,
[cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__product__status__02133CD2] DEFAULT ('N'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[product_deltrg]
on [dbo].[product]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* AUDIT_CODE_BEGIN */
select @atrans_id = max(trans_id)
from dbo.icts_transaction WITH (INDEX=icts_transaction_idx4)
where spid = @@spid and
      tran_date >= (select top 1 login_time
                    from master.dbo.sysprocesses (nolock)
                    where spid = @@spid)

if @atrans_id is null
begin
   select @errmsg = '(product) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 10, 1)
   rollback tran
   return
end

insert dbo.aud_product
(  
   id,
   base_product_id, 
   cmdty_code, 
   name, 
   status,
   trans_id,
   resp_trans_id
)
select
   d.id,
   d.base_product_id, 
   d.cmdty_code, 
   d.name, 
   d.status,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[product_updtrg]
on [dbo].[product]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror('(product) The change needs to be attached with a new trans_id.', 10, 1)
   rollback tran
   return
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(product) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror(@errmsg, 10, 1)
      rollback tran
      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.id = d.id)
begin
   select @errmsg = '(product) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.id) + ')'
      from inserted i
   end
   rollback tran
   raiserror(@errmsg, 10, 1)
   return
end

/* RECORD_STAMP_END */

if update(id)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.id = d.id)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror('(product) primary key can not be changed.', 10, 1)
      rollback tran
      return
   end
end

if @dummy_update = 0
   insert dbo.aud_product
 	    (id,
       base_product_id, 
       cmdty_code, 
       name, 
       status,
       trans_id,
       resp_trans_id)
   select
 	    d.id,
      d.base_product_id, 
      d.cmdty_code, 
      d.name, 
      d.status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.id = i.id 

return
GO
ALTER TABLE [dbo].[product] ADD CONSTRAINT [CK__product__status__0307610B] CHECK (([status]='I' OR [status]='A' OR [status]='N'))
GO
ALTER TABLE [dbo].[product] ADD CONSTRAINT [product_pk] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[product] ADD CONSTRAINT [product_uk1] UNIQUE NONCLUSTERED  ([name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[product] ADD CONSTRAINT [product_fk1] FOREIGN KEY ([base_product_id]) REFERENCES [dbo].[product] ([id])
GO
ALTER TABLE [dbo].[product] ADD CONSTRAINT [product_fk2] FOREIGN KEY ([cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[product] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[product] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[product] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[product] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'product', NULL, NULL
GO
