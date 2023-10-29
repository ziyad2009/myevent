const String meQuery = r'''query getme{
  me{
    id
    __typename
    username
    email
    confirmed
    blocked
  }
}''';

const String profileInfoQuery = r'''query getprofile($field: ID!){
  user(id: $field)
  {
    id
    __typename
    username
    email
    fullName
    phone
    shortBio
    aboutDescription
    facebookLink
    websiteLink
  }
}''';

const String loadSingleAd = r'''query singlead($field: ID!){
  userAd(id: $field){
    id
    __typename
    title
    createdAt
    adStatus
    isFeatured
    sellerDesignation
   seller
  {
    id
    __typename
    username
    email
    
    fullName
    phone
    shortBio
    firebaseID
    aboutDescription
    facebookLink
    websiteLink
    profilePicture{
      id
      url
    }
    coverImage{
      id
      url
    }
  }
    price
    description
    venueLat
    venueLon
    venueAddress
    venueTypes{
      id
      typeName
      typeIcon{
        id
        url
      }
    }
    accommodation
    area
    availableTill
    timeStart
    timeEnd
    perkList{
      id
      perkName
    }
    unavailableDates{
      id
      unavailable
      offlineByVendor
    }
    adImages{
      id
      url
    }
    propertyVideo{
      id
      url
    }
  }
}''';

const String loadSavedAds = r'''query getsaved($field: ID!){
  user(id: $field)
  {
    id
    __typename
    savedAds{
      id
    }
  }
}''';

const String loadSavedDetail = r'''query getsaveddetail($field: ID!){
  user(id: $field)
  {
    savedAds{
      id
      __typename
    title
    seller
  {
    id
    __typename
    username
    email
    fullName
    phone
    shortBio
    aboutDescription
    facebookLink
    websiteLink
    profilePicture{
      id
      url
    }
    coverImage{
      id
      url
    }
    aboutDescription
    aboutImages{
      id
      url
    }
  }
    price
    description
    address
    accommodation
    area
    availableTill
    timeStart
    timeEnd
    isFeatured
    perkList{
      id
      perkName
    }
    adImages{
      id
      url
    }
  }
    }
  }''';

const String loadAds =
    r'''query aditems($start : Int, $limit: Int, $field: JSON, $sort: String){
  userAds(start: $start, limit: $limit, where: $field, sort: $sort){
    id
    __typename
    title
    createdAt
    price
    description
    accommodation
    area
    timeStart
    timeEnd
    venueLat
    venueLon
    venueAddress
    isFeatured
    venueTypes{
      id
      typeName
      typeIcon{
        id
        url
      }
    }
    featuredImage{
      id
      url
    }
    adImages{
      id
      url
    }
  }
}''';

const loadTrackedAds = r'''query loadsavedads($field: ID!)
{
  user(id: $field)
  {
    savedAds{
       id
    __typename
    title
    createdAt
    price
    description
    venueLat
    venueLon
    venueAddress
    accommodation
    area
    venueTypes{
      id
      typeName
      typeIcon{
        id
        url
      }
    }
    timeStart
    timeEnd
    adImages{
      id
      url
    }
    }
  }
}''';

const String getVenueTypes = r'''query getVenueTypes{
  venueTypes{
    id
    typeName
    typeIcon{
      id
      url
    }
  }
}''';

const String anyProfileInfo = r'''query getprofile($field: ID!){
  user(id: $field)
  {
    id
    __typename
    username
    email
    fullName
    phone
    shortBio
    aboutDescription
    facebookLink
    websiteLink
    profilePicture{
      id
      url
    }
    coverImage{
      id
      url
    }
    aboutDescription
    aboutImages{
      id
      url
    }
  }
}''';

const String searchUsersQuery = r'''query usersearch($fields: JSON){
  users(where: $fields){
    id
   	fullName
    username
    confirmed
    blocked
    phone
    firebaseID
    profilePicture{
      id
      url
    }
  }
}''';

const String loadReviews = r'''query getreviews($field: JSON)
{
  reviews(where: $field, sort: "createdAt:desc")
  {
    id
    content
    stars
    reviewer{
      id
      username
      fullName
      confirmed
      phone
      blocked
      firebaseID
      profilePicture{
        id
        url
      }
    }
  }
}''';

const String ratingAverage = r'''query getReviewAverage($field: JSON)
{
  reviewsConnection(where: $field){
    aggregate{
      count
      avg{
        stars
      }
    }
  }
}''';

const String fetchPerks = r'''query perks{
  perks{
    id
    perkName
  }
}''';

const String fetchSingleService = r'''query getSingleService($field: ID!)
{
  service(id: $field)
  {
    id
      __typename
      name
      description
      createdAt
      updatedAt
      adStatus
      serviceAddress
      serviceLat
      serviceLon
      pricePerDay
      unavailableDates{
        id
        unavailable
        offlineByVendor
      }
   	  perkList{
        id
        perkName
      }
    	isPremium
      provider
  		{
    	id
      __typename
      username
      email
      fullName
      phone
      shortBio
      firebaseID
      aboutDescription
      facebookLink
      websiteLink
      profilePicture{
      id
      url
    	}
    	coverImage{
      	id
      	url
    	}
  	}
    	servicePhotos{
        id
        url
      }
      serviceFeatureImage{
        id
        url
      }
      serviceVideo{
        id
        url
      }
  }
}''';

const String getServiceItems =
    r'''query getServiceItems($field: JSON!, $sort: String)
{
  services(where: $field, sort: $sort){
    id
    name
    createdAt
    serviceAddress
    serviceFeatureImage{
      id
      url
    }
    pricePerDay
    isPremium
    description
    perkList{
      id
      perkName
    }
  }
}''';

const loadTrackedServices = r'''query loadtrackedservices($field: ID!)
{
  user(id: $field)
  {
    savedServices{
    id
    name
    createdAt
    serviceAddress
    serviceFeatureImage{
      id
      url
    }
    pricePerDay
    isPremium
    description
    perkList{
      id
      perkName
    }
  }
  }
}''';

const String savedServicesListQuery = r'''query SavedServicesIDs($field: ID!)
{
  user(id: $field)
  {
    savedServices{
    	id
  	}
  }
}''';

const String getOfflineDates = r'''query getOfflineDates($field: JSON!)
{
  offlineDates(where: $field)
  {
    id
    unavailable
    offlineByVendor
  }
}''';

const String getVenueBookingDates = r'''query VenueBookingDates($field: ID!)
{
  booking(id: $field)
  {
    bookedDates{
      id
      unavailable
      offlineByVendor
    }
    booker{
      id
      __typename
      username
      email
      fullName
      phone
      shortBio
      firebaseID
      aboutDescription
      facebookLink
      websiteLink
      profilePicture{
      id
      url
    	}
    	coverImage{
      	id
      	url
    	}
    }
  }
}''';

const String getServiceBookingDates = r'''query ServiceBookingDates($field: ID!)
{
  serviceBooking(id: $field)
  {
    bookedDates{
      id
      unavailable
      offlineByVendor
    }
    booker{
      id
      __typename
      username
      email
      fullName
      phone
      shortBio
      firebaseID
      aboutDescription
      facebookLink
      websiteLink
      profilePicture{
      id
      url
    	}
    	coverImage{
      	id
      	url
    	}
    }
  }
}''';

const String fetchMyServiceBookings =
    r'''query getServiceBookings($field: JSON!)
{
  serviceBookings(where: $field)
  {
    id
    netPayment
    status
    paymentStatus
    service{
      id
    name
    createdAt
    serviceAddress
    serviceFeatureImage{
      id
      url
    }
    pricePerDay
    isPremium
    description
    perkList{
      id
      perkName
    }
    }
  }
}''';

const String fetchMyVenueBookings = r'''query getServiceBookings($field: JSON!)
{
  bookings(where: $field)
  {
    id
    netPayment
    status
    paymentStatus
    property{
      id
    __typename
    title
    createdAt
    price
    description
    accommodation
    area
    timeStart
    timeEnd
    venueLat
    venueLon
    venueAddress
    isFeatured
    venueTypes{
      id
      typeName
      typeIcon{
        id
        url
      }
    }
    featuredImage{
      id
      url
    }
    adImages{
      id
      url
    }
  	}
}
}''';
