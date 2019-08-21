CREATE TABLE [dbo].[riskmgr_win_def]
(
[win_id] [int] NOT NULL,
[description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[is_public] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[owner_name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[window_title] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[port_path] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL CONSTRAINT [df_riskmgr_win_def_port_path] DEFAULT (''),
[selected_index] [int] NOT NULL CONSTRAINT [df_riskmgr_win_def_selected_index] DEFAULT ((0)),
[trans_id] [int] NOT NULL,
[show_history_pnl] [bit] NOT NULL CONSTRAINT [df_riskmgr_win_def_show_history_pnl] DEFAULT ((0)),
[visible_portfolio_cols] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[riskmgr_win_def_deltrg]
ON [dbo].[riskmgr_win_def]
FOR DELETE
as
declare @num_rows           int,
        @errmsg             varchar(255),
        @atrans_id          bigint,
        @the_entity_name    varchar(80)

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
   select @errmsg = '(riskmgr_win_def) Failed to obtain a valid responsible trans_id.'
   if exists (select 1
              from master.dbo.sysprocesses (nolock)
              where spid = @@spid and
                    (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                     program_name like 'Microsoft SQL Server Management Studio%') )
      select @errmsg = @errmsg + char(10) + 'You must use the gen_new_transaction procedure to obtain a new trans_id before executing delete statement.'
   raiserror(@errmsg, 10, 1)
   rollback tran
   return
end

set @the_entity_name = 'RiskmgrWinDef'

/* BEGIN_TRANSACTION_TOUCH */

insert dbo.transaction_touch
select 'DELETE',
       @the_entity_name,
       'DIRECT',
       convert(varchar(40), d.win_id),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       @atrans_id,
       it.sequence
from dbo.icts_transaction it WITH (NOLOCK),
     deleted d
where it.trans_id = @atrans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

insert into dbo.aud_riskmgr_win_def
(
   win_id,
   description,
   is_public,
   owner_name,
   window_title,
   port_path,
   selected_index,
   show_history_pnl,
   visible_portfolio_cols,
   trans_id,
   resp_trans_id 
)
select 
   d.win_id,
   d.description,
   d.is_public,
   d.owner_name,
   d.window_title,
   d.port_path,
   d.selected_index,
   d.show_history_pnl,
   d.visible_portfolio_cols,
   d.trans_id,
   @atrans_id
from deleted d
return
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[riskmgr_win_def_instrg]
ON [dbo].[riskmgr_win_def]
for insert
as
declare @num_rows           int,
        @the_entity_name    varchar(30)

select @num_rows = @@rowcount
if @num_rows = 0
   return        

set @the_entity_name = 'RiskmgrWinDef'	
	
/* BEGIN_TRANSACTION_TOUCH */
insert dbo.transaction_touch
select 'INSERT',
       @the_entity_name,
       'DIRECT',
       convert(varchar(40), i.win_id),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from dbo.icts_transaction it WITH (NOLOCK),
     inserted i
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */
		
return	
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[riskmgr_win_def_updtrg]
ON [dbo].[riskmgr_win_def]
for update
as
declare @num_rows           int,
        @errmsg             varchar(255),
        @the_entity_name    varchar(30)

select @num_rows = @@rowcount
if @num_rows = 0
   return

if not update(trans_id)
begin
   raiserror ('(riskmgr_win_def) The change needs to be attached with a new trans_id', 10, 1)
   if @@trancount > 0 rollback tran

   return
end

if exists (select 1
           from master.dbo.sysprocesses
           where spid = @@spid and
                (rtrim(program_name) IN ('ISQL-32', 'OSQL-32', 'SQL Query Analyzer', 'SQLCMD') OR
                 program_name like 'Microsoft SQL Server Management Studio%') )
begin
   if (select count(*) from inserted, deleted where inserted.trans_id <= deleted.trans_id) > 0
   begin
      select @errmsg = '(riskmgr_win_def) New trans_id must be larger than original trans_id.'
      select @errmsg = @errmsg + char(10) + 'You can use the the gen_new_transaction procedure to obtain a new trans_id.'
      raiserror(@errmsg, 10, 1)
      if @@trancount > 0 rollback tran

      return
   end
end

if exists (select * from inserted i, deleted d
           where i.trans_id < d.trans_id and
                 i.win_id = d.win_id)
begin
   raiserror ('(riskmgr_win_def) new trans_id must not be older than current trans_id.', 10, 1)
   if @@trancount > 0 rollback tran

   return
end

/* BEGIN_TRANSACTION_TOUCH */
set @the_entity_name = 'RiskmgrWinDef'

insert dbo.transaction_touch
select 'UPDATE',
       @the_entity_name,
       'DIRECT',
       convert(varchar(40), i.win_id),
       null,
       null,
       null,
       null,
       null,
       null,
       null,
       i.trans_id,
       it.sequence
from dbo.icts_transaction it WITH (NOLOCK),
     inserted i
where i.trans_id = it.trans_id and
      it.type != 'E'

/* END_TRANSACTION_TOUCH */

/* Audit Table */
insert into dbo.aud_riskmgr_win_def
(
   win_id,
   description,
   is_public,
   owner_name,
   window_title,
   port_path,
   selected_index,
   show_history_pnl,
   visible_portfolio_cols,
   trans_id,
   resp_trans_id 
)
select 
   d.win_id,
   d.description,
   d.is_public,
   d.owner_name,
   d.window_title,
   d.port_path,
   d.selected_index,
   d.show_history_pnl,
   d.visible_portfolio_cols,
   d.trans_id,
   i.trans_id
from deleted d 
        inner join inserted i
           on d.win_id = i.win_id
return
GO
ALTER TABLE [dbo].[riskmgr_win_def] ADD CONSTRAINT [PK_riskmgr_win_def] PRIMARY KEY CLUSTERED  ([win_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[riskmgr_win_def] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[riskmgr_win_def] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[riskmgr_win_def] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[riskmgr_win_def] TO [next_usr]
GO
