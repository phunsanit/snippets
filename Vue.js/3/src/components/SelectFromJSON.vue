<script lang="ts">
import { defineComponent, PropType } from 'vue';

interface SelectOption {
  label?: string;
  options?: SelectOption[];
  text: string;
  value: string;
}
/* un used attribute on select
enterkeyhint
inputmode
popover
spellcheck
*/
interface SelectFromJSONProps {
  accesskey?: string;
  autocomplete?: 'on' | 'off';
  autofocus?: boolean;
  class?: string;
  contenteditable?: 'inherit' | 'plaintext-only' | boolean;
  data?: string;
  dir?: 'auto' | 'ltr' | 'rtl';
  disabled?: boolean;
  draggable?: boolean;
  form?: string;
  hidden?: boolean;
  id?: string;
  json: string;//get option form json
  lang?: string;
  multiple?: boolean;
  name: string;
  required?: boolean;
  selected?: string | string[]; // Allow single or multiple selected values
  size?: number;
  style?: string;
  tabindex?: string;
  title?: string;
  translate?: 'yes' | 'no';
}

export default defineComponent({
  async mounted() {
    await this.fetchOptions();
  },
  data() {
    return {
      error: null as string | null,
      loading: true,
      options: [] as SelectOption[],
      selectedOption: this.selected as string | string[] | null, // Initialize with prop value
    };
  },
  emits: ['update:selected'],
  methods: {
    async fetchOptions() {
      this.error = null;
      this.loading = true;
      try {
        const response = await fetch(this.json);
        const data = await response.json() as SelectOption[];
        this.options = data;
      } catch (error) {
        console.error('Error fetching options:', error);
        this.error = (error as any).message || 'Failed to load options.';
      } finally {
        this.loading = false;
      }
    },
    onSelectChange(event: HTMLSelectElement) {
      const value = this.multiple ? Array.from(event.selectedOptions).map(option => option.value) : event.value;
      this.$emit('update:selected', value);
      this.selectedOption = value;
    }
  },
  name: 'SelectFromJSON',
  props: {
    accesskey: { default: null, type: String },
    autocomplete: { default: 'on', type: String as PropType<'on' | 'off'> },
    autofocus: { default: false, type: Boolean },
    class: { default: null, type: String },
    contenteditable: {
      default: null,
      type: String as PropType<'inherit' | 'plaintext-only' | boolean>,
      validator: (value: any) => ['inherit', 'plaintext-only', null].includes(value) || typeof value === 'boolean',
    },
    data: { default: () => ({}), type: Object },
    dir: { default: null, type: String },
    disabled: { default: false, type: Boolean },
    draggable: { default: null, type: Boolean },
    form: { default: '', type: String },
    hidden: { default: false, type: Boolean },
    id: { default: null, type: String },
    json: { required: true, type: String },
    lang: { default: null, type: String },
    multiple: { default: false, type: Boolean },
    name: { required: true, type: String },
    required: { default: false, type: Boolean },
    selected: {
      default: null,
      type: [String, Array] as PropType<string | string[]>
    },
    size: { default: 1, type: Number },
    style: { default: null, type: String },
    tabindex: { default: null, type: String },
    title: { default: null, type: String },
    translate: {
      default: null,
      type: String as PropType<'yes' | 'no'>,
    }
  }
});
</script>

<template>
  <select :value="selectedOption" @change="onSelectChange($event.target as HTMLSelectElement)"
    aria-label="Select an option" v-bind="$props">
    <template v-if="loading">
      <option disabled>Loading...</option>
    </template>
    <template v-else-if="error">
      <option disabled>{{ error }}</option>
    </template>
    <template v-else v-for="option in options">
      <optgroup v-if="option.label" :label="option.label" :key="option.label">
        <option v-for="subOption in option.options" :key="subOption.value" :value="subOption.value"
          :selected="Array.isArray(selectedOption) ? selectedOption.includes(subOption.value) : selectedOption === subOption.value">
          {{ subOption.text }}
        </option>
      </optgroup>
      <option v-else :key="option.value" :value="option.value"
        :selected="Array.isArray(selectedOption) ? selectedOption.includes(option.value) : selectedOption === option.value">
        {{ option.text }}
      </option>
    </template>
  </select>
</template>