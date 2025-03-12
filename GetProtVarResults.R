# IMPORT RESULTS
library(readr)
library(utils)
library(arrow)

if (!file.exists("temp/nutrigenetic_dataset/grpm_nutrigen_int.parquet")) {
  
  # Verifica la cartella di lavoro corrente
  getwd()
  
  # Define the URL and destination file
  url <- "https://zenodo.org/records/14052302/files/nutrigenetic_dataset.zip?download=1"
  destfile <- "nutrigenetic_dataset.zip"
  
  # Use download.file function to download the zip file
  download.file(url, destfile, mode = "wb")
  
  # Extract files from the zip archive
  unzip(destfile, exdir = "temp")
  
}

# Carica il dataset Parquet
GrpmNutrigenInt <- read_parquet("temp/nutrigenetic_dataset/grpm_nutrigen_int.parquet")
# Display the topics table
# List of topics
topics <- c("General Nutrition", 
            "Obesity, Weight Control and Compulsive Eating", 
            "Diabetes Mellitus Type II and Metabolic Syndrome", 
            "Cardiovascular Health and Lipid Metabolism", 
            "Vitamin and Micronutrients Metabolism and Deficiency-Related Diseases", 
            "Eating Behavior and Taste Sensation", 
            "Food Intolerances", 
            "Food Allergies", 
            "Diet-induced Oxidative Stress", 
            "Xenobiotics Metabolism")

# Create a data frame with topic IDs
(topics_df <- data.frame(
  topic_id = 1:length(topics),
  topic_name = topics,
  stringsAsFactors = FALSE
))
(GrpmNutrigenInt <- left_join(GrpmNutrigenInt, topics_df, by = c("topic" = "topic_name")))

# Import CSV file as tibble
(protvar_data <- read_parquet("ProtVar_GrpmNutrigInt_MissenseAnnotations.parquet"))


###### Get ProtVar annotation for each Topic ######

# Select Topic Id [1:10]
topic_id <- 1    
GrpmTopic = GrpmNutrigenInt %>% filter(topic_id == topic_id)

(filtered_data <- protvar_data[protvar_data$ID %in% GrpmTopic$rsid, ])
cat("Displaying ProtVar Data for", topics_df$topic_name[topics_df$topic_id == topic_id], "\n")
