export default {
  mounted() {
    if (!this.el.hidden) this.focus();
    this.hiddenBefore = this.el.hidden;
  },
  updated() {
    if (this.hiddenBefore && !this.el.hidden) this.focus();
    this.hiddenBefore = this.el.hidden;
  },
  focus() {
    this.el.focus();
    this.el.select();
  },
};
