<template>
	<q-card class="statistics-card">
		<q-card-section>
			<div class="text-h6">wBAN Statistics</div>
			<div class="text-subtitle2">by Benis</div>
		</q-card-section>
		<q-card-section>
			<p>
				<strong>
					Total Supply
					<q-icon name="info" class="dictionary vertical-top">
						<q-tooltip>Number of wBAN that have been created from associated BAN deposits</q-tooltip>
					</q-icon>
					:
				</strong>
				{{ totalSupply | bnToHumanString }} wBAN ({{ totalSupply | bnToString | banPrice }})
			</p>
		</q-card-section>
	</q-card>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import { namespace } from 'vuex-class'
import { bnToStringFilter, banPriceFilter } from '@/utils/filters'
import { BigNumber } from 'ethers'

const contractsStore = namespace('contracts')

@Component({
	filters: {
		bnToStringFilter,
		banPriceFilter
	}
})
export default class Statistics extends Vue {
	@contractsStore.Getter('totalSupply')
	totalSupply!: BigNumber
}
</script>

<style lang="sass" scoped>
@import '@/styles/quasar.sass'

.statistics-card
	background-image: url('../../public/bg-hero.svg') !important
	background-size: cover !important

.dictionary
	margin-left: -3px
</style>
