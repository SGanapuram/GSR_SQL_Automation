CREATE TABLE [dbo].[market_info]
(
[mkt_info_num] [int] NOT NULL,
[mkt_info_headline] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_info_concluded_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[mkt_info_type] [tinyint] NOT NULL,
[idms_board_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[newsgrazer_dept_name] [char] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[market_info_deltrg]
on [dbo].[market_info]
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
   select @errmsg = '(market_info) Failed to obtain a valid responsible trans_id.'
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


insert dbo.aud_market_info
   (mkt_info_num,
    mkt_info_headline,
    mkt_info_concluded_ind,
    mkt_info_type,
    idms_board_name,
    newsgrazer_dept_name,
    trans_id,
    resp_trans_id)
select
   d.mkt_info_num,
   d.mkt_info_headline,
   d.mkt_info_concluded_ind,
   d.mkt_info_type,
   d.idms_board_name,
   d.newsgrazer_dept_name,
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

create trigger [dbo].[market_info_updtrg]
on [dbo].[market_info]
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
   raiserror ('(market_info) The change needs to be attached with a new trans_id',16,1)
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
      select @errmsg = '(market_info) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.mkt_info_num = d.mkt_info_num )
begin
   raiserror ('(market_info) new trans_id must not be older than current trans_id.',16,1)
   if @@trancount > 0 rollback tran

   return
end

/* RECORD_STAMP_END */

if update(mkt_info_num) 
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.mkt_info_num = d.mkt_info_num )
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(market_info) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

/* AUDIT_CODE_BEGIN */

if @dummy_update = 0
   insert dbo.aud_market_info
      (mkt_info_num,
       mkt_info_headline,
       mkt_info_concluded_ind,
       mkt_info_type,
       idms_board_name,
       newsgrazer_dept_name,
       trans_id,
       resp_trans_id)
   select
      d.mkt_info_num,
      d.mkt_info_headline,
      d.mkt_info_concluded_ind,
      d.mkt_info_type,
      d.idms_board_name,
      d.newsgrazer_dept_name,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.mkt_info_num = i.mkt_info_num 

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[market_info] ADD CONSTRAINT [market_info_pk] PRIMARY KEY NONCLUSTERED  ([mkt_info_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[market_info] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[market_info] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[market_info] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[market_info] TO [next_usr]
GO
