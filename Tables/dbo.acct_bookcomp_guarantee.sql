CREATE TABLE [dbo].[acct_bookcomp_guarantee]
(
[acct_guarantee_num] [int] NOT NULL,
[acct_bookcomp_key] [int] NOT NULL,
[guarantee_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_acct_bookcomp_guarantee_guarantee_type] DEFAULT ('PCG'),
[order_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_acct_bookcomp_guarantee_order_type_code] DEFAULT ('PHYSICAL'),
[guarantee_amt] [numeric] (20, 8) NOT NULL,
[guarantee_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[guarantee_direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_acct_bookcomp_guarantee_guarantee_direction] DEFAULT ('I'),
[guarantor_acct_num] [int] NULL,
[eff_date] [datetime] NOT NULL,
[maturity_date] [datetime] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[acct_bookcomp_guarantee_deltrg]
on [dbo].[acct_bookcomp_guarantee]
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
   select @errmsg = '(acct_bookcomp_guarantee) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_acct_bookcomp_guarantee
(  
   acct_guarantee_num,
   acct_bookcomp_key,
   guarantee_type,
   order_type_code,
   guarantee_amt,
   guarantee_curr_code,
   guarantee_direction,
   guarantor_acct_num,
   eff_date,
   maturity_date,
   trans_id,
   resp_trans_id
)
select
   d.acct_guarantee_num,
   d.acct_bookcomp_key,
   d.guarantee_type,
   d.order_type_code,
   d.guarantee_amt,
   d.guarantee_curr_code,
   d.guarantee_direction,
   d.guarantor_acct_num,
   d.eff_date,
   d.maturity_date,
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

create trigger [dbo].[acct_bookcomp_guarantee_updtrg]
on [dbo].[acct_bookcomp_guarantee]
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
   raiserror ('(acct_bookcomp_guarantee) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(acct_bookcomp_guarantee) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_guarantee_num = d.acct_guarantee_num)
begin
   select @errmsg = '(acct_bookcomp_guarantee) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.acct_guarantee_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(acct_guarantee_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_guarantee_num = d.acct_guarantee_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(acct_bookcomp_guarantee) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_acct_bookcomp_guarantee
      (acct_guarantee_num,
       acct_bookcomp_key,
       guarantee_type,
       order_type_code,
       guarantee_amt,
       guarantee_curr_code,
       guarantee_direction,
       guarantor_acct_num,
       eff_date,
       maturity_date,
       trans_id,
       resp_trans_id)
   select
      d.acct_guarantee_num,
      d.acct_bookcomp_key,
      d.guarantee_type,
      d.order_type_code,
      d.guarantee_amt,
      d.guarantee_curr_code,
      d.guarantee_direction,
      d.guarantor_acct_num,
      d.eff_date,
      d.maturity_date,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_guarantee_num = i.acct_guarantee_num 

return
GO
ALTER TABLE [dbo].[acct_bookcomp_guarantee] ADD CONSTRAINT [chk_acct_bookcomp_guarantee_guarantee_direction] CHECK (([guarantee_direction]='O' OR [guarantee_direction]='I'))
GO
ALTER TABLE [dbo].[acct_bookcomp_guarantee] ADD CONSTRAINT [chk_acct_bookcomp_guarantee_guarantee_type] CHECK (([guarantee_type]='COMFORTLETTER' OR [guarantee_type]='PCG'))
GO
ALTER TABLE [dbo].[acct_bookcomp_guarantee] ADD CONSTRAINT [chk_acct_bookcomp_guarantee_order_type_code] CHECK (([order_type_code]='DERIVATI' OR [order_type_code]='PHYSICAL'))
GO
ALTER TABLE [dbo].[acct_bookcomp_guarantee] ADD CONSTRAINT [acct_bookcomp_guarantee_pk] PRIMARY KEY CLUSTERED  ([acct_guarantee_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[acct_bookcomp_guarantee] ADD CONSTRAINT [acct_bookcomp_guarantee_fk1] FOREIGN KEY ([acct_bookcomp_key]) REFERENCES [dbo].[acct_bookcomp] ([acct_bookcomp_key])
GO
ALTER TABLE [dbo].[acct_bookcomp_guarantee] ADD CONSTRAINT [acct_bookcomp_guarantee_fk2] FOREIGN KEY ([guarantee_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[acct_bookcomp_guarantee] ADD CONSTRAINT [acct_bookcomp_guarantee_fk3] FOREIGN KEY ([guarantor_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
GRANT DELETE ON  [dbo].[acct_bookcomp_guarantee] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[acct_bookcomp_guarantee] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[acct_bookcomp_guarantee] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[acct_bookcomp_guarantee] TO [next_usr]
GO
