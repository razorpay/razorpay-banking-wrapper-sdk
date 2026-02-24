// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RazorpayBankWrapper",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "RazorpayBankWrapper",
            targets: ["RazorpayBankWrapperShim"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/razorpay/razorpay-pod.git", from: "1.4.1"),
    ],
    targets: [
        .binaryTarget(
            name: "RazorpayBankWrapper",
            path: "Frameworks/RazorpayBankWrapper.xcframework"
        ),
        .target(
            name: "RazorpayBankWrapperShim",
            dependencies: [
                "RazorpayBankWrapper",
                .product(name: "RazorpayCheckout", package: "razorpay-pod"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
