CREATE TABLE [dbo].[implied_pr_differential]
(
[differential] [numeric] (14, 4) NOT NULL,
[editor_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[implied_commkt_key] [int] NOT NULL,
[implied_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[implied_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[oid] [int] NOT NULL,
[source_commkt_key] [int] NOT NULL,
[source_price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[source_trading_prd] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[implied_pr_differential_deltrg]
on [dbo].[implied_pr_differential]
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
   select @errmsg = '(implied_pr_differential) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_implied_pr_differential
   (differential,
    editor_id,
    implied_commkt_key,
    implied_price_source_code,
    implied_trading_prd,
    oid,
    source_commkt_key,
    source_price_source_code,
    source_trading_prd,
    trans_id,
    resp_trans_id)
select
   d.differential,
   d.editor_id,
   d.implied_commkt_key,
   d.implied_price_source_code,
   d.implied_trading_prd,
   d.oid,
   d.source_commkt_key,
   d.source_price_source_code,
   d.source_trading_prd,
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

create trigger [dbo].[implied_pr_differential_updtrg]
on [dbo].[implied_pr_differential]
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
   raiserror ('(implied_pr_differential) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(account_type) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   raiserror ('(implied_pr_differential) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(implied_pr_differential) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_implied_pr_differential
      (differential,
       editor_id,
       implied_commkt_key,
       implied_price_source_code,
       implied_trading_prd,
       oid,
       source_commkt_key,
       source_price_source_code,
       source_trading_prd,
       trans_id,
       resp_trans_id)
   select
      d.differential,
      d.editor_id,
      d.implied_commkt_key,
      d.implied_price_source_code,
      d.implied_trading_prd,
      d.oid,
      d.source_commkt_key,
      d.source_price_source_code,
      d.source_trading_prd,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[implied_pr_differential] ADD CONSTRAINT [implied_pr_differential_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [implied_price_diff_idx1] ON [dbo].[implied_pr_differential] ([implied_commkt_key], [implied_trading_prd], [implied_price_source_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[implied_pr_differential] ADD CONSTRAINT [implied_pr_differential_fk1] FOREIGN KEY ([editor_id]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[implied_pr_differential] ADD CONSTRAINT [implied_pr_differential_fk2] FOREIGN KEY ([implied_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[implied_pr_differential] ADD CONSTRAINT [implied_pr_differential_fk3] FOREIGN KEY ([implied_commkt_key], [implied_trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
ALTER TABLE [dbo].[implied_pr_differential] ADD CONSTRAINT [implied_pr_differential_fk4] FOREIGN KEY ([source_price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
ALTER TABLE [dbo].[implied_pr_differential] ADD CONSTRAINT [implied_pr_differential_fk5] FOREIGN KEY ([source_commkt_key], [source_trading_prd]) REFERENCES [dbo].[trading_period] ([commkt_key], [trading_prd])
GO
GRANT DELETE ON  [dbo].[implied_pr_differential] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[implied_pr_differential] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[implied_pr_differential] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[implied_pr_differential] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'implied_pr_differential', NULL, NULL
GO
