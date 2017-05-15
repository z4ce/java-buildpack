# Cloud Foundry Java Buildpack
# Copyright 2017 the original author or authors.
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

require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for enabling zero-touch FusionReactor support.
    class FusionReactorAgent < JavaBuildpack::Component::VersionedDependencyComponent

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        download_tar
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        credentials = @application.services.find_service(FILTER)['credentials']
        java_opts   = @droplet.java_opts

        java_opts.add_system_property('frlicense', license(credentials))
                 .add_system_property('fradminpassword', password(credentials))
                 .add_javaagent_with_props(jar_name, 'name' => name(credentials), 'address' => address(credentials))

        java_opts.add_agentpath(lib_name) if debug(credentials)
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        @application.services.one_service? FILTER, LICENSE_KEY, PASSWORD
      end

      private

      DEBUG = 'debug'.freeze

      FILTER = /fusionreactor/

      LICENSE_KEY = 'license'.freeze

      PASSWORD = 'password'.freeze

      private_constant :DEBUG, :FILTER, :LICENSE_KEY, :PASSWORD

      def address(credentials)
        credentials['instance_port'] || 8088
      end

      def debug(credentials)
        credentials.key?(DEBUG) ? credentials[DEBUG] : true
      end

      def jar_name
        @droplet.sandbox + 'fusionreactor/fusionreactor.jar'
      end

      def lib_name
        if `uname -s` =~ /Darwin/
          @droplet.sandbox + 'fusionreactor/libfrjvmti_x64.dylib'
        else
          @droplet.sandbox + 'fusionreactor/libfrjvmti_x64.so'
        end
      end

      def license(credentials)
        credentials[LICENSE_KEY]
      end

      def name(credentials)
        credentials['instance_name'] || @application.details['application_name']
      end

      def password(credentials)
        credentials[PASSWORD]
      end

    end

  end
end
