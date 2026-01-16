@EndUserText.label: 'Statystyki Eventów'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_EVENT_STATS_QUERY_WS'
define custom entity ZI_EVENT_STATS_WS
{
  key Status    : abap.char(1);
      
      @EndUserText.label: 'Liczba Wydarzeń'
      EventCount : abap.int4;
}
