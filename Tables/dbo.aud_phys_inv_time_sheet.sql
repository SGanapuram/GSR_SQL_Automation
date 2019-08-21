CREATE TABLE [dbo].[aud_phys_inv_time_sheet]
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
[resp_trans_id] [int] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_phys_inv_time_sheet] ON [dbo].[aud_phys_inv_time_sheet] ([oid], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_phys_inv_time_sheet_idx1] ON [dbo].[aud_phys_inv_time_sheet] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_phys_inv_time_sheet] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_phys_inv_time_sheet] TO [next_usr]
GO
