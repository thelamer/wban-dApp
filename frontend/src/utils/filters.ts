import Vue from 'vue'
import { ethers } from 'ethers'
import numeral from 'numeral'
import { date } from 'quasar'
import ban from '@/store/modules/ban'

const bnToStringFilter = Vue.filter('bnToString', (value: string) => {
	return numeral(ethers.utils.formatUnits(value, 18)).format('0,0[.]00000')
})

const bnToHumanStringFilter = Vue.filter('bnToHumanString', (value: string) => {
	return `~ ${numeral(ethers.utils.formatUnits(value, 18)).format('0,00 a')}`
})

const bscAddressFilter = Vue.filter('bscAddress', (address: string) => {
	return address
		.substring(0, 8)
		.concat('...')
		.concat(address.substring(address.length - 6))
})

const banPriceFilter = Vue.filter('banPrice', (amount: string) => {
	return numeral(Number.parseFloat(amount) * ban.banPriceInUSD).format('$0,0.00')
})

const timestampFilter = Vue.filter('timestamp', (timestamp: string) => {
	return date.formatDate(Number.parseInt(timestamp), 'YYYY-MM-DD HH:mm:ss')
})

const hashTrimmedFilter = Vue.filter('hash_trimmed', (hash: string) => {
	return hash
		.substring(0, 6)
		.concat('...')
		.concat(hash.substring(hash.length - 7, hash.length - 1))
})

export { bnToStringFilter, bnToHumanStringFilter, bscAddressFilter, banPriceFilter, timestampFilter, hashTrimmedFilter }
