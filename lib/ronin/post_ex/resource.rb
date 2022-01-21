#
# ronin-post_ex - a Ruby API for Post-Exploitation.
#
# Copyright (c) 2007-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-post_ex.
#
# ronin-post_ex is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-post_ex is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-post_ex.  If not, see <https://www.gnu.org/licenses/>.
#

module Ronin
  module PostEx
    #
    # A base-class for all Post-Exploitation Resources.
    #
    class Resource

      # The object providing control of the Resource
      attr_reader :controller

      #
      # Creates a new Resource.
      #
      # @param [Object] controller
      #   The object controlling the Resource.
      #
      def initialize(controller)
        @controller = controller
      end

      #
      # Determines whether the controller object supports the Resource method(s).
      #
      # @param [Array<Symbol>] method_names
      #   The name of the Resource method.
      #
      # @return [Boolean]
      #   Specifies whether the controller object supports the method.
      #
      # @example
      #   fs.supports?(:read, :write)
      #   # => true
      #
      # @api public
      #
      def supports?(*method_names)
        method_names.all? do |method_name|
          method_name        = method_name.to_sym
          controller_methods = self.class.resource_methods[method_name]

          controller_methods && controller_methods.all? { |control_method|
            @controller.respond_to?(control_method)
          }
        end
      end

      #
      # Determines which Resource methods are supported by the controlling
      # object.
      #
      # @return [Array<Symbol>]
      #   The names of the supported Resource methods.
      #
      def supports
        self.class.resource_methods.keys.select do |method_name|
          supports?(method_name)
        end
      end

      #
      # Allows resources to spawn interactive consoles.
      #
      # @raise [NotImplementedError]
      #   The console method is not implemented by default.
      #
      def console
        raise(NotImplementedError,"#{self.class} does not provide a console")
      end

      protected

      #
      # The defined Resource methods.
      #
      # @return [Hash{Symbol => Array<Symbol>}]
      #   The names of the Resource methods and their required controller methods.
      #
      # @api semipublic
      #
      def self.resource_methods
        @resource_methods ||= {}
      end

      #
      # Specifies that a Resource method requires certain methods define by the
      # controller object.
      #
      # @param [Symbol] method_name
      #   The name of the Resource method.
      #
      # @param [Array<Symbol>] control_methods
      #   The methods that must be defined by the controller object.
      #
      # @api semipublic
      #
      def self.resource_method(method_name,control_methods=[])
        resource_methods[method_name.to_sym] = control_methods.map(&:to_sym)
      end

      #
      # Requires that the controlling object define the given method.
      #
      # @param [Symbol] name
      #   The name of the method that is required.
      #
      # @return [true]
      #   The method is defined.
      #
      # @raise [NotImplementedError]
      #   The method is not defined by the controlling object.
      #
      def requires_method!(name)
        unless @controller.respond_to?(name)
          raise(NotImplementedError,"#{@controller.inspect} does not define #{name}")
        end

        return true
      end

    end
  end
end
