CREATE TABLE [dbo].[FL_GROUPS_USERS]
(
[fleetimeUser] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[groupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[FL_GROUPS_USERS_DEL]
on [dbo].[FL_GROUPS_USERS]
for delete
as

declare @num_rows         int,
        @count_num_rows   int,
        @operation_date   datetime,
	@utenza	          varchar(256)

select @num_rows = @@rowcount
if @num_rows = 0
   return


select @operation_date   = getdate()
select @utenza  = user

insert dbo.AUD_FL_GROUPS_USERS
(
fleetimeUser ,
groupName    ,
operation		 ,
userid              ,
date_op		
)
select 
d.fleetimeUser ,
d.groupName    ,
'DEL',
@utenza,
@operation_date 		
from deleted d

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[FL_GROUPS_USERS_INS]
on [dbo].[FL_GROUPS_USERS]
for insert
as

declare @num_rows         int,
        @count_num_rows   int,
        @operation_date   datetime,
	@utenza	          varchar(256)

select @num_rows = @@rowcount
if @num_rows = 0
   return


select @operation_date   = getdate()
select @utenza  = user

insert dbo.AUD_FL_GROUPS_USERS
(
fleetimeUser ,
groupName    ,
operation		 ,
userid              ,
date_op		
)
select 
i.fleetimeUser ,
i.groupName    ,
'INS',
@utenza,
@operation_date 		
from inserted i

/* AUDIT_CODE_END */

return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[FL_GROUPS_USERS_UPD]
on [dbo].[FL_GROUPS_USERS]
for update
as

declare @num_rows         int,
        @count_num_rows   int,
        @operation_date   datetime,
	@utenza	          varchar(256)

select @num_rows = @@rowcount
if @num_rows = 0
   return


select @operation_date   = getdate()
select @utenza  = user

insert dbo.AUD_FL_GROUPS_USERS
(
fleetimeUser ,
groupName    ,
operation		 ,
userid              ,
date_op		
)
select 
i.fleetimeUser ,
i.groupName    ,
'UPD',
@utenza,
@operation_date 		
from inserted i

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[FL_GROUPS_USERS] ADD CONSTRAINT [PK_GroupsUsers] PRIMARY KEY CLUSTERED  ([fleetimeUser], [groupName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FL_GROUPS_USERS] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[FL_GROUPS_USERS] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[FL_GROUPS_USERS] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[FL_GROUPS_USERS] TO [next_usr]
GO
