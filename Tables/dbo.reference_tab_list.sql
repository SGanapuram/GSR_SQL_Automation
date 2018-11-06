CREATE TABLE [dbo].[reference_tab_list]
(
[ref_tab_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ref_tab_desc] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL,
[use_ind] [bit] NOT NULL CONSTRAINT [DF__reference__use_i__5DD5DC5C] DEFAULT ((1))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[reference_tab_list_updtrg]
on [dbo].[reference_tab_list]
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
   raiserror ('(reference_tab_list) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(reference_tab_list) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.ref_tab_name = d.ref_tab_name )
begin
   raiserror ('(reference_tab_list) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(ref_tab_name) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.ref_tab_name = d.ref_tab_name )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(reference_tab_list) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[reference_tab_list] ADD CONSTRAINT [reference_tab_list_pk] PRIMARY KEY CLUSTERED  ([ref_tab_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reference_tab_list] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[reference_tab_list] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[reference_tab_list] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[reference_tab_list] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'reference_tab_list', NULL, NULL
GO
