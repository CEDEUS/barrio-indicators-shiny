---
title: Indicators
author: ''
date: '2017-12-11'
slug: indicators
categories: []
tags: []
menu: 'main'
weight: 70
---

## A look inside the indicators databases

```
> head(readRDS("accesibility_score_final_15.RDS"))
           ID_W value               d
1 9112041001032    36 Barrio Amanecer
2 9101171003040    75 Barrio Amanecer
3 9101171003002    52 Barrio Amanecer
4 9101171001001    54 Barrio Amanecer
5 9101171003028    65 Barrio Amanecer
6 9101171002002    80 Barrio Amanecer
```


| COLUMN | DESCRIPTION                    |
|--------|--------------------------------|
| ID_W   | Census code related to manzana |
| value  | Score of the indicator         |
| d      | Barrio's name                  |

## How to add a new indicator

- First you have to set up a database using the specifications above
- Then edit the hidden data.frames and choose a view (at the moment I have 3)