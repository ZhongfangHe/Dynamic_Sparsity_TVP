# Dynamic_Sparsity_TVP
Matlab codes and data spreadsheets for the paper "*Locally time-varying parameter regression*". Note that all the files should be kept in the same folder to run the codes.

**Simulation example:**
The file "*main_sim_github.m*" estimates the models for the simulated data. One can adjust the number of burn-ins and effective posterior draws through the variables "*burnin*" and "*ndraws*" in the code. Posterior draws and other useful results are stored in the structure array "*draws*".

**Equity premium example:**
The spreadsheet "*Equity_Qtrly_Github.xlsx*" stores the data. In particular the worksheet "*Data*" contains the data to feed into the models. The other worksheet "*RawData*" contains the original raw data.

The file "*main_equity_github.m*" estimates the models based on the equity premium data. The variable "*npred*" determines the number of out-of-sample forecasts to be performed. If npred = 0, estimation is conducted based on the full sample and no forecast is performed. If npred > 0, then npred out-fo-sample forecasts are performed based on iterative estimations (it could be time consuming depending on how large npred is). Log predictive likelihoods are the outputs of forecasts.

**Industrial output example:**
The spreadsheet "*Industrial_Output_Github.xlsx*" stores the data. The worksheet "*Data*" contains the data to feed into the models while the other worksheet contains the original raw data.

The file "*main_industrial_output_github.m*" estimates the models based on the industrial output data. Adjusting the number of forecasts is the same as in the equity premium example. Posterior draws and other useful results are stored in the structure array "*draws*".
