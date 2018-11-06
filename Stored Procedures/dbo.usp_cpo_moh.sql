SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_cpo_moh] (      
 @input xml,      
 @executorUser varchar(100)      
 )      
as      
begin      
 if object_id('tempdb..#XmlFile') is not null      
  drop table #XmlFile      
      
 create table #XmlFile (      
  RowNumber int primary key Identity(1, 1),      
  [TradeNo] [nvarchar](120) null,      
  [OrderNo] [nvarchar](120) null,      
  [ItemNo] [nvarchar](120) null,      
  [ShipmentNo] [nvarchar](120) null,      
  [ParcelNo] [nvarchar](120) null      
  );      
      
 if exists (      
   select 1      
   from #XmlFile      
   )      
  delete      
  from #XmlFile      
      
 begin      
  insert into #XmlFile      
  select t.value('(TradeNo/text())[1]', 'nvarchar(120)') as TradeNo,      
   t.value('(OrderNo/text())[1]', 'nvarchar(120)') as OrderNo,      
   t.value('(ItemNo/text())[1]', 'nvarchar(120)') as ItemNo,      
   t.value('(ShipmentNo/text())[1]', 'nvarchar(120)') as ShipmentNo,      
   t.value('(ParcelNo/text())[1]', 'nvarchar(120)') as ParcelNo      
  from @input.nodes('Parameters/Parameter') as TempTable(t)      
 end      
      
 if object_id('tempdb..#FinalResults') is not null      
  drop table #FinalResults      
      
 create table #FinalResults (      
   [CounterpartyFullName] [nvarchar](255) NULL      
  ,  [CommodityFullName] [varchar](40) NULL      
  ,  [AmendNum] [smallint] NULL      
  ,  [ContractQty] [float] NULL      
  ,  [ContrQtyUomCode] [char](4) NULL 
  ,  [RefNR] [varchar](92) NULL     
  ,  [ETADate] [varchar](8000) NULL       
  ,  [TolSign] [varchar](3) NULL      
  ,  [TolQty] [float] NOT NULL      
  ,  [TolQtyUomCode] [char](4) NULL      
  ,  [TolOpt] [varchar](8) NULL      
  ,  [MinTolQtyUomCode] [char](4) NULL      
  ,  [MaxTolQtyUomCode] [char](4) NULL      
  ,  [DensityIndicator] [char](1) NULL  
  ,  [DelDateFrom] [nvarchar](93) NULL  
  ,  [DelDateTo]   [nvarchar](93) NULL  
  ,  [MinTolQty] [float] NOT NULL      
  ,  [MaxTolQty] [float] NOT NULL      
  ,  [SpecTypicalVal] [float] NULL      
  ,  [InspectionCompany] [nvarchar](15) NULL      
  ,  [LayDays] [nvarchar](124) NULL      
  ,  [GuaranteedSpec] [varchar](16) NULL      
  ,  [MotFullName] [varchar](40) NULL      
  );      
 begin      
  declare @RowNumber int,      
   @tradeNum int,      
   @executor varchar(50),      
   @orderNum int,      
   @itemNum int,      
   @shipmentNum int = null,      
   @parcelNum int = null      
      
  while exists (      
    select 1      
    from #XmlFile      
    )      
  begin      
   select @RowNumber = min(RowNumber)      
   from #XmlFile      
      
   select @tradeNum = TradeNo,      
    @executor = @executorUser,      
    @orderNum = OrderNo,      
    @itemNum = ItemNo,      
    @shipmentNum = ShipmentNo,      
    @parcelNum = ParcelNo      
   from #XmlFile      
   where RowNumber = @RowNumber      
      
   begin      
    insert into #FinalResults      
    exec usp_get_trade_operations_data_cpo_temp @tradeNum,      
     @executor,      
     @orderNum,      
     @itemNum,      
     @shipmentNum,      
     @parcelNum      
   end      
      
   delete      
   from #XmlFile      
   where RowNumber = @RowNumber      
  end      
 end      
      
 select *      
 from #FinalResults      
end   
GO
GRANT EXECUTE ON  [dbo].[usp_cpo_moh] TO [next_usr]
GO
