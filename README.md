### This folder contains the resources scripts and functions to:

- ### 1. Collect your own data using the PEET via Qualtrics

- ### 2. Analyse the data:
- #### i) effort-discounting models (with expectation maximisation; em) on participant data [subfolder Model_real_data]
- #### ii) model identifiability and parameter recovery [subfolder Model_simulated_data]
- #### iii) analysis on the model parameters, trial by trial behavioural data [subfolder PM_R_code]

[Click here to view plots and main results](https://github.com/SDN-lab/proenvironmental-motiv/blob/main/PM_R_code/Climate_effort_analysis.md)

### To collect data:

Download Qualtrics .qsf file from the PEET_task folder: Pro-Environmental_Effort_Task.qsf

After collecting data, use the data_prep_PEET.R file to wrangle the Qualtrics output to a long format dataframe

### For analysis of the real participant data (i & iii):

#### Step 1 - Download and convert data to the required format 

#### Step 2 - Run_em_model.m 
Script to run and compare models using expectation maximisation fit

##### Output from script
   - matlab variables
   	- 's.PM.em'  - contains model results including the model parameters for each participant
   - datafiles in specified output directory:
       - EM_fit_parameters_all.csv - estimated parameters for each participant
       - PM_model_fit_statistics_all - model fits
     
#### Step 3 - Create data files of trial by trial behavioural data (see LMMs_final_full.csv)

#### Step 4 - Climate_effort_analysis.Rmd
Run analysis using R project, script, and files from above output (note sections of this script also plot results from simulation experiments - model identifiability and parameter recovery - see below and use results from lesion analysis).

### For simulation experiments (ii):

#### Step 1 - Simulate_PR_MI_data_PM.m 
Script to run model identifiability and / or parameter recovery

#### Step 2 - Climate_effort_analysis.Rmd 
Plot results using R script

### Prosocial effort discounting models 
Based on [Lockwood et al. (2017), *Nature Human Behaviour*](https://doi.org/10.1038/s41562-017-0131) - test different variations of k and beta parameters

#### Models compared combine all combinations of single or separate k and single or separate beta parameters:
##### - two_k_one_beta
##### - two_k_two_beta
#### and different shapes for the discounting (k) parameter:
##### - parabolic 
##### - linear
##### - hyperbolic  

### Developed using:

MATLAB 2019b - requires Econometrics and Bioinformatics toolboxes

macOS 10.15 Catalina / 11.1 Big Sur

R version 3.6.2 (2019-12-12)
