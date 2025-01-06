<script lang="ts">
interface Window {
  locales: string[];
  datetimeOptions: {
    year: 'numeric' | '2-digit';
    month: 'numeric' | '2-digit';
    day: 'numeric' | '2-digit';
    hour: 'numeric' | '2-digit';
    minute: 'numeric' | '2-digit';
  };
}

export default {
  computed: {
    formattedDate(this: { datetime: string }) {
      const date: Date = new Date(this.datetime);
      if (!window.datetimeOptions) {
        console.warn('window.datetimeOptions is undefined, using default options');
        window.datetimeOptions = {
          year: 'numeric',
          month: 'numeric',
          day: 'numeric',
          hour: 'numeric',
          minute: 'numeric'
        };
      }
      const datetimeOptions = {
        ...window.datetimeOptions,
        year: window.datetimeOptions.year as 'numeric' | '2-digit',
        month: window.datetimeOptions.month as 'numeric' | '2-digit',
        day: window.datetimeOptions.day as 'numeric' | '2-digit',
        hour: window.datetimeOptions.hour as 'numeric' | '2-digit',
        minute: window.datetimeOptions.minute as 'numeric' | '2-digit'
      };
      const userLocales = window.userLocales ? [...window.userLocales] : ['en-US'];

      return date.toLocaleDateString(userLocales, datetimeOptions);
    }
  },
  name: 'DateLocale',
  props: {
    datetime: {
      type: String,
      required: true
    }
  }
}
</script>

<template>
  <div>{{ formattedDate }}</div>
</template>