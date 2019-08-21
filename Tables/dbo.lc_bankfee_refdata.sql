CREATE TABLE [dbo].[lc_bankfee_refdata]
(
[oid] [int] NOT NULL,
[lc_type_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[lc_exp_imp_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_lc_bankfee_refdata_lc_exp_imp_ind] DEFAULT ('I'),
[book_comp_num] [int] NOT NULL,
[issuing_bank] [int] NOT NULL,
[lc_bankfee_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_lc_bankfee_refdata_lc_bankfee_type] DEFAULT ('F'),
[lc_bankfee_amt] [decimal] (20, 8) NOT NULL,
[lc_bankfee_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_bankfee_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_lc_bankfee_refdata_lc_bankfee_status] DEFAULT ('A'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[lc_bankfee_refdata_deltrg]
on [dbo].[lc_bankfee_refdata]
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
   select @errmsg = '(lc_bankfee_refdata) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_lc_bankfee_refdata
(  
   oid,     
   lc_type_code,     
   lc_exp_imp_ind,     
   book_comp_num,	
   issuing_bank,	
   lc_bankfee_type,
   lc_bankfee_amt,
   lc_bankfee_curr_code,
   lc_bankfee_status,
   trans_id,
   resp_trans_id
)
select
   d.oid,     
   d.lc_type_code,     
   d.lc_exp_imp_ind,     
   d.book_comp_num,	
   d.issuing_bank,	
   d.lc_bankfee_type,
   d.lc_bankfee_amt,
   d.lc_bankfee_curr_code,
   d.lc_bankfee_status,
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

create trigger [dbo].[lc_bankfee_refdata_updtrg]
on [dbo].[lc_bankfee_refdata]
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
   raiserror ('(lc_bankfee_refdata) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(lc_bankfee_refdata) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(lc_bankfee_refdata) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(lc_bankfee_refdata) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_lc_bankfee_refdata
 	    (oid,    
         lc_type_code,     
         lc_exp_imp_ind,     
         book_comp_num,	
         issuing_bank,	
         lc_bankfee_type,
         lc_bankfee_amt,
         lc_bankfee_curr_code,
         lc_bankfee_status,
         trans_id,
         resp_trans_id)
   select
 	  d.oid,
      d.lc_type_code,     
      d.lc_exp_imp_ind,     
      d.book_comp_num,	
      d.issuing_bank,	
      d.lc_bankfee_type,
      d.lc_bankfee_amt,
      d.lc_bankfee_curr_code,
      d.lc_bankfee_status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 
   
return
GO
ALTER TABLE [dbo].[lc_bankfee_refdata] ADD CONSTRAINT [chk_lc_bankfee_refdata_lc_bankfee_status] CHECK (([lc_bankfee_status]='I' OR [lc_bankfee_status]='A'))
GO
ALTER TABLE [dbo].[lc_bankfee_refdata] ADD CONSTRAINT [chk_lc_bankfee_refdata_lc_bankfee_type] CHECK (([lc_bankfee_type]='R' OR [lc_bankfee_type]='F'))
GO
ALTER TABLE [dbo].[lc_bankfee_refdata] ADD CONSTRAINT [chk_lc_bankfee_refdata_lc_exp_imp_ind] CHECK (([lc_exp_imp_ind]='I' OR [lc_exp_imp_ind]='E'))
GO
ALTER TABLE [dbo].[lc_bankfee_refdata] ADD CONSTRAINT [lc_bankfee_refdata_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lc_bankfee_refdata] ADD CONSTRAINT [lc_bankfee_refdata_fk1] FOREIGN KEY ([lc_type_code]) REFERENCES [dbo].[lc_type] ([lc_type_code])
GO
ALTER TABLE [dbo].[lc_bankfee_refdata] ADD CONSTRAINT [lc_bankfee_refdata_fk2] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc_bankfee_refdata] ADD CONSTRAINT [lc_bankfee_refdata_fk3] FOREIGN KEY ([issuing_bank]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[lc_bankfee_refdata] ADD CONSTRAINT [lc_bankfee_refdata_fk4] FOREIGN KEY ([lc_bankfee_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[lc_bankfee_refdata] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[lc_bankfee_refdata] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[lc_bankfee_refdata] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[lc_bankfee_refdata] TO [next_usr]
GO
