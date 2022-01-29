from brownie import FundMe, network, config, MockV3Aggregator
from scripts.helpful_script import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)


def deploy_fund_me():
    account = get_account()

    # if ... deploy to a live chain, else... deploy to a development chain
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deploy_mocks()
        # use the last version deployed of it
        price_feed_address = MockV3Aggregator[-1].address
        print("Mocks deployed")

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
