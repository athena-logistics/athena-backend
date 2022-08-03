import {
  CategoryScale,
  Chart,
  LineController,
  LineElement,
  LinearScale,
  PointElement,
  TimeScale,
  Tooltip,
} from "chart.js";
import "chartjs-adapter-luxon";

Chart.register(
  CategoryScale,
  LineController,
  LineElement,
  LinearScale,
  PointElement,
  TimeScale,
  Tooltip
);

const baseColors = [
  "#37B8BF",
  "#5893A4",
  "#796F89",
  "#994A6D",
  "#BA2552",
  "#C6424A",
  "#D25F42",
  "#DE7B39",
  "#EA9831",
  "#C68B4D",
  "#A17E68",
  "#7D7084",
  "#58639F",
];

const backgrounds = [
  ...baseColors,
  ...baseColors,
  ...baseColors,
  ...baseColors,
  ...baseColors,
  ...baseColors,
];

Chart.defaults.responsive = true;
Chart.defaults.maintainAspectRatio = true;
Chart.defaults.aspectRatio = 16 / 9;

function prepareConfig(config) {
  config = addColorsToDataset(config);

  return config;
}

function addColorsToDataset({
  data: { datasets, ...otherData },
  enableVisionImpairedMode = false,
  ...config
}) {
  return {
    data: {
      datasets: datasets.map((dataset, index) => ({
        backgroundColor: backgrounds[index % backgrounds.length],
        borderColor: backgrounds[index % backgrounds.length],
        ...dataset,
      })),
      ...otherData,
    },
    ...config,
  };
}

export default {
  mounted() {
    const { id, data, ...config } = prepareConfig(
      JSON.parse(this.el.dataset.chart)
    );

    this.chart = new Chart(id, { data, ...config });
  },

  updated() {
    const { data } = prepareConfig(JSON.parse(this.el.dataset.chart));

    this.chart.data = data;
    this.chart.update();
  },

  beforeDestroy() {
    this.chart.destroy();
  },
};
