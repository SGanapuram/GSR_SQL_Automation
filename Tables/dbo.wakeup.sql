CREATE TABLE [dbo].[wakeup]
(
[wakeup_num] [int] NOT NULL,
[als_decision_class_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[asof_trans_id] [int] NOT NULL,
[exception_flag] [tinyint] NOT NULL,
[exception_reason] [text] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trigger_after] [datetime] NULL,
[key1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key5] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key6] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key7] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[key8] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[wakeup_entity_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[wakeup_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[related_asof_transids] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[instance_num] [smallint] NULL,
[status] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[wakeup_deltrg]
on [dbo].[wakeup]
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
   select @errmsg = '(wakeup) Failed to obtain a valid responsible trans_id.'
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


/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[wakeup_updtrg]
on [dbo].[wakeup]
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
   raiserror ('(wakeup) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(wakeup) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.wakeup_num = d.wakeup_num )
begin
   raiserror ('(wakeup) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(wakeup_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.wakeup_num = d.wakeup_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(wakeup) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[wakeup] ADD CONSTRAINT [CK__wakeup__exceptio__035C66C6] CHECK (([exception_flag]=(1) OR [exception_flag]=(0)))
GO
ALTER TABLE [dbo].[wakeup] ADD CONSTRAINT [CK__wakeup__wakeup_t__04508AFF] CHECK (([wakeup_type]='T' OR [wakeup_type]='Q'))
GO
ALTER TABLE [dbo].[wakeup] ADD CONSTRAINT [wakeup_pk] PRIMARY KEY CLUSTERED  ([wakeup_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [wakeup_idx3] ON [dbo].[wakeup] ([als_decision_class_name], [exception_flag]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [wakeup_idx2] ON [dbo].[wakeup] ([als_decision_class_name], [wakeup_entity_name], [key1], [key2], [key3]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [wakeup_idx1] ON [dbo].[wakeup] ([wakeup_type], [exception_flag], [trigger_after]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[wakeup] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[wakeup] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[wakeup] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[wakeup] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'wakeup', NULL, NULL
GO
