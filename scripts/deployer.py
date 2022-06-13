from brownie import FullFlash
from scripts.set_accounts import *


def deployer(user, aave, factory, factoryS, uni_router, sushi_router):
    c = FullFlash.deploy(aave, factory, factoryS,
                         uni_router, sushi_router, {'from': user})
    return c


def main():
    user, aave, factory, factoryS, uni_router, sushi_router = setting()
    c = deployer(user, aave, factory, factoryS, uni_router, sushi_router)
    print("Contract deployed at:", c.address)
