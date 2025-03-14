# nanami -- Nano Markdown compiler
# Copyright (C) 2025 pokeghost
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# frozen_string_literal: true

require_relative 'nanami/version'
require_relative 'nanami/nama_parser'
require_relative 'nanami/nama_transformer'

module Nanami
  class Error < StandardError; end

  # Default settings
  files_to_process = []

  i = 0

  if ARGV.empty?
    puts 'No options specified. Add --help, -h or -? to print help'
    exit(0)
  end

  while i < ARGV.length
    arg = ARGV[i]

    case arg
    when '--help', '-h', '-?'
      puts <<~HELP
        Usage: nanami [args] [file1] [file2] [file3] [...]
        Converts .nama markdown files, according to the syntax, to HTML5 .html or XHTML 1.0 Strict .xhtml files and lists them in a "directory.(x)html".
        Options:
           --help, -h or -?: displays this.
           --version or -v: displays the version number.
           --manual-directory or --manual_directory: resets to the directory.html according to the files just compiled, according to the order listed in the arguments.
           --append-directory or --append_directory: appends to an existing directory.html.
           --alphabetize-directory or --alphabetize_directory:  alphabetizes an already existing or commanded to exist directory.html.
           --html5: set output file to be HTML5.
           --xhtml: set output file to be XHTML 1.0 Strict.
           --outpute: Print out and write without the header or <body>.
           --template: Takes template file and puts directory where {directory} is and content where {content} is.
      HELP
      exit(0)
    when '--version', '-v'
      puts "nanami version #{VERSION}"
      exit(0)
    when '--manual-directory', '--manual_directory'
      puts 'not implemented'
      exit(0)
    when '--append-directory', '--append_directory'
      puts 'not implemented'
      exit(0)
    when '--alphabetize-directory', '--alphabetize_directory'
      puts 'not implemented'
      exit(0)
    when '--html5'
      puts 'not implemented'
      exit(0)
    when '--xhtml'
      puts 'not implemented'
      exit(0)
    when '--outpute'
      puts 'not implemented'
      exit(0)
    when '--template'
      puts 'not implemented'
      exit(0)
    else
      if File.exist?(arg)
        files_to_process << arg
      else
        puts "Warning: File '#{arg}' not found, skipping"
      end
    end

    i += 1
  end

  if files_to_process.empty?
    puts 'Error: No input files specified or all files were not found'
    exit(1)
  end
end
