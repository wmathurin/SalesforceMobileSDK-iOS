# Copyright (c) 2021-present, salesforce.com, inc. All rights reserved.
#  
#  Redistribution and use of this software in source and binary forms, with or without modification,
#  are permitted provided that the following conditions are met:
#  * Redistributions of source code must retain the above copyright notice, this list of conditions
#  and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright notice, this list of
#  conditions and the following disclaimer in the documentation and/or other materials provided
#  with the distribution.
#  * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
#  endorse or promote products derived from this software without specific prior written
#  permission of salesforce.com, inc.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
#  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
#  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
#  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

def use_mobile_sdk!(options={})
  path = options[:path] ||= "./mobile_sdk/SalesforceMobileSDK-iOS"

  pod 'SalesforceSDKCommon', :path => path
  pod 'SalesforceAnalytics', :path => path
  pod 'SalesforceSDKCore', :path => path
  pod 'SmartStore', :path => path
  pod 'MobileSync', :path => path
end

# Pre Install: Building Mobile SDK targets as dynamic frameworks
def mobile_sdk_pre_install(installer)
   dynamic_framework = ['SalesforceAnalytics', 'SalesforceSDKCore', 'SalesforceSDKCommon', 'SmartStore', 'FMDB', 'SQLCipher', 'MobileSync']
   installer.pod_targets.each do |pod|
     if dynamic_framework.include?(pod.name)
       def pod.build_type
         Pod::BuildType.dynamic_framework
       end
     end
   end
end
  

# Post Install: Enable sign posts
def signposts_post_install(installer)
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.name == 'Debug'
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DEBUG=1','SIGNPOST_ENABLED=1']
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-DDEBUG','-DSIGNPOST_ENABLED']
      end
    end
  end
end

# Post Install: Keeping Mobile SDK deployement target at 14 (__apply_Xcode_12_5_M1_post_install_workaround changes it to 11)
def mobile_sdk_post_install(installer)
  installer.pods_project.targets.each do |target|
    if ['SalesforceAnalytics', 'SalesforceSDKCommon', 'SalesforceSDKCore', 'SmartStore', 'MobileSync', 'SalesforceReact'].include?(target.name)
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
  end
end

