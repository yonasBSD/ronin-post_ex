#
# ronin-post_ex - a Ruby API for Post-Exploitation.
#
# Copyright (c) 2007-2013 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/post_ex/resource'
require 'ronin/post_ex/io'

module Ronin
  module PostEx
    #
    # The {Command} class represents commands being executed on remote
    # systems. The {Command} class wraps around the `shell_exec` method
    # defined in the object controller shell access.
    #
    # @since 1.0.0
    #
    class Command < Resource

      include IO
      include Enumerable

      # The program name
      attr_reader :program

      # The arguments of the program
      attr_reader :arguments

      #
      # Creates a new Command.
      #
      # @param [#shell_exec] controller
      #   The object controlling command execution.
      #
      # @param [String] program
      #   The program to run.
      #
      # @param [Array] arguments
      #   The arguments to run with.
      #
      # @raise [RuntimeError]
      #   The controller object does not define `shell_exec`.
      #
      def initialize(controller,program,*arguments)
        unless controller.respond_to?(:shell_exec)
          raise(RuntimeError,"#{controller.inspect} must define shell_exec for #{self.class}")
        end

        @controller = controller
        @program    = program
        @arguments  = arguments

        io_initialize
      end

      #
      # Reopens the command.
      #
      # @param [String] program
      #   The new program to run.
      #
      # @param [Array] arguments
      #   The new arguments to run with.
      #
      # @return [Command]
      #   The new command.
      #
      def reopen(program,*arguments)
        close

        @program = program
        @arguments = arguments

        return open
      end
      resource_method :reopen, [:shell_exec]

      #
      # Converts the command to a `String`.
      #
      # @return [String]
      #   The program name and arguments.
      #
      def to_s
        ([@program] + @arguments).join(' ')
      end

      #
      # Inspects the command.
      #
      # @return [String]
      #   The inspected command listing the program name and arguments.
      #
      def inspect
        "#<#{self.class}: #{self}>"
      end

      protected

      #
      # Executes and opens the command for reading.
      #
      # @return [Enumerator]
      #   The enumerator that wraps around `shell_exec`.
      #
      def io_open
        @controller.enum_for(:shell_exec,@program,*@arguments)
      end
      resource_method :open, [:shell_exec]

      #
      # Reads a line of output from the command.
      #
      # @return [String]
      #   A line of output.
      #
      # @raise [EOFError]
      #   The end of the output stream has been reached.
      #
      def io_read
        begin
          @fd.next
        rescue StopIteration
          raise(EOFError,"end of command")
        end
      end
      resource_method :read

      #
      # Writes data to the shell.
      #
      # @param [String] data
      #   The data to write to the shell.
      #
      # @return [Integer]
      #   The number of bytes writen.
      #
      def io_write(data)
        if @controller.respond_to?(:shell_write)
          @controller.shell_write(data)
        else
          raise(IOError,"#{@controller.inspect} does not support writing to the shell")
        end
      end
      resource_method :write, [:shell_write]

    end
  end
end
