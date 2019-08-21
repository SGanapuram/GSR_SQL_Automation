CREATE TABLE [dbo].[paper_allocation]
(
[paper_alloc_num] [int] NOT NULL,
[pos_num] [int] NOT NULL,
[alloc_date] [datetime] NOT NULL,
[alloc_pl] [float] NULL,
[alloc_pl_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_pl_calc_date] [datetime] NULL,
[alloc_pl_asof_date] [datetime] NULL,
[alloc_brokerage_cost] [float] NULL,
[paper_alloc_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[paper_allocation_deltrg]
on [dbo].[paper_allocation]
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
   select @errmsg = '(paper_allocation) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_paper_allocation
   (paper_alloc_num,
    pos_num,
    alloc_date,
    alloc_pl,
    alloc_pl_curr_code,
    alloc_pl_calc_date,
    alloc_pl_asof_date,
    alloc_brokerage_cost,
    paper_alloc_status,
    trans_id,
    resp_trans_id)
select
   d.paper_alloc_num,
   d.pos_num,
   d.alloc_date,
   d.alloc_pl,
   d.alloc_pl_curr_code,
   d.alloc_pl_calc_date,
   d.alloc_pl_asof_date,
   d.alloc_brokerage_cost,
   d.paper_alloc_status,
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

create trigger [dbo].[paper_allocation_updtrg]
on [dbo].[paper_allocation]
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
   raiserror ('(paper_allocation) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(paper_allocation) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.paper_alloc_num = d.paper_alloc_num )
begin
   raiserror ('(paper_allocation) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(paper_alloc_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.paper_alloc_num = d.paper_alloc_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(paper_allocation) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_paper_allocation
      (paper_alloc_num,
       pos_num,
       alloc_date,
       alloc_pl,
       alloc_pl_curr_code,
       alloc_pl_calc_date,
       alloc_pl_asof_date,
       alloc_brokerage_cost,
       paper_alloc_status,
       trans_id,
       resp_trans_id)
   select
      d.paper_alloc_num,
      d.pos_num,
      d.alloc_date,
      d.alloc_pl,
      d.alloc_pl_curr_code,
      d.alloc_pl_calc_date,
      d.alloc_pl_asof_date,
      d.alloc_brokerage_cost,
      d.paper_alloc_status,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.paper_alloc_num = i.paper_alloc_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[paper_allocation] ADD CONSTRAINT [paper_allocation_pk] PRIMARY KEY CLUSTERED  ([paper_alloc_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [paper_allocation_idx1] ON [dbo].[paper_allocation] ([alloc_date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paper_allocation] ADD CONSTRAINT [paper_allocation_fk1] FOREIGN KEY ([alloc_pl_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[paper_allocation] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[paper_allocation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[paper_allocation] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[paper_allocation] TO [next_usr]
GO
