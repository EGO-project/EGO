# Uncomment the next line to define a global platform for your project
# platform :ios, '14.0'

target 'EGO' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  #DB
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'

  #Kakao

  pod 'KakaoSDKCommon'
  pod 'KakaoSDKAuth'
  /Users/bugoncha/Documents/EGO/EGO/detailViewController.swift  pod 'KakaoSDKUser'

  pod 'KakaoSDKShare'    # 메시지(카카오링크)
  pod 'KakaoSDKTemplate' # 메시지 템플릿


  # Pods for FSCalendar_Tuto
  pod 'FSCalendar'
  
  #Google
  pod 'GoogleSignIn'

  # Pods for EGO

  target 'EGOTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'EGOUITests' do
    # Pods for testing
  end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end

end

