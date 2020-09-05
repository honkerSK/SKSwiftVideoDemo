//
//  ViewController.swift
//  NativeAudioVideoDemo
//
//  Created by sunke on 2020/8/30.
//  Copyright © 2020 KentSun. All rights reserved.
//
// 原生音视频采集

import UIKit
import AVFoundation


class ViewController: UIViewController {

    fileprivate weak var session : AVCaptureSession!
    fileprivate weak var previewLayer : AVCaptureVideoPreviewLayer!
    fileprivate weak var videoInput : AVCaptureDeviceInput!
    fileprivate weak var videoOutput : AVCaptureVideoDataOutput!
    fileprivate weak var fileOutput : AVCaptureMovieFileOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


}


extension ViewController {
    @IBAction func startCapturing() {
        // 1.创建AVCaptureSession
        let session = AVCaptureSession()
        self.session = session
        
        // 2.添加输入的源
        // 2.1.添加视频的输入源
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("您的摄像头有问题")
            return
        }
        
        
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        self.videoInput = deviceInput
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        // 2.2.添加音频的输入源
        guard let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio) else {
            return
        }
        
        
        guard let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            return
        }
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        // 3.添加输出的源
        // 3.1.添加一个写入文件的输出源
        let fileOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(fileOutput) {
            session.addOutput(fileOutput)
        }
        self.fileOutput = fileOutput
        // 3.2.视频的输出源
        let output = AVCaptureVideoDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        self.videoOutput = output
        // 3.3.音频的输出源
        let audioOutput = AVCaptureAudioDataOutput()
        let audioQueue = DispatchQueue.global()
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        if session.canAddOutput(audioOutput) {
            session.addOutput(audioOutput)
        }
        
        // 4.添加预览图层
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
        
        // 5.开始采集
        session.startRunning()
        
        // 6.开始写入文件
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return
        }
        let filePath = path.appending("/abc.mp4")
        let url = URL(fileURLWithPath: filePath)
        fileOutput.startRecording(to: url, recordingDelegate: self)
    }
    
    @IBAction func stopCapturing() {
        fileOutput.stopRecording()
        session.stopRunning()
        previewLayer.removeFromSuperlayer()
    }
}


extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if videoOutput.connection(with: AVMediaType.video) == connection {
            print("获取到视频的一帧画面")
        } else {
            print("采集到音频数据")
        }
        
    }
}

extension ViewController : AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("开始写入")
    }
    
//    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
//        print("写入完成")
//    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("写入完成")
    }
}

extension ViewController {
    @IBAction func rotateCamera() {
        // 1.获取之前的镜头的方向
        var position = videoInput.device.position
        
        // 2.切换方向
        position = position == .front ? .back : .front
        
        // 3.根据方向, 获取最新的设备
        guard let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] else {
            return
        }
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .unspecified) else {
//            return
//        }

        
        // 4.获取对应的设备 filter/map/reduce
        guard let device = devices.filter({ $0.position == position }).first else {
            return
        }
//        if device.position != position {
//            return
//        }
        
        // 5.根据最新的设备创建最新的input
        guard let newInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        // 6.移除旧的input, 添加新的input
        session.beginConfiguration()
        session.removeInput(videoInput)
        if session.canAddInput(newInput) {
            session.addInput(newInput)
        }
        session.commitConfiguration()
        
        // 7.保存最新的newInput
        videoInput = newInput
    }
}
