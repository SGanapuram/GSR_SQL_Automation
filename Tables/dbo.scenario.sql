CREATE TABLE [dbo].[scenario]
(
[oid] [int] NOT NULL,
[scenario_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[scenario_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [DF__scenario__scenar__1CC7330E] DEFAULT ('ASSET'),
[qty] [numeric] (20, 8) NULL,
[qty_uom_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[qty_periodicity] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL CONSTRAINT [DF__scenario__qty_pe__1EAF7B80] DEFAULT ('D'),
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_num] [int] NULL,
[trans_id] [int] NOT NULL,
[storage_acct_num] [int] NULL,
[title_del_loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[scenario_deltrg]
on [dbo].[scenario]
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
   select @errmsg = '(scenario) Failed to obtain a valid responsible trans_id.'
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

insert dbo.aud_scenario
(  
   oid,
   scenario_name,
   scenario_type,
   qty,
   qty_uom_code,
   qty_periodicity,
   creator_init,
   port_num,
   storage_acct_num,
   title_del_loc_code,
   trans_id,
   resp_trans_id
)
select
   d.oid,
   d.scenario_name,
   d.scenario_type,
   d.qty,
   d.qty_uom_code,
   d.qty_periodicity,
   d.creator_init,
   d.port_num,
   d.storage_acct_num,
   d.title_del_loc_code,
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

create trigger [dbo].[scenario_updtrg]
on [dbo].[scenario]
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
   raiserror ('(scenario) The change needs to be attached with a new trans_id.',10,1)
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
      select @errmsg = '(scenario) New trans_id must be larger than original trans_id.'
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
   select @errmsg = '(scenario) new trans_id must not be older than current trans_id.'   
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
      raiserror ('(scenario) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_scenario
 	    (oid,
       scenario_name,
       scenario_type,
       qty,
       qty_uom_code,
       qty_periodicity,
       creator_init,
       port_num,
       storage_acct_num,
       title_del_loc_code,
       trans_id,
       resp_trans_id)
   select
      d.oid,
      d.scenario_name,
      d.scenario_type,
      d.qty,
      d.qty_uom_code,
      d.qty_periodicity,
      d.creator_init,
      d.port_num,
      d.storage_acct_num,
      d.title_del_loc_code,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.oid = i.oid 

return
GO
ALTER TABLE [dbo].[scenario] ADD CONSTRAINT [CK__scenario__qty_pe__1FA39FB9] CHECK (([qty_periodicity]='L' OR [qty_periodicity]='D'))
GO
ALTER TABLE [dbo].[scenario] ADD CONSTRAINT [CK__scenario__scenar__1DBB5747] CHECK (([scenario_type]='OPPORTUNITY' OR [scenario_type]='ASSET'))
GO
ALTER TABLE [dbo].[scenario] ADD CONSTRAINT [scenario_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[scenario] ADD CONSTRAINT [scenario_fk1] FOREIGN KEY ([qty_uom_code]) REFERENCES [dbo].[uom] ([uom_code])
GO
ALTER TABLE [dbo].[scenario] ADD CONSTRAINT [scenario_fk2] FOREIGN KEY ([creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[scenario] ADD CONSTRAINT [scenario_fk3] FOREIGN KEY ([port_num]) REFERENCES [dbo].[portfolio] ([port_num])
GO
ALTER TABLE [dbo].[scenario] ADD CONSTRAINT [scenario_fk4] FOREIGN KEY ([storage_acct_num]) REFERENCES [dbo].[account] ([acct_num])
GO
ALTER TABLE [dbo].[scenario] ADD CONSTRAINT [scenario_fk5] FOREIGN KEY ([title_del_loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
GRANT DELETE ON  [dbo].[scenario] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[scenario] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[scenario] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[scenario] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'scenario', NULL, NULL
GO
