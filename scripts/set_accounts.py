from brownie import interface, config, accounts, network, Contract


def user_address():
    if network.show_active() == ('polyfork' or 'forky'):
        return accounts[0]
    else:
        return accounts.add(config['wallets']['from_key'])


def addreesses(asset, token=False):
    if token == True:
        return interface.IERC20(config['networks'][network.show_active()][asset])
    else:
        return config['networks'][network.show_active()][asset]


def contract_deployed():
    return Contract('0x8d5C4D285cA67f7197021b3B5C854390f545a205')


def setting():
    user = user_address()
    aave = addreesses('aave')
    factory = addreesses('factory')
    factoryS = addreesses('factoryS')
    uni_router = addreesses('uni')
    sushi_router = addreesses('sushi')

    print("All too well")
    return user, aave, factory, factoryS, uni_router, sushi_router


def setting_tokens():
    weth = addreesses('weth', True)
    dai = addreesses('dai', True)
    print("Wildest dreams")
    return weth, dai


'''def printer(token, user, amount):
    tx = token.deposit({'from': user, 'value': amount * 10**18})
    tx.wait(1)
    print("PRINTER GOES BRRRRRRRRRRR")'''
