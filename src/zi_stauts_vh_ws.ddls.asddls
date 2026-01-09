@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Słownik Statusów z Domeny'
@ObjectModel.resultSet.sizeCategory: #XXS

define view entity ZI_Stauts_VH_WS
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_EVENT_STATUS_WS' )
{
      @UI.textArrangement: #TEXT_ONLY
      @ObjectModel.text.element: [ 'StatusText' ]

  key value_low      as Status,

      /* KLUCZE TECHNICZNE */
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
  
      text           as StatusText,
      @UI.hidden: true
      case value_low
        when 'O' then 3 
        when 'F' then 2 
        when 'X' then 1 
        when 'D' then 0 
        else 0          
      end            as Criticality
}
where language = $session.system_language
