# Capital Bikeshare Data Analysis
## Measuring the First and Last Mile solution provided by Capital Bikeshare to Metro riders in the Washington, D.C. metropolitan area.

---

### Terminology

Source station:	The station from which the rider enters the system and begins a ride.

Target station:	The station from which the rider exits the system and complete a ride.

Ride:	The unit of measure of the data: each ride consists of a Source and Target station as well as the time of entry into the Source station and time of exit from the Target station.

Bikeshare:	A 3rd generation bicycle sharing system: defined as a system with membership rates and bicycle Source and Target station tracking system. This analysis uses the D.C. region’s Capital Bikeshare system rider data. Ridership hit 2,100,000+ rides in 2015.

Metro:	The WMATA’s rapid transit system servicing Washington, D.C. metropolitan area with 271,160,000 rides in 2014. The data includes Source and Target stations for each ride.

First and Last Mile:	A part of a multimodal transportation solution where riders start or complete their journey by some other mode of transportation that is in addition to a primary transportation solution. The First Mile being at the onset of the entire trip, and the Last Mile being the finale of the entire trip. For example, walking to the bus stop where the bus will take you to work (walking = First Mile solution), or riding a Bikeshare bicycle to work from a Metro station you just exited (riding = Last Mile solution).

---

### Objective

Use the relationship between ridership on Metro and ridership on Capital Bikeshare to measure the Last and First Mile rides on Capital Bikeshare. Relating the rush-hour periodicity of both systems will allow for filtering of the Bikeshare rides. These rides can be geographically evaluated to measure their likelihood of being a Last or First Mile ride.

---

### Hypotheses

A rise in Metro ridership will coincide with a rise in ridership on nearby Bikeshare stations due to First and Last Mile riles, with possible periodicity phasing such that a First and Last Mile relationships can be inferred from signal position as well as geographic context.

---

### Methods

So far, a PostgreSQL PostGIS-enabled database with R scripts to build charts for visually assessing signal relationship. See Figures 1-3 below for the ridership at Union Station Metro station and the nearby Capital Bikeshare station on June 3rd, 2015.

Many ranges of certain parameters (time duration used to bin the data, possibly averaged data) will be tested for their sensitivity and ability to describe the signal changes. A Python script utilizing NumPy will be utilized to measure signal strengths and relationships. Integration with R for certain signal processing algorithms might be necessary, similar to the attached R script that runs the final SQL query through the R script on pre-processed PostgreSQL tables.

To evaluate each ride against a likelihood of it being a Last or First Mile ride, each Target Bikeshare station should be less than a 30 minute ride from the Source Bikeshare station. Using a service like Google Maps Directions API to provide bicycle directions for each Target and Source Bikeshare station, the stations can be attributed as within or outside of the Last and First Mile range. Different types of First and Last Mile rides could be evaluated as well. Maybe on nicer days, people ride further.

---

### Expected Results

The final result will be a successful implementation of the methodology and a mapping solution that can communicate the First and Last Mile empirically derived measure, most likely a magnitude. A simple drawing below is an example map that would include the geographic restrictions on the analysis in order to communicate the importance of the 30 minute distance restriction on the likelihood of a trip being First or Last Mile.

---

### References

"Transit Ridership Report Fourth Quarter and End-of-Year 2014" (pdf). American Public Transportation Association. March 3, 2015. Retrieved 2016-03-03. <http://www.apta.com/resources/statistics/Pages/ridershipreport.aspx>.

“How to use the cross-spectral density to calculate the phase shift of two related signals.” StackExchange. February 10, 2014. Retrieved 2016-03-03. <http://stackoverflow.com/questions/21647120/how-to-use-the-cross-spectral-density-to-calculate-the-phase-shift-of-two-relate>.

“Capital Bikeshare.” Wikipedia. Retrieved 2016-03-03. <https://en.wikipedia.org/wiki/Capital_Bikeshare>.