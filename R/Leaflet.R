Leaflet = setRefClass('Leaflet', contains = 'rCharts', methods = list(
  initialize = function(){
    callSuper()
    LIB <<- get_lib(system.file('libraries', 'leaflet', package = 'rMaps'))
    .self$tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png')
    params$addons <<- list(enablePopover = FALSE)
  },
  enablePopover = function(e = TRUE){
    params$addons$enablePopover <<- e
  },
  mapOpts = function(worldCopyJump = FALSE, ...){
    params$mapOpts <<- list(..., worldCopyJump = worldCopyJump)
  },
  fullScreen = function(e = TRUE){
    params$addons$fullscreen <<- e
  },
  setView = function(center, zoom = 10, ...){
    params <<- c(params, list(center = center, zoom = zoom))
  },
  tileLayer = function(urlTemplate, provider = NULL, ...){
    if (!is.null(provider)){
      params$provider <<- provider
    } else {
      params$urlTemplate <<- urlTemplate
      params$layerOpts <<- list(..., 
        attribution =  'Map data<a href="http://openstreetmap.org">OpenStreetMap</a>
         contributors, Imagery<a href="http://mapbox.com">MapBox</a>'
      )
    }
  },
  marker = function(LatLng, ...){
    m = list(
      marker = as.list(LatLng),
      addTo = '#! map !#',
      ...
    )
    params$marker <<- c(params$marker, list(m))
  },
  circle = function(LatLng, radius = 500, ...){
    circle_ = list(
      circle = LatLng,
      setRadius = radius,
      ...,
      addTo = '#! map !#'
    )
    params$circle <<- c(params$circle, list(circle_))
  },
  circle2 = function(circleData){
    require(plyr)
    dat = alply(circleData, 1, function(c){
      list(
        center = list(c$lat, c$lng), 
        radius = c$radius, 
        opts = c[!(names(c) %in% c('lat', 'lng', 'radius'))])
    })
    params$circle2 <<- setNames(dat, nm = NULL)
  },
  geocsv = function(data){
    paste2 = function(...) {paste(..., sep = ';')}
    params$addons$geocsv <<- TRUE
    params$geocsv <<- list(
      titles = names(data),
      data = paste(do.call('paste2', data), collapse = '\n')
    )
  },
  geoJson = function(list_, ...){
    params$addons$geoJson <<- TRUE
    params$features <<- list_
    dotlist = list(...)
    if (length(dotlist) > 0){
      params$geoJson <<- list(...)
    } else {
      params$geoJson <<- FALSE
    }
  },
  addKML = function(kmlFile){
    params$addons$kml <<- TRUE
    params$kml <<- kmlFile
  },
  legend = function(position, colors, labels){
    params$addons$legend <<- TRUE
    params$legend <<- list(position = position, colors = colors, labels = labels)
  },
  getPayload = function(chartId){
    skip = c('marker', 'circle', 'addons', 'geoJson', 'kml')
    geoJson = toJSON2(params$geoJson)
    kml = toJSON2(params$kml)
    marker = paste(lapply(params$marker, toChain, obj =  'L'), collapse = '\n')
    # circle = paste(lapply(params$circle, toChain, obj =  'L'), collapse = '\n')
    circle = toChain(params$circle, obj = 'L')
    chartParams = toJSON(params[!(names(params) %in% skip)], digits = 13)
    list(
      chartParams = chartParams, 
      chartId = chartId, 
      lib = basename(lib),
      marker = marker,
      circle = circle,
      addons = params$addons,
      geoJson = geoJson,
      kml = kml
    )
  }
))

rqMap <- function(location = "montreal", ...){
  myMap = Leaflet$new()
  myMap$setView(c(LngLat$lat, LngLat$lon), ...)
  return(myMap)
}



# data1 = makeChoroData(
#   cut(Adult_Obesity_Rate, 5, labels = F) ~ state | Mandates_BMI_Screening,
#   data = obesity,
#   pal = 'PuRd'
# )
# 
# data2 = llply(data1, processChoroData, 
#   x =cut(Adult_Obesity_Rate, 5, labels = F) ~ state | Mandates_BMI_Screening,
#   pal = 'PuRd', map = 'usa'
# )

