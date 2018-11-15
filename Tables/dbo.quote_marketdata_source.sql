CREATE TABLE [dbo].[quote_marketdata_source]
(
[id] [int] NOT NULL,
[calendar_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[currency_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_id] [int] NOT NULL,
[uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
create trigger [dbo].[quote_marketdata_source_deltrg]
on [dbo].[quote_marketdata_source]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int
 
set @num_rows = @@rowcount
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
   set @errmsg = '(quote_marketdata_source) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      set @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 
insert dbo.aud_quote_marketdata_source
(
   id,
   calendar_code,
   currency_code,
   quote_id,
   uom_code,
   trans_id,
   resp_trans_id
)
select
   d.id,
   d.calendar_code,
   d.currency_code,
   d.quote_id,
   d.uom_code,
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
 
create trigger [dbo].[quote_marketdata_source_updtrg]
on [dbo].[quote_marketdata_source]
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
   raiserror('(quote_marketdata_source) The change needs to be attached with a new trans_id.', 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      set @errmsg = '(quote_marketdata_source) New trans_id must be larger than original trans_id.'
      set @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg, 10, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.id = d.id)
begin
   raiserror ('(quote_marketdata_source) new trans_id must not be older than current trans_id.', 10, 1)
   if @@trancount > 0 rollback tran
   return
end
 
/* RECORD_STAMP_END */
if update(id)
begin
   set @count_num_rows = (select count(*) from inserted i, deleted d
                          where i.id = d.id)
   if (@count_num_rows = @num_rows)
   begin
      set @dummy_update = 1
   end
   else
   begin
      raiserror ('(quote_marketdata_source) primary key can not be changed.', 10, 1)
      if @@trancount > 0 rollback tran
      return
   end
end
 
if @dummy_update = 0
   insert dbo.aud_quote_marketdata_source
 	    (id,
 	     calendar_code,
 	     currency_code,
 	     quote_id,
 	     uom_code,
 	     trans_id,
       resp_trans_id)
   select
 	    d.id,
 	    d.calendar_code,
 	    d.currency_code,
 	    d.quote_id,
 	    d.uom_code,
 	    d.trans_id,
 	    i.trans_id
   from deleted d, inserted i
   where d.id = i.id
return
GO
ALTER TABLE [dbo].[quote_marketdata_source] ADD CONSTRAINT [quote_marketdata_source_pk] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[quote_marketdata_source] ADD CONSTRAINT [quote_marketdata_source_fk1] FOREIGN KEY ([calendar_code]) REFERENCES [dbo].[calendar] ([calendar_code])
GO
ALTER TABLE [dbo].[quote_marketdata_source] ADD CONSTRAINT [quote_marketdata_source_fk2] FOREIGN KEY ([currency_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[quote_marketdata_source] ADD CONSTRAINT [quote_marketdata_source_fk3] FOREIGN KEY ([quote_id]) REFERENCES [dbo].[quote] ([id])
GO
ALTER TABLE [dbo].[quote_marketdata_source] ADD CONSTRAINT [quote_marketdata_source_fk4] FOREIGN KEY ([uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[quote_marketdata_source] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[quote_marketdata_source] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[quote_marketdata_source] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[quote_marketdata_source] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'quote_marketdata_source', NULL, NULL
GO
