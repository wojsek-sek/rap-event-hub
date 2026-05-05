@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Event Details'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZWSEVENT_HUB'
}
@AccessControl.authorizationCheck: #CHECK
define root view entity ZWSC_EVENT_WS
  provider contract transactional_query
  as projection on ZWSI_EVENT_WS
  association [1..1] to ZWSI_EVENT_WS as _BaseEntity on $projection.EventUUID = _BaseEntity.EventUUID
{
  key EventUUID,
  EventID,
  @Consumption.valueHelpDefinition: [ { 
    entity: { 
        name:    '/DMO/I_Customer_StdVH',
        element: 'FirstName'
    }
  } ]
  Title,
  @Consumption.valueHelpDefinition: [ { 
    entity: { 
        name:    'ZWSI_VENUE_VH_WS',
        element: 'VenueName'
    },
    
    additionalBinding: [ { localElement: 'Location', element: 'Street' } ] 
  } ]
  Location,
  StartDate,
  EndDate,
  @Consumption.valueHelpDefinition: [ { 
    entity: { 
        name:    'ZWSI_Stauts_VH_WS',
        element: 'Status'
    }, distinctValues: true
  } ]
  @UI.textArrangement: #TEXT_ONLY
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
  _BaseEntity,
  
  @UI.hidden: true
  OccupiedCriticality,
  @UI.hidden: true
  StatusCriticality,
  DaysToStart,
  @UI.hidden: true
  StartTimeCriticality,
  
  
  /* Przekierowanie relacji do wersji "C_" dziecka */
  _Registrations : redirected to composition child ZWSC_REG_WS
}
