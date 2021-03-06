# How to build Gtk4 Tutorial

## Prerequisites

- To clone the repository, git is necessary. Most distribution has its package.
- Ruby and rake.
- To generate html and latex files, pandoc is necessary.
- To make pdf, latex system is necessary. Texlive2020 or later version is recommended.

## Clone the repository

type the following command.

    $ git clone https://github.com/ToshioCP/Gtk4-tutorial.git

## Github flavored markdown

When you see [gtk4_tutorial github page](https://github.com/ToshioCP/Gtk4-tutorial), you'll find `Readme.md` contents below the list of files.
This file is written in markdown language, of which the file has `.md` suffix.

There are several kinds of markdown language.
`Readme.md` uses 'github flavored markdown', which is often shortened as GFM.
Markdown files in the top directory also written in GFM.
If you are not familiar with it, refer the website [github flavoer markdown spec](https://github.github.com/gfm/).

## Pandoc's markdown

This tutorial uses another markdown -- pandoc's markdown.
Pandoc is a converter between markdown, html, latex, word docx and so on.
This type of markdown is used to generate html and latex files in this tutorial.

## Src.md file

Src.md is similar to markdown but it has two commands which isn't included in markdown syntax.
They are @@@ command and $$$ command.

    @@@ C_source_file [function_list]

This command includes the C source file, but if a function list is given, only the functions in the C source file are included.
If no function list is given, the command can include any text files even it is not C source file.

    $$$
    shell command
    ... ...
    $$$

This command executes the shell command and substitutes the strings in the standard output for the lines between $$$ inclusive.

These two commands are carried out by scripts src2md.rb, which is described in the next subsection.

## Conversion

A ruby script src2md converts src.md file to md file.

    ruby src2md.rb src.md_file md_file

This script recognizes and carrys out the commands described in the previous subsection.
For example, it is assumed that there are two files sample.src.md and sample.c, which have contents as follows.

    $ cat sample.src.md
    The following is the contents of the file 'sample.c'.

    @@@ sample.c

    $ cat sample.c
    #include <stdio.h>

    int
    main(int argc, char **argv) {
        printf("Hello world.\n");
    }

Now, convert sample.src.md to a markdown file sample.md.

    $ ruby src2md.rb sample.src.md sample.md
    $ cat sample.md
    The following is the contents of the file 'sample.c'.

        #include <stdio.h>

        int
        main(int argc, char **argv) {
            printf("Hello world.\n");
        }

Compare sample.src.md and sample.md.
The contents of sample.c is substituted for the line `@@@ sample.c`.
In addition four spaces are added at the top of each line of sample.c.

These two commands have two advantages.

1. Less typing.
2. You don't need to modify your src.md file, even if the C sourcefile, which is included by @@@ command, is modified.
In the same way, any upgrade of the shell commands described between $$$ commands doesn't affect the src.md file.

There's a method `src2md` in the `lib/lib_src2md.rb` script.
This method converts src.md file into md file.
This method is also used in other ruby scripts like Rakefile.

## Directory structure

There are six directories under `gtk4_tutorial` directory.
They are `gfm`, `src`, `image`, `html`, `latex` and `lib`.
Three directories `gfm`, `html` and `latex` are the destination directores for GFM, html and latex files respectively.
It is possible that these three directories don't exist before the conversion.

- src: This directory contains src.md files and C-related source files.
- image: This directory contains image files like png or jpg.
- gfm: This directory is empty at first. A ruby script will convert src.md files to GFM files and store them in this directory.
- html: This directory is empty at first. A ruby script will convert src.md files to html files and store them in this directory.
- latex: This directory is empty at first. A ruby script will convert src.md files to latexl files and store them in this directory.
- lib: This directory includes ruby library files.
 
## Src and top directories

Src directory contains src.md files and C-related source files.
The top directory, which is gtk\_tutorial directory, contains `Rakefile`, `Readme_for_developers.md` and some other files.
`Readme.md` is generated and located at the top directory by rake.
`Readme.md` has title, abstract, table of contents and links to GFM files,
which rake also generates under `gfm` directory.

    $ rake

Rakefile describes how to convert src.md files into GFM files.
Rake carries out the conversion according to the instruction written in Rakefile.

## The name of files in src directory

Each file in src directory is a section of the whole document.
The name of the files are "sec", number of the section and ".src.md" suffix.
For example, "sec1.src.md", "sec5.src.md" or "sec12.src.md".
They are the files correspond to section 1, section 5 and section 12 respectively.

## C source file directory

Src.md files might have @@@ commands and they include C source files.
Such C source files are located in the src directory or its subdirectories.

Usually, those C files are compiled and tested.
At that time, some auxiliary files and target file like a.out are generated.
If you locate the C source files under src directory, those temporary files make the directory messy.
Therefore, It is a good idea to make subdirectories under src directory and put each C source file under the corresponding subdirectory.

The name of the subdirectories should be independent of section names.
It is because of renumbering, which will be explained in the next subsection.

## Renumbering

Sometimes you want to insert a section.
For example, inserting it between section 4 and section 5.
You can make a temporary section 4.5, that is a rational number between 4 and 5.
However, section numbers are usually integer so it must change to section 5 and the numbers of following sections also must be added by one.

This renumbering is done by a method `renum` of the class `Sec_files`.

- It changes file names.
- If there are references to sections in src.md files, the section numbers will be automatically renumbered.

## Rakefile

Rakefile is a similar file to Makefile but controlled by rake, which is a make-like program written in ruby.
Rakefile has the following tasks.

- md: generate GFM markdown files. This is the default.
- html: generate html files.
- pdf: generate latex files and a pdf file, which is generated by pdflatex.
- latex: generate latex files.
- all: generate md, html, latex and pdf files.

Rake does renumbering before the tasks above.

## Generate GFM markdown files

Markdown files (GFM) are generated by rake.

    $ rake

This command generates `Readme.md`, which has no original src.md file.
At the same time, it converts each .src.md file into GFM file under `gfm` directory.
When translated, it is added a navigation line at the top and bottom.

You can describe width and height of images in .src.md files.
For example,

    ![sample image](../image/sample_image.png){width=10cm height=6cm}

The size between left brace abd right brace is used in latex file and it is not fit to GFM syntax.
So the size is removed in the conversion above.

If a src.md file has relative URL link, it will be changed by conversion.
Because src.md files are located under `src` directory and GFM files are located under `gfm` directory, base URL of GFM files is different from base URL of src.md files.
For example, `[Sample.c](sample.c)` is translated to `[Sample.c](../src/sample.c)`.

If a link points another src.md file, then the target filename will be changed to .md file.
For example, `[Section 5](sec5.src.md)` is translated to `[Section 5](sec5.md)`.

If you want to clean the directory, that means remove all the generated markdown files, type `rake clean`.

    $ rake clean

If you see the github repository (ToshioCP/Gtk4-tutorial), `Readme.md` is shown below the list of the top directory.
And `Readme.md` includes links to each markdown files.
The repository not only stores source files but also shows the tutorial in it.

## Generate html files

Src.md files can be translated to html files.
You need pandoc to do this.
Most linux distribution has pandoc package.
Refer to your distribution document to install it.

Type `rake html` to generate html files.

    $ rake html

First, it generates pandoc's markdown files under `html` directory.
Then, pandoc converts them to html files.
The description of the width and height of image files is removed.

`index.html` is the top html file.
If you want to clean `html` directory, type `rake cleanhtml`

    $ rake cleanhtml

Every html file has stylesheet in its header.
This comes from `header` string in `Rakefile`.
You can customize the style by modifying `Rakefile`.

## Generate latex files and a pdf file

Src.md files can be translated to latex files.
You need pandoc to do this.

Type `rake latex` to generate latex files.

    $ rake latex

First, it generates pandoc's markdown files under `latex` directory.
Then, pandoc converts them to latex files.
Links to files or directories are removed because latex doesn't support them.
However, links to full URL are kept.

`main.tex` is the top latex file.
If you want to clean `latex` directory, type `rake cleanlatex`

    $ rake cleanlatex

You can customize `main.tex` and `helper.tex`, which describes preamble, by modifying `Rakefile`.

You can generate pdf file by typing `rake pdf`.

    $ rake pdf


