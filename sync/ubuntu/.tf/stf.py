import sys
from pprint import pformat
from thefuck.argument_parser import Parser
from thefuck.exceptions import EmptyCommand
from thefuck import logs, types, const
from thefuck.conf import settings
from thefuck.corrector import get_corrected_commands
from thefuck.entrypoints.fix_command import _get_raw_command

parser = Parser()
known_args = parser.parse(sys.argv)
settings.init(known_args)
with logs.debug_time('Total'):
    logs.debug(u'Run with settings: {}'.format(pformat(settings)))
    raw_command = _get_raw_command(known_args)
    try:
        command = types.Command.from_raw_script(raw_command)
        #print(command)
    except EmptyCommand:
        logs.debug('Empty command, nothing to do')
        sys.exit(1)
    corrected_commands = get_corrected_commands(command)
    l = list(corrected_commands)
    if len(l):
        [print(c.script) for c in l]
    else:
        print(command.script)
