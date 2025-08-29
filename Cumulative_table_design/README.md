# Cumulative Player Seasons Table Design

## Overview

This repository demonstrates a **cumulative table design** applied to the `player_seasons` dataset. The goal is to **optimize storage, reduce computation, and improve query performance** for large-scale sports datasets.

Instead of storing one row per player per season, this approach aggregates season-level statistics into **array-based cumulative records per player**. This reduces the number of rows and overall storage requirements by **over 60%**, while maintaining full analytical flexibility.

---

## Features

- **Compact Storage:**  
  - Player data and season stats are stored in arrays, significantly reducing row counts.
  - Supports **Run-Length Encoding (RLE)** and other compression methods with no errors when using **Spark** or other parallel processing engines.

- **Performance Optimized Queries:**  
  - Common queries such as first/last season, total seasons, or ratios of performance metrics can be done by scanning a small table.  
  - Avoids expensive operations like `GROUP BY`, `MIN`, and `MAX` on the full dataset.  

- **Efficient Incremental Updates:**  
  - New seasons can be added without rewriting the entire table.
  - Only the affected player rows are updated by appending the new season to the existing array.
  - Supports batch or streaming updates efficiently in **PostgreSQL** or distributed engines like **Spark**.

- **Flexible Analytics:**  
  - Calculate player scoring classification (`bad`, `average`, `good`, `star`) easily.
  - Compute derived metrics like **average height**, **active vs inactive players**, or **ratios of recent-to-first season stats** efficiently.

- **Spark & Parallel Engine Friendly:**  
  - Fully compatible with **distributed computation**.
  - Optimized for **vectorized operations** and avoids skew in large datasets.

---
