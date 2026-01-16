@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZEVENT_HUB'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZI_EVENT_WS
  as select from zaevent_ws 
  composition [0..*] of ZI_REG_WS as _Registrations
  association [0..1] to ZI_STAUTS_VH_WS as _StatusVH on $projection.Status = _StatusVH.Status
  association [0..1] to ZI_TFRAME_TXT_WS as _TxtPast 
  on _TxtPast.TimeCode = 'PAST' and _TxtPast.Language = $session.system_language
  association [0..1] to ZI_TFRAME_TXT_WS as _TxtToday
  on _TxtToday.TimeCode = 'TODAY' and _TxtToday.Language = $session.system_language
  association [0..1] to ZI_TFRAME_TXT_WS as _TxtPfx
  on _TxtPfx.TimeCode = 'PFX' and _TxtPfx.Language = $session.system_language
  association [0..1] to ZI_TFRAME_TXT_WS as _TxtSfx
  on _TxtSfx.TimeCode = 'SFX' and _TxtSfx.Language = $session.system_language
{
  key event_uuid as EventUUID,
  event_id as EventID,
  title as Title,
  location as Location,
  start_date as StartDate,
  end_date as EndDate,
  status as Status,
  cast( max_seats      as abap.int4 ) as MaxSeats,
  cast( occupied_seats      as abap.int4 ) as OccupiedSeats,
  cancel_reason as CancelReason,
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
    
    
    @EndUserText.label: 'Dni do startu'
    case
      when dats_days_between( $session.system_date, start_date ) = 0 then _TxtToday.Text
      when dats_days_between( $session.system_date, start_date ) < 0 then _TxtPast.Text
      else concat( coalesce( _TxtPfx.Text, '' ), concat( cast( dats_days_between( $session.system_date, start_date ) as abap.char(12) ), coalesce( _TxtSfx.Text, '' ) ) )
    end as DaysToStart,
      
    case 
      when dats_days_between( $session.system_date, start_date ) < 1 then 1
      when dats_days_between( $session.system_date, start_date ) < 3 then 2
      else 3
    end as StartTimeCriticality,
    
    
  /* Expose association (upublicznij relację) */
  _Registrations,
  _StatusVH
}
