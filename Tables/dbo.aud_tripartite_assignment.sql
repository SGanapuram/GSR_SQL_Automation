CREATE TABLE [dbo].[aud_tripartite_assignment]
(
[trade_num] [int] NOT NULL,
[order_num] [int] NOT NULL,
[item_num] [smallint] NOT NULL,
[assign_num] [smallint] NOT NULL,
[port_num] [int] NULL,
[shipment_num] [int] NULL,
[parcel_num] [int] NULL,
[actual_num] [int] NULL,
[assign_pcnt] [float] NOT NULL,
[bank_acct_num] [int] NULL,
[acct_bank_id] [int] NULL,
[assign_start_date] [datetime] NULL,
[assign_end_date] [datetime] NULL,
[trans_id] [int] NOT NULL,
[resp_trans_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tripartite_assignment] ON [dbo].[aud_tripartite_assignment] ([trade_num], [order_num], [item_num], [assign_num], [trans_id], [resp_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [aud_tripartite_assignment_idx1] ON [dbo].[aud_tripartite_assignment] ([trans_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[aud_tripartite_assignment] TO [next_usr]
GO
GRANT SELECT ON  [dbo].[aud_tripartite_assignment] TO [next_usr]
GO
