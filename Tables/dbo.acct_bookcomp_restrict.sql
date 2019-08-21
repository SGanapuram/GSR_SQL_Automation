CREATE TABLE [dbo].[acct_bookcomp_restrict]
(
[acct_restriction_num] [int] NOT NULL,
[acct_bookcomp_key] [int] NOT NULL,
[nobuy_restriction_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_acct_bookcomp_restrict_nobuy_restriction_ind] DEFAULT ('N'),
[nosell_restriction_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_acct_bookcomp_restrict_nosell_restriction_ind] DEFAULT ('N'),
[order_type_group] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[restriction_eff_date] [datetime] NOT NULL CONSTRAINT [df_acct_bookcomp_restrict_restriction_eff_date] DEFAULT (getdate()),
[restriction_end_date] [datetime] NOT NULL CONSTRAINT [df_acct_bookcomp_restrict_restriction_end_date] DEFAULT ('12/31/2078'),
[trans_id] [int] NOT NULL,
[tenor_code] [char] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[allows_netout] [bit] NULL,
[allows_bookout] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[acct_bookcomp_restrict_deltrg]
on [dbo].[acct_bookcomp_restrict]
for delete
as
declare @num_rows  int,
        @errmsg    varchar(255),
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
   select @errmsg = '(acct_bookcomp_restrict) Failed to obtain a valid responsible trans_id. '
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

insert dbo.aud_acct_bookcomp_restrict
(  
   acct_restriction_num,
   acct_bookcomp_key,
   nobuy_restriction_ind,
   nosell_restriction_ind,
   order_type_group,
   restriction_eff_date,
   restriction_end_date,
   tenor_code,
   allows_netout,
   allows_bookout,
   trans_id,
   resp_trans_id
)
select
   d.acct_restriction_num,
   d.acct_bookcomp_key,
   d.nobuy_restriction_ind,
   d.nosell_restriction_ind,
   d.order_type_group,
   d.restriction_eff_date,
   d.restriction_end_date,
   d.tenor_code,
   d.allows_netout,
   d.allows_bookout,
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

create trigger [dbo].[acct_bookcomp_restrict_updtrg]
on [dbo].[acct_bookcomp_restrict]
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
   raiserror ('(acct_bookcomp_restrict) The change needs to be attached with a new trans_id.',16,1)
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
      select @errmsg = '(acct_bookcomp_restrict) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror (@errmsg,16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.acct_restriction_num = d.acct_restriction_num)
begin
   select @errmsg = '(acct_bookcomp_restrict) new trans_id must not be older than current trans_id.'   
   if @num_rows = 1 
   begin
      select @errmsg = @errmsg + ' (' + convert(varchar, i.acct_restriction_num) + ')'
      from inserted i
   end
   if @@trancount > 0 rollback tran

   raiserror (@errmsg,16,1)
   return
end

/* RECORD_STAMP_END */

if update(acct_restriction_num)
begin
   select @count_num_rows = (select count(*) from inserted i, deleted d
                             where i.acct_restriction_num = d.acct_restriction_num)
   if (@count_num_rows = @num_rows)
   begin
      select @dummy_update = 1
   end
   else
   begin
      raiserror ('(acct_bookcomp_restrict) primary key can not be changed.',16,1)
      if @@trancount > 0 rollback tran

      return
   end
end

if @dummy_update = 0
   insert dbo.aud_acct_bookcomp_restrict
 	    (acct_restriction_num,
       acct_bookcomp_key,
       nobuy_restriction_ind,
       nosell_restriction_ind,
       order_type_group,
       restriction_eff_date,
       restriction_end_date,
       tenor_code,
       allows_netout,
       allows_bookout,
       trans_id,
       resp_trans_id)
   select
 	    d.acct_restriction_num,
      d.acct_bookcomp_key,
      d.nobuy_restriction_ind,
      d.nosell_restriction_ind,
      d.order_type_group,
      d.restriction_eff_date,
      d.restriction_end_date,
      d.tenor_code,
      d.allows_netout,
      d.allows_bookout,
      d.trans_id,
      i.trans_id
   from deleted d, inserted i
   where d.acct_restriction_num = i.acct_restriction_num 

return
GO
ALTER TABLE [dbo].[acct_bookcomp_restrict] ADD CONSTRAINT [chk_acct_bookcomp_restrict_nobuy_restriction_ind] CHECK (([nobuy_restriction_ind]='N' OR [nobuy_restriction_ind]='Y'))
GO
ALTER TABLE [dbo].[acct_bookcomp_restrict] ADD CONSTRAINT [chk_acct_bookcomp_restrict_nosell_restriction_ind] CHECK (([nosell_restriction_ind]='N' OR [nosell_restriction_ind]='Y'))
GO
ALTER TABLE [dbo].[acct_bookcomp_restrict] ADD CONSTRAINT [acct_bookcomp_restrict_pk] PRIMARY KEY CLUSTERED  ([acct_restriction_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[acct_bookcomp_restrict] ADD CONSTRAINT [acct_bookcomp_restrict_fk1] FOREIGN KEY ([acct_bookcomp_key]) REFERENCES [dbo].[acct_bookcomp] ([acct_bookcomp_key])
GO
ALTER TABLE [dbo].[acct_bookcomp_restrict] ADD CONSTRAINT [acct_bookcomp_restrict_fk2] FOREIGN KEY ([order_type_group]) REFERENCES [dbo].[order_type_grp_desc] ([order_type_group])
GO
ALTER TABLE [dbo].[acct_bookcomp_restrict] ADD CONSTRAINT [acct_bookcomp_restrict_fk3] FOREIGN KEY ([tenor_code]) REFERENCES [dbo].[trade_tenor] ([tenor_code])
GO
GRANT DELETE ON  [dbo].[acct_bookcomp_restrict] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[acct_bookcomp_restrict] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[acct_bookcomp_restrict] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[acct_bookcomp_restrict] TO [next_usr]
GO
