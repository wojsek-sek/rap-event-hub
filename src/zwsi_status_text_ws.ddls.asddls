@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status Text View'
@ObjectModel.dataCategory: #TEXT

define view entity ZWSI_STATUS_TEXT_WS
  as select from zwsstatus_txt_ws
{
  key language  as Language,
  key status_id as StatusId,
      description as Description
}
