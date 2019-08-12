import subprocess
from subprocess import TimeoutExpired

from pynvim.api.nvim import NvimError

import vim
from ncm2 import Ncm2Source
from ncm2 import Popen
from ncm2 import getLogger

logger = getLogger(__name__)

class Source(Ncm2Source):
    PROC_TIMEOUT = 5
    DEFUALT_COMMANDS = {
        'accounts': ['ledger', 'accounts'],
        'tags': ['ledger', 'tags'],
        'payees': ['ledger', 'payees'],
        'commodities': ['ledger', 'commodities']
    }

    def __init__(self, nvim, name):
        super().__init__(nvim)

        self.name = name
        self.command = None
        self.candidates = []

        try:
            setting = 'g:ncm2_ledger_cmd_' + name
            self.command = self.nvim.eval(setting)
        except NvimError:
            self.command = Source.DEFUALT_COMMANDS[name]

        logger.debug('"%s" command is: %s', name, self.command)

    def on_complete(self, ctx):
        base = ctx['base']
        matcher = self.matcher_get(ctx)

        try:
            proc = Popen(
                args=self.command,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            outs, errs = proc.communicate(timeout=Source.PROC_TIMEOUT)

            candidates = outs.decode('utf-8').splitlines()
            candidates = self.matches_formalize(ctx, candidates)

            if candidates:
                self.candidates = candidates
                logger.info('Found %s "%s" completion candidates',
                    len(self.candidates), self.name
                )
        except TimeoutExpired as err:
            proc.kill()
            logger.exception('Error collecting "%s" matches', self.name)
        except Exception as err:
            logger.exception('Error collecting "%s" matches', self.name)

        matches = [candidate for candidate in self.candidates if matcher(base, candidate)]
        logger.info('Found %s "%s" completion matches',
            len(matches), self.name
        )
        self.complete(ctx, ctx['startccol'], matches, True)

accounts = Source(vim, 'accounts')
tags = Source(vim, 'tags')
payees = Source(vim, 'payees')
commodities = Source(vim, 'commodities')

accounts_provider = accounts.on_complete
tags_provider = tags.on_complete
payees_provider = payees.on_complete
commodities_provider = commodities.on_complete
