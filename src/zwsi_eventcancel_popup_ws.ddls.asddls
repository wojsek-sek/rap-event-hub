@EndUserText.label: 'Anulowanie Wydarzenia'
define abstract entity ZWSI_EventCancel_Popup_WS
{
  @EndUserText.label: 'Powód Anulowania'
  @UI.defaultValue: '01'
  @Consumption.valueHelpDefinition: [ { 
    entity: { 
        name:    'ZWSI_Cancel_reason_VH_WS',
        element: 'CancelReason'
    }
  } ]
  reason : abap.char(255);
}
