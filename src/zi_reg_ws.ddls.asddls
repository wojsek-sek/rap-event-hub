@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for Registration'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_REG_WS
  as select from zareg_ws
  association to parent ZI_EVENT_WS as _Event on $projection.event_uuid = _Event.EventUUID
{
  key regist_uuid,
  event_uuid,
  
  first_name,
  last_name,
  email,
  booking_date,
  ticket_code,
  
  /* Pola techniczne */
  local_last_changed_at,
  
  /* Asocjacje */
  _Event // <--- To pozwala dziecku "widzieć" rodzica
}
