CREATE TABLE [dbo].[FL_GROUPS]
(
[groupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[builtin] [int] NOT NULL CONSTRAINT [df_FL_GROUPS_builtin] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[FL_GROUPS_DEL]
on [dbo].[FL_GROUPS]
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

insert dbo.AUD_FL_GROUPS
(
groupName    ,
description  ,
builtin      ,
operation		 ,
userid              ,
date_op		
)
select 
d.groupName    ,
d.description  ,
d.builtin      ,
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
CREATE TRIGGER [dbo].[FL_GROUPS_INS]
on [dbo].[FL_GROUPS]
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

insert dbo.AUD_FL_GROUPS
(
groupName    ,
description  ,
builtin      ,
operation		 ,
userid              ,
date_op		
)
select 
i.groupName    ,
i.description  ,
i.builtin      ,
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
CREATE TRIGGER [dbo].[FL_GROUPS_UPD]
on [dbo].[FL_GROUPS]
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

insert dbo.AUD_FL_GROUPS
(
groupName    ,
description  ,
builtin      ,
operation		 ,
userid              ,
date_op		
)
select 
i.groupName    ,
i.description  ,
i.builtin      ,
'UPD',
@utenza,
@operation_date 		
from inserted i

/* AUDIT_CODE_END */

return
GO
ALTER TABLE [dbo].[FL_GROUPS] ADD CONSTRAINT [PK_Groups] PRIMARY KEY CLUSTERED  ([groupName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FL_GROUPS] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[FL_GROUPS] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[FL_GROUPS] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[FL_GROUPS] TO [next_usr]
GO
