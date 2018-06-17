# Unsure

A simple app to efficiently account for multiple independent sources of uncertainty in complex predictive models

---

Unsure approximates the user's model with a Cobb-Douglas function to rapidly estimate results with any combination of input values. It requires that the user already has a working model and has run a standard sensitivity analysis.

# Inputs

inputDistributions.csv is a table of the potential values of uncertain inputs, and their associated probabilities

* id - ID of the input variable
* name - name of the input variable
* value - value of the input variable
* probability - probability that input variable has this value

inputElasticities.csv is a table of the results of a sensitivity analysis of the user's model

* id - ID of the input variable
* name - name of the input variable
* base_value - default value of input variable
* elasticity - elasticity of model output with respect to input variable

# Run

1. Run server.R or ui.R in R
2. Navigate to default port in a browser
3. Upload inputDistributions.csv and inputElasticities.csv
4. View Cumulative Distribution Function (CDF) and table (Stats) of potential results
5. Select input variables and values under *Explorer* to highlight filtered results
6. Download CSV of results under *Output*
