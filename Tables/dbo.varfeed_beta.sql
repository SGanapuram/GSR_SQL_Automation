CREATE TABLE [dbo].[varfeed_beta]
(
[commkt_key] [int] NOT NULL,
[price_source_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[val_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[risk_factor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[price_beta] [numeric] (20, 8) NULL,
[vol_beta] [numeric] (20, 8) NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[varfeed_beta_deltrg]
on [dbo].[varfeed_beta]
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
   select @errmsg = '(varfeed_beta) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_varfeed_beta
(  
   commkt_key,
   price_source_code,
   val_type,
   risk_factor,
   price_beta,
   vol_beta,
   trans_id,
   resp_trans_id
)
select
   d.commkt_key,
   d.price_source_code,
   d.val_type,
   d.risk_factor,
   d.price_beta,
   d.vol_beta,
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

create trigger [dbo].[varfeed_beta_updtrg]
on [dbo].[varfeed_beta]
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
   raiserror ('(varfeed_beta) The change needs to be attached with a new trans_id',16,1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.commkt_key = d.commkt_key and
                 i.price_source_code = d.price_source_code and
                 i.val_type = d.val_type)
begin
   raiserror ('(varfeed_beta) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(commkt_key)  or  
   update(price_source_code) or
   update(val_type)
begin
   select @count_num_rows = (select count(*) 
                             from inserted i, deleted d
                             where i.commkt_key = d.commkt_key and
                                   i.price_source_code = d.price_source_code and
                                   i.val_type = d.val_type)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      select @errmsg = '(varfeed_beta) primary key can not be changed.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_varfeed_beta
   (
      commkt_key,
      price_source_code,
      val_type,
      risk_factor,
      price_beta,
      vol_beta,
      trans_id,
      resp_trans_id
   )
   select
      d.commkt_key,
      d.price_source_code,
      d.val_type,
      d.risk_factor,
      d.price_beta,
      d.vol_beta,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.commkt_key = i.commkt_key and
         d.price_source_code = i.price_source_code and
         d.val_type = i.val_type 

/* AUDIT_CODE_END */  
return
GO
ALTER TABLE [dbo].[varfeed_beta] ADD CONSTRAINT [varfeed_beta_pk] PRIMARY KEY CLUSTERED  ([commkt_key], [price_source_code], [val_type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[varfeed_beta] ADD CONSTRAINT [varfeed_beta_fk1] FOREIGN KEY ([commkt_key]) REFERENCES [dbo].[commodity_market] ([commkt_key])
GO
ALTER TABLE [dbo].[varfeed_beta] ADD CONSTRAINT [varfeed_beta_fk2] FOREIGN KEY ([price_source_code]) REFERENCES [dbo].[price_source] ([price_source_code])
GO
GRANT DELETE ON  [dbo].[varfeed_beta] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[varfeed_beta] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[varfeed_beta] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[varfeed_beta] TO [next_usr]
GO
