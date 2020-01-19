import UIKit
import Flutter
import Lottie

public class LottieView: NSObject, FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64

    var animationView: AnimationView?
    var testStream: TestStreamHandler?
    var delegates: [AnyValueProvider]
    var registrarInstance: FlutterPluginRegistrar


    init(_ frame: CGRect, viewId: Int64, args: Any?, registrarInstance: FlutterPluginRegistrar) {
        self.frame = frame
        self.viewId = viewId
        self.registrarInstance = registrarInstance
        self.delegates = []

        super.init()

        self.create(args: args)
    }

    func create(args: Any?) {

        let channel: FlutterMethodChannel = FlutterMethodChannel.init(name: "convictiontech/flutter_lottie_" + String(viewId), binaryMessenger: self.registrarInstance.messenger())
        let handler: FlutterMethodCallHandler = methodCall;
        channel.setMethodCallHandler(handler)

        let testChannel = FlutterEventChannel(name: "convictiontech/flutter_lottie_stream_playfinish_" + String(viewId), binaryMessenger: self.registrarInstance.messenger())
        self.testStream = TestStreamHandler()
        testChannel.setStreamHandler(testStream as? FlutterStreamHandler & NSObjectProtocol)


        if let argsDict = args as? Dictionary<String, Any> {
            let url = argsDict["url"] as? String ?? nil;
            let filePath = argsDict["filePath"] as? String ?? nil;

            if url != nil {
//            self.animationView = AnimationView(url: URL(string: url!),bundle: "ddd")
                self.animationView = AnimationView(url: URL(string: url!)!, imageProvider: nil, closure: { (err) in
                }, animationCache: nil)
            }

            if filePath != nil {
                print("THIS IS THE ID " + String(viewId) + " " + filePath!)
                let key = self.registrarInstance.lookupKey(forAsset: filePath!)
                let path = Bundle.main.path(forResource: key, ofType: nil)
                self.animationView = AnimationView(filePath: path!)
            }

            let loop = argsDict["loop"] as? Bool ?? false
            let reverse = argsDict["reverse"] as? Bool ?? false
            let autoPlay = argsDict["autoPlay"] as? Bool ?? false

            if (loop) {
                self.animationView?.loopMode = LottieLoopMode.loop
            }
            if (reverse) {
                self.animationView?.loopMode = LottieLoopMode.autoReverse
            }
            if (autoPlay) {
                self.animationView?.play(completion: completionBlock);
            }
        }

    }

    public func view() -> UIView {
        return animationView!
    }

    public func completionBlock(animationFinished: Bool) -> Void {
        if let ev: FlutterEventSink = self.testStream!.event {
            ev(animationFinished)
        }
    }


    func methodCall(call: FlutterMethodCall, result: FlutterResult) {
        var props: Dictionary<String, Any> = [String: Any]()

        if let args = call.arguments as? Dictionary<String, Any> {
            props = args
        }

        if (call.method == "play") {
            self.animationView?.currentProgress = 0
            self.animationView?.play(completion: completionBlock);
        }

        if (call.method == "resume") {
            self.animationView?.play(completion: completionBlock);
        }

        if (call.method == "playWithProgress") {
            let toProgress = props["toProgress"] as! CGFloat;
            if let fromProgress = props["fromProgress"] as? CGFloat {
                self.animationView?.play(fromProgress: fromProgress, toProgress: toProgress
                        , completion: completionBlock)
            } else {
                self.animationView?.play(toProgress: toProgress
                        , completion: completionBlock)
            }
        }


        if (call.method == "playWithFrames") {
            let toFrame = props["toFrame"] as! NSNumber;
            if let fromFrame = props["fromFrame"] as? NSNumber {
                self.animationView?.play(fromFrame: fromFrame as? AnimationFrameTime, toFrame: AnimationFrameTime(truncating: toFrame), completion: completionBlock);
            } else {
                self.animationView?.play(toFrame: AnimationFrameTime(truncating: toFrame), completion: completionBlock);
            }
        }

        if (call.method == "stop") {
            self.animationView?.stop();
        }

        if (call.method == "pause") {
            self.animationView?.pause();
        }

        if (call.method == "setAnimationSpeed") {
            self.animationView?.animationSpeed = props["speed"] as! CGFloat
        }

        if (call.method == "setLoopAnimation") {
            self.animationView?.loopMode = props["loop"] as! LottieLoopMode
        }

        if (call.method == "setAutoReverseAnimation") {
            self.animationView?.loopMode = props["reverse"] as! LottieLoopMode
        }

        if (call.method == "setAnimationProgress") {
            self.animationView?.currentProgress = props["progress"] as! CGFloat
        }

        if (call.method == "setProgressWithFrame") {
            let frame = props["frame"] as! NSNumber
            self.animationView?.currentProgress = AnimationProgressTime(truncating: frame)
//         self.animationView?.setProgressWithFrame(frame)
        }

        if (call.method == "isAnimationPlaying") {
            let isAnimationPlaying = self.animationView?.isAnimationPlaying
            result(isAnimationPlaying)
        }

        if (call.method == "getAnimationDuration") {
//         let animationDuration = self.animationView?.animationDuration
//        let animationDuration = self.animationView?.frame
//         result(1000)
        }

        if (call.method == "getAnimationProgress") {
            let currentProgress = self.animationView?.currentProgress
            result(currentProgress)
        }

        if (call.method == "getAnimationSpeed") {
            let animationSpeed = self.animationView?.animationSpeed
            result(animationSpeed)
        }

        if (call.method == "getLoopAnimation") {
            let loopMode = self.animationView?.loopMode
            result(loopMode)
        }

        if (call.method == "getAutoReverseAnimation") {
            let loopMode = self.animationView?.loopMode
            result(loopMode)
        }


        if (call.method == "setValue") {
            let value = props["value"] as! String;
            let keyPath = props["keyPath"] as! String;
            if let type = props["type"] as? String {
                setValue(type: type, value: value, keyPath: keyPath)
            }
        }

        if (call.method == "setAnimationByPath") {
            let filePath = props["path"] as! String;
            setAnimationByPath(filePath: filePath, result: result)
        }
    }

    func setValue(type: String, value: String, keyPath: String) -> Void {
        switch type {
        case "LOTColorValue":
            let i = UInt32(value.dropFirst(2), radix: 16)
            let color = hexToColor(hex8: i!);
            self.delegates.append(ColorDelegate(color: color) as! AnyValueProvider)
            self.animationView?.setValueProvider(self.delegates[self.delegates.count - 1], keypath: AnimationKeypath(keypath: keyPath + ".Color"))
            break;
        case "LOTOpacityValue":
            if let n = NumberFormatter().number(from: value) {
                let f = CGFloat(truncating: n)
                self.delegates.append(NumberDelegate(number: f) as! AnyValueProvider)
                self.animationView?.setValueProvider(self.delegates[self.delegates.count - 1], keypath: AnimationKeypath(keypath: keyPath + ".Opacity"))
            }
            break;
        default:
            break;
        }
    }

    func stop() -> Void {
        self.animationView?.stop()
        self.animationView?.currentProgress = 0
    }

    func setAnimationByPath(filePath: String, result: FlutterResult) -> Void {
        self.stop()

        let show = filePath != nil && !filePath.isEmpty

        if show {
            let key = self.registrarInstance.lookupKey(forAsset: filePath)
            let path = Bundle.main.path(forResource: key, ofType: nil)
            self.animationView?.animation = Animation.filepath(path!)
            self.animationView?.play(completion: completionBlock);
        }

        self.animationView?.isHidden = !show

        result(nil)
    }
}
