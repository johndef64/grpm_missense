library(arrow)
library(tidyverse)

imp <- function(x) {
  x %>% 
    separate(`Residue_function_(evidence)`,
             into=c("one","bob"), sep = "-", extra="merge") %>%
    count(Protein_catalytic_activity, one,sort=T)
}

imp2 <- function(x) {
  x %>%
  select(`Foldx_prediction(foldxDdg;plddt)`) %>%
  separate(`Foldx_prediction(foldxDdg;plddt)`,
           into = c("fx","plddt"), sep=";") %>%
  select(fx) %>%
  filter(fx != "N/A") %>%
  mutate(fx = gsub("foldxDdg:","",fx)) %>%
  mutate(fx = as.numeric(fx))
}

imp3 <- function(x) {
  x %>% 
select(dav = Diseases_associated_with_variant) %>%
separate_rows(dav, sep="\\|") %>%
separate(dav, into =c("one","dum"),
         sep = "-\\(", extra="merge") %>%
         select(one) %>%
         distinct
}

imp4 <- function(x) {
  x %>%
   select(am=`AlphaMissense_pathogenicity(class)`) %>%
   filter(am != "N/A") %>%
   separate(am, into = c("score","class"),sep ="\\(") %>%
   mutate(score=as.numeric(score), class=gsub(")$","",class))  
}

GrpmNutrigenInt <- read_parquet("temp/nutrigenetic_dataset/grpm_nutrigen_int.parquet")
protvar_file_name <- "ProtVar_GrpmNutrigInt_MissenseAnnotations"
protvar_data <- read_parquet(paste0(protvar_file_name, ".parquet"))

rsids <- GrpmNutrigenInt %>%
 select(topic,rsid) %>%
 split(.$topic, .$rsid)

did <- rsids %>%
 enframe %>%
 mutate(dfs = map(value, function(x) filter(protvar_data, ID %in% x$rsid)))

#col 30,32,33,35 is interaction/predict.int/fx/amiss

dud <- did %>% #remember to use the RDS
 mutate(asd = map(dfs, imp))

dud2 <- did %>% #remember to use the RDS
 mutate(fix = map(dfs,imp2))

dud3 <- did %>% #remember to use the RDS
 mutate(fix = map(dfs,imp3))

dud4 <- did %>% #remember to use the RDS
 mutate(am = map(dfs,imp4))

did %>%
 mutate(snp_count = map_int(value,nrow),
        missense_count = map_int(dfs,nrow),
        miss_gene_count = map_int(dfs, function(x) n_distinct(x$Gene)),
        missense_snp_ratio= round(missense_count/snp_count,2)) %>%
 select(-value,-dfs) %>%
  write.table(pipe("xsel -b"), row.names = F, quote = F, sep = ";")

dud %>%
  select(name,asd) %>%
  unnest(asd) %>%
  group_by(name) %>%
  mutate(n = round(n/sum(n),3)) %>%
  ungroup %>%
  pivot_wider(names_from = one, values_from = n, values_fill = 0)

fx_bins <- dud2 %>%
  select(name,fix) %>%
  unnest(fix) %>%
  mutate(bin = cut(fx, breaks = c(-Inf, -4, -2, 0, 2, 4, Inf))) %>%
  count(name, bin)

fx_plot <- ggplot(fx_bins, aes(y = name, x = n, fill = bin)) +
  geom_col(position = "fill") +
  scale_x_reverse()

am_plot <- dud4 %>%
  select(name,am) %>%
  unnest(am) %>%
  mutate(class = fct_relevel(class, "BENIGN")) %>%
  ggplot(aes(y=name,fill=class)) +
         geom_bar(position="fill") +
  scale_x_reverse() +
  scale_fill_manual(values = c("BENIGN" = "dodgerblue", "AMBIGUOUS" = "orange",
                               "PATHOGENIC" = "firebrick"))

binary_matrix <- dud3 %>%
  select(name,fix) %>%
  unnest(fix) %>% 
  distinct(name,one) %>%
  pivot_wider(names_from=name, values_from = name, values_fn = length,
              values_fill = 0) %>%
  column_to_rownames("one")

ComplexUpset::upset(binary_matrix, intersect = colnames(binary_matrix),
    base_annotations=list(
        'Intersection size' = ComplexUpset::intersection_size(
            text=list(
                vjust=0.45,
                hjust=-0.1,
                angle=90
            )
        )
    ),
      min_size=10)
