CREATE TABLE [dbo].[lc_bankfee_autogen]
(
[oid] [int] NOT NULL,
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_exp_imp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__lc_bankfe__lc_ex__6EAB62A3] DEFAULT ('E'),
[book_comp_num] [int] NOT NULL,
[issuing_bank] [int] NOT NULL,
[lc_bankfee_amt_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__lc_bankfe__lc_ba__7093AB15] DEFAULT ('F'),
[lc_bankfee_amt] [decimal] (20, 8) NOT NULL,
[lc_bankfee_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_bankfee_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__lc_bankfe__lc_ba__727BF387] DEFAULT ('A'),
[trans_id] [int] NOT NULL,
[fee_validity_date] [datetime] NULL CONSTRAINT [DF__lc_bankfe__fee_v__74643BF9] DEFAULT ('01/01/2001')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lc_bankfee_autogen_deltrg]
on [dbo].[lc_bankfee_autogen]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
        @atrans_id int

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
   select @errmsg = '(lc_bankfee_autogen) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_lc_bankfee_autogen
(  
   oid,
   lc_type_code,
   lc_exp_imp_ind,
   book_comp_num,
   issuing_bank,
   lc_bankfee_amt_type,  
   lc_bankfee_amt,
   lc_bankfee_curr_code,
   lc_bankfee_status,
   fee_validity_date,
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.lc_type_code,
   d.lc_exp_imp_ind,
   d.book_comp_num,
   d.issuing_bank,
   d.lc_bankfee_amt_type,  
   d.lc_bankfee_amt,
   d.lc_bankfee_curr_code,
   d.lc_bankfee_status,
   d.fee_validity_date,
   d.trans_id,
   @atrans_id
from deleted d

/* AUDIT_CODE_END */
return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lc_bankfee_autogen_instrg]
on [dbo].[lc_bankfee_autogen]
for insert
as
declare @num_rows        int

select @num_rows = @@rowcount
if @num_rows = 0
   return

if exists (select 1
           from inserted 
           where fee_validity_date is null)
begin
   update a
   set fee_validity_date = '01/01/2001'
   from dbo.lc_bankfee_autogen a
           join inserted i
              on a.oid = i.oid
   where i.fee_validity_date is null
end

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lc_bankfee_autogen_updtrg]
on [dbo].[lc_bankfee_autogen]
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

if exists (select 1
           from inserted 
           where fee_validity_date is null)
begin
   update a
   set fee_validity_date = '01/01/2001'
   from dbo.lc_bankfee_autogen a
           join inserted i
              on a.oid = i.oid
   where i.fee_validity_date is null
end

/* added by Peter Lo  Sep-4-2002 */
if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id < deleted.trans_id) > 0
   begin
      select @errmsg = '(lc_bankfee_autogen) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(lc_bankfee_autogen) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.oid) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
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
      raiserror ('(lc_bankfee_autogen) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_lc_bankfee_autogen
 	    (oid,
       lc_type_code,
       lc_exp_imp_ind,
       book_comp_num,
       issuing_bank,
       lc_bankfee_amt_type,  
       lc_bankfee_amt,
       lc_bankfee_curr_code,
       lc_bankfee_status,
       fee_validity_date,
       trans_id,
       resp_trans_id)
   select
 	    d.oid,
      d.lc_type_code,
      d.lc_exp_imp_ind,
      d.book_comp_num,
      d.issuing_bank,
      d.lc_bankfee_amt_type,  
      d.lc_bankfee_amt,
      d.lc_bankfee_curr_code,
      d.lc_bankfee_status,
      isnull(d.fee_validity_date, '01/01/2001'),
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

return
GO
ALTER TABLE [dbo].[lc_bankfee_autogen] ADD CONSTRAINT [CK__lc_bankfe__lc_ba__7187CF4E] CHECK (([lc_bankfee_amt_type]='P' OR [lc_bankfee_amt_type]='F'))
GO
ALTER TABLE [dbo].[lc_bankfee_autogen] ADD CONSTRAINT [CK__lc_bankfe__lc_ba__737017C0] CHECK (([lc_bankfee_status]='I' OR [lc_bankfee_status]='A'))
GO
ALTER TABLE [dbo].[lc_bankfee_autogen] ADD CONSTRAINT [CK__lc_bankfe__lc_ex__6F9F86DC] CHECK (([lc_exp_imp_ind]='I' OR [lc_exp_imp_ind]='E'))
GO
ALTER TABLE [dbo].[lc_bankfee_autogen] ADD CONSTRAINT [lc_bankfee_autogen_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lc_bankfee_autogen] ADD CONSTRAINT [lc_bankfee_autogen_fk1] FOREIGN KEY ([lc_type_code]) REFERENCES [dbo].[lc_type] ([lc_type_code])
GO
ALTER TABLE [dbo].[lc_bankfee_autogen] ADD CONSTRAINT [lc_bankfee_autogen_fk2] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc_bankfee_autogen] ADD CONSTRAINT [lc_bankfee_autogen_fk3] FOREIGN KEY ([issuing_bank]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc_bankfee_autogen] ADD CONSTRAINT [lc_bankfee_autogen_fk4] FOREIGN KEY ([lc_bankfee_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[lc_bankfee_autogen] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[lc_bankfee_autogen] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[lc_bankfee_autogen] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[lc_bankfee_autogen] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'lc_bankfee_autogen', NULL, NULL
GO
