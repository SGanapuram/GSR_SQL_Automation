SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[portfolioChildren]
(
   @TopPortfolio        int = -1,
   @PortfolioType       char(2) = '??',
   @show_port_num_ind   bit = 1
)
as 
set nocount on

   if @TopPortfolio = -1
   begin
      print 'Please provide a valid port_num for the argument @TopPortfolio!'
      goto reportusage
   end

   if @PortfolioType = '??'
   begin
      print 'Please provide a valid portfolio type for the argument @PortfolioType!'
      goto reportusage
   end

   if @show_port_num_ind is null
      set @show_port_num_ind = 1

   create table #children 
   (
      port_num  int PRIMARY KEY,
      port_type char(2)
   )

   exec dbo.port_children @TopPortfolio, @PortfolioType, @show_port_num_ind

   if @show_port_num_ind = 1
      drop table #children
   return
   
reportusage:
   print 'Usage: exec dbo.portfolioChildren @TopPortfolio = <port_num>, @PortfolioType = <port type>, @show_port_num_ind = <1 or 0>'
   return
GO
GRANT EXECUTE ON  [dbo].[portfolioChildren] TO [next_usr]
GO
