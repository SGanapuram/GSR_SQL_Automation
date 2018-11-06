CREATE TABLE [dbo].[commodity_market_alias]
(
[commkt_key] [int] NOT NULL,
[alias_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__commodity___type__55BFB948] DEFAULT ('U'),
[commkt_alias_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alias_format_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[commodity_market_alias_deltrg]
on [dbo].[commodity_market_alias]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int

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
   select @errmsg = '(commodity_market_alias) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end


insert dbo.aud_commodity_market_alias
   (commkt_key,
    alias_source_code,
    type,
    commkt_alias_name,
    alias_format_code,
    trans_id,
    resp_trans_id)
select
   d.commkt_key,
   d.alias_source_code,
   d.type,
   d.commkt_alias_name,
   d.alias_format_code,
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

create trigger [dbo].[commodity_market_alias_updtrg]
on [dbo].[commodity_market_alias]
for update
as
declare @num_rows         int,
        @count_num_rows   int,
        @dummy_update     int,
        @errorNumber      int,
        @errmsg           varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

select @dummy_update = 0

/* RECORD_STAMP_BEGIN */
if not update(trans_id) 
begin
   raiserror ('(commodity_market_alias) The change needs to be attached with a new trans_id',10,1)
   if @@trancount > 0 rollback tran

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
      select @errmsg = '(commodity_market_alias) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key and 
                 i.alias_source_code = d.alias_source_code and
                 i.type = d.type )
begin
   raiserror ('(commodity_market_alias) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(commkt_key) or  
   update(alias_source_code) or
   update(type)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.commkt_key = d.commkt_key and 
                                   i.alias_source_code = d.alias_source_code and
                                   i.type = d.type )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(commodity_market_alias) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_commodity_market_alias
      (commkt_key,
       alias_source_code,
       type,
       commkt_alias_name,
       alias_format_code,
       trans_id,
       resp_trans_id)
   select
      d.commkt_key,
      d.alias_source_code,
      d.type,
      d.commkt_alias_name,
      d.alias_format_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.commkt_key = i.commkt_key and
         d.alias_source_code = i.alias_source_code and
         d.type = i.type

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[commodity_market_alias] ADD CONSTRAINT [CK__commodity___type__56B3DD81] CHECK (([type]='V' OR [type]='O' OR [type]='M' OR [type]='I' OR [type]='F' OR [type]='E' OR [type]='C' OR [type]='U'))
GO
ALTER TABLE [dbo].[commodity_market_alias] ADD CONSTRAINT [commodity_market_alias_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [alias_source_code], [type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [commodity_market_alias_ix2] ON [dbo].[commodity_market_alias] ([alias_source_code], [commkt_alias_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_market_alias] ADD CONSTRAINT [commodity_market_alias_fk1] FOREIGN KEY ([alias_source_code]) REFERENCES [dbo].[alias_source] ([alias_source_code])
GO
ALTER TABLE [dbo].[commodity_market_alias] ADD CONSTRAINT [commodity_market_alias_fk2] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
GRANT DELETE ON  [dbo].[commodity_market_alias] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[commodity_market_alias] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[commodity_market_alias] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[commodity_market_alias] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'commodity_market_alias', NULL, NULL
GO
