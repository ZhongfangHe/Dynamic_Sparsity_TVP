# Dynamic_Sparsity_TVP
Matlab codes and data spreadsheets for the paper "*Achieving dynamic sparsity in time-varying parameter regressions*" (January 2022, "*ds.pdf*"). Note that all the files should be kept in the same folder to directly run the codes.

**Simulation example:**
The file "*main_simulate_data2.m*" simulates the data used in the simulation study. 3 sets of data are simulated with different noise-to-signal ratios (*S, M, L*). The main results in the paper are for the data with the "small" noise-to-signal ratio ("*Simulated_Data_MS.xlsx*"). The other two datasets are mainly for validation purpose.

The file "*main_sim_github.m*" estimates the DTL and DTS models for the simulated data. One can adjust the number of burn-ins and effective posterior draws through the variables "*burnin*" and "*ndraws*" in the code. Posterior draws and other useful results are stored in the structure array "*draws*".

**Equity premium example:**
The spreadsheet "*Equity_Qtrly_Github.xlsx*" stores the data. In particular the worksheet "*Data*" contains the data to feed into the models. The other worksheet "*RawData*" contains the original raw data.

The file "*main_equity_github.m*" can estimate the DTL and DTS models as well as the alternatives (RMI, DHS, LMI) based on the equity premium data. The variable "*npred*" determines the number of out-of-sample forecasts to be performed. If npred = 0, estimation is conducted based on the full sample and no forecast is performed. If npred > 0, then npred out-fo-sample forecasts are performed based on iterative estimations (it could be time consuming depending on how large npred is). Log predictive likelihoods are the outputs of forecasts. Posterior draws and other useful results are stored in the structure array "*draws*".

**Inflation rate example:**
The spreadsheet "*Inflation_Qtrly_Github.xlsx*" stores the data. The worksheet "*Data2*" contains the data to feed into the models while the other worksheets contain the original raw data.

The file "*main_inflation_github.m*" can estimate the DTL and DTS models as well as the alternatives (RMI, DHS, LMI) based on the inflation rate data. Adjusting the number of forecasts is the same as in the equity premium example. Posterior draws and other useful results are stored in the structure array "*draws*".
