CREATE TABLE [dbo].[acct_bookcomp_collatera]
(
[acct_collat_num] [int] NOT NULL,
[mca_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__acct_book__mca_i__403A8C7D] DEFAULT ('N'),
[mca_eff_date] [datetime] NULL,
[net_pay_agree_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__acct_book__net_p__4222D4EF] DEFAULT ('N'),
[net_out_agree_eff_date] [datetime] NULL,
[net_out_cont_num] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[isda_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__acct_book__isda___440B1D61] DEFAULT ('N'),
[isda_eff_date] [datetime] NULL,
[acct_bookcomp_key] [int] NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[acct_bookcomp_collatera_deltrg]
on [dbo].[acct_bookcomp_collatera]
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
   select @errmsg = '(acct_bookcomp_collatera) Failed to obtain a valid responsible trans_id. '
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

insert dbo.aud_acct_bookcomp_collatera
(  
   acct_collat_num,
   mca_ind,
   mca_eff_date,
   net_pay_agree_ind,
   net_out_agree_eff_date,
   net_out_cont_num,
   isda_ind,
   isda_eff_date,
   acct_bookcomp_key,
   trans_id,
   resp_trans_id
)
select
   d.acct_collat_num,
   d.mca_ind,
   d.mca_eff_date,
   d.net_pay_agree_ind,
   d.net_out_agree_eff_date,
   d.net_out_cont_num,
   d.isda_ind,
   d.isda_eff_date,
   d.acct_bookcomp_key,
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

create trigger [dbo].[acct_bookcomp_collatera_updtrg]
on [dbo].[acct_bookcomp_collatera]
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
   raiserror ('(acct_bookcomp_collatera) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(acct_bookcomp_collatera) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_collat_num = d.acct_collat_num)
begin
   select @errmsg = '(acct_bookcomp_collatera) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.acct_collat_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,10,1)
   return
end

/* RECORD_STAMP_END */

if update(acct_collat_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_collat_num = d.acct_collat_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(acct_bookcomp_collatera) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_acct_bookcomp_collatera
 	    (acct_collat_num,
       mca_ind,
       mca_eff_date,
       net_pay_agree_ind,
       net_out_agree_eff_date,
       net_out_cont_num,
       isda_ind,
       isda_eff_date,
       acct_bookcomp_key,
       trans_id,
       resp_trans_id)
   select
 	    d.acct_collat_num,
      d.mca_ind,
      d.mca_eff_date,
      d.net_pay_agree_ind,
      d.net_out_agree_eff_date,
      d.net_out_cont_num,
      d.isda_ind,
      d.isda_eff_date,
      d.acct_bookcomp_key,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_collat_num = i.acct_collat_num 

return
GO
ALTER TABLE [dbo].[acct_bookcomp_collatera] ADD CONSTRAINT [CK__acct_book__isda___44FF419A] CHECK (([isda_ind]='N' OR [isda_ind]='Y'))
GO
ALTER TABLE [dbo].[acct_bookcomp_collatera] ADD CONSTRAINT [CK__acct_book__mca_i__412EB0B6] CHECK (([mca_ind]='N' OR [mca_ind]='Y'))
GO
ALTER TABLE [dbo].[acct_bookcomp_collatera] ADD CONSTRAINT [CK__acct_book__net_p__4316F928] CHECK (([net_pay_agree_ind]='N' OR [net_pay_agree_ind]='Y'))
GO
ALTER TABLE [dbo].[acct_bookcomp_collatera] ADD CONSTRAINT [acct_bookcomp_collatera_pk] PRIMARY KEY CLUSTERED  ([acct_collat_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[acct_bookcomp_collatera] ADD CONSTRAINT [acct_bookcomp_collatera_fk1] FOREIGN KEY ([acct_bookcomp_key]) REFERENCES [dbo].[acct_bookcomp] ([acct_bookcomp_key])
GO
GRANT DELETE ON  [dbo].[acct_bookcomp_collatera] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[acct_bookcomp_collatera] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[acct_bookcomp_collatera] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[acct_bookcomp_collatera] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'acct_bookcomp_collatera', NULL, NULL
GO
