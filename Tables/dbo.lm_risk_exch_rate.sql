CREATE TABLE [dbo].[lm_risk_exch_rate]
(
[exch_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[quote_date] [datetime] NOT NULL,
[from_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[to_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[exch_rate] [decimal] (20, 8) NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lm_risk_exch_rate_deltrg]
on [dbo].[lm_risk_exch_rate]
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
   select @errmsg = '(lm_risk_exch_rate) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_lm_risk_exch_rate
(  
   exch_code,
   quote_date,
   from_curr_code,
   to_curr_code,
   exch_rate,
   trans_id,
   resp_trans_id
)
select
   d.exch_code,
   d.quote_date,
   d.from_curr_code,
   d.to_curr_code,
   d.exch_rate,
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

create trigger [dbo].[lm_risk_exch_rate_updtrg]
on [dbo].[lm_risk_exch_rate]
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
   raiserror ('(lm_risk_exch_rate) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(lm_risk_exch_rate) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.exch_code = d.exch_code and
                 i.quote_date = d.quote_date and
		             i.from_curr_code = d.from_curr_code and
		             i.to_curr_code = d.to_curr_code)
begin
   select @errmsg = '(lm_risk_exch_rate) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (''' + i.exch_code + ''',''' +  convert(varchar, i.quote_date, 101) + ''',''' +  i.from_curr_code + ''',''' + i.to_curr_code + ''')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(exch_code) or
   update(quote_date) or
   update(from_curr_code) or
   update(to_curr_code)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.exch_code = d.exch_code and
                                   i.quote_date = d.quote_date and
				                           i.from_curr_code = d.from_curr_code and
				                           i.to_curr_code = d.to_curr_code)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(lm_risk_exch_rate) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_lm_risk_exch_rate
 	    (exch_code,
	     quote_date,
       from_curr_code,
       to_curr_code,
       exch_rate,
	     trans_id,
       resp_trans_id)
   select
     	d.exch_code,
	    d.quote_date,
	    d.from_curr_code,
	    d.to_curr_code,
	    d.exch_rate,
	    d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.exch_code = i.exch_code and
         d.quote_date = i.quote_date and
	       d.from_curr_code = i.from_curr_code and
	       d.to_curr_code = i.to_curr_code

return
GO
ALTER TABLE [dbo].[lm_risk_exch_rate] ADD CONSTRAINT [lm_risk_exch_rate_pk] PRIMARY KEY CLUSTERED  ([exch_code], [quote_date], [from_curr_code], [to_curr_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lm_risk_exch_rate] ADD CONSTRAINT [lm_risk_exch_rate_fk1] FOREIGN KEY ([from_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[lm_risk_exch_rate] ADD CONSTRAINT [lm_risk_exch_rate_fk2] FOREIGN KEY ([to_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[lm_risk_exch_rate] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[lm_risk_exch_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[lm_risk_exch_rate] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[lm_risk_exch_rate] TO [next_usr]
GO
