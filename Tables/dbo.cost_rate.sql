CREATE TABLE [dbo].[cost_rate]
(
[oid] [int] NOT NULL,
[cost_num] [int] NOT NULL,
[rate] [decimal] (20, 8) NOT NULL,
[rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rate_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[effective_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[formula_num] [int] NULL,
[formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[factor] [decimal] (20, 8) NULL,
[is_fully_priced] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[formula_cost_num] [int] NULL,
[librarary_formula_num] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_rate_deltrg]
on [dbo].[cost_rate]
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
   select @errmsg = '(cost_rate) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_cost_rate
(
   oid,
   cost_num,
   rate,
   rate_curr_code,
   rate_uom_code,
   effective_date,   
   formula_num,
   formula_ind,
   factor,
   is_fully_priced,
   formula_cost_num,
   librarary_formula_num,
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.cost_num,
   d.rate,
   d.rate_curr_code,
   d.rate_uom_code,
   d.effective_date,
   d.formula_num,
   d.formula_ind,
   d.factor,
   d.is_fully_priced,
   d.formula_cost_num,
   d.librarary_formula_num,   
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

create trigger [dbo].[cost_rate_updtrg]
on [dbo].[cost_rate]
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
   raiserror ('(cost_rate) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(cost_rate) New trans_id must be larger than original trans_id.'
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
   raiserror ('(cost_rate) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(oid) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.oid = d.oid )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost_rate) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_cost_rate
   (
      oid,
      cost_num,
      rate,
      rate_curr_code,
      rate_uom_code,
      effective_date,
      formula_num,
      formula_ind,
      factor,
      is_fully_priced,
      formula_cost_num,
      librarary_formula_num,
      trans_id,
      resp_trans_id
   )
   select 
      d.oid,
      d.cost_num,
      d.rate,
      d.rate_curr_code,
      d.rate_uom_code,
      d.effective_date,
      d.formula_num,
      d.formula_ind,
      d.factor,
      d.is_fully_priced,
      d.formula_cost_num,
      d.librarary_formula_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[cost_rate] ADD CONSTRAINT [chk_cost_rate_formula_ind] CHECK (([formula_ind]=NULL OR [formula_ind]='N' OR [formula_ind]='Y'))
GO
ALTER TABLE [dbo].[cost_rate] ADD CONSTRAINT [chk_cost_rate_is_fully_priced] CHECK (([is_fully_priced]=NULL OR [is_fully_priced]='N' OR [is_fully_priced]='Y'))
GO
ALTER TABLE [dbo].[cost_rate] ADD CONSTRAINT [cost_rate_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cost_rate] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_rate] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_rate] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_rate] TO [next_usr]
GO
