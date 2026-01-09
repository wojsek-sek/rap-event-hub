@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Venus Value Help CDS View for Event Hub'
@Search.searchable: true
define view entity ZI_VENUE_VH_WS as select from zvenue_ws
{
    @UI.hidden: true
    key venue_id as VenueId,
    
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.8
    @UI.lineItem: [{ position: 10, label: 'Nazwa Obiektu' }]
    @EndUserText.label : 'Name'
    name as VenueName,
    
    @Search.defaultSearchElement: true
    @UI.lineItem: [{ position: 20, label: 'Miasto' }]
    city as City,
    
    street as Street
}
