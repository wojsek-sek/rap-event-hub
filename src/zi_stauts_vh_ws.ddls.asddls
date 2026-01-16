@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Status'
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZI_STAUTS_VH_WS
  as select from zstatus_ws
  
  association [0..1] to ZI_STATUS_TEXT_WS as _Text 
    on $projection.Status = _Text.StatusId
    and _Text.Language    = $session.system_language
{
      @ObjectModel.text.element: [ 'Description' ]
  key status_id as Status,
  
      _Text.Description,
      
      _Text
}
