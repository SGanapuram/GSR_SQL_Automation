CREATE TABLE [dbo].[aud_contract_transmission]
(
[contr_num] [int] NOT NULL,
[contr_rev_num] [int] NOT NULL,
[contr_copy_num] [tinyint] NOT NULL,
[contr_transmit_date] [datetime] NOT NULL,
[contr_transmit_media] [char] (8) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_transmit_user_init] [char] (3) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[contr_acknowledged_date] [datetime] NULL,
[contr_acknowledged_by] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_transmission] ON [dbo].[aud_contract_transmission] ([contr_num], [contr_rev_num], [contr_copy_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_contract_transmissio_idx1] ON [dbo].[aud_contract_transmission] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_contract_transmission] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_contract_transmission] TO [next_usr]
GO
