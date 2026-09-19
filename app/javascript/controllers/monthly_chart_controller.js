import { Controller } from "@hotwired/stimulus"

const GRID_COLOR = "rgba(128, 128, 128, 0.2)"

let chartLibrary = null

// Loaded on demand: every controller is eager-loaded, but only a couple of pages
// draw a chart.
async function loadChart() {
  if (!chartLibrary) {
    const { Chart, registerables } = await import("chart.js")
    Chart.register(...registerables)
    chartLibrary = Chart
  }

  return chartLibrary
}

// Connects to data-controller="monthly-chart"
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    labels: Array,
    income: Array,
    expense: Array,
    currency: String
  }

  async connect() {
    this.darkMode = window.matchMedia("(prefers-color-scheme: dark)")
    this.retheme = this._retheme.bind(this)
    this.darkMode.addEventListener("change", this.retheme)

    const Chart = await loadChart()
    if (!this.element.isConnected) return

    const colors = this._colors()

    this.chart = new Chart(this.canvasTarget, {
      type: "bar",
      data: {
        labels: this.labelsValue,
        datasets: [
          { label: "Income", data: this.incomeValue, backgroundColor: colors.income },
          { label: "Expenses", data: this.expenseValue, backgroundColor: colors.expense }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        datasets: {
          bar: {
            maxBarThickness: 24,
            borderRadius: 4,
            borderSkipped: "bottom",
            categoryPercentage: 0.7,
            barPercentage: 0.9
          }
        },
        scales: {
          x: {
            grid: { display: false },
            ticks: { autoSkip: true, maxRotation: 0, color: colors.ink }
          },
          y: {
            border: { display: false },
            grid: { color: GRID_COLOR },
            ticks: { callback: (value) => this._format(value, 0), color: colors.ink }
          }
        },
        plugins: {
          legend: {
            position: "bottom",
            labels: { boxWidth: 12, boxHeight: 12, color: colors.ink }
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
    this.darkMode.removeEventListener("change", this.retheme)
    this.chart?.destroy()
    this.chart = null
  }

  _retheme() {
    if (!this.chart) return

    const colors = this._colors()

    this.chart.data.datasets[0].backgroundColor = colors.income
    this.chart.data.datasets[1].backgroundColor = colors.expense
    this.chart.options.scales.x.ticks.color = colors.ink
    this.chart.options.scales.y.ticks.color = colors.ink
    this.chart.options.plugins.legend.labels.color = colors.ink
    this.chart.update()
  }

  _colors() {
    const styles = getComputedStyle(this.element)

    return {
      income: styles.getPropertyValue("--monthly-chart-income").trim(),
      expense: styles.getPropertyValue("--monthly-chart-expense").trim(),
      ink: styles.color
    }
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
