// This file contains two helper classes that can be used to parse budget data from the //<>// //<>//
// City of St. Paul's Open Data Portal, which is provided in raw csv file format.
// For use with CSci-5609 Homeworks and Projects
// Author: Dan Keefe, January 31, 2019
// Modified: Kenny Peng

import java.util.*;
import java.lang.*;


// This class holds data for a single year of the budget.  It stores the overall total
// propsed budget for the year and the overall approved budget for the year.  And, it
// also stores totals broken down by category.  There are many possible approaches to
// breaking down by category.  For now, the class supports just a top-level categorization
// according to the "service" data variable.  St. Paul uses 7 categories for services
// (Public Safety, Transportation, ...)
public class YearlyData {
  private int year;
  private float totalProposed;
  private float totalApproved;
  private HashMap<String, Float> totalProposedByService;
  private HashMap<String, Float> totalApprovedByService;

  private HashMap<String, String> biggestContributorsToApprovedByService;
  private HashMap<String, String> biggestContributorsToProposedByService;
  private HashMap<String, Float> biggestContributorsToApprovedByServiceTracker;
  private HashMap<String, Float> biggestContributorsToProposedByServiceTracker;

  // Constructor, initialize by providing the year as an int
  public YearlyData(int year) {
    this.year = year;
    this.totalProposed = 0.0;
    this.totalApproved = 0.0;
    this.totalProposedByService = new HashMap<String, Float>();
    this.totalApprovedByService = new HashMap<String, Float>();

    //
    this.biggestContributorsToApprovedByService = new HashMap<String, String>();
    this.biggestContributorsToProposedByService = new HashMap<String, String>();
    this.biggestContributorsToApprovedByServiceTracker = new HashMap<String, Float>();
    this.biggestContributorsToProposedByServiceTracker = new HashMap<String, Float>();
  }

  // Adds one row of data from the csv file and recomputes yearly totals as needed
  public void addDataRow(String service, String department, String costCenter, 
    String expenseType, String expenseCategory, String itemDetail, 
    float proposed, float approved, String fund, String fundType) 
  {    
    // add to the grand totals for this year
    this.totalProposed += proposed;
    this.totalApproved += approved; 

    // add to the totals broken down by the name of the service
    if (!this.totalProposedByService.containsKey(service)) {
      this.totalProposedByService.put(service, 0.0);
    }
    Float p = this.totalProposedByService.get(service);
    this.totalProposedByService.put(service, p + proposed);

    if (!this.totalApprovedByService.containsKey(service)) {
      this.totalApprovedByService.put(service, 0.0);
    }
    Float a = this.totalApprovedByService.get(service);
    this.totalApprovedByService.put(service, a + approved);    

    // TODO: So far, this class only aggregates by "service".  We could add additional
    // totals or statistics here if needed...

    // new
    // i mean in theory we do this in order right
    // so we have one hashmap pair for the strings and one hashmap pair for the actual values (floats)
    // we see if proposed / approved is bigger in the float hashmap
    if (!this.biggestContributorsToApprovedByService.containsKey(service)) {
      this.biggestContributorsToApprovedByService.put(service, 
        department + " " + costCenter + " - " + expenseType + " - " + expenseCategory + " - " + itemDetail + " - $" + nfc(int(approved)));
      this.biggestContributorsToApprovedByServiceTracker.put(service, approved);
    }
    if (!this.biggestContributorsToProposedByService.containsKey(service)) {
      this.biggestContributorsToProposedByService.put(service, 
        department + " - " + costCenter + " - " + expenseType + " - " + expenseCategory + " - " + itemDetail + " - $" + nfc(int(proposed)));
      this.biggestContributorsToProposedByServiceTracker.put(service, proposed);
    }

    if (this.biggestContributorsToApprovedByServiceTracker.containsKey(service)) {
      if (approved > this.biggestContributorsToApprovedByServiceTracker.get(service)) {
        this.biggestContributorsToApprovedByService.put(service, 
          department + " - " + costCenter + " - " + expenseType + " - " + expenseCategory + " - " + itemDetail + " - $" + nfc(int(approved)));
        this.biggestContributorsToApprovedByServiceTracker.put(service, approved);
      }
    }
    if (this.biggestContributorsToProposedByServiceTracker.containsKey(service)) {
      if (proposed > this.biggestContributorsToProposedByServiceTracker.get(service)) {
        this.biggestContributorsToProposedByService.put(service, 
          department + " - " + costCenter + " - " + expenseType + " - " + expenseCategory + " - " + itemDetail + " - $" + nfc(int(proposed)));
        this.biggestContributorsToProposedByServiceTracker.put(service, proposed);
      }
    }
    // end new
  }

  // the year for the budget data
  public int getYear() {
    return this.year;
  }

  // the grand total of the proposed budget for this year
  public float getTotalProposed() {
    return this.totalProposed;
  }

  // the grand total of the approved budget for this year
  public float getTotalApproved() {
    return this.totalApproved;
  }

  // an array of strings for the names of the services that appreared in the budget for this year.
  // these are conveniently reported in a sorted array where the first service listed is the one
  // with the largest budget for the year and the last one has the smallest budget.
  public String [] getServices() {
    List<Map.Entry<String, Float> > list = new LinkedList<Map.Entry<String, Float> >(this.totalProposedByService.entrySet());
    Collections.sort(list, new Comparator<Map.Entry<String, Float> >() {
      public int compare(Map.Entry<String, Float> a, Map.Entry<String, Float> b) {
        return (a.getValue()).compareTo(b.getValue());
      }
    }
    );
    Collections.reverse(list);
    String [] rv = new String [list.size()];
    for (int i=0; i<list.size(); i++) {      
      rv[i] = list.get(i).getKey();
    } 
    return rv;
  }

  // returns the total proposed budget for the year for the service category specified, 
  // e.g., the total budget for the "Public Safety" service category.
  public float getTotalProposedByService(String service) {
    if (this.totalProposedByService.containsKey(service)) {
      return this.totalProposedByService.get(service);
    } else {
      return 0.0;
    }
  }

  // returns the total approved budget for the year for the service category specified, 
  // e.g., the total budget for the "Public Safety" service category.
  public float getTotalApprovedByService(String service) {
    if (this.totalApprovedByService.containsKey(service)) {
      return this.totalApprovedByService.get(service);
    } else {
      return 0.0;
    }
  }

  // new
  public String getBiggestContributorToProposedByService(String service) {
    if (this.biggestContributorsToProposedByService.containsKey(service)) {
      return this.biggestContributorsToProposedByService.get(service);
    } else {
      return "N/A";
    }
  }

  public String getBiggestContributorToApprovedByService(String service) {
    if (this.biggestContributorsToApprovedByService.containsKey(service)) {
      return this.biggestContributorsToApprovedByService.get(service);
    } else {
      return "N/A";
    }
  }
}




// This class loads an entire budget csv file and creates multiple YearlyData classes to hold
// the data for each year.
public class BudgetData {
  private HashMap<Integer, YearlyData> dataByYear;

  // Constructor just initializes internal variables
  public BudgetData() {
    dataByYear = new HashMap<Integer, YearlyData>();
  }

  public float getMaxProposedBudget() {
    float maxBudget = 0.0;
    for (int year : dataByYear.keySet()) {
      float proposedBudget = dataByYear.get(year).getTotalProposed();
      if (proposedBudget > maxBudget) {
        maxBudget = proposedBudget;
      }
    }

    return maxBudget;
  }

  public float getMinProposedBudget() {
    float minBudget = this.getMaxProposedBudget();
    for (int year : dataByYear.keySet()) {
      float proposedBudget = dataByYear.get(year).getTotalProposed();
      if (proposedBudget < minBudget) {
        minBudget = proposedBudget;
      }
    }

    return minBudget;
  }

  // This is the key top-level function to call in order to load data from a csv file.
  public void loadFromFile(String fileName) {
    Table rawData = loadTable(fileName, "header");
    for (TableRow rawRow : rawData.rows()) {  
      int fiscalYear = rawRow.getInt("FISCAL YEAR");
      String service = rawRow.getString("SERVICE");
      String department = rawRow.getString("DEPARTMENT");
      String costCenter = rawRow.getString("COST CENTER");
      String expenseType = rawRow.getString("EXPENSE TYPE");
      String expenseCategory = rawRow.getString("EXPENSE CATEGORY");
      String itemDetail = rawRow.getString("ITEM DETAIL");
      Float proposedAmount = rawRow.getFloat("PROPOSED AMOUNT");
      // missing values are reported as NaNs, turn them into 0.0 instead
      if (proposedAmount.isNaN()) {
        proposedAmount = 0.0;
      }
      Float approvedAmount = rawRow.getFloat("ADOPTED AMOUNT");
      // missing values are reported as NaNs, turn them into 0.0 instead
      if (approvedAmount.isNaN()) {
        approvedAmount = 0.0;
      }
      String fund = rawRow.getString("FUND");
      String fundType = rawRow.getString("FUND TYPE");
      // not sure what count_column means
      //int countColumn = rawRow.getInt("count_column");

      if (!dataByYear.containsKey(fiscalYear)) {
        YearlyData yd = new YearlyData(fiscalYear);
        dataByYear.put(fiscalYear, yd);
      }
      dataByYear.get(fiscalYear).addDataRow(service, department, costCenter, expenseType, 
        expenseCategory, itemDetail, proposedAmount, 
        approvedAmount, fund, fundType);
    }
  }

  // Returns a sorted array of years for which YearlyData are available.
  public int [] getYears() {
    Object[] objArray = dataByYear.keySet().toArray();
    Arrays.sort(objArray);
    int[] intArray = new int[objArray.length];
    for (int i=0; i<objArray.length; i++) {
      intArray[i] = ((Integer)objArray[i]).intValue();
    }
    return intArray;
  }

  // Provides access to the YearlyData objects that were constructed after reading the csv file.
  public YearlyData getYearlyData(int year) {
    if (dataByYear.containsKey(year)) {
      return dataByYear.get(year);
    } else {
      return null;
    }
  }
}
