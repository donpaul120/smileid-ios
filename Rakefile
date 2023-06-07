namespace :build do
  desc 'Builds all packages and executables'
  task all: ['package:all', 'example:all', 'xcframework']

  desc 'Builds the Smile ID package for supported platforms'
  namespace :package do
    desc 'Builds the Smile ID package for iOS'
    task all: ['iOS']

    desc 'Builds the Smile ID package for iOS'
    task :iOS do
      xcodebuild('build -scheme "SmileID" -destination generic/platform=iOS')
    end
  end

  desc 'Builds the Smile ID example app for supported platforms'
  namespace :example do
    desc 'Builds the Smile ID example apps for all supported platforms'
    task all: ['iOS']

    desc 'Builds the iOS Smile ID Example app'
    task :iOS do
      xcodebuild('build -scheme "SmileIdentity-Example" -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)" -project Example/SmileIdentity.xcodeproj')
    end
  end

  desc 'Builds an xcframework for all supported platforms'
  task :xcframework do
    sh 'rm -rf .build/archives'
    sh 'rm -rf release'
    sh 'mint run unsignedapps/swift-create-xcframework --zip'
    sh 'rm -rf SmileID.xcframework'
    sh 'swift package compute-checksum SmileID.zip'
    sh 'mkdir release'
    sh 'mv SmileID.zip SmileID.sha256 release/'
  end
end
  
namespace :test do
  desc 'Tests the package , processed the test results and tests spm compatibility'
  task all: ['package', 'process', 'spm','example']
  desc 'Tests the Smile ID package for iOS'
  task :package do
    sh 'rm -rf Tests/Artifacts'
    xcodebuild('test  -scheme "SmileID" -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)" -resultBundlePath Tests/Artifacts/SmileIdentityTests.xcresult')
  end

  desc 'Tests the example app unit tests'
  task :example do
    xcodebuild('test -project Example/SmileIdentity.xcodeproj  -scheme "SmileIdentityTests" -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)"')
  end

  desc 'Processes .xcresult artifacts from the most recent test:package execution'
  task :process do
    sh 'mint run ChargePoint/xcparse@2.3.1 xcparse attachments Tests/Artifacts/SmileIdentityTests.xcresult Tests/Artifacts/TestAttachments'
  end

  desc 'Tests Swift Package Manager support'
  task :spm do
    xcodebuild('build -scheme "SmileID" -destination generic/platform=iOS')
  end
end
  
namespace :lint do
  desc 'Lints swift files'
  task :swift do
    sh 'mint run realm/SwiftLint'
  end

  desc 'Lints the CocoaPods podspec'
  task :podspec do
    sh 'pod lib lint SmileIdentity.podspec'
  end
end
  
namespace :format do
  desc 'Formats swift files'
  task :swift do
    sh 'mint run swiftformat . --swiftversion 5.8'
  end
end
  
def xcodebuild(command)
  # Check if the mint tool is installed -- if so, pipe the xcodebuild output through xcbeautify
  `which mint`
  sh 'rm -rf ~/Library/Developer/Xcode/DerivedData/* && echo "Successfully flushed DerivedData"'
  if $?.success?
    sh "set -o pipefail && xcodebuild #{command} | mint run thii/xcbeautify@0.10.2"
  else
    sh "xcodebuild #{command}"
  end
end