CREATE TABLE [dbo].[allocation_world_scale]
(
[alloc_num] [int] NOT NULL,
[origin_load_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[origin_del_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[origin_scale_rate] [float] NOT NULL,
[origin_scale_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[new_load_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[new_del_loc] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[new_scale_rate] [float] NOT NULL,
[new_scale_rate_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[charter_party_rate] [float] NOT NULL,
[charter_party_min] [float] NULL,
[actual_qty] [float] NOT NULL,
[due_date] [datetime] NULL,
[acct_num] [int] NOT NULL,
[book_comp_num] [int] NULL,
[pay_rec_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_allocation_world_scale_pay_rec_ind] DEFAULT ('P'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[allocation_world_scale_deltrg]
on [dbo].[allocation_world_scale]
for delete
as
declare @num_rows   int,
        @errmsg     varchar(255),
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
   select @errmsg = '(allocation_world_scale) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_allocation_world_scale
   (alloc_num,
    origin_load_loc,
    origin_del_loc,
    origin_scale_rate,
    origin_scale_rate_curr_code,
    new_load_loc,
    new_del_loc,
    new_scale_rate, 
    new_scale_rate_curr_code,
    charter_party_rate,
    charter_party_min,
    actual_qty,
    due_date,
    acct_num,
    book_comp_num,
    pay_rec_ind,
    trans_id,
    resp_trans_id)
select
   d.alloc_num,
   d.origin_load_loc,
   d.origin_del_loc,
   d.origin_scale_rate,
   d.origin_scale_rate_curr_code,
   d.new_load_loc,
   d.new_del_loc,
   d.new_scale_rate, 
   d.new_scale_rate_curr_code,
   d.charter_party_rate,
   d.charter_party_min,
   d.actual_qty,
   d.due_date,
   d.acct_num,
   d.book_comp_num,
   d.pay_rec_ind,
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

create trigger [dbo].[allocation_world_scale_updtrg]
on [dbo].[allocation_world_scale]
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
   raiserror ('(allocation_world_scale) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(allocation_world_scale) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.alloc_num = d.alloc_num )
begin
   raiserror ('(allocation_world_scale) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(alloc_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.alloc_num = d.alloc_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(allocation_world_scale) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_allocation_world_scale
      (alloc_num,
       origin_load_loc,
       origin_del_loc,
       origin_scale_rate,
       origin_scale_rate_curr_code,
       new_load_loc,
       new_del_loc,
       new_scale_rate, 
       new_scale_rate_curr_code,
       charter_party_rate,
       charter_party_min,
       actual_qty,
       due_date,
       acct_num,
       book_comp_num,
       pay_rec_ind,
       trans_id,
       resp_trans_id)
    select
       d.alloc_num,
       d.origin_load_loc,
       d.origin_del_loc,
       d.origin_scale_rate,
       d.origin_scale_rate_curr_code,
       d.new_load_loc,
       d.new_del_loc,
       d.new_scale_rate, 
       d.new_scale_rate_curr_code,
       d.charter_party_rate,
       d.charter_party_min,
       d.actual_qty,
       d.due_date,
       d.acct_num,
       d.book_comp_num,
       d.pay_rec_ind,
       d.trans_id,
       i.trans_id
    from deleted d, inserted i
    where d.alloc_num = i.alloc_num

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[allocation_world_scale] ADD CONSTRAINT [chk_allocation_world_scale_pay_rec_ind] CHECK (([pay_rec_ind]='R' OR [pay_rec_ind]='P'))
GO
ALTER TABLE [dbo].[allocation_world_scale] ADD CONSTRAINT [allocation_world_scale_pk] PRIMARY KEY CLUSTERED  ([alloc_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation_world_scale] ADD CONSTRAINT [allocation_world_scale_fk2] FOREIGN KEY ([acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation_world_scale] ADD CONSTRAINT [allocation_world_scale_fk3] FOREIGN KEY ([book_comp_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[allocation_world_scale] ADD CONSTRAINT [allocation_world_scale_fk4] FOREIGN KEY ([origin_load_loc]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation_world_scale] ADD CONSTRAINT [allocation_world_scale_fk5] FOREIGN KEY ([origin_del_loc]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation_world_scale] ADD CONSTRAINT [allocation_world_scale_fk6] FOREIGN KEY ([new_load_loc]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation_world_scale] ADD CONSTRAINT [allocation_world_scale_fk7] FOREIGN KEY ([new_del_loc]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[allocation_world_scale] ADD CONSTRAINT [allocation_world_scale_fk8] FOREIGN KEY ([origin_scale_rate_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[allocation_world_scale] ADD CONSTRAINT [allocation_world_scale_fk9] FOREIGN KEY ([new_scale_rate_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[allocation_world_scale] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[allocation_world_scale] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[allocation_world_scale] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[allocation_world_scale] TO [next_usr]
GO
