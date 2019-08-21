CREATE TABLE [dbo].[glfile_th]
(
[glfile_bh_num] [int] NOT NULL,
[glfile_th_num] [int] NOT NULL,
[th_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_control_total] [float] NOT NULL,
[th_ref1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_ref2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_ref3] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_ref4] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_ref5] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[th_sign_fix_sw] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_num] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[th_record_class] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_owner_code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[bh_num] [char] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[th_post_currency] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_prim_trans_currency] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_trans_corp_xrate] [float] NULL,
[th_trans_corp_xrate_format] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_trans_func_xrate] [float] NULL,
[th_trans_func_xrate_format] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_xrate_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_source_trans_num] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_user_int_area] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[th_posted_date] [datetime] NULL,
[th_cost_num] [int] NOT NULL,
[th_accr_rev_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[glfile_th_updtrg]
on [dbo].[glfile_th]
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
   raiserror ('(glfile_th) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(glfile_th) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.glfile_bh_num = d.glfile_bh_num and 
                 i.glfile_th_num = d.glfile_th_num )
begin
   raiserror ('(glfile_th) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(glfile_bh_num) or  
   update(glfile_th_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.glfile_bh_num = d.glfile_bh_num and 
                                   i.glfile_th_num = d.glfile_th_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(glfile_th) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

return
GO
ALTER TABLE [dbo].[glfile_th] ADD CONSTRAINT [glfile_th_pk] PRIMARY KEY CLUSTERED  ([glfile_bh_num], [glfile_th_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[glfile_th] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[glfile_th] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[glfile_th] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[glfile_th] TO [next_usr]
GO
