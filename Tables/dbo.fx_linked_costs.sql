CREATE TABLE [dbo].[fx_linked_costs]
(
[fx_link_oid] [int] NOT NULL,
[cost_num] [int] NOT NULL,
[curr_cost_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_linked_costs_deltrg]
on [dbo].[fx_linked_costs]
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
   select @errmsg = '(fx_linked_costs) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_fx_linked_costs
   (fx_link_oid,
    cost_num,
    curr_cost_ind,
    trans_id,
    resp_trans_id)
select
    d.fx_link_oid,
    d.cost_num,
    d.curr_cost_ind,
    d.trans_id,
    @atrans_id 
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'FxLinkedCosts',
       'DIRECT',
       convert(varchar(40), d.fx_link_oid),
       convert(varchar(40), d.cost_num),
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from deleted d, dbo.icts_transaction it
where it.trans_id = @atrans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_linked_costs_instrg]
on [dbo].[fx_linked_costs]
for insert
as
declare @num_rows       int,
        @count_num_rows int,
        @errmsg         varchar(255)

select @num_rows = @@rowcount
if @num_rows = 0
   return

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'INSERT',
       'FxLinkedCosts',
       'DIRECT',
       convert(varchar(40), i.fx_link_oid),
       convert(varchar(40), i.cost_num),
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_linked_costs_updtrg]
on [dbo].[fx_linked_costs]
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
   raiserror ('(fx_linked_costs) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(fx_linked_costs) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.fx_link_oid = d.fx_link_oid and
                 i.cost_num = d.cost_num )
begin
   raiserror ('(fx_linked_costs) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(fx_link_oid) or
   update(cost_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.fx_link_oid = d.fx_link_oid and
                                   i.cost_num = d.cost_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(fx_linked_costs) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_fx_linked_costs
      (fx_link_oid,
       cost_num,
       curr_cost_ind,
       trans_id,
       resp_trans_id)
   select
       d.fx_link_oid,
       d.cost_num,
       d.curr_cost_ind,
       d.trans_id,
       i.trans_id 
   from deleted d, inserted i
   where i.fx_link_oid = d.fx_link_oid and
         i.cost_num = d.cost_num 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FxLinkedCosts',
       'DIRECT',
       convert(varchar(40), i.fx_link_oid),
       convert(varchar(40), i.cost_num),
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from inserted i, dbo.icts_transaction it
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

return
GO
ALTER TABLE [dbo].[fx_linked_costs] ADD CONSTRAINT [chk_fx_linked_costs_curr_cost_ind] CHECK (([curr_cost_ind]='N' OR [curr_cost_ind]='C'))
GO
ALTER TABLE [dbo].[fx_linked_costs] ADD CONSTRAINT [fx_linked_costs_pk] PRIMARY KEY CLUSTERED  ([fx_link_oid], [cost_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fx_linked_costs] ADD CONSTRAINT [fx_linked_costs_fk1] FOREIGN KEY ([fx_link_oid]) REFERENCES [dbo].[fx_linking] ([oid])
GO
GRANT DELETE ON  [dbo].[fx_linked_costs] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fx_linked_costs] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fx_linked_costs] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fx_linked_costs] TO [next_usr]
GO
