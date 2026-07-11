import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

const MILESTONES = [
  { key: "turningPoint", emoji: "🔄", label: "Turning point" },
  { key: "dryEnd", emoji: "🟡", label: "Final de secagem" },
  { key: "firstCrack", emoji: "💥", label: "1º Crack" },
  { key: "drop", emoji: "🏁", label: "Saída" },
]

const PHASES = [
  {
    from: "start",
    to: "dryEnd",
    name: "Secagem",
    color: "rgba(254, 240, 138, 0.35)",
    accent: "#a16207",
    labelPosition: "top-left",
  },
  {
    from: "dryEnd",
    to: "firstCrack",
    name: "Maillard",
    color: "rgba(253, 186, 116, 0.35)",
    accent: "#c2410c",
    labelPosition: "top-center",
  },
  {
    from: "firstCrack",
    to: "drop",
    name: "Desenv.",
    color: "rgba(252, 165, 165, 0.35)",
    accent: "#b91c1c",
    labelPosition: "bottom-left",
  },
]

export default class extends Controller {
  static values = { points: Array, milestones: Object }

  connect() {
    const points = this.pointsValue
    const beanTemperature = this.movingAverage(points.map((point) => point.bean_temperature))
    const exhaustTemperature = this.movingAverage(points.map((point) => point.exhaust_temperature))
    const markers = this.buildMilestoneMarkers(points, beanTemperature)
    const phaseBoundaries = {
      start: 0,
      dryEnd: this.milestoneIndex(points, "dryEnd"),
      firstCrack: this.milestoneIndex(points, "firstCrack"),
      drop: this.milestoneIndex(points, "drop") ?? points.length - 1,
    }

    this.chart = new Chart(this.element, {
      type: "line",
      plugins: [this.phaseBackgroundPlugin(points, phaseBoundaries), this.milestoneLabelsPlugin(markers)],
      data: {
        labels: points.map((point) => this.formatTime(point.time_in_seconds)),
        datasets: [
          {
            label: "Temp. do grão (°C)",
            data: beanTemperature,
            borderColor: "#b45309",
            backgroundColor: "#b45309",
            borderWidth: 1,
            pointRadius: 0,
            tension: 0.3,
          },
          {
            label: "Temp. de exaustão (°C)",
            data: exhaustTemperature,
            borderColor: "#2563eb",
            backgroundColor: "#2563eb",
            borderWidth: 1,
            pointRadius: 0,
            tension: 0.3,
          },
          {
            label: "RoR (°C/min)",
            data: points.map((point) => point.ror),
            borderColor: "#059669",
            backgroundColor: "#059669",
            borderWidth: 1,
            pointRadius: 0,
            tension: 0.3,
            yAxisID: "y1",
          },
          {
            label: "Marcos da torra",
            data: markers.values,
            pointStyle: markers.styles,
            pointRadius: markers.radii,
            pointHoverRadius: markers.radii,
            showLine: false,
            borderWidth: 0,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: "index", intersect: false },
        scales: {
          x: { title: { display: true, text: "Tempo" } },
          y: { title: { display: true, text: "Temperatura (°C)" } },
          y1: {
            position: "right",
            grid: { drawOnChartArea: false },
            title: { display: true, text: "RoR (°C/min)" },
          },
        },
        plugins: {
          legend: {
            labels: { filter: (item) => item.text !== "Marcos da torra" },
          },
          tooltip: {
            filter: (item) => item.dataset.label !== "Marcos da torra",
          },
        },
      },
    })
  }

  disconnect() {
    this.chart?.destroy()
  }

  buildMilestoneMarkers(points, beanTemperature) {
    const milestones = this.milestonesValue
    const values = new Array(points.length).fill(null)
    const styles = new Array(points.length).fill("circle")
    const radii = new Array(points.length).fill(0)
    const labels = new Array(points.length).fill(null)

    MILESTONES.forEach(({ key, emoji, label }) => {
      const milestone = milestones[key]
      if (!milestone || milestone.time_in_seconds == null) return

      const index = this.closestIndex(points, milestone.time_in_seconds)
      if (index === -1) return

      const temperature = milestone.celsius_temperature ?? beanTemperature[index]

      values[index] = temperature
      styles[index] = this.emojiPointStyle(emoji)
      radii[index] = 12
      labels[index] = [`${label}: ${Math.round(temperature)}°C`, `Tempo: ${this.formatTime(points[index].time_in_seconds)}`]
    })

    return { values, styles, radii, labels }
  }

  closestIndex(points, targetSeconds) {
    let closestIndex = -1
    let smallestDiff = Infinity

    points.forEach((point, index) => {
      const diff = Math.abs(point.time_in_seconds - targetSeconds)
      if (diff < smallestDiff) {
        smallestDiff = diff
        closestIndex = index
      }
    })

    return closestIndex
  }

  milestoneIndex(points, key) {
    const milestone = this.milestonesValue[key]
    if (!milestone || milestone.time_in_seconds == null) return null

    const index = this.closestIndex(points, milestone.time_in_seconds)
    return index === -1 ? null : index
  }

  phaseBackgroundPlugin(points, boundaries) {
    const totalSeconds = points[boundaries.drop].time_in_seconds - points[boundaries.start].time_in_seconds
    const padding = 6

    return {
      id: "phaseBackground",
      beforeDatasetsDraw: (chart) => {
        const { ctx, chartArea, scales } = chart
        const xScale = scales.x

        ctx.save()
        PHASES.forEach(({ from, to, name, color, accent, labelPosition }) => {
          const fromIndex = boundaries[from]
          const toIndex = boundaries[to]
          if (fromIndex == null || toIndex == null || fromIndex >= toIndex) return

          const xStart = xScale.getPixelForValue(fromIndex)
          const xEnd = xScale.getPixelForValue(toIndex)

          ctx.fillStyle = color
          ctx.fillRect(xStart, chartArea.top, xEnd - xStart, chartArea.bottom - chartArea.top)

          const durationSeconds = points[toIndex].time_in_seconds - points[fromIndex].time_in_seconds
          const percentage = totalSeconds > 0 ? Math.round((durationSeconds / totalSeconds) * 100) : 0
          const detail = `${this.formatTime(durationSeconds)} (${percentage}%)`

          this.drawPhaseBadge(ctx, { xStart, xEnd, chartArea, labelPosition, name, detail, accent, padding })
        })
        ctx.restore()
      },
    }
  }

  drawPhaseBadge(ctx, { xStart, xEnd, chartArea, labelPosition, name, detail, accent, padding }) {
    const titleFont = "bold 11px sans-serif"
    const detailFont = "10px sans-serif"
    const lineHeight = 13
    const boxPaddingX = 8
    const boxPaddingY = 5

    ctx.font = titleFont
    const titleWidth = ctx.measureText(name).width
    ctx.font = detailFont
    const detailWidth = ctx.measureText(detail).width

    const boxWidth = Math.max(titleWidth, detailWidth) + boxPaddingX * 2
    const boxHeight = lineHeight * 2 + boxPaddingY * 2

    let boxX
    let boxY

    if (labelPosition === "top-left") {
      boxX = xStart + padding
      boxY = chartArea.top + padding
    } else if (labelPosition === "top-center") {
      boxX = (xStart + xEnd) / 2 - boxWidth / 2
      boxY = chartArea.top + padding
    } else {
      boxX = xStart + padding
      boxY = chartArea.bottom - padding - boxHeight
    }

    ctx.save()
    ctx.beginPath()
    if (ctx.roundRect) {
      ctx.roundRect(boxX, boxY, boxWidth, boxHeight, 6)
    } else {
      ctx.rect(boxX, boxY, boxWidth, boxHeight)
    }
    ctx.fillStyle = "rgba(255, 255, 255, 0.92)"
    ctx.fill()
    ctx.lineWidth = 1.5
    ctx.strokeStyle = accent
    ctx.stroke()

    ctx.textAlign = "center"
    ctx.textBaseline = "middle"
    const centerX = boxX + boxWidth / 2

    ctx.font = titleFont
    ctx.fillStyle = accent
    ctx.fillText(name, centerX, boxY + boxPaddingY + lineHeight / 2)

    ctx.font = detailFont
    ctx.fillStyle = "#44403c"
    ctx.fillText(detail, centerX, boxY + boxPaddingY + lineHeight + lineHeight / 2)
    ctx.restore()
  }

  milestoneLabelsPlugin(markers) {
    return {
      id: "milestoneLabels",
      afterDatasetsDraw: (chart) => {
        const datasetIndex = chart.data.datasets.findIndex((dataset) => dataset.label === "Marcos da torra")
        if (datasetIndex === -1) return

        const ctx = chart.ctx
        const meta = chart.getDatasetMeta(datasetIndex)

        meta.data.forEach((element, index) => {
          const lines = markers.labels[index]
          if (!lines) return

          const { x, y } = element.getProps(["x", "y"], true)
          const lineHeight = 14
          const boxY = y - 26 - lineHeight

          ctx.save()
          ctx.font = "11px sans-serif"
          ctx.textAlign = "center"
          ctx.textBaseline = "middle"

          const paddingX = 4
          const textWidth = Math.max(...lines.map((line) => ctx.measureText(line).width))

          ctx.fillStyle = "rgba(255, 255, 255, 0.9)"
          ctx.fillRect(x - textWidth / 2 - paddingX, boxY - lineHeight / 2 - 2, textWidth + paddingX * 2, lineHeight * lines.length + 4)

          ctx.fillStyle = "#1c1917"
          lines.forEach((line, lineIndex) => ctx.fillText(line, x, boxY + lineIndex * lineHeight))
          ctx.restore()
        })
      },
    }
  }

  emojiPointStyle(emoji, size = 20) {
    const canvas = document.createElement("canvas")
    canvas.width = size
    canvas.height = size

    const ctx = canvas.getContext("2d")
    ctx.font = `${size - 4}px serif`
    ctx.textAlign = "center"
    ctx.textBaseline = "middle"
    ctx.fillText(emoji, size / 2, size / 2 + 1)

    return canvas
  }

  movingAverage(values, windowSize = 5) {
    return values.map((_, index) => {
      const start = Math.max(0, index - Math.floor(windowSize / 2))
      const window = values.slice(start, start + windowSize)
      return window.reduce((sum, value) => sum + value, 0) / window.length
    })
  }

  formatTime(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = Math.round(totalSeconds % 60)
    return `${minutes}:${seconds.toString().padStart(2, "0")}`
  }
}
