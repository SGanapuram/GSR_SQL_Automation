CREATE TABLE [dbo].[fx_linking]
(
[oid] [int] NOT NULL,
[fx_link_rate] [numeric] (20, 8) NULL,
[fx_rate_m_d_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__fx_linkin__fx_ra__664B26CC] DEFAULT ('M'),
[from_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[to_curr_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[need_rate_computation] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__fx_linkin__need___68336F3E] DEFAULT ('Y'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[fx_linking_deltrg]
on [dbo].[fx_linking]
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
   select @errmsg = '(fx_linking) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_fx_linking
   (oid,
    fx_link_rate,
    fx_rate_m_d_ind,
    from_curr_code,
    to_curr_code,
    need_rate_computation,
    trans_id,
    resp_trans_id)

select
    d.oid,
    d.fx_link_rate,
    d.fx_rate_m_d_ind,
    d.from_curr_code,
    d.to_curr_code,
    d.need_rate_computation,
    d.trans_id,
    @atrans_id 
from deleted d

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       'FxLinking',
       'DIRECT',
       convert(varchar(40), d.oid),
       null,
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

create trigger [dbo].[fx_linking_instrg]
on [dbo].[fx_linking]
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
       'FxLinking',
       'DIRECT',
       convert(varchar(40), i.oid),
       null,
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

create trigger [dbo].[fx_linking_updtrg]
on [dbo].[fx_linking]
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
   raiserror ('(fx_linking) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(fx_linking) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.oid = d.oid )
begin
   raiserror ('(fx_linking) new trans_id must not be older than current trans_id.',10,1)
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
      raiserror ('(fx_linking) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_fx_linking
      (oid,
       fx_link_rate,
       fx_rate_m_d_ind,
       from_curr_code,
       to_curr_code,
       need_rate_computation,
       trans_id,
       resp_trans_id)
   select
       d.oid,
       d.fx_link_rate,
       d.fx_rate_m_d_ind,
       d.from_curr_code,
       d.to_curr_code,
       d.need_rate_computation,
       d.trans_id,
       i.trans_id 
   from deleted d, inserted i
   where d.oid = i.oid 

/* AUDIT_CODE_END */

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'UPDATE',
       'FxLinking',
       'DIRECT',
       convert(varchar(40), i.oid),
       null,
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
ALTER TABLE [dbo].[fx_linking] ADD CONSTRAINT [CK__fx_linkin__fx_ra__673F4B05] CHECK (([fx_rate_m_d_ind]='D' OR [fx_rate_m_d_ind]='M'))
GO
ALTER TABLE [dbo].[fx_linking] ADD CONSTRAINT [CK__fx_linkin__need___69279377] CHECK (([need_rate_computation]='Y' OR [need_rate_computation]='N'))
GO
ALTER TABLE [dbo].[fx_linking] ADD CONSTRAINT [fx_linking_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fx_linking] ADD CONSTRAINT [fx_linking_fk1] FOREIGN KEY ([from_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[fx_linking] ADD CONSTRAINT [fx_linking_fk2] FOREIGN KEY ([to_curr_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
GRANT DELETE ON  [dbo].[fx_linking] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[fx_linking] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[fx_linking] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[fx_linking] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'fx_linking', NULL, NULL
GO
