CREATE TABLE [dbo].[otc_option_value]
(
[otc_opt_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[otc_opt_quote_date] [datetime] NOT NULL,
[otc_opt_price] [float] NULL,
[otc_opt_delta] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[otc_option_value_deltrg]
on [dbo].[otc_option_value]
for delete
as
declare @num_rows    int,
        @errmsg      varchar(255),
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
   select @errmsg = '(otc_option_value) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_otc_option_value
   (otc_opt_code,
    otc_opt_quote_date,
    otc_opt_price,
    otc_opt_delta,
    trans_id,
    resp_trans_id)
select
   d.otc_opt_code,
   d.otc_opt_quote_date,
   d.otc_opt_price,
   d.otc_opt_delta,
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

create trigger [dbo].[otc_option_value_updtrg]
on [dbo].[otc_option_value]
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
   raiserror ('(otc_option_value) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(otc_option_value) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.otc_opt_code = d.otc_opt_code and 
                 i.otc_opt_quote_date = d.otc_opt_quote_date )
begin
   raiserror ('(otc_option_value) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(otc_opt_code) or  
   update(otc_opt_quote_date) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.otc_opt_code = d.otc_opt_code and 
                                   i.otc_opt_quote_date = d.otc_opt_quote_date )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(otc_option_value) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_otc_option_value
      (otc_opt_code,
       otc_opt_quote_date,
       otc_opt_price,
       otc_opt_delta,
       trans_id,
       resp_trans_id)
   select
      d.otc_opt_code,
      d.otc_opt_quote_date,
      d.otc_opt_price,
      d.otc_opt_delta,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.otc_opt_code = i.otc_opt_code and
         d.otc_opt_quote_date = i.otc_opt_quote_date 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[otc_option_value] ADD CONSTRAINT [otc_option_value_pk] PRIMARY KEY CLUSTERED  ([otc_opt_code], [otc_opt_quote_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[otc_option_value] ADD CONSTRAINT [otc_option_value_fk1] FOREIGN KEY ([otc_opt_code]) REFERENCES [dbo].[otc_option] ([otc_opt_code])
GO
GRANT DELETE ON  [dbo].[otc_option_value] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[otc_option_value] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[otc_option_value] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[otc_option_value] TO [next_usr]
GO
