CREATE TABLE [dbo].[ai_est_actual_spec]
(
[alloc_num] [int] NOT NULL,
[alloc_item_num] [smallint] NOT NULL,
[ai_est_actual_num] [smallint] NOT NULL,
[spec_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[spec_actual_value] [float] NULL,
[spec_actual_value_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[spec_provisional_val] [float] NULL,
[trans_id] [int] NOT NULL,
[use_in_formula_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[use_in_cost_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ai_est_actual_spec] ADD CONSTRAINT [ai_est_actual_spec_pk] PRIMARY KEY CLUSTERED  ([alloc_num], [alloc_item_num], [ai_est_actual_num], [spec_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ai_est_actual_spec] ADD CONSTRAINT [ai_est_actual_spec_fk2] FOREIGN KEY ([spec_code]) REFERENCES [dbo].[specification] ([spec_code])
GO
GRANT DELETE ON  [dbo].[ai_est_actual_spec] TO [next_usr]
GO
GRANT INSERT ON  [dbo].[ai_est_actual_spec] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[ai_est_actual_spec] TO [next_usr]
GO
GRANT UPDATE ON  [dbo].[ai_est_actual_spec] TO [next_usr]
GO
