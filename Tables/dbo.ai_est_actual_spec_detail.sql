CREATE TABLE [dbo].[ai_est_actual_spec_detail]
(
[detail_num] [int] NOT NULL,
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[creation_date] [datetime] NULL,
[actual_date] [datetime] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_actual_value] [decimal] (18, 0) NULL,
[spec_actual_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_provisional_val] [float] NULL,
[trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ai_est_actual_spec_detail] ADD CONSTRAINT [ai_est_actual_spec_detail_pk] PRIMARY KEY CLUSTERED  ([detail_num]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ai_est_actual_spec_detail] ADD CONSTRAINT [ai_est_actual_spec_detail_fk1] FOREIGN KEY ([alloc_num], [alloc_item_num], [ai_est_actual_num]) REFERENCES [dbo].[ai_est_actual] ([alloc_num], [alloc_item_num], [ai_est_actual_num])
GO
GRANT DELETE ON  [dbo].[ai_est_actual_spec_detail] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ai_est_actual_spec_detail] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ai_est_actual_spec_detail] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ai_est_actual_spec_detail] TO [next_usr]
GO
