# lib_src2md.rb
require 'pathname'

# The method 'src2md' convert .src.md file into .md file.
# The output .md file is fit for the final format, which is one of markdown, html and latex.
# - Links to relative URL are removed for latex. Otherwise, it remains.
#   See "Hyperref and relative link" below for further explanation.
# - Width and height for images are removed for markdown and html. it remains for latex.
#    ![sample](sample_image){width=10cm height=5cm} => ![sample](sample_image)    for markdown and html

# ---- Hyperref and relative link ----
# Hyperref package makes internal link possible.
# The target of the link is made with '\hypertarget' command.
# And the link is made with '\hyperlink' command.
# For example,
#  (sec11.tex)
#   \hyperlink{tfeapplication.c}{Section 13}
#   ... ...
#  (sec13.tex)
#   \hypertarget{tfeapplication.c}{%
#   \section{tfeapplication.c}\label{tfeapplication.c}}
# If you click the text 'Section 13' in sec11.tex, then you can move to '13 tfeapplication.c', which is section 13 in sec13.tex.

# The following lines are the original one in sec11.md and the result in sec11.tex, which is generated by pandoc.
#  (sec11.md)
#   All the source files are listed in [Section 13](sec13.tex).
#  (sec11.tex)
#   All the source files are listed in \href{sec13.tex}{Section 13}.
# Therefore, if you want to correct the link in sec11.tex, you need to do the followings.
# 1. Look at the first line of sec13.md and get the section heading (tfeapplication.c).
# 2. substitute "\hyperlink{tfeapplication.c}{Section 13}" for "\href{sec13.tex}{Section 13}".

# The following lines are another conversion case by pandoc.
#  (sec7.md)
#   The source code of `tfe3.c` is stored in [src/tfe](../src/tfe) directory.
#  (sec7.tex)
#   The source code of \texttt{tfe3.c} is stored in \href{../src/tfe}{src/tfe} directory.
# The pdf file generated by pdflatex recognizes that the link 'href{../src/tfe}' points a pdf file '../src/tfe.pdf'.
# To avoid generating such incorrect links, it is good to remove the links from the original markdown file.

# If the target is full URL, which means absolute URL begins with "http", no problem happens.

# This Rakefile just remove the links if its target is relative URL.
# If you want to revive the link with relative URL, refer the description above.

# ---- Folding verbatim lines ----
# When C sourcefiles or subshell output are included, the lines are folded to fit in 'width'.
# Before they are folded, four space characters are prepended to the line.
# Therefore, 'width' must be at least five.
# Otherwise the lines are not folded.

def src2md srcmd, md, width
  src_buf = IO.readlines srcmd
  src_dir = File.dirname srcmd
  md_dir = File.dirname md
# type is 'the type of the target', which is one of "markdown", "html" and "latex".
  type = md_dir == "." ? "markdown" : md_dir

  md_buf = []
  comflag = false
  src_buf.each do |line|
    if comflag
      if line == "$$$\n"
        comflag = false
      else
        md_buf << "    $ "+line
        `cd #{src_dir}; #{line.chomp}`.each_line do |l|
          md_buf << l.gsub(/^/,"    ")
        end
      end
    elsif line == "$$$\n"
      comflag = true
    elsif line =~ /^@@@\s+(\S+)\s*(.*)\s*$/
      c_file = $1
      c_functions = $2.split(" ")
      if c_file =~ /^\// # absolute path
        c_file_buf = IO.readlines(c_file)
      else #relative path
        c_file_buf = IO.readlines(src_dir+"/"+c_file)
      end
      if c_functions.empty? # no functions are specified
        tmp_buf = c_file_buf
      else
        tmp_buf = []
        spc = false
        c_functions.each do |c_function|
          from = c_file_buf.find_index { |line| line =~ /^#{c_function} *\(/ }
          if ! from
            warn "ERROR!!! --- Didn't find #{c_function} in #{filename}. ---"
            break
          end
          to = from
          while to < c_file_buf.size do
            if c_file_buf[to] == "}\n"
              break
            end
            to += 1
          end
          n = from-1
          if spc
            tmp_buf << "\n"
          else
            spc = true
          end
          while n <= to do
            tmp_buf << c_file_buf[n]
            n += 1
          end
        end
      end
      ln_width = tmp_buf.size.to_s.length
      n = 1
      tmp_buf.each do |l|
        l = sprintf("    %#{ln_width}d %s", n, l)
        md_buf << l
        n += 1
      end
    else
      md_buf << change_rel_link(line, src_dir, File.dirname(md))
    end
  end
  tmp_buf = md_buf
  md_buf = []
  tmp_buf.each do |line|
    if line =~ /^    / && width.instance_of?(Integer) && width >= 5
      indent = line =~ /^( *\d+ +)/ ? " "*$1.length : "    " 
      while line.instance_of?(String) && line.length > width
        md_buf << line[0, width]+"\n"
        line = line[width .. -1].gsub(/^/,indent)
      end
    elsif type == "latex"
      line.gsub!(/(^|[^!])\[([^\]]*)\]\((?~http)\)/,"\\1\\2") # remove link
    else # type == "markdown" or "html"
      line.gsub!(/(!\[[^\]]*\]\([^\)]*\)) *{width *= *\d*(|\.\d*)cm *height *= *\d*(|\.\d*)cm}/,"\\1") # remove size option from link to image files.
    end
    md_buf << line
  end
  IO.write(md,md_buf.join)
end

def change_rel_link line, src_dir, basedir
  p_basedir = Pathname.new basedir
  left = ""
  right = line
  while right =~ /(!?\[[^\]]*\])\(([^\)]*)\)/
    left = $`
    right = $'
    name = $1
    link = $2
    if name =~ /\[(S|s)ection (\d+)\]/
      link = "sec#{$2}.md"
    elsif ! (link =~ /^(http|\/)/)
      p_link = Pathname.new "#{src_dir}/#{link}"
      link = p_link.relative_path_from(p_basedir).to_s
    end
    left += "#{name}(#{link})"
  end
  left + right
end

