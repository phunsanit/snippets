<script lang="ts">
import { formatDistance } from 'date-fns/formatDistance'

export default {
  computed: {
    formatDistance() {
      const startDate = new Date(0);
      const endDate = new Date(0);
      endDate.setMinutes(Number(this.minutes));

      return formatDistance(startDate, endDate, { addSuffix: false });
    }
  },
  name: 'TimeLocale',
  props: {
    minutes: {
      type: String,
      required: true
    }
  }
}
</script>

<template>
  <div>{{ formatDistance }}</div>
</template>