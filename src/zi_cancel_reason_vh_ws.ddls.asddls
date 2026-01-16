@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Słownik Cancel Reason z Domeny'


define view entity ZI_CANCEL_REASON_VH_WS
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_CANCEL_REASON_WS' )
{
      @ObjectModel.text.element: [ 'CancelText' ]
      @EndUserText.label: 'Reason'
  key value_low      as CancelReason,

      /* KLUCZE TECHNICZNE */
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @EndUserText.label: 'Cancelation Reason'
      text           as CancelText
}
where language = $session.system_language
