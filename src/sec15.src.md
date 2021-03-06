# tfe5 source files

## How to compile and execute tfe text editor.

First, source files are shown in the later subsections.
How to download them is written at the end of the [previous section](sec14.src.md).

The following is the instruction of compilation and execution.

- You need meson and ninja.
- Set necessary environment variables.
If you have installed gtk4 under the instruction in [Section 2](sec2.src.md), type `. env.sh` to set the environment variables.
- change your current directory to `src/tfe5` directory.
- type `meson _build` for configuration.
- type `ninja -C _build` for compilation.
Then the application `tfe` is build under the `_build` directory.
- type `_build/tfe` to execute it.

Then the window appears.
There are four buttons, `New`, `Open`, `Save` and `Close`.

- Click on `Open` button, then a FileChooserDialog appears.
Choose a file in the list and click on `Open` button.
Then the file is read and a new Notebook Page appears.
- Edit the file and click on `Save` button, then the text is saved to the original file.
- Click `Close`, then the Notebook Page disappears.
- Click `Close` again, then the `Untitle` Notebook Page disappears and at the same time the appication quits.

This is a very simple editor.
It is a good practice for you to add more features.

## meson.buld

@@@ tfe5/meson.build

## tfe.gresource.xml

@@@ tfe5/tfe.gresource.xml

## tfe.ui

@@@ tfe5/tfe.ui

## tfe.h

@@@ tfe5/tfe.h

## tfeapplication.c

@@@ tfe5/tfeapplication.c

## tfenotebook.h

@@@ tfe5/tfenotebook.h

## tfenotebook.c

@@@ tfe5/tfenotebook.c

## tfetextview.h

@@@ tfe5/tfetextview.h

## tfetextview.c

@@@ tfe5/tfetextview.c

## Total number of lines, words and charcters

$$$
LANG=C wc tfe5/meson.build tfe5/tfeapplication.c tfe5/tfe.gresource.xml tfe5/tfe.h tfe5/tfenotebook.c tfe5/tfenotebook.h tfe5/tfetextview.c tfe5/tfetextview.h tfe5/tfe.ui
$$$
