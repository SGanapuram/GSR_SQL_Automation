CREATE TABLE [dbo].[glfile_bh]
(
[glfile_bh_num] [int] NOT NULL,
[bh_comp_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bh_post_currency] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_journal] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_source_comp_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_num] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bh_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_date] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bh_system_comp_id] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_ref1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_ref2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_ref3] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_period_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_acct_function_ind] [char] (2) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_data_class] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_control_total] [float] NOT NULL,
[bh_post_acct_format] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_record_class] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_owner_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_override_susp_acct] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_reversal_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_user_int_area] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_posted_date] [datetime] NULL,
[cost_status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_type_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[cost_book_comp_num] [int] NOT NULL,
[cost_book_curr_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[bh_post_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[glfile_bh_updtrg]
on [dbo].[glfile_bh]
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
   raiserror ('(glfile_bh) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(glfile_bh) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.glfile_bh_num = d.glfile_bh_num )
begin
   raiserror ('(glfile_bh) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(glfile_bh_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.glfile_bh_num = d.glfile_bh_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(glfile_bh) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[glfile_bh] ADD CONSTRAINT [glfile_bh_pk] PRIMARY KEY CLUSTERED  ([glfile_bh_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[glfile_bh] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[glfile_bh] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[glfile_bh] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[glfile_bh] TO [next_usr]
GO
