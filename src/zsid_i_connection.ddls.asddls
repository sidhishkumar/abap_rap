@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@UI.headerInfo :{
  typeName: 'Connection',
  typeNamePlural: 'Connections'
}
@Search.searchable: true
define view entity ZSID_I_CONNECTION
  as select from /dmo/connection


  association [*] to ZSID_I_FLIGHT  as _FLIGHT  on  $projection.CarrierId    = _FLIGHT.CarrierId
                                                and $projection.ConnectionId = _FLIGHT.ConnectionId

  association [1] to ZSID_I_CARRIER as _Airline on  $projection.CarrierId = _Airline.CarrierId
  
//  association[1] to ZSID_I_AIRPORT_VH as _Airport on $projection.AirportFromId = _Airport.AirportId

{

      @UI.facet: [{
          id :  'connection',
          purpose: #STANDARD,
          position: 10,
          label: 'Connection Details',
          type: #IDENTIFICATION_REFERENCE
      },

      {
           id :  'flight',
          purpose: #STANDARD,
          position: 20,
          label: 'Flight Details ',
          type: #LINEITEM_REFERENCE,
          targetElement: '_FLIGHT'
      }



      ]


      @UI.lineItem: [{ position: 10, label: 'Airline'  }]
      @UI.identification: [{ position: 10, label: 'Airline' }]
      @ObjectModel.text.association: '_Airline'
      @Search.defaultSearchElement: true
  key carrier_id      as CarrierId,
      @UI.selectionField: [{ position: 10 }]
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @Search.defaultSearchElement: true
  key connection_id   as ConnectionId,
      @UI.selectionField: [{ position: 20 }]
      @UI.lineItem: [{ position: 30, label: 'Airport From Id 2' }]
      @UI.identification: [{ position: 30 }]
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [ { entity : { element: 'AirportId', name: 'ZSID_I_AIRPORT_VH' } } ]
      @EndUserText.label: 'Airport From Id'
      airport_from_id as AirportFromId,
      @UI.lineItem: [{ position: 40 }]
      @UI.selectionField: [{  position: 30  }]
      @UI.identification: [{ position: 40 }]
      @Search.defaultSearchElement: true
       @Consumption.valueHelpDefinition: [ { entity : { element: 'AirportId', name: 'ZSID_I_AIRPORT_VH' } } ]
      airport_to_id   as AirportToId,
      @UI.lineItem: [{ position: 50, label: 'Departure Time' }]
      @UI.identification: [{ position: 50 }]
      departure_time  as DepartureTime,
      @UI.lineItem: [{ position: 60, label: 'Arrival Time' }]
      @UI.identification: [{ position: 60 }]
      arrival_time    as ArrivalTime,
      @UI.identification: [{ position: 70 }]
      @Semantics.quantity.unitOfMeasure: 'DistanceUnit'
      distance        as Distance,
      distance_unit   as DistanceUnit,
        @Search.defaultSearchElement: true
      _FLIGHT,
      @Search.defaultSearchElement: true
      _Airline
//      _Airport
}
