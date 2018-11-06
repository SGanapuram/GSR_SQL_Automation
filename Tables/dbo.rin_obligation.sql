CREATE TABLE [dbo].[rin_obligation]
(
[oid] [int] NOT NULL,
[mf_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rin_cmdty_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[obligation_ratio] [numeric] (20, 8) NOT NULL,
[mf_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[rin_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__rin_oblig__statu__05E3CDB6] DEFAULT ('A'),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[rin_obligation_deltrg]
on [dbo].[rin_obligation]
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
   select @errmsg = '(rin_obligation) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_rin_obligation
(  
   oid,			
   mf_cmdty_code,	
   rin_cmdty_code,	
   obligation_ratio,	
   mf_uom_code,		
   rin_uom_code,		
   status,		
   trans_id,		
   resp_trans_id
)
select
   d.oid,			
   d.mf_cmdty_code,	
   d.rin_cmdty_code,	
   d.obligation_ratio,	
   d.mf_uom_code,		
   d.rin_uom_code,		
   d.status,		
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

create trigger [dbo].[rin_obligation_updtrg]
on [dbo].[rin_obligation]
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
   raiserror ('(rin_obligation) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(rin_obligation) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(rin_obligation) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(rin_obligation) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_rin_obligation
     (oid,			
      mf_cmdty_code,	
      rin_cmdty_code,	
      obligation_ratio,	
      mf_uom_code,		
      rin_uom_code,		
      status,		
      trans_id,		
      resp_trans_id)
   select
      d.oid,			
      d.mf_cmdty_code,	
      d.rin_cmdty_code,	
      d.obligation_ratio,	
      d.mf_uom_code,		
      d.rin_uom_code,		
      d.status,		
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

return
GO
ALTER TABLE [dbo].[rin_obligation] ADD CONSTRAINT [CK__rin_oblig__statu__06D7F1EF] CHECK (([status]='I' OR [status]='A'))
GO
ALTER TABLE [dbo].[rin_obligation] ADD CONSTRAINT [rin_obligation_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rin_obligation] ADD CONSTRAINT [rin_obligation_fk1] FOREIGN KEY ([mf_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[rin_obligation] ADD CONSTRAINT [rin_obligation_fk2] FOREIGN KEY ([rin_cmdty_code]) REFERENCES [dbo].[commodity] ([cmdty_code])
GO
ALTER TABLE [dbo].[rin_obligation] ADD CONSTRAINT [rin_obligation_fk3] FOREIGN KEY ([mf_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[rin_obligation] ADD CONSTRAINT [rin_obligation_fk4] FOREIGN KEY ([rin_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
GRANT DELETE ON  [dbo].[rin_obligation] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[rin_obligation] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[rin_obligation] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[rin_obligation] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'rin_obligation', NULL, NULL
GO
