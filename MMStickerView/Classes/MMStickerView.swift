//
//  MMStickerView.swift
//  ImageCut
//
//  Created by Miles on 2022/12/2.
//

import UIKit


class MMStickerView:UIView,StickerViewDelegate{
    
    private var imageView:UIImageView = UIImageView()
    private var contentSticks:[MMStickerContentView] = []
    var contentInset:UIEdgeInsets = .zero{didSet{
        self.layoutSubviews()
    }}
    
    var image:UIImage? = nil{didSet{
        imageView.image = image
    }}
    weak var delegate:StickerViewDelegate? = nil
    
    init(image:UIImage){
        super.init(frame: .zero)
        self.image = image
        self.imageView.image = image
        setupUI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        
        self.clipsToBounds = true
        self.imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)
        imageView.tag = 10000
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = .init(x: contentInset.left, y: contentInset.top, width: self.bounds.size.width-contentInset.left-contentInset.right, height: self.bounds.size.height-contentInset.top-contentInset.bottom)
    }
    
    private var _selectedStickerView:MMStickerContentView?
    var currentStickerView:MMStickerContentView? {
        get {
            return _selectedStickerView
        }
        set {
            // if other sticker choosed then resign the handler
            if _selectedStickerView != newValue {
                if let currentStickerView = _selectedStickerView {
                    currentStickerView.showEditingHandlers = false
                }
                _selectedStickerView = newValue
            }
            // assign handler to new sticker added
            if let currentStickerView = _selectedStickerView {
                currentStickerView.showEditingHandlers = true
                currentStickerView.superview?.bringSubviewToFront(currentStickerView)
            }
        }
    }
    
    
    /// 添加贴纸(自动除重)
    /// - Parameter item: MMPhotoStickItem
    public func addStick(item:MMPhotoStickItem){
        
        if let stickView = contentSticks.filter({$0.tag == item.section}).first{
            
            (stickView.contentView as! UIImageView).image = item.image
            self.currentStickerView = stickView
            
        }else{
            
            let testImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 240, height: 240))
            testImage.image = item.image
            testImage.contentMode = .scaleAspectFit
            let stickerView3 = MMStickerContentView.init(contentView: testImage)
            stickerView3.center = CGPoint.init(x: 150, y: 150)
            stickerView3.delegate = self
            stickerView3.setImage(UIImage.init(named: "Close")!, forHandler: StickerViewHandler.close)
            stickerView3.setImage(UIImage.init(named: "Rotate")!, forHandler: StickerViewHandler.rotate)
            //           stickerView3.setImage(UIImage.init(named: "Flip")!, forHandler: StickerViewHandler.flip)
            stickerView3.showEditingHandlers = false
            stickerView3.tag = item.section
            self.addSubview(stickerView3)
            self.contentSticks.append(stickerView3)
            self.currentStickerView = stickerView3
        }
    }
    
    /// 移除全部贴纸
    public func removeAllStick(){
        
        for (index,stick) in self.contentSticks.enumerated().reversed(){
            stick.removeFromSuperview()
            self.contentSticks.remove(at: index)
        }
    }
    
    /// 移除贴纸
    /// - Parameter stickerView: 贴纸
    public func removeStick(_ stickerView:MMStickerContentView){
        if contentSticks.contains(stickerView){
            contentSticks = contentSticks.enumerated().compactMap({_,element in element.tag == stickerView.tag ? nil : element})
            stickerView.removeFromSuperview()
        }
    }
    
    
    /// 选中贴纸
    /// - Parameter selectIndex: Section
    public func selectedStickView(_ selectIndex:Int){
        
        for stickView in self.contentSticks where selectIndex == stickView.tag{
            self.currentStickerView = stickView;
            break
        }
    }
    
    /// 选中贴纸
    /// - Parameter stickView: MMStickerContentView
    public func selectedStickView(_ stickView:MMStickerContentView){
        
        if contentSticks.contains(stickView){
            self.currentStickerView = stickView
        }
    }
    
    
    public func getResultImage()->UIImage?{
        
        currentStickerView?.showEditingHandlers = false
        
        if self.subviews.filter({$0.tag <= 9999}).count > 0 {
            if let image = mergeImages(view: self){
                return image
            }else{
                print("Image not found !!")
                return nil
            }
        }else{
            return nil
        }
    }
    
    private  func mergeImages(view: UIView) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    func stickerViewDidTap(_ stickerView: MMStickerContentView) {
        self.currentStickerView = stickerView
        delegate?.stickerViewDidTap(stickerView)
    }
    
    func stickerViewDidBeginMoving(_ stickerView: MMStickerContentView) {
        self.currentStickerView = stickerView
        delegate?.stickerViewDidBeginMoving(stickerView)
    }
    
    func stickerViewDidChangeMoving(_ stickerView: MMStickerContentView) {
        delegate?.stickerViewDidChangeMoving(stickerView)
    }
    
    func stickerViewDidEndMoving(_ stickerView: MMStickerContentView) {
        delegate?.stickerViewDidEndMoving(stickerView)
    }
    
    func stickerViewDidBeginRotating(_ stickerView: MMStickerContentView) {
        delegate?.stickerViewDidBeginRotating(stickerView)
    }
    
    func stickerViewDidChangeRotating(_ stickerView: MMStickerContentView) {
        delegate?.stickerViewDidChangeRotating(stickerView)
    }
    
    func stickerViewDidEndRotating(_ stickerView: MMStickerContentView) {
        delegate?.stickerViewDidEndRotating(stickerView)
    }
    
    func stickerViewDidClose(_ stickerView: MMStickerContentView) {
        
        contentSticks = contentSticks.enumerated().compactMap({_,element in element.tag == stickerView.tag ? nil : element})
        delegate?.stickerViewDidClose(stickerView)
    }
}


public enum StickerViewHandler:Int {
    case close = 0
    case rotate
    case flip
}

public enum StickerViewPosition:Int {
    case topLeft = 0
    case topRight
    case bottomLeft
    case bottomRight
}

@inline(__always) func CGRectGetCenter(_ rect:CGRect) -> CGPoint {
    return CGPoint(x: rect.midX, y: rect.midY)
}

@inline(__always) func CGRectScale(_ rect:CGRect, wScale:CGFloat, hScale:CGFloat) -> CGRect {
    return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * wScale, height: rect.size.height * hScale)
}

@inline(__always) func CGAffineTransformGetAngle(_ t:CGAffineTransform) -> CGFloat {
    return atan2(t.b, t.a)
}

@inline(__always) func CGPointGetDistance(point1:CGPoint, point2:CGPoint) -> CGFloat {
    let fx = point2.x - point1.x
    let fy = point2.y - point1.y
    return sqrt(fx * fx + fy * fy)
}

@objc public  protocol StickerViewDelegate {
    @objc func stickerViewDidBeginMoving(_ stickerView: MMStickerContentView)
    @objc func stickerViewDidChangeMoving(_ stickerView: MMStickerContentView)
    @objc func stickerViewDidEndMoving(_ stickerView: MMStickerContentView)
    @objc func stickerViewDidBeginRotating(_ stickerView: MMStickerContentView)
    @objc func stickerViewDidChangeRotating(_ stickerView: MMStickerContentView)
    @objc func stickerViewDidEndRotating(_ stickerView: MMStickerContentView)
    @objc func stickerViewDidClose(_ stickerView: MMStickerContentView)
    @objc func stickerViewDidTap(_ stickerView: MMStickerContentView)
}

public class MMStickerContentView: UIView {
    
    
    public var delegate: StickerViewDelegate!
    /// The contentView inside the sticker view.
    public var contentView:UIView!
    /// Enable the close handler or not. Default value is YES.
    public var enableClose:Bool = true {
        didSet {
            if self.showEditingHandlers {
                self.setEnableClose(self.enableClose)
            }
        }
    }
    /// Enable the rotate/resize handler or not. Default value is YES.
    public var enableRotate:Bool = true{
        didSet {
            if self.showEditingHandlers {
                self.setEnableRotate(self.enableRotate)
            }
        }
    }
    /// Enable the flip handler or not. Default value is YES.
    public var enableFlip:Bool = true
    /// Show close and rotate/resize handlers or not. Default value is YES.
    public var showEditingHandlers:Bool = true {
        didSet {
            if self.showEditingHandlers {
                self.setEnableClose(self.enableClose)
                self.setEnableRotate(self.enableRotate)
                self.setEnableFlip(self.enableFlip)
                self.contentView?.layer.borderWidth = 0.7
            }
            else {
                self.setEnableClose(false)
                self.setEnableRotate(false)
                self.setEnableFlip(false)
                self.contentView?.layer.borderWidth = 0
            }
        }
    }
    
    /// Minimum value for the shorter side while resizing. Default value will be used if not set.
    private var _minimumSize:NSInteger = 0
    public  var minimumSize:NSInteger {
        set {
            _minimumSize = max(newValue, self.defaultMinimumSize)
        }
        get {
            return _minimumSize
        }
    }
    /// Color of the outline border. Default: brown color.
    private var _outlineBorderColor:UIColor = .clear
    public  var outlineBorderColor:UIColor {
        set {
            _outlineBorderColor = newValue
            self.contentView?.layer.borderColor = _outlineBorderColor.cgColor
        }
        get {
            return _outlineBorderColor
        }
    }
    /// A convenient property for you to store extra information.
    public  var userInfo:Any?
    
    /**
     *  Initialize a sticker view. This is the designated initializer.
     *
     *  @param contentView The contentView inside the sticker view.
     *                     You can access it via the `contentView` property.
     *
     *  @return The sticker view.
     */
    public  init(contentView: UIView) {
        self.defaultInset = 25/2
        self.defaultMinimumSize = 4 * self.defaultInset
        
        var frame = contentView.frame
        frame = CGRect(x: 0, y: 0, width: frame.size.width + CGFloat(self.defaultInset) * 2, height: frame.size.height + CGFloat(self.defaultInset) * 2)
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.addGestureRecognizer(self.moveGesture)
        self.addGestureRecognizer(self.tapGesture)
        
        // Setup content view
        self.contentView = contentView
        self.contentView.center = CGRectGetCenter(self.bounds)
        self.contentView.isUserInteractionEnabled = false
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.layer.allowsEdgeAntialiasing = true
        self.addSubview(self.contentView)
        
        // Setup editing handlers
        self.setPosition(.topLeft, forHandler: .close)
        self.addSubview(self.closeImageView)
        
        self.setPosition(.bottomRight, forHandler: .rotate)
        self.addSubview(self.rotateImageView)
        
        self.setPosition(.bottomLeft, forHandler: .flip)
        self.addSubview(self.flipImageView)
        
        self.showEditingHandlers = true
        self.enableClose = true
        self.enableRotate = true
        self.enableFlip = true
        
        self.minimumSize = self.defaultMinimumSize
        self.outlineBorderColor = UIColor.init(hex: "#C1C1C1")
    }
    
    public  required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     *  Use image to customize each editing handler.
     *  It is your responsibility to set image for every editing handler.
     *
     *  @param image   The image to be used.
     *  @param handler The editing handler.
     */
    public func setImage(_ image:UIImage, forHandler handler:StickerViewHandler) {
        switch handler {
        case .close:
            self.closeImageView.image = image
        case .rotate:
            self.rotateImageView.image = image
        case .flip:
            self.flipImageView.image = image
        }
    }
    
    /**
     *  Customize each editing handler's position.
     *  If not set, default position will be used.
     *  @note  It is your responsibility not to set duplicated position.
     *
     *  @param position The position for the handler.
     *  @param handler  The editing handler.
     */
    
    public func setPosition(_ position:StickerViewPosition, forHandler handler:StickerViewHandler) {
        let origin = self.contentView.frame.origin
        let size = self.contentView.frame.size
        let offset = CGFloat(defaultInset)
        
        var handlerView:UIImageView?
        switch handler {
        case .close:
            handlerView = self.closeImageView
        case .rotate:
            handlerView = self.rotateImageView
        case .flip:
            handlerView = self.flipImageView
        }
        
        
        switch position {
        case .topLeft:
            //            handlerView?.center = origin
            handlerView?.center = CGPoint(x: origin.x + offset, y: origin.y+offset)
            handlerView?.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        case .topRight:
            handlerView?.center = CGPoint(x: origin.x + size.width-offset, y: origin.y+offset)
            handlerView?.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        case .bottomLeft:
            //            handlerView?.center = CGPoint(x: origin.x, y: origin.y + size.height)
            handlerView?.center = CGPoint(x: origin.x+offset, y: origin.y+size.height-offset)
            handlerView?.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
        case .bottomRight:
            handlerView?.center = CGPoint(x: origin.x + size.width-offset, y: origin.y + size.height-offset)
            handlerView?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        }
        
        handlerView?.tag = position.rawValue
    }
    
    /**
     *  Customize handler's size
     *
     *  @param size Handler's size
     */
    public func setHandlerSize(_ size:Int) {
        if size <= 0 {
            return
        }
        
        self.defaultInset = NSInteger(round(Float(size) / 2))
        self.defaultMinimumSize = 4 * self.defaultInset
        self.minimumSize = max(self.minimumSize, self.defaultMinimumSize)
        
        let originalCenter = self.center
        let originalTransform = self.transform
        var frame = self.contentView.frame
        frame = CGRect(x: 0, y: 0, width: frame.size.width + CGFloat(self.defaultInset) * 2, height: frame.size.height + CGFloat(self.defaultInset) * 2)
        
        self.contentView.removeFromSuperview()
        
        self.transform = CGAffineTransform.identity
        self.frame = frame
        
        self.contentView.center = CGRectGetCenter(self.bounds)
        self.addSubview(self.contentView)
        self.sendSubviewToBack(self.contentView)
        
        let handlerFrame = CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2)
        self.closeImageView.frame = handlerFrame
        self.setPosition(StickerViewPosition(rawValue: self.closeImageView.tag)!, forHandler: .close)
        
        self.rotateImageView.frame = handlerFrame
        self.setPosition(StickerViewPosition(rawValue: self.rotateImageView.tag)!, forHandler: .rotate)
        
        self.flipImageView.frame = handlerFrame
        self.setPosition(StickerViewPosition(rawValue: self.flipImageView.tag)!, forHandler: .flip)
        
        self.center = originalCenter
        self.transform = originalTransform
    }
    
    /**
     *  Default value
     */
    private var defaultInset:NSInteger
    private var defaultMinimumSize:NSInteger
    
    /**
     *  Variables for moving viewes
     */
    private var beginningPoint = CGPoint.zero
    private var beginningCenter = CGPoint.zero
    
    /**
     *  Variables for rotating and resizing viewes
     */
    private var initialBounds = CGRect.zero
    private var initialDistance:CGFloat = 0
    private var deltaAngle:CGFloat = 0
    
    private lazy var moveGesture = {
        return UIPanGestureRecognizer(target: self, action: #selector(handleMoveGesture(_:)))
    }()
    private lazy var rotateImageView:UIImageView = {
        let rotateImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2))
        rotateImageView.contentMode = UIView.ContentMode.scaleAspectFit
        rotateImageView.backgroundColor = UIColor.clear
        rotateImageView.isUserInteractionEnabled = true
        rotateImageView.addGestureRecognizer(self.rotateGesture)
        
        return rotateImageView
    }()
    private lazy var rotateGesture = {
        return UIPanGestureRecognizer(target: self, action: #selector(handleRotateGesture(_:)))
    }()
    private lazy var closeImageView:UIImageView = {
        let closeImageview = UIImageView(frame: CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2))
        closeImageview.contentMode = UIView.ContentMode.scaleAspectFit
        closeImageview.backgroundColor = UIColor.clear
        closeImageview.isUserInteractionEnabled = true
        closeImageview.addGestureRecognizer(self.closeGesture)
        return closeImageview
    }()
    private lazy var closeGesture = {
        return UITapGestureRecognizer(target: self, action: #selector(handleCloseGesture(_:)))
    }()
    private lazy var flipImageView:UIImageView = {
        let flipImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.defaultInset * 2, height: self.defaultInset * 2))
        flipImageView.contentMode = UIView.ContentMode.scaleAspectFit
        flipImageView.backgroundColor = UIColor.clear
        flipImageView.isUserInteractionEnabled = true
        flipImageView.addGestureRecognizer(self.flipGesture)
        return flipImageView
    }()
    private lazy var flipGesture = {
        return UITapGestureRecognizer(target: self, action: #selector(handleFlipGesture(_:)))
    }()
    private lazy var tapGesture = {
        return UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    }()
    // MARK: - Gesture Handlers
    @objc
    func handleMoveGesture(_ recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: self.superview)
        switch recognizer.state {
        case .began:
            self.beginningPoint = touchLocation
            self.beginningCenter = self.center
            if let delegate = self.delegate {
                delegate.stickerViewDidBeginMoving(self)
            }
        case .changed:
            self.center = CGPoint(x: self.beginningCenter.x + (touchLocation.x - self.beginningPoint.x), y: self.beginningCenter.y + (touchLocation.y - self.beginningPoint.y))
            if let delegate = self.delegate {
                delegate.stickerViewDidChangeMoving(self)
            }
        case .ended:
            self.center = CGPoint(x: self.beginningCenter.x + (touchLocation.x - self.beginningPoint.x), y: self.beginningCenter.y + (touchLocation.y - self.beginningPoint.y))
            if let delegate = self.delegate {
                delegate.stickerViewDidEndMoving(self)
            }
        default:
            break
        }
    }
    
    @objc
    func handleRotateGesture(_ recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: self.superview)
        let center = self.center
        
        switch recognizer.state {
        case .began:
            self.deltaAngle = CGFloat(atan2f(Float(touchLocation.y - center.y), Float(touchLocation.x - center.x))) - CGAffineTransformGetAngle(self.transform)
            self.initialBounds = self.bounds
            self.initialDistance = CGPointGetDistance(point1: center, point2: touchLocation)
            if let delegate = self.delegate {
                delegate.stickerViewDidBeginRotating(self)
            }
        case .changed:
            let angle = atan2f(Float(touchLocation.y - center.y), Float(touchLocation.x - center.x))
            let angleDiff = Float(self.deltaAngle) - angle
            self.transform = CGAffineTransform(rotationAngle: CGFloat(-angleDiff))
            
            var scale = CGPointGetDistance(point1: center, point2: touchLocation) / self.initialDistance
            let minimumScale = CGFloat(self.minimumSize) / min(self.initialBounds.size.width, self.initialBounds.size.height)
            scale = max(scale, minimumScale)
            let scaledBounds = CGRectScale(self.initialBounds, wScale: scale, hScale: scale)
            self.bounds = scaledBounds
            self.setNeedsDisplay()
            
            if let delegate = self.delegate {
                delegate.stickerViewDidChangeRotating(self)
            }
        case .ended:
            if let delegate = self.delegate {
                delegate.stickerViewDidEndRotating(self)
            }
        default:
            break
        }
    }
    
    @objc
    func handleCloseGesture(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.stickerViewDidClose(self)
        }
        self.removeFromSuperview()
    }
    
    @objc
    func handleFlipGesture(_ recognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.contentView.transform = self.contentView.transform.scaledBy(x: -1, y: 1)
        }
    }
    
    @objc
    func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.stickerViewDidTap(self)
        }
    }
    
    // MARK: - Private Methods
    private func setEnableClose(_ enableClose:Bool) {
        self.closeImageView.isHidden = !enableClose
        self.closeImageView.isUserInteractionEnabled = enableClose
    }
    
    private func setEnableRotate(_ enableRotate:Bool) {
        self.rotateImageView.isHidden = !enableRotate
        self.rotateImageView.isUserInteractionEnabled = enableRotate
    }
    
    private func setEnableFlip(_ enableFlip:Bool) {
        self.flipImageView.isHidden = !enableFlip
        self.flipImageView.isUserInteractionEnabled = enableFlip
    }
}

extension MMStickerContentView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}