// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RazorpayPaymentBank",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "RazorpayPaymentBank",
            targets: ["RazorpayPaymentBank"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/razorpay/razorpay-pod.git", from: "1.4.1"),
    ],
    targets: [
        .binaryTarget(
            name: "RazorpayPaymentBank",
            path: "Frameworks/RazorpayPaymentBank.xcframework"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
