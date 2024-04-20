@EndUserText.label: 'Approver Travel Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@UI.headerInfo : {
  typeName: 'Booking',
  typeNamePlural: 'Bookings',

  title : {
   type: #STANDARD,
   value: 'TravelId'

  }


}
define root view entity ZSID_C_APPROVER_TRAVEL
  provider contract transactional_query
  as projection on ZSID_I_TRAVEL_M
{
      @UI.facet: [{

      id: 'travel',
      position: 10,
      purpose: #STANDARD,
      type: #IDENTIFICATION_REFERENCE,
      label: 'Travel'
       },

       {
         id : 'booking',
         purpose: #STANDARD,
         type: #LINEITEM_REFERENCE,
         targetElement: '_Booking',
         position: 20,
         label: 'Bookings'

       }
       ]
      @UI.lineItem: [{ type: #FOR_ACTION , label: 'Approve Travel', dataAction: 'acceptTravel' },
                     { type: #FOR_ACTION , label: 'Reject Travel', dataAction: 'rejectTravel' },
                     { position: 10 }]
      @UI.identification: [{ position: 10 },
                           { type: #FOR_ACTION , label: 'Approve Travel', dataAction: 'acceptTravel' },
                           { type: #FOR_ACTION , label: 'Reject Travel', dataAction: 'rejectTravel' }
      ]
  key TravelId,
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @ObjectModel.text.element: [ 'AgencyName' ]
      @UI.selectionField: [{ position: 10 }]
      @Search.defaultSearchElement: true
      AgencyId,

      _Agency.Name       as AgencyName,
      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      //      @ObjectModel.text.association: '_Customer'
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity : { element: 'CustomerID', name: '/DMO/I_Customer'} }]
      @UI.selectionField: [{ position: 20 }]
      @Search.defaultSearchElement: true
      CustomerId,
      //      concat( _Customer.FirstName , _Customer.LastName ) as CustometName  ,
      _Customer.LastName as CustomerName,
      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      BeginDate,

      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      EndDate,
      @UI.identification: [{ position: 60 }]
      BookingFee,
      @UI.identification: [{ position: 70 }]
      TotalPrice,
      @UI.identification: [{ position: 80 }]
      CurrencyCode,
      @UI.identification: [{ position: 90 }]
      Description,
      @UI.identification: [{ position: 100 }]
      @Consumption.valueHelpDefinition: [{ entity : { element: 'OverallStatus', name: '/DMO/I_Overall_Status_VH'} }]
      OverallStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZSID_C_APPROVER_BOOKING,
      _Currency,
      _Customer,
      _Status
}
