void drawTimelineView() {
  // draw the timeline itself
  fill(0); // black
  strokeWeight(2.0); // big
  line(timelineWidthOffset - 30, timelineHeight, 1600 - timelineWidthOffset + 30, timelineHeight); // extend a little

  // ticks + text
  int tickSpace = (1600 - (2 * timelineWidthOffset)) / (num_years - 1);
  for (int i = 0; i < num_years; i++) {
    fill(0);
    line(timelineWidthOffset + i*tickSpace, timelineHeight - 15, timelineWidthOffset + i*tickSpace, timelineHeight + 15);
    textAlign(CENTER);
    fill(100);
    textFont(smallFont);
    text(years[i], timelineWidthOffset + i*tickSpace, timelineHeight - 20);
  }
  textAlign(LEFT);
  // small
  strokeWeight(1.0);

  // moveable circle as a scrubber / slider
  // idea: so that getting exactly to a year isn't a gigantic pain in the ass, have a region of x +/- something like 5 just be considered as the year
  fill(color(100, 100, 100));
  circle(sliderXPos, sliderYPos, 20);

  // get the data + draw
  BarChart approved = new BarChart(this);
  float[] approvedTimelineData = getApprovedTimelineData();
  approved.setData(approvedTimelineData);
  approved.setBarLabels(services);
  approved.setBarColour(approvedBarChartColor);
  approved.setBarGap(2); 
  approved.setValueFormat("$###,###");
  approved.showValueAxis(true); 
  approved.showCategoryAxis(true); 
  approved.setMinValue(0); 
  approved.setMaxValue(maxCategoryValue);

  BarChart proposed = new BarChart(this);
  float[] proposedTimelineData = getProposedTimelineData();
  proposed.setData(proposedTimelineData);
  proposed.setBarLabels(services);
  proposed.setBarColour(proposedBarChartColor);
  proposed.setBarGap(2); 
  proposed.setValueFormat("$###,###");
  proposed.showValueAxis(true); 
  proposed.showCategoryAxis(true); 
  proposed.setMinValue(0); 
  proposed.setMaxValue(maxCategoryValue);

  if (timelineViewApproved) {
    approved.draw(10, chartHeightOffset + 25, width-20, height-(chartHeightOffset + 25 + 10));
  }
  if (timelineViewProposed) {
    proposed.draw(10, chartHeightOffset + 25, width-20, height-(chartHeightOffset + 25 + 10));
  }

  drawTimelineViewTitleAndLegend();
  drawTimelineViewApprovedToggleButton();
  drawTimelineViewProposedToggleButton();
  drawReturnToInitialViewButton();

  // tooltip time
  // define a set of bounding boxes for where the tooltip will show up based on chart height + values
  int chartHeight = height-(chartHeightOffset + 25 + 10);
  int chartWidth = width - 20;
  int rectBBWidth = (chartWidth / services.length) - 20;
  for (int i = 0; i < services.length; i++) {
    float heightOfBar = (approvedTimelineData[i] / maxCategoryValue) * chartHeight + 10;
    boolean widthCondition = mouseX > 10 + 70 + i*rectBBWidth && mouseX < 10 + 70 + i*rectBBWidth + rectBBWidth;
    boolean heightCondition = mouseY > chartHeightOffset + (chartHeight - int(heightOfBar)) + 20;
    // noFill();
    // rect(10 + 70 + i*rectBBWidth, chartHeightOffset + (chartHeight - int(heightOfBar)) + 20, rectBBWidth, int(heightOfBar));

    if (widthCondition && heightCondition) {
      fill(222, 222, 222);
      rect(mouseX - 95, mouseY - 100, 190, 100);
      textAlign(CENTER);
      textFont(smallFont);
      fill(0, 0, 0);
      String categoryText = services[i];
      String approvedText = "Approved: $" + nfc(int(approvedTimelineData[i]));
      String proposedText = "Proposed: $" + nfc(int(proposedTimelineData[i]));
      text(categoryText, mouseX - 95, mouseY - 85, 190, 30);
      text(approvedText, mouseX - 95, mouseY - 55, 190, 30);
      text(proposedText, mouseX - 95, mouseY - 40, 190, 30);
    }
  }
  textAlign(LEFT);
}

float[] getApprovedTimelineData() {
  int tickSpace = (1600 - (2 * timelineWidthOffset)) / (num_years - 1);
  for (int i = 0; i < num_years; i++) {
    // regular years
    if ((sliderXPos > timelineWidthOffset + i*tickSpace - 5) && (sliderXPos < timelineWidthOffset + i*tickSpace + 5)) {
      return categoryApprovedData[i];
    }
  }

  // not close enough to an actual year -- interpolate between data
  int index1 = floor(float(sliderXPos - timelineWidthOffset) / tickSpace);
  int index2 = ceil(float(sliderXPos - timelineWidthOffset) / tickSpace);
  println(index1);
  println(index2);

  // the locations are tickSpace - 10 away from each other (140 px i think)
  int adjustedSliderPos = (sliderXPos - timelineWidthOffset) - (index1 * tickSpace);
  float ratio = (float)(adjustedSliderPos-5) / (float)(tickSpace - 10);
  println(adjustedSliderPos);
  println(ratio);
  println(" == ");

  float[] data = new float[services.length];
  for (int i = 0; i < services.length; i++) {
    float lower = categoryApprovedData[index1][i];
    float upper = categoryApprovedData[index2][i];

    float val = ratio * (upper - lower);
    data[i] = lower + val;
  }

  return data;
}

float[] getProposedTimelineData() {
  int tickSpace = (1600 - (2 * timelineWidthOffset)) / (num_years - 1);
  for (int i = 0; i < num_years; i++) {
    // regular years
    if ((sliderXPos > timelineWidthOffset + i*tickSpace - 5) && (sliderXPos < timelineWidthOffset + i*tickSpace + 5)) {
      return categoryProposedData[i];
    }
  }

  // not close enough to an actual year -- interpolate between data
  int index1 = floor(float(sliderXPos - timelineWidthOffset) / tickSpace);
  int index2 = ceil(float(sliderXPos - timelineWidthOffset) / tickSpace);

  // the locations are tickSpace - 10 away from each other (140 px i think)
  int adjustedSliderPos = (sliderXPos - timelineWidthOffset) - (index1 * tickSpace);
  float ratio = (float)(adjustedSliderPos-5) / (float)(tickSpace - 10);
  float[] data = new float[services.length];
  for (int i = 0; i < services.length; i++) {
    float lower = categoryProposedData[index1][i];
    float upper = categoryProposedData[index2][i];
    float val = ratio * (upper - lower);
    data[i] = lower + val;
  }
  return data;
}

void drawTimelineViewTitleAndLegend() {
  // legends first
  // 20 x 20 rectangle the color of proposed
  fill(approvedBarChartColor);
  rect(105, 50, 20, 20);

  // 20 x 20 rectangle the color of approved
  fill(proposedBarChartColor);
  rect(105, 90, 20, 20);

  // legend labels
  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  text("Approved", 135, 50 + textHeight + 5);
  text("Proposed", 135, 90 + textHeight + 5);

  // now titles
  // calculate indices again
  int tickSpace = (1600 - (2 * timelineWidthOffset)) / (num_years - 1);
  for (int i = 0; i < num_years; i++) {
    // regular years
    if ((sliderXPos > timelineWidthOffset + i*tickSpace - 5) && (sliderXPos < timelineWidthOffset + i*tickSpace + 5)) {
      textFont(titleFont);
      textAlign(CENTER);
      fill(100);
      text("St. Paul Expense Budget by Category, " + years[i], 800, 20);
      textAlign(LEFT);
      return;
    }
  }

  // not close enough to an actual year -- interpolate between data
  int index1 = floor(float(sliderXPos - timelineWidthOffset) / tickSpace);
  int index2 = ceil(float(sliderXPos - timelineWidthOffset) / tickSpace);
  textFont(titleFont);
  textAlign(CENTER);
  fill(100);
  text("St. Paul Expense Budget by Category, " + years[index1] + " - " + years[index2], 800, 20);
  textAlign(LEFT);
  return;
}

void drawTimelineViewApprovedToggleButton()
{
  // try 20x20 for now
  int fillColor = timelineViewApproved ? 0 : 255;
  fill(fillColor);
  rect(1400, 50, 20, 20);

  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  text("View approved data", 1430, 50 + textHeight + 5);

  if (mousePressed) {
  }
}

void drawTimelineViewProposedToggleButton()
{
  int fillColor = timelineViewProposed ? 0 : 255;
  fill(fillColor);
  rect(1400, 90, 20, 20);

  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  text("View proposed data", 1430, 90 + textHeight + 5);

  if (mousePressed) {
  }
}

void mouseDragged() {
  // need this for slider 
  if ((mouseX < sliderXPos + 10) && (mouseX > sliderXPos - 10) && (mouseY > sliderYPos - 20) && (mouseY < sliderYPos + 20)) { // give a little more vertical leeway
    int newXPos = constrain(mouseX, timelineWidthOffset, 1600 - timelineWidthOffset);
    sliderXPos = newXPos;
  }
}
