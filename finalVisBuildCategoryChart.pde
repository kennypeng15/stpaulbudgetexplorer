void drawStackedCategoryChartTooltips(int[] serviceIndices, Boolean approved) {
  // define a set of bounding boxes for where the tooltip will show up based on chart height + values
  int chartHeight = height - chartHeightOffset;
  int chartWidth = width - 20;
  int rectBBWidth = (chartWidth / num_years) - 10;
  for (int i = 0; i < num_years; i++) {
    float heightOfBar = (proposedData[i] / proposedBarChart.getMaxValue()) * chartHeight;
    boolean widthCondition = mouseX > 10 + 70 + i*rectBBWidth && mouseX < 10 + 70 + i*rectBBWidth + rectBBWidth;
    boolean heightCondition = mouseY > chartHeightOffset + (chartHeight - int(heightOfBar));

    if (widthCondition && heightCondition && !categorySelectorOpen) { // don't draw when category selector is open so tooltip doesn't cover the selector
      // change color of tooltip to grey
      int tooltipHeight = (serviceIndices.length * 30) + 70;
      fill(25, 25, 25);
      rect(mouseX - 95, mouseY - (tooltipHeight + 10), 190, tooltipHeight);

      textAlign(CENTER);
      fill(255, 255, 255);
      text(years[i], mouseX, mouseY - (tooltipHeight - 10));

      if (approved) {
        String approvedText = "Total approved: $" + nfc(int(approvedData[i]));
        text(approvedText, mouseX, mouseY - (tooltipHeight - 30));
      } else {
        String proposedText = "Total proposed: $" + nfc(int(proposedData[i]));
        text(proposedText, mouseX, mouseY - (tooltipHeight - 30));
      }

      for (int j = 0; j < serviceIndices.length; j++) {
        String approvedOrProposedText = approved ? "approved" : "proposed";
        String categoryTooltipValue = approved ? nfc(int(yearlyData[i].getTotalApprovedByService(services[serviceIndices[j]]))) 
          : nfc(int(yearlyData[i].getTotalProposedByService(services[serviceIndices[j]])));
        String categoryTooltipText = "Total " + approvedOrProposedText + " for " + services[serviceIndices[j]] + ": $" + categoryTooltipValue;
        // maybe add something by percent ???
        fill(colors[j]);
        text(categoryTooltipText, mouseX - 95, mouseY - (tooltipHeight - (45 + 30*j)), 190, 30);
      }
    }
    textAlign(LEFT);
  }
}

// TODO title and legend
void drawStackedCategoryChartTitleAndLegend(int[] serviceIndices, Boolean approved) {
  // rip straight from initial view for now
  fill(100);
  textFont(titleFont);
  String approvedProposedText = approved ? "Approved" : "Proposed";
  String titleText = "St. Paul " + approvedProposedText + " Expense Budget, 2014-2021, Category Overlay";
  text(titleText, 500, 20);

  // legends
  textFont(smallFont);
  float textHeight = textAscent();
  for (int i = 0; i < serviceIndices.length; i++) { 
    fill(colors[i]);
    int rectLeft = 105 + (i/2 * 250);
    int rectTop = (i % 2 == 0) ? 50 : 90;
    rect(rectLeft, rectTop, 20, 20);
    fill(100);
    text(services[serviceIndices[i]], rectLeft + 30, rectTop + textHeight + 5);
  }
}

// TODO return to initial view button
// nvm i reused the other one

void drawStackedCategoryChart(int[] serviceIndices, Boolean approved) {
  // idea -- cool build-a-chart functionality like in dave's sketch
  // change it so users can select what categories they want to see rather than all of them being present immediately
  // also have the actual value of the entire budget as like a really pale afterimage bar

  BarChart b_a = new BarChart(this);
  BarChart b_p = new BarChart(this);
  // FUCKING DEEP COPIES

  b_p.setData(proposedData);
  b_p.setBarLabels(years);
  b_p.setBarGap(2); 
  b_p.setValueFormat("$###,###");
  b_p.showValueAxis(true); 
  b_p.showCategoryAxis(true); 
  b_p.setMinValue(0);

  // approved data
  b_a.setData(approvedData);
  b_a.setBarLabels(years);
  b_a.setMinValue(proposedBarChart.getMinValue());
  b_a.setMaxValue(proposedBarChart.getMaxValue());
  b_a.setBarGap(2); 
  b_a.setValueFormat("$###,###");
  b_a.showValueAxis(true); 
  b_a.showCategoryAxis(true);

  b_a.setBarColour(color(245, 245, 245));
  b_p.setBarColour(color(245, 245, 245));

  if (approved) {
    b_a.draw(10, chartHeightOffset, width-20, height-chartHeightOffset);
  } else {
    b_p.draw(10, chartHeightOffset, width-20, height-chartHeightOffset);
  }

  float[] accumulator = new float[num_years]; // one for each year
  BarChart[] charts = new BarChart[serviceIndices.length];

  for (int n = 0; n < serviceIndices.length; n++) {
    BarChart chart = new BarChart(this);
    float[] curr_data = new float[num_years];

    for (int i = 0; i < num_years; i++) {
      if (approved) {
        accumulator[i] += yearlyData[i].getTotalApprovedByService(services[serviceIndices[n]]);
      } else {
        accumulator[i] += yearlyData[i].getTotalProposedByService(services[serviceIndices[n]]);
      }
      // I HATE PASS BY REFERENCE I HATE PASS BY REFERENCE I HATE PASS BY REFERENCE
      curr_data[i] = accumulator[i];
    }

    chart.setData(curr_data);
    chart.setBarLabels(years);
    chart.setBarColour(colors[n]);
    chart.setMinValue(proposedBarChart.getMinValue());
    chart.setMaxValue(proposedBarChart.getMaxValue());
    chart.setBarGap(2);
    chart.setValueFormat("$###,###");
    chart.showValueAxis(true);
    chart.showCategoryAxis(true);
    charts[n] = chart;
  }  

  for (int i = serviceIndices.length - 1; i >= 0; i--) {
    charts[i].draw(10, chartHeightOffset, width-20, height-chartHeightOffset);
  }
}
