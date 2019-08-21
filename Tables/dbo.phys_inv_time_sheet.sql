CREATE TABLE [dbo].[phys_inv_time_sheet]
(
[oid] [int] NOT NULL,
[exec_inv_num] [int] NOT NULL,
[logistic_event_order_num] [smallint] NOT NULL,
[logistic_event] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[loc_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[mot_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[document_id] [int] NULL,
[event_from_date] [datetime] NULL,
[from_date_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[event_to_date] [datetime] NULL,
[to_date_actual_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[short_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[cmnt_num] [int] NULL,
[trans_id] [int] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[phys_inv_time_sheet] ADD CONSTRAINT [phys_inv_time_sheet_pk] PRIMARY KEY CLUSTERED  ([oid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[phys_inv_time_sheet] ADD CONSTRAINT [phys_inv_time_sheet_fk1] FOREIGN KEY ([exec_inv_num]) REFERENCES [dbo].[exec_phys_inv] ([exec_inv_num])
GO
ALTER TABLE [dbo].[phys_inv_time_sheet] ADD CONSTRAINT [phys_inv_time_sheet_fk2] FOREIGN KEY ([loc_code]) REFERENCES [dbo].[location] ([loc_code])
GO
ALTER TABLE [dbo].[phys_inv_time_sheet] ADD CONSTRAINT [phys_inv_time_sheet_fk3] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
GRANT DELETE ON  [dbo].[phys_inv_time_sheet] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[phys_inv_time_sheet] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[phys_inv_time_sheet] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[phys_inv_time_sheet] TO [next_usr]
GO
