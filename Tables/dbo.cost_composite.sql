CREATE TABLE [dbo].[cost_composite]
(
[cost_num] [int] NOT NULL,
[trade_num] [int] NOT NULL,
[movement_date] [datetime] NULL,
[loc_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lc_num] [int] NOT NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cost_composite_source] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trader_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[state_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[lease_num] [int] NULL,
[transporter_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bol_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[alloc_num] [int] NULL,
[alloc_item_num] [smallint] NULL,
[ai_est_actual_date] [datetime] NULL,
[option_exercise_date] [datetime] NULL,
[option_expiration_date] [datetime] NULL,
[ticket_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[cost_composite_updtrg]
on [dbo].[cost_composite]
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
   raiserror ('(cost_composite) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(cost_composite) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.cost_num = d.cost_num )
begin
   raiserror ('(cost_composite) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(cost_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.cost_num = d.cost_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(cost_composite) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[cost_composite] ADD CONSTRAINT [cost_composite_pk] PRIMARY KEY CLUSTERED  ([cost_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_composite] ADD CONSTRAINT [cost_composite_fk3] FOREIGN KEY ([trader_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
ALTER TABLE [dbo].[cost_composite] ADD CONSTRAINT [cost_composite_fk5] FOREIGN KEY ([mot_code]) REFERENCES [dbo].[mot] ([mot_code])
GO
ALTER TABLE [dbo].[cost_composite] ADD CONSTRAINT [cost_composite_fk6] FOREIGN KEY ([state_code]) REFERENCES [dbo].[state] ([state_code])
GO
GRANT DELETE ON  [dbo].[cost_composite] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[cost_composite] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[cost_composite] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[cost_composite] TO [next_usr]
GO
