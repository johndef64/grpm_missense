###################### Get and load GRPM Nutrigen Dataset #########################
# Load the required package
library(utils)
library(arrow)

# Verifica la cartella di lavoro corrente
getwd()

# Define the URL and destination file
url <- "https://zenodo.org/records/14052302/files/nutrigenetic_dataset.zip?download=1"
destfile <- "nutrigenetic_dataset.zip"

# Use download.file function to download the zip file
download.file(url, destfile, mode = "wb")

# Extract files from the zip archive
unzip(destfile, exdir = "temp")
list.files("temp")
######



# Caricare i pacchetti necessari
library(arrow)
library(dplyr)

# Carica il dataset Parquet
GrpmNutrigenInt <- read_parquet("temp/nutrigenetic_dataset/grpm_nutrigen_int.parquet")

# Group by 'rsid' and summarize each column by counting distinct values
statistics <- GrpmNutrigenInt %>%
  group_by(rsid) %>%  summarize(across(everything(), ~ length(unique(.)), .names = "unique_{col}"))
statistics


# Define Topic Id
(unique(GrpmNutrigenInt$topic))
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

write.csv(topics_df, "topics_df.csv", row.names = FALSE)


# Display the topics table
(GrpmNutrigenInt <- left_join(GrpmNutrigenInt, topics_df, by = c("topic" = "topic_name")))


# Select Subset by Topic 
topic_df = GrpmNutrigenInt %>% filter(topic_id == 1)

statistics <- topic_df %>%
  group_by(rsid) %>%
  summarize(across(everything(), ~ length(unique(.)), .names = "unique_{col}"))
statistics


##################### Get Varian Annotations ##################### 
library(biomaRt)
#library(GenomicRanges)
#library(VariantAnnotation)

# Definisci la funzione per ottenere le annotazioni delle varianti
get_variant_annotations <- function(rsids) {
  # Collega a Ensembl usando il pacchetto biomaRt
  ensembl <- useEnsembl(biomart = "snp", dataset = "hsapiens_snp")
  
  # Recupera le annotazioni per la lista di RSID
  annotations <- getBM(
    attributes = c('refsnp_id', 'chr_name', 'chrom_start', 'consequence_type_tv', 'allele'),
    filters = 'snp_filter',
    values = rsids,
    mart = ensembl
  )
  
  return(annotations)
}

##########

file_name <- "VarAnnotations_GrpmNutrigenInt.parquet"

if (!file.exists(file_name)) {
# Chiamata alla funzione per ottenere le annotazioni
annotations <- get_variant_annotations(unique(GrpmNutrigenInt$rsid))

# Visualizza le annotazioni
print(annotations)
c(unique(annotations$refsnp_id) %>% length(), unique(GrpmNutrigenInt$rsid) %>% length()) 

# Save the annotations to a parquet file
write_parquet(annotations, file_name)

}

# Iport annotation back
(annotations <- read_parquet(file_name))



###########  Add Topics to Annotations ###############

result <- GrpmNutrigenInt %>%
  group_by(rsid) %>%
  summarise(topics_list = list(unique(topic_id)))#paste(unique(topic_id), collapse = ", "))

result$topics_list[6]

annotation_topics <- left_join(annotations, result, by = c("refsnp_id" = "rsid"))

# explode
library(tidyr) 
# Explode the 'topics_list' column
result.EXP <- annotation_topics %>%
  unnest(topics_list) %>%
  rename(topic_id = topics_list)



write_parquet(arrange(result.EXP, topic_id)
, "VarAnnotations_GrpmNutrigenInt_AllTopics.parquet")


#################  PROTVAR  ######################


unique(annotation_topics$refsnp_id )


missense_only <- filter(annotation_topics, c(consequence_type_tv == "missense_variant"))

# Ottieni gli ID unici 'refsnp_id'
unique_refsnp_missense <- unique(missense_only$refsnp_id)

# Scrivi gli ID unici in un file di testo, un ID per riga
writeLines(unique_refsnp_missense, "nutrigenint_refsnp_missense.txt")
# PASS RSID LIST TO WEB APP https://www.ebi.ac.uk/ProtVar/

# Import CSV file as tibble and convert it to parquet
protvar_file_name <- "ProtVar_GrpmNutrigInt_MissenseAnnotations"
(protvar_data <- read_csv(paste0(protvar_file_name, ".csv")))
# Save the annotations to a parquet file
write_parquet(protvar_data, paste0(protvar_file_name, ".parquet"))
protvar_data <- read_parquet(paste0(protvar_file_name, ".parquet"))



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
(topics_df  <- read_csv("topics_df.csv"))
(GrpmNutrigenInt <- left_join(GrpmNutrigenInt, topics_df, by = c("topic" = "topic_name")))


# Save the annotations to a parquet file
protvar_file_name <- "ProtVar_GrpmNutrigInt_MissenseAnnotations"
protvar_data <- read_parquet(paste0(protvar_file_name, ".parquet"))


# Get ProtVar annotation for each Topic
topic_id <- 2    # Select Topic Id
GrpmTopic = GrpmNutrigenInt %>% filter(topic_id == topic_id)

(filtered_data <- protvar_data[protvar_data$ID %in% GrpmTopic$rsid, ])
cat("Displaying ProtVar Data for", topics_df$topic_name[topics_df$topic_id == topic_id], "\n")


