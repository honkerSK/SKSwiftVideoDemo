//
//  ViewController.swift
//  GPUImage3Demo
//
//  Created by sunke on 2020/9/5.
//  Copyright © 2020 KentSun. All rights reserved.
//

// GPUImage3（一）集成与使用
import UIKit

import GPUImage
import AVFoundation

class ViewController: UIViewController {
    
    var camera: Camera!
    var basicOperation: BasicOperation!
    var renderView: RenderView!
    
    lazy var imageView: UIImageView = {
       
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
//        imageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: "Yui", ofType: "jpg")!)
        imageView.image = UIImage(named: "Yui")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
    view.addSubview(imageView)
}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //实时视频滤镜
//        self.cameraFiltering()
        
        //从实时视频中截图图片
//        self.captureImageFromVideo()
        
        //处理静态图片
//        self.filteringImage()
        
        //自定义滤镜(待完善)
//        self.customFilter()
        
        //操作组
        self.operationGroup()
    }
}

extension ViewController {
    
    // MARK: - 实时视频滤镜，将相机捕获的图像经过处理显示在屏幕上
    func cameraFiltering() {
        
        // Camera的构造函数是可抛出错误的
        do {
            // 创建一个Camera的实例，Camera遵循ImageSource协议，用来从相机捕获数据
            
            /// Camera的指定构造器
            ///
            /// - Parameters:
            ///   - sessionPreset: 捕获视频的分辨率
            ///   - cameraDevice: 相机设备，默认为nil
            ///   - location: 前置相机还是后置相机，默认为.backFacing
            ///   - captureAsYUV: 是否采集为YUV颜色编码，默认为true
            /// - Throws: AVCaptureDeviceInput构造错误
            camera = try Camera(sessionPreset: AVCaptureSession.Preset.hd1280x720,
                                cameraDevice: nil,
                                location: .backFacing,
                                captureAsYUV: true)
            
            // Camera的指定构造器是有默认参数的，可以只传入sessionPreset参数
            // camera = try Camera(sessionPreset: AVCaptureSessionPreset1280x720)
            
        } catch {
            
            print(error)
            return
        }
        
        // 创建一个Luminance颜色处理滤镜
        basicOperation = Luminance()
        
        // 创建一个RenderView的实例并添加到view上，用来显示最终处理出的内容
        renderView = RenderView(frame: view.bounds)
        view.addSubview(renderView)
        
        // 绑定处理链
        camera --> basicOperation --> renderView
        
        // 开始捕捉数据
        camera.startCapture()
        
        // 结束捕捉数据
        // camera.stopCapture()
    }
    
    // MARK: - 从实时视频中截图图片
    // 从视频中获取某一帧的图片，可以以任一滤镜节点作为数据源。
    func captureImageFromVideo() {
        
        // 启动实时视频滤镜
        self.cameraFiltering()
        
        // 设置保存路径
        guard let outputPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        
        let originalPath = outputPath + "/originalImage.png"
        print("path: \(originalPath)")
        let originalURL = URL(fileURLWithPath: originalPath)
        
        let filteredPath = outputPath + "/filteredImage.png"
        print("path: \(filteredPath)")
        let filteredlURL = URL(fileURLWithPath: filteredPath)
        
        // 延迟1s执行，防止截到黑屏
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            
            // 保存相机捕捉到的图片
            self.camera.saveNextFrameToURL(originalURL, format: .png)
            
            // 保存滤镜后的图片
            self.basicOperation.saveNextFrameToURL(filteredlURL, format: .png)
            
            // 如果需要处理回调，有下面两种写法
            
            let dataOutput = PictureOutput()
            dataOutput.encodedImageFormat = .png
            dataOutput.encodedImageAvailableCallback = {imageData in
                // 这里的imageData是截取到的数据，Data类型
            }
            self.camera --> dataOutput
            
            let imageOutput = PictureOutput()
            imageOutput.encodedImageFormat = .png
            imageOutput.imageAvailableCallback = {image in
                // 这里的image是截取到的数据，UIImage类型
            }
            self.camera --> imageOutput
        }
    }
    
    // MARK: - 处理静态图片
    func filteringImage() {
        
        // 创建一个BrightnessAdjustment颜色处理滤镜 (明亮)
        let brightnessAdjustment = BrightnessAdjustment()
        brightnessAdjustment.brightness = 0.2
        
        // 创建一个ExposureAdjustment颜色处理滤镜 (曝光)
        let exposureAdjustment = ExposureAdjustment()
        exposureAdjustment.exposure = 0.5
        
        /*
        // 方法1.使用GPUImage对UIImage的扩展方法进行滤镜处理
        var filteredImage: UIImage
        // 1.1单一滤镜
        filteredImage = imageView.image!.filterWithOperation(brightnessAdjustment)
        
        // 1.2多个滤镜叠加  (SK注: filterWithOperation filterWithPipeline, 同时会有使用错误!)
        filteredImage = imageView.image!.filterWithPipeline { (input, output) in
            input --> brightnessAdjustment --> exposureAdjustment --> output
        }
        
        // 不建议的
        imageView.image = filteredImage
        //注意：如果要将图片显示在屏幕上或者进行多次滤镜处理时，以上方法会让Core Graphics产生更多开销，建议使用处理链，最后指向RenderView来显示，如下：
            */
 
      
        // 方法2.使用管道处理
        // 创建图片输入
        let pictureInput = PictureInput(image: imageView.image!)
        // 创建图片输出
        let pictureOutput = PictureOutput()
        // 给闭包赋值
        pictureOutput.imageAvailableCallback = {[weak self] image in
            // 这里的image是处理完的数据，UIImage类型
            self?.imageView.image = image
        }
        // 绑定处理链
        pictureInput --> brightnessAdjustment --> exposureAdjustment --> pictureOutput
        // 开始处理 synchronously: true 同步执行 false 异步执行，处理完毕后会调用imageAvailableCallback这个闭包
        pictureInput.processImage(synchronously: true)
         
    }
    
    // MARK: - 编写自定义的图像处理操作
    func customFilter() {
        
        // 获取文件路径
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Custom", ofType: "fsh")!)
        
        var customFilter: BasicOperation

        do {
            // 从文件中创建自定义滤镜
//            customFilter = try BasicOperation(fragmentShaderFile: url)
            customFilter = try BasicOperation(fragmentFunctionName: "Custom.fsh")

        } catch {
            print(error)
            return
        }
        
        // 进行滤镜处理
        imageView.image = imageView.image!.filterWithOperation(customFilter)
    }
    
    // MARK: - 操作组
    /*
     可以将若干个BasicOperation的实例包装成一个OperationGroup操作组，通过给闭包赋值来定义组内滤镜的处理流程，外部可以将OperationGroup的实例作为一个独立单位参与其他滤镜处理。
     */
    func operationGroup() {
        
        // 创建一个BrightnessAdjustment颜色处理滤镜
        let brightnessAdjustment = BrightnessAdjustment()
        brightnessAdjustment.brightness = 0.2
        
        // 创建一个ExposureAdjustment颜色处理滤镜
        let exposureAdjustment = ExposureAdjustment()
        exposureAdjustment.exposure = 0.5
        
        // 创建一个操作组
        let operationGroup = OperationGroup()
        
        // 给闭包赋值，绑定处理链
        operationGroup.configureGroup{input, output in
            input --> brightnessAdjustment --> exposureAdjustment --> output
        }
        
        // 进行滤镜处理
        imageView.image = imageView.image!.filterWithOperation(operationGroup)
    }
}


