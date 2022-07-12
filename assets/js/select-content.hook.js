export default {
  mounted() {
    this.onFocus = () => this.el.select();
    this.el.addEventListener('focus', this.onFocus);
  },
  destroyed() {
    this.el.removeEventListener('focus', this.onFocus);
  },
};
