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

require 'ronin/ui/shell'

module Ronin
  module PostEx
    module Shells
      #
      # A shell for {Resources::FS}.
      #
      # @since 1.0.0
      #
      class FS < UI::Shell

        #
        # Initializes the file-system shell.
        #
        # @param [Resources::FS] fs
        #   The file-system resource.
        #
        def initialize(fs)
          super(name: 'fs')

          @fs = fs
        end

        protected

        #
        # Changes the working directory.
        #
        # @param [String] path
        #   The new working directory.
        #
        # @see Resources::FS#chdir
        #
        def chdir(path)
          @fs.chdir(path)
          print_info "Current working directory is now: #{@fs.pwd}"
        end
        alias cd chdir

        #
        # Prints the current working directory.
        #
        # @see Resources::FS#getcwd
        #
        def cwd
          print_info "Current working directory: #{@fs.getcwd}"
        end
        alias pwd cwd

        #
        # Reads data from a file.
        #
        # @param [String] path
        #   The file to read from.
        #
        # @see Resources::FS#read
        #
        def read(path)
          write(@fs.read(path))
        end
        alias cat read

        #
        # Reads the destination of a link.
        #
        # @param [String] path
        #   The path to the link.
        #
        # @see Resources::FS#readlink
        #
        def readlink(path)
          puts @fs.readlink(path)
        end

        #
        # Reads the entries of a directory.
        #
        # @param [String] path
        #   The path to the directory.
        #
        # @see Resources::FS#readdir
        #
        def readdir(path)
          @fs.readdir(path).each do |entry|
            puts entry
          end
        end
        alias dir readdir

        #
        # Hexdumps a file.
        #
        # @param [String] path
        #   The file to hexdump.
        #
        # @see Resources::FS#hexdump
        #
        def hexdump(path)
          @fs.hexdump(path,self)
        end

        #
        # Copies a file to a destination.
        #
        # @param [String] src
        #   The file to copy.
        #
        # @param [String] dest
        #   The destination to copy the file to.
        #
        # @see Resources::FS#copy
        #
        def copy(src,dest)
          @fs.copy(src,dest)

          print_info "Copied #{@fs.join(src)} -> #{@fs.join(dest)}"
        end
        alias cp copy

        #
        # Removes a file.
        #
        # @param [String] path
        #   The file to be removed.
        #
        # @see Resources::FS#unlink
        #
        def unlink(path)
          @fs.unlink(path)

          print_info "Removed #{@fs.join(path)}"
        end
        alias rm unlink

        #
        # Removes an empty directory.
        #
        # @param [String] path
        #   The file to be removed.
        #
        # @see Resources::FS#rmdir
        #
        def rmdir(path)
          @fs.rmdir(path)

          print_info "Removed directory #{@fs.join(path)}"
        end

        #
        # Moves a file or directory.
        #
        # @param [String] src
        #   The file or directory to move.
        #
        # @param [String] dest
        #   The destination to move the file or directory to.
        #
        # @see Resources::FS#move
        #
        def move(src,dest)
          @fs.move(src,dest)

          print_info "Moved #{@fs.join(src)} -> #{@fs.join(dest)}"
        end
        alias mv move

        #
        # Creates a link to a file or directory.
        #
        # @param [String] src
        #   The file or directory to link to.
        #
        # @param [String] dest
        #   The path of the new link.
        #
        # @see Resources::FS#link
        #
        def link(src,dest)
          @fs.link(src,dest)

          print_info "Linked #{@fs.join(src)} -> #{@fs.join(dest)}"
        end
        alias ln link

        #
        # Changes ownership of a file or directory.
        #
        # @param [Array<String>] args
        #   Arguments for `chown`.
        #
        # @see Resources::FS#chown
        #
        def chown(*args)
          @fs.chown(*args)

          print_info "Changed ownership of #{@fs.join(args.first)}"
        end

        #
        # Changes group ownership of a file or directory.
        #
        # @param [Array<String>] args
        #   Arguments for `chgrp`.
        #
        # @see Resources::FS#chgrp
        #
        def chgrp(*args)
          @fs.chgrp(*args)

          print_info "Changed group ownership of #{@fs.join(args.first)}"
        end

        #
        # Changes the permissions of a file or directory.
        #
        # @param [Array<String>] args
        #   Arguments for `chmod`.
        #
        # @see Resources::FS#chmod
        #
        def chmod(*args)
          @fs.chmod(*args)

          print_info "Changed permissions on #{@fs.join(args.first)}"
        end

        #
        # Stats a file or directory.
        #
        # @param [String] path
        #   The file or directory to stat.
        #
        # @see Resources::FS#stat
        #
        def stat(path)
          @fs.stat(path)
        end

      end
    end
  end
end
