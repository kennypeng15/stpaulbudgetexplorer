void mousePressed() {
  if (initialViewOn) {
    if ((mouseX > 1400 && mouseX < 1420) && (mouseY > 50 && mouseY < 70)) {
      initialViewApproved = !initialViewApproved;
    } else if ((mouseX > 1400 && mouseX < 1420) && (mouseY > 90 && mouseY < 110)) {
      initialViewProposed = !initialViewProposed;
    } else if ((mouseX > 1400 && mouseX < 1570) && (mouseY > 130 && mouseY < 150)) {
      compareSelectorOpen = !compareSelectorOpen;
    } else if (compareSelectorOpen) {
      for (int i = 0; i < num_years; i++) {
        // button
        int left = (i % 2 == 0) ? 1320 : 1435;
        int top = 165 + (i / 2) * 35;
        if ((mouseX > left && mouseX < left+20) && (mouseY > top && mouseY < top+20)) {
          compareSelectedYears[i] = !compareSelectedYears[i];
        }
      }
      // final compare button
      if ((mouseX > 1345 && mouseX < 1345+180) && (mouseY > 315 && mouseY < 315+20)) {
        compareSelectorOpen = !compareSelectorOpen;
        initialViewOn = !initialViewOn;
        compareViewOn = !compareViewOn;
      }
    } else if ((mouseX > 105 && mouseX < 105+170) && (mouseY > 130 && mouseY < 150)) {
      // maybe chang
      categoryBuilderViewOn = !categoryBuilderViewOn;
      initialViewOn = !initialViewOn;
    } else if ((mouseX > 1400 && mouseX < 1400+170) && (mouseY > 10 && mouseY < 30)) {
      // rect(1400, 10, 170, 20); 
      initialViewOn = !initialViewOn;
      timelineViewOn = !timelineViewOn;
    }
  } else if (compareViewOn) {
    if ((mouseX > 1400 && mouseX < 1400+180) && (mouseY > 130 && mouseY < 130+20)) { // 10
      compareSelectorOpen = false;
      initialViewOn = true;
      compareViewOn = false;
    } else if ((mouseX > 1400 && mouseX < 1420) && (mouseY > 50 && mouseY < 70)) {
      compareViewApproved = !compareViewApproved;
      compareViewProposed = !compareViewProposed;
    } else if ((mouseX > 1400 && mouseX < 1420) && (mouseY > 90 && mouseY < 110)) {
      compareViewProposed = !compareViewProposed;
      compareViewApproved = !compareViewApproved;
    } else if ((mouseX > 1400 && mouseX < 1400+180) && (mouseY > 10 && mouseY < 10+20)) {
      compareViewPercentages = !compareViewPercentages;
    }
  } else if (categoryBuilderViewOn) {
    if ((mouseX > 105 && mouseX < 105+170) && (mouseY > 130 && mouseY < 150)) {
      categorySelectorOpen = !categorySelectorOpen;
    } else if (categorySelectorOpen) {
      for (int i = 0; i < services.length; i++) {
        int left = (i % 2 == 0) ? 120 : 345;
        int top = 165 + (i / 2) * 35;
        if ((mouseX > left && mouseX < left+20) && (mouseY > top && mouseY < top+20)) {
          categoryOverlaySelections[i] = !categoryOverlaySelections[i];
        }
      }
    } else if ((mouseX > 1400 && mouseX < 1400+180) && (mouseY > 130 && mouseY < 130+20)) {
      initialViewOn = true;
      compareViewOn = false;
      categoryBuilderViewOn = false;
      categorySelectorOpen = false;
    }
  } else if (timelineViewOn) {
    if ((mouseX > 1400 && mouseX < 1420) && (mouseY > 50 && mouseY < 70)) {
      timelineViewApproved = !timelineViewApproved;
    } else if ((mouseX > 1400 && mouseX < 1420) && (mouseY > 90 && mouseY < 110)) {
      timelineViewProposed = !timelineViewProposed;
    } else if ((mouseX > 1400 && mouseX < 1400+180) && (mouseY > 130 && mouseY < 130+20)) {
      initialViewOn = true;
      timelineViewOn = false;
    }
  }
}
