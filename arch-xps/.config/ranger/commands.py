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
