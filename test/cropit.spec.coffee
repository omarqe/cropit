imageUrl = 'http://example.com/image.jpg'
imageData = 'data:image/png;base64,image-data...'

describe 'Cropit', ->

  cropit = null

  it 'sets default options', ->
    cropit = new Cropit
    expect(cropit.options.exportZoom).toBe 1
    expect(cropit.options.imageBackground).toBe false
    expect(cropit.options.imageBackgroundBorderSize).toBe 0
    expect(cropit.options.imageState).toBe null

  describe 'init()', ->

    it 'sets default sliderPos', ->
      cropit = new Cropit
      expect(cropit.sliderPos).toBe cropit.initialZoomSliderPos

    it 'sets default offset', ->
      cropit = new Cropit
      expect(cropit.offset).toEqual x: 0, y: 0

    it 'restores imageState', ->
      cropit = new Cropit null,
        imageState:
          src: imageUrl
          offset: x: -1, y: -1
          zoom: .5
          sliderPos: .75
      expect(cropit.imageSrc).toBe imageUrl
      expect(cropit.sliderPos).toBe .75
      expect(cropit.zoom).toBe .5
      expect(cropit.offset).toEqual x: -1, y: -1

    it 'calls loadImage() if image source is present', ->
      cropit = new Cropit null,
        imageState:
          src: imageUrl
      spyOn cropit, 'loadImage'

      cropit.init()
      expect(cropit.loadImage).toHaveBeenCalled()

  describe 'onFileReaderLoaded()', ->

    beforeEach ->
      cropit = new Cropit

    it 'calls loadImage()', ->
      spyOn cropit, 'loadImage'

      cropit.onFileReaderLoaded target: result: imageData
      expect(cropit.loadImage).toHaveBeenCalled()

    it 'resets zoom slider', ->
      cropit.sliderPos = 1
      expect(cropit.sliderPos).not.toBe 0

      cropit.onFileReaderLoaded target: result: imageData
      expect(cropit.sliderPos).toBe 0

    it 'resets offset', ->
      cropit.offset = x: 1, y: 1
      expect(cropit.offset).not.toEqual x: 0, y: 0

      cropit.onFileReaderLoaded target: result: imageData
      expect(cropit.offset).toEqual x: 0, y: 0

  describe 'handlePreviewEvent()', ->

    previewEvent =
      type: 'mousedown'
      clientX: 1
      clientY: 1
      stopPropagation: ->

    beforeEach ->
      cropit = new Cropit

    it 'sets origin coordinates on mousedown', ->
      expect(cropit.origin).not.toEqual x: 1, y: 1

      cropit.disabled = false
      cropit.handlePreviewEvent previewEvent
      expect(cropit.origin).toEqual x: 1, y: 1

    it 'calls stopPropagation()', ->
      spyOn previewEvent, 'stopPropagation'
      cropit.disabled = false
      cropit.handlePreviewEvent previewEvent
      expect(previewEvent.stopPropagation).toHaveBeenCalled()

    it 'does nothing when disabled', ->
      spyOn previewEvent, 'stopPropagation'
      cropit.handlePreviewEvent previewEvent
      expect(cropit.origin).not.toEqual x: 1, y: 1
      expect(previewEvent.stopPropagation).not.toHaveBeenCalled()

  describe 'fixOffset()', ->

    beforeEach ->
      cropit = new Cropit

    describe 'fixes x', ->

      it 'fits image to left if image width is less than preview', ->
        cropit.imageSize = w: 1
        cropit.zoom = .5
        cropit.previewSize = w: 1
        offset = cropit.fixOffset x: -1
        expect(offset.x).toBe 0

      it 'fits image to left', ->
        cropit.imageSize = w: 4
        cropit.zoom = .5
        cropit.previewSize = w: 1
        offset = cropit.fixOffset x: 1
        expect(offset.x).toBe 0

      it 'fits image to right', ->
        cropit.imageSize = w: 4
        cropit.zoom = .5
        cropit.previewSize = w: 1
        offset = cropit.fixOffset x: -2
        expect(offset.x).toBe -1

      it 'rounds x', ->
        cropit.imageSize = w: 4
        cropit.zoom = .5
        cropit.previewSize = w: 1
        offset = cropit.fixOffset x: -.25
        expect(offset.x).toBe 0

    describe 'fixes y', ->

      it 'fits image to top if image height is less than preview', ->
        cropit.imageSize = h: 1
        cropit.zoom = .5
        cropit.previewSize = h: 1
        offset = cropit.fixOffset y: -1
        expect(offset.y).toBe 0

      it 'fits image to top', ->
        cropit.imageSize = h: 4
        cropit.zoom = .5
        cropit.previewSize = h: 1
        offset = cropit.fixOffset y: 1
        expect(offset.y).toBe 0

      it 'fits image to bottom', ->
        cropit.imageSize = h: 4
        cropit.zoom = .5
        cropit.previewSize = h: 1
        offset = cropit.fixOffset y: -2
        expect(offset.y).toBe -1

      it 'rounds y', ->
        cropit.imageSize = h: 4
        cropit.zoom = .5
        cropit.previewSize = h: 1
        offset = cropit.fixOffset y: -.25
        expect(offset.y).toBe 0

  describe 'isZoomable()', ->

    it 'returns zoomer.isZoomable', ->
      cropit = new Cropit

      cropit.zoomer = isZoomable: -> true
      expect(cropit.isZoomable()).toBe true

      cropit.zoomer = isZoomable: -> false
      expect(cropit.isZoomable()).toBe false

  describe 'getImageState()', ->

    it 'returns image state', ->
      cropit = new Cropit
      cropit.imageSrc = imageData
      cropit.offset = x: -1, y: -1
      cropit.zoom = .5
      cropit.sliderPos = .75
      imageState = cropit.getImageState()
      expect(imageState.src).toBe imageData
      expect(imageState.offset).toEqual x: -1, y: -1
      expect(imageState.zoom).toBe .5
      expect(imageState.sliderPos).toBe .75

  describe 'getImageSize()', ->

    beforeEach ->
      cropit = new Cropit

    it 'returns image size', ->
      cropit.imageSize = w: 1, h: 1
      expect(cropit.getImageSize()).toEqual width: 1, height: 1

    it 'returns null when imageSize is absent', ->
      expect(cropit.getImageSize()).toBe null
