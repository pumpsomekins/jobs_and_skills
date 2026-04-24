I'll generate a complete HTML/CSS document that builds a job-market homepage around the Chef prototype, adding job listings, market news, and search features while preserving the original dark-themed design system.
```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JobForesight — Job Market Intelligence & Automation Tracking</title>
    <link href="https://api.fontshare.com/v2/css?f[]=satoshi@400,500,700,900&f[]=cabinet-grotesk@800&display=swap" rel="stylesheet">
    <style>
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
        *,
        *::before,
        *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0
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
            min-height: 100dvh;
            position: relative;
        }
        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background: repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0, 0, 0, .05) 2px, rgba(0, 0, 0, .05) 4px);
            pointer-events: none;
            z-index: 0;
        }
        button {
            cursor: pointer;
            border: none;
            background: none;
            font: inherit
        }
        a {
            color: inherit;
            text-decoration: none
        }
        img {
            max-width: 100%;
            display: block
        }

        /* ── Layout ── */
        .page-wrap {
            position: relative;
            z-index: 1;
            max-width: 1300px;
            margin: 0 auto;
            padding: 0 24px 80px
        }
        @media(max-width:768px) {
            .page-wrap {
                padding: 0 14px 50px
            }
        }

        /* ── NAVBAR ── */
        .navbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 16px 0;
            border-bottom: 1px solid var(--border);
            margin-bottom: 28px;
            flex-wrap: wrap;
            position: sticky;
            top: 0;
            background: var(--bg);
            z-index: 50;
        }
        .nav-brand {
            font-family: var(--font-display);
            font-size: 20px;
            font-weight: 800;
            color: #fff;
            letter-spacing: -.02em;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .nav-brand-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--accent);
            animation: pulse 2s ease-in-out infinite;
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
        .nav-links {
            display: flex;
            align-items: center;
            gap: 20px;
            flex-wrap: wrap;
        }
        .nav-link {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
            letter-spacing: .03em;
            transition: color .15s;
            white-space: nowrap;
        }
        .nav-link:hover,
        .nav-link.active {
            color: #fff;
        }
        .nav-link.active {
            color: var(--accent);
        }
        .nav-actions {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .btn-sm {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 7px 13px;
            border-radius: var(--radius-md);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: .03em;
            transition: all .18s var(--ease);
            white-space: nowrap;
            border: 1px solid var(--border-hi);
            background: var(--surface);
            color: var(--text-muted);
        }
        .btn-sm:hover {
            border-color: var(--text-faint);
            color: var(--text);
        }
        .btn-sm.accent {
            background: var(--accent);
            color: #fff;
            border-color: transparent;
        }
        .btn-sm.accent:hover {
            background: var(--accent-hover);
            transform: translateY(-1px);
            box-shadow: 0 6px 20px color-mix(in oklch, var(--accent) 30%, transparent);
        }
        .btn-sm.ghost {
            background: transparent;
            border-color: var(--border-hi);
            color: var(--text-muted);
        }
        .btn-sm.ghost:hover {
            border-color: var(--accent);
            color: var(--text);
        }
        @media(max-width:640px) {
            .nav-links {
                gap: 10px;
                font-size: 11px;
            }
            .nav-brand {
                font-size: 16px;
            }
        }

        /* ── HERO ── */
        .hero {
            display: flex;
            align-items: center;
            gap: 40px;
            margin-bottom: 40px;
            padding: 36px 0;
            flex-wrap: wrap;
        }
        .hero-left {
            flex: 1;
            min-width: 280px;
        }
        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--accent);
            background: color-mix(in oklch, var(--accent) 12%, transparent);
            border: 1px solid color-mix(in oklch, var(--accent) 28%, transparent);
            padding: 4px 10px;
            border-radius: 4px;
            margin-bottom: 14px;
        }
        .hero-badge .live-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: var(--accent);
            animation: pulse 2s ease-in-out infinite;
        }
        .hero-title {
            font-family: var(--font-display);
            font-size: clamp(28px, 4.5vw, 46px);
            font-weight: 800;
            color: #fff;
            line-height: 1.08;
            letter-spacing: -.02em;
            margin-bottom: 12px;
        }
        .hero-title span {
            color: var(--accent);
        }
        .hero-sub {
            font-size: 14px;
            color: var(--text-muted);
            max-width: 460px;
            margin-bottom: 22px;
            line-height: 1.6;
        }
        .hero-search {
            display: flex;
            gap: 8px;
            max-width: 500px;
            flex-wrap: wrap;
        }
        .hero-input {
            flex: 1;
            min-width: 200px;
            background: var(--surface-2);
            border: 1px solid var(--border-hi);
            border-radius: var(--radius-md);
            padding: 11px 15px;
            color: var(--text);
            font: inherit;
            font-size: 14px;
            outline: none;
            transition: border-color .18s;
        }
        .hero-input::placeholder {
            color: var(--text-faint);
        }
        .hero-input:focus {
            border-color: var(--accent);
        }
        .hero-right {
            flex: 0 0 320px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        @media(max-width:768px) {
            .hero-right {
                flex: 1 1 100%;
                flex-direction: row;
                flex-wrap: wrap;
            }
        }
        .hero-stat {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 14px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: border-color .2s;
        }
        .hero-stat:hover {
            border-color: var(--border-hi);
        }
        .hero-stat-icon {
            font-size: 24px;
            flex-shrink: 0;
        }
        .hero-stat-val {
            font-family: var(--font-display);
            font-size: 20px;
            font-weight: 800;
            color: #fff;
            line-height: 1;
        }
        .hero-stat-lbl {
            font-size: 10px;
            color: var(--text-muted);
            letter-spacing: .04em;
            text-transform: uppercase;
        }

        /* ── SECTION HEADERS ── */
        .section-header {
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 18px;
            flex-wrap: wrap;
        }
        .section-title {
            font-family: var(--font-display);
            font-size: clamp(18px, 2.5vw, 24px);
            font-weight: 800;
            color: #fff;
            letter-spacing: -.01em;
        }
        .section-link {
            font-size: 12px;
            font-weight: 700;
            color: var(--accent);
            letter-spacing: .04em;
            transition: color .15s;
        }
        .section-link:hover {
            color: var(--accent-hover);
        }
        .sec-divider {
            height: 1px;
            background: var(--border);
            margin: 28px 0;
        }

        /* ── OCCUPATION CARDS GRID ── */
        .occupation-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
            gap: 10px;
            margin-bottom: 32px;
        }
        .occ-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 18px 16px;
            transition: border-color .2s, transform .15s var(--ease), box-shadow .2s;
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }
        .occ-card:hover {
            border-color: var(--border-hi);
            transform: translateY(-2px);
            box-shadow: 0 8px 28px rgba(0, 0, 0, .4);
        }
        .occ-card::after {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(circle at 50% 0%, var(--occ-glow, transparent) 0%, transparent 70%);
            pointer-events: none;
            opacity: .5;
        }
        .occ-icon {
            font-size: 28px;
            margin-bottom: 8px;
            display: block;
        }
        .occ-name {
            font-family: var(--font-display);
            font-size: 16px;
            font-weight: 800;
            color: #fff;
            margin-bottom: 3px;
            letter-spacing: -.01em;
        }
        .occ-salary {
            font-size: 11px;
            color: var(--text-muted);
            margin-bottom: 8px;
        }
        .occ-risk-row {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-bottom: 8px;
        }
        .occ-risk-pill {
            font-size: 9px;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 3px;
            letter-spacing: .04em;
            white-space: nowrap;
        }
        .risk-low {
            background: color-mix(in oklch, var(--green) 14%, transparent);
            color: var(--green);
            border: 1px solid color-mix(in oklch, var(--green) 25%, transparent);
        }
        .risk-mid {
            background: color-mix(in oklch, var(--yellow) 12%, transparent);
            color: var(--yellow);
            border: 1px solid color-mix(in oklch, var(--yellow) 22%, transparent);
        }
        .risk-high {
            background: color-mix(in oklch, var(--red) 12%, transparent);
            color: var(--red);
            border: 1px solid color-mix(in oklch, var(--red) 22%, transparent);
        }
        .occ-bar {
            height: 3px;
            background: var(--border);
            border-radius: 2px;
            overflow: hidden;
        }
        .occ-bar-fill {
            height: 100%;
            border-radius: 2px;
            transition: width 1s var(--ease);
        }
        .occ-badge {
            position: absolute;
            top: 12px;
            right: 12px;
            font-size: 9px;
            font-weight: 700;
            letter-spacing: .06em;
            text-transform: uppercase;
            padding: 3px 7px;
            border-radius: 3px;
            background: var(--surface-3);
            color: var(--text-faint);
            border: 1px solid var(--border-hi);
        }
        .occ-badge.hot {
            background: color-mix(in oklch, var(--orange) 14%, transparent);
            color: var(--orange);
            border-color: color-mix(in oklch, var(--orange) 25%, transparent);
        }

        /* ── NEWS SECTION ── */
        .news-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 14px;
            margin-bottom: 32px;
        }
        @media(max-width:768px) {
            .news-grid {
                grid-template-columns: 1fr;
            }
        }
        .news-featured {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 22px 20px;
            display: flex;
            flex-direction: column;
            gap: 14px;
            transition: border-color .2s;
        }
        .news-featured:hover {
            border-color: var(--border-hi);
        }
        .news-featured-tag {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: var(--accent);
            align-self: flex-start;
        }
        .news-featured-title {
            font-family: var(--font-display);
            font-size: clamp(16px, 2vw, 20px);
            font-weight: 800;
            color: #fff;
            line-height: 1.3;
            letter-spacing: -.01em;
        }
        .news-featured-excerpt {
            font-size: 12px;
            color: var(--text-muted);
            line-height: 1.6;
        }
        .news-featured-meta {
            font-size: 10px;
            color: var(--text-faint);
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }
        .news-side-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .news-side-item {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 13px 15px;
            transition: border-color .2s;
            cursor: pointer;
        }
        .news-side-item:hover {
            border-color: var(--border-hi);
        }
        .news-side-title {
            font-size: 13px;
            font-weight: 700;
            color: #fff;
            margin-bottom: 3px;
            line-height: 1.3;
        }
        .news-side-meta {
            font-size: 10px;
            color: var(--text-faint);
        }

        /* ── JOB LISTINGS TABLE ── */
        .table-wrap {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            overflow: hidden;
            margin-bottom: 32px;
        }
        .table-scroll {
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 700px;
        }
        thead {
            background: var(--surface-2);
        }
        th {
            padding: 10px 14px;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: var(--text-faint);
            border-bottom: 1px solid var(--border);
            white-space: nowrap;
            text-align: left;
        }
        td {
            padding: 12px 14px;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
            font-size: 13px;
        }
        tr:last-child td {
            border-bottom: none;
        }
        tbody tr {
            transition: background .15s var(--ease);
            cursor: pointer;
        }
        tbody tr:hover {
            background: var(--surface-2);
        }
        .job-title-col {
            font-weight: 700;
            color: #fff;
            white-space: nowrap;
        }
        .job-company {
            color: var(--text-muted);
            font-size: 11px;
        }
        .job-location {
            color: var(--text-muted);
            font-size: 12px;
            white-space: nowrap;
        }
        .job-salary-col {
            font-weight: 600;
            color: var(--green);
            white-space: nowrap;
        }
        .job-risk-col {
            text-align: center;
        }
        .job-tag {
            display: inline-block;
            font-size: 9px;
            font-weight: 700;
            padding: 3px 7px;
            border-radius: 3px;
            letter-spacing: .04em;
            white-space: nowrap;
        }
        .job-tag.new {
            background: color-mix(in oklch, var(--green) 14%, transparent);
            color: var(--green);
            border: 1px solid color-mix(in oklch, var(--green) 25%, transparent);
        }
        .job-tag.urgent {
            background: color-mix(in oklch, var(--red) 14%, transparent);
            color: var(--red);
            border: 1px solid color-mix(in oklch, var(--red) 25%, transparent);
        }
        .job-tag.featured {
            background: color-mix(in oklch, var(--accent) 14%, transparent);
            color: var(--accent);
            border: 1px solid color-mix(in oklch, var(--accent) 25%, transparent);
        }

        /* ── MARKET PULSE ── */
        .pulse-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 32px;
        }
        @media(max-width:768px) {
            .pulse-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        @media(max-width:480px) {
            .pulse-grid {
                grid-template-columns: 1fr;
            }
        }
        .pulse-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 16px 18px;
            transition: border-color .2s;
        }
        .pulse-card:hover {
            border-color: var(--border-hi);
        }
        .pulse-label {
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 6px;
        }
        .pulse-value {
            font-family: var(--font-display);
            font-size: clamp(18px, 2.5vw, 26px);
            font-weight: 800;
            color: #fff;
            line-height: 1;
            margin-bottom: 3px;
        }
        .pulse-change {
            font-size: 10px;
            font-weight: 700;
        }
        .pulse-change.up {
            color: var(--green);
        }
        .pulse-change.down {
            color: var(--red);
        }
        .pulse-change.neutral {
            color: var(--yellow);
        }

        /* ── NEWSLETTER CTA ── */
        .cta-banner {
            background: var(--surface);
            border: 1px solid var(--border-hi);
            border-radius: var(--radius-lg);
            padding: 28px 24px;
            text-align: center;
            margin-bottom: 32px;
        }
        .cta-banner-title {
            font-family: var(--font-display);
            font-size: clamp(18px, 2.5vw, 22px);
            font-weight: 800;
            color: #fff;
            margin-bottom: 6px;
            letter-spacing: -.01em;
        }
        .cta-banner-sub {
            font-size: 12px;
            color: var(--text-muted);
            margin-bottom: 16px;
        }
        .cta-input-row {
            display: flex;
            gap: 8px;
            justify-content: center;
            flex-wrap: wrap;
            max-width: 400px;
            margin: 0 auto;
        }
        .cta-input {
            flex: 1;
            min-width: 180px;
            background: var(--surface-2);
            border: 1px solid var(--border-hi);
            border-radius: var(--radius-md);
            padding: 10px 14px;
            color: var(--text);
            font: inherit;
            font-size: 13px;
            outline: none;
        }
        .cta-input:focus {
            border-color: var(--accent);
        }
        .cta-input::placeholder {
            color: var(--text-faint);
        }

        /* ── FOOTER ── */
        .footer {
            border-top: 1px solid var(--border);
            padding-top: 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            flex-wrap: wrap;
            font-size: 11px;
            color: var(--text-faint);
        }
        .footer-links {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
        }
        .footer-links a {
            color: var(--text-faint);
            transition: color .15s;
        }
        .footer-links a:hover {
            color: var(--text-muted);
        }

        /* Toast */
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
            transition: all .28s var(--ease);
            pointer-events: none;
        }
        .toast.show {
            transform: none;
            opacity: 1;
            pointer-events: all;
        }
        .toast-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: var(--green);
            flex-shrink: 0;
            animation: pulse 2s infinite;
        }

        /* ── Theme Toggle ── */
        .theme-toggle {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 12px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-hi);
            background: var(--surface);
            color: var(--text-muted);
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            transition: all .18s var(--ease);
            letter-spacing: .03em;
            white-space: nowrap;
        }
        .theme-toggle:hover {
            border-color: var(--accent);
            color: var(--text);
        }

        /* LIGHT MODE */
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
            color: var(--text);
        }
        html[data-theme="light"] body::before {
            background: repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0, 0, 0, .02) 2px, rgba(0, 0, 0, .02) 4px);
        }
        html[data-theme="light"] .nav-brand,
        html[data-theme="light"] .hero-title,
        html[data-theme="light"] .section-title,
        html[data-theme="light"] .occ-name,
        html[data-theme="light"] .news-featured-title,
        html[data-theme="light"] .news-side-title,
        html[data-theme="light"] .job-title-col,
        html[data-theme="light"] .pulse-value,
        html[data-theme="light"] .cta-banner-title,
        html[data-theme="light"] .hero-stat-val {
            color: #111;
        }
        html[data-theme="light"] .navbar {
            background: var(--bg);
        }
        html[data-theme="light"] thead {
            background: var(--surface-2);
        }
        html[data-theme="light"] tbody tr:hover {
            background: var(--surface-2);
        }
        html[data-theme="light"] .table-wrap {
            background: var(--surface);
        }
    </style>
</head>
<body>

    <!-- Toast -->
    <div class="toast" id="toast">
        <span class="toast-dot"></span>
        <span id="toastMsg">Alert set successfully</span>
    </div>

    <!-- Page Wrap -->
    <div class="page-wrap">

        <!-- ── NAVBAR ── -->
        <nav class="navbar">
            <a href="#" class="nav-brand">
                <span class="nav-brand-dot"></span> JobForesight
            </a>
            <div class="nav-links">
                <a href="#" class="nav-link active">Home</a>
                <a href="#jobs" class="nav-link">Jobs</a>
                <a href="#occupations" class="nav-link">Occupations</a>
                <a href="#news" class="nav-link">News</a>
                <a href="#market" class="nav-link">Market Pulse</a>
                <a href="#" class="nav-link">Chef Tracker</a>
            </div>
            <div class="nav-actions">
                <button class="btn-sm ghost">Upload Resume</button>
                <button class="btn-sm ghost">Login</button>
                <button class="theme-toggle" id="themeToggle" title="Toggle light/dark mode">
                    <span id="themeIcon">☀️</span> <span id="themeLabel">Light</span>
                </button>
                <button class="btn-sm accent" id="subscribeBtn">🔔 Get Alerts</button>
            </div>
        </nav>

        <!-- ── HERO ── -->
        <section class="hero">
            <div class="hero-left">
                <div class="hero-badge"><span class="live-dot"></span> Live Market Data</div>
                <h1 class="hero-title">Find Your <span>AI-Proof</span><br>Career Path</h1>
                <p class="hero-sub">Browse thousands of jobs across 200+ occupations. Track automation risk, salary trends, and market news — all in one place. Make informed career moves before AI reshapes your industry.</p>
                <div class="hero-search">
                    <input class="hero-input" id="heroSearch" type="text" placeholder="Search jobs, occupations, or skills...">
                    <button class="btn-sm accent" id="heroSearchBtn">🔍 Search</button>
                </div>
            </div>
            <div class="hero-right">
                <div class="hero-stat">
                    <span class="hero-stat-icon">📊</span>
                    <div>
                        <div class="hero-stat-val">12,847</div>
                        <div class="hero-stat-lbl">Active Jobs Tracked</div>
                    </div>
                </div>
                <div class="hero-stat">
                    <span class="hero-stat-icon">🤖</span>
                    <div>
                        <div class="hero-stat-val" style="color:var(--yellow)">37%</div>
                        <div class="hero-stat-lbl">Avg Automation Risk</div>
                    </div>
                </div>
                <div class="hero-stat">
                    <span class="hero-stat-icon">💰</span>
                    <div>
                        <div class="hero-stat-val" style="color:var(--green)">$58.4K</div>
                        <div class="hero-stat-lbl">Median Tracked Salary</div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ── OCCUPATION CATEGORIES ── -->
        <section id="occupations">
            <div class="section-header">
                <h2 class="section-title">Top Occupations by Automation Risk</h2>
                <a href="#" class="section-link">View All 200+ →</a>
            </div>
            <div class="occupation-grid" id="occupationGrid">
                <!-- Rendered by JS -->
            </div>
        </section>

        <div class="sec-divider"></div>

        <!-- ── LATEST JOBS ── -->
        <section id="jobs">
            <div class="section-header">
                <h2 class="section-title">Latest Job Listings</h2>
                <a href="#" class="section-link">Browse All Jobs →</a>
            </div>
            <div class="table-wrap">
                <div class="table-scroll">
                    <table aria-label="Latest job listings">
                        <thead>
                            <tr>
                                <th>Job Title</th>
                                <th>Company</th>
                                <th>Location</th>
                                <th>Salary</th>
                                <th style="text-align:center">Auto Risk</th>
                                <th style="text-align:center">Tag</th>
                            </tr>
                        </thead>
                        <tbody id="jobsTableBody">
                            <!-- Rendered by JS -->
                        </tbody>
                    </table>
                </div>
            </div>
        </section>

        <!-- ── NEWS ── -->
        <section id="news">
            <div class="section-header">
                <h2 class="section-title">Job Market News</h2>
                <a href="#" class="section-link">All News →</a>
            </div>
            <div class="news-grid" id="newsGrid">
                <!-- Rendered by JS -->
            </div>
        </section>

        <div class="sec-divider"></div>

        <!-- ── MARKET PULSE ── -->
        <section id="market">
            <div class="section-header">
                <h2 class="section-title">Market Pulse</h2>
                <span style="font-size:10px;color:var(--text-faint);">Updated hourly</span>
            </div>
            <div class="pulse-grid" id="pulseGrid">
                <!-- Rendered by JS -->
            </div>
        </section>

        <!-- ── CTA ── -->
        <div class="cta-banner">
            <div class="cta-banner-title">📬 Stay Ahead of the Job Market</div>
            <p class="cta-banner-sub">Get weekly job market insights, automation risk alerts, and curated job listings delivered to your inbox.</p>
            <div class="cta-input-row">
                <input class="cta-input" id="ctaEmail" type="email" placeholder="your@email.com">
                <button class="btn-sm accent" id="ctaSubscribeBtn">Subscribe Free</button>
            </div>
        </div>

        <!-- ── FOOTER ── -->
        <footer class="footer">
            <span>© 2026 JobForesight · Data from BLS, ILO, and 40+ sources</span>
            <div class="footer-links">
                <a href="#">About</a>
                <a href="#">Privacy</a>
                <a href="#">Terms</a>
                <a href="#">Contact</a>
                <a href="#">Chef Tracker</a>
            </div>
        </footer>
    </div>

    <script>
        // ── OCCUPATION DATA ──────────────────────────────────
        const OCCUPATIONS = [
            { id: 'chef', name: 'Chef / Cook', icon: '👨‍🍳', salary: '$56,000', risk: 37, riskLabel: 'MID', riskClass: 'risk-mid',
                glow: 'color-mix(in oklch,var(--yellow) 15%,transparent)', badge: 'hot', badgeText: 'TRENDING',
                barColor: '#eab308' },
            { id: 'driver', name: 'Truck Driver', icon: '🚛', salary: '$48,000', risk: 72, riskLabel: 'HIGH',
                riskClass: 'risk-high', glow: 'color-mix(in oklch,var(--red) 15%,transparent)', badge: '',
                badgeText: '', barColor: '#ef4444' },
            { id: 'nurse', name: 'Registered Nurse', icon: '🏥', salary: '$82,000', risk: 14, riskLabel: 'LOW',
                riskClass: 'risk-low', glow: 'color-mix(in oklch,var(--green) 12%,transparent)', badge: 'hot',
                badgeText: 'IN DEMAND', barColor: '#22c55e' },
            { id: 'dev', name: 'Software Developer', icon: '💻', salary: '$110,000', risk: 28, riskLabel: 'LOW-MID',
                riskClass: 'risk-low', glow: 'color-mix(in oklch,var(--green) 10%,transparent)',
                badge: '', badgeText: '', barColor: '#22c55e' },
            { id: 'teacher', name: 'Teacher (K-12)', icon: '📚', salary: '$62,000', risk: 12, riskLabel: 'LOW',
                riskClass: 'risk-low', glow: 'color-mix(in oklch,var(--green) 8%,transparent)',
                badge: '', badgeText: '', barColor: '#22c55e' },
            { id: 'cashier', name: 'Retail Cashier', icon: '🛒', salary: '$28,000', risk: 85, riskLabel: 'CRITICAL',
                riskClass: 'risk-high', glow: 'color-mix(in oklch,var(--red) 18%,transparent)', badge: '',
                badgeText: '', barColor: '#ef4444' },
            { id: 'analyst', name: 'Data Analyst', icon: '📈', salary: '$78,000', risk: 42, riskLabel: 'MID',
                riskClass: 'risk-mid', glow: 'color-mix(in oklch,var(--yellow) 12%,transparent)',
                badge: 'hot', badgeText: 'GROWING', barColor: '#eab308' },
            { id: 'electrician', name: 'Electrician', icon: '⚡', salary: '$60,000', risk: 8, riskLabel: 'VERY LOW',
                riskClass: 'risk-low', glow: 'color-mix(in oklch,var(--green) 10%,transparent)',
                badge: '', badgeText: '', barColor: '#22c55e' },
            { id: 'writer', name: 'Content Writer', icon: '✍️', salary: '$52,000', risk: 55, riskLabel: 'MID-HIGH',
                riskClass: 'risk-mid', glow: 'color-mix(in oklch,var(--orange) 14%,transparent)',
                badge: '', badgeText: '', barColor: '#f97316' },
            { id: 'lawyer', name: 'Lawyer', icon: '⚖️', salary: '$135,000', risk: 22, riskLabel: 'LOW',
                riskClass: 'risk-low', glow: 'color-mix(in oklch,var(--green) 10%,transparent)',
                badge: '', badgeText: '', barColor: '#22c55e' },
            { id: 'accountant', name: 'Accountant', icon: '🧮', salary: '$70,000', risk: 48, riskLabel: 'MID',
                riskClass: 'risk-mid', glow: 'color-mix(in oklch,var(--yellow) 12%,transparent)',
                badge: '', badgeText: '', barColor: '#eab308' },
            { id: 'waiter', name: 'Waiter / Server', icon: '🍽️', salary: '$26,000', risk: 60, riskLabel: 'MID-HIGH',
                riskClass: 'risk-mid', glow: 'color-mix(in oklch,var(--orange) 14%,transparent)',
                badge: '', badgeText: '', barColor: '#f97316' },
        ];

        function renderOccupations() {
            const grid = document.getElementById('occupationGrid');
            if (!grid) return;
            grid.innerHTML = OCCUPATIONS.map(o => `
            <div class="occ-card" style="--occ-glow:${o.glow}" data-id="${o.id}" onclick="navigateToOccupation('${o.id}')">
              ${o.badge ? `<span class="occ-badge ${o.badge}">${o.badgeText}</span>` : ''}
              <span class="occ-icon">${o.icon}</span>
              <div class="occ-name">${o.name}</div>
              <div class="occ-salary">Median: ${o.salary}/yr</div>
              <div class="occ-risk-row">
                <span class="occ-risk-pill ${o.riskClass}">${o.riskLabel} · ${o.risk}%</span>
              </div>
              <div class="occ-bar"><div class="occ-bar-fill" style="width:${o.risk}%;background:${o.barColor}"></div></div>
            </div>
          `).join('');
        }

        function navigateToOccupation(id) {
            if (id === 'chef') {
                // Scroll to top and show toast — Chef tracker is the prototype page
                window.scrollTo({ top: 0, behavior: 'smooth' });
                showToast('👨‍🍳 Chef/Cook detailed tracker is available — full prototype with LTV, career levels, and city heatmap.');
            } else {
                showToast(
                    `📊 ${OCCUPATIONS.find(o=>o.id===id)?.name || id} — Detailed automation analysis coming soon. Check back for updates.`
                    );
            }
        }

        // ── JOB LISTINGS ──────────────────────────────────
        const JOB_LISTINGS = [
            { title: 'Executive Chef', company: 'Four Seasons Resort', location: 'Maui, HI', salary: '$95,000 – $130,000',
                risk: 37, tag: 'featured', tagText: 'FEATURED' },
            { title: 'Sous Chef', company: 'The Ritz-Carlton', location: 'New York, NY', salary: '$65,000 – $82,000',
                risk: 37, tag: 'new', tagText: 'NEW' },
            { title: 'Line Cook', company: 'Olive Garden', location: 'Dallas, TX', salary: '$32,000 – $38,000', risk: 37,
                tag: '', tagText: '' },
            { title: 'Senior Software Engineer', company: 'Google', location: 'Mountain View, CA',
                salary: '$160,000 – $220,000', risk: 28, tag: 'urgent', tagText: 'URGENT' },
            { title: 'Registered Nurse (ICU)', company: 'Mayo Clinic', location: 'Rochester, MN',
                salary: '$78,000 – $105,000', risk: 14, tag: 'new', tagText: 'NEW' },
            { title: 'Data Analyst', company: 'JP Morgan Chase', location: 'New York, NY',
                salary: '$85,000 – $110,000', risk: 42, tag: 'featured', tagText: 'FEATURED' },
            { title: 'Truck Driver (CDL-A)', company: 'Walmart Logistics', location: 'Phoenix, AZ',
                salary: '$55,000 – $72,000', risk: 72, tag: 'urgent', tagText: 'URGENT' },
            { title: 'Content Marketing Manager', company: 'HubSpot', location: 'Remote', salary: '$70,000 – $95,000',
                risk: 55, tag: '', tagText: '' },
        ];

        function renderJobListings() {
            const tbody = document.getElementById('jobsTableBody');
            if (!tbody) return;
            tbody.innerHTML = JOB_LISTINGS.map(j => `
            <tr>
              <td>
                <div class="job-title-col">${j.title}</div>
                <div class="job-company">${j.company}</div>
              </td>
              <td class="job-company">${j.company}</td>
              <td class="job-location">${j.location}</td>
              <td class="job-salary-col">${j.salary}</td>
              <td class="job-risk-col">
                <span class="occ-risk-pill ${j.risk>60?'risk-high':j.risk>35?'risk-mid':'risk-low'}">${j.risk}%</span>
              </td>
              <td class="job-risk-col">
                ${j.tag ? `<span class="job-tag ${j.tag}">${j.tagText}</span>` : '<span style="color:var(--text-faint);font-size:10px">—</span>'}
              </td>
            </tr>
          `).join('');
        }

        // ── NEWS ──────────────────────────────────────────
        function renderNews() {
            const grid = document.getElementById('newsGrid');
            if (!grid) return;
            grid.innerHTML = `
            <div class="news-featured">
              <span class="news-featured-tag">📰 BREAKING</span>
              <div class="news-featured-title">Miso Robotics Expands Flippy Deployment to 500+ Fast-Food Locations by Q3 2026</div>
              <div class="news-featured-excerpt">The rapid expansion of robotic fry cooks is accelerating automation risk for line cooks and fast-food kitchen staff. Industry analysts project a 15% reduction in entry-level kitchen hiring across major QSR chains within 18 months.</div>
              <div class="news-featured-meta">
                <span>🕐 2 hours ago</span>
                <span>📎 Robotics & Automation</span>
                <span>👁️ 4.2K views</span>
              </div>
            </div>
            <div class="news-side-list">
              <div class="news-side-item">
                <div class="news-side-title">🏥 Nursing Shortage Worsens — AI Assistants Fill Gaps, Not Replace Staff</div>
                <div class="news-side-meta">3 hours ago · Healthcare</div>
              </div>
              <div class="news-side-item">
                <div class="news-side-title">📊 BLS Revises 2026 Job Growth Forecast: 6 Occupations Most at Risk</div>
                <div class="news-side-meta">5 hours ago · Market Analysis</div>
              </div>
              <div class="news-side-item">
                <div class="news-side-title">💻 Remote Work Stabilizes at 28% of All Jobs — Hybrid Model Dominates</div>
                <div class="news-side-meta">8 hours ago · Workplace Trends</div>
              </div>
              <div class="news-side-item">
                <div class="news-side-title">🇸🇬 Singapore Accelerates AI Adoption in F&B — 40% of Hawker Stalls Pilot Automation</div>
                <div class="news-side-meta">12 hours ago · International</div>
              </div>
            </div>
          `;
        }

        // ── MARKET PULSE ──────────────────────────────────
        function renderPulse() {
            const grid = document.getElementById('pulseGrid');
            if (!grid) return;
            grid.innerHTML = `
            <div class="pulse-card">
              <div class="pulse-label">Job Openings (MoM)</div>
              <div class="pulse-value">+3.2%</div>
              <div class="pulse-change up">▲ 1.8% vs last month</div>
            </div>
            <div class="pulse-card">
              <div class="pulse-label">Avg Automation Index</div>
              <div class="pulse-value" style="color:var(--yellow)">37.4%</div>
              <div class="pulse-change neutral">● Unchanged</div>
            </div>
            <div class="pulse-card">
              <div class="pulse-label">Highest Demand Sector</div>
              <div class="pulse-value" style="font-size:18px;color:var(--accent)">Healthcare</div>
              <div class="pulse-change up">▲ 12% YoY growth</div>
            </div>
            <div class="pulse-card">
              <div class="pulse-label">Fastest Declining Sector</div>
              <div class="pulse-value" style="font-size:18px;color:var(--red)">Retail Cashier</div>
              <div class="pulse-change down">▼ 8% YoY decline</div>
            </div>
          `;
        }

        // ── TOAST ─────────────────────────────────────────
        function showToast(msg) {
            const toast = document.getElementById('toast');
            const msgEl = document.getElementById('toastMsg');
            if (!toast || !msgEl) return;
            msgEl.textContent = msg;
            toast.classList.add('show');
            clearTimeout(toast._timeout);
            toast._timeout = setTimeout(() => toast.classList.remove('show'), 3500);
        }

        // ── SUBSCRIBE HANDLERS ────────────────────────────
        function handleSubscribe(inputId) {
            const input = document.getElementById(inputId);
            if (!input) return;
            const email = input.value.trim();
            if (!email || !email.includes('@')) {
                input.style.borderColor = 'var(--red)';
                input.focus();
                setTimeout(() => input.style.borderColor = '', 1200);
                showToast('⚠️ Please enter a valid email address.');
                return;
            }
            showToast('✅ Subscribed! Check your inbox for confirmation.');
            input.value = '';
        }
        document.getElementById('subscribeBtn')?.addEventListener('click', () => {
            const email = prompt('Enter your email to get job market alerts:');
            if (email && email.includes('@')) {
                showToast('✅ Subscribed! Check your inbox for confirmation.');
            } else if (email) {
                showToast('⚠️ Please enter a valid email address.');
            }
        });
        document.getElementById('ctaSubscribeBtn')?.addEventListener('click', () => handleSubscribe('ctaEmail'));
        document.getElementById('heroSearchBtn')?.addEventListener('click', () => {
            const q = document.getElementById('heroSearch')?.value?.trim();
            if (q) {
                showToast(`🔍 Searching for "${q}" — showing best matches across jobs and occupations.`);
                document.getElementById('heroSearch').value = '';
            } else {
                showToast('🔍 Please enter a search term to find jobs and occupations.');
            }
        });
        // Enter key support
        document.getElementById('heroSearch')?.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') document.getElementById('heroSearchBtn')?.click();
        });
        document.getElementById('ctaEmail')?.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') document.getElementById('ctaSubscribeBtn')?.click();
        });

        // ── THEME TOGGLE ───────────────────────────────────
        (function() {
            const btn = document.getElementById('themeToggle');
            const icon = document.getElementById('themeIcon');
            const label = document.getElementById('themeLabel');
            if (!btn) return;
            let dark = true;
            btn.addEventListener('click', () => {
                dark = !dark;
                if (dark) {
                    document.documentElement.removeAttribute('data-theme');
                    icon.textContent = '☀️';
                    label.textContent = 'Light';
                } else {
                    document.documentElement.setAttribute('data-theme', 'light');
                    icon.textContent = '🌙';
                    label.textContent = 'Dark';
                }
            });
        })();

        // ── INIT ───────────────────────────────────────────
        function init() {
            renderOccupations();
            renderJobListings();
            renderNews();
            renderPulse();
        }
        document.addEventListener('DOMContentLoaded', init);
    </script>
</body>
</html>
```
### Homepage Features

This dashboard turns job-market data into an actionable tool for you. The design focuses on helping you scan complex information quickly and find what matters most.

- **Top Occupation Cards:** The main grid uses **color-coded risk badges** (e.g., "HIGH", "LOW") and **animated progress bars** to visually rank 12 professions. Hover effects and gradient glows make each card feel interactive, guiding your eye to high-risk or high-demand roles.

- **Job Listings Table:** A clean, scannable table organizes live listings by title, company, and salary. **Risk percentages** and **status tags** (e.g., "URGENT", "NEW") add immediate context without cluttering the row.

- **Market News & Pulse:** The news section uses a **featured story + side list** pattern for hierarchy. Market stats use large typography and simple directional indicators (▲/▼) to convey trends instantly.

- **Hero & Search:** The hero combines a direct search bar with three **key stats** (jobs tracked, avg risk, median salary). The sticky navigation bar keeps core filters accessible as you scroll.
