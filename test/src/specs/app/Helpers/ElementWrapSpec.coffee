describe "ElementWrapSpec", ->
  describe "Get Tree Structure", ->
    it "should get a tree Structure of all 'components' from the passed in element", ->
      startElement = $j("
        <div id='tree_test' style='display: none;'>
          <div id='p1' class='ae-comp'>
            <div id='p2' class='ae-comp'>
              <div id='p3' class='ae-comp'></div>
            </div>
          </div>
          <div id='p4' class='ae-comp'>
            <!-- p5 does not have the component class -->
            <div id='p5' class=''></div>
          </div>
        </div>")

      structure = AppEngine.Helpers.ElementWrap.getTreeStructure(startElement)

      expect(structure.length).toEqual(2)
      expect(structure[0].el[0].id).toEqual("p1")
      expect(structure[0].children.length).toEqual(1)
      expect(structure[1].el[0].id).toEqual("p4")


  describe "createTree", ->
    it "should create a tree of components to be marked up", ->
