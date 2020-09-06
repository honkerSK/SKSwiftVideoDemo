//
//  DisplayViewController.swift
//  GPUImage2FilterList
//
//  Created by sunke on 2020/9/6.
//  Copyright © 2020 KentSun. All rights reserved.
//

import UIKit
import GPUImage

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let SCREEN_WIDTH_Float = Float(UIScreen.main.bounds.width)
let SCREEN_HEIGHT_Float = Float(UIScreen.main.bounds.height)
let SCREEN_SIZE = Size(width: SCREEN_WIDTH_Float, height: SCREEN_WIDTH_Float)

class DisplayViewController: UIViewController {
    
    var pictureInput: PictureInput!
    var filterModel: FilterModel!
    var filter: AnyObject!
    
    var renderView: RenderView = {
        
        let renderView = RenderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        renderView.fillMode = .preserveAspectRatio
        renderView.backgroundRenderColor = .white
        return renderView
    }()
    
    var slider: UISlider = {
        
        let slider = UISlider(frame: CGRect(x: 8, y: SCREEN_HEIGHT - 60, width: SCREEN_WIDTH - 40, height: 20))
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        slider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        view.addSubview(renderView)
        view.addSubview(slider)
        title = filterModel.name
        self.setupFilterChain()
    }

    override func viewWillDisappear(_ animated: Bool) {
        pictureInput.removeAllTargets()
        
        super.viewWillDisappear(animated)
    }
    
    deinit {
        print("deinit")
    }
    
    func setupFilterChain() {
        
        pictureInput = PictureInput(image: MaYuImage)
        slider.minimumValue = filterModel.range?.0 ?? 0
        slider.maximumValue = filterModel.range?.1 ?? 0
        slider.value = filterModel.range?.2 ?? 0
        filter = filterModel.initCallback()
        
        switch filterModel.filterType! {
            
        case .imageGenerators:
            filter as! ImageSource --> renderView
            
        case .basicOperation:
            if let actualFilter = filter as? BasicOperation {
                pictureInput --> actualFilter --> renderView
                pictureInput.processImage()
            }
            
        case .operationGroup:
            if let actualFilter = filter as? OperationGroup {
                pictureInput --> actualFilter --> renderView
            }
            
        case .blend:
            if let actualFilter = filter as? BasicOperation {
                let blendImgae = PictureInput(image: flowerImage)
                blendImgae --> actualFilter
                pictureInput --> actualFilter --> renderView
                blendImgae.processImage()
                pictureInput.processImage()
            }
            
        case .custom:
            filterModel.customCallback!(pictureInput, filter, renderView)
        }
        
        self.sliderValueChanged(slider: slider)
    }
    
    @objc func sliderValueChanged(slider: UISlider) {
        
        print("slider value: \(slider.value)")
        
        if let actualCallback = filterModel.valueChangedCallback {
            actualCallback(filter, slider.value)
        } else {
            slider.isHidden = true
        }
        
        if filterModel.filterType! != .imageGenerators {
            pictureInput.processImage()
        }
    }
}
