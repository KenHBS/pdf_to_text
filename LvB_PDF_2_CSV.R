library(httr)
library(rvest)
library(pdftools)

## 0. Functions for the script 
## 1. Scrape table-info from CRC 649 page 
## 2. Scrape & save full PDF articles of CRC 649
## 3. Extract text, organize and save to CSV

##################################################################### 


### 0. Functions for the script:
clean_text <- function(text){
  text = gsub("[^ a-zA-Z]", "", text)               # Keep space and letters
  text = gsub("\\s[A-Za-z]\\s", "", text)           # Rm single chars
  text = gsub("\\s{3,}\\S{1,6}\\s{3,}", "", text)   # Rm short words surrounded by 3+ space
  text = gsub("\\s{5,}\\S{6,15}\\s{5,}", "", text)  # Rm longer words surrounded by 5+ space
  text = gsub("\\s+", " ", text)
  return(text)
}

pdf_to_charvec <- function(pdf){
  pdf_txt = pdftools::pdf_text(pdf)
  pdf_txt = pdf_txt[-1]
  pdf_txt = paste0(pdf_txt, collapse=" ")
  pdf_txt = clean_text(pdf_txt)
  return(pdf_txt)
}

clean_jels <- function(jelstring){
  jelstring = gsub("[^A-Z0-9]", " ", jelstring)
  jelstring = gsub("\\s+", " ", jelstring)
  return(jelstring)
}


### 1. Get the table-info from the CRC 649 page: ###
drc = POST("http://sfb649.wiwi.hu-berlin.de/fedc/discussionPapers_formular_content.php", 
           body = list(filterTypeName = "filterTypeName:AUTHORS", 
                       filteryear = "all", 
                       B1 = "Search"), 
           encode = "form")
abstr_info = read_html(drc) %>% 
  html_nodes("body")  %>% 
  html_nodes("tbody") %>% 
  html_nodes("tr")    %>% 
  html_nodes("tr")    %>% 
  html_nodes("table") %>% 
  html_table(header=NA, fill=TRUE)
abstr_info = abstr_info[4][[1]]

# Only retain article ID, Title and JEL codes
abstr_info = abstr_info[ , c(1,2,6) ]
colnames(abstr_info) = c("id", "title", "jel")
abstr_info = abstr_info[-nrow(abstr_info), ]


### 2. Get the URLs and download PDFs to CRC folder
from_here = paste0("http://sfb649.wiwi.hu-berlin.de/papers/pdf/SFB649DP", abstr_info$id, ".pdf")
dir.create("CRC"); setwd("CRC")
to_here = paste0(abstr_info$id, ".pdf")
base::mapply(download.file, url=from_here, destfile=to_here)


### 3. Extract text, organize and save to CSV
# Extract, clean and save the text from the PDF
to_here = list.files()

articles = sapply(to_here, pdf_to_charvec)
ids = names(articles)
ids = substr(ids, 0, nchar(ids)-4)

# Reorder the JEL codes to ensure correctness
i <- 1
vec <- c()
for(val in ids){
  vec[i] <- which(abstr_info$id==val)
  i <- i+1
}
jel_codes = abstr_info$jel[vec]
jel_codes = clean_jels(jel_codes)

# Create data.frame and save it to CSV
df <- data.frame(ids = ids, 
                 texts = articles,
                 jels = jel_codes, stringsAsFactors=FALSE)
write.csv2(x=df, file="LvB_fulldocs.csv", row.names=FALSE)
