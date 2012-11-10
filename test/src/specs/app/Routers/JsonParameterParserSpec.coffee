describe "JsonParameterParser specs", ->
  p = new AppEngine.Routers.JsonParameterParser();
  page1 = {
    pageName: "p1",
    params: { 
      'foo1': 1, 
      'bar1': 'foofoo'
    }
  }

  page2 = {
    pageName: "p2",
    params: { 
      'foo2': 2, 
      'bar2': 'foo2foo2'
    }
  }

  describe "parseParameters", ->
    it "should parse JSON that has the incorrect string terminators in the parameter keys", ->
      url = "p1/{ 'foo1': 1, 'bar1': 'foofoo' }"
      pageAndParams = p.parseParameters(url)
      expect(pageAndParams[0]).toEqual(page1)

    it "should parse 2 pages and parameters", ->
      url = "p1/" + encodeURIComponent(JSON.stringify(page1.params)) + "/p2/" + JSON.stringify(page2.params)

      pageAndParams = p.parseParameters(url)

      expect(pageAndParams.length).toEqual(2)
      expect(pageAndParams[0]).toEqual(page1)
      expect(pageAndParams[1]).toEqual(page2)
      
    it "should parse 3 pages and null params", ->
      url = "p1/{ 'foo1': 1, 'bar1': 'foofoo' }/p2//p3"
      p = new AppEngine.Routers.JsonParameterParser();

      pageAndParams = p.parseParameters(url)

      expect(pageAndParams.length).toEqual(3)
      expect(pageAndParams[0]).toEqual(page1)
      expect(pageAndParams[1]).toEqual({ pageName: "p2", params: null })
      expect(pageAndParams[2]).toEqual({ pageName: "p3", params: null })

    it "should fail on invalid page parameter", ->
      url = "p1/{ 'foo1': 1, 'Invalid_JSON': "
      p = new AppEngine.Routers.JsonParameterParser();

      expect(->
        p.parseParameters(url)
      ).toThrow(new Error "Routing: p1: Error parsing params")
      
