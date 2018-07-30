#!/usr/bin/env python

# Source: https://github.com/shellphish/fuzzer/blob/master/bin/create_dict.py
# License:
# Copyright (c) 2015, The Regents of the University of California
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import os
import sys
import angr
import string
import itertools

import logging

l = logging.getLogger("create_dict")


def hexescape(s):
    '''
    perform hex escaping on a raw string s
    '''

    out = []
    acceptable = string.letters + string.digits + " ."
    for c in s:
        if c not in acceptable:
            out.append("\\x%02x" % ord(c))
        else:
            out.append(c)

    return ''.join(out)


strcnt = itertools.count()

def create(binary):

    b = angr.Project(binary, load_options={'auto_load_libs': False})
    cfg = b.analyses.CFG(resolve_indirect_jumps=True, collect_data_references=True)

    state = b.factory.blank_state()

    string_references = []
    for v in cfg._memory_data.values():
        if v.sort == "string" and v.size > 1:
            st = state.se.eval(state.memory.load(v.address, v.size), cast_to=str)
            string_references.append((v.address, st))

    strings = [] if len(string_references) == 0 else zip(*string_references)[1]

    valid_strings = []
    if len(strings) > 0:
        for s in strings:
            if len(s) <= 128:
                valid_strings.append(s)
            for s_atom in s.split():
                # AFL has a limit of 128 bytes per dictionary entries
                if len(s_atom) <= 128:
                    valid_strings.append(s_atom)

    for s in set(valid_strings):
        s_val = hexescape(s)
        print "string_%d=\"%s\"" % (strcnt.next(), s_val)


def main(argv):

    if len(argv) < 2:
        l.error("incorrect number of arguments passed to create_dict")
        print "usage: %s [binary1] [binary2] [binary3] ... " % sys.argv[0]
        return 1

    for binary in argv[1:]:
        if os.path.isfile(binary):
            create(binary)

    return int(strcnt.next() == 0)

if __name__ == "__main__":
    sys.exit(main(sys.argv))
