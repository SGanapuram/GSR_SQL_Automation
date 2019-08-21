CREATE TABLE [dbo].[allocation_insp]
(
[alloc_num] [int] NOT NULL,
[insp_comp_num] [int] NOT NULL,
[insp_comp_short_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[insp_fee_split_count] [tinyint] NOT NULL,
[insp_fee_amt] [float] NOT NULL,
[insp_fee_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[insp_fee_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[alloc_insp_short_cmnt] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_insp_deltrg]
on [dbo].[allocation_insp]
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
   select @errmsg = '(allocation_insp) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_allocation_insp
   (alloc_num,
    insp_comp_num,
    insp_comp_short_name,
    insp_fee_split_count,
    insp_fee_amt,
    insp_fee_uom_code,
    insp_fee_curr_code,
    alloc_insp_short_cmnt,
    cmnt_num,
    trans_id,
    resp_trans_id)
select
   d.alloc_num,
   d.insp_comp_num,
   d.insp_comp_short_name,
   d.insp_fee_split_count,
   d.insp_fee_amt,
   d.insp_fee_uom_code,
   d.insp_fee_curr_code,
   d.alloc_insp_short_cmnt,
   d.cmnt_num,
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

create trigger [dbo].[allocation_insp_updtrg]
on [dbo].[allocation_insp]
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
   raiserror ('(allocation_insp) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(allocation_insp) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num and 
                 i.insp_comp_num = d.insp_comp_num )
begin
   raiserror ('(allocation_insp) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(alloc_num) or  
   update(insp_comp_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                                where i.alloc_num = d.alloc_num and 
                                      i.insp_comp_num = d.insp_comp_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(allocation_insp) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_allocation_insp
      (alloc_num,
       insp_comp_num,
       insp_comp_short_name,
       insp_fee_split_count,
       insp_fee_amt,
       insp_fee_uom_code,
       insp_fee_curr_code,
       alloc_insp_short_cmnt,
       cmnt_num,
       trans_id,
       resp_trans_id)
   select
      d.alloc_num,
      d.insp_comp_num,
      d.insp_comp_short_name,
      d.insp_fee_split_count,
      d.insp_fee_amt,
      d.insp_fee_uom_code,
      d.insp_fee_curr_code,
      d.alloc_insp_short_cmnt,
      d.cmnt_num,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.alloc_num = i.alloc_num and
         d.insp_comp_num = i.insp_comp_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[allocation_insp] ADD CONSTRAINT [allocation_insp_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [insp_comp_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation_insp] ADD CONSTRAINT [allocation_insp_fk1] FOREIGN KEY ([insp_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation_insp] ADD CONSTRAINT [allocation_insp_fk4] FOREIGN KEY ([insp_fee_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[allocation_insp] ADD CONSTRAINT [allocation_insp_fk5] FOREIGN KEY ([insp_fee_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[allocation_insp] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation_insp] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation_insp] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation_insp] TO [next_usr]
GO
