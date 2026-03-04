@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Events'
define root view entity ZI_EVENT_WS
  as select from zaevent_ws 
  composition [0..*] of ZI_REG_WS as _Registrations
  association [0..1] to ZI_STAUTS_VH_WS as _StatusVH on $projection.Status = _StatusVH.Status
{
  key event_uuid as EventUUID,
  event_id as EventID,
  title as Title,
  location as Location,
  start_date as StartDate,
  end_date as EndDate,
  status as Status,
  
  cast( max_seats as abap.int4 ) as MaxSeats,
  cast( occupied_seats as abap.int4 ) as OccupiedSeats,
  cancel_reason as CancelReason,
  local_created_by as LocalCreatedBy,
  local_created_at as LocalCreatedAt,
  local_last_changed_by as LocalLastChangedBy,
  local_last_changed_at as LocalLastChangedAt,
  last_changed_at as LastChangedAt,
  
  cast( 
      case 
        when occupied_seats = 0 then 0
        when occupied_seats < max_seats then 3 
        when occupied_seats >= max_seats then 1
        else 0
      end as abap.int1 
    ) as OccupiedCriticality,
    
  cast( 
      case 
        when status = 'O' then 3
        when status = 'X' then 1 
        else 0
      end as abap.int1 
    ) as StatusCriticality,

  /* --- Virtual Element --- */
  @EndUserText.label: 'Dni do startu'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_EVENT_DAYS_CALS'
  cast( '' as abap.char(132) ) as DaysToStart,
  /* ------------------------- */
      
  case 
      when dats_days_between( $session.system_date, start_date ) < 1 then 1
      when dats_days_between( $session.system_date, start_date ) < 3 then 2
      else 3
  end as StartTimeCriticality,
    
  _Registrations,
  _StatusVH
}
