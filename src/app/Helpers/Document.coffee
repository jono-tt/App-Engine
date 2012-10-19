helpers = __t('AppEngine.Helpers')

helpers.changeDocumentLocation = (location) ->
  if !_.isUndefined(location)
    console.debug "Document: sending user to location '#{location}'"
    window.location = location

  return null

 