import { WBANToken } from '@artifacts/typechain'
import { BigNumber } from 'ethers'

type SwapToWBanRequest = {
	amount: BigNumber,
	bscWallet: string,
	receipt: string,
	uuid: string,
	contract: WBANToken
}

export default SwapToWBanRequest
