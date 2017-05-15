# Cloud Foundry Java Buildpack
# Copyright 2013-2017 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'
require 'component_helper'
require 'java_buildpack/framework/fusion_reactor_agent'

describe JavaBuildpack::Framework::FusionReactorAgent do
  include_context 'component_helper'

  it 'does not detect without fusionreactor-n/a service' do
    expect(component.detect).to be_nil
  end

  context do

    before do
      allow(services).to receive(:one_service?).with(/fusionreactor/, 'license', 'password').and_return(true)
    end

    it 'detects with fusionreactor-n/a service' do
      expect(component.detect).to eq("fusion-reactor-agent=#{version}")
    end

    it 'downloads Fusion agent',
       cache_fixture: 'stub-fusion-reactor-agent.tar.gz' do

      component.compile

      expect(sandbox + 'fusionreactor/fusionreactor.jar').to exist
    end

    it 'updates JAVA_OPTS' do
      allow(services).to receive(:find_service)
        .and_return('credentials' => { 'license' => 'test-license', 'password' => 'test-password' })

      component.release

      expect(java_opts).to include('-javaagent:$PWD/.java-buildpack/fusion_reactor_agent/fusionreactor/' \
                                           'fusionreactor.jar=name=test-application-name,address=8088')
      expect(java_opts).to include('-Dfrlicense=test-license')
      expect(java_opts).to include('-Dfradminpassword=test-password')

      if `uname -s` =~ /Darwin/
        expect(java_opts).to include('-agentpath:$PWD/.java-buildpack/fusion_reactor_agent/fusionreactor/' \
                                             'libfrjvmti_x64.dylib')
      else
        expect(java_opts).to include('-agentpath:$PWD/.java-buildpack/fusion_reactor_agent/fusionreactor/' \
                                             'libfrjvmti_x64.so')
      end
    end

    it 'updates JAVA_OPTS with explicit instance name' do
      allow(services).to receive(:find_service)
        .and_return('credentials' => { 'instance_name' => 'test-instance-name', 'license' => 'test-license',
                                       'password' => 'test-password' })

      component.release

      expect(java_opts).to include('-javaagent:$PWD/.java-buildpack/fusion_reactor_agent/fusionreactor/' \
                                           'fusionreactor.jar=name=test-instance-name,address=8088')
    end

    it 'updates JAVA_OPTS with explicit instance port' do
      allow(services).to receive(:find_service)
        .and_return('credentials' => { 'instance_port' => 5_000, 'license' => 'test-license',
                                       'password' => 'test-password' })

      component.release

      expect(java_opts).to include('-javaagent:$PWD/.java-buildpack/fusion_reactor_agent/fusionreactor/' \
                                           'fusionreactor.jar=name=test-application-name,address=5000')
    end

    it 'updates JAVA_OPTS with explicit debug true' do
      allow(services).to receive(:find_service)
        .and_return('credentials' => { 'debug' => true, 'license' => 'test-license', 'password' => 'test-password' })

      component.release

      if `uname -s` =~ /Darwin/
        expect(java_opts).to include('-agentpath:$PWD/.java-buildpack/fusion_reactor_agent/fusionreactor/' \
                                             'libfrjvmti_x64.dylib')
      else
        expect(java_opts).to include('-agentpath:$PWD/.java-buildpack/fusion_reactor_agent/fusionreactor/' \
                                             'libfrjvmti_x64.so')
      end
    end

    it 'updates JAVA_OPTS with explicit debug false' do
      allow(services).to receive(:find_service)
        .and_return('credentials' => { 'debug' => false, 'license' => 'test-license', 'password' => 'test-password' })

      component.release

      if `uname -s` =~ /Darwin/
        expect(java_opts).not_to include('-agentpath:$PWD/.java-buildpack/fusion_reactor_agent/fusionreactor/' \
                                         'libfrjvmti_x64.dylib')
      else
        expect(java_opts).not_to include('-agentpath:$PWD/.java-buildpack/fusion_reactor_agent/fusionreactor/' \
                                         'libfrjvmti_x64.so')
      end
    end

  end

end
