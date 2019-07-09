import subprocess

from pynvim.api.nvim import NvimError

import vim
from ncm2 import Ncm2Source
from ncm2 import Popen
from ncm2 import getLogger

logger = getLogger(__name__)

class Source(Ncm2Source):
    LEDGER_COMMAND = ['ledger', 'accounts']
    PROC_TIMEOUT = 5

    def __init__(self, nvim):
        super().__init__(nvim)

        self.matches = []

        try:
            self.ledger_command = self.nvim.eval('g:ncm2_ledger_cmd_accounts')
        except NvimError:
            self.ledger_command = Source.LEDGER_COMMAND

        logger.debug('command is: %s', self.ledger_command)

    def on_complete(self, ctx):
        base = ctx['base']
        matcher = self.matcher_get(ctx)

        try:
            proc = Popen(
                args=self.ledger_command,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            outs, errs = proc.communicate(timeout=Source.PROC_TIMEOUT)

            items = outs.decode('utf-8').split()
            items = self.matches_formalize(ctx, items)

            matches = [item for item in items if matcher(base, item)]
            if matches:
                self.matches = matches
                logger.info('Found %s completion candidates', len(self.matches))
        except TimeoutExpired as err:
            proc.kill()
            logger.exception('Error collecting matches')
        except Exception as err:
            logger.exception('Error collecting matches')

        self.complete(ctx, ctx['startccol'], self.matches, True)

source = Source(vim)
on_complete = source.on_complete