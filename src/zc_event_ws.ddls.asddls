@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZEVENT_HUB'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_EVENT_WS
  provider contract transactional_query
  as projection on ZI_EVENT_WS
  association [1..1] to ZI_EVENT_WS as _BaseEntity on $projection.EventUUID = _BaseEntity.EventUUID
{
  key EventUUID,
  EventID,
  Title,
  Location,
  StartDate,
  EndDate,
  Status,
  MaxSeats,
  OccupiedSeats,
  @Semantics: {
    user.createdBy: true
  }
  LocalCreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  LocalCreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LocalLastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  _BaseEntity
}
