import org.gicentre.utils.stat.*;        // For chart classes. //<>//

// Adapted from CSci-5609 Assignment on St. Paul Budget Data
// January 2022
// Original authors Dan Keefe and Bridger Herman, Univ. of Minnesota
// {dfk, herma582}@umn.edu

// Modified for final project by David Ma and Kenny Peng, Univ. of MN
// {maxxx818, pengx283}@umn.edu

// Sketch to demonstrate the use of the BarChart class to draw simple bar charts.
// Version 1.3, 6th February, 2016.
// Author Jo Wood, giCentre.

// --------------------- Sketch-wide variables ----------------------

int num_years = 8;

// colors from colorbrewer
color [] colors = {
  color(31, 120, 180), // blue
  color(227, 26, 28), // red
  color(51, 160, 44), // green
  color(253, 191, 111), // orange
  color(166, 206, 227), // l. blue
  color(251, 154, 153), // l.red
  color(178, 223, 138), // l.green
};

BarChart proposedBarChart;
color proposedBarChartColor = colors[0];
BarChart approvedBarChart;
color approvedBarChartColor = colors[4];
float [] proposedData = new float[num_years];
float [] approvedData = new float[num_years];
PFont titleFont, smallFont;

color bloodRed = colors[1];
color salmonyRed = colors[5];

BudgetData budgetData;
YearlyData[] yearlyData = new YearlyData[num_years];
String [] services;
String [] years = new String[] {"2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021"};

int chartHeightOffset = 100;
boolean initialViewOn = true;
boolean initialViewProposed = true;
boolean initialViewApproved = true;
boolean compareSelectorOpen = false;
Boolean [] compareSelectedYears = new Boolean[] {false, false, false, false, false, false, false, false};

// category builder view
boolean categoryBuilderViewOn = false;
boolean categorySelectorOpen = false;
boolean categoryOverlayOn = false;
Boolean [] categoryOverlaySelections = new Boolean[] {false, false, false, false, false, false, false};

// compare page
boolean compareViewOn = false;
boolean compareViewApproved = true;
boolean compareViewProposed = false;
boolean compareViewPercentages = false;

// timeline view
boolean timelineViewOn = false;
boolean timelineViewApproved = true;
boolean timelineViewProposed = true;
int timelineHeight = 85;
int timelineWidthOffset = 275; // then total line width = 1600 - 2 * lineWidthOffset
int sliderXPos = 275; //
int sliderYPos = 85;
// array of arrays; each year and then by each service
float[][] categoryApprovedData = new float[num_years][7];
float[][] categoryProposedData = new float[num_years][7];
float maxCategoryValue = 0;

// ------------------------ Initialisation --------------------------

public void settings() {  
  size(1600, 900);
}

// Initialises the data and bar chart.
void setup()
{
  smooth();

  titleFont = loadFont("Helvetica-22.vlw");
  smallFont = loadFont("Helvetica-12.vlw");
  textFont(smallFont);

  // here's how to load the budget data
  budgetData = new BudgetData();
  budgetData.loadFromFile("operating_budget-2022-01-16.csv");

  int[] years = budgetData.getYears();

  String [] barLabels = new String[years.length - 1];
  services = budgetData.getYearlyData(years[years.length-1]).getServices();  

  // note - there's incomplete data for 2022, so exclude it -- that's why we do years.length - 1
  for (int i = 0; i < years.length - 1; i++)
  {
    YearlyData yd = budgetData.getYearlyData(years[i]);
    yearlyData[i] = yd;
    proposedData[i] = yd.getTotalProposed();
    approvedData[i] = yd.getTotalApproved();
    barLabels[i] = str(years[i]);
  }

  // populate category by year info
  for (int i = 0; i < years.length - 1; i++) {
    // this is in a setup block, so I don't care about gross nested loops
    for (int j = 0; j < services.length; j++) {
      categoryApprovedData[i][j] = yearlyData[i].getTotalApprovedByService(services[j]);
      categoryProposedData[i][j] = yearlyData[i].getTotalProposedByService(services[j]);
      float max = max(yearlyData[i].getTotalApprovedByService(services[j]), yearlyData[i].getTotalProposedByService(services[j]));
      maxCategoryValue = (max > maxCategoryValue) ? max : maxCategoryValue;
    }
  }

  // initial view charts
  // proposed data
  proposedBarChart = new BarChart(this);
  proposedBarChart.setData(proposedData);
  proposedBarChart.setBarLabels(barLabels);
  proposedBarChart.setBarColour(proposedBarChartColor);
  proposedBarChart.setBarGap(2); 
  proposedBarChart.setValueFormat("$###,###");
  proposedBarChart.showValueAxis(true); 
  proposedBarChart.showCategoryAxis(true); 
  // !!! need this for category shit
  proposedBarChart.setMinValue(0); // maybe play with this? setting outright to 0 looks a little odd

  // approved data
  approvedBarChart = new BarChart(this);
  approvedBarChart.setData(approvedData);
  approvedBarChart.setBarLabels(barLabels);
  approvedBarChart.setBarColour(approvedBarChartColor);
  approvedBarChart.setMinValue(proposedBarChart.getMinValue());
  approvedBarChart.setMaxValue(proposedBarChart.getMaxValue());
  approvedBarChart.setBarGap(2); 
  approvedBarChart.setValueFormat("$###,###");
  approvedBarChart.showValueAxis(true); 
  approvedBarChart.showCategoryAxis(true);
}

// ================= User-defined draw functions ========

void drawInitialViewApprovedToggleButton()
{
  // try 20x20 for now
  int fillColor = initialViewApproved ? 0 : 255;
  fill(fillColor);
  rect(1400, 50, 20, 20);

  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  text("View approved data", 1430, 50 + textHeight + 5);

  if (mousePressed) {
  }
}

void drawInitialViewProposedToggleButton()
{
  int fillColor = initialViewProposed ? 0 : 255;
  fill(fillColor);
  rect(1400, 90, 20, 20);

  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  text("View proposed data", 1430, 90 + textHeight + 5);

  if (mousePressed) {
  }
}

void drawInitialViewTitleAndLegend() {
  // title text
  fill(100);
  textFont(titleFont);
  textAlign(CENTER);
  text("St. Paul Expense Budget, 2014-2021", 800, 20);
  textAlign(LEFT);

  // legends
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
}

void drawInitialViewCompareButton() {
  // draw compare screen menu button
  fill(222, 222, 222);
  rect(1400, 130, 170, 20);
  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  text("Select years to compare", 1420, 130 + textHeight + 5);
  if (mousePressed) {
  }
  if (compareSelectorOpen) {
    fill(255);
    rect(1300, 150, 270, 200);

    for (int i = 0; i < num_years; i++) {
      // button
      int boxFillColor = compareSelectedYears[i] ? 0 : 255;
      fill(boxFillColor);
      int left = (i % 2 == 0) ? 1320 : 1435;
      int top = 165 + (i / 2) * 35;
      rect(left, top, 20, 20);

      // text
      fill(100);
      text(years[i], left + 30, top + textHeight + 5);
    }

    // final compare button
    fill(222, 222, 222);
    rect(1345, 315, 180, 20);
    fill(100);
    text("Compare selected years", 1365, 315 + textHeight + 5);
  }
}

void drawInitialViewTimelineViewToggle() {
  fill(222, 222, 222);
  rect(1400, 10, 170, 20);
  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  textAlign(CENTER);
  text("Go to timeline view", 1485, 10 + textHeight + 5);
  textAlign(LEFT);
  if (mousePressed) {
  }
}

void drawInitialViewCategoryOverlaySelector() {
  // maybe change where this is
  fill(222, 222, 222);
  rect(105, 130, 170, 20);
  textFont(smallFont);
  float textHeight = textAscent();
  fill(100);
  String buttonText = initialViewOn ? "Go to stacked category view" : "Select category to overlay";
  int xPos = initialViewOn ? 115 : 120;
  text(buttonText, xPos, 130 + textHeight + 5);
  if (mousePressed) {
  }
  if (categorySelectorOpen) {
    fill(255);
    rect(105, 150, 475, 160);

    for (int i = 0; i < services.length; i++) {
      // button
      int boxFillColor = categoryOverlaySelections[i] ? 0 : 255;
      fill(boxFillColor);
      int left = (i % 2 == 0) ? 120 : 345;
      int top = 165 + (i / 2) * 35;
      rect(left, top, 20, 20);

      // text
      fill(100);
      text(services[i], left + 30, top + textHeight + 5);
    }
  }
}

void drawInitialViewTooltips() {
  // get all approved and proposed by yeaer amounts
  float[] propByYear = new float[num_years];
  float[] appByYear = new float[num_years];
  for (int i = 0; i < num_years; i++) {
    propByYear[i] = yearlyData[i].getTotalProposed();
    appByYear[i] = yearlyData[i].getTotalApproved();
  }

  // define a set of bounding boxes for where the tooltip will show up based on chart height + values
  int chartHeight = height - chartHeightOffset;
  int chartWidth = width - 20;
  int rectBBWidth = (chartWidth / num_years) - 10; // - 10 to adjust for the fact that we have axes, which makes bars less thick
  for (int i = 0; i < num_years; i++) {
    float heightOfBar = (propByYear[i] / proposedBarChart.getMaxValue()) * chartHeight;
    // nofill();
    // rect(10 + 70 + i*rectBBWidth, chartHeightOffset + (chartHeight - int(heightOfBar)), rectBBWidth, int(heightOfBar)); // 10 + (70) to adjust for the fact that axes offset things
    boolean widthCondition = mouseX > 10 + 70 + i*rectBBWidth && mouseX < 10 + 70 + i*rectBBWidth + rectBBWidth;
    boolean heightCondition = mouseY > chartHeightOffset + (chartHeight - int(heightOfBar));

    // actually draw the tooltips
    if (widthCondition && heightCondition && !compareSelectorOpen) { // don't draw when compare selector is open so tooltip doesn't cover the selector
      // change color of tooltip to grey
      int tooltipHeight = categoryOverlayOn ? 240 : 70;
      fill(225, 225, 225);
      rect(mouseX - 95, mouseY - (tooltipHeight + 10), 190, tooltipHeight);

      textAlign(CENTER);
      fill(0, 0, 0);
      text(years[i], mouseX, mouseY - (tooltipHeight - 10));   
      String proposedText = "Proposed: $" + nfc(int(propByYear[i]));
      text(proposedText, mouseX, mouseY - (tooltipHeight - 30));
      String approvedText = "Approved: $" + nfc(int(appByYear[i]));
      text(approvedText, mouseX, mouseY - (tooltipHeight - 45));
    }
    // change back text align so repeatedly drawing doesn't screw things up
    textAlign(LEFT);
  }
}

// ================= End user-defined draw functions ====

// ------------------ Processing draw --------------------

// Draws the graph in the sketch.
void draw()
{
  background(255);
  // initial view
  if (initialViewOn) {
    if (initialViewApproved) {
      approvedBarChart.draw(10, chartHeightOffset, width-20, height-chartHeightOffset);
    }
    if (initialViewProposed) {
      proposedBarChart.draw(10, chartHeightOffset, width-20, height-chartHeightOffset);
    }
    drawInitialViewApprovedToggleButton();
    drawInitialViewProposedToggleButton();
    drawInitialViewTimelineViewToggle();
    drawInitialViewTitleAndLegend();   
    drawInitialViewCompareButton();
    if (initialViewApproved ^ initialViewProposed) {
      drawInitialViewCategoryOverlaySelector(); // change name lmao?
    }
    drawInitialViewTooltips();
  }  
  if (!initialViewOn && compareViewOn) {
    // just pick the first two true ones
    int [] yearsToCompare = new int [] {};
    for (int i = 0; i < num_years; i++) {
      if (compareSelectedYears[i]) {
        yearsToCompare = append(yearsToCompare, i);
      }
    }
    if (yearsToCompare.length == 2) {
      drawGroupedComparativeBarChart(yearsToCompare[0], yearsToCompare[1]);
    }
    drawReturnToInitialViewButton();
    drawCompareViewProposedToggleButton();
    drawCompareViewApprovedToggleButton();
    drawCompareViewTogglePercentOrDollarButton();
  }
  if (!initialViewOn && categoryBuilderViewOn) {
    // Boolean approved = initialViewApproved ? true : false;
    int[] indices = new int[] {};
    for (int i = 0; i < categoryOverlaySelections.length; i++) {
      if (categoryOverlaySelections[i]) {
        indices = append(indices, i);
      }
    }
    drawStackedCategoryChart(indices, initialViewApproved); 
    drawInitialViewCategoryOverlaySelector();
    drawReturnToInitialViewButton();
    drawStackedCategoryChartTooltips(indices, initialViewApproved);
    drawStackedCategoryChartTitleAndLegend(indices, initialViewApproved);
  }
  if (timelineViewOn) {
    drawTimelineView();
  }
}
