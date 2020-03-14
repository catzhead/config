import difflib
import filecmp
import os
import termios
import shutil
import sys

CORRESPONDANCE = {
    'home': '~/',
    'etc': '/etc'
    }


def getkey():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    new = termios.tcgetattr(fd)
    new[3] = new[3] & ~termios.ICANON & ~termios.ECHO
    new[6][termios.VMIN] = 1
    new[6][termios.VTIME] = 0
    termios.tcsetattr(fd, termios.TCSANOW, new)
    c = None
    try:
        c = os.read(fd, 1)
    finally:
        termios.tcsetattr(fd, termios.TCSAFLUSH, old)
    return c


def clean_path(path):
    return os.path.expanduser(os.path.normpath(path))


def diff_files(left_file, right_file):
    cmp = filecmp.cmp(left_file, right_file)
    if cmp:
        print(f'{left_file} and {right_file} are identical')
    else:
        print(f'{left_file} and {right_file} are different:')
        finished = False
        while not finished:
            print('> show [d]iff, replace [l]eft, replace [r]ight, [i]gnore, '
                  '[q]uit')
            c = getkey()
            if c == b'i':
                print('ignoring')
                finished = True
            if c == b'q':
                print('exiting')
                sys.exit(0)
            elif c == b'l':
                shutil.copyfile(right_file, left_file)
                finished = True
            elif c == b'r':
                shutil.copyfile(left_file, right_file)
                finished = True
            elif c == b'd':
                with open(left_file) as left_fd:
                    with open(right_file) as right_fd:
                        diff = difflib.ndiff(right_fd.readlines(),
                                             left_fd.readlines())
                print(''.join(diff))


def diff_dir(left_dir, right_dir):
    original_dir = os.getcwd()
    os.chdir(left_dir)
    for root, dirs, files in os.walk('.'):
        for file in files:
            left_file = clean_path(os.path.join(root, file))
            right_file = clean_path(os.path.join(right_dir, root, file))

            if not os.path.isfile(right_file):
                print(f'{right_file} does not exist')
            else:
                diff_files(left_file, right_file)
    os.chdir(original_dir)


if __name__ == "__main__":
    for dir in CORRESPONDANCE:
        diff_dir(dir, CORRESPONDANCE[dir])
