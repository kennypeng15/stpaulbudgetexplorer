void drawGroupedComparativeBarChart(int index1, int index2) 
{
  // general idea for making a grouped bar chart (gicentre doesn't seem to support this):
  // make 3 separate charts - an empty chart representing the axes (set all data to 0), 
  // set axes to true, min and max to an actual chart, etc.
  // then just make two actual charts with real data, but have axes set to false, 
  // then offset them in the draw function (want barPadding or barGap to be significant)
  int numServices = services.length;

  // naievely assume that the higher index will always have the max value, and that
  // the lower index will have the min value
  // figure it out later tho
  int minIndex = min(index1, index2);
  int maxIndex = max(index1, index2);
  YearlyData ydMin = yearlyData[minIndex];
  YearlyData ydMax = yearlyData[maxIndex];

  float[] breakdownMin = new float[numServices];
  float[] breakdownMax = new float[numServices];
  float totalMin = 0;
  float totalMax = 0;

  for (int i = 0; i < numServices; i++) {
    if (compareViewApproved) {
      breakdownMin[i] = ydMin.getTotalApprovedByService(services[i]);
      breakdownMax[i] = ydMax.getTotalApprovedByService(services[i]);
    } else { // compareViewProposed
      breakdownMin[i] = ydMin.getTotalProposedByService(services[i]);
      breakdownMax[i] = ydMax.getTotalProposedByService(services[i]);
    }
  }

  if (compareViewPercentages) {
    for (int i = 0; i < numServices; i++) {
      totalMin += breakdownMin[i];
      totalMax += breakdownMax[i];
    }
    for (int i = 0; i < numServices; i++) {
      breakdownMin[i] = (breakdownMin[i] / totalMin) * 100;
      breakdownMax[i] = (breakdownMax[i] / totalMax) * 100;
    }
  }

  // so that we can always see something for proposed or accepted data
  float zeroDataPoint = compareViewPercentages ? 0.0 : min(breakdownMin) - 10000000;
  float[] zeroData = new float[] {zeroDataPoint, 
    zeroDataPoint, 
    zeroDataPoint, 
    zeroDataPoint, 
    zeroDataPoint, 
    zeroDataPoint, 
    zeroDataPoint};

  // i hate java i hate java i hate java
  String valueFormatString = compareViewPercentages ? "##,##%" : "$###,###";

  BarChart chartMax = new BarChart(this);
  chartMax.setData(breakdownMax);
  chartMax.setBarLabels(services);
  chartMax.setBarColour(approvedBarChartColor);

  BarChart chartMin = new BarChart(this);
  chartMin.setData(breakdownMin);
  chartMin.setBarLabels(services);

  chartMax.setMinValue(zeroDataPoint);
  chartMax.setMaxValue(chartMax.getMaxValue());
  chartMax.setBarGap(140); 
  chartMax.setValueFormat(valueFormatString);
  chartMax.showValueAxis(false); 
  chartMax.showCategoryAxis(false); 

  chartMin.setMinValue(zeroDataPoint);
  chartMin.setMaxValue(chartMax.getMaxValue());
  chartMin.setBarColour(proposedBarChartColor);
  chartMin.setBarGap(140); 
  chartMin.setValueFormat(valueFormatString);
  chartMin.showValueAxis(false); 
  chartMin.showCategoryAxis(false); 

  BarChart axes = new BarChart(this);
  axes.setData(zeroData);
  axes.setBarLabels(services);
  axes.setMinValue(zeroDataPoint);
  axes.setMaxValue(chartMax.getMaxValue());
  axes.setBarGap(2);
  axes.setValueFormat(valueFormatString);
  axes.showValueAxis(true);
  axes.showCategoryAxis(true);

  axes.draw(10, chartHeightOffset-10, width+30, height-chartHeightOffset);
  chartMin.draw(90, chartHeightOffset-20, width-220, height-chartHeightOffset);
  chartMax.draw(170, chartHeightOffset-20, width-220, height-chartHeightOffset);


  // now draw legends
  // title text
  fill(100);
  textFont(titleFont);
  textAlign(CENTER);
  String typeString1 = compareViewApproved ? "(approved budget data)" : "(proposed budget data)";
  String typeString2 = compareViewPercentages ? " as % of total budget" : "";
  String titleText = "St. Paul Expense Budget " + typeString1 + typeString2 + " - " 
    + years[minIndex] + " and " + years[maxIndex];
  text(titleText, 800, 20);
  textAlign(LEFT);

  // legends
  // min chart == proposed color
  // max chart == approved color
  // 20 x 20 rectangle the color of proposed
  fill(proposedBarChartColor);
  rect(850, 50, 20, 20);

  // 20 x 20 rectangle the color of approved
  fill(approvedBarChartColor);
  rect(850, 90, 20, 20);

  // legend labels
  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  text(years[minIndex], 890, 50 + textHeight + 5); // approved color
  text(years[maxIndex], 890, 90 + textHeight + 5); // proposed color

  // tooltips    
  int chartHeight = height - chartHeightOffset;
  int chartWidth = width - 20;
  int rectBBWidth = (chartWidth / num_years) - 10; // - 10 to adjust for the fact that we have axes, which makes bars less thick
  for (int i = 0; i < services.length; i++) {
    float heightOfBar = (breakdownMax[i] / axes.getMaxValue()) * chartHeight;
    // noFill();
    // rect(10 + 70 + i*rectBBWidth + i*30, chartHeightOffset + (chartHeight - int(heightOfBar)) - 50, rectBBWidth, int(heightOfBar) + 30); // 10 + (70) to adjust for the fact that axes offset things
    boolean widthCondition = (mouseX > 10 + 70 + i*rectBBWidth + i*30) && (mouseX < 10 + 70 + i*rectBBWidth + rectBBWidth + i*30);
    boolean heightCondition = mouseY > chartHeightOffset + (chartHeight - int(heightOfBar)) - 50;
    if (widthCondition && heightCondition) {
      // change color of tooltip to grey
      int tooltipHeight = !compareViewPercentages ? 200 : 70;
      int tooltipWidth = !compareViewPercentages ? 280 : 200;
      fill(225, 225, 225);
      rect(mouseX - (tooltipWidth / 2), mouseY - (tooltipHeight + 10), tooltipWidth, tooltipHeight);

      textAlign(CENTER);
      fill(0, 0, 0);
      text(services[i], mouseX, mouseY - (tooltipHeight - 10));   
      String minYearPercentageText = years[minIndex] + ": " + nf(breakdownMin[i], 0, 2) + "%";
      String minYearDollarText = years[minIndex] + ": $" + nfc(int(breakdownMin[i]));
      String maxYearPercentageText = years[maxIndex] + ": " + nf(breakdownMax[i], 0, 2) + "%";
      String maxYearDollarText = years[maxIndex] + ": $" + nfc(int(breakdownMax[i]));

      String minYearText = compareViewPercentages ? minYearPercentageText : minYearDollarText; 
      text(minYearText, mouseX, mouseY - (tooltipHeight - 30));
      String maxYearText = compareViewPercentages ? maxYearPercentageText : maxYearDollarText; 
      text(maxYearText, mouseX, mouseY - (tooltipHeight - 45));

      String minYearBiggestContributorText = "Biggest contributor - " + years[minIndex] + ": " + yearlyData[minIndex].getBiggestContributorToApprovedByService(services[i]);
      String maxYearBiggestContributorText = "Biggest contributor - " + years[maxIndex] + ": " + yearlyData[maxIndex].getBiggestContributorToApprovedByService(services[i]);
      if (!compareViewPercentages) {
        text(minYearBiggestContributorText, mouseX - (tooltipWidth / 2), mouseY - (tooltipHeight - 55), tooltipWidth, 80);
        text(maxYearBiggestContributorText, mouseX - (tooltipWidth / 2), mouseY - (tooltipHeight - 125), tooltipWidth, 80);
      }
    }
  }
  textAlign(LEFT);
}

void drawReturnToInitialViewButton() {
  // draw back button
  fill(222, 222, 222);
  rect(1400, 130, 180, 20);
  // 1400, 10, 180, 20

  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  text("Return to initial view", 1435, 130 + textHeight + 5); // 10

  if (mousePressed) {
  }
}

void drawCompareViewApprovedToggleButton()
{
  // try 20x20 for now
  int fillColor = compareViewApproved ? 0 : 255;
  fill(fillColor);
  rect(1400, 50, 20, 20);

  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  text("View approved data", 1430, 50 + textHeight + 5);

  if (mousePressed) {
  }
}

void drawCompareViewProposedToggleButton()
{
  int fillColor = compareViewProposed ? 0 : 255;
  fill(fillColor);
  rect(1400, 90, 20, 20);

  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  text("View proposed data", 1430, 90 + textHeight + 5);

  if (mousePressed) {
  }
}

void drawCompareViewTogglePercentOrDollarButton()
{
  // draw back button
  fill(222, 222, 222);
  rect(1400, 10, 180, 20);

  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  String buttonText = compareViewPercentages ? "View data in dollars" : "View data as percentages";
  int textPosition = compareViewPercentages ? 1435 : 1420;
  text(buttonText, textPosition, 10 + textHeight + 5); // 10

  if (mousePressed) {
  }
}
