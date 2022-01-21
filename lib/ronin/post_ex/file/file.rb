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

require 'ronin/post_ex/file/stat'
require 'ronin/post_ex/resource'

require 'fake_io'
require 'set'

module Ronin
  module PostEx
    #
    # The {File} class represents files on a remote system. {File} requires
    # the controller object to define either `fs_read` and/or `fs_write`.
    # Additionally, {File} can optionally use the `fs_open`, `fs_close`,
    # `fs_tell`, `fs_seek` and `fs_stat` methods.
    #
    class File < Resource

      include FakeIO

      #
      # Creates a new remote controlled File object.
      #
      # @param [#fs_read, #fs_write] controller
      #   The object controlling remote files.
      #
      # @param [String] path
      #   The path of the remote file.
      #
      def initialize(controller,path,mode='r')
        @controller = controller
        @path       = path.to_s
        @mode       = mode.to_s

        super()
      end

      #
      # Opens a file.
      #
      # @param [#fs_read] controller
      #   The object controlling remote files.
      #
      # @param [String] path
      #   The path of the remote file.
      #
      # @yield [file]
      #   The given block will be passed the newly created file object.
      #   When the block has returned, the File object will be closed.
      #
      # @yieldparam [File]
      #   The newly created file object.
      #
      def self.open(controller,path)
        io = new(controller,path)

        if block_given?
          value = yield(io)

          io.close
          return value
        else
          return io
        end
      end

      #
      # Sets the position in the file to read.
      #
      # @param [Integer] new_pos
      #   The new position to read from.
      #
      # @return [Integer]
      #   The new position within the file.
      #
      def seek(new_pos,whence=SEEK_SET)
        clear_buffer!

        if @controller.respond_to?(:fs_seek)
          @controller.fs_seek(@fd,new_pos,whence)
        end

        @pos = new_pos
      end
      resource_method :seek

      #
      # The current offset in the file.
      #
      # @return [Integer]
      #   The current offset in bytes.
      #
      def tell
        if @controller.respond_to?(:fs_tell)
          @pos = @controller.fs_tell(@fd)
        else
          @pos
        end
      end
      resource_method :tell

      #
      # Executes a low-level command to control or query the IO stream.
      #
      # @param [String, Array<Integer>] command
      #   The IOCTL command.
      #
      # @param [Object] argument
      #   Argument of the command.
      #
      # @raise [RuntimeError]
      #   The controller object does not define `fs_ioctl`.
      #
      def ioctl(command,argument)
        unless @controller.respond_to?(:fs_ioctl)
          raise(RuntimeError,"#{@controller.inspect} does not define fs_ioctl")
        end

        return @controller.fs_ioctl(command,argument)
      end
      resource_method :ioctl, [:fs_ioctl]

      #
      # Executes a low-level command to control or query the file stream.
      #
      # @param [String, Array<Integer>] command
      #   The FCNTL command.
      #
      # @param [Object] argument
      #   Argument of the command.
      #
      # @raise [RuntimeError]
      #   The controller object does not define `fs_fcntl`.
      #
      def fcntl(command,argument)
        unless @controller.respond_to?(:fs_fcntl)
          raise(RuntimeError,"#{@controller.inspect} does not define fs_fcntl")
        end

        return @controller.fs_fcntl(command,argument)
      end
      resource_method :fcntl, [:fs_fcntl]

      #
      # Re-opens the file.
      #
      # @param [String] path
      #   The new path for the file.
      #
      # @return [File]
      #   The re-opened the file.
      #
      def reopen(path)
        close

        @path = path.to_s
        return open
      end
      resource_method :reopen

      #
      # The status information for the file.
      #
      # @return [Stat]
      #   The status information.
      #
      def stat
        File::Stat.new(@controller,@path)
      end
      resource_method :stat, [:fs_stat]

      #
      # Inspects the open file.
      #
      # @return [String]
      #   The inspected open file.
      #
      def inspect
        "#<#{self.class}:#{@path}>"
      end

      protected

      #
      # Attempts calling `fs_open` from the controller object to open
      # the remote file.
      #
      # @return [Object]
      #   The file descriptor returned by `fs_open`.
      #
      def io_open
        if @controller.respond_to?(:fs_open)
          @controller.fs_open(@path,@mode)
        else
          @path
        end
      end
      resource_method :open

      #
      # Reads a block from the remote file by calling `fs_read` or
      # `fs_readfile` from the controller object.
      #
      # @return [String, nil]
      #   A block of data from the file.
      #
      # @raise [IOError]
      #   The controller object does not define `fs_read` or `fs_readfile`.
      #
      def io_read
        if @controller.respond_to?(:fs_readfile)
          @eof = true
          @controller.fs_readfile(@path)
        elsif @controller.respond_to?(:fs_read)
          @controller.fs_read(@fd,@pos)
        else
          raise(IOError,"#{@controller.inspect} does not support reading")
        end
      end
      resource_method :read, [:fs_read]

      #
      # Writes data to the remote file by calling `fs_write` from the
      # controller object.
      #
      # @param [String] data
      #   The data to write.
      #
      # @return [Integer]
      #   The number of bytes writen.
      #
      # @raise [IOError]
      #   The controller object does not define `fs_write`.
      #
      def io_write(data)
        if @controller.respond_to?(:fs_write)
          @pos += @controller.fs_write(@fd,@pos,data)
        else
          raise(IOError,"#{@controller.inspect} does not support writing to files")
        end
      end
      resource_method :write, [:fs_write]

      #
      # Attempts calling `fs_close` from the controller object to close
      # the file.
      #
      def io_close
        if @controller.respond_to?(:fs_close)
          @controller.fs_close(@fd)
        end
      end
      resource_method :close

    end
  end
end