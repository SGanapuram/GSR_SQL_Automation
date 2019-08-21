CREATE TABLE [dbo].[quote_price_term]
(
[qpt_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[qpt_term_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[dept_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qpt_pricing_days] [smallint] NULL,
[qpt_price_cal_days_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qpt_start_end_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qpt_relative_days] [smallint] NULL,
[qpt_rel_price_cal_days_ind] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qpt_roll_accum_prd_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[quote_price_term_deltrg]
on [dbo].[quote_price_term]
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
   select @errmsg = '(quote_price_term) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_quote_price_term
   (qpt_term_code,
    qpt_term_desc,
    dept_code,
    qpt_pricing_days,
    qpt_price_cal_days_ind,
    qpt_start_end_ind,
    qpt_relative_days,
    qpt_rel_price_cal_days_ind,
    qpt_roll_accum_prd_ind,
    trans_id,
    resp_trans_id)
select
   d.qpt_term_code,
   d.qpt_term_desc,
   d.dept_code,
   d.qpt_pricing_days,
   d.qpt_price_cal_days_ind,
   d.qpt_start_end_ind,
   d.qpt_relative_days,
   d.qpt_rel_price_cal_days_ind,
   d.qpt_roll_accum_prd_ind,
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

create trigger [dbo].[quote_price_term_updtrg]
on [dbo].[quote_price_term]
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
   raiserror ('(quote_price_term) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(quote_price_term) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.qpt_term_code = d.qpt_term_code )
begin
   raiserror ('(quote_price_term) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(qpt_term_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.qpt_term_code = d.qpt_term_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(quote_price_term) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_quote_price_term
      (qpt_term_code,
       qpt_term_desc,
       dept_code,
       qpt_pricing_days,
       qpt_price_cal_days_ind,
       qpt_start_end_ind,
       qpt_relative_days,
       qpt_rel_price_cal_days_ind,
       qpt_roll_accum_prd_ind,
       trans_id,
       resp_trans_id)
   select
      d.qpt_term_code,
      d.qpt_term_desc,
      d.dept_code,
      d.qpt_pricing_days,
      d.qpt_price_cal_days_ind,
      d.qpt_start_end_ind,
      d.qpt_relative_days,
      d.qpt_rel_price_cal_days_ind,
      d.qpt_roll_accum_prd_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.qpt_term_code = i.qpt_term_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[quote_price_term] ADD CONSTRAINT [quote_price_term_pk] PRIMARY KEY CLUSTERED  ([qpt_term_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[quote_price_term] ADD CONSTRAINT [quote_price_term_fk1] FOREIGN KEY ([dept_code]) REFERENCES [dbo].[department] ([dept_code])
GO
GRANT DELETE ON  [dbo].[quote_price_term] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[quote_price_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[quote_price_term] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[quote_price_term] TO [next_usr]
GO
