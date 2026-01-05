@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZEVENT_HUB'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZI_EVENT_WS
  as select from zaevent_ws 
  composition [0..*] of ZI_REG_WS as _Registrations
{
  key event_uuid as EventUUID,
  event_id as EventID,
  title as Title,
  location as Location,
  start_date as StartDate,
  end_date as EndDate,
  status as Status,
  max_seats as MaxSeats,
  occupied_seats as OccupiedSeats,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  
  /* Expose association (upublicznij relację) */
  _Registrations
}
