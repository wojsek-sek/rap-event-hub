@EndUserText.label: 'Consumption View for Registration'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZWSC_REG_WS
  as projection on ZWSI_REG_WS
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
  _Event : redirected to parent ZWSC_EVENT_WS
}
