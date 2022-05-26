function getOrientation() {
  return window.innerHeight > window.innerWidth ? 'portrait' : 'landscape';
}

export default {
  mounted() {
    this.lastOrientation = getOrientation();

    this.listener = () => {
      const newOrientation = getOrientation();
      if(this.lastOrientation === newOrientation) return;

      this.lastOrientation = newOrientation;
      this.pushEvent('orientationchange', {orientation: this.lastOrientation});
    }

    this.pushEvent('orientationchange', {orientation: this.lastOrientation});

    window.addEventListener('resize', this.listener);
  },
  destroyed() {
    window.removeEventListener('resize', this.listener);
  }
};
