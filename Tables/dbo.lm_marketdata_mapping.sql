CREATE TABLE [dbo].[lm_marketdata_mapping]
(
[oid] [int] NOT NULL,
[commkt_key] [int] NOT NULL,
[exch_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exch_cmpx_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[product_family_type] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[product_family_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cb_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lm_marketdata_mapping_deltrg]
on [dbo].[lm_marketdata_mapping]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id   bigint

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
   select @errmsg = '(lm_marketdata_mapping) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror (@errmsg,16,1)
   if @@trancount > 0 rollback tran

   return
end

insert dbo.aud_lm_marketdata_mapping
(  
   oid,
   commkt_key,
   exch_code,
   exch_cmpx_code,
   product_family_type,
   product_family_code,
   cb_cmdty_code,
   trans_id,
   resp_trans_id
)
select
   d.oid, 
   d.commkt_key,
   d.exch_code,
   d.exch_cmpx_code,
   d.product_family_type,
   d.product_family_code,
   d.cb_cmdty_code,
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

create trigger [dbo].[lm_marketdata_mapping_updtrg]
on [dbo].[lm_marketdata_mapping]
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
   raiserror ('(lm_marketdata_mapping) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(lm_marketdata_mapping) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid)
begin
   select @errmsg = '(lm_marketdata_mapping) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
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
      raiserror ('(lm_marketdata_mapping) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_lm_marketdata_mapping
    (oid,
     commkt_key,
     exch_code,
     exch_cmpx_code,
     product_family_type,
     product_family_code,
     cb_cmdty_code,
     trans_id,
     resp_trans_id)
   select
     d.oid,
     d.commkt_key,
     d.exch_code,
     d.exch_cmpx_code,
     d.product_family_type,
     d.product_family_code,
     d.cb_cmdty_code, 
     d.trans_id,
     i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid

return
GO
ALTER TABLE [dbo].[lm_marketdata_mapping] ADD CONSTRAINT [lm_marketdata_mapping_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lm_marketdata_mapping] ADD CONSTRAINT [lm_marketdata_mapping_fk1] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
GRANT DELETE ON  [dbo].[lm_marketdata_mapping] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[lm_marketdata_mapping] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[lm_marketdata_mapping] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[lm_marketdata_mapping] TO [next_usr]
GO
