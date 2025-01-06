<script lang="ts">
import { defineComponent, PropType } from 'vue';

interface SelectOption {
  label?: string;
  options?: SelectOption[];
  text: string;
  value: string;
}

interface SelectFromJSONProps {
  accesskey?: string;
  autofocus?: boolean;
  class?: string;
  contenteditable?: 'inherit' | 'plaintext-only' | boolean;
  disabled?: boolean;
  draggable?: boolean;
  form?: string;
  id?: string;
  json: string;
  multiple?: boolean;
  name: string;
  required?: boolean;
  selected?: string;
  size?: number;
  spellcheck?: boolean;
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
      options: [] as SelectOption[],
      selectedOption: this.selected as string | null, // Initialize with prop value
    };
  },
  methods: {
    async fetchOptions() {
      try {
        const response = await fetch(this.json);
        const data = await response.json() as SelectOption[];
        this.options = data;
      } catch (error) {
        console.error('Error fetching options:', error);
      }
    },
  },
  name: 'SelectFromJSON',
  props: {
    accesskey: { default: null, type: String },
    autofocus: { default: false, type: Boolean },
    class: { default: null, type: String },
    contenteditable: {
      default: null,
      type: String as PropType<'inherit' | 'plaintext-only' | boolean>,
      validator: (value: any) => ['inherit', 'plaintext-only', null].includes(value) || typeof value === 'boolean',
    },
    disabled: { default: false, type: Boolean },
    draggable: { default: null, type: Boolean },
    form: { default: '', type: String },
    id: { default: null, type: String },
    json: { required: true, type: String },
    multiple: { default: false, type: Boolean },
    name: { required: true, type: String },
    required: { default: false, type: Boolean },
    selected: { default: null, type: String },
    size: { default: 1, type: Number },
    spellcheck: { default: null, type: Boolean },
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
  <select>
    <template v-for="option in options">
      <optgroup v-if="option.label" :label="option.label" :key="option.label">
        <option v-for="subOption in option.options" :key="subOption.value" :value="subOption.value">
          {{ subOption.text }}
        </option>
      </optgroup>
      <option v-else :value="option.value" :key="option.value">
        {{ option.text }}
      </option>
    </template>
  </select>
</template>