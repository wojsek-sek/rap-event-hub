
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data definition for time frame texts'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #TEXT
define view entity ZWSI_TFRAME_TXT_WS as select from zwstframe_ws_txt
{
    key language as Language,
    key time_code as TimeCode,
    text as Text
}
