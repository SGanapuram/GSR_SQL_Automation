CREATE TABLE [dbo].[market]
(
[mkt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_full_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[market_deltrg]
on [dbo].[market]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
        @atrans_id   int,
        @tablename   varchar(30)

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
   select @errmsg = '(market) Failed to obtain a valid responsible trans_id.'
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



select @atrans_id = max(t.trans_id)
from icts_transaction t, master.dbo.sysprocesses ps
where t.spid = @@spid and
      t.spid = ps.spid and
      t.tran_date >= ps.login_time

if @atrans_id is null
begin
   select @errmsg = 'Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses
              where spid = @@spid and
                    rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,10,1)
   if @@trancount > 0 rollback tran

   return
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'DELETE',
       'Market',
       'DIRECT',
       convert(varchar(40), d.mkt_code),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'
 
/* END_TRANSACTION_TOUCH */


/* AUDIT_CODE_BEGIN */

insert dbo.aud_market
   (mkt_code,
    mkt_type,
    mkt_status,
    mkt_short_name,
    mkt_full_name,
    trans_id,
    resp_trans_id)
select
   d.mkt_code,
   d.mkt_type,
   d.mkt_status,
   d.mkt_short_name,
   d.mkt_full_name,
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

create trigger [dbo].[market_instrg]
on [dbo].[market]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

   /* BEGIN_TRANSACTION_TOUCH */
 
   insert dbo.transaction_touch
   select 'INSERT',
          'Market',
          'DIRECT',
          convert(varchar(40), i.mkt_code),
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          i.trans_id,
          it.sequence
   from inserted i, dbo.icts_transaction it
   where i.trans_id = it.trans_id and
         it.type != 'E'
 
   /* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[market_updtrg]
on [dbo].[market]
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
   raiserror ('(market) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(market) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.mkt_code = d.mkt_code )
begin
   raiserror ('(market) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(mkt_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.mkt_code = d.mkt_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(market) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* BEGIN_TRANSACTION_TOUCH */
 
insert dbo.transaction_touch
select 'UPDATE',
       'Market',
       'DIRECT',
       convert(varchar(40), i.mkt_code),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'
  
/* END_TRANSACTION_TOUCH */

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_market
      (mkt_code,
       mkt_type,
       mkt_status,
       mkt_short_name,
       mkt_full_name,
       trans_id,
       resp_trans_id)
   select
      d.mkt_code,
      d.mkt_type,
      d.mkt_status,
      d.mkt_short_name,
      d.mkt_full_name,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.mkt_code = i.mkt_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[market] ADD CONSTRAINT [market_pk] PRIMARY KEY CLUSTERED  ([mkt_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [market_POSGRID_idx1] ON [dbo].[market] ([mkt_code]) INCLUDE ([mkt_short_name], [mkt_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[market] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[market] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[market] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[market] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'market', NULL, NULL
GO
