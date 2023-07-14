# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'allAboutCollege2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for allAboutCollege2
    pod 'GoogleSignIn', '~> 5.0.2'
    pod 'Firebase/Core'
    pod 'Firebase/Auth','>=9.6.0'
    pod 'Firebase/Firestore'
    pod 'Firebase/Storage'
    pod 'DropDown'
    pod 'RxKeyboard'
    pod 'RxSwift', '~> 5'
    pod 'RxCocoa', '~> 5'
    pod 'IQKeyboardManagerSwift'
    pod 'BTNavigationDropdownMenu'
    pod 'SwiftSoup'
    pod 'RealmSwift', '~>10'
    pod 'SwiftCSV'
    pod 'Elliotable'
    pod 'Toast-Swift', '~> 5.0.1'
    pod 'Tabman', '~> 2.9'
    pod 'Kingfisher'
    pod 'DGCharts'
    pod 'Charts'

end




post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end

