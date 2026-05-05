@EndUserText.label: 'Statystyki Eventów'
@ObjectModel.query.implementedBy: 'ABAP:ZWSCL_EVENT_STATS_QUERY_WS'
define custom entity ZWSI_EVENT_STATS_WS
{
  key Status    : abap.char(1);
      
      @EndUserText.label: 'Liczba Wydarzeń'
      EventCount : abap.int4;
}
