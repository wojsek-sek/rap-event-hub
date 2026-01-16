@EndUserText.label: 'Anulowanie Wydarzenia'
define abstract entity ZI_EventCancel_Popup_WS
{
  @EndUserText.label: 'Powód Anulowania'
  @UI.defaultValue: '01'
  @Consumption.valueHelpDefinition: [ { 
    entity: { 
        name:    'ZI_Cancel_reason_VH_WS',
        element: 'CancelReason'
    }
  } ]
  reason : abap.char(255);
}
