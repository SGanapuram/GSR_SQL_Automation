CREATE TABLE [dbo].[gtc]
(
[gtc_code] [char] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[gtc_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[agreement_num] [int] NULL,
[agreement_date] [datetime] NULL,
[creator_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[creation_date] [datetime] NOT NULL CONSTRAINT [df_gtc_creation_date] DEFAULT (getdate()),
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[gtc_deltrg]
on [dbo].[gtc]
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
   select @errmsg = '(gtc) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_gtc
   (gtc_code,
    gtc_desc,
    agreement_num,
    agreement_date,
    creator_init,
    creation_date,
    trans_id,
    resp_trans_id
   )
select
   d.gtc_code,
   d.gtc_desc,
   d.agreement_num,
   d.agreement_date,
   d.creator_init,
   d.creation_date,
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

create trigger [dbo].[gtc_updtrg]
on [dbo].[gtc]
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
   raiserror ('(gtc) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(gtc) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.gtc_code = d.gtc_code )
begin
   raiserror ('(gtc) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(gtc_code) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.gtc_code = d.gtc_code )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(gtc) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end


/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_gtc
      (gtc_code,
       gtc_desc,
       agreement_num,
       agreement_date,
       creator_init,
       creation_date,
       trans_id,
       resp_trans_id)
   select
      d.gtc_code,
      d.gtc_desc,
      d.agreement_num,
      d.agreement_date,
      d.creator_init,
      d.creation_date,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.gtc_code = i.gtc_code 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[gtc] ADD CONSTRAINT [gtc_pk] PRIMARY KEY CLUSTERED  ([gtc_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gtc] ADD CONSTRAINT [gtc_fk1] FOREIGN KEY ([creator_init]) REFERENCES [dbo].[icts_user] ([user_init])
GO
GRANT DELETE ON  [dbo].[gtc] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[gtc] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[gtc] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[gtc] TO [next_usr]
GO
