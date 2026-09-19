import { Controller } from "@hotwired/stimulus"

const GRID_COLOR = "rgba(128, 128, 128, 0.2)"
const ZERO_LINE_COLOR = "rgba(128, 128, 128, 0.5)"

const MARKS = {
  bar: {
    maxBarThickness: 24,
    borderRadius: 4,
    borderSkipped: "bottom",
    categoryPercentage: 0.7,
    barPercentage: 0.9
  },
  line: {
    borderWidth: 2,
    tension: 0,
    pointRadius: 0,
    pointHoverRadius: 4,
    pointHitRadius: 12
  }
}

let chartLibrary = null

// Loaded on demand: controllers are eager-loaded, but few pages draw a chart.
async function loadChart() {
  if (!chartLibrary) {
    const { Chart, registerables } = await import("chart.js")
    Chart.register(...registerables)
    chartLibrary = Chart
  }

  return chartLibrary
}

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    type: String,
    labels: Array,
    series: Array,
    currency: String
  }

  async connect() {
    // Guards a reconnect landing mid-await and building a second chart on the canvas.
    const connection = {}
    this.connection = connection

    this.darkMode = window.matchMedia("(prefers-color-scheme: dark)")
    this.retheme = this._retheme.bind(this)
    this.darkMode.addEventListener("change", this.retheme)

    await this._shown()
    if (this.connection !== connection) return

    const Chart = await loadChart()
    if (this.connection !== connection) return

    const ink = this._ink()

    this.chart = new Chart(this.canvasTarget, {
      type: this.typeValue,
      data: {
        labels: this.labelsValue,
        datasets: this.seriesValue.map((series) => this._dataset(series))
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: "index", intersect: false },
        datasets: { [this.typeValue]: MARKS[this.typeValue] },
        scales: {
          x: {
            grid: { display: false },
            ticks: { autoSkip: true, maxRotation: 0, color: ink }
          },
          y: {
            border: { display: false },
            grid: { color: (context) => (context.tick.value === 0 ? ZERO_LINE_COLOR : GRID_COLOR) },
            ticks: { callback: (value) => this._format(value, 0), color: ink }
          }
        },
        plugins: {
          legend: {
            display: this.seriesValue.length > 1,
            position: "bottom",
            labels: { boxWidth: 12, boxHeight: 12, color: ink }
          },
          tooltip: {
            callbacks: {
              label: (context) => `${context.dataset.label}: ${this._format(context.parsed.y, 2)}`
            }
          }
        }
      }
    })
  }

  disconnect() {
    this.connection = null
    this.darkMode.removeEventListener("change", this.retheme)
    this.chart?.destroy()
    this.chart = null
  }

  // A closed <details> still reports a layout box, so only its toggle is reliable.
  _shown() {
    const details = this.element.closest("details")
    if (!details || details.open) return Promise.resolve()

    return new Promise((resolve) => details.addEventListener("toggle", resolve, { once: true }))
  }

  _retheme() {
    if (!this.chart) return

    const ink = this._ink()

    this.chart.data.datasets.forEach((dataset, index) => {
      Object.assign(dataset, this._dataset(this.seriesValue[index]))
    })
    this.chart.options.scales.x.ticks.color = ink
    this.chart.options.scales.y.ticks.color = ink
    this.chart.options.plugins.legend.labels.color = ink
    this.chart.update()
  }

  _dataset({ label, data, color }) {
    const resolved = this._color(color)

    return { label, data, backgroundColor: resolved, borderColor: resolved }
  }

  _color(property) {
    return getComputedStyle(this.element).getPropertyValue(property).trim()
  }

  _ink() {
    return getComputedStyle(this.element).color
  }

  _format(value, fractionDigits) {
    return new Intl.NumberFormat(undefined, {
      style: "currency",
      currency: this.currencyValue,
      minimumFractionDigits: fractionDigits,
      maximumFractionDigits: fractionDigits
    }).format(value)
  }
}
