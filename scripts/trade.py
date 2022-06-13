from scripts.set_accounts import *
from brownie import FullFlash

opcion = 0


def main():
    c = contract_deployed()
    user = user_address()
    wmatic = addreesses('wmatic', True)
    dai = addreesses('dai', True)
    fl = c.initFlashLoan(dai, wmatic, 1000000000000000000000,
                         opcion, {'from': user})
    fl.wait(1)
    print(fl.events['LogSwapper'])
    tx = c.withdraw(dai, {'from': user})
    tx.wait(1)
    print("ASI ES ELL BULL MARKET")
