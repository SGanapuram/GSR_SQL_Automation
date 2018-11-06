CREATE TABLE [dbo].[formula_comp_price_term]
(
[formula_num] [int] NOT NULL,
[formula_body_num] [tinyint] NOT NULL,
[formula_comp_num] [smallint] NOT NULL,
[qpt_term_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[fcpt_pricing_days] [smallint] NULL,
[fcpt_price_cal_days_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fcpt_start_end_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fcpt_relative_days] [smallint] NULL,
[fcpt_rel_price_cal_days_ind] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fcpt_roll_accum_prd_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[formula_comp_price_term_deltrg]
on [dbo].[formula_comp_price_term]
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
   select @errmsg = '(formula_comp_price_term) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_formula_comp_price_term
   (formula_num,
    formula_body_num,
    formula_comp_num,
    qpt_term_code,
    fcpt_pricing_days,
    fcpt_price_cal_days_ind,
    fcpt_start_end_ind,
    fcpt_relative_days,
    fcpt_rel_price_cal_days_ind,
    fcpt_roll_accum_prd_ind,
    trans_id,
    resp_trans_id)
select
   d.formula_num,
   d.formula_body_num,
   d.formula_comp_num,
   d.qpt_term_code,
   d.fcpt_pricing_days,
   d.fcpt_price_cal_days_ind,
   d.fcpt_start_end_ind,
   d.fcpt_relative_days,
   d.fcpt_rel_price_cal_days_ind,
   d.fcpt_roll_accum_prd_ind,
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

create trigger [dbo].[formula_comp_price_term_updtrg]
on [dbo].[formula_comp_price_term]
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
   raiserror ('(formula_comp_price_term) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(formula_comp_price_term) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.formula_num = d.formula_num  and i.formula_body_num = d.formula_body_num  and i.formula_comp_num = d.formula_comp_num )
begin
   raiserror ('(formula_comp_price_term) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(formula_num) or  
   update(formula_body_num) or  
   update(formula_comp_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.formula_num = d.formula_num and 
                                   i.formula_body_num = d.formula_body_num and 
                                   i.formula_comp_num = d.formula_comp_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(formula_comp_price_term) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_formula_comp_price_term
      (formula_num,
       formula_body_num,
       formula_comp_num,
       qpt_term_code,
       fcpt_pricing_days,
       fcpt_price_cal_days_ind,
       fcpt_start_end_ind,
       fcpt_relative_days,
       fcpt_rel_price_cal_days_ind,
       fcpt_roll_accum_prd_ind,
       trans_id,
       resp_trans_id)
   select
      d.formula_num,
      d.formula_body_num,
      d.formula_comp_num,
      d.qpt_term_code,
      d.fcpt_pricing_days,
      d.fcpt_price_cal_days_ind,
      d.fcpt_start_end_ind,
      d.fcpt_relative_days,
      d.fcpt_rel_price_cal_days_ind,
      d.fcpt_roll_accum_prd_ind,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.formula_num = i.formula_num and
         d.formula_body_num = i.formula_body_num and
         d.formula_comp_num = i.formula_comp_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[formula_comp_price_term] ADD CONSTRAINT [formula_comp_price_term_pk] PRIMARY KEY CLUSTERED  ([formula_num], [formula_body_num], [formula_comp_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[formula_comp_price_term] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[formula_comp_price_term] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[formula_comp_price_term] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[formula_comp_price_term] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'formula_comp_price_term', NULL, NULL
GO
