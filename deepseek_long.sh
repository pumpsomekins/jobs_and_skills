#!/bin/bash

# ==============================================================================
# 1. 区域：输入你的内容 + 自定义输出文件名
# 使用 'EOF' 确保其中的特殊字符不会被 bash 提前解析
# ==============================================================================
# 你的提问内容
read -r -d '' CONTENT << 'EOF'
Working on html code below. Do not change any visual output or data values.
Only fix structure and bugs as described below.

Bug 1 — countryNames redundancy:
  - Delete the entire `countryNames` key from CHEF_DATA
  - In renderNetworkSection, replace D.countryNames[country]||country
    with D.countries[country]?.name || country

Bug 2 — hardcoded network cards:
  - Add a `networkCards` array to CHEF_DATA with this shape:
    { title: string, value: string, meta: string }
  - Extract the four hardcoded cards from renderNetworkSection into this array:
    "Recommended Majors", "Target Courses", "Stretch Majors", "Key Connections"
  - Update renderNetworkSection to render from D.networkCards.map(...)
  - The Hall of Fame card stays rendered separately (it uses country-specific data)

Bug 3 — random MBTI:
  - At the top of the logic <script>, before initAll(), declare:
    const selectedMBTI = D.mbtiData[0];
  - In renderCareerNotes, replace the Math.random() line with selectedMBTI

Bug 4 — hardcoded filter count:
  - In renderFiltersAndTable, replace the hardcoded count (currently 4)
    with D.tasks.length

Bug 5 — version and footnote:
  - Add two fields to CHEF_DATA:
    version: 'v2.2 · Apr 2026',
    footnote: '* Data: Miso Robotics deployments · BLS Occupational Outlook 2025 · JobForesight 2026 · ILO salary benchmarks'
  - In renderFiltersAndTable, replace the hardcoded version string with D.version
  - In the HTML, replace the hardcoded footnote text with a <span id="footnoteText"></span>
    and populate it in initAll() with:
    document.getElementById('footnoteText').textContent = D.footnote;

Rename:
  - Rename CHEF_DATA → JOB_DATA everywhere (both the declaration and const D = JOB_DATA)
  - This makes the logic script reusable across all future occupation files

  <!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Career Intelligence Hub – Chef</title>
    <link href="https://api.fontshare.com/v2/css?f[]=satoshi@400,500,700,900&f[]=cabinet-grotesk@800&display=swap" rel="stylesheet">
    <style>
        *,
        *::before,
        *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0
        }

        :root {
            --bg: #0e0e0e;
            --surface: #161616;
            --surface-2: #1c1c1c;
            --surface-3: #222;
            --border: #2a2a2a;
            --border-hi: #363636;
            --text: #e2e2e2;
            --text-muted: #888;
            --text-faint: #444;
            --green: #22c55e;
            --yellow: #eab308;
            --orange: #f97316;
            --red: #ef4444;
            --accent: #4f98a3;
            --accent-hover: #60b8c4;
            --font-body: 'Satoshi', 'Inter', sans-serif;
            --font-display: 'Cabinet Grotesk', 'Satoshi', sans-serif;
            --ease: cubic-bezier(0.16, 1, 0.3, 1);
            --radius-sm: 4px;
            --radius-md: 8px;
            --radius-lg: 12px;
        }

        html {
            -webkit-font-smoothing: antialiased;
            scroll-behavior: smooth
        }

        body {
            background: var(--bg);
            color: var(--text);
            font-family: var(--font-body);
            font-size: 15px;
            line-height: 1.6;
            min-height: 100dvh
        }

        button {
            cursor: pointer;
            border: none;
            background: none;
            font: inherit
        }

        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background: repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0, 0, 0, .05) 2px, rgba(0, 0, 0, .05) 4px);
            pointer-events: none;
            z-index: 0
        }

        .page {
            position: relative;
            z-index: 1;
            max-width: 1200px;
            margin: 0 auto;
            padding: 36px 24px 80px
        }

        @media(max-width:768px) {
            .page {
                padding: 20px 14px 60px
            }
        }

        .industry-row {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 14px
        }

        .industry-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 11px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: .04em;
            border: 1px solid var(--border-hi);
            color: var(--text-faint);
            cursor: pointer;
            transition: all .18s var(--ease);
            white-space: nowrap
        }

        .industry-pill:hover {
            color: var(--text-muted);
            border-color: var(--text-faint)
        }

        .industry-pill.active {
            color: #fff;
            border-color: transparent;
            background: var(--surface-3)
        }

        .industry-pill .ind-dot {
            width: 5px;
            height: 5px;
            border-radius: 50%;
            background: currentColor;
            flex-shrink: 0;
            opacity: .7
        }

        .header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 28px;
            padding-bottom: 22px;
            border-bottom: 1px solid var(--border)
        }

        .header-tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: var(--accent);
            background: color-mix(in oklch, var(--accent) 12%, transparent);
            border: 1px solid color-mix(in oklch, var(--accent) 30%, transparent);
            padding: 4px 10px;
            border-radius: 4px;
            margin-bottom: 10px
        }

        .header-tag .live-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: var(--accent);
            animation: pulse 2s ease-in-out infinite
        }

        @keyframes pulse {
            0%,
            100% {
                opacity: 1
            }
            50% {
                opacity: .35
            }
        }

        .page-title {
            font-family: var(--font-display);
            font-size: clamp(22px, 4vw, 32px);
            font-weight: 800;
            color: #fff;
            line-height: 1.1;
            margin-bottom: 6px;
            letter-spacing: -.01em
        }

        .page-subtitle {
            font-size: 12px;
            color: var(--text-muted)
        }

        .page-subtitle span {
            color: var(--accent);
            font-size: 11px;
            font-family: monospace
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-shrink: 0;
            padding-top: 2px
        }

        .btn-subscribe {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 9px 18px;
            border-radius: var(--radius-md);
            font-size: 13px;
            font-weight: 700;
            letter-spacing: .02em;
            background: var(--accent);
            color: #fff;
            transition: background .18s var(--ease), transform .15s, box-shadow .18s var(--ease)
        }

        .btn-subscribe:hover {
            background: var(--accent-hover);
            transform: translateY(-1px);
            box-shadow: 0 6px 24px color-mix(in oklch, var(--accent) 35%, transparent)
        }

        .btn-subscribe svg {
            width: 14px;
            height: 14px
        }

        .country-section {
            margin-bottom: 20px
        }

        .country-label {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--text-faint);
            margin-bottom: 10px
        }

        .country-tabs {
            display: flex;
            gap: 6px;
            flex-wrap: wrap
        }

        .ctab {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 13px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-hi);
            font-size: 12px;
            font-weight: 600;
            color: var(--text-muted);
            cursor: pointer;
            transition: all .18s var(--ease);
            white-space: nowrap;
            position: relative
        }

        .ctab:hover {
            border-color: var(--text-faint);
            color: var(--text)
        }

        .ctab.active {
            background: var(--surface-2);
            border-color: var(--accent);
            color: #fff
        }

        .ctab.active::after {
            content: '';
            position: absolute;
            bottom: -7px;
            left: 50%;
            transform: translateX(-50%);
            width: 4px;
            height: 4px;
            border-radius: 50%;
            background: var(--accent)
        }

        .ctab .flag {
            font-size: 14px;
            line-height: 1
        }

        .ctab .cname {
            font-size: 11px
        }

        .ctab .crisk {
            font-size: 10px;
            padding: 1px 5px;
            border-radius: 3px;
            font-weight: 700;
            margin-left: 2px
        }

        .crisk.fast {
            background: color-mix(in oklch, var(--red) 18%, transparent);
            color: var(--red);
            border: 1px solid color-mix(in oklch, var(--red) 30%, transparent)
        }

        .crisk.mid {
            background: color-mix(in oklch, var(--yellow) 14%, transparent);
            color: var(--yellow);
            border: 1px solid color-mix(in oklch, var(--yellow) 25%, transparent)
        }

        .crisk.slow {
            background: color-mix(in oklch, var(--green) 14%, transparent);
            color: var(--green);
            border: 1px solid color-mix(in oklch, var(--green) 25%, transparent)
        }

        .ltv-section {
            margin-bottom: 28px
        }

        .section-label {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: var(--text-faint);
            margin-bottom: 14px
        }

        .ltv-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 10px;
            margin-bottom: 12px
        }

        @media(max-width:1000px) {
            .ltv-grid {
                grid-template-columns: repeat(3, 1fr)
            }
        }

        @media(max-width:600px) {
            .ltv-grid {
                grid-template-columns: repeat(2, 1fr)
            }
        }

        .ltv-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 16px 18px 14px;
            position: relative;
            overflow: hidden;
            transition: border-color .2s, box-shadow .2s var(--ease)
        }

        .ltv-card:hover {
            border-color: var(--border-hi);
            box-shadow: 0 8px 28px rgba(0, 0, 0, .35)
        }

        .ltv-card::after {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(circle at 50% 0%, var(--glow, transparent) 0%, transparent 70%);
            pointer-events: none;
            opacity: .5
        }

        .ltv-card.c-total {
            --glow: color-mix(in oklch, var(--accent) 15%, transparent)
        }

        .ltv-card.c-safe {
            --glow: color-mix(in oklch, var(--green) 12%, transparent)
        }

        .ltv-card.c-risk {
            --glow: color-mix(in oklch, var(--red) 12%, transparent)
        }

        .ltv-card.c-idx {
            --glow: color-mix(in oklch, var(--yellow) 12%, transparent)
        }

        .ltv-card.c-age {
            --glow: color-mix(in oklch, var(--orange) 12%, transparent)
        }

        .ltv-lbl {
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 8px
        }

        .ltv-val {
            font-family: var(--font-display);
            font-size: clamp(20px, 2.5vw, 28px);
            font-weight: 800;
            letter-spacing: -.02em;
            line-height: 1;
            margin-bottom: 4px
        }

        .cl-total {
            color: #fff
        }

        .cl-safe {
            color: var(--green)
        }

        .cl-risk {
            color: var(--red)
        }

        .cl-idx {
            color: var(--yellow)
        }

        .cl-age {
            color: var(--orange)
        }

        .ltv-meta {
            font-size: 10px;
            color: var(--text-faint);
            line-height: 1.4
        }

        .ltv-bar {
            height: 3px;
            background: var(--border);
            border-radius: 2px;
            margin-top: 10px;
            overflow: hidden
        }

        .ltv-bar-fill {
            height: 100%;
            border-radius: 2px;
            transition: width 1.4s var(--ease)
        }

        .age-timeline {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-top: 8px
        }

        .age-seg {
            height: 4px;
            border-radius: 2px;
            transition: width .8s var(--ease)
        }

        .age-seg.safe-seg {
            background: var(--green);
            flex: 1
        }

        .age-seg.risk-seg {
            background: var(--orange);
            flex-shrink: 0
        }

        .age-pins {
            display: flex;
            justify-content: space-between;
            margin-top: 3px
        }

        .age-pin {
            font-size: 9px;
            color: var(--text-faint)
        }

        .age-pin.risk-pin {
            color: var(--orange);
            font-weight: 700
        }

        .ltv-chart-wrap {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 18px 22px;
            margin-bottom: 12px
        }

        .ltv-chart-title {
            font-size: 11px;
            font-weight: 600;
            color: var(--text-muted);
            letter-spacing: .06em;
            text-transform: uppercase;
            margin-bottom: 12px
        }

        .ltv-breakdown {
            display: flex;
            gap: 0;
            height: 24px;
            border-radius: 4px;
            overflow: hidden
        }

        .ltv-seg {
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .04em;
            transition: width 1.2s var(--ease);
            white-space: nowrap;
            overflow: hidden
        }

        .ltv-seg.seg-safe {
            background: color-mix(in oklch, var(--green) 28%, transparent);
            border: 1px solid var(--green);
            color: var(--green)
        }

        .ltv-seg.seg-risk {
            background: color-mix(in oklch, var(--red) 18%, transparent);
            border: 1px solid var(--red);
            border-left: none;
            color: var(--red)
        }

        .ltv-legend {
            display: flex;
            gap: 16px;
            margin-top: 8px;
            flex-wrap: wrap
        }

        .ltv-legend-item {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 10px;
            color: var(--text-muted)
        }

        .ltv-legend-dot {
            width: 8px;
            height: 8px;
            border-radius: 2px;
            flex-shrink: 0
        }

        .car-viz {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 20px 22px
        }

        .car-viz-header {
            display: flex;
            align-items: baseline;
            gap: 10px;
            margin-bottom: 4px;
            flex-wrap: wrap
        }

        .car-viz-eq {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--text-faint)
        }

        .car-viz-val {
            font-family: var(--font-display);
            font-size: clamp(18px, 3vw, 26px);
            font-weight: 800;
            color: #fff;
            transition: all .3s var(--ease)
        }

        .car-viz-val span {
            color: var(--accent)
        }

        .car-viz-sub {
            font-size: 11px;
            color: var(--text-faint);
            margin-bottom: 16px
        }

        .car-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
            margin-bottom: 10px;
            min-height: 60px
        }

        .car-icon {
            width: 38px;
            height: 22px;
            flex-shrink: 0;
            transition: opacity .3s var(--ease), transform .3s var(--ease)
        }

        .car-icon.safe-car {
            color: var(--green);
            opacity: .85
        }

        .car-icon.risk-car {
            color: var(--red);
            opacity: .55
        }

        .car-legend {
            display: flex;
            gap: 16px;
            flex-wrap: wrap
        }

        .car-legend-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 10px;
            color: var(--text-muted)
        }

        .car-legend-swatch {
            width: 24px;
            height: 10px;
            border-radius: 2px
        }

        .car-legend-swatch.safe {
            background: color-mix(in oklch, var(--green) 35%, transparent);
            border: 1px solid var(--green)
        }

        .car-legend-swatch.risk {
            background: color-mix(in oklch, var(--red) 25%, transparent);
            border: 1px solid var(--red)
        }

        .filters-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 14px;
            flex-wrap: wrap
        }

        .filters-left {
            display: flex;
            align-items: center;
            gap: 7px;
            flex-wrap: wrap
        }

        .filter-pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 11px;
            border-radius: 4px;
            border: 1px solid var(--border-hi);
            font-size: 11px;
            font-weight: 600;
            letter-spacing: .04em;
            color: var(--text-muted);
            cursor: pointer;
            transition: all .15s var(--ease)
        }

        .filter-pill.active,
        .filter-pill:hover {
            color: #fff;
            border-color: transparent
        }

        .filter-pill.all.active {
            background: #fff2;
            color: #fff
        }

        .filter-pill.gf.active {
            background: color-mix(in oklch, var(--green) 22%, transparent);
            border-color: var(--green);
            color: var(--green)
        }

        .filter-pill.yf.active {
            background: color-mix(in oklch, var(--yellow) 18%, transparent);
            border-color: var(--yellow);
            color: var(--yellow)
        }

        .filter-pill.of.active {
            background: color-mix(in oklch, var(--orange) 18%, transparent);
            border-color: var(--orange);
            color: var(--orange)
        }

        .filter-pill.rf.active {
            background: color-mix(in oklch, var(--red) 16%, transparent);
            border-color: var(--red);
            color: var(--red)
        }

        .filter-pill .dot {
            width: 5px;
            height: 5px;
            border-radius: 50%;
            background: currentColor
        }

        .table-wrap {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            overflow: hidden
        }

        .table-scroll {
            overflow-x: auto
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 780px
        }

        thead {
            background: var(--surface-2)
        }

        th {
            padding: 11px 16px;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .09em;
            text-transform: uppercase;
            color: var(--text-faint);
            border-bottom: 1px solid var(--border);
            white-space: nowrap
        }

        th:not(:last-child) {
            border-right: 1px solid var(--border)
        }

        td {
            padding: 13px 16px;
            border-bottom: 1px solid var(--border);
            vertical-align: middle
        }

        td:not(:last-child) {
            border-right: 1px solid var(--border)
        }

        tr:last-child td {
            border-bottom: none
        }

        tbody tr {
            transition: background .15s var(--ease)
        }

        tbody tr:hover {
            background: var(--surface-2)
        }

        tbody tr.hidden-row {
            display: none
        }

        .col-action {
            font-weight: 600;
            font-size: 14px;
            color: #fff;
            white-space: nowrap
        }

        .col-human,
        .col-ai {
            font-size: 12px;
            max-width: 200px
        }

        .col-human {
            color: var(--text-muted)
        }

        .col-ai {
            color: #7fb3d3
        }

        .bar-wrap {
            display: flex;
            flex-direction: column;
            gap: 4px;
            min-width: 130px
        }

        .bar-track {
            width: 100%;
            background: var(--border);
            border-radius: 2px;
            height: 5px;
            overflow: hidden
        }

        .bar-fill {
            height: 100%;
            border-radius: 2px;
            transition: width 1.2s var(--ease)
        }

        .bar-lbl {
            font-size: 10px;
            color: var(--text-muted);
            display: flex;
            justify-content: space-between
        }

        .bar-lbl span:last-child {
            font-weight: 700;
            color: var(--text)
        }

        .ltv-chip {
            display: inline-block;
            font-size: 10px;
            font-weight: 700;
            padding: 3px 7px;
            border-radius: 3px;
            letter-spacing: .03em;
            white-space: nowrap
        }

        .ltv-chip.safe {
            background: color-mix(in oklch, var(--green) 14%, transparent);
            color: var(--green);
            border: 1px solid color-mix(in oklch, var(--green) 28%, transparent)
        }

        .ltv-chip.partial {
            background: color-mix(in oklch, var(--yellow) 12%, transparent);
            color: var(--yellow);
            border: 1px solid color-mix(in oklch, var(--yellow) 22%, transparent)
        }

        .ltv-chip.risk {
            background: color-mix(in oklch, var(--red) 12%, transparent);
            color: var(--red);
            border: 1px solid color-mix(in oklch, var(--red) 22%, transparent)
        }

        .eta-badge {
            font-size: 11px;
            color: var(--text-muted);
            white-space: nowrap
        }

        .eta-soon {
            color: var(--orange)
        }

        .eta-mid {
            color: var(--yellow)
        }

        .eta-far {
            color: var(--green)
        }

        .eta-prot {
            color: var(--accent)
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 9px;
            border-radius: 3px;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .07em;
            text-transform: uppercase;
            white-space: nowrap
        }

        .status-badge .dot {
            width: 5px;
            height: 5px;
            border-radius: 50%;
            background: currentColor;
            flex-shrink: 0
        }

        .b-play {
            background: color-mix(in oklch, var(--green) 16%, transparent);
            color: var(--green);
            border: 1px solid color-mix(in oklch, var(--green) 30%, transparent)
        }

        .b-ing {
            background: color-mix(in oklch, var(--yellow) 13%, transparent);
            color: var(--yellow);
            border: 1px solid color-mix(in oklch, var(--yellow) 25%, transparent)
        }

        .b-intro {
            background: color-mix(in oklch, var(--orange) 14%, transparent);
            color: var(--orange);
            border: 1px solid color-mix(in oklch, var(--orange) 28%, transparent)
        }

        .b-none {
            background: color-mix(in oklch, var(--red) 13%, transparent);
            color: var(--red);
            border: 1px solid color-mix(in oklch, var(--red) 25%, transparent)
        }

        .summary-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-top: 12px
        }

        @media(max-width:640px) {
            .summary-row {
                grid-template-columns: 1fr
            }
        }

        .summary-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 14px 16px;
            font-size: 12px;
            color: var(--text-muted)
        }

        .summary-card strong {
            color: var(--text);
            display: block;
            font-size: 14px;
            font-weight: 700;
            margin-bottom: 3px
        }

        .footnote {
            margin-top: 12px;
            font-size: 10px;
            color: var(--text-faint);
            text-align: right
        }

        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, .75);
            backdrop-filter: blur(6px);
            z-index: 100;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            opacity: 0;
            pointer-events: none;
            transition: opacity .25s var(--ease)
        }

        .modal-overlay.open {
            opacity: 1;
            pointer-events: all
        }

        .modal {
            background: var(--surface-2);
            border: 1px solid var(--border-hi);
            border-radius: var(--radius-lg);
            padding: 30px;
            max-width: 420px;
            width: 100%;
            transform: translateY(14px) scale(.97);
            transition: transform .28s var(--ease);
            position: relative
        }

        .modal-overlay.open .modal {
            transform: none
        }

        .modal-close {
            position: absolute;
            top: 12px;
            right: 12px;
            width: 28px;
            height: 28px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-muted);
            transition: background .15s, color .15s
        }

        .modal-close:hover {
            background: var(--border);
            color: var(--text)
        }

        .modal-icon {
            width: 42px;
            height: 42px;
            background: color-mix(in oklch, var(--accent) 16%, transparent);
            border: 1px solid color-mix(in oklch, var(--accent) 32%, transparent);
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--accent);
            margin-bottom: 14px
        }

        .modal-title {
            font-family: var(--font-display);
            font-size: 19px;
            font-weight: 800;
            color: #fff;
            margin-bottom: 5px;
            letter-spacing: -.01em
        }

        .modal-desc {
            font-size: 12px;
            color: var(--text-muted);
            margin-bottom: 22px;
            line-height: 1.6
        }

        .modal-desc strong {
            color: var(--text)
        }

        .input-group {
            display: flex;
            gap: 7px;
            margin-bottom: 12px
        }

        .modal-input {
            flex: 1;
            background: var(--surface);
            border: 1px solid var(--border-hi);
            border-radius: var(--radius-md);
            padding: 9px 13px;
            color: var(--text);
            font: inherit;
            font-size: 13px;
            outline: none;
            transition: border-color .18s
        }

        .modal-input::placeholder {
            color: var(--text-faint)
        }

        .modal-input:focus {
            border-color: var(--accent)
        }

        .btn-confirm {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 9px 16px;
            border-radius: var(--radius-md);
            background: var(--accent);
            color: #fff;
            font: inherit;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            border: none;
            white-space: nowrap;
            transition: background .18s var(--ease), transform .15s
        }

        .btn-confirm:hover {
            background: var(--accent-hover);
            transform: translateY(-1px)
        }

        .modal-tags {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            margin-top: 4px
        }

        .modal-tag {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 5px 9px;
            border: 1px solid var(--border-hi);
            border-radius: 4px;
            font-size: 11px;
            color: var(--text-muted);
            cursor: pointer;
            transition: all .15s
        }

        .modal-tag:hover,
        .modal-tag.sel {
            border-color: var(--accent);
            color: var(--accent);
            background: color-mix(in oklch, var(--accent) 10%, transparent)
        }

        .modal-success {
            text-align: center;
            padding: 14px 0;
            display: none
        }

        .modal-success .check {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: color-mix(in oklch, var(--green) 16%, transparent);
            border: 1px solid var(--green);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--green);
            margin: 0 auto 12px;
            font-size: 22px
        }

        .modal-success h3 {
            color: #fff;
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 5px
        }

        .modal-success p {
            font-size: 12px;
            color: var(--text-muted)
        }

        .toast {
            position: fixed;
            bottom: 22px;
            right: 22px;
            background: var(--surface-2);
            border: 1px solid var(--border-hi);
            border-radius: var(--radius-md);
            padding: 11px 15px;
            font-size: 12px;
            color: var(--text);
            display: flex;
            align-items: center;
            gap: 9px;
            z-index: 200;
            box-shadow: 0 8px 32px rgba(0, 0, 0, .5);
            transform: translateY(18px);
            opacity: 0;
            transition: all .28s var(--ease)
        }

        .toast.show {
            transform: none;
            opacity: 1
        }

        .toast-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: var(--green);
            flex-shrink: 0;
            animation: pulse 2s infinite
        }

        .ltv-fade {
            animation: fadeIn .4s var(--ease)
        }

        @keyframes fadeIn {
            from {
                opacity: .2;
                transform: translateY(4px)
            }
            to {
                opacity: 1;
                transform: none
            }
        }

        .level-section {
            margin-bottom: 20px
        }

        .level-tabs {
            display: flex;
            align-items: center;
            gap: 0;
            flex-wrap: wrap
        }

        .ltab {
            position: relative;
            display: inline-flex;
            flex-direction: column;
            align-items: center;
            gap: 3px;
            padding: 9px 16px;
            border: 1px solid var(--border-hi);
            font-size: 12px;
            font-weight: 700;
            color: var(--text-muted);
            cursor: pointer;
            transition: all .18s var(--ease);
            background: var(--surface);
            white-space: nowrap;
            margin-right: -1px
        }

        .ltab:first-child {
            border-radius: var(--radius-md) 0 0 var(--radius-md)
        }

        .ltab:last-child {
            border-radius: 0 var(--radius-md) var(--radius-md) 0;
            margin-right: 0
        }

        .ltab:hover {
            color: var(--text);
            background: var(--surface-2);
            z-index: 1
        }

        .ltab.active {
            background: var(--surface-2);
            border-color: var(--accent);
            color: #fff;
            z-index: 2
        }

        .ltab .lyears {
            font-size: 9px;
            font-weight: 500;
            color: var(--text-faint);
            letter-spacing: .04em
        }

        .ltab.active .lyears {
            color: var(--accent)
        }

        .ltab .lpct {
            font-size: 9px;
            font-weight: 700;
            color: var(--accent);
            letter-spacing: .03em;
            background: color-mix(in oklch, var(--accent) 12%, transparent);
            border: 1px solid color-mix(in oklch, var(--accent) 25%, transparent);
            padding: 1px 5px;
            border-radius: 3px;
            margin-top: 1px
        }

        .ltab.active .lpct {
            background: color-mix(in oklch, var(--accent) 20%, transparent)
        }

        .ltab .lcolor-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: var(--ldot, var(--text-faint));
            margin-bottom: 2px
        }

        .income-chart-wrap {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 20px 22px;
            margin-bottom: 12px
        }

        .income-chart-header {
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            margin-bottom: 14px;
            flex-wrap: wrap;
            gap: 8px
        }

        .income-chart-title {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--text-faint)
        }

        .income-chart-note {
            font-size: 10px;
            color: var(--text-faint)
        }

        #incomeSVG {
            width: 100%;
            overflow: visible;
            display: block
        }

        .level-legend {
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
            margin-top: 10px
        }

        .level-legend-item {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 10px;
            color: var(--text-muted)
        }

        .level-legend-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            flex-shrink: 0
        }

        .promo-section {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 18px 22px;
            margin-bottom: 12px
        }

        .promo-flow {
            display: flex;
            align-items: center;
            gap: 0;
            overflow-x: auto;
            padding: 4px 0
        }

        .promo-node {
            display: flex;
            flex-direction: column;
            align-items: center;
            min-width: 100px;
            gap: 5px
        }

        .promo-circle {
            width: 46px;
            height: 46px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: .02em;
            text-align: center;
            border: 2px solid;
            line-height: 1.2
        }

        .promo-label {
            font-size: 10px;
            font-weight: 600;
            color: var(--text-muted);
            text-align: center;
            max-width: 90px;
            line-height: 1.3
        }

        .promo-salary {
            font-size: 10px;
            color: var(--text-faint);
            text-align: center;
            font-weight: 700
        }

        .promo-arrow {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 2px;
            padding: 0 4px;
            min-width: 52px
        }

        .promo-arrow-line {
            width: 100%;
            height: 1px;
            background: var(--border-hi);
            position: relative
        }

        .promo-arrow-line::after {
            content: '▶';
            position: absolute;
            right: -5px;
            top: -5px;
            font-size: 10px;
            color: var(--text-faint)
        }

        .promo-arrow-years {
            font-size: 9px;
            color: var(--accent);
            font-weight: 700;
            white-space: nowrap;
            text-align: center
        }

        .promo-arrow-sub {
            font-size: 8px;
            color: var(--text-faint);
            white-space: nowrap
        }

        .insights-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-bottom: 12px
        }

        @media(max-width:768px) {
            .insights-grid {
                grid-template-columns: repeat(2, 1fr)
            }
        }

        @media(max-width:480px) {
            .insights-grid {
                grid-template-columns: 1fr
            }
        }

        .insight-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 16px 18px;
            position: relative;
            overflow: hidden;
            transition: border-color .2s
        }

        .insight-card:hover {
            border-color: var(--border-hi)
        }

        .insight-icon {
            font-size: 22px;
            margin-bottom: 8px;
            display: block
        }

        .insight-label {
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 4px
        }

        .insight-value {
            font-family: var(--font-display);
            font-size: clamp(16px, 2vw, 22px);
            font-weight: 800;
            color: #fff;
            line-height: 1;
            margin-bottom: 4px
        }

        .insight-meta {
            font-size: 10px;
            color: var(--text-faint);
            line-height: 1.4
        }

        .difficulty-bar {
            display: flex;
            gap: 3px;
            margin-top: 8px
        }

        .diff-pip {
            width: 14px;
            height: 6px;
            border-radius: 2px;
            background: var(--border)
        }

        .diff-pip.filled-low {
            background: var(--green)
        }

        .diff-pip.filled-mid {
            background: var(--yellow)
        }

        .diff-pip.filled-high {
            background: var(--orange)
        }

        .diff-pip.filled-max {
            background: var(--red)
        }

        .hazards-section {
            margin-bottom: 12px
        }

        .hazards-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 8px
        }

        @media(max-width:600px) {
            .hazards-grid {
                grid-template-columns: repeat(2, 1fr)
            }
        }

        .hazard-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 12px 14px;
            display: flex;
            align-items: center;
            gap: 10px
        }

        .hazard-icon {
            font-size: 20px;
            flex-shrink: 0
        }

        .hazard-info {
            flex: 1;
            min-width: 0
        }

        .hazard-name {
            font-size: 11px;
            font-weight: 700;
            color: var(--text);
            margin-bottom: 4px
        }

        .hazard-bar-track {
            width: 100%;
            height: 4px;
            background: var(--border);
            border-radius: 2px;
            overflow: hidden
        }

        .hazard-bar-fill {
            height: 100%;
            border-radius: 2px
        }

        .hazard-level {
            font-size: 9px;
            color: var(--text-faint);
            margin-top: 3px
        }

        .haz-1 {
            background: var(--green)
        }

        .haz-2 {
            background: color-mix(in oklch, var(--green) 60%, var(--yellow))
        }

        .haz-3 {
            background: var(--yellow)
        }

        .haz-4 {
            background: var(--orange)
        }

        .haz-5 {
            background: var(--red)
        }

        .lang-section {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 18px 22px;
            margin-bottom: 12px
        }

        .lang-list {
            display: flex;
            flex-direction: column;
            gap: 10px
        }

        .lang-row {
            display: flex;
            align-items: center;
            gap: 12px
        }

        .lang-name {
            font-size: 13px;
            font-weight: 700;
            color: #fff;
            min-width: 90px
        }

        .lang-level-pill {
            display: inline-flex;
            align-items: center;
            padding: 3px 9px;
            border-radius: 3px;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .05em;
            white-space: nowrap
        }

        .llp-essential {
            background: color-mix(in oklch, var(--red) 14%, transparent);
            color: var(--red);
            border: 1px solid color-mix(in oklch, var(--red) 28%, transparent)
        }

        .llp-helpful {
            background: color-mix(in oklch, var(--yellow) 12%, transparent);
            color: var(--yellow);
            border: 1px solid color-mix(in oklch, var(--yellow) 22%, transparent)
        }

        .llp-optional {
            background: color-mix(in oklch, var(--green) 12%, transparent);
            color: var(--green);
            border: 1px solid color-mix(in oklch, var(--green) 22%, transparent)
        }

        .llp-senior {
            background: color-mix(in oklch, var(--accent) 12%, transparent);
            color: var(--accent);
            border: 1px solid color-mix(in oklch, var(--accent) 22%, transparent)
        }

        .lang-bar-wrap {
            flex: 1;
            max-width: 180px
        }

        .lang-bar-track {
            width: 100%;
            height: 4px;
            background: var(--border);
            border-radius: 2px;
            overflow: hidden
        }

        .lang-bar-fill {
            height: 100%;
            border-radius: 2px;
            background: var(--accent)
        }

        .heatmap-section {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 18px 22px;
            margin-bottom: 12px
        }

        .heatmap-header {
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            margin-bottom: 14px;
            flex-wrap: wrap;
            gap: 8px
        }

        .heatmap-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
            gap: 8px
        }

        .city-card {
            border-radius: var(--radius-md);
            padding: 12px 14px;
            position: relative;
            overflow: hidden;
            cursor: default;
            transition: transform .15s var(--ease), box-shadow .15s
        }

        .city-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, .4)
        }

        .city-name {
            font-size: 12px;
            font-weight: 700;
            color: #fff;
            margin-bottom: 2px
        }

        .city-region {
            font-size: 9px;
            color: rgba(255, 255, 255, .5);
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: .06em
        }

        .city-salary {
            font-size: 14px;
            font-weight: 800;
            color: #fff;
            font-family: var(--font-display)
        }

        .city-cost {
            font-size: 9px;
            color: rgba(255, 255, 255, .55);
            margin-top: 2px
        }

        .heatmap-scale {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 10px;
            flex-wrap: wrap
        }

        .heatmap-scale-bar {
            display: flex;
            height: 6px;
            border-radius: 3px;
            overflow: hidden;
            flex: 1;
            max-width: 200px
        }

        .hs-low {
            background: var(--red);
            flex: 1
        }

        .hs-mid {
            background: var(--yellow);
            flex: 1
        }

        .hs-high {
            background: var(--green);
            flex: 1
        }

        .heatmap-scale-labels {
            display: flex;
            justify-content: space-between;
            width: 100%;
            max-width: 200px;
            font-size: 9px;
            color: var(--text-faint)
        }

        .extended-section {
            margin-bottom: 12px
        }

        .extended-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-bottom: 12px
        }

        @media(max-width:768px) {
            .extended-grid {
                grid-template-columns: repeat(2, 1fr)
            }
        }

        @media(max-width:480px) {
            .extended-grid {
                grid-template-columns: 1fr
            }
        }

        .link-grid-extended {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px
        }

        @media(max-width:900px) {
            .link-grid-extended {
                grid-template-columns: repeat(2, 1fr)
            }
        }

        @media(max-width:560px) {
            .link-grid-extended {
                grid-template-columns: 1fr
            }
        }

        .link-card,
        .note-card,
        .insight-card,
        .ltv-card,
        .summary-card,
        .ctab,
        .ltab,
        .filter-pill,
        .industry-pill,
        .modal-tag {
            transition: border-color 0.2s var(--ease), transform 0.2s var(--ease), box-shadow 0.2s var(--ease), background-color 0.2s var(--ease);
        }

        .link-card:hover,
        .note-card:hover,
        .insight-card:hover,
        .ltv-card:hover,
        .summary-card:hover,
        .ctab:hover,
        .ltab:hover,
        .filter-pill:hover:not(.active),
        .industry-pill:hover:not(.active),
        .modal-tag:hover:not(.sel) {
            border-color: var(--border-hi);
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
        }

        .link-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 14px 16px
        }

        .link-card-title {
            font-size: 12px;
            font-weight: 700;
            color: #fff;
            margin-bottom: 4px
        }

        .link-card-desc {
            font-size: 10px;
            color: var(--text-muted);
            line-height: 1.5
        }

        .note-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-bottom: 12px
        }

        @media(max-width:900px) {
            .note-grid {
                grid-template-columns: repeat(2, 1fr)
            }
        }

        @media(max-width:560px) {
            .note-grid {
                grid-template-columns: 1fr
            }
        }

        .note-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 16px 18px;
            position: relative;
            overflow: hidden
        }

        .note-title {
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 6px
        }

        .note-value {
            font-family: var(--font-display);
            font-size: 16px;
            font-weight: 800;
            color: #fff;
            line-height: 1.2;
            margin-bottom: 6px
        }

        .note-meta {
            font-size: 11px;
            color: var(--text-muted);
            line-height: 1.55
        }

        .sec-divider {
            height: 1px;
            background: var(--border);
            margin: 20px 0
        }

        .theme-toggle {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 14px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-hi);
            background: var(--surface);
            color: var(--text-muted);
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            transition: all .18s var(--ease);
            letter-spacing: .04em
        }

        .theme-toggle:hover {
            border-color: var(--accent);
            color: var(--text)
        }

        .theme-toggle .th-icon {
            font-size: 15px;
            line-height: 1
        }

        .btn-ghost {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 14px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-hi);
            background: var(--surface);
            color: var(--text-muted);
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            transition: all .18s var(--ease);
            letter-spacing: .04em
        }

        .btn-ghost:hover {
            border-color: var(--accent);
            color: var(--text)
        }

        .btn-login {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 9px 18px;
            border-radius: var(--radius-md);
            font-size: 13px;
            font-weight: 700;
            letter-spacing: .02em;
            background: var(--surface-3);
            color: #fff;
            border: 1px solid var(--border-hi);
            transition: all .18s var(--ease);
            cursor: pointer
        }

        .btn-login:hover {
            background: var(--surface-2);
            border-color: var(--text-muted)
        }

        html[data-theme="light"] {
            --bg: #f4f4f5;
            --surface: #ffffff;
            --surface-2: #f0f0f0;
            --surface-3: #e8e8e8;
            --border: #e0e0e0;
            --border-hi: #cccccc;
            --text: #111111;
            --text-muted: #555555;
            --text-faint: #999999;
            --green: #16a34a;
            --yellow: #ca8a04;
            --orange: #ea580c;
            --red: #dc2626;
            --accent: #2a7b8a;
            --accent-hover: #1e6474;
        }

        html[data-theme="light"] body {
            color: var(--text)
        }

        html[data-theme="light"] body::before {
            background: repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0, 0, 0, .02) 2px, rgba(0, 0, 0, .02) 4px)
        }

        html[data-theme="light"] .page-title {
            color: #111
        }

        html[data-theme="light"] .col-action {
            color: #111
        }

        html[data-theme="light"] thead {
            background: var(--surface-2)
        }

        html[data-theme="light"] .modal {
            background: var(--surface)
        }

        html[data-theme="light"] .modal-title {
            color: #111
        }

        html[data-theme="light"] .car-viz-val {
            color: #111
        }

        html[data-theme="light"] .insight-value {
            color: #111
        }

        html[data-theme="light"] .note-value {
            color: #111
        }

        html[data-theme="light"] .ltv-val.cl-total {
            color: #111
        }

        html[data-theme="light"] .city-name {
            color: #111
        }

        html[data-theme="light"] .city-salary {
            color: #111
        }

        html[data-theme="light"] .promo-label {
            color: var(--text-muted)
        }

        html[data-theme="light"] .table-wrap {
            background: var(--surface)
        }

        html[data-theme="light"] tbody tr:hover {
            background: var(--surface-2)
        }

        html[data-theme="light"] .summary-card strong {
            color: #111
        }

        html[data-theme="light"] .modal-input {
            background: var(--surface-2);
            color: #111
        }

        html[data-theme="light"] .lang-name {
            color: #111
        }
    </style>
</head>
<body>

    <!-- SVG Car Symbol (hidden) -->
    <svg style="display:none" xmlns="http://www.w3.org/2000/svg">
        <symbol id="car" viewBox="0 0 38 22">
            <rect x="1" y="8" width="36" height="9" rx="2" fill="currentColor" opacity=".9" />
            <path d="M8 8 L13 3 H25 L30 8 Z" fill="currentColor" />
            <circle cx="10" cy="19" r="3" fill="currentColor" />
            <circle cx="28" cy="19" r="3" fill="currentColor" />
            <rect x="13.5" y="3.5" width="4" height="4" rx=".7" fill="rgba(0,0,0,.35)" />
            <rect x="18.5" y="3.5" width="4" height="4" rx=".7" fill="rgba(0,0,0,.35)" />
        </symbol>
    </svg>

    <!-- Modal -->
    <div class="modal-overlay" id="modalOverlay" role="dialog" aria-modal="true">
        <div class="modal">
            <button class="modal-close" id="modalClose" aria-label="Close">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 6 6 18M6 6l12 12" /></svg>
            </button>
            <div id="modalForm">
                <div class="modal-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.73 21a2 2 0 0 1-3.46 0" /></svg>
                </div>
                <div class="modal-title">Subscribe to AI Threat Alerts</div>
                <div class="modal-desc">Get notified when automation risk changes for <strong>Chef / Cook</strong> roles. Updates sourced from Miso Robotics, BLS, and JobForesight.</div>
                <div class="input-group">
                    <input class="modal-input" id="emailInput" type="email" placeholder="your@email.com" autocomplete="email">
                    <button class="btn-confirm" id="confirmBtn">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12" /></svg>
                        Subscribe
                    </button>
                </div>
                <div style="font-size:10px;color:var(--text-faint);margin-bottom:12px">Select alert types:</div>
                <div class="modal-tags" id="modalTags">
                    <span class="modal-tag sel" data-val="status">📊 Status Changes</span>
                    <span class="modal-tag sel" data-val="ltv">💰 LTV Updates</span>
                    <span class="modal-tag" data-val="weekly">📅 Weekly Digest</span>
                    <span class="modal-tag" data-val="break">⚡ Tech Breakthroughs</span>
                </div>
            </div>
            <div class="modal-success" id="modalSuccess">
                <div class="check">✓</div>
                <h3>You're subscribed!</h3>
                <p>We'll alert you when Chef/Cook automation landscape changes. Confirm via email.</p>
            </div>
        </div>
    </div>

    <!-- Toast -->
    <div class="toast" id="toast">
        <span class="toast-dot"></span>
        <span id="toastMsg">Subscribed successfully</span>
    </div>

    <!-- Page -->
    <div class="page">

        <!-- Industry Tags -->
        <div class="industry-row" role="group" aria-label="Industry segments" id="industryRow"></div>

        <!-- Header -->
        <header class="header">
            <div>
                <div class="header-tag"><span class="live-dot"></span> Live Tracking</div>
                <h1 class="page-title">AI Career<br>Intelligence Hub</h1>
                <p class="page-subtitle">Target Occupation: <span>CHEF / COOK (ID: OCC-2026-C)</span></p>
            </div>
            <div class="header-right">
                <button class="btn-ghost">Upload Resume</button>
                <button class="btn-ghost">Enter MBTI</button>
                <button class="btn-login">Login</button>
                <button class="theme-toggle" id="themeToggle" title="Toggle light/dark mode">
                    <span class="th-icon">☀️</span><span id="themeLabel">Light</span>
                </button>
                <button class="btn-subscribe" id="openModal">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" /><path d="M13.73 21a2 2 0 0 1-3.46 0" /></svg>
                    Subscribe
                </button>
            </div>
        </header>

        <!-- Country Selector -->
        <div class="country-section">
            <div class="country-label">Select Region — LTV &amp; Risk Age by Country</div>
            <div class="country-tabs" role="tablist" id="countryTabs"></div>
        </div>

        <!-- Career Level Selector -->
        <div class="level-section">
            <div class="section-label">Career Level — Click to compare salary, LTV &amp; insights</div>
            <div class="level-tabs" id="levelTabs"></div>
        </div>

        <!-- LTV Section -->
        <section class="ltv-section">
            <div class="section-label">Job Lifetime Value Analysis</div>
            <div class="ltv-grid" id="ltvKpiGrid"></div>
            <div class="ltv-chart-wrap" id="ltvBreakdownWrap"></div>
            <div class="car-viz" id="carVizWrap"></div>
        </section>

        <!-- Income Curve Chart -->
        <div class="income-chart-wrap" id="incomeChartWrap"></div>

        <!-- Promotion Ladder -->
        <div class="promo-section" style="margin-bottom:12px" id="promoSectionWrap"></div>

        <!-- Career Insights -->
        <div class="sec-divider"></div>
        <div class="section-label">Career Profile Insights</div>
        <div class="insights-grid" id="insightsGrid"></div>

        <!-- Language Requirements -->
        <div class="lang-section" id="langSection"></div>

        <!-- City Income Heatmap -->
        <div class="heatmap-section" id="heatmapSection"></div>

        <!-- Occupational Hazards -->
        <div class="hazards-section" id="hazardsSection"></div>

        <!-- Extended Sections -->
        <div class="extended-section" id="extraInsightsSection"></div>
        <div class="extended-section" id="accessSection"></div>
        <div class="extended-section" id="careerNotesSection"></div>
        <div class="sec-divider"></div>

        <!-- Career Recommendations -->
        <div class="extended-section" id="careerRecsSection"></div>

        <!-- Study & Network Recommendations -->
        <div class="extended-section" id="networkSection"></div>

        <!-- Filters + Table -->
        <div class="filters-row" id="filtersRow"></div>
        <div class="table-wrap" id="tableWrap"></div>

        <!-- Summary -->
        <div class="summary-row" id="summaryRow"></div>
        <div class="footnote">* Data: Miso Robotics deployments · BLS Occupational Outlook 2025 · JobForesight 2026 · ILO salary benchmarks</div>
    </div>

    <!-- ═══════════════════════════════════════════════════════════════════════ -->
    <!-- ░░░░░░  ALL EDITABLE DATA — Single Configuration Object ░░░░░░░░░░░░ -->
    <!-- ═══════════════════════════════════════════════════════════════════════ -->
    <script>
        // ==========================================================================
        //  CHEF_DATA — The single source of truth for ALL data in this dashboard.
        //  To edit any value (salary, city, risk age, language, etc.), modify the
        //  relevant section below. The UI will automatically reflect changes.
        // ==========================================================================
        const CHEF_DATA = {

            // ── Industry Tags ──────────────────────────────────────────────────────
            industries: [
                { id: 'fb', label: 'Food & Beverage', active: true },
                { id: 'hosp', label: 'Hospitality', active: false },
                { id: 'qsr', label: 'QSR / Fast Food', active: false },
                { id: 'fine', label: 'Fine Dining', active: false },
                { id: 'cat', label: 'Catering', active: false },
                { id: 'inst', label: 'Institutional', active: false },
            ],

            // ── Countries ─────────────────────────────────────────────────────────
            countries: {
                US: { name: 'United States', symbol: '$', annualUSD: 56000, annualLocal: 56000,
                    career: 30, automationIdx: 37, carName: 'Toyota Camry', carPriceUSD: 28000,
                    riskAge: 47, startAge: 25, localDisplay: '$56,000/yr (USD)', flag: '🇺🇸',
                    riskLabel: 'MID', riskClass: 'mid' },
                UK: { name: 'United Kingdom', symbol: '£', annualUSD: 44000, annualLocal: 35000,
                    career: 30, automationIdx: 37, carName: 'Ford Focus', carPriceUSD: 26000,
                    riskAge: 49, startAge: 25, localDisplay: '~£35K/yr (~$44K)', flag: '🇬🇧',
                    riskLabel: 'MID', riskClass: 'mid' },
                AU: { name: 'Australia', symbol: 'A$', annualUSD: 42000, annualLocal: 65000,
                    career: 30, automationIdx: 37, carName: 'Toyota RAV4', carPriceUSD: 28000,
                    riskAge: 48, startAge: 25, localDisplay: '~A$65K/yr (~$42K)', flag: '🇦🇺',
                    riskLabel: 'MID', riskClass: 'mid' },
                DE: { name: 'Germany', symbol: '€', annualUSD: 41000, annualLocal: 38000, career: 30,
                    automationIdx: 37, carName: 'VW Golf', carPriceUSD: 30000, riskAge: 50, startAge: 25,
                    localDisplay: '~€38K/yr (~$41K)', flag: '🇩🇪', riskLabel: 'SLOW', riskClass: 'slow' },
                JP: { name: 'Japan', symbol: '¥', annualUSD: 28000, annualLocal: 4200000, career: 30,
                    automationIdx: 37, carName: 'Toyota Corolla', carPriceUSD: 18000, riskAge: 52,
                    startAge: 25, localDisplay: '~¥4.2M/yr (~$28K)', flag: '🇯🇵', riskLabel: 'SLOW',
                    riskClass: 'slow' },
                SG: { name: 'Singapore', symbol: 'S$', annualUSD: 31000, annualLocal: 42000, career: 30,
                    automationIdx: 37, carName: 'Toyota Corolla*', carPriceUSD: 88000, riskAge: 46,
                    startAge: 25, localDisplay: '~S$42K/yr (~$31K)', flag: '🇸🇬', riskLabel: 'FAST',
                    riskClass: 'fast' },
                TW: { name: 'Taiwan', symbol: 'NT$', annualUSD: 15000, annualLocal: 480000, career: 30,
                    automationIdx: 37, carName: 'Toyota Corolla', carPriceUSD: 22000, riskAge: 45,
                    startAge: 25, localDisplay: '~NT$480K/yr (~$15K)', flag: '🇹🇼', riskLabel: 'FAST',
                    riskClass: 'fast' },
                CN: { name: 'China', symbol: '¥', annualUSD: 12000, annualLocal: 86000, career: 30,
                    automationIdx: 37, carName: 'BYD Seagull', carPriceUSD: 12000, riskAge: 44,
                    startAge: 25, localDisplay: '~¥86K/yr (~$12K)', flag: '🇨🇳', riskLabel: 'FAST',
                    riskClass: 'fast' },
            },

            // ── Career Levels ──────────────────────────────────────────────────────
            levels: [
                { id: 0, name: 'Line Cook', short: 'Line', yearsFrom: 0, color: '#888888',
                    yearsLabel: 'Entry · Yr 0' },
                { id: 1, name: 'Chef de Partie', short: 'CDP', yearsFrom: 2, color: '#4f98a3',
                    yearsLabel: '≈ 2–3 yrs' },
                { id: 2, name: 'Sous Chef', short: 'Sous', yearsFrom: 5, color: '#eab308',
                    yearsLabel: '≈ 5–6 yrs' },
                { id: 3, name: 'Head Chef', short: 'Head', yearsFrom: 8, color: '#f97316',
                    yearsLabel: '≈ 8–11 yrs' },
                { id: 4, name: 'Executive Chef', short: 'Exec', yearsFrom: 16, color: '#22c55e',
                    yearsLabel: '≈ 16–19 yrs' },
            ],

            // ── Promotion Transitions ──────────────────────────────────────────────
            promotions: [
                { from: 'Line Cook', to: 'Chef de Partie', years: '2–3 yrs',
                    tip: 'Station mastery required' },
                { from: 'Chef de Partie', to: 'Sous Chef', years: '2–3 yrs',
                    tip: 'Performance + kitchen leadership' },
                { from: 'Sous Chef', to: 'Head Chef', years: '3–5 yrs',
                    tip: 'Menu creation + team management' },
                { from: 'Head Chef', to: 'Executive Chef', years: '5–8 yrs',
                    tip: 'Business acumen + reputation' },
            ],

            // ── Salary Data (USD equivalent per country per level) ──────────────────
            levelUSD: {
                US: [32000, 48000, 55000, 72000, 95000],
                UK: [28000, 42000, 48000, 65000, 88000],
                AU: [33000, 45000, 50000, 68000, 90000],
                DE: [26000, 38000, 42000, 58000, 78000],
                JP: [25000, 35000, 40000, 55000, 73000],
                SG: [22000, 36000, 41000, 58000, 78000],
                TW: [13000, 18000, 20000, 28000, 37000],
                CN: [8000, 12000, 14000, 20000, 30000],
            },

            // ── Salary Data (Local currency display per country per level) ──────────
            levelLocal: {
                US: ['$32K', '$48K', '$55K', '$72K', '$95K'],
                UK: ['£22K', '£32K', '£37K', '£50K', '£68K'],
                AU: ['A$45K', 'A$62K', 'A$70K', 'A$95K', 'A$125K'],
                DE: ['€24K', '€35K', '€39K', '€54K', '€72K'],
                JP: ['¥3.2M', '¥4.5M', '¥5.1M', '¥7.0M', '¥9.3M'],
                SG: ['S$30K', 'S$48K', 'S$55K', 'S$78K', 'S$105K'],
                TW: ['NT$380K', 'NT$520K', 'NT$580K', 'NT$820K', 'NT$1.1M'],
                CN: ['¥50K', '¥72K', '¥85K', '¥120K', '¥180K'],
            },

            // ── Language Requirements per Country ──────────────────────────────────
            languages: {
                US: [{ lang: 'English', level: 'Essential', score: 5 }, { lang: 'Spanish', level: 'Helpful',
                    score: 2 }],
                UK: [{ lang: 'English', level: 'Essential', score: 5 }],
                AU: [{ lang: 'English', level: 'Essential', score: 5 }],
                DE: [{ lang: 'German', level: 'Essential', score: 5 }, { lang: 'English', level: 'Helpful',
                    score: 2 }],
                JP: [{ lang: 'Japanese', level: 'Essential', score: 5 }, { lang: 'English',
                    level: 'Senior Only', score: 3 }],
                SG: [{ lang: 'English', level: 'Essential', score: 5 }, { lang: 'Mandarin', level: 'Helpful',
                    score: 2 }, { lang: 'Malay', level: 'Optional', score: 1 }],
                TW: [{ lang: 'Mandarin', level: 'Essential', score: 5 }, { lang: 'Taiwanese',
                    level: 'Helpful', score: 2 }, { lang: 'English', level: 'Senior Only', score: 3 }],
                CN: [{ lang: 'Mandarin', level: 'Essential', score: 5 }, { lang: 'Dialect', level: 'Regional',
                    score: 2 }, { lang: 'English', level: 'High-end Only', score: 3 }],
            },

            // ── Language Score Descriptions ────────────────────────────────────────
            langScoreLabels: { 1: 'Elementary', 2: 'Limited Working', 3: 'Professional Working',
                4: 'Full Professional', 5: 'Native / Bilingual' },

            // ── City Data (salary in local-currency-equivalent USD, cost index) ─────
            cities: {
                US: [
                    { city: 'San Francisco', region: 'West', salary: 72000, cost: 105 },
                    { city: 'New York', region: 'Northeast', salary: 68000, cost: 103 },
                    { city: 'Boston', region: 'Northeast', salary: 64000, cost: 90 },
                    { city: 'Seattle', region: 'West', salary: 62000, cost: 88 },
                    { city: 'Los Angeles', region: 'West', salary: 65000, cost: 95 },
                    { city: 'Chicago', region: 'Midwest', salary: 58000, cost: 80 },
                    { city: 'Denver', region: 'Mountain', salary: 55000, cost: 78 },
                    { city: 'Miami', region: 'South', salary: 52000, cost: 75 },
                    { city: 'Dallas', region: 'South', salary: 50000, cost: 65 },
                    { city: 'Phoenix', region: 'Southwest', salary: 48000, cost: 60 },
                ],
                UK: [
                    { city: 'London', region: 'England', salary: 55000, cost: 100 },
                    { city: 'Edinburgh', region: 'Scotland', salary: 44000, cost: 75 },
                    { city: 'Bristol', region: 'England', salary: 43000, cost: 73 },
                    { city: 'Manchester', region: 'England', salary: 42000, cost: 72 },
                    { city: 'Birmingham', region: 'England', salary: 40000, cost: 70 },
                    { city: 'Leeds', region: 'England', salary: 39000, cost: 68 },
                ],
                AU: [
                    { city: 'Sydney', region: 'NSW', salary: 88000, cost: 100 },
                    { city: 'Melbourne', region: 'VIC', salary: 82000, cost: 92 },
                    { city: 'Canberra', region: 'ACT', salary: 80000, cost: 85 },
                    { city: 'Perth', region: 'WA', salary: 78000, cost: 82 },
                    { city: 'Brisbane', region: 'QLD', salary: 75000, cost: 80 },
                    { city: 'Gold Coast', region: 'QLD', salary: 70000, cost: 75 },
                    { city: 'Adelaide', region: 'SA', salary: 68000, cost: 72 },
                ],
                DE: [
                    { city: 'Munich', region: 'Bavaria', salary: 72000, cost: 100 },
                    { city: 'Frankfurt', region: 'Hesse', salary: 68000, cost: 95 },
                    { city: 'Stuttgart', region: 'Baden-W.', salary: 66000, cost: 88 },
                    { city: 'Hamburg', region: 'Hamburg', salary: 65000, cost: 88 },
                    { city: 'Düsseldorf', region: 'NRW', salary: 60000, cost: 82 },
                    { city: 'Berlin', region: 'Berlin', salary: 60000, cost: 80 },
                    { city: 'Cologne', region: 'NRW', salary: 58000, cost: 78 },
                ],
                JP: [
                    { city: 'Tokyo', region: 'Kanto', salary: 68000, cost: 100 },
                    { city: 'Yokohama', region: 'Kanto', salary: 62000, cost: 90 },
                    { city: 'Osaka', region: 'Kansai', salary: 58000, cost: 85 },
                    { city: 'Kyoto', region: 'Kansai', salary: 55000, cost: 82 },
                    { city: 'Nagoya', region: 'Chubu', salary: 52000, cost: 75 },
                    { city: 'Fukuoka', region: 'Kyushu', salary: 47000, cost: 70 },
                    { city: 'Sapporo', region: 'Hokkaido', salary: 45000, cost: 68 },
                ],
                SG: [
                    { city: 'Orchard', region: 'Central', salary: 82000, cost: 103 },
                    { city: 'CBD / Marina', region: 'Central', salary: 80000, cost: 100 },
                    { city: 'Tampines', region: 'East', salary: 64000, cost: 80 },
                    { city: 'Jurong', region: 'West', salary: 62000, cost: 78 },
                    { city: 'Woodlands', region: 'North', salary: 60000, cost: 72 },
                ],
                TW: [
                    { city: 'Taipei', region: 'Northern', salary: 30000, cost: 100 },
                    { city: 'Hsinchu', region: 'Northern', salary: 28000, cost: 82 },
                    { city: 'New Taipei', region: 'Northern', salary: 27000, cost: 88 },
                    { city: 'Taichung', region: 'Central', salary: 24000, cost: 72 },
                    { city: 'Kaohsiung', region: 'Southern', salary: 23000, cost: 68 },
                    { city: 'Tainan', region: 'Southern', salary: 22000, cost: 65 },
                    { city: 'Taitung', region: 'Eastern', salary: 18000, cost: 55 },
                    { city: 'Hualien', region: 'Eastern', salary: 17000, cost: 52 },
                ],
                CN: [
                    { city: 'Shanghai', region: 'East', salary: 30000, cost: 105 },
                    { city: 'Beijing', region: 'North', salary: 28000, cost: 100 },
                    { city: 'Shenzhen', region: 'South', salary: 28000, cost: 98 },
                    { city: 'Guangzhou', region: 'South', salary: 24000, cost: 85 },
                    { city: 'Chengdu', region: 'Southwest', salary: 18000, cost: 65 },
                    { city: 'Chongqing', region: 'Southwest', salary: 17000, cost: 60 },
                    { city: 'Wuhan', region: 'Central', salary: 16000, cost: 58 },
                    { city: "Xi'an", region: 'Northwest', salary: 14000, cost: 52 },
                ],
            },

            // ── Country Metadata ───────────────────────────────────────────────────
            countryMeta: {
                US: { difficulty: 8, restDays: 10, hoursPerDay: 10.5, splitShift: true,
                    bestLearnAge: '17–22', bestEntryAge: '19–25',
                    cert: 'ServSafe · CIA Degree Optional', travel: 'Low', mobility: 'High',
                    expression: 'High' },
                UK: { difficulty: 8, restDays: 15, hoursPerDay: 10, splitShift: true,
                    bestLearnAge: '16–21', bestEntryAge: '18–24',
                    cert: 'Level 2/3 Food Safety · NVQ', travel: 'Low', mobility: 'High',
                    expression: 'High' },
                AU: { difficulty: 7, restDays: 20, hoursPerDay: 9.5, splitShift: false,
                    bestLearnAge: '17–22', bestEntryAge: '19–25',
                    cert: 'SITXFSA006 · Certificate III Hospitality', travel: 'Low', mobility: 'High',
                    expression: 'High' },
                DE: { difficulty: 7, restDays: 25, hoursPerDay: 9, splitShift: false,
                    bestLearnAge: '16–20', bestEntryAge: '18–23',
                    cert: 'Ausbildung Koch (3 yrs IHK apprentice)', travel: 'Low', mobility: 'High',
                    expression: 'Moderate' },
                JP: { difficulty: 9, restDays: 8, hoursPerDay: 11, splitShift: true,
                    bestLearnAge: '18–23', bestEntryAge: '20–26',
                cert: '調理師免許 (National Cook License)', travel: 'Very Low', mobility: 'Extreme',
                    expression: 'Moderate' },
                SG: { difficulty: 8, restDays: 14, hoursPerDay: 10.5, splitShift: true,
                    bestLearnAge: '17–22', bestEntryAge: '19–25',
                    cert: 'WSQ Food Safety · ITE Pastry/Culinary', travel: 'Low', mobility: 'High',
                    expression: 'High' },
                TW: { difficulty: 8, restDays: 12, hoursPerDay: 10, splitShift: true,
                    bestLearnAge: '17–22', bestEntryAge: '19–25',
                cert: '廚師證照 Level 1–3 · 餐飲管理學位', travel: 'Low', mobility: 'High',
                    expression: 'Moderate' },
                CN: { difficulty: 9, restDays: 7, hoursPerDay: 11.5, splitShift: true,
                    bestLearnAge: '16–21', bestEntryAge: '18–24',
                cert: '中式烹飪師 (初/中/高級) · 廚師職業資格証', travel: 'Low', mobility: 'High',
                    expression: 'High' },
            },

            // ── Difficulty Level Labels ────────────────────────────────────────────
            difficultyLabels: ['', '', 'Very Easy', 'Easy', 'Below Avg', 'Average', 'Above Avg', 'Hard',
                'Very Hard', 'Brutal', 'Extreme'
            ],

            // ── Extended Meta per Country ──────────────────────────────────────────
            extendedMeta: {
                US: { budget: '$450/mo', hnwi: 'Private Clubs · Resort Dining · Estate Chef Ladder',
                    startup: '68% readiness', mbti: 'ESTP · ISTJ · ENTJ', uni: 'Not required',
                    uniMeta: 'Prestige helps less than Michelin-grade references and consistency under service pressure.',
                    privateSchool: 'Useful but debt-sensitive',
                    privateMeta: 'Private culinary school helps with network and polish, but line experience still wins in many kitchens.',
                    schools: 'CIA · Johnson & Wales · Kendall',
                    retire: 'Best Later-Career Exits: corporate Dining Leadership, Instructor Roles, private Chef Work, Product R&D.',
                pivot: 'Best Pivot Set: Estate Chef, Kitchen Ops Consultant, Content/Demo Chef.' },
                UK: { budget: '£260/mo', hnwi: 'Hotels · Members Clubs · Private Events',
                    startup: '54% readiness', mbti: 'ISTJ · ESTJ · ENTJ', uni: 'Optional',
                    uniMeta: 'Hospitality pedigree matters in some London groups, but references and practical output dominate.',
                    privateSchool: 'Helpful for placement',
                    privateMeta: 'Private schools can speed early placement, but apprenticeship kitchens still carry more weight long term.',
                    schools: 'Westminster Kingsway · Le Cordon Bleu London · University College Birmingham',
                    retire: 'Best Later-Career Exits: Hotel Training, F&B Management, Consultancy, premium Catering.',
                pivot: 'Best Pivot Set: Members-Club Chef, Luxury Catering Lead, Compliance Trainer.' },
                AU: { budget: 'A$420/mo', hnwi: 'Resorts · Wine Regions · Premium Tourism',
                    startup: '72% readiness', mbti: 'ESTP · ENTJ · ISTJ', uni: 'Optional',
                    uniMeta: 'TAFE and real kitchen output usually matter more than elite university branding.',
                    privateSchool: 'Often practical',
                    privateMeta: 'Private programs can be useful when tied to placement, but should not replace live service volume.',
                    schools: 'Le Cordon Bleu Melbourne · William Angliss · TAFE NSW Hospitality',
                    retire: 'Best Later-Career Exits: Catering Operator, Venue Manager, Hospitality Trainer, Food Business Owner.',
                pivot: 'Best Pivot Set: private Dining Operator, Venue Consultant, regional culinary Trainer.' },
                DE: { budget: '€220/mo', hnwi: 'Luxury Hotels · Old-money Dining · Cruise / Resort Paths',
                    startup: '49% readiness', mbti: 'ISTJ · INTJ · ESTJ', uni: 'Usually not required',
                    uniMeta: 'Formal training structure matters more than prestige university signaling.',
                    privateSchool: 'Apprenticeship usually stronger',
                    privateMeta: 'The apprenticeship route is often more trusted than expensive private alternatives.',
                    schools: 'Culinary schools tied to IHK tracks · Hotelfachschule Heidelberg · DHBW hospitality routes',
                    retire: 'Best Later-Career Exits: Training Kitchens, Hotel Operations, Procurement and Food Safety Roles.',
                pivot: 'Best Pivot Set: Food Safety Lead, Hotel Trainer, Procurement Specialist.' },
                JP: { budget: '¥45,000/mo',
                    hnwi: 'Omakase · Ryokan · Private Invitation Dining', startup: '46% readiness',
                    mbti: 'ISTJ · INTJ · ISFJ', uni: 'Not required',
                    uniMeta: 'Lineage, discipline, and master-apprentice credibility matter more than elite university names.',
                    privateSchool: 'Can help, lineage stronger',
                    privateMeta: 'School can open doors, but hierarchy and apprenticeship quality remain the stronger signal.',
                    schools: 'Tsuji Culinary Institute · Hattori Nutrition College · Tokyo Seika',
                    retire: 'Best Later-Career Exits: Teaching, Quality Control, Supplier Advisory, Small-Format premium Dining. Includes Potential for parental Retirement Support.',
                pivot: 'Best Pivot Set: Luxury Counter Chef, QA/Standards Lead, Craft Instructor.' },
                SG: { budget: 'S$420/mo', hnwi: 'Luxury Hotels · Expat Clients · Regional Affluent Events',
                    startup: '76% readiness', mbti: 'ENTJ · ESTJ · ESTP', uni: 'Useful but optional',
                    uniMeta: 'Prestige helps in hotel groups, but multilingual polish and operational discipline matter more.',
                    privateSchool: 'Useful if placement-led',
                    privateMeta: 'Private training is most useful when tied to brand-name hotel placement and language advantage.',
                    schools: 'At-Sunrice · SHATEC · Temasek hospitality tracks',
                    retire: 'Best Later-Career Exits: Consulting, regional Training, private Dining, Multi-Outlet Oversight. Includes Potential for parental Retirement Support.',
                pivot: 'Best Pivot Set: Cloud-Kitchen Founder, private Dining Operator, regional Trainer.' },
                TW: { budget: 'NT$8,000/mo',
                    hnwi: 'Private Banquets · Boutique Hospitality · Luxury Clubs', startup: '57% readiness',
                    mbti: 'ISTJ · ESTP · ENTJ', uni: 'Optional',
                    uniMeta: 'Prestige matters less than bilingual service quality and steady kitchen reputation.',
                    privateSchool: 'Selective value',
                    privateMeta: 'Private school can help with early access, but consistent kitchen output remains the strongest signal.',
                    schools: '國立高雄餐旅大學 · 景文科大餐飲系 · 實踐大學 hospitality tracks',
                    retire: 'Best Later-Career Exits: Banquet Operations, culinary Teaching, central Kitchen Roles. Includes Potential for parental Retirement Support.',
                pivot: 'Best Pivot Set: Banquet Lead, Product Testing, Kitchen Standards Consultant.' },
                CN: { budget: '¥1,800/mo',
                    hnwi: 'Luxury Banquets · Private Rooms · Club Kitchens', startup: '61% readiness',
                    mbti: 'ISTJ · ESTP · ENTJ', uni: 'Not required',
                    uniMeta: 'Brand-name university is much less important than apprenticeship pedigree, execution, and network.',
                    privateSchool: 'Mixed value',
                    privateMeta: 'Private culinary schools can speed placement, but live kitchen references usually outrank tuition branding.',
                    schools: 'Le Cordon Bleu Shanghai · SICA · Shanghai Business & Tourism',
                    retire: 'Best Later-Career Exits: Training Manager, central Kitchen Leader, private Chef, culinary Lecturer. Includes Potential for parental Retirement Support.',
                pivot: 'Best Pivot Set: private Household Chef, SOP Consultant, Flavor/Product R&D.' },
            },

            // ── Country Name Lookup ────────────────────────────────────────────────
            countryNames: { US: 'USA', UK: 'United Kingdom', AU: 'Australia', DE: 'Germany', JP: 'Japan',
                SG: 'Singapore', TW: 'Taiwan', CN: 'China' },

            // ── Startup Resource Links per Country ─────────────────────────────────
            startupLinks: {
                US: [{ label: 'SBA Grants', url: 'https://www.sba.gov' }, { label: 'CloudKitchens',
                    url: 'https://cloudkitchens.com' }, { label: 'Restaurant Owner Association',
                    url: 'https://www.restaurantowner.com' }],
                UK: [{ label: 'Gov Business Support', url: 'https://www.gov.uk/business-finance-support' },
                    { label: 'Kitchen United', url: 'https://www.kitchenunited.com' },
                    { label: 'British Hospitality Association', url: 'https://www.ukhospitality.org.uk' }],
                AU: [{ label: 'Business.gov.au', url: 'https://business.gov.au' }, { label: 'FoodStars',
                    url: 'https://foodstars.com.au' }, { label: 'Restaurant & Catering Australia',
                    url: 'https://rca.asn.au' }],
                DE: [{ label: 'KfW Start-ups', url: 'https://www.kfw.de' }, { label: 'KitchenTown Berlin',
                    url: 'https://www.kitchentown.de' }, { label: 'DEHOGA',
                    url: 'https://www.dehoga-bundesverband.de' }],
                JP: [{ label: 'J-Net21', url: 'https://j-net21.smrj.go.jp' }, { label: 'Cloud Kitchen Japan',
                    url: 'https://cloudkitchens.com/jp/' }, { label: 'Japan Foodservice Association',
                    url: 'http://www.jfnet.or.jp' }],
                SG: [{ label: 'Enterprise SG', url: 'https://www.enterprisesg.gov.sg' },
                    { label: 'Smart City Kitchens', url: 'https://smartcitykitchens.com' },
                    { label: 'Restaurant Association of SG', url: 'https://ras.org.sg' }],
                TW: [{ label: 'SMEA Grants', url: 'https://www.smea.gov.tw' }, { label: 'Cloud Kitchen Taiwan',
                    url: 'https://www.cloudkitchens.com.tw' }, { label: 'Taiwan Gourmet Association',
                    url: 'http://www.tga.org.tw' }],
                CN: [{ label: 'China Business Registry', url: 'http://www.gsxt.gov.cn' },
                    { label: 'Meituan Cloud Kitchen', url: 'https://kd.meituan.com' },
                    { label: 'China Hospitality Association', url: 'http://www.chinahotel.org.cn' }],
            },

            // ── Famous Chefs per Country ───────────────────────────────────────────
            famousChefs: {
                US: [{ name: 'Alan Wong', netWorth: '$1.1B' }, { name: 'Wolfgang Puck',
                netWorth: '$120M' }],
                UK: [{ name: 'Gordon Ramsay', netWorth: '$220M' }, { name: 'Jamie Oliver',
                netWorth: '$200M' }],
                AU: [{ name: 'Curtis Stone', netWorth: '$25M' }, { name: 'Neil Perry',
                netWorth: '$25M' }],
                DE: [{ name: 'Tim Mälzer', netWorth: '$10M' }, { name: 'Eckart Witzigmann',
                netWorth: '$5M' }],
                JP: [{ name: 'Nobu Matsuhisa', netWorth: '$200M' }, { name: 'Masaharu Morimoto',
                    netWorth: '$18M' }],
                SG: [{ name: 'Sam Leong', netWorth: '$5M' }, { name: 'Janice Wong', netWorth: '$3M' }],
                TW: [{ name: 'André Chiang', netWorth: '$10M' }, { name: 'Lanshu Chen',
                netWorth: '$5M' }],
                CN: [{ name: 'Da Dong', netWorth: '$50M' }, { name: 'Wang Gang', netWorth: '$2M' }],
            },

            // ── Access Links ───────────────────────────────────────────────────────
            accessLinks: [
                { title: 'Training & Courses',
                    desc: 'Online platforms and culinary schools — Coursera, Rouxbe, Le Cordon Bleu, and local academies' },
                { title: 'Certifications & Credentials',
                    desc: 'Professional credentials: food safety, HACCP, Red Seal, and role-specific licensing paths' },
                { title: 'Job Search & Placement',
                    desc: 'Top hiring channels: LinkedIn, Culinary Agents, hotel career pages, and premium hospitality boards' },
                { title: 'Freelance & Side Work',
                    desc: 'Supplemental income opportunities: banquet staffing, private events, pop-ups, and seasonal resort roles' },
                { title: 'Your Portfolio & Referrals',
                    desc: 'Link to your own portfolio, tasting menu decks, and personal referral network' },
                { title: 'Find a Mentor',
                    desc: 'Connect with a master chef, culinary guide, or senior sifu to grow your craft and expand your network' },
            ],

            // ── Career Recommendations per Level ───────────────────────────────────
            careerRecs: [
                [{ title: 'Kitchen Quality Monitor', match: '76%', color: 'var(--green)',
                    desc: 'Inspect food prep standards, portion accuracy, and safety compliance on the line.',
                    skills: ['Food Safety Awareness', 'Temperature Control'] },
                    { title: 'Catering Production Staff', match: '71%', color: 'var(--yellow)',
                        desc: 'Execute large-batch food production; leverages station discipline and consistency.',
                        skills: ['Station Management', 'Speed & Consistency'] },
                    { title: 'Food Prep Trainer', match: '65%', color: 'var(--orange)',
                        desc: 'Onboard new kitchen staff on safe food handling, basic knife skills, and prep routines.',
                        skills: ['Knife Skills', 'Ingredient Handling'] },
                ],
                [{ title: 'Recipe Testing Technician', match: '83%', color: 'var(--green)',
                    desc: 'Support R&D teams testing and refining dishes; leverages sensory sharpness and station mastery.',
                    skills: ['Sensory Evaluation', 'Mise en Place Mastery'] },
                    { title: 'Catering Supervisor', match: '78%', color: 'var(--yellow)',
                        desc: 'Lead a team for events and large service operations; leverages coordination and quality awareness.',
                        skills: ['Team Coordination', 'Quality Awareness'] },
                    { title: 'Production Kitchen Lead', match: '72%', color: 'var(--orange)',
                        desc: 'Oversee batch production for central kitchens; leverages timing and station leadership.',
                        skills: ['Station Leadership', 'Time Management'] },
                ],
                [{ title: 'Food Technologist (R&D)', match: '88%', color: 'var(--green)',
                    desc: 'Focus on sensory evaluation, recipe scaling, and food chemistry. High growth, lower physical strain.',
                    skills: ['Recipe Development', 'Quality Control'] },
                    { title: 'Event Operations Manager', match: '82%', color: 'var(--yellow)',
                        desc: 'Leverages high-pressure coordination, vendor management, and timing logistics.',
                        skills: ['Staff Supervision', 'Cost Management'] },
                    { title: 'F&B Procurement Analyst', match: '76%', color: 'var(--orange)',
                        desc: 'Utilizes knowledge of ingredient quality, yield management, and supplier networks.',
                        skills: ['Inventory Control', 'Supplier Knowledge'] },
                ],
                [{ title: 'F&B Operations Manager', match: '90%', color: 'var(--green)',
                    desc: 'Oversee multi-venue food and beverage operations; leverages budget, team, and menu mastery.',
                    skills: ['Budget Control', 'Team Management'] },
                    { title: 'Event Operations Manager', match: '85%', color: 'var(--yellow)',
                        desc: 'Leverages crisis management, vendor coordination, and large-scale event logistics.',
                        skills: ['Crisis Management', 'Logistics Planning'] },
                    { title: 'F&B Procurement Specialist', match: '80%', color: 'var(--orange)',
                        desc: 'Utilizes deep knowledge of suppliers, ingredient quality, and yield optimisation.',
                        skills: ['Supply Chain Knowledge', 'Negotiation'] },
                ],
                [{ title: 'F&B Director', match: '93%', color: 'var(--green)',
                    desc: 'Lead entire food and beverage strategy for multi-outlet properties; highest executive transition.',
                    skills: ['Strategic Planning', 'Brand Building'] },
                    { title: 'Food Innovation Consultant', match: '88%', color: 'var(--yellow)',
                        desc: 'Advise food companies on menu trends, product development, and culinary innovation.',
                        skills: ['Culinary Expertise', 'Market Analysis'] },
                    { title: 'Culinary Program Director', match: '82%', color: 'var(--orange)',
                        desc: 'Lead culinary school or corporate training program; leverages expertise depth and leadership.',
                        skills: ['Training Design', 'Leadership'] },
                ],
            ],

            // ── Survival Strategy per Level ────────────────────────────────────────
            survivalStrategy: [
                'As a <strong>Line Cook</strong>, master speed, knife precision, and food safety — skills no robot fully replicates at your pace. Build sensory memory and station reliability to become indispensable.',
                'As a <strong>Chef de Partie</strong>, double down on station mastery and specialty depth. Own a single domain (pastry, sauté, garde manger) so thoroughly that automation cannot displace your judgment.',
                'As a <strong>Sous Chef</strong>, your recipe development and people management are your armor. Invest in costing menus and coaching staff — the operational intelligence AI cannot yet replicate.',
                'As a <strong>Head Chef</strong>, focus on menu creation, brand identity, and team culture. These creative and relational assets are the highest-value nodes least penetrable by AI.',
                'As an <strong>Executive Chef</strong>, your leverage is brand, vision, and business relationships. Transition into consultancy, multi-venue leadership, or content creation to build a career machines cannot replace.',
            ],

            // ── Occupational Hazards ────────────────────────────────────────────────
            hazards: [
                { icon: '🔥', name: 'Burns & Scalds', levelClass: 'haz-5', width: '100%',
                    desc: 'Critical · open flame, hot oil' },
                { icon: '🌡️', name: 'Heat Exhaustion', levelClass: 'haz-5', width: '100%',
                    desc: 'Critical · 38–50°C kitchens' },
                { icon: '🔪', name: 'Cuts & Lacerations', levelClass: 'haz-4', width: '80%',
                    desc: 'High · daily knife work' },
                { icon: '💪', name: 'Musculoskeletal Strain', levelClass: 'haz-4', width: '80%',
                    desc: 'High · 8–12 hrs standing daily' },
                { icon: '🧠', name: 'Mental Fatigue & Stress', levelClass: 'haz-4', width: '75%',
                    desc: 'High · burnout rate 40–60%' },
                { icon: '🚿', name: 'Slip & Fall', levelClass: 'haz-3', width: '55%',
                    desc: 'Medium · wet floor surfaces' },
                { icon: '⚗️', name: 'Chemical Exposure', levelClass: 'haz-3', width: '50%',
                    desc: 'Medium · cleaning agents' },
                { icon: '👂', name: 'Noise Exposure', levelClass: 'haz-2', width: '35%',
                    desc: 'Low-Med · extraction fans' },
                { icon: '🫁', name: 'Smoke & Fumes', levelClass: 'haz-3', width: '45%',
                    desc: 'Medium · inadequate vent. risk' },
            ],

            // ── Task Table Data ────────────────────────────────────────────────────
            tasks: [
                { action: 'Inventory & Ordering', status: 'playable',
                    human: 'Manually count fridge inventory, estimate usage, and call suppliers for orders',
                    ai: 'MarketMan / BlueCart AI predictive analytics for automated ordering', ratio: 85,
                    ratioColor: 'var(--green)', ltvLabel: '~10% at risk', ltvClass: 'risk',
                    eta: '~2 yrs', etaClass: 'eta-soon', statusClass: 'b-play', statusLabel: 'Playable' },
                { action: 'Frying & Grilling', status: 'ingame',
                    human: 'Stand over hot oil, monitor temperature, manually flip and drain food',
                    ai: 'Miso Robotics (Flippy) robotic arm with computer vision for automated flipping',
                    ratio: 65, ratioColor: 'var(--yellow)', ltvLabel: '~30% partial', ltvClass: 'partial',
                    eta: '3–5 yrs', etaClass: 'eta-mid', statusClass: 'b-ing', statusLabel: 'In-Game' },
                { action: 'Recipe Creation', status: 'intro',
                    human: 'Draw on sensory experience and intuition to pair new ingredients',
                    ai: 'Generative AI analyzes molecular flavor profiles and outputs recipes', ratio: 30,
                    ratioColor: 'var(--orange)', ltvLabel: '~20% partial', ltvClass: 'partial',
                    eta: '7–10 yrs', etaClass: 'eta-far', statusClass: 'b-intro', statusLabel: 'Intro' },
                { action: 'Plating & Tasting', status: 'nothing',
                    human: 'Artistically plate dishes, taste for seasoning balance, and fine-tune flavor',
                    ai: 'No viable AI solution yet; sensors cannot fully replicate human subjective taste',
                    ratio: 8, ratioColor: 'var(--red)', ltvLabel: '~40% protected', ltvClass: 'safe',
                    eta: '10+ yrs', etaClass: 'eta-prot', statusClass: 'b-none', statusLabel: 'Nothing' },
            ],

            // ── Filter Pills ───────────────────────────────────────────────────────
            filters: [
                { id: 'all', label: 'All', class: 'all', active: true, dot: false, count: 4 },
                { id: 'playable', label: 'Playable', class: 'gf', active: false, dot: true },
                { id: 'ingame', label: 'In-Game', class: 'yf', active: false, dot: true },
                { id: 'intro', label: 'Intro', class: 'of', active: false, dot: true },
                { id: 'nothing', label: 'Nothing', class: 'rf', active: false, dot: true },
            ],

            // ── MBTI Data ──────────────────────────────────────────────────────────
            mbtiData: [
                { type: 'ESTP',
                    desc: 'The Dynamo. Thrives in fast-paced, high-pressure environments. Excellent at hands-on execution and real-time problem solving on the line.' },
                { type: 'ISTJ',
                    desc: 'The Inspector. Reliable and meticulous. Ensures absolute consistency in recipes and maintains the highest standards of food safety.' },
                { type: 'ENTJ',
                    desc: 'The Commander. Natural leaders who can efficiently manage a complex kitchen brigade and drive the restaurant towards strategic goals.' },
                { type: 'ISFP',
                    desc: 'The Artist. Passionate about culinary aesthetics. Brings creativity and a unique sensory flair to menu development and plating.' },
                { type: 'ESFJ',
                    desc: 'The Provider. Excellent team players who foster a collaborative kitchen culture and ensure guest satisfaction through service excellence.' },
                { type: 'INTJ',
                    desc: 'The Architect. Strategic thinkers who excel at kitchen optimization, cost control, and designing efficient operational systems.' },
            ],

            // ── Filial Piety Countries (show parental retirement note) ──────────────
            filialPietyCountries: ['CN', 'TW', 'SG', 'JP'],

            // ── LTV Methodology Text ────────────────────────────────────────────────
            ltvMethodology: 'BLS 2025 median salary × 30-year career horizon. AI Risk weighted: automation rate per task node × estimated time share. Local reference vehicle used per country.',
            highestThreat: 'Inventory & Ordering is the most vulnerable node (85%), yet accounts for only ~10% of role value. True leverage lies in the sensory execution layer.',

            // ── Language Pill Class Mapping ────────────────────────────────────────
            langPillClasses: { 'Essential': 'llp-essential', 'Helpful': 'llp-helpful', 'Optional': 'llp-optional',
                'Senior Only': 'llp-senior', 'High-end Only': 'llp-senior', 'Regional': 'llp-helpful' },
        };
    </script>

    <!-- ═══════════════════════════════════════════════════════════════════════ -->
    <!-- ░░░░░░  APPLICATION LOGIC — Reads from CHEF_DATA above ░░░░░░░░░░░░░ -->
    <!-- ═══════════════════════════════════════════════════════════════════════ -->
    <script>
        // ── State ──────────────────────────────────────────────────────────────────
        let currentCountry = 'US';
        let currentLevel = 0;
        const D = CHEF_DATA; // shorthand

        // ── Utility ────────────────────────────────────────────────────────────────
        function fmt(n, c) {
            const sym = (D.countries[c] || D.countries.US).symbol || '$';
            return sym + n.toLocaleString('en-US');
        }

        function fmtK(n, c) {
            const sym = (D.countries[c] || D.countries.US).symbol || '$';
            return n >= 1000000 ? sym + (n / 1000000).toFixed(2) + 'M' : fmt(n, c);
        }

        function animNum(el, from, to, prefix = '', suffix = '', duration = 700) {
            const start = performance.now();

            function tick(now) {
                const p = Math.min((now - start) / duration, 1);
                const ease = 1 - Math.pow(1 - p, 3);
                const val = Math.round(from + ease * (to - from));
                el.textContent = prefix + (val >= 1000 ? val.toLocaleString('en-US') : val) + suffix;
                if (p < 1) requestAnimationFrame(tick);
            }
            requestAnimationFrame(tick);
        }

        function calcLTV(c) {
            const ltv = c.annualUSD * c.career;
            const safe = Math.round(ltv * (1 - c.automationIdx / 100));
            const risk = ltv - safe;
            const carCount = Math.round(ltv / c.carPriceUSD);
            const safeCarCount = Math.round(safe / c.carPriceUSD);
            const riskCarCount = carCount - safeCarCount;
            const safeYears = c.riskAge - c.startAge;
            const totalWorkYears = 55 - c.startAge;
            return { ltv, safe, risk, carCount, safeCarCount, riskCarCount, safeYears, totalWorkYears };
        }

        function buildCarGrid(safeCount, riskCount) {
            const grid = document.getElementById('carGrid');
            if (!grid) return;
            const total = safeCount + riskCount;
            grid.innerHTML = '';
            for (let i = 0; i < total; i++) {
                const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
                svg.setAttribute('width', '38');
                svg.setAttribute('height', '22');
                svg.setAttribute('viewBox', '0 0 38 22');
                svg.setAttribute('role', 'img');
                svg.setAttribute('aria-label', i < safeCount ? 'Safe earnings car' : 'At-risk earnings car');
                svg.classList.add('car-icon', i < safeCount ? 'safe-car' : 'risk-car');
                svg.style.opacity = '0';
                svg.style.transform = 'scale(.7)';
                const use = document.createElementNS('http://www.w3.org/2000/svg', 'use');
                use.setAttribute('href', '#car');
                svg.appendChild(use);
                grid.appendChild(svg);
                const delay = i * 28;
                setTimeout(() => {
                    svg.style.transition =
                        `opacity .25s ${delay}ms, transform .3s ${delay}ms`;
                    svg.style.opacity = '';
                    svg.style.transform = '';
                }, 60);
            }
        }

        // ── Render: Country Tabs ──────────────────────────────────────────────────
        function renderCountryTabs() {
            const container = document.getElementById('countryTabs');
            if (!container) return;
            container.innerHTML = Object.entries(D.countries).map(([code, c]) => `
            <button class="ctab${code === currentCountry ? ' active' : ''}" role="tab" data-country="${code}">
              <span class="flag">${c.flag}</span><span class="cname">${c.name}</span><span class="crisk ${c.riskClass}">${c.riskLabel}</span>
            </button>
          `).join('');
        }

        // ── Render: Industry Pills ────────────────────────────────────────────────
        function renderIndustryPills() {
            const row = document.getElementById('industryRow');
            if (!row) return;
            row.innerHTML = D.industries.map(ind => `
            <span class="industry-pill${ind.active ? ' active' : ''}" data-ind="${ind.id}">
              <span class="ind-dot"></span>${ind.label}
            </span>
          `).join('');
        }

        // ── Render: Level Tabs ────────────────────────────────────────────────────
        function renderLevelTabs() {
            const container = document.getElementById('levelTabs');
            if (!container) return;
            const maxSal = D.levelUSD[currentCountry] ? D.levelUSD[currentCountry][D.levels.length - 1] :
                D.levelUSD.US[D.levels.length - 1];
            container.innerHTML = D.levels.map((lvl, i) => {
                const salaries = D.levelUSD[currentCountry] || D.levelUSD.US;
                const pct = Math.round(salaries[i] / maxSal * 100);
                const pctText = i === D.levels.length - 1 ? 'Peak LTV' : pct + '% of peak LTV';
                return `
              <button class="ltab${i === currentLevel ? ' active' : ''}" data-level="${i}" style="--ldot:${lvl.color}">
                <span class="lcolor-dot"></span>${lvl.name}<span class="lyears">${lvl.yearsLabel}</span><span class="lpct">${pctText}</span>
              </button>`;
            }).join('');
        }

        // ── Render: LTV KPI Cards ─────────────────────────────────────────────────
        function renderLTVKpiCards(countryCode, levelIndex, animate = true) {
            const grid = document.getElementById('ltvKpiGrid');
            if (!grid) return;
            const c = D.countries[countryCode] || D.countries.US;
            const salaries = D.levelUSD[countryCode] || D.levelUSD.US;
            const salariesLocal = D.levelLocal[countryCode] || D.levelLocal.US;
            const annualUSD = salaries[levelIndex];
            const careerYrs = c.career;
            const ltv = annualUSD * careerYrs;
            const maxUSD = salaries[D.levels.length - 1];
            const peakLTV = maxUSD * careerYrs;
            const ltvPct = Math.round((ltv / peakLTV) * 100);
            const safe = Math.round(ltv * (1 - c.automationIdx / 100));
            const risk = ltv - safe;
            const lvlName = D.levels[levelIndex].name;
            const d = calcLTV(c);
            const totalSpan = 55 - c.startAge;
            const safeSpan = d.safeYears;
            const riskSpan = totalSpan - safeSpan;

            grid.innerHTML = `
            <div class="ltv-card c-total">
              <div class="ltv-lbl">Career LTV</div>
              <div class="ltv-val cl-total" id="kpi-ltv">${c.symbol}${ltv.toLocaleString('en-US')}</div>
              <div class="ltv-meta" id="kpi-ltv-meta">${careerYrs} yrs · ${salariesLocal[levelIndex]}/yr at ${lvlName}</div>
              <div class="ltv-bar"><div class="ltv-bar-fill" style="width:${ltvPct}%;background:var(--accent)" id="bar-ltv"></div></div>
            </div>
            <div class="ltv-card c-safe">
              <div class="ltv-lbl">Human-Safe LTV</div>
              <div class="ltv-val cl-safe" id="kpi-safe">${c.symbol}${safe.toLocaleString('en-US')}</div>
              <div class="ltv-meta">AI cannot replicate (${100 - c.automationIdx}%)</div>
              <div class="ltv-bar"><div class="ltv-bar-fill" style="width:${100 - c.automationIdx}%;background:var(--green)" id="bar-safe"></div></div>
            </div>
            <div class="ltv-card c-risk">
              <div class="ltv-lbl">At-Risk LTV</div>
              <div class="ltv-val cl-risk" id="kpi-risk">${c.symbol}${risk.toLocaleString('en-US')}</div>
              <div class="ltv-meta">Threatened by AI (${c.automationIdx}%)</div>
              <div class="ltv-bar"><div class="ltv-bar-fill" style="width:${c.automationIdx}%;background:var(--red)" id="bar-risk"></div></div>
            </div>
            <div class="ltv-card c-idx">
              <div class="ltv-lbl">Automation Index</div>
              <div class="ltv-val cl-idx" id="kpi-idx">${c.automationIdx}%</div>
              <div class="ltv-meta">Weighted across task nodes</div>
              <div class="ltv-bar"><div class="ltv-bar-fill" style="width:${c.automationIdx}%;background:var(--yellow)" id="bar-idx"></div></div>
            </div>
            <div class="ltv-card c-age">
              <div class="ltv-lbl">Peak Risk Age</div>
              <div class="ltv-val cl-age" id="kpi-age">${c.riskAge}</div>
              <div class="ltv-meta" id="kpi-age-meta">Safe window: ${c.startAge} → ${c.riskAge} (${safeSpan} yrs)</div>
              <div class="age-timeline">
                <div class="age-seg safe-seg" id="age-safe-seg" style="flex:${safeSpan}"></div>
                <div class="age-seg risk-seg" id="age-risk-seg" style="flex:${riskSpan}"></div>
              </div>
              <div class="age-pins">
                <span class="age-pin">${c.startAge}</span>
                <span class="age-pin risk-pin" id="age-pin-risk">${c.riskAge} ⚠</span>
                <span class="age-pin">55</span>
              </div>
            </div>
          `;
        }

        // ── Render: LTV Breakdown Bar ─────────────────────────────────────────────
        function renderLTVBreakdown(countryCode, levelIndex) {
            const wrap = document.getElementById('ltvBreakdownWrap');
            if (!wrap) return;
            const c = D.countries[countryCode] || D.countries.US;
            const salaries = D.levelUSD[countryCode] || D.levelUSD.US;
            const ltv = salaries[levelIndex] * c.career;
            const safe = Math.round(ltv * (1 - c.automationIdx / 100));
            const risk = ltv - safe;
            const safePct = Math.round((safe / ltv) * 100);
            const riskPct = 100 - safePct;
            wrap.innerHTML = `
            <div class="ltv-chart-title">Career Value Distribution</div>
            <div class="ltv-breakdown">
              <div class="ltv-seg seg-safe" style="width:${safePct}%" id="seg-safe">${fmt(safe, countryCode)} Safe (${safePct}%)</div>
              <div class="ltv-seg seg-risk" style="width:${riskPct}%" id="seg-risk">${fmt(risk, countryCode)} At Risk (${riskPct}%)</div>
            </div>
            <div class="ltv-legend">
              <div class="ltv-legend-item"><div class="ltv-legend-dot" style="background:var(--green)"></div>Human-Safe — physical judgment, creativity, subjective taste</div>
              <div class="ltv-legend-item"><div class="ltv-legend-dot" style="background:var(--red)"></div>At-Risk — existing or emerging AI / robotics coverage</div>
            </div>
          `;
        }

        // ── Render: Car Visualization ─────────────────────────────────────────────
        function renderCarViz(countryCode, levelIndex) {
            const wrap = document.getElementById('carVizWrap');
            if (!wrap) return;
            const c = D.countries[countryCode] || D.countries.US;
            const salaries = D.levelUSD[countryCode] || D.levelUSD.US;
            const ltv = salaries[levelIndex] * c.career;
            const safe = Math.round(ltv * (1 - c.automationIdx / 100));
            const risk = ltv - safe;
            const carCount = Math.round(ltv / c.carPriceUSD);
            const safeCarCount = Math.round(safe / c.carPriceUSD);
            const riskCarCount = carCount - safeCarCount;
            const sgNote = countryCode === 'SG' ? ' *COE-inclusive price applies' : '';
            wrap.innerHTML = `
            <div class="car-viz-header">
              <span class="car-viz-eq">Career LTV Equals</span>
              <span class="car-viz-val"><span id="car-count">${carCount}</span> <span id="car-name" style="color:var(--text-muted)">${c.carName}${carCount === 1 ? '' : 's'}</span></span>
            </div>
            <div class="car-viz-sub" id="car-sub">Based on $${c.carPriceUSD.toLocaleString('en-US')} (USD)/unit reference price${sgNote} · 🟢 Safe earnings · 🔴 At-risk earnings</div>
            <div class="car-grid" id="carGrid" aria-label="Car visualization"></div>
            <div class="car-legend">
              <div class="car-legend-item"><div class="car-legend-swatch safe"></div><span id="car-safe-label">${safeCarCount} cars = Human-Safe LTV (${fmt(safe, countryCode)})</span></div>
              <div class="car-legend-item"><div class="car-legend-swatch risk"></div><span id="car-risk-label">${riskCarCount} cars = At-Risk LTV (${fmt(risk, countryCode)})</span></div>
            </div>
          `;
            buildCarGrid(safeCarCount, riskCarCount);
        }

        // ── Render: Income Chart ──────────────────────────────────────────────────
        function buildIncomePoints(country) {
            const salaries = D.levelUSD[country] || D.levelUSD.US;
            const transitions = D.levels.map(l => l.yearsFrom);
            const pts = [];
            for (let yr = 0; yr <= 30; yr++) {
                let lvl = 0;
                for (let i = transitions.length - 1; i >= 0; i--) { if (yr >= transitions[i]) { lvl =
                        i; break; } }
                const nextTrans = transitions[lvl + 1] || 30;
                const frac = lvl < 4 ? (yr - transitions[lvl]) / (nextTrans - transitions[lvl]) : 1;
                const baseSal = salaries[lvl];
                const nextSal = lvl < 4 ? salaries[lvl + 1] : salaries[4] * 1.15;
                const sal = baseSal + (nextSal - baseSal) * frac * 0.4;
                pts.push({ yr, sal, lvl });
            }
            return pts;
        }

        function renderIncomeChart(country) {
            const wrap = document.getElementById('incomeChartWrap');
            if (!wrap) return;
            const pts = buildIncomePoints(country);
            const TOTAL_YRS = 30;
            const W = 900,
                H = 240,
                padL = 55,
                padR = 30,
                padT = 24,
                padB = 38;
            const cW = W - padL - padR,
                cH = H - padT - padB;
            const maxSal = Math.max(...pts.map(p => p.sal)) * 1.12;
            const minSal = pts[0].sal * 0.75;
            const xOf = yr => padL + (yr / TOTAL_YRS) * cW;
            const yOf = sal => padT + cH - ((sal - minSal) / (maxSal - minSal)) * cH;
            let inner = '';
            for (let g = 0; g <= 4; g++) {
                const y = padT + (g / 4) * cH;
                const val = Math.round(maxSal - (g / 4) * (maxSal - minSal));
                inner +=
                    `<line x1="${padL}" y1="${y}" x2="${W-padR}" y2="${y}" stroke="#222" stroke-width="1"/><text x="${padL-5}" y="${y+4}" text-anchor="end" fill="#555" font-size="10">${val>=1000?'$'+(val/1000).toFixed(0)+'K':val}</text>`;
            }
            [0, 5, 10, 15, 20, 25, 30].forEach(yr => {
                inner +=
                    `<text x="${xOf(yr)}" y="${H-5}" text-anchor="middle" fill="#555" font-size="10">Yr ${yr}</text>`;
            });
            inner +=
                `<line x1="${xOf(30)}" y1="${padT}" x2="${xOf(30)}" y2="${H-padB}" stroke="#555" stroke-width="1.5" stroke-dasharray="4,3"/><text x="${xOf(30)-4}" y="${padT+12}" text-anchor="end" fill="#666" font-size="9" font-weight="600">CAREER END</text>`;
            let d = '';
            pts.forEach((p, i) => { d += (i === 0 ? 'M' : 'L') + xOf(p.yr).toFixed(1) + ',' + yOf(p.sal)
                    .toFixed(1); });
            inner += `<path d="${d}" fill="none" stroke="url(#careerGrad)" stroke-width="2.5"/>`;
            const lvlStart = D.levels[currentLevel].yearsFrom;
            const currentSal = pts.find(p => p.yr === lvlStart)?.sal || (D.levelUSD[country] || D.levelUSD
                .US)[currentLevel];
            const projX1 = xOf(lvlStart),
                projX2 = xOf(30),
                projY = yOf(currentSal);
            inner +=
                `<line x1="${projX1}" y1="${projY}" x2="${projX2}" y2="${projY}" stroke="#ef4444" stroke-width="2" stroke-dasharray="4,3" opacity="0.8"/>`;
            const transYears = [...D.levels.map(l => l.yearsFrom), 30];
            transYears.forEach(yr => {
                const p = pts.find(pp => pp.yr === yr);
                if (!p) return;
                const col = D.levels[p.lvl].color;
                inner +=
                    `<circle cx="${xOf(p.yr)}" cy="${yOf(p.sal)}" r="5" fill="${col}" stroke="#0e0e0e" stroke-width="2"/><line x1="${xOf(p.yr)}" y1="${yOf(p.sal)}" x2="${xOf(p.yr)}" y2="${H-padB+4}" stroke="${col}" stroke-width="1" stroke-dasharray="3,3" opacity="0.35"/>`;
            });
            const lvlColor = D.levels[currentLevel].color;
            const lvlEnd = currentLevel < 4 ? D.levels[currentLevel + 1].yearsFrom : 30;
            const rx1 = xOf(lvlStart),
                rx2 = xOf(lvlEnd);
            const defs =
                `<defs><linearGradient id="careerGrad" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stop-color="#4f98a3"/><stop offset="60%" stop-color="#eab308"/><stop offset="100%" stop-color="#22c55e"/></linearGradient></defs><rect x="${rx1}" y="${padT}" width="${rx2-rx1}" height="${cH}" fill="${lvlColor}" opacity="0.07" rx="2"/>`;
            wrap.innerHTML = `
            <div class="income-chart-header">
              <span class="income-chart-title">Annual Income Curve — Full Career (<span id="chartCountryLabel">${D.countryNames[country]||country}</span>)</span>
              <span class="income-chart-note">Colored dots mark level transitions · hover for value</span>
            </div>
            <svg id="incomeSVG" height="${H}" viewBox="0 0 ${W} ${H}" preserveAspectRatio="none">${defs}${inner}</svg>
            <div class="level-legend">
              ${D.levels.map(l=>`<div class="level-legend-item"><div class="level-legend-dot" style="background:${l.color}"></div>${l.name}</div>`).join('')}
              <div class="level-legend-item" style="margin-left:10px;border-left:1px solid #333;padding-left:10px"><svg width="18" height="8" viewBox="0 0 18 8" style="flex-shrink:0"><line x1="0" y1="4" x2="18" y2="4" stroke="#ef4444" stroke-width="2" stroke-dasharray="4,3"/></svg><span style="color:var(--red)">Current Level → Career End (~Yr 30)</span></div>
            </div>
          `;
        }

        // ── Render: Promotion Flow ────────────────────────────────────────────────
        function renderPromoFlow(country) {
            const wrap = document.getElementById('promoSectionWrap');
            if (!wrap) return;
            const salaries = D.levelLocal[country] || D.levelLocal.US;
            let html =
                '<div class="section-label" style="margin-bottom:16px">Typical Promotion Timeline — Years in Role Before Advancement</div><div class="promo-flow">';
            D.levels.forEach((lvl, i) => {
                const isActive = i === currentLevel;
                html += `
              <div class="promo-node">
                <div class="promo-circle" style="border-color:${lvl.color};background:${isActive?lvl.color+'22':'transparent'};color:${lvl.color}">
                  <span style="font-size:9px;text-align:center;padding:2px">${lvl.short}</span>
                </div>
                <div class="promo-label" style="color:${isActive?lvl.color:'var(--text-muted)'}">${lvl.name}</div>
                <div class="promo-salary" style="color:${isActive?'#fff':'var(--text-faint)'}">${salaries[i]}</div>
              </div>`;
                if (i < D.levels.length - 1) {
                    const tr = D.promotions[i];
                    html += `
                <div class="promo-arrow">
                  <div class="promo-arrow-line"></div>
                  <div class="promo-arrow-years">${tr.years}</div>
                  <div class="promo-arrow-sub">${tr.tip}</div>
                </div>`;
                }
            });
            html += '</div>';
            wrap.innerHTML = html;
        }

        // ── Render: Career Insights ────────────────────────────────────────────────
        function renderInsights(country) {
            const grid = document.getElementById('insightsGrid');
            if (!grid) return;
            const m = D.countryMeta[country] || D.countryMeta.US;
            const difLabel = D.difficultyLabels[m.difficulty] || 'Hard';
            const difPips = Array.from({ length: 10 }, (_, i) => {
                let cls = 'diff-pip';
                if (i < m.difficulty) {
                    if (m.difficulty <= 3) cls += ' filled-low';
                    else if (m.difficulty <= 6) cls += ' filled-mid';
                    else if (m.difficulty <= 8) cls += ' filled-high';
                    else cls += ' filled-max';
                }
                return `<div class="${cls}"></div>`;
            }).join('');
            grid.innerHTML = `
            <div class="insight-card"><span class="insight-icon">💪</span><div class="insight-label">Job Hardship</div><div class="insight-value" style="color:var(--orange)">${m.difficulty}/10</div><div class="insight-meta">${difLabel} · physically &amp; mentally demanding</div><div class="difficulty-bar">${difPips}</div></div>
            <div class="insight-card"><span class="insight-icon">🏖️</span><div class="insight-label">Annual Leave</div><div class="insight-value" style="color:var(--accent)">${m.restDays} days</div><div class="insight-meta">${m.hoursPerDay}h avg work day · ${m.splitShift?'Split shifts common':'Continuous shifts'}</div></div>
            <div class="insight-card"><span class="insight-icon">🎓</span><div class="insight-label">Best Learning Age</div><div class="insight-value" style="color:var(--yellow)">${m.bestLearnAge}</div><div class="insight-meta">Culinary school or apprenticeship entry window</div></div>
            <div class="insight-card"><span class="insight-icon">🚀</span><div class="insight-label">Best Entry Age</div><div class="insight-value" style="color:var(--green)">${m.bestEntryAge}</div><div class="insight-meta">Peak energy &amp; fastest skill absorption period</div></div>
            <div class="insight-card"><span class="insight-icon">✈️</span><div class="insight-label">Business Travel</div><div class="insight-value" style="color:var(--accent)">${m.travel}</div><div class="insight-meta">Frequency of travel for events, sourcing, or multi-site management.</div></div>
            <div class="insight-card"><span class="insight-icon">🏃</span><div class="insight-label">Physical Mobility</div><div class="insight-value" style="color:var(--orange)">${m.mobility}</div><div class="insight-meta">Level of constant movement, standing, and station transitions.</div></div>
            <div class="insight-card"><span class="insight-icon">🗣️</span><div class="insight-label">Creative Self-Expression</div><div class="insight-value" style="color:var(--yellow)">${m.expression}</div><div class="insight-meta">Requirement to communicate vision, lead teams, and express creativity.</div></div>
            <div class="insight-card" style="grid-column:span 2"><span class="insight-icon">📜</span><div class="insight-label">Certifications Required</div><div class="insight-value" style="font-size:13px;color:var(--text)">${m.cert}</div><div class="insight-meta">Varies by employer tier &amp; establishment type</div></div>
          `;
        }

        // ── Render: Language Section ───────────────────────────────────────────────
        function renderLang(country) {
            const section = document.getElementById('langSection');
            if (!section) return;
            const langs = D.languages[country] || [];
            const pillClass = D.langPillClasses;
            section.innerHTML = `
            <div class="section-label" style="margin-bottom:12px">Language Requirements — <span>${D.countryNames[country]||country}</span></div>
            <div class="lang-list">${langs.map(l=>`
              <div class="lang-row">
                <div class="lang-name">${l.lang}</div>
                <span class="lang-level-pill ${pillClass[l.level]||'llp-optional'}">${l.level}</span>
                <div class="lang-bar-wrap"><div class="lang-bar-track"><div class="lang-bar-fill" style="width:${l.score*20}%"></div></div></div>
                <div style="font-size:10px;color:var(--text-faint);min-width:120px">${D.langScoreLabels[l.score]||l.score+'/5'}</div>
              </div>`).join('')}
            </div>`;
        }

        // ── Render: City Heatmap ──────────────────────────────────────────────────
        function renderHeatmap(country) {
            const section = document.getElementById('heatmapSection');
            if (!section) return;
            const cities = D.cities[country] || [];
            if (!cities.length) { section.innerHTML =
                    '<div style="font-size:12px;color:var(--text-faint);padding:18px">No city data available</div>';
                return; }
            const sorted = [...cities].sort((a, b) => b.salary - a.salary);
            const maxS = sorted[0].salary,
                minS = sorted[sorted.length - 1].salary;
            const cards = sorted.map(c => {
                const pct = (c.salary - minS) / (maxS - minS || 1);
                let bg;
                if (pct < 0.5) { const t = pct * 2;
                    bg =
                    `rgba(${Math.round(239+(234-239)*t)},${Math.round(68+(179-68)*t)},${Math.round(68+(8-68)*t)},0.25)`; } else { const
                        t = (pct - 0.5) * 2;
                    bg =
                    `rgba(${Math.round(234+(34-234)*t)},${Math.round(179+(197-179)*t)},${Math.round(8+(94-8)*t)},0.25)`; }
                const brd = pct < 0.33 ? 'var(--red)' : pct < 0.66 ? 'var(--yellow)' : 'var(--green)';
                const salK = c.salary >= 1000 ? (c.salary / 1000).toFixed(0) + 'K' : c.salary;
                return `<div class="city-card" style="background:${bg};border:1px solid ${brd}"><div class="city-name">${c.city}</div><div class="city-region">${c.region}</div><div class="city-salary">$${salK}</div><div class="city-cost">Cost Index: ${c.cost}</div></div>`;
            }).join('');
            section.innerHTML = `
            <div class="heatmap-header"><span class="section-label" style="margin-bottom:0">City Income Heatmap — <span>${D.countryNames[country]||country}</span></span><span style="font-size:10px;color:var(--text-faint)">Avg. cook salary (local equiv. USD) · <span style="color:var(--text-muted)">cost index</span></span></div>
            <div class="heatmap-grid">${cards}</div>
            <div class="heatmap-scale"><div class="heatmap-scale-bar"><div class="hs-low"></div><div class="hs-mid"></div><div class="hs-high"></div></div><span style="font-size:9px;color:var(--text-faint)">Low → High income</span></div>`;
        }

        // ── Render: Hazards ────────────────────────────────────────────────────────
        function renderHazards() {
            const section = document.getElementById('hazardsSection');
            if (!section) return;
            section.innerHTML = `
            <div class="section-label">Occupational Hazards</div>
            <div class="hazards-grid">
              ${D.hazards.map(h=>`
                <div class="hazard-card"><span class="hazard-icon">${h.icon}</span><div class="hazard-info"><div class="hazard-name">${h.name}</div><div class="hazard-bar-track"><div class="hazard-bar-fill ${h.levelClass}" style="width:${h.width}"></div></div><div class="hazard-level">${h.desc}</div></div></div>
              `).join('')}
            </div>`;
        }

        // ── Render: Extended Insights ──────────────────────────────────────────────
        function renderExtraInsights(country) {
            const section = document.getElementById('extraInsightsSection');
            if (!section) return;
            const meta = D.extendedMeta[country] || D.extendedMeta.US;
            const links = D.startupLinks[country] || [];
            const linksHtml = links.map(l =>
                `<a href="${l.url}" target="_blank" style="color:var(--accent);text-decoration:none;font-size:10px;display:block;margin-top:4px">→ ${l.label}</a>`
                ).join('');
            const baseStartup = parseInt(meta.startup);
            const multipliers = [0, 5, 15, 25, 40];
            const dynamicStartup = Math.min(95, baseStartup + multipliers[currentLevel]);
            const startupColor = dynamicStartup >= 70 ? 'var(--green)' : dynamicStartup >= 40 ? 'var(--yellow)' :
                'var(--red)';
            section.innerHTML = `
            <div class="section-label">Career Economics and Fit</div>
            <div class="extended-grid">
              <div class="insight-card"><span class="insight-icon">💸</span><div class="insight-label">Relationship Budget</div><div class="insight-value" style="color:var(--accent)">${meta.budget}</div><div class="insight-meta">Approximate monthly social / dating spend that usually stays manageable at this path level.</div></div>
              <div class="insight-card"><span class="insight-icon">🧑‍💼</span><div class="insight-label">High-Net-Worth Individual (HNWI) Client Access</div><div class="insight-value" style="font-size:13px;color:var(--text)">${meta.hnwi}</div><div class="insight-meta">Best environments for reaching high-net-worth diners and private clients.</div></div>
              <div class="insight-card" id="startupCard" style="cursor:pointer"><span class="insight-icon">🚀</span><div class="insight-label">Startup Readiness</div><div class="insight-value" style="color:${startupColor}">${dynamicStartup}% readiness</div><div class="insight-meta">How naturally this market supports private dining, cloud kitchen, or consulting pivots.</div><div id="startupLinks" style="display:block;margin-top:8px;border-top:1px solid var(--border);padding-top:8px">${linksHtml}</div><div id="startupToggle" style="font-size:9px;color:var(--accent);margin-top:8px;text-decoration:underline">Click to hide resources</div></div>
            </div>`;
            document.getElementById('startupCard')?.addEventListener('click', function() {
                const l = document.getElementById('startupLinks');
                const t = document.getElementById('startupToggle');
                if (l && t) {
                    if (l.style.display === 'none') { l.style.display = 'block';
                        t.textContent = 'Click to hide resources'; } else { l.style.display = 'none';
                        t.textContent = 'Click to view local resources'; }
                }
            });
        }

        // ── Render: Access Links ──────────────────────────────────────────────────
        function renderAccessLinks() {
            const section = document.getElementById('accessSection');
            if (!section) return;
            section.innerHTML = `
            <div class="section-label">Pathways &amp; Access Points</div>
            <div class="link-grid-extended">
              ${D.accessLinks.map(item=>`<div class="link-card"><div class="link-card-title">${item.title}</div><div class="link-card-desc">${item.desc}</div></div>`).join('')}
            </div>`;
        }

        // ── Render: Career Notes (Education, Retirement, MBTI) ────────────────────
        function renderCareerNotes(country) {
            const section = document.getElementById('careerNotesSection');
            if (!section) return;
            const meta = D.extendedMeta[country] || D.extendedMeta.US;
            const randomMBTI = D.mbtiData[Math.floor(Math.random() * D.mbtiData.length)];
            let retireMetaText =
                "Your late-career exit options and personal retirement outlook.";
            if (D.filialPietyCountries.includes(country)) {
                retireMetaText +=
                    " Includes financial and strategic planning for parental care.";
            } else { retireMetaText +=
                    " Parental support potential is shown where culturally applicable."; }
            section.innerHTML = `
            <div class="section-label">Education, Retirement &amp; Career Pivots</div>
            <div class="note-grid">
              <div class="note-card"><div class="note-title">MBTI fit: ${randomMBTI.type}</div><div class="note-value" style="font-size:14px;color:var(--accent)">Highly Compatible</div><div class="note-meta">${randomMBTI.desc}<br><br><div style="background:color-mix(in oklch,var(--accent) 10%,transparent);border:1px dashed var(--accent);padding:8px;border-radius:4px;margin-top:4px"><div style="color:var(--accent);font-weight:700;font-size:11px">Log in to see how your own MBTI type fits this role.</div></div></div></div>
              <div class="note-card"><div class="note-title">Prestige University</div><div class="note-value">${meta.uni}</div><div class="note-meta">${meta.uniMeta}</div></div>
              <div class="note-card"><div class="note-title">Private Schooling Considerations</div><div class="note-value">${meta.privateSchool}</div><div class="note-meta">${meta.privateMeta}<br><br><div style="background:color-mix(in oklch,var(--accent) 10%,transparent);border:1px dashed var(--accent);padding:8px;border-radius:4px;margin-top:4px"><div style="color:var(--accent);font-weight:700;font-size:11px"><strong>Is it worth it for me?</strong> Login for a personalized ROI analysis.<br><strong>Can my income cover my child's tuition?</strong> Estimated by career level.</div></div></div></div>
              <div class="note-card"><div class="note-title">Recommended Schools</div><div class="note-value" style="font-size:13px">${meta.schools}</div><div class="note-meta"><div style="background:color-mix(in oklch,var(--accent) 10%,transparent);border:1px dashed var(--accent);padding:8px;border-radius:4px;margin-top:4px"><div style="color:var(--accent);font-weight:700;font-size:11px">Login for a personalized school match based on your goals — or browse the most recognized programs listed above.</div></div></div></div>
              <div class="note-card"><div class="note-title">Retirement Planning</div><div class="note-value" style="font-size:13px">${meta.retire}</div><div class="note-meta">${retireMetaText}</div></div>
              <div class="note-card"><div class="note-title">Skill Pivot</div><div class="note-value" style="font-size:13px">${meta.pivot}</div><div class="note-meta"><div style="background:color-mix(in oklch,var(--accent) 10%,transparent);border:1px dashed var(--accent);padding:8px;border-radius:4px;margin-top:4px"><div style="color:var(--accent);font-weight:700;font-size:11px">Login to discover roles that better match your skillset and career background.</div></div></div></div>
            </div>`;
        }

        // ── Render: Career Recommendations ────────────────────────────────────────
        function renderCareerRecs(level) {
            const section = document.getElementById('careerRecsSection');
            if (!section) return;
            const recs = D.careerRecs[level] || D.careerRecs[0];
            section.innerHTML = `
            <div class="section-label">Career Recommendations (Based on Skill Set)</div>
            <div class="note-grid">${recs.map(r=>`
              <div class="note-card"><div class="note-title">${r.title}</div><div class="note-value" style="font-size:14px;color:${r.color}">${r.match} Match</div><div class="note-meta">${r.desc}<br><br><strong>Matching Skills:</strong> ${r.skills.join(', ')}.</div></div>
            `).join('')}</div>`;
        }

        // ── Render: Network & Study Section ───────────────────────────────────────
        function renderNetworkSection(country) {
            const section = document.getElementById('networkSection');
            if (!section) return;
            const chefs = D.famousChefs[country] || D.famousChefs.US;
            const chefsHtml = chefs.map(c => `<strong>${c.name}</strong> (${c.netWorth})`).join(', ');
            section.innerHTML = `
            <div class="section-label">Academic & Networking Strategy</div>
            <div class="note-grid">
              <div class="note-card"><div class="note-title">Recommended Majors</div><div class="note-value" style="font-size:14px">Culinary Arts & Hospitality Mgt</div><div class="note-meta">Secondary: Food Science, Nutrition, or Business Administration.</div></div>
              <div class="note-card"><div class="note-title">Target Courses</div><div class="note-value" style="font-size:14px">Kitchen Ops & Cost Control</div><div class="note-meta">Also highly recommended: Molecular Gastronomy, Sustainable Sourcing, and Staff Leadership.</div></div>
              <div class="note-card"><div class="note-title">Stretch Majors</div><div class="note-value" style="font-size:14px">F&B Tech & Innovation</div><div class="note-meta">To beat AI risk, transition into tech-enabled food systems or high-end molecular research.</div></div>
              <div class="note-card"><div class="note-title">Key Connections</div><div class="note-value" style="font-size:14px">Michelin Execs & F&B Directors</div><div class="note-meta"><div style="background:color-mix(in oklch,var(--accent) 10%,transparent);border:1px dashed var(--accent);padding:8px;border-radius:4px;margin-top:4px"><div style="color:var(--accent);font-weight:700;font-size:11px">Login to unlock your personalized key connection plan and step-by-step outreach strategy</div></div></div></div>
              <div class="note-card" style="grid-column:span 2"><div class="note-title">Hall of Fame — ${D.countryNames[country]||country}</div><div class="note-value" style="font-size:14px">${chefsHtml}</div><div class="note-meta">These chefs scaled by leveraging personal brand, media, and multi-venue empires rather than just line cooking.</div></div>
            </div>`;
        }

        // ── Render: Filters + Table ────────────────────────────────────────────────
        function renderFiltersAndTable() {
            const filtersRow = document.getElementById('filtersRow');
            const tableWrap = document.getElementById('tableWrap');
            if (!filtersRow || !tableWrap) return;
            filtersRow.innerHTML = `
            <div class="filters-left" role="group">
              ${D.filters.map(f=>`
                <button class="filter-pill ${f.class}${f.active?' active':''}" data-filter="${f.id}">
                  ${f.dot?'<span class="dot"></span> ':''}${f.label}${f.id==='all'?` <span style="opacity:.5;font-size:10px">${f.count}</span>`:''}
                </button>
              `).join('')}
            </div>
            <div style="font-size:10px;color:var(--text-faint)">v2.2 · Apr 2026</div>`;
            tableWrap.innerHTML = `
            <div class="table-scroll"><table aria-label="Job automation compatibility">
              <thead><tr><th>Action</th><th>Human Workflow</th><th>AI / Bot Workflow</th><th>Replace Ratio</th><th style="text-align:center">Node LTV</th><th style="text-align:center">ETA</th><th style="text-align:center">Status</th></tr></thead>
              <tbody>${D.tasks.map(t=>`
                <tr data-status="${t.status}">
                  <td class="col-action">${t.action}</td>
                  <td class="col-human">${t.human}</td>
                  <td class="col-ai">${t.ai}</td>
                  <td><div class="bar-wrap"><div class="bar-track"><div class="bar-fill" style="width:${t.ratio}%;background:${t.ratioColor}"></div></div><div class="bar-lbl"><span>Automated</span><span>${t.ratio}%</span></div></div></td>
                  <td style="text-align:center"><span class="ltv-chip ${t.ltvClass}">${t.ltvLabel}</span></td>
                  <td style="text-align:center"><span class="eta-badge ${t.etaClass}">${t.eta}</span></td>
                  <td style="text-align:center"><span class="status-badge ${t.statusClass}"><span class="dot"></span>${t.statusLabel}</span></td>
                </tr>`).join('')}
              </tbody>
            </table></div>`;
        }

        // ── Render: Summary ────────────────────────────────────────────────────────
        function renderSummary(level) {
            const row = document.getElementById('summaryRow');
            if (!row) return;
            row.innerHTML = `
            <div class="summary-card" id="survivalStratCard"><strong>Survival Strategy</strong> ${D.survivalStrategy[level]||D.survivalStrategy[0]}</div>
            <div class="summary-card"><strong>Highest Threat</strong>${D.highestThreat}</div>
            <div class="summary-card"><strong>LTV Methodology</strong>${D.ltvMethodology}</div>`;
        }

        // ── Master Render ──────────────────────────────────────────────────────────
        function renderAll(countryCode, levelIndex, animate = true) {
            renderLTVKpiCards(countryCode, levelIndex, animate);
            renderLTVBreakdown(countryCode, levelIndex);
            renderCarViz(countryCode, levelIndex);
            renderIncomeChart(countryCode);
            renderPromoFlow(countryCode);
            renderInsights(countryCode);
            renderLang(countryCode);
            renderHeatmap(countryCode);
            renderExtraInsights(countryCode);
            renderCareerNotes(countryCode);
            renderCareerRecs(levelIndex);
            renderNetworkSection(countryCode);
            renderSummary(levelIndex);
            // Update level tab percentages
            const maxSal = (D.levelUSD[countryCode] || D.levelUSD.US)[D.levels.length - 1];
            D.levels.forEach((_, i) => {
                const el = document.getElementById('lpct-' + i);
                if (!el) return;
                const salaries = D.levelUSD[countryCode] || D.levelUSD.US;
                if (i === D.levels.length - 1) { el.textContent = 'Peak LTV'; return; }
                el.textContent = Math.round(salaries[i] / maxSal * 100) + '% of peak LTV';
            });
            if (animate) {
                const sec = document.querySelector('.ltv-section');
                if (sec) { sec.classList.remove('ltv-fade');
                    void sec.offsetWidth;
                    sec.classList.add('ltv-fade'); }
            }
        }

        // ── Initial Render ─────────────────────────────────────────────────────────
        function initAll() {
            renderIndustryPills();
            renderCountryTabs();
            renderLevelTabs();
            renderHazards();
            renderAccessLinks();
            renderFiltersAndTable();
            renderAll(currentCountry, currentLevel, false);
        }

        // ── Event: Country Tabs ────────────────────────────────────────────────────
        document.getElementById('countryTabs')?.addEventListener('click', e => {
            const tab = e.target.closest('.ctab');
            if (!tab) return;
            document.querySelectorAll('.ctab').forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            currentCountry = tab.dataset.country;
            renderAll(currentCountry, currentLevel, true);
        });

        // ── Event: Level Tabs ──────────────────────────────────────────────────────
        document.getElementById('levelTabs')?.addEventListener('click', e => {
            const tab = e.target.closest('.ltab');
            if (!tab) return;
            document.querySelectorAll('.ltab').forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            currentLevel = parseInt(tab.dataset.level) || 0;
            renderAll(currentCountry, currentLevel, true);
        });

        // ── Event: Filter Pills ────────────────────────────────────────────────────
        document.getElementById('filtersRow')?.addEventListener('click', e => {
            const pill = e.target.closest('.filter-pill');
            if (!pill) return;
            document.querySelectorAll('.filter-pill').forEach(p => p.classList.remove('active'));
            pill.classList.add('active');
            const f = pill.dataset.filter;
            document.querySelectorAll('tbody tr').forEach(r => {
                r.classList.toggle('hidden-row', f !== 'all' && r.dataset.status !== f);
            });
        });

        // ── Event: Industry Pills ──────────────────────────────────────────────────
        document.getElementById('industryRow')?.addEventListener('click', e => {
            const pill = e.target.closest('.industry-pill');
            if (!pill) return;
            document.querySelectorAll('.industry-pill').forEach(p => p.classList.remove('active'));
            pill.classList.add('active');
        });

        // ── Modal ──────────────────────────────────────────────────────────────────
        const overlay = document.getElementById('modalOverlay');
        document.getElementById('openModal')?.addEventListener('click', () => overlay.classList.add('open'));
        document.getElementById('modalClose')?.addEventListener('click', () => overlay.classList.remove('open'));
        overlay?.addEventListener('click', e => { if (e.target === overlay) overlay.classList.remove('open'); });
        document.addEventListener('keydown', e => { if (e.key === 'Escape') overlay.classList.remove('open'); });
        document.querySelectorAll('.modal-tag').forEach(t => t.addEventListener('click', () => t.classList.toggle(
            'sel')));
        document.getElementById('confirmBtn')?.addEventListener('click', () => {
            const email = document.getElementById('emailInput').value.trim();
            if (!email || !email.includes('@')) {
                const inp = document.getElementById('emailInput');
                inp.style.borderColor = 'var(--red)';
                inp.focus();
                setTimeout(() => inp.style.borderColor = '', 1200);
                return;
            }
            document.getElementById('modalForm').style.display = 'none';
            document.getElementById('modalSuccess').style.display = 'block';
            setTimeout(() => overlay.classList.remove('open'), 2200);
            setTimeout(() => {
                document.getElementById('modalForm').style.display = 'block';
                document.getElementById('modalSuccess').style.display = 'none';
                document.getElementById('emailInput').value = '';
            }, 2800);
            const toast = document.getElementById('toast');
            document.getElementById('toastMsg').textContent = 'Subscribed · alerts enabled for Chef role';
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 3200);
        });

        // ── Theme Toggle ────────────────────────────────────────────────────────────
        (function() {
            const btn = document.getElementById('themeToggle');
            const lbl = document.getElementById('themeLabel');
            if (!btn) return;
            let dark = true;
            btn.addEventListener('click', () => {
                dark = !dark;
                if (dark) {
                    document.documentElement.removeAttribute('data-theme');
                    btn.querySelector('.th-icon').textContent = '☀️';
                    lbl.textContent = 'Light';
                } else {
                    document.documentElement.setAttribute('data-theme', 'light');
                    btn.querySelector('.th-icon').textContent = '🌙';
                    lbl.textContent = 'Dark';
                }
            });
        })();

        // ── Kickoff ─────────────────────────────────────────────────────────────────
        initAll();
    </script>
</body>
</html>

EOF

# 【新增】自定义输出文档名（支持txt/md等格式）
OUTPUT_FILE="deepseek回答.md"
# ==============================================================================

# 2. 区域：逻辑处理（无需修改）
# 建议：不要硬编码API_KEY！推荐在终端执行 export API_KEY="你的key" 后运行脚本
API_KEY="${API_KEY:-sk-3b227102823d48d499796908610a3e54}"

if [ -z "$CONTENT" ]; then
    echo "错误：CONTENT 为空，请在脚本的 CONTENT 中输入内容。"
    exit 1
fi

JSON_PAYLOAD=$(jq -n \
  --arg model "deepseek-v4-pro" \
  --arg system "完成要求规定的任务。" \
  --arg user "$CONTENT" \
  '{
    model: $model,
    messages: [
      {role: "system", content: $system},
      {role: "user", content: $user}
    ],
    stream: false
  }')

# 3. 区域：执行请求 + 保存结果到文档
echo "正在请求 DeepSeek API..."
# 核心修改：用 tee 命令 同时输出到终端 + 写入文件
curl -s https://api.deepseek.com/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$JSON_PAYLOAD" | jq -r '.choices[0].message.content' | tee "$OUTPUT_FILE"

# 提示保存成功
echo -e "\n========================================"
echo "✅ 回答已保存到文档：$OUTPUT_FILE"
echo "========================================"