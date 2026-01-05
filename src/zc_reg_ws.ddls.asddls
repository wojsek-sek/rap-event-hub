@EndUserText.label: 'Consumption View for Registration'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZC_REG_WS
  as projection on ZI_REG_WS
{
  key regist_uuid,
  
  @UI.hidden: true
  event_uuid,
  first_name,
  last_name,
  email,
  booking_date,
  ticket_code,
  
  local_last_changed_at,
  
  /* Relacja do rodzica (Consumption) */
  _Event : redirected to parent ZC_EVENT_WS
}
