SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[usp_find_TI_4_ContrTagsAndTP]
(
   @contract_num        varchar(16),
   @contract_line_num   varchar(16),
   @trading_period      varchar(8)
)
as
set nocount on
declare @entity_id              int,
        @ContrNum_tag_id        int,
        @ContrLineNum_tag_id    int,
        @errcode                int,
        @rows_affected          int,
        @smsg                   varchar(255)

   select @errcode = 0   

   if @contract_num is null
   begin
      select @smsg = '=> You must pass a non-null value to the argument @contract_num!' 
      goto reportusage
   end
   if @contract_line_num is null
   begin
      select @smsg = '=> You must pass a non-null value to the argument @contract_line_num!' 
      goto reportusage
   end
   if @trading_period is null
   begin
      select @smsg = '=> You must pass a non-null value to the argument @trading_period!' 
      goto reportusage
   end

   CREATE TABLE #trade_order_item
   (
      trade_num   int        NOT NULL,
      order_num   smallint   NOT NULL,
      item_num    smallint   NOT NULL
   )
   if @@error > 0
   begin
      print 'Failed to create temporary table!'
      goto endofsp2
   end

   create unique clustered index xx0120_trade_order_item_idx1 
       on #trade_order_item (trade_num, order_num, item_num)

   -- 1. get entity_tag_id's from entity_tag_definition
   SELECT @entity_id = oid 
   FROM dbo.icts_entity_name 
   WHERE entity_name = 'TradeItem'
   
   if @entity_id is null
   begin
      print '=> Could not find an entity ID for the entity ''TradeItem''!'
      goto endofsp1
   end
   
   SELECT @ContrNum_tag_id = oid 
   FROM dbo.entity_tag_definition name 
   WHERE entity_id = @entity_id AND 
         entity_tag_name = 'ContrNum'
   if @ContrNum_tag_id is null
   begin
      print '=> Could not find a TAG ID for the tag ''ContrNum''!'
      goto endofsp1
   end
   
   SELECT @ContrLineNum_tag_id = oid 
   FROM dbo.entity_tag_definition name 
   WHERE entity_id = @entity_id AND 
         entity_tag_name = 'ContrLineNum'
   if @ContrLineNum_tag_id is null
   begin
      print '=> Could not find a TAG ID for the tag ''ContrLineNum''!'
      goto endofsp1
   end

   -- 2. populate a temp table with trade, order, item tuples
   INSERT INTO #trade_order_item 
        (trade_num, order_num, item_num)
   SELECT cast(et1.key1 as int), 
          cast(et1.key2 as smallint), 
          cast(et1.key3 as smallint)
   FROM dbo.entity_tag et1
   WHERE EXISTS (SELECT 1
                 FROM dbo.entity_tag et2
                 WHERE et1.key1 = et2.key1 AND
                       et1.key2 = et2.key2 AND
                       et1.key3 = et2.key3 AND
                       et2.entity_tag_id = @ContrLineNum_tag_id AND
                       et2.target_key1 = @contract_line_num) AND
         et1.entity_tag_id = @ContrNum_tag_id AND
         et1.target_key1 = @contract_num
   SELECT @rows_affected = @@rowcount,
          @errcode = @@error
   If @errcode > 0
   begin
      print 'Failed to copy data to temp table!'
      Goto endofsp1
   end
   IF @rows_affected = 0
   Begin
      Select null, null, null
      Goto endofsp1
   end

   -- 3. now join #trade_order_item with trade_item on keys and 
   --    look for trade_item.trading_prd
   SELECT ti.trade_num, ti.order_num, ti.item_num
   FROM dbo.trade_item ti
   WHERE EXISTS (SELECT 1
                 FROM #trade_order_item tmp
                 WHERE ti.trade_num = tmp.trade_num AND
                       ti.order_num = tmp.order_num AND
                       ti.item_num = tmp.item_num) AND
         ti.trading_prd = @trading_period

endofsp1:
   drop table #trade_order_item

endofsp2:
  if @errcode = 0
   return 0
  return 1
  
reportusage:
   print ' '
   print @smsg
   print ' '
   print 'Usage: exec dbo.usp_find_TI_4_ContrTagsAndTP'
   print '                 @contract_num = ?,'
   print '                 @contract_line_num= ?,'
   print '                 @trading_period = ''?'''
   return 2
GO
GRANT EXECUTE ON  [dbo].[usp_find_TI_4_ContrTagsAndTP] TO [next_usr]
GO
