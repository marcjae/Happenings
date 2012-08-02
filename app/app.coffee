#Date converted to coffee 2012/07/26
circle = '';
token = '';
authToken = 0;
fourSquareToken = '';
fourSquareClientId = '3ODULPRCZOZL43JVOBNUBAUPXD5MXKBX24DOUZYNO0V3SEUL';
searchRadius = 1200

#Access token functions
redirectUrl = 'http://localhost/development/happenings/index.html'
authorizeApp = (user,api) ->
  
  if api is 'foursquare'
    
    uri = 'https://foursquare.com/oauth2/authenticate?client_id='+clientId+'&response_type=token&redirect_uri='+redirectUrl
  else
    clientId = '5d1ba596dc034a7a8895e309f5f2452f';
    uri = 'https://instagram.com/oauth/authorize/?client_id=' + clientId + '&redirect_uri='+redirectUrl+'&response_type=token'
  return window.location.href = uri;
getToken =  (type) ->
  if type is 'fourSquare'
    return window.location.href.split('#access_token=')[1]
  else
    return window.location.href.split('#access_token=')[1]
tokenCheck = ->
  if window.location.href.indexOf('access_token') > 0
    token = getToken();
  else if window.location.href.indexOf('access_token') > 0
    fourSquareToken = getToken('fourSquare')
  else
    authorizeApp('blah', 'foursquare'); 

#ajax function
request = (long,lat,clientId,photoLayer,venueLayer) ->

  #foursquare demo
  $.ajax({
    type: "GET",
    dataType: "jsonp",
    cache: false,
    url: 'https://api.foursquare.com/v2/venues/explore?ll='+lat+','+long+'&radius='+searchRadius+'&client_id='+fourSquareClientId+'&client_secret='+fourSquareSecret+'&v=20120726',
    success: (venues) ->
      #Foursquare
      venueLayer.clearLayers();
      groups = venues.response.groups[0].items;
      _.each(groups, (item) ->
        
        locationLat = item.venue.location.lat;
        locationLng = item.venue.location.lng;
        object = new L.CircleMarker(new L.LatLng(locationLat, locationLng), {
            radius: 7,
            clickable: true,
            stroke: 0,
            fillOpacity: .5,
            color:'#3ea7d7'
        });
        photoTemplate = _.template($("#popupTemplate_venue").html(), {
          item: item
        });
        object.bindPopup(photoTemplate);        
        venueLayer.addLayer(object);
      )
  });
  
  
  
  if token
    uri = 'https://api.instagram.com/v1/media/search?lat='+lat+'&lng='+long+'&distance='+searchRadius+'&access_token=' + token
  else
    uri = 'https://api.instagram.com/v1/media/search?lat='+lat+'&lng='+long+'&distance='+searchRadius+'&client_id=' + clientId

  $.ajax({
    type: "GET",
    dataType: "jsonp",
    cache: false,
    url: uri,
    success: (photos) ->
      
      photoLayer.clearLayers();
      _.each(photos.data, (photo) ->
        if photo.location 
          object = new L.CircleMarker(new L.LatLng(photo.location.latitude, photo.location.longitude), {
            radius: 7,
            clickable: true,
            stroke: 0,
            fillOpacity: .5,
            color:'#FF9933'
          });
          photoTemplate = _.template($("#popupTemplate").html(), {
            photo: photo
          });
          object.bindPopup(photoTemplate);
          photoLayer.addLayer(object);
      )
   });

#map creation   
mappingTasks = ->
  #map call backs
  onLocationFound = (e) ->
  onLocationError = (e) ->
    map.setView(new L.LatLng(37.76745803822967, - 122.45018005371094), 13).addLayer(tiles);
  onMapClick = (e) ->
    if not circle
      
      radius = parseInt(searchRadius+500)
      
      circle = new L.Circle(e.latlng, radius , {
        color: '#919191',
        fill: true,
        fillOpacity: 0.1,
        weight: 1.5,
        clickable: false,
      });
      map.addLayer(circle)
    else
      circle.setLatLng(e.latlng);
    request(+e.latlng.lng.toFixed(2),e.latlng.lat.toFixed(2),clientId,photoLayer,venueLayer);
  
  #map vars    
  map = new L.Map('map')
  tiles = new L.TileLayer('http://a.tiles.mapbox.com/v3/bobbysud.map-ez4mk2nl/{z}/{x}/{y}.png', {maxZoom: 17})
  photoLayer = new L.LayerGroup();
  venueLayer = new L.LayerGroup();
  clientId = 'f62cd3b9e9a54a8fb18f7e122abc52df'
  map.addLayer(tiles);
  map.on('locationfound', onLocationFound);
  map.on('locationerror', onLocationError);
  map.locateAndSetView(13);  
  map.on('click', onMapClick); 
  map.addLayer(photoLayer); 
  map.addLayer(venueLayer); 
  map.on("popupopen", (e) ->
    date = new Date(parseInt($("#timeago").html()) * 1000);
    $('.leaflet-popup-pane').css({
      'opacity':0,
      'margin-top': 0
    })
    $('#timeago').text($.timeago(date));
    $('.leaflet-popup-pane').animate({
       opacity: 1,
       marginTop: '-5',
       }, 500,  ->
         #do stuff
    )  
    #$('#instagram-profile').children('img').load( ->

    #)
   
  )
  #zoom button
  $('<div>zoom out</div>').addClass('zoom-out').attr('title', 'See somewhere other than San Francisco, the map demo capital of the world.').click( ->
    map.setView(new L.LatLng(40.84706035607122, - 94.482421875), 4);
  ).appendTo($('#map'));  
  


#DOM READY
$(document).ready( ->
  mappingTasks()
  if authToken is 1
    tokenCheck()
)
