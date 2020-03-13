# Custom commands
# -----------------------------------------------------------------------------

from __future__ import (absolute_import, division, print_function)

import os

from ranger.api.commands import Command


class mpv(Command):
    """:mpv [filename]

    Launch mpv with the current selection
    """

    def execute(self):
        cmd = ["mpv"]
        cmd.extend([f.realpath for f in self.fm.thistab.get_selection()])
        self.fm.execute_command(cmd)


class watched(Command):
    """:watched [filename]

    Toggle a suffix to the filename to mark it as watched
    """

    def execute(self):
        mark = '[w]'
        files = [f.realpath for f in self.fm.thistab.get_selection()]
        for file in files:
            filepath, extension = os.path.splitext(file)
            if not filepath.endswith(mark):
                new_name = filepath + mark + extension
            else:
                new_name = filepath[:-len(mark)] + extension
            os.rename(file, new_name)
