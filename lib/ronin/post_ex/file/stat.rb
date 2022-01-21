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

require 'ronin/post_ex/resource'

module Ronin
  module PostEx
    class File < Resource
      #
      # Represents the status information of a remote file. The {Stat} class
      # using the `fs_stat` method defined by the controller object to
      # request the remote status information.
      #
      # @since 1.0.0
      #
      class Stat

        # The path of the file
        attr_reader :path

        # The size of the file (in bytes)
        attr_reader :size

        # The number of native file-system blocks
        attr_reader :blocks

        # The native file-system block size.
        attr_reader :blocksize

        # The Inode number
        attr_reader :inode

        # The number of hard links to the file
        attr_reader :nlinks

        # The mode of the file
        attr_reader :mode

        #
        # Creates a new File Stat object.
        #
        # @param [#fs_stat] controller
        #   The object controlling file-system stat.
        #
        # @param [String] path
        #   The path of the remote.
        #
        # @raise [RuntimeError]
        #   The leveraging object does not define `fs_stat` needed by
        #   {Stat}.
        #
        # @raise [Errno::ENOENT]
        #   The remote file does not exist.
        #
        def initialize(controller,path)
          unless controller.respond_to?(:fs_stat)
            raise(RuntimeError,"#{controller.inspect} does not define fs_stat")
          end

          @controller = controller
          @path       = path.to_s

          unless (stat = @controller.fs_stat(@path))
            raise(Errno::ENOENT,"No such file or directory #{@path.dump}")
          end

          @size      = stat[:size]
          @blocks    = stat[:blocks]
          @blocksize = stat[:blocksize]
          @inode     = stat[:inode]
          @nlinks    = stat[:nlinks]

          @mode = stat[:mode]
          @uid  = stat[:uid]
          @gid  = stat[:gid]

          @atime = stat[:atime]
          @ctime = stat[:ctime]
          @mtime = stat[:mtime]
        end

        alias ino inode
        alias blksize blocksize

        #
        # Determines whether the file has zero size.
        #
        # @return [Boolean]
        #   Specifies whether the file has zero size.
        #
        def zero?
          @size == 0
        end

      end
    end
  end
end
