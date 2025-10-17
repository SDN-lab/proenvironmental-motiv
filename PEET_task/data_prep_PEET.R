# Created: "Thu Dec 12 16:13:18 2024"

#NOTE:  If using Prolific or similar to recruit participants, may need to change `id` variable to match the name of your ID variable in your dataset)
#NOTE:  
library(dplyr)

rawdata <- read.csv("qualtrics_data_output.csv", check.names = FALSE) # Name of data file output from Qualtrics, e.g., "Pro-Environmental_Effort_Task_December+3,+2024_08.39.csv" ("check.names=TRUE" keeps column names the same)
cleandata <- rawdata[-c(1:2), ] # remove first two rows of meta data

## Create structured dataframe for boxes task from Qualtrics output --------------
# The output from Qualtrics is a bit messy and in a wide format. Here we create 
#   a long format dataframe that matches the order of the trials from the 
#   Loop & Merge spreadsheet in the Qualtrics task. We recreate the trial order
#   from the spreadsheet and add each participants data to it. The trial orders
#   are randomized between participants, but Qualtrics outputs trials in the same
#   order that they appear in the Loop & Merge spreadsheet of the task.

# Grab choice for each trial #
# There are 24 trials, corresponding to the row number from the Loop & Merge
# spreadsheet. So there are 24 "#_choice_screen" that appear,
# where "#" is the corresponding row number from the Loop & Merge spreadsheet


nsubj = nrow(cleandata) #Qualtrics saves each new participant as a row

# Loops through columns and gets the choice made (3 credits for Rest vs X credits for Y boxes) and recodes to 0 and 1, respectively
choice_data <- sapply(1:24, function(i) {
  dplyr::recode(cleandata[, paste0(i, "_choice_screen")], 
    "3 credits for Rest" = 0,
    "${lm://Field/2} credits for ${lm://Field/3} boxes" = 1,
    .default = NA_real_
  )
})

# Grab work success (clicked all boxes) for each trial #
# If they chose the click boxes option ("work"), then the "_work_feedback_timing_Page.Submit"
#   only appears if they successfully clicked all the boxes on the screen.
work_success_data <- sapply(1:24, function(i) {
  tmp <- as.numeric(cleandata[, paste0(i, "_work_feedback_timing_Page Submit")])
  ifelse(is.na(tmp), 0, 1)
})

## Create a new dataframe, with a structure that can be used to fit models ##
# There are 24 trials in total, so variables need to be repeated to fill all 
#   the rows for each participant.
# Note: the order of the dataframe does not match the order that participants 
#   saw the trials. Qualtrics does not output the trial-order seen, and instead
#   outputs the responses for each trial in the order that they appear in the 
#   Loop & Merge spreadsheet
main_data <- NULL
main_data$id <- rep(cleandata$ResponseId, each = 24) # repeat each ID 24 times to align with number of rows (Note: if using Prolific or similar to recruit participants, can change this variable to whatever your ID variable is called)
main_data$agent <- rep(c("Food", "Climate"), each = 12) # The recipient of the credits
main_data$rew <- rep(c(4,12,20), times = 8*nsubj) # The number of credits for the "work" option
main_data$rew <- factor(main_data$rew, levels = c("4", "12", "20"))
main_data$eff <- rep(c("easy50", "easy65", "hard80", "hard95"), each = 3, times = 2*nsubj) # The effort level for the "work" option. Corresponds to 50%, 65%, 80%, and 95% of max boxes, respectively.
main_data$eff <- factor(main_data$eff, levels = c("easy50", "easy65", "hard80", "hard95"))
main_data$decision <- c(t(choice_data)) # transpose then convert to 1-d vector to put all in one column
main_data$success <- c(t(work_success_data))
main_data$max_boxes <- rep(cleandata$max_boxes, each = 24)
main_data$easy50_nboxes <- rep(cleandata$easy50, each = 24)
main_data$easy65_nboxes <- rep(cleandata$easy65, each = 24)
main_data$hard80_nboxes <- rep(cleandata$hard80, each = 24)
main_data$hard95_nboxes <- rep(cleandata$hard95, each = 24)
main_data <- as.data.frame(main_data)

# Write the cleaned and organised data to a csv file
write.csv(main_data, file = "PEET_data.csv", row.names = FALSE)
