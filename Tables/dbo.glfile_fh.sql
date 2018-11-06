CREATE TABLE [dbo].[glfile_fh]
(
[glfile_fh_num] [int] NOT NULL,
[fh_edit_only_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_use_susp_acct_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_data_interpret_sw] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_report_title] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_post_to_inactive_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_sign_fix_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_generate_acct_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_process_mode_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_page_break_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_print_level_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_post_summary_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_thousand_separator] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_decimal_separator] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_epic_report_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[fh_post_unbalance_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[glfile_fh_updtrg]
on [dbo].[glfile_fh]
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
   raiserror ('(glfile_fh) The change needs to be attached with a new trans_id',10,1)
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
      select @errmsg = '(glfile_fh) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.glfile_fh_num = d.glfile_fh_num )
begin
   raiserror ('(glfile_fh) new trans_id must not be older than current trans_id.',10,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(glfile_fh_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.glfile_fh_num = d.glfile_fh_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(glfile_fh) primary key can not be changed.',10,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[glfile_fh] ADD CONSTRAINT [glfile_fh_pk] PRIMARY KEY CLUSTERED  ([glfile_fh_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[glfile_fh] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[glfile_fh] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[glfile_fh] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[glfile_fh] TO [next_usr]
GO
EXEC sp_addextendedproperty N'SymphonyProduct', N'OIL', 'SCHEMA', N'dbo', 'TABLE', N'glfile_fh', NULL, NULL
GO
